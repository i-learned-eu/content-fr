lang: fr
Authors: Ownesis, Eban, Elmar
Date: 2022-07-09
Keywords: malware, sécurité
Slug: xorddos
Summary: Par un heureux hasard, un fichier nommé `libudev.so`, apparemment malveillant, est apparu dans notre dossier Téléchargements, nous avons donc voulu en savoir plus. Entre reverse engineering, analyse réseau et OSINT, c’est cette quête d’information qui nous mènera à découvrir un mystérieux pirate, vouant une adoration à ses cochons, que nous allons relater dans cet article.
Title:  Un malware, un cochon et un APT chinois
Category: Cybersécurité

Par un heureux hasard, un fichier nommé `libudev.so`, apparemment malveillant, est apparu dans notre dossier Téléchargements, nous avons donc voulu en savoir plus. Entre reverse engineering, analyse réseau et OSINT, c’est cette quête d’information qui nous mènera à découvrir un mystérieux pirate, vouant une adoration à ses cochons, que nous allons relater dans cet article.

<br />

Le sample analysé tout au long de cet article est disponible [ici](https://bazaar.abuse.ch/sample/8642022960d919321ccfcfb0a0cd631db0e5dac3e75014fc0c4cc6ff413c72c5/).

*Disclaimer : I Learned ne saurait en aucun cas être responsable de tout dommage engendré par la manipulation du fichier présent ci-dessus, nous rappellons en outre que la distribution de malware à des fins malveillantes est illégale. En outre, l'attribution d'un malware à un acteur malveillant est un processus périlleux, l'analyse qui suit est donc à lire en gardant en tête qu'il ne s'agit que de suppositions.*

<br />

L’image ci-dessous est une cartographie des informations récoltées dans cette enquête, elle a été faite sur [Maltego](https://www.maltego.com/), nous l'utiliserons tout au long de cet article !

![Graphique maltego des informations trouvées](/static/img/xorddos/maltego-global-view.webp)

# 👀 Premières analyses

Notre premier réflexe à la vue de ce supposé malware est de le [scanner dans un logiciel antivirus (VirusTotal)](https://www.virustotal.com/gui/file/8642022960d919321ccfcfb0a0cd631db0e5dac3e75014fc0c4cc6ff413c72c5/detection). Le résultat est sans appel, de nombreux éditeurs d'antivirus détectent ce malware et le nomment, "XorDDoS".

![Le malware est détecté par une grande majorité de logiciels antivirus.](/static/img/xorddos/virustotal.webp)

Après plusieurs recherches on peut observer que ce malware est en fait une version d'un logiciel malveillant très connu découvert en 2014 par le groupe de recherche `MalwareMustDie`. Ce malware a même fait l'objet d'[un article de Microsoft](https://www.microsoft.com/security/blog/2022/05/19/rise-in-xorddos-a-deeper-look-at-the-stealthy-ddos-malware-targeting-linux-devices/), néanmoins, le virus analysé par la société éditrice de Windows n'est pas la même version que celle que nous analysons dans cet article.

On peut aussi remarquer que le binaire a été compilé de manière statique, c'est-à-dire en incluant toutes les librairies dont il dépend, par GCC 4.1.2 sur une machine Red Hat. La structure des fichiers sources du binaire est :
```
- autorun.c
- crc32.c
- encrypt.c
- execpacket.c
- buildnet.c
- hide.c
- http.c
- kill.c
- main.c
- proc.c
- socket.c
- tcp.c
- thread.c
- findip.c
- dns.c
```

Avec cette seule information, on peut déjà observer certains fichiers intéressants, comme `encrypt.c` ou `hide.c` .

# 🦠 L'infection

Le principal vecteur d'infection utilisé par ce malware est le [bruteforce](https://fr.wikipedia.org/wiki/Attaque_par_force_brute) de serveur SSH, d'où l'importance d'utiliser des clés cryptographiques (comme [ED25519](https://www.unixtutorial.org/how-to-generate-ed25519-ssh-key/)) ou à minima un mot de passe fort.

Lors de la première infection, le malware va faire en sorte d'assurer sa persistance, pour ce faire, il va en premier lieu créer le fichier `/etc/cron.hourly/gcc.sh`, celui-ci contient un script qui va simplement démarrer toutes les interfaces réseau, se copier dans un autre endroit et se lancer. Le fait que ce script soit présent dans le dossier `/etc/cron.hourly` à son importance, les scripts présents dans ce dossier sont lancé automatiquement par le système toutes les heures.

```sh
#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/X11R6/
for i in `cat /proc/net/dev|grep :|awk -F: {'print $1'}`;
  do ifconfig $i up
done # Démarre toutes les interfaces réseau
cp /lib/libudev.so /lib/libudev.so.6
/lib/libudev.so.6
```

Le nommage du script en `gcc.sh` est sûrement fait pour se faire passer pour le compilateur bien connu `gcc` et donc ne pas paraitre suspect.

Une fois ce script cron créé, le malware va aussi créer un fichier dans `/etc/init.d`, ce dossier contient des fichiers de services systemd, runit ou openrc sous forme de script shell (🤮). Le malware va donc créer dans ce dossier un fichier contenant le code suivant :

```sh
#!/bin/sh
# chkconfig: 12345 90 90
# description: tlvgyjdotz
case $1 in
start)
	/usr/bin/tlvgyjdotz
	;;
stop)
	;;
*)
	/usr/bin/tlvgyjdotz
	;;
esac
```

On voit que ce simple script shell lance un binaire dans `/usr/bin`, c'est en fait le même binaire que celui de notre malware initial (`libudev.so`) mais qui est simplement copié avec un nom aléatoire, sûrement pour échapper à certains systèmes de protection.

Ces deux moyens d'assurer la persistance du malware sont gérés par les fonctions `InstallSys` et `add_service`.

# 🗨️ Communication avec le C2

Une fois que le malware est installé avec succès, il va commencer la communication avec le C2 – C2, pour Command&Control, c'est le nom du/des serveur-s qui donnent des ordres aux machines infectées. Toute la communication avec l'extérieur se fait via une fonction nommée `exec_packet`. Cette fonction permet notamment au binaire de se mettre à jour, mais aussi de télécharger d'autres binaires et de les lancer. Via cette fonction, le malware est aussi capable d'envoyer un hash md5 de son processus et de recevoir l'ordre de tuer certains processus. Lors de la première communication avec le C2, on a pu déterminer que plusieurs informations concernant la machine sont envoyées, dont notamment des statistiques sur la RAM, le CPU ou encore la vitesse de la connexion.

Enfin, cette fonction permet aussi de créer un grand nombre de threads dans lesquels est exécutée une fonction qui envoie des paquets TCP SYN, DNS ou TCP ACK, au vu du comportement de cette fonction, on peut supputer que ce serait elle qui serait en charge de lancer un DDoS vers une cible, les paquets [SYN](https://www.cloudflare.com/learning/ddos/syn-flood-ddos-attack/), [ACK](https://www.cloudflare.com/learning/ddos/what-is-an-ack-flood/) et [DNS](https://www.cloudflare.com/learning/ddos/dns-amplification-ddos-attack/) étant notamment très utilisés pour mener ce genre d'actions malveillantes.

![Un schéma résumant le paragraphe précédent](/static/img/xorddos/malware-function-schema.webp)


Aussi, on peut remarquer qu'une grande partie des communications sont chiffrées au moyen de l'algorithme XOR, les clés (`BB2FA36AAA9541F0`) étant présentes en clair dans le code (🤦) il est trivial de déchiffrer ces données, celles-ci étant principalement des noms de domaine qui révèleront leur utilité dans la prochaine partie.

C'est l'utilisation intensive de XOR qui donne d'ailleurs à ce malware son nom, XorDDoS.

# 🌐 Exploration de l'infrastructure du botnet

En explorant les trames réseaux et à la lecture du code décompilé, nous avons rapidement pu identifier 4 domaines liés au malware. Deux d'entre eux contiennent la liste des potentielles C2. Un autre domaine semble lié une liste de victimes, le 4ᵉ domaine est lui inutilisé.

Nous avons pu trouver trois dénominateurs communs pour les serveurs qui semblent être les C2
- Ce sont des machines sous Windows Server 2012
- Les IPs de ces serveurs appartiennent à l'hébergeur OVH, sous 2 organisations différentes.
- Ces deux organisations sont liées par un mail commun dans leur whois, `admin@66[.]to`.

![Un graph montrant toutes les IPs reliées au mail admin@66.to](/static/img/xorddos/hack520-maltego.webp)

Sur le nom de domaine `66[.]to`, directement lié à l'adresse mail, on peut trouver, tout d'abord, ce site avec cette magnifique image de cochon, elle aura son importance plus tard. Le site nous renvois par ailleurs vers le sous-domaine `secure[.]66[.]to`.

![Une capture d'écran du site de 66.to, présentant un texte décrivant un site d'hébergement et une photo de cochons](/static/img/xorddos/66-to-capture.webp)

En se rendant sur `secure[.]66[.]to` on se retrouve sur le site d'un hébergeur un peu suspect.

![Un site d'hébergeur](/static/img/xorddos/secure-66-to-capture.webp)

(Les pages ont été traduites en anglais pour les besoins de l'article, elles étaient initialement en chinois.)

L'hébergeur en question est, selon les informations que nous avons pu trouver¹, lié à un pirate répondant au pseudo de Hack520 (nous y reviendrons).

En analysant les requêtes DNS faites par le binaire, nous avons pu remarquer le domaine `a1.evil`\*, ces requêtes renvoyant une liste d'IPs ne semblant n'avoir aucun lien entre elles. De plus, les IPs liées à ce nom de domaine changent de temps en temps, il semblerait que ces IPs sont seraient celles des machines compromises par le virus.


# 🐷 Découverte de notre amateur de cochon

Comme cité plus haut, nous avons réussi à lier le botnet à un individu répondant au pseudo hack520.

C'est l'image de cochon que nous avons pu voir tout à l'heure qui nous a permise de remonter jusqu'à lui. La recherche d'image inversée de Baidu, nous a permise de remonter à un article de TrendMicro à propos de cet individu. La recherche inversée nous a aussi permise de retrouver certains de ses réseaux sociaux. Nous avons d'abord pu trouver son blog (`zhu[.]vn`), qui contenait des liens vers son compte twitter (`hack520_est`), nous avons aussi pu retrouver le Github (`Kwan9`) lui aussi grâce à l'image de cochon qui se trouve être la photo de profil. Par ailleurs, les deux cochons que vous pouvez retrouver ci-dessous répondent aux doux noms de LouLou (噜噜) et Mouchoutoutou (母豬嘟嘟).

![Loulou](/static/img/xorddos/loulou.webp)
![Moutchoutoutou](/static/img/xorddos/moutchoutoutou.webp)

Son compte github montre un certain attrait pour les mineurs de cryptomonnaie. À en croire ses commits, il possèderait l'adresse mail `kwanleo@126.com`. On peut aussi via github savoir que son ordinateur est dans la timezone Asia/Shanghai, elle permet, avec diverses autres informations que nous avons, de faire penser qu'il se situerait à Hong Kong. Un autre élément qui tend à prouver sa présence sur Hong Kong est cette [photo](https://twitter.com/hack520_est/status/697290929107898368) sur son twitter qui nous montre le téléphérique de [Ngong Ping](https://en.wikipedia.org/wiki/Ngong_Ping). Un post sur son github nous permet aussi de voir qu'il utilise windows.

Nous avons trouvé certains de ses autres réseaux sociaux, mais il ne nous semblait rien apporter, c'est pourquoi nous ne les avons pas mis ici.

Via l'article de trendmicro, on apprend par ailleurs qu'il est potentiellement membre de [Winnti Group](https://malpedia.caad.fkie.fraunhofer.de/actor/axiom), un collectif proche d'[APT](https://fr.wikipedia.org/wiki/Advanced_Persistent_Threat) chinois (41 et 17).

# 📑 Conlusion

Pour résumer, d’après nos analyses, ce malware relativement peu sophistiqué serait utilisé pour former un réseau de botnet. Un botnet est un réseau de machines répondant un ordre d’un serveur central (C2), utilisées pour faire des attaques DDoS — Distributed Denial of Service. Nous avons par ailleurs réussi à identifier certaines victimes présumées présentes dans ce réseau de botnet. Il s'avère que ce logiciel malveillant est déjà relativement connu et nommé XorDDos. Celui-ci est d'ailleurs détecté par de nombreux antivirus, incluant le logiciel libre [ClamAV](https://www.clamav.net/). Si vous souhaitez vous protéger de menaces similaires, il peut être intéressant de vous renseigner sur l'utilisation de logiciels antivirus sur vos serveurs !

\*Les adresses et pseudonymes ont été modifiés

- [1] [Examining a Possible Member of the Winnti Group](https://www.trendmicro.com/en_us/research/17/d/pigs-malware-examining-possible-member-winnti-group.html)
