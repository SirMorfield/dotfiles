cp -r ../rs ~/.rs/
echo "*/5 * * * * nice bash /home/joppe/rs.sh push all > /dev/null 2>&1" | crontab -
