# Procédure d'installation de BookStack dans un environement hautement disponible

En éxecutant les scripts, vous obtiendrez à la fin une installation de BookStack redondé via heartbeat et drbd

Les fichiers de configuration sont fourni, afin que le script puisse bien les copier et effectuer ses actions clonez ce projet.

:warning: Votre installation de Nginx peut ne pas autoriser les liens symboliques, activer l'option en ajoutant la ligne `disable_symlinks off;` dans la section `http` dans le fichier `/etc/nginx/nginx.conf`


## Configuration des disques

Créez une machine virtuelle debian 10 avec 2 disques de 10GB

Lors de l'installation de l'os effectuez les étapes suivantes :

- Sur le disque 1
  - créez une partition 1 de 500MB qui servira pour le /boot
  - créez une partition 2 avec le reste du disque qui servira pour le volume group

- Sur le disque 2 créez les mêmes partition avec les même tailles
  - créez une partition 1 de 500MB qui servira pour le /boot
  - créez une partition 2 avec le reste du disque qui servira pour le volume group

- raid md0 avec les 2 partitions 1
- raid md1 avec les 2 partitions 2

- Créez une partition ext2 sur le volume raid md0 /boot ext2

- Créez un volume group sur le volume raid md1
  - Créez les logical volume suivant :
    - lv_root 500MB que vous monterez par la suite sur / formaté en btrfs
    - lv_var 2GB que vous monterez par la suite sur /var formaté en xfs
    - lv_swap 100MB que vous monterez par la suite comme swap

Une fois que l'os est fonctionel, vous pouvez executer le script `scripts/filesystem-setup.sh`

:warning: Executez le script à vos risques et peril, les modifications effectués peuvent boulverser votre système.
Les commandes restent les mêmes et sont executables une à une.

:warning: Pensez à remplacer les variables par vos valeurs !

Le script va vous permettre de remplacer le swap par du zramfs et de nettoyer votre fichier fstab pour que vos différents volumes se montent bien au démarrage.


## Installation de Cheat

Suivre le script `scripts/install-cheat.sh`

Le script installera l'outil cheat qui permet d'avoir des informations sur des commandes avec des exemples d'utilisation.

## Installation de BookStack

Suivre le script `scripts/install-bookstack.sh`

:warning: Pensez à remplacer les variables par vos valeurs

:warning: Vous serez prompté pour rentrer le mot de passe root pour vous connecter à MariaDB.

Le script installera Bookstack, Nginx, PHP et MariaDB.



## Installation et Configuration de DRBD et Heartbeat

Suivre le script `scripts/drbd-heartbeat.sh`

:warning: Pensez à remplacer les variables par vos valeurs

:warning: L'execution de ce script peut entraîner des pertes de données à executer avec précautions

Le script installera DRBD et heartbeat et vous aidera à les configurer pour obtenir un service aussi résilient que possible.