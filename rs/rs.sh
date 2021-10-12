#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Usage: ./rs.sh push|pull dir|all"
	exit 1
fi

if [ $(curl -s ifconfig.me) == "80.61.192.39" ]; then
	sshcmd="'ssh'"
	server="joppe@192.168.2.1"
else	
	sshcmd="'ssh -p 10001'"
	server="joppe@joppekoers.nl"
fi

if [[ $(hostname) == *".codam.nl"* ]] && [[ $(whoami) == "jkoers" ]]; then
	host="codam"
else
	host=$(hostname)
fi

if [ "$2" == "all" ]; then
	dir="$HOME/Downloads $HOME/Desktop $HOME/GitHub"
else
	dir=$2
fi

if [ "$1" = "push" ]; then
	sh -c "rsync -ahP --delete-after --delete-excluded --backup-dir ../$(echo $host)_deleted/ --links -e $sshcmd $dir $server:/home/joppe/sync/$host/"
else
	echo "pull not implemented"
fi
