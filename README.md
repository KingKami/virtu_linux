HA Linux

DEB10 NetInstall minimal

ssh server
utilitaires

Disques : 2 x 10Go 1Go RAM

Partitionnement:

sda1
/boot (RAID 1) 500Mo ext2

sda2 (PV) (RAID 1)
/ : btrfs (/dev/VGROOT/lv_root) 3Go
/var : xfs (/dev/VGROOT/lv_var) 2Go
swap : zramfs (/dev/zram0 : 100Mo)

1.  Authentification par clés entre le poste de travail et la VM Debian
2.  Autoriser l'accès de la VM par le prof
3.  Améliorer l'environnement SHELL (prompt, alias....)
4.  Installer l'outil cheat

BootStack (Wiki wysiwig)
Reverse Proxy ( wiki.esgi.local)

5.  Clonage de la VM
6.  Mise en oeuvre d'une solution de fail-over (actif-passif) à base de DRBD
    le site wiki.esgi.local est une IP virtuelle

7.  Mise en oeurve de HeartBeat

8.  HA malgré l'arret d'un serveur (coupure de HeartBeat)
9.  HA malgré le reboot des 2 serveurs
10. HA malgré l'arret d'un service ( serveur Web / serveur de base MariaDB )

TP à rendre pour le vendredi 12 mars 23:59:59
83.159.86.56
port 7222
incoming
user : rendu
mdp : rendu

5SRC2.Nom.Prenom.HA.gz

Facultatif :

Keycloak (SSO) (SAML2)
HTTPS
