Title: A quoi sert initramfs
Keywords: Linux, init, initramfs, boot
Date: 2022-02-10
Slug: initramfs
Author: Ownesis
Summary: Dans cet article, on va voir ce qu'est et à quoi sert initramfs

# Pour la faire courte
Initramfs est un [système de fichier](https://ilearned.eu/fat.html) monté dans la [RAM](https://en.wikipedia.org/wiki/Random-access_memory) lors de l'initialisation du [noyau (kernel)](https://fr.wikipedia.org/wiki/Noyau_de_syst%C3%A8me_d%27exploitation).

# Un peu plus de détails
Initramfs est présenté sous forme d'archive [cpio](https://fr.wikipedia.org/wiki/Cpio), c'est en quelque sorte l'ancêtre de [tar](https://doc.ubuntu-fr.org/tar).
L'archive contient les fichiers, scripts, bibliothèques, fichiers de configuration, et d'autres qui peut ou pourrait être utile au noyau pour monté le vrai système de ficier racine `root`.
Cette dernière est ensuite compressé avec [gzip](https://fr.wikipedia.org/wiki/Gzip) et est stocké au coté du noyau [Linux](https://en.wikipedia.org/wiki/Linux_kernel).

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

sources:
 - [wiki.gentoo.org](https://wiki.gentoo.org/wiki/Initramfs/Guide/fr)
 - [fr.linuxfromscratch.org](https://www.fr.linuxfromscratch.org/view/blfs-svn/postlfs/initramfs.html)
