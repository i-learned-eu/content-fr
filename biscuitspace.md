lang: fr
Author: Tagada 
Date: 2022/03/27
Keywords: yunohost
Slug: yunohost
Summary: Je vous raconte comment j'ai déployé des services stables, pour moi et mes proches, facilement et rapidement, grâce à YunoHost.
Title: Biscuit Space : Comment créer un CHATONS en 2 heures avec YunoHost ?

Ça fait déjà maintenant quelques années que j'héberge des services accessibles
librement, ou pour mes proches. De manière autodidacte et un peu chaotique, mais
ça tient ! Et de mieux en mieux avec YunoHost !

Il y a 3 ans, j'ai découvert YunoHost : un projet sympathique qui vise à rendre
l'administration d'un serveur facile et accessible. La distribution embarque
une interface d'administration complète en Web et en CLI incluant la gestion des
utilisateurices, noms de domaines, certificats SSL, sauvegardes, par-feu, un
serveur mail complet, un serveur XMPP et un outils de diagnostic.

![Administration Web de YunoHost](/static/img/biscuitspace/yunohost-admin.png)

Un des principes clé de YunoHost c'est la simplicité. Autant dans l'utilisation
que dans la conception, les fonctionnalitées doivent rester simple. Pour 
installer une application, il suffit de quelques clic. YunoHost récupère le
paquet et lance le script d'installation. Une fois terminé, l'application est
intégrée dans YunoHost et accessible via le portail.

![Portail YunoHost](https://yunohost.org/_images/home_panel.jpg)

Le portail *Single Sign-On* (ou SSO) permet aux utilisateurices de se connecter
à toutes les applications qui sont installées et auxquelles iels ont accès.

Pour l'administrateurice, le catalogue propose de nombreuses applications 
permettant de mettre en place rapidement une infrastructure pour son équipe,
association, entreprise ou pour soi même.


## Le contexte

Biscuit Space est un projet qui existe déjà, tourne déjà sur YunoHost mais que
j'ai décidé de "refaire au propre". Depuis quelques années, j'héberge mes
services chez différents hébergeurs commerciaux et bientôt je devrais être
capable de migrer ça chez moi. Ce n'est pas encore pour cette fois, mes serveurs
actuels sont décommissionnés le 1er avril et je dois tout migrer sur les
nouveaux serveurs avant ça.

Le serveur va accueillir plusieurs choses : Biscuit Space (le chaton), Biscuit
Town et Ouin Land (deux instances Mastodon). Biscuit Space (Yunohost) sera
installé sur le serveur directement, et il y aura un container pour chaque
instance Mastodon.

J'ai décidé d'ouvrir Biscuit Space avec quelques services, mais la liste pourra
évoluer plus tard. Au départ, nous aurons :

- Nextcloud, un outil multifonction permettant de partager fichiers, contact,
photos et agenda avec son équipe ou des proches ;
- Rainloop, un webmail pour pouvoir consulter son adresse @biscuit.space ;
- Etherpad, un logiciel d'édition de texte à plusieurs, permettant de prendre
des notes en simultané ;
- Vautlwarden, une réécriture du gestionnaire de mot de passe Bitwarden ;
- Wekan, un gestionnaire de tableau Kanban ;
- WireGuard, un VPN efficace et chiffré.

On va commencer par installer YunoHost.


## Préparation du serveur

Je ne vais pas trop détailler ces étapes, mais n'hésitez pas à passer sur les
réseaux pour demander plus d'explications o/

Mon hébergeur m'a donné le choix entre Debian 10 et 11. À ce jour, YunoHost
stable supporte uniquement Debian 10, donc c'est parti pour buster o/

Je vérifie le partitionnement, le swap, ma clé SSH...

Après, il suffit de suivre la [procédure de la documentation de YunoHost](https://yunohost.org/fr/install/hardware:vps_debian). Une fois terminé, on peut passer à la post-installation,
via son navigateur web ou en SSH, puis créer un premier utilisateur.


## Un wiki pour documenter tout ça

La première des choses, maintenant que le serveur est prêt, c'est d'y installer
un wiki.

C'est une chose utile lorsqu'on crée un projet qu'on est susceptible de gérer à
plusieurs. Ça permet d'avoir un endroit dédié au stockage des informations
pertinentes à la gestion du projet (procédures, historique de maintenance...).

J'ai choisi Dokuwiki que je connais déjà et utilise sur d'autres projets. Seul
moi y aurait accès pour le moment. Dans le futur, d'autres membres de Biscuit
Space sont susceptibles d'y accéder. J'y renseignerais toutes les opérations de
maintenance que j'effectue et un résumé de l'état actuel du serveur.

Le top, ça serait que tout ou partie du wiki soit accessible à toustes pour
pouvoir reproduire l'expérience facilement !

J'installe Dokuwiki depuis l'interface d'administration web.

// Insérer screenshot de l'installation + GIF de la procédure


## Les applications

D'abord il faut se situer un peu l'URL des différentes applications, sachant que
certaines requiert un nom de domaine particulier (c'est souvent indiqué dans le
README).

On aura donc le plan suivant :

- Nextcloud : `biscuit.space/nextcloud`
- Rainloop : `biscuit.space/webmail`
- Etherpad : `biscuit.space/pad`
- Vaultwarden : `warden.biscuit.space`
- Wekan : `biscuit.space/wekan`
- Wireguard : `wg.biscuit.space`

Ici une des étapes les plus simples, on peut de se rendre sur l'interface web et
installer de quelques cliques toutes les applications, ou depuis la CLI aussi :

```
$ sudo yunohost app install nextcloud
```

// Insérer asciinema ici

Ici on nous pose quelques et on n'a plus qu'à laisser le script se dérouler. En
quelques minutes, l'application est installée et utilisable o/

Il suffit de répéter l'opération pour toutes les applications :

```
$ sudo yunohost app install rainloop
$ sudo yunohost app install etherpad_mypads
$ sudo yunohost app install vaultwarden
$ sudo yunohost app install wekan
$ sudo yunohost app install wireguard
```

## Mes besoins perso

//J'ai craqué pour un ERP de frigo, ou Je raconte mon aventure Grocy
// LXD pour Biscuit Town et Ouin Land


## Aujourd'hui

J'utilise YunoHost depuis 3 ans et tout roule. J'ai très vite commencé à
m'intéresser au packaging d'applications et pris contact avec l'équipe qui m'a
très bien accueillie. Je suis aussi allée toucher au core dans certaines
situations et depuis janvier 2022 je contribue au core et à quelques
applications de manière régulière. À la mi-mars 2022, j'ai rejoint l'équipe des
contributeurices régulières.

YunoHost, une réponse aux GAFAM : permettre au plus grand nombre de participer
facilement à la création d'un Internet décentralisé et au datalove <3
