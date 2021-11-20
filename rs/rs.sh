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
elif [ $(hostname) == "joppes-mbp.home" ]; then
	host="macbook-pro"
else
	host=$(hostname)
fi

if [ "$2" == "all" ]; then
	dir=$(cd $HOME && find . -maxdepth 1 \
		-not -name '.' \
		-not -name '.cache' \
		-not -name '.DS_Store' \
		-not -name 'Library' \
		-not -name 'server1' \
		-not -name '.ssh' \
		-not -name 'Applications' \
		-exec echo "'{}'" \; \
		| tr '\n' ' ')
else
	dir=$2
fi

if [ "$1" = "push" ]; then
	cd $HOME
	sh -c "rsync --archive --no-links --human-readable -P --one-file-system --delete-after --delete-excluded --backup-dir ../$(echo $host)_deleted/ -e $sshcmd $dir $server:/home/joppe/sync/$host/"
else
	echo "pull not implemented"
fi
