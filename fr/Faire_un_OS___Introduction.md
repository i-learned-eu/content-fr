lang: fr
Author: Lolo
Date: 2022-07-15
Keywords: OS, C, introduction, C++ 
Slug: faire-un-os-intro
Summary: Tout est dans le titre: une introduction sur comment faire un OS, ou plutôt comprendre comment fonctionne un OS
Title:  Faire un OS: Introduction

# Faire un OS : Introduction
-----
Si vous lisez cet article, c’est que vous utilisez un système d’exploitation. Que ça soit sur un ordinateur, un téléphone ou encore certains systèmes embarqués vous en utilisez tous les jours. Et dans cet article, mon objectif va être de vous expliquer dans les grandes lignes comment un système d’exploitation (OS) fonctionne. C'est aussi une introduction pour un potentiel article qui sera quant à lui beaucoup plus technique. 

## Un OS ? Mais ça fait quoi ? 
Un OS est logicielle qui contrôle les périphériques de votre ordinateur et est chargé de fournir les éléments suivants : 
 - une interface entre les composants et l’utilisateur (une interface minimale) 
 - la gestion des processus, exécuter plusieurs tâches en même temps, prioriser, etc.
 - la gestion de la mémoire, allouer et libérer.
 ---
L’OS peut également être indépendant du support physique sur lequel il est, comme windows, ou à l’inverse propre à certains composants comme des OS faits par des amateurs ou Apple. *Il est beaucoup plus courant de voir des OS qui sont indépendants de leurs support physique*

Cependant il existe différents types d'OS pour différents besoin :
 - OS pour mainframe : ferme de calcul, il y a un très grand nombre de processus.
 - OS pour serveur: idem qu’un mainframe mais avec moins de performances, une gestion des utilisateurs également, généralement plus robuste qu’un OS personnel mais les différences sont de plus en plus rares.
 - OS personnel : celui que je viens de vous décrire ! 
 - OS embarqué : est présent dans la machine et est rarement changé, il est soumis à de fortes contraintes (peu de RAM, faible processeur, taille réduite d’espace). On a par exemple des OS pour des montres connectées.
 - OS temps réel : soumise à des contraintes de temps très fortes, le temps de réponse doit être instantané et surtout ne dois pas planter. Utilisé dans des usines de productions, systèmes de freinage de voiture par exemple. 

## Ok c’est utile, mais ça marche comment ? 

Pour comprendre le fonctionnement d’un système d’exploitation, nous allons commencer par suivre ces actions dès le démarrage de votre ordinateur/téléphone :
#### Le démarrage
Votre ordinateur démarre, le BIOS (Basic Input Output System) va lire le disque dur à la recherche d’une séquence particulière de données que l’on appelle “boot sector”, celui-ci va ainsi lancer le chargement d’un programme comme par exemple, *et par hasard*, votre OS.
*(attention je simplifie le fonctionnement mais vous trouverez des ressources plus technique dans les liens en fin d'articles ou dans l'articles faisant suite à celui-ci)*
#### Les périphériques
Une fois que le “boot sector” a ordonné le lancement de l’OS, celui-ci peut exécuter plusieurs tâches mais restons sur l’essentiel. 
La première tâche de votre système d’exploitation va être d’initialiser plusieurs choses, notamment l’affichage, la pagination de la mémoire, l’ordonnanceur et vérifier les périphériques. Je ne vais pas détailler ces étapes mais me concentrer sur les fonctionnalités mères : l’**ordonnancement** et la **gestion de la mémoire**.

---
### La gestion de la mémoire
La mémoire est un grand tableau, les programmes ont besoin de mémoire pour fonctionner et donc il faut découper ce tableau en blocs et chaque programme se verra alloué un certain nombre de blocs. L’OS a donc pour but de connaître la taille de la mémoire en la lisant entièrement puis de la découper en blocs. Voilà là la pagination de la mémoire. Assez simple non ?

La gestion de ces blocs est cependant légèrement plus complexe. Elle peut être faite de différentes manières que l’on ne va pas détailler dans cet article mais l’idée générale est de déterminer le meilleur emplacement pour un nombre de blocs souhaité. C'est-à-dire qu'il va arriver que la mémoire soi fragmeter, qu'il y ait un des blocs libres entres deux portions de blocs utilisés :
![Schema fragmentation](https://media.geeksforgeeks.org/wp-content/uploads/20200413104252/pp312.png)
Imaginons que la mémoire libre est en vert, si la section `P3` est libérée avant les autres. Il faut prendre en compte que celle-ci peut être utilisé si on n'a pas besoin de plus de mémoire que ce qui est disponible au niveau de `P3`. Sinon il faut trouver un autre emplacement.

### La gestion des processus
Pour ce qui est des processus, il faut passer par un peu d’architecture des ordinateurs et surtout des processeurs. 
Les processeurs sont des circuits qui, pour une grande majorité, sont en plusieurs cœurs. Il existe cependant des processeurs mono-cœur et nous allons parler ce ceux-ci puisque le principe qui s'applique à un processeur mono-cœur est celui qui s’appliquerait, à quelques petites exceptions, à celui d’un cœur d’un processeur multi-cœur.

Le cœur va donc exécuter des calculs, des instructions ; cela est donc très pratique, le processeur va par exemple afficher l’heure. Mais comme vous vous en doutez, c’est très vite limiter. Il faut donc trouver une parade à cela. Pour un processeur multi-cœur on peut avoir une tâche par cœur physique, mais encore une fois la solution reste très limitée. Il faut donc une solution, l’ordonnancement.
#### L'ordonnancement
Il existe différentes techniques d’ordonnancement et je vais vous en présenter trois qui sont les plus utilisées.
- **Round-robin :**
On prend un quantum de temps (une unité de temps) et on le divise en fonction du nombre de processus que l’on souhaite exécuter en même temps. C’est à dire que si l’on a 4 processus, chaque processus va être exécuté pendant ¼ du quantum de temps, être mis en pause avec une sauvegarde de son état, puis repris une fois son tour venu. De cette manière chaque processus a un accès égal au temps processeur. Notez que les fréquences des processeurs sont si rapides que le changement d’une tâche à une autre ne se remarque pas pour l’humain, tellement imperceptible que nous utilisateurs pensons que les tâches s’exécutent en simultanée.
- **La queue ou FIFO (First In First Out) :**
Chaque processus est exécuté selon son ordre d’arrivée : premier arrivé, premier servi. 
- **Les priorités :**
Les processus se voient attribués une priorité (de 1 à 7 avec 7 la priorité maximale) et le processus de la queue qui a la priorité la plus élevée est celui qui est exécuté. 
- **Shortest time remaining :**
Le principe est simplement de définir la tâche qui se finira en premier et d'ainsi réaliser celle-ci. *Oui c'est très peu pratique*

#### Mais du coup quelle méthode est utilisée par tous nos OS ? 

Si vous avez pensé à l’une des 3 méthodes : vous aviez tort !
 *Enfin, en partie…*
La réalité est que votre système d’exploitation est basé sur un subtil mélange de round-robin avec des priorités.

## Conclusion

Ainsi, un OS est un logiciel en charge de faire l'interface entre l'utilisateur et les composants physiques de l'ordinateur. Cela inclut une interface graphique minimal pour l'utiliser, une gestion de la mémoire et une gestion des processus. 
De cette manière, plusieurs tâches peuvent être exécutées en même temps et la mémoire est allouée judicieusement.

Tout ce que j’ai dit dans cet article est évidemment très sommaire et n’est qu’une introduction à un article que je souhaite rédiger sur “Comment faire un OS”, celui-ci ne sera pas un tutoriel mais reprendra les étapes que j’ai moi-même suivies lorsque j’ai créé le miens ! Attention, il s’agit d’un projet d’école, que j’ai souhaité réaliser. Il n’est ni parfait, ni réellement fini mais j’en parlerai dans le prochain article *si celui-ci sort un jour*. En attendant, vous trouverez le lien du github de celui-ci ainsi que toutes les ressources que j’ai utilisées pour rédiger cet article ! Merci beaucoup d'avoir lu jusqu'ici :)

## Sources de l'article
---
Operating system: Design and Implementation 2nd & 3rd ed - Andrew Tanenbaum
wiki.osdev.org
how to make an OS - poncho
Make an OS - deadalus Community
The Heap: what dies malloc() do ? - LiveOverflow
Lyre OS - https://github.com/lyre-os/lyre
Limine - https://github.com/limine-bootloader/limine
printf - https://github.com/eyalroz/printf
Turb-OS (mon projet) - https://github.com/loic-prn/Turb-OS