#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Supply 2 arguments: push|pull dir"
	exit 1
fi

if [ $(hostname) == "laptop" ]; then
	localtrash="$HOME/.local/share/Trash/files/"
else
	localtrash="$HOME/Trash"
fi

if [ $(curl -s ifconfig.me) == "80.61.192.39" ]; then
	sshcmd="'ssh'"
	server="joppe@192.168.2.1"
else	
	sshcmd="'ssh -p 10001'"
	server="joppe@joppekoers.nl"
fi

if [ "$2" == "all" ]; then
	dir="/home/joppe/Downloads /home/joppe/Desktop /home/joppe/GitHub"
	# dir="/home/joppe/GitHub"
else
	dir=$2
fi

if [ "$1" = "pull" ]; then
	sh -c "rsync -ahP --delete-after --delete-excluded --backup-dir --links -e $sshcmd $server:/home/joppe/laptop/$dir '$HOME'"
elif [ "$1" = "push" ]; then
	sh -c "rsync -ahP --delete-after --delete-excluded --backup-dir ../laptop_deleted/ --links -e $sshcmd $dir $server:/home/joppe/laptop/"
else
	echo "Invalid argument, use push|pull dir|all"
fi
