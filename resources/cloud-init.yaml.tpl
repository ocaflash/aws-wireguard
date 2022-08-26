#cloud-config
# Add groups to the system
# Adds the ubuntu group with members 'root' and 'sys'
# and the empty group rps.
groups:
  - ubuntu: [root,sys]
  - wguser
  - docker

# Add users to the system. Users are added after groups are added.
users:
  - default
  - name: wguser
    gecos: wguser
    shell: /bin/bash
    primary_group: wguser
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    lock_passwd: false
    ssh_authorized_keys: []

apt:
  sources:
    docker.list:
      source: deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable
      keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg-agent
  - software-properties-common
  - docker-ce
  - docker-ce-cli
  - docker-compose
  - containerd.io
  - awscli

write_files:
  - path: /etc/sysctl.d/enabled_ipv4_forwarding.conf
    content: |
      net.ipv4.conf.all.forwarding=1
  - path: /home/wguser/wireguard/docker-compose.yaml
    content: |
      version: "3"
      services:
        linguard:
          image: "ghcr.io/joseantmazonsb/linguard:stable"
          container_name: "linguard"
          cap_add:
            - NET_ADMIN
            - NET_RAW
          volumes:
            - "./linguard/data:/data"
          restart: unless-stopped
          ports:
            - "${public_port}:8080"
            - "51820:51820/udp"
          sysctls:
            - net.ipv4.conf.all.src_valid_mark=1

  - path: /home/wguser/wireguard/scripts/conf_backup.sh
    content: |
      #/bin/bash
      POSTFIX_DATE=$(date +%Y-%m-%d_%H-%M-%S)
      tar cvzf /tmp/"backup_$POSTFIX_DATE.tgz" --absolute-names /home/wguser/wireguard/linguard/data/*
      aws s3 cp /tmp/"backup_$POSTFIX_DATE.tgz" s3://"${name_prefix}-backup-${project_uuid}"/`date +%Y`/`date +%m`/backup_$POSTFIX_DATE.tgz
      sudo rm -R /tmp/backup_*.tgz
    permissions: '0755'

  - path: /home/wguser/wireguard/scripts/cron_backup.sh
    content: |
      #/bin/bash
      sudo crontab -l > backup_wireguard
      sudo echo "0 0 * * * /home/wguser/wireguard/scripts/conf_backup.sh" >> backup_wireguard
      sudo crontab /home/wguser/wireguard/backup_wireguard
      sudo rm -R /home/wguser/wireguard/backup_wireguard
    permissions: '0755'

system_info:
  default_user:
    groups: [docker]
  wguser:
    groups: [docker]

runcmd:
  - cd /home/wguser/wireguard && docker-compose up -d
  - /home/wguser/wireguard/scripts/cron_backup.sh
