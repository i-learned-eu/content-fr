lang: fr
Author: Eban
Date: 2022-08-07
Keywords: sync, synchronisation
Slug: syncthing
Summary: Qui a déjà utilisé différents ordinateurs en même temps sait la complexité que représente de gérer la synchronisation entre ceux-ci, nous traiterons dans cet article d'un logiciel, Syncthing, qui permet de régler ce soucis de façon assez magique 🪄.
Title: Syncthing, la synchronisation de fichiers dopée aux stéroïdes

Qui a déjà utilisé différents ordinateurs en même temps sait la complexité que représente de gérer la synchronisation entre ceux-ci, nous traiterons dans cet article d'un logiciel, Syncthing, qui permet de régler ce soucis de façon assez magique 🪄.

# 🧱 Architecture des systèmes de synchronisation

Il existe principalement deux architectures permettant la synchronisation des fichiers

## ➡️ Client/Serveur

C'est l'architecture la plus classique, proposée par de gros acteurs du secteur comme [Google](https://www.google.com/intl/fr/drive/), [Dropbox](https://www.dropbox.com/fr/), [Apple](https://icloud.com) ou encore [Nextcloud](https://nextcloud.com). Le principe est relativement simple, tous les fichiers sont uploadés vers un serveur chez l'opérateur de cloud, et lorsque l'on utilise un autre appareil, les changements sont téléchargés des serveurs de cet opérateur.

![Un schéma montrant un exemple d'architecture client/serveur](/static/img/syncthing/client-server.webp)

C'est le modèle le plus répandu pour une raison, c'est le plus simple à mettre en place, et ça l'était encore plus, il y a quelques années. Cependant, depuis, un autre modèle devient de plus en plus commun.

## 🕸️ Mesh

Cet autre modèle, ce sont les réseaux maillés, ou mesh. Plutôt que de s'appuyer sur un serveur central, qui peut se retrouver inopérant à n'importe quel moment, on utilise tous les appareils à la fois comme serveur et comme client. Cela permet à cette topologie d'être beaucoup plus **résiliente**.

![Une schéma montrant un exemple d'architecture mesh](/static/img/syncthing/mesh.webp)

On peut voir sur ce schéma que même si l'ordinateur principal n'est pas en capacité d'accéder à certains appareils directement (parce que ceux-ci n'ont pas accès à internet par exemple) cela ne pose aucun problème car, chacun d'entre eux étant interconnecté, les modifications finissent par être propagées partout.

On a aussi un autre avantage de taille, si deux appareils sont sur le même réseau local, ils n'auront pas à passer par Internet, ce qui permet d'accélérer grandement la vitesse de mise à jour entre les appareils.

C'est ce modèle qu'utilise Syncthing, le logiciel dont nous allons traiter ici.

# 📦 Syncthing

Syncthing est un [logiciel libre](https://github.com/syncthing/syncthing) créé en 2013, il est activement supporté, compte quelque 80 000 utilisateurs, et a depuis sa création, permit de transférer [34 Pib](https://data.syncthing.net/) (4 785 000 Go) ! Il s'appuie sur un protocole appelé BEP ([Block Exchange Protocol](https://docs.syncthing.net/specs/bep-v1.html)) que je vais tâcher de vous décrire ici.

BEP est un protocole qui s'appuie sur une 
structure de données assez simple, chaque appareil (device) a une liste de dossiers (folder). Ces dossiers sont découpés en plus petits blocs entre 128 KiB et 16 MiB, Syncthing stocke le hash de chacun de ces blocs, et échange cette liste de hash avec les autres appareils afin de savoir si la version d'un dossier stocké est à jour.

![Un exemple de dossier découpé en blocs](/static/img/syncthing/folder.webp)

Si le hash d'un des blocs n'est pas le même, l'appareil va alors synchroniser ce bloc avec l'autre appareil ayant la version plus récente.

Il existe trois modes d'échanges entre les appareils, `send only`, `receive only`, et `send & receive`.  Le premier est particulièrement utile sur un ordinateur qui voudrait envoyer des sauvegardes vers un serveur par exemple, l'ordinateur ne veut pas recevoir de fichier du serveur, juste en envoyer. À l'inverse, dans ce cas, le serveur serait en `receive only`. Le mode `send & receive` est tout particulièrement utile pour synchroniser, par exemple, le dossier `~/Documents` entre deux ordinateurs, permettant à l'un et l'autre d'effectuer des modifications sur un document et d'être toujours synchronisé.

Toute l'ingéniosité de Syncthing repose dans son optimisation, le protocole principalement utilisé pour le transfert de fichier est [`Quic`](https://blog.ilearned.eu/http3.html), un parfait compromis entre la robustesse de [`tcp`](https://blog.ilearned.eu/tcp.html) et la vitesse d'[`udp`](https://blog.ilearned.eu/udp.html). Syncthing optimise aussi grandement le transfert en lui-même, en permettant par exemple de ne pas retransférer certaines données si elles sont déjà présentes dans d'autres fichiers. Par exemple, si je veux synchroniser mon `~/Dev`, et que j'ai dedans plusieurs projets en JS, plutôt que de télécharger le dossier `node_modules` à chaque nouveau projet créé sur une machine distante, il va copier les fichiers déjà existant sur le disque pour des bibliothèques qui auraient déjà été téléchargées par exemple.

Ces optimisations permettent un gain de bande passante assez incroyable, d'après les statistiques de Syncthing récoltées sur l'ensemble des appareils ayant autorisé la télémétrie, la réutilisation des données d'autres fichiers aurait permis d'économiser 8 % de bande passante !

![Totals to date Transferred	34.62 PiB (38.72%) Saved by renaming files	2.1 PiB (2.35%) Saved by resuming transfer	4.29 PiB (4.80%) Saved by reusing data from old file	40.23 PiB (45.00%) Saved by reusing shifted data from old file	827.11 TiB (0.90%) Saved by reusing data from other file    7.36 PiB (8.23%)](/static/img/syncthing/stats.webp)

Cet article touche à sa fin, j'espère que vous en savez maintenant un peu plus sur Syncthing, pour finir j'aimerais vous donner une dernière astuce, si vous comptez utiliser Syncthing entre deux ordinateurs que nous n'utilisez pas en même temps (ex. un ordinateur portable pour les cours et un fixe chez soi) je ne pourrais que vous conseiller de mettre Syncthing sur un NAS, un VPS ou même un simple Raspberry Pi fera l'affaire, cela permettra de synchroniser les fichiers même si un des deux ordinateurs n'est pas allumé. Merci d'avoir suivi cet article ! 😄
