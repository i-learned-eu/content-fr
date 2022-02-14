Title: A quoi sert initramfs
Keywords: Linux, init, initramfs, boot
Date: 2022-02-14
Slug: initramfs
Author: Ownesis
Summary: Dans cet article, on va voir ce qu'est et à quoi sert initramfs

# Pour la faire courte
Initramfs est un [système de fichier](https://ilearned.eu/fat.html) monté dans la [RAM](https://en.wikipedia.org/wiki/Random-access_memory) lors de l'initialisation du [noyau (kernel)](https://fr.wikipedia.org/wiki/Noyau_de_syst%C3%A8me_d%27exploitation).

# Un peu plus de détails
Initramfs est présenté sous forme d'archive [cpio](https://fr.wikipedia.org/wiki/Cpio), c'est en quelque sorte l'ancêtre de [tar](https://doc.ubuntu-fr.org/tar).
> Pourquoi ne pas utiliser tar ?? 🧐 

Tout simplement parce que le code était plus facile à mettre en oeuvre dans Linux et qu'il prend en charge des fichiers de périphériques, contrairement à `tar`.

L'archive contient les fichiers, scripts, bibliothèques, fichiers de configuration, et d'autres qui peut ou pourrait être utile au noyau pour monté le vrai système de ficier racine `root`.
Cette dernière est ensuite compressé avec [gzip](https://fr.wikipedia.org/wiki/Gzip) et est stocké au coté du noyau [Linux](https://en.wikipedia.org/wiki/Linux_kernel) qui est sous le nom "`vmlinuz`" dans `/boot/` (pour du l'UEFI) ou à la racine `/` pour du BIOS.
> vmlinuz ? 🤨

Oui, c'est le nom du binaire du noyau Linux, vmlinuz est compressé en [Bzip](http://www.bzip.org/) (pour ma part).
en réalité, vimlinuz cache un vmlinux qui est lui le binaire du noyau, (le **z** à la place du **x** de Linu**x** c'est tout simplement pour precisé qu'il est compréssé (**z**ip)
je vous laisse lire [cet article](https://www.lojiciels.com/quest-ce-que-vmlinuz-sous-linux/#Qursquoest-ce_que_vmlinuz_et_Initramfs) qui explique un peu ce que je vous explique ici, mais le plus intéréssant étant "l'histoire" du nom "vmlinuz".

# A quoi ressemble le contenu d'un initramfs
Voyons ca étape par étape (si jamais l'envie vous prend de regarder votre initramfs (si vous en avez un).

Dabord on copie notre initramfs dans un dossier, dans`/tmp` pour jouer l'immersion à fond 🤓 (*/tmp étant NORMALEMENT monté en `tmpfs`, comme le système de fichier connu de Linux et dans le quel sera extrait le contenu de notre initramfs*)

Si vous exécuté la commande `file` sur votre initramfs, vous verrez:
```
initramfs-linux.img: Zstandard compressed data
```

Il faut donc le décompressé, avec l'outil `zstd` ou, comme moi, utiliser `zstdcat` pour afficher le contenu décompressé et envoyer la sortie (stdout) vers l'entrée (stdin) de `cpio` qui permet de désarchiver un fichier `cpio`.

> Si vous n'êtes pas root, vous n'avez certainement pas le droit de lire le dit fichier, executer donc la commande si dessous avec `sudo` ou `doas`, ou alors donnez vous les droits de lecture (avec `chmod`).

`zstdcat initramfs-linux.img | cpio -i`

Si vous listez le contenu de votre dossier vous verrez quelque chose de familier, une hiérarchie à la Unix  avec les répertoires de base:

```
ilearned:/tmp ➜  ls -l
total 8708
lrwxrwxrwx 1 ownesis ownesis       7 14 févr. 11:32 bin -> usr/bin
-rw-r--r-- 1 ownesis ownesis    2510 14 févr. 11:32 buildconfig
-rw-r--r-- 1 ownesis ownesis      64 14 févr. 11:32 config
drwxr-xr-x 2 ownesis ownesis      40 14 févr. 11:32 dev
drwxr-xr-x 3 ownesis ownesis     160 14 févr. 11:32 etc
drwxr-xr-x 2 ownesis ownesis      60 14 févr. 11:32 hooks
-rwxr-xr-x 1 ownesis ownesis    2093 14 févr. 11:32 init
-rw-r--r-- 1 ownesis ownesis   13140 14 févr. 11:32 init_functions
lrwxrwxrwx 1 ownesis ownesis       7 14 févr. 11:32 lib -> usr/lib
lrwxrwxrwx 1 ownesis ownesis       7 14 févr. 11:32 lib64 -> usr/lib
drwxr-xr-x 2 ownesis ownesis      40 14 févr. 11:32 new_root
drwxr-xr-x 2 ownesis ownesis      40 14 févr. 11:32 proc
drwxr-xr-x 2 ownesis ownesis      40 14 févr. 11:32 run
lrwxrwxrwx 1 ownesis ownesis       7 14 févr. 11:32 sbin -> usr/bin
drwxr-xr-x 2 ownesis ownesis      40 14 févr. 11:32 sys
drwxr-xr-x 2 ownesis ownesis      40 14 févr. 11:32 tmp
drwxr-xr-x 5 ownesis ownesis     140 14 févr. 11:32 usr
drwxr-xr-x 2 ownesis ownesis      60 14 févr. 11:32 var
-rw-r--r-- 1 ownesis ownesis       2 14 févr. 11:32 VERSION
```

Je vous laisse vous balader dans les différents répoertoires disponible. Par exemple dans `bin` qui pointe vers (`usr/bin`), vous verrez des outils comme:

- `bzip` 
- `mount`
- `fsck.ext4`
- `tftp` qui a un article dédié [ici](https://ilearned.eu/tftp.html) 😜
- `lsmod`
- `rmmod`

et plein d'autres encore...

> la plus part des outils présent dans initramfs sont disponible via un seul et même binaire qui est [busybox](https://www.busybox.net/)

# Processus de démarrage
On commence à partir du [chargeur d'hamorcage (bootloader)](https://fr.wikipedia.org/wiki/Chargeur_d%27amor%C3%A7age), [GRUB](https://www.gnu.org/software/grub/) par exemple.

1. GRUB charge Linux et l'image initramfs dans la mémoire puis démarre le noyau (Linux).
2. Linux vérifie la présence d'un initramfs, si il en trouve il créer un système de fichier [tmpfs](https://doc.ubuntu-fr.org/tmpfs) et y extrait et monte l'initramfs.
3. Dans ce même système de fichier (tmpfs), le noyau exécute le script init.
4. Le script init monte le système de fichier racine `root`, en chargeant des modules du noyau utile pour le montage grace au différents script/programme et autre utilitaires présent dans l'initramfs (au besoin) et monte aussi les systèmes de fichiers comme `/var` et `/usr`.
5. Une fois la racine monté, le script init commute la racine de tmpfs vers le système de fichier précedement monté.
6. Une fois la racine changé, le script init exécute le binaire `/sbin/init` pour continuer le processus de démarrage (en lancant des services/démons pout lancer le système).

# Utilité d'un initramfs
Un initramfs n'est pas obligatoire, si on install une [distribution](https://fr.wikipedia.org/wiki/Distribution_Linux) Linux qui permet de compilé sa propre version du noyau ainsi que sa configuration, une image initramfs n'est pas nécéssaire car le système est connu d'avance.
Dans d'autre distributions, il y'a beaucoup d'inconnues pour le noyau, comme le type de système de fichiers par exemple, ce qui demande de charger certains modules dans le noyau ou d'avoir besoin de certains scripts/programmes.
Généralement, ce sont les modules Linux qui pousse l'utilisation d'un initramfs.

Mais pour un exemple, imaginez une infrastructure ou tout les dossiers `/home` sont sur une autre machine, Linux est normalement incapable à lui tout seul de pouvoir se connecter à une machine distante sur le réseau de l'entreprise, pour ce faire, il utilise initramfs, qui possède tout une panoplie d'outils comme le paquet `iproute`, `dhcp`, `mount`, etc
qui va permettre de monter un [nfs](https://fr.wikipedia.org/wiki/Network_File_System) (par exemple) depuis la machine distante qui partage les dossier utilisateurs.

# Conclusion
L'initramfs est un "mini" système de fichier compressé contenant tout une hiérarchie de système Linux avec des outils utile pour le montage du système de fichier racine de votre machine.
Mais il n'est pas obligatoire.

sources:
 - [wiki.gentoo.org](https://wiki.gentoo.org/wiki/Initramfs/Guide/fr)
 - [fr.linuxfromscratch.org](https://www.fr.linuxfromscratch.org/view/blfs-svn/postlfs/initramfs.html)
