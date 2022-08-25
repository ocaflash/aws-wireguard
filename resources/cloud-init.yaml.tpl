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


system_info:
  default_user:
    groups: [docker]
  wguser:
    groups: [docker]

runcmd:
  - cd /home/wguser/wireguard && docker-compose up -d
  - tar cvzf "backup_$(date +%Y-%m-%d).tgz" /home/wguser/wireguard/linguard/data/*
