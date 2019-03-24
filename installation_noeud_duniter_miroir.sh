#!/bin/bash
# description : installation d'un noeud duniter miroir version serveur
# author : pytlin <pytlin@protonmail.com>
# duniter : https://duniter.org/fr/
# VERSION="2019.03.24"
set -e


# VARIABLES
version="1.7.11"
format="server"
myip=`ip route get 1 | awk '{print $NF;exit}'`
port="10901"
noeudReference="g1.duniter.fr"

# VARIABLES COULEURS
blanc="\033[1;37m"
gris="\033[0;37m"
magenta="\033[0;35m"
rouge="\033[1;31m"
vert="\033[1;32m"
jaune="\033[1;33m"
bleu="\033[1;34m"
rescolor="\033[0m"


#FONCTIONS 
is_centos() {
	[[ $(lsb_release -d) =~ "CentOS" ]]
	return $?
}

is_ubuntu() {
	[[ $(lsb_release -d) =~ "Ubuntu" ]]
	return $?
}
is_debian() {
	[[ $(lsb_release -d) =~ "Debian" ]]
	return $?
}



# DEBUT DU SCRIPT
echo -e "$vert"
echo -e "#########################################################"
echo -e "#                                                       #"
echo -e "#   Script d'installation d'un noeud duniter miroir     #"
echo -e "#                                                       #"
echo -e "#              Testé sur Debian 9.8 x64                 #"
echo -e "#                      by @pytlin                       #"
echo -e "#                                                       #"
echo -e "#########################################################"
echo -e "                     $VERSION"
echo -e "$rescolor\n\n"
sleep 3

if [ "$UID" -ne "0" ]
then
	echo -e "\n${jaune}\tRun this script as root.$rescolor \n\n"
	exit 1
fi



if is_debian; then
	echo -e "\n${jaune}Mise à jour du système...${rescolor}" && sleep 1
	apt update -y && apt upgrade -y
	echo -e "\n${jaune}Téléchargement de la dernière version de duniter...${rescolor}" && sleep 1
	wget https://git.duniter.org/nodes/typescript/duniter/-/jobs/16737/artifacts/raw/work/bin/duniter-${format}-v${version}-linux-x64.deb
	echo -e "\n${jaune}Installation de duniter...${rescolor}" && sleep 1
	dpkg -i duniter-server-v1.7.11-linux-x64.deb
	echo -e "\n${jaune}Synchronisation du noeud...${rescolor}" && sleep 1
	sudo -u duniter duniter sync $noeudReference
        echo -e "\n${jaune}Lancement de duniter...${rescolor}" && sleep 1
	sudo -u duniter duniter webstart --webmhost $myip --webmport $port
	echo -e "\n${jaune}Vérification du status de duniter...${rescolor}" && sleep 1
	status=`sudo -u duniter duniter status`
	if [[ $status == *"PID"* ]]; then
		echo -e "\n${vert}Duniter tourne bien..${rescolor}" && sleep 1
		echo -e "\n${vert}rendez-vous sur http://${myip}:${port}${rescolor}" && sleep 1
		exit 0
	else
		echo -e "\n${rouge}Un petit problème est survenue lors du lancement de duniter, vérifiez les logs..${rescolor}" && sleep 1
		exit 1
	fi	
else

	echo -e "\n${jaune}Votre système n'est pas Debian, ce script ne fonctionne pour le moment que sur Debian...${rescolor}"
	exit 1
fi














