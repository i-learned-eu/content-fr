Author: Ramle
Date: 
Slug: secure_boot_pratice
Title: Mise en pratique de secure boot
Summary:

Nous avions, dans un article précédant, parlé de la théorie autour de secure boot, dans l'article du jour nous allons voir comment mettre en œuvre. Je vais pour l'exemple utiliser une machine sous ArchLinux avec systemd-noot en bootloader. La marche à suivre reste cependant très similaire pour d'autre configuration logiciel. 

# Quelques rappels théorique

Avant de commencer rappelons la chaine de clé utile à secure boot :

![La chaine de confiance de Secure Boot](https://ilearned.eu/static/img/secure_boot/Cl_secure_boot(1).webp)

On va donc devoir remplacé la chaine de clé présente de base dans l'UEFI pour mettre des clés qu'on aura généré. Dans le cas ou vous avez un Dualboot avec Windows il faudra rajouté les clés utilisée pour le signer dans la DB.

# Mise en pratique

Avant de commencer on peut installer le paquet  `sbsigntools`.

On doit commencer par générer les différentes les différentes clés et certificat. Pour ma pars j'ai mis les clés dans `/etc/efi-keys/`.

```
NAME=<nom utilisez pour les certificats>

openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$NAME PK/" -keyout PK.key \
        -out PK.crt -days 3650 -nodes -sha256
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$NAME KEK/" -keyout KEK.key \
        -out KEK.crt -days 3650 -nodes -sha256
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$NAME DB/" -keyout DB.key \
        -out DB.crt -days 3650 -nodes -sha256
openssl x509 -in PK.crt -out PK.cer -outform DER
openssl x509 -in KEK.crt -out KEK.cer -outform DER
openssl x509 -in DB.crt -out DB.cer -outform DER

GUID=$(uuidgen)
echo $GUID > myGUID.txt

cert-to-efi-sig-list -g $GUID PK.crt PK.esl
cert-to-efi-sig-list -g $GUID KEK.crt KEK.esl
cert-to-efi-sig-list -g $GUID DB.crt DB.esl
rm -f noPK.esl
touch noPK.esl

sign-efi-sig-list -t "$(date --date='1 second' +'%Y-%m-%d %H:%M:%S')" \
                  -k PK.key -c PK.crt PK PK.esl PK.auth
sign-efi-sig-list -t "$(date --date='1 second' +'%Y-%m-%d %H:%M:%S')" \
                  -k PK.key -c PK.crt PK noPK.esl noPK.auth
sign-efi-sig-list -t "$(date --date='1 second' +'%Y-%m-%d %H:%M:%S')" \
                  -k PK.key -c PK.crt KEK KEK.esl KEK.auth
sign-efi-sig-list -t "$(date --date='1 second' +'%Y-%m-%d %H:%M:%S')" \
                  -k KEK.key -c KEK.crt db DB.esl DB.auth

chmod 0600 *.key
```

Une fois les différentes clés générées on peut commencer à signer les fichier EFI. Dans le cas ou on utilise (spécifique à systemd-boot et arch, il faut adaptez si vous utilisez autre chose) :




```
find /boot -type f ( -name vmlinuz-* -o -name systemd* ) -exec /usr/bin/sh -c 'if ! /usr/bin/sbverify --list {} 2>/dev/null | /usr/bin/grep -q "signature certificates"; then /usr/bin/sbsign --key /etc/efi-keys/DB.key --cert DB.crt --output "$1" "$1"; fi' _ {}
```

On peut aussi signer copier l'utilitaire KeyTool dans la partition EFI, cet outil permet de pousser nos clés dans les variables UEFI.

```
sbsign --key db.key --cert DB.crt --output /boot/EFI/Linux/KeyTool-signed.efi /usr/share/efitools/efi/KeyTool.efi
```



Il nous faut ensuite activé le "setup mode" de secure boot depuis l'UEFI. Puis démarrer sur KeyTool (normalement systemd-boot le propose de lui même).
