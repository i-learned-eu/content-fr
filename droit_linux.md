lang: fr
Title: Permissions sous Linux
Keywords: permission, Capabilities, linux, sécurité
Date: 2022/03/31
Author: Ramle
Summary: En utilisant Linux, vous avez probablement rencontré des erreurs telles que "permission denied" (permission refusée). Souvent des erreurs du genre sont frustrantes, pourquoi le système que j'ai installé me refuse l'accès ? Le but de cet article est justement de comprendre en détail le fonctionnement des permissions sous Linux et de vous aider.
Slug: droit_linux

En utilisant Linux, vous avez probablement rencontré des erreurs telles que "permission denied" (permission refusée). Souvent des erreurs du genre sont frustrantes, pourquoi le système que j'ai installé me refuse l'accès ? Le but de cet article est justement de comprendre en détail le fonctionnement des permissions sous Linux et de vous aider.

Pour parler de droit sous Linux, il faut bien comprendre que tout est fichiers, que ce soit les configurations, les périphériques ou encore les informations sur un pid. Comme tout est fichier, les droits d'accès à chacun sont donc primordiaux. Par exemple, un utilisateur qui accède à /dev/sda (dans le cas où votre disque est sda) serait dramatique.

## Permission de base
Pour pallier à ces soucis, Linux dispose de droits originalement plutôt basiques se limitant à :
- **r**ead : autoriser à lire le fichier
- **w**rite : autorise à écrire le fichier
- e**x**ecute : autorise à exécuter le fichier

Pour les dossiers, c'est la même chose mise à part que execute autorise à lister les fichiers.
On peut prendre un exemple :
```
% ls -l
total 8
-rwx------. 1 raiponce raiponce 32 19 mar 16:17 a
-rw-r-----. 1 raiponce pascal   0 19 mar 16:15 b
-rwxr-xr-x. 1 raiponce raiponce 32 19 mar 16:16 c
```
![Notation droit linux](/static/img/droit_linux/perm_notation.webp)

On voit tout de suites l'utilité des lettres mises en gras plus haut. Elles sont utilisées pour visualiser les droits. Sous Linux de base, il y a 3 groupes de permissions :
- utilisateur : ce que l'utilisateur peut faire
- groupe : ce que le groupe peut faire
- tout le monde : ce que tout le monde peut faire

Dans notre exemple, le fichier `a` est lisible, modifiable et exécutable par raiponce, pour le fichier. `b` est lisible et modifiable par l'utilisateur (ici raiponce) et lisible pour le groupe (ici pascal). Pour `c` tout le monde peut lancer et lire, mais seule raiponce peut modifier.

Les 2 principaux utilitaires pour gérer les droits de manière basique sur les fichiers sont `chmod` et `chown`. Pour chmod on peut l'utiliser soit en lui disant quel droit ajouter ou enlever à un fichier ou répertoire, par exemple :
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

Vous l'avez probablement remarqué, mais ce ne sont que de simple addition, par exemple pour `rw` c'est le résultat de 2+4, il suffit donc de retenir le numéro lié à chaque droit et non tout le tableau.

Reprenons donc un exemple, donnons donc accès au groupe pascal en lecture et à l'utilisateur raiponce en lecture écriture aux fichiers `x`, ce qui nous donnera la suite de commande :
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

### Masquage
Un autre aspect important est le  "masquage", cela permet de définir les permissions pour les nouveaux fichiers ou dossiers. On peut voir le masque d'un dossier via `umask -S`. Le masque est une soustraction, par exemple `umask 022` donnera les permissions 644 sur un fichier et 755 sur un dossier. Cela peut paraitre étrange, les permissions du fichier devrait être 755 non ? En fait, le masque par de la valeur 666 et non 777 (il faut donc manuellement donner les droits d'exécuter, le masque ne peut le faire) mais reste 777 pour les dossiers. Par exemple, si on veut que les nouveaux fichiers aient comme droit `rw-r-----` (640) on va pouvoir faire : `umask 027`, ce qui donnera aux dossiers les permissions 750.

## Capabilities et Setuid/Setgid
Sous linux il existe des permissions plus poussée et fine pour donner certains droit à des binaires. Cela permet d'éviter de devoir lancer en root (root est le "super-utilisateur", c'est à dire qu'il a presque tous les droits).

### Setuid et Setgid
Ces droits permettent à un binaire de se lancer en tant qu'une autre personne. Par exemple, si le fichier `i_am_root` est propriété de root il pourrait lancer un shell en root. Il est donc primordial de ne pas donner le setuid (souvent abrégé suid) ou setgid sur n'importe quel fichier. Bien sûr la plupart des programmes qui requiert un suid ou guid rajoutent des règles pour limiter les utilisateurs pouvant utiliser entièrement la commande (on peut le voir dans [le code de passwd](https://github.com/shadow-maint/shadow/blob/master/src/passwd.c) par exemple).
Pour rajouter un suid ou sgid c'est toujours la commande chmod qui le permet. Par exemple : `chmod ug+s y` rajouteras un suid et guid au fichier y. On peut aussi utiliser la notation à base de nombre, pour ça il faut utiliser 4 chiffres au lieu des 3 pour les permissions simple. 2 signifie un setguid et 4 un setuid, l'équivalent du chmod montré juste au dessus serait donc `chmod 6755` (dans le cas ou les permissions du fichier sont `rwxr-x-rx`).

# Capabilities
Certaines actions sous Linux ne peuvent pas être faites en temps que simple utilisateur, pour éviter de devoir lancer en tant que root, ce qui est regrettable niveau sécurité, Linux possède ce qu'on nomme des capabilities. Elles permettent par exemple d'autoriser à un programme d'écouter un port en dessous de 1024. On peut lister celles présente sur un fichier via `getcap`. Par exemple pour `ping` on aura : `/usr/bin/ping cap_net_raw=ep`. Cela permet d'utiliser des socket raw. On peut voir dans la page de man : [capabilities(7)](https://man.archlinux.org/man/capabilities.7) la liste de celles-ci et leurs descriptions. Pour donner une capabilities à un binaire, on peut utiliser `setcap`, par exemple `setcap 'cap_net_bind_service=+ep' listener` donne le droit à `listener` d'écouter sur un port plus faible que le 1024.

J'espère que cet article moins poussé techniquement que d'habitude vous auras plus, ça commençait à faire longtemps qu'on n'avait plus rien sorti 😅. On va essayer de vous sortir des articles d'ici pas trop longtemps, pour ne rien spoiler il y a un gros article qui ne parle pas d'informatique en préparation ;).