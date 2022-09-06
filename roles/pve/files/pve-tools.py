#!/usr/bin/python3
# python3 pve-tools.py root=8451d9b6-4cd7-4d12-812d-6bd903681a09 /dev/sdb local-lvm-MassStorage7-1 pve1

import sys
import json
import requests
requests.packages.urllib3.disable_warnings()


def create_lvm(device, name, node):
    data = {
        "device": device,
        "name": name,
        "node": node,
        "add_storage": True
    }
    r = requests.post(api_host + lvm_path, headers=header,
                      json=data, verify=False, )
    return r.json()


if "__main__" == __name__:
    apitoken = sys.argv[1]
    device = sys.argv[2]
    name = sys.argv[3]
    node = sys.argv[4]
    api_host = "https://127.0.0.1:8006"
    lvm_path = f"/api2/json/nodes/{node}/disks/lvm"
    apitoken = 'PVEAPIToken root@pam!'+apitoken
    header = {'Content-Type': 'application/json',
              'Authorization': apitoken}
    r = create_lvm(device=device, name=name, node=node)
    print(json.dumps(r, indent=4))
