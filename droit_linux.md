lang: fr
Title:
Keywords:
Date:
Author: Ramle
Summary:
Slug: droit_linux

En utilisant Linux vous avez probablement rencontré des erreurs tel que "permission denied" (permission non accordée). Souvent des erreurs du genre sont frustrante, pourquoi le système que j'ai installé me refuse l'accès ? Le but de cet article est justement de comprendre en détail le fonctionnement des permissions sous Linux.

Pour parler de droit sous Linux il faut bien comprendre que touts est fichiers, que ce soit les configurations, les périphériques ou encore les informations sur un pid. Comme touts est fichier les droits d'accès à chacun sont primordiaux, un utilisateur qui accède à /dev/sda (dans le cas ou votre disque est sda) serait dramatique.

Pour pallier à ces soucis Linux dispose de droits originalement plutôt basique se limitant à :
- **r**ead : autoriser à lire le fichier
- **w**rite : autorise à écrire le fichier
- e**x**ecute : autorise à exécuter le fichier

Pour les dossiers c'est la même chose mise à part que execute autorise à lister les fichiers.
On peut prendre un exemple :
```
% ls -l
total 8
-rwx------. 1 raiponce raiponce 32 19 mar 16:17 a
-rw-r-----. 1 raiponce pascal   0 19 mar 16:15 b
-rwxr-xr-x. 1 raiponce raiponce 32 19 mar 16:16 c
```
On voit touts de suites l'utilité des lettres mises en gras plus haut. Elles sont utilisée pour visualisée les droits. Sous Linux de base il y a 3 groupes de permissions :
- utilisateur : ce que l'utilisateur peut faire.
- groupe : ce que le groupe peut faire
- touts le monde : ce que tout le monde peut faire

Pour le fichier `a` l'utilisateur raiponce peut lire, modifier et exécuter, pour le fichier. `b` est lui lisible et modifiable par l'utilisateur et lisible pour le groupe. Pour `c` tout le monde peut lancer et lire mais seul raiponce peut modifier.
