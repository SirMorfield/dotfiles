# add to end of crontab
(crontab -l && echo "*/5 * * * * nice bash /home/joppe/.dotfiles/rs/rs.sh push all > /dev/null 2>&1") | crontab -
