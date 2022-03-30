lang: fr
Title:
Keywords:
Date:
Author: Ramle
Summary:
Slug: droit_linux

En utilisant Linux vous avez probablement rencontré des erreurs tel que "permission denied" (permission refusée). Souvent des erreurs du genre sont frustrante, pourquoi le système que j'ai installé me refuse l'accès ? Le but de cet article est justement de comprendre en détail le fonctionnement des permissions sous Linux et de vous aider.

Pour parler de droit sous Linux il faut bien comprendre que touts est fichiers, que ce soit les configurations, les périphériques ou encore les informations sur un pid. Comme touts est fichier les droits d'accès à chacun sont primordiaux, un utilisateur qui accède à /dev/sda (dans le cas ou votre disque est sda) serait dramatique.

## Permission de base
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
*insérer schéma*

On voit touts de suites l'utilité des lettres mises en gras plus haut. Elles sont utilisée pour visualiser les droits. Sous Linux de base il y a 3 groupes de permissions :
- utilisateur : ce que l'utilisateur peut faire
- groupe : ce que le groupe peut faire
- touts le monde : ce que tout le monde peut faire

Dans notre exemple, le fichier `a` est lisible, modifiable et exécutable par raiponce, pour le fichier. `b` est lisible et modifiable par l'utilisateur (ici raiponce) et lisible pour le groupe (ici pascal). Pour `c` tout le monde peut lancer et lire mais seul raiponce peut modifier.

Les 2 principaux utilitaires pour gérer les droits de manière basique sur les fichiers sont `chmod` et `chown`. Pour chmod ont peut l'utiliser soit en lui disant quel droit ajouter ou enlever à un fichier ou répertoire par exemple :
```
chmod g+rw a
```
Ajoute les droits de lecture et écriture au groupe propriétaire sur le fichier `a`.

Une autre méthode consiste à utiliser des "nombres" ou chaque chiffre corresponds à une catégorie de droit (utilisateur, groupe, tous) et des permissions.
| Droit                 | Valeur en lettres | Valeur en nombre |
|-----------------------|-------------------|------------------|
| Aucun droit           | ---               | 0                |
| exécution seulement   | --x               | 1                |
| écriture seulement    | -w-               | 2                |
| écriture et exécution | -wx               | 3                |
| lecture seulement     | r--               | 4                |
| lecture et exécution  | r-x               | 5                |
| lecture et écriture   | rw-               | 6                |
| tous les droits       | rwx               | 7                |

Vous l'avez probablement remarqué mais ce ne sont que de simple addition, par exemple pour `rw` c'est le résultat de 2+4, il suffit donc de retenir le numéro lié à chaque droits et non tout le tableau.

Reprenons donc un exemple, donnons donc accès au groupe pascal en lecture et à l'utilisateur raiponce en lecture écriture aux fichiers `x`, ce qui nous donneras la suite de commande :
```
chown raiponce:pascal x #On met l'utilisateur raiponce et le groupe pascal propriétaire
chmod 0640 x #On donne les droits : rw-r-----

```

- Si je veux autoriser pascal à modifier son site qui se trouve dans /var/www/pascal/ tout en laissant le serveur web qui tourne via l'utilisateur et le groupe `www-data` servir les fichiers ? ||pascal:www-data en propriétaire et -rwx-r-x---, ce qui nous donne les commandes suivantes :
```
chown pascal:www-data
chmod 750 #Sur un dossier le droit d'exécution permet de lister les fichiers
```
||

## Capabilities et Setuid/Setgid
Sous linux il existe des permissions plus poussée et fine pour donner certains droit à des binaires. Cela permet d'éviter de devoir lancer en root (root est le "super-utilisateur", c'est à dire qu'il a presque tous les droits).
### Setuid et Setgid
Ces droits permettent à un binaire de se lancer en tant qu'une autre personne. Par exemple
