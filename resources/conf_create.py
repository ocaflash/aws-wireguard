import json
import yaml
from time import sleep
from os.path import dirname, join
from os.path import exists
from uuid import uuid4 as gen_uuid
from typing import Dict, Any
from time import sleep
from linguard.common.models.user import users, User
from linguard.common.properties import global_properties
from linguard.common.utils.system import try_makedir, Command
from linguard.core.config.web import config as web_config
from linguard.core.config.wireguard import config
from linguard.core.managers.wireguard import wireguard_manager
from linguard.core.managers.config import config_manager
from linguard.core.models import interfaces, Interface, Peer
from linguard.core.utils.wireguard import generate_privkey, generate_pubkey

filepath = 'data/linguard.yaml'
file_users = 'data/users.csv'

on_up = ['/usr/sbin/iptables -I FORWARD -i tough-moth -j ACCEPT',
         '/usr/sbin/iptables -I FORWARD -o tough-moth -j ACCEPT',
         '/usr/sbin/iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE']

on_down = ['/usr/sbin/iptables -D FORWARD -i tough-moth -j ACCEPT',
           '/usr/sbin/iptables -D FORWARD -o tough-moth -j ACCEPT',
           '/usr/sbin/iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE']

interface_dict = dict({'name': 'wg0', 'uuid': gen_uuid().hex, 'gw_iface': 'wg0',
                       'ipv4_address': '${ipv4_address}/26', 'listen_port': '${client_port}',
                       'auto': True, 'on_up': on_up, 'on_down': on_down})


def cleanup():
    yield
    config_manager.load_defaults()
    config.load_defaults()


def find_yaml_data(config_file):
    with open(config_file) as fh:
        dictionary_data = yaml.safe_load(fh)
    return dictionary_data['web'].secret_key


def create_admin(user, passwd):
    admin_user = User(user)
    admin_user.password = passwd
    users[admin_user.id] = admin_user
    workdir = join(dirname(__file__), 'data')
    try_makedir(workdir)
    global_properties.workdir = workdir
    config_manager.load()
    config_manager.save()
    users.save(web_config.credentials_file, find_yaml_data(filepath))


def get_system_interfaces() -> Dict[str, Any]:
    ifaces = {}
    for iface in json.loads(Command('ip -json address').run().output):
        ifaces[iface['ifname']] = iface
    return ifaces


def create_iface(name, ipv4, port):
    gw = list(filter(lambda i: i != 'lo', get_system_interfaces().keys()))[0]
    return Interface(name=name, description='', gw_iface=gw, ipv4_address=ipv4, listen_port=port, auto=False,
                     on_up=on_up, on_down=on_down)


def add_peers(iface):
    if exists(file_users):
        with open(file_users, 'r') as f:
            list_users = f.read().splitlines()
        for user in list_users:
            list_user = user.split(':')
            ipv4_address_interface = '${ipv4_address}'
            index_ldot = ipv4_address_interface.rfind('.')+1
            ipv4_address_client=ipv4_address_interface[:index_ldot]+str(int(list_user[0])+int(10))+'/32'
            peer = Peer(name=list_user[1], description='', ipv4_address=ipv4_address_client,
                        nat=False, interface=iface, dns1='8.8.8.8', dns2='1.1.1.1')
            iface.add_peer(peer)


def fill_config_data():
    open('data/.setup', 'w').close()
    iface = create_iface(interface_dict['name'], interface_dict['ipv4_address'],
                         interface_dict['listen_port'])
    interfaces[iface.uuid] = iface
    add_peers(iface)
    iface.auto = True
    iface.up()
    config.set_default_endpoint()
    config_manager.config_filepath = filepath
    config_manager.save()
    config.apply()
    wireguard_manager.stop()
    sleep(1)
    wireguard_manager.start()

create_admin('${web_admin_name}', '${web_admin_pass}')
fill_config_data()
