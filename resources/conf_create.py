import json
import yaml
from os.path import dirname, join
from os.path import exists

from uuid import uuid4 as gen_uuid
from linguard.common.models.user import users, User
from linguard.common.properties import global_properties
from linguard.common.utils.system import try_makedir, Command
from linguard.core.config.web import config as web_config
from linguard.core.config.wireguard import config
from linguard.core.managers.config import config_manager
from linguard.core.models import interfaces, Interface, Peer
from linguard.core.utils.wireguard import generate_privkey, generate_pubkey
from typing import Dict, Any

filepath = "data/linguard.yaml"
file_users = "data/users.csv"

on_up = ["/usr/sbin/iptables -I FORWARD -i tough-moth -j ACCEPT",
         "/usr/sbin/iptables -I FORWARD -o tough-moth -j ACCEPT",
         "/usr/sbin/iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE"]

on_down = ["/usr/sbin/iptables -D FORWARD -i tough-moth -j ACCEPT",
           "/usr/sbin/iptables -D FORWARD -o tough-moth -j ACCEPT",
           "/usr/sbin/iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE"]


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
    workdir = join(dirname(__file__), "data")
    try_makedir(workdir)
    global_properties.workdir = workdir
    config_manager.load()
    config_manager.save()
    users.save(web_config.credentials_file, find_yaml_data(filepath))


def create_interface_dict():
    dct = dict()
    uuid = gen_uuid().hex
    dct["name"] = "wg0"
    dct["uuid"] = uuid
    dct["description"] = "vpn for scranton branch"
    dct["gw_iface"] = "wg0"
    dct["ipv4_address"] = "${ipv4_address}/26"
    dct["listen_port"] = "${web_port}"
    dct["auto"] = True
    dct["on_up"] = on_up
    dct["on_down"] = on_down
    return dct


def get_system_interfaces() -> Dict[str, Any]:
    ifaces = {}
    for iface in json.loads(Command("ip -json address").run().output):
        ifaces[iface["ifname"]] = iface
    return ifaces


def create_iface(name, ipv4, port):
    gw = list(filter(lambda i: i != "lo", get_system_interfaces().keys()))[1]
    return Interface(name=name, description="", gw_iface=gw, ipv4_address=ipv4, listen_port=port, auto=False,
                     on_up=on_up, on_down=on_down)


def add_peers(iface):
    if exists(file_users):
        with open(file_users, 'r') as f:
            list_users = f.read().splitlines()
        for user in list_users:
            list_user = user.split(':')
            peer = Peer(name=list_user[1], description="", ipv4_address="10.0.0."+str(int(list_user[0])+int(10))+"/32",
                        nat=False, interface=iface, dns1="8.8.8.8", dns2="1.1.1.1")
            iface.add_peer(peer)


def fill_config_data():
    open("data/.setup", 'w').close()
    iface = create_iface(create_interface_dict()["name"], create_interface_dict()["ipv4_address"],
                         create_interface_dict()["listen_port"])
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
    cron_manager.start()

# if not exists('data/linguard.yaml.bkp'):
#     shutil.copy(filepath, 'data/linguard.yaml.bkp')
# shutil.copy('data/linguard.yaml.bkp', filepath)
read_list_users(file_users)

create_admin("${web_admin_name}", "${web_admin_pass}")
fill_config_data()
