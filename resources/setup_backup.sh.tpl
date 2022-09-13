#/bin/bash
sudo crontab -l > backup_wireguard
sudo echo "0 0 * * * /home/wguser/wireguard/scripts/backup.sh" >> backup_wireguard
sudo crontab /home/wguser/wireguard/backup_wireguard
sudo rm -R /home/wguser/wireguard/backup_wireguard
