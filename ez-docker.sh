#!/bin/bash

#Version
version="1.7"

#Cli colors
nc='\033[0m'
red='\033[0;31m'
yellow='\033[0;33m'
cyan='\033[0;36m'
boldblue='\033[1;34m'
boldgreen='\033[1;32m'

function init {
	sudo services start docker >/dev/null 2>&1 || sudo systemctl start docker >/dev/null 2>&1
}

function pause {
	printf "\n"
	read -sp "Press ENTER to continue..."
}

function confirmation {
	local confirmation
	read -p "
	[y/N] $1
	> " confirmation

	case "$confirmation" in
		y|Y) echo true;;
		*) echo false
	esac
}

function getListContainer {
	printf "${boldblue}"
	sudo docker ps -a --format 'Name: {{.Names}} \nImage: {{.Image}}\n'
	printf "${nc}"
}

function getListImage {
	printf "${boldblue}$(sudo docker image ls --format 'table {{.Repository}}\t{{.Tag}}\t{{.CreatedSince}}\t{{.Size}}')\n${nc}"
}

function runningContainerStats {
	trap main SIGINT #Ctrl-C trapped to main menu
	printf "${boldblue}"
	sudo docker container stats
	printf "${nc}"
}

function resume {
	getListContainer
	printf "Name of the container to resume:\n"
	local name
	read -p "> " name

	[[ "$(confirmation 'Launch in the background ?')" == "true" ]] || local arg="-ai"

	sudo docker start $arg $name
}

function save {
	getListContainer
	printf "Container name to save:\n"
	local name
	read -p "> " name
	local id=$(sudo docker ps -aqf "name=$name")
	sudo docker commit $id $name
}

function stop {
	getListContainer
	printf "Container name to stop [all]:\n"
	local name
	read -p "> " name
	case "$name" in
		all) sudo docker stop $(sudo docker ps -aq);;
		*) sudo docker stop $(sudo docker ps -aqf "name=$name")
	esac
}

function createc {
	getListImage
	local repo
	read -p "
	[!] Repo name
	> " repo

	local tag
	read -p "
	[!] Tag [latest]
	> " tag

	case "$tag" in
		latest|"") local image="$repo:latest";;
		*) local image="$repo:$tag"
	esac

	local arg="--network host"

	[[ "$(confirmation 'Delete after exit ?')" == "true" ]] && arg+=" --rm"

	[[ "$(confirmation 'Run in background ?')" == "true" ]] && arg+=" -d" || arg+=" -it"

	if [[ "$(confirmation 'Bind a directory ?')" == "true" ]]; then
		local ldir
		read -p "[?] Local directory\n> " ldir

		local rdir
		read -p "[?] Container directory\n> " rdir
	fi

	[[ "$(confirmation 'Give extended privileges ?')" == "true" ]] && arg+=" --privileged"

	read -p "
	[!] Name of the container
	> " name && \
	arg+=" --name $name -h $name"

	printf "\n\t${cyan}Optionnal launch option${nc}"
	local addarg
	read -p "
	> " addarg
	arg+=" $addarg"

echo $arg
	sudo docker container run $arg $image
}

function deletec {
	getListContainer
	printf "Container name to delete [all]:\n"
	local name
	read -p "> " name
	case "$name" in
		all|"") sudo docker container prune;;
		*) sudo docker rm $name
	esac
}

function pull {
	printf "Name of the image to download:\nex: ubuntu/nginx\n"
	local image
	read -p "> " image

	printf "\n"

	sudo docker pull $image
}

function createi {
	printf "Absolute path to dockerfile:\nex: /root/git/master\n"
	local path
	read -p "> " path

	printf "\nImage name:\n"
	local name
	read -p "> " name

	sudo docker build -t $name "$path"
}

function deletei {
	getListImage
	printf "Image name to delete [all]:\n"
	local name
	read -p "> " name
	case "$name" in
		""|all) sudo docker rmi -f "$(sudo docker images -aq)";;
		*) sudo docker rmi -f $name
	esac
}

################################################### Menu ###################################################

function containerMenu {
	clear
	printf "${cyan}EZ-Docker - Container
	${boldblue}[1] List
	[2] Running stats
	${boldgreen}[3] Resume
	[4] Save a running container
	[5] Create
	${yellow}[6] Stop
	${red}[7] Delete${nc}
	"
	local choice

	read -p "> " choice
	clear

	case "$choice" in
		1)
			getListContainer
			pause;;
		2)
			runningContainerStats
			pause;;
		3)
			resume
			pause;;
		4)
			save
			pause;;
		5)
			createc
			pause;;
		6)
			stop
			pause;;
		7)
			deletec
			pause
	esac
}

function imageMenu {
	clear
	printf "${cyan}EZ-Docker - Image
	${cyan}[1] List
	${boldgreen}[2] Download
	[3] Create from dockerfile
	${red}[4] Delete${nc}
	"

	read -p "> " choice
	clear

	case $choice in
		1)
			getListImage
			pause;;
		2)
			pull
			pause;;
		3)
			createi
			pause;;
		4)
			deletei
			pause;;
		q|Q) exit 0
	esac
	# Todo: update an image; delete the current version & download the :latest
}

function main {
	clear
	trap - SIGINT #Ctrl-C allowed
	printf "${cyan}EZ-Docker v$version
	${boldgreen}[1] Container
	[2] Image${nc}
	"

	local main
	read -p "> " main
	clear

	case "$main" in
		1) containerMenu;;
		2) imageMenu;;
		q|Q) exit 0
	esac
}

################################################### Main ###################################################

init
while true
do
	main
done