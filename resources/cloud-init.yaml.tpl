#cloud-config
# Add groups to the system
# Adds the ubuntu group with members 'root' and 'sys'
# and the empty group rps.
groups:
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
    ssh_authorized_keys: {}

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
  - wireguard-tools

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
            - "${dashboard_port}:8080"
            - "${client_port}:${client_port}/udp"
          sysctls:
            - net.ipv4.conf.all.src_valid_mark=1

  - path: /home/wguser/wireguard/scripts/backup.sh
    content: |
      #!/bin/bash
      POSTFIX_DATE=$(date +%Y-%m-%d_%H-%M-%S)
      tar cvzf /tmp/"backup_$POSTFIX_DATE.tgz" --absolute-names /home/wguser/wireguard/linguard/data/*
      aws s3 cp /tmp/"backup_$POSTFIX_DATE.tgz" s3://"${name_prefix}-backup-${project_uuid}"/`date +%Y`/`date +%m`/backup_$POSTFIX_DATE.tgz
      sudo rm -R /tmp/backup_*.tgz
    permissions: '0755'

  - path: /home/wguser/wireguard/scripts/setup_backup.sh
    content: |
      #!/bin/bash
      crontab -l > backup_wireguard
      sudo echo "0 0 * * * /home/wguser/wireguard/scripts/backup.sh" >> backup_wireguard
      crontab /home/wguser/wireguard/backup_wireguard
      sudo rm -R /home/wguser/wireguard/backup_wireguard
    permissions: '0755'

  - path: /home/wguser/wireguard/scripts/interface.tpl
    content: |
      interfaces: !yamlable/interfaces {}
        interfaces: !yamlable/interfaces
          ${uuid_interface}: !yamlable/interface
            auto: true
            description: ''
            gw_iface: eth0
            ipv4_address: ${ipv4_address}/30
            listen_port: ${client_port}
            name: wg0
            on_down:
            - "/usr/sbin/iptables -D FORWARD -i wg0 -j ACCEPT\r"
            - "/usr/sbin/iptables -D FORWARD -o wg0 -j ACCEPT\r"
            - /usr/sbin/iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
            on_up:
            - "/usr/sbin/iptables -I FORWARD -i wg0 -j ACCEPT\r"
            - "/usr/sbin/iptables -I FORWARD -o wg0 -j ACCEPT\r"
            - "/usr/sbin/iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE\r"
            - "/usr/sbin/iptables -I FORWARD -m string --algo bm --string 'BitTorrent' -j DROP\r"
            - "/usr/sbin/iptables -I FORWARD -m string --algo bm --string 'BitTorrent protocol' -j DROP\r"
            - "/usr/sbin/iptables -I FORWARD -m string --algo bm --string 'peer_id=' -j DROP\r"
            - "/usr/sbin/iptables -I FORWARD -m string --algo bm --string '.torrent' -j DROP\r"
            - "/usr/sbin/iptables -I FORWARD -m string --algo bm --string 'announce.php?passkey=' -j DROP\r"
            - "/usr/sbin/iptables -I FORWARD -m string --algo bm --string 'torrent' -j DROP\r"
            - "/usr/sbin/iptables -I FORWARD -m string --algo bm --string 'announce' -j DROP\r"
            - /usr/sbin/iptables -I FORWARD -m string --algo bm --string 'info_hash' -j DROP
            peers: !yamlable/peers {}
            private_key: __private_key__
            public_key: __public_key__
            uuid: ${uuid_interface}

  - path: /home/wguser/wireguard/scripts/setup_config.sh
    content: |
      #!/bin/bash
      while [ ! -f linguard/data/linguard.yaml ]; do sleep 2; done
      sudo sh -c "wg genkey | tee privatekey | wg pubkey > publickey"
      privatekey=$(cat privatekey) && publickey=$(cat publickey) rm -R privatekey && rm -R publickey
      sed '/{}/r scripts/interface.tpl' linguard/data/linguard.yaml > linguard/data/linguard.yaml.tmp
      sed -n '/{}/!p' linguard/data/linguard.yaml.tmp > linguard/data/linguard.yaml && rm -R linguard/data/linguard.yaml.tmp
      sed -i "s|__private_key__|$privatekey|g" linguard/data/linguard.yaml
      sed -i "s|__public_key__|$publickey|g" linguard/data/linguard.yaml
      touch linguard/data/.setup
    permissions: '0755'

system_info:
  default_user:
    groups: [docker]
  wguser:
    groups: [docker]

runcmd:
  - cd /home/wguser/wireguard && docker-compose up -d
  - scripts/setup_backup.sh
  - scripts/setup_config.sh
  - sudo docker restart linguard
