import json
import os

os.system('rm -rf certs')
os.system('mkdir certs')
os.system('wget https://www.amazontrust.com/repository/AmazonRootCA1.pem -O certs/AmazonRootCA1.pem')

json_str = input('Enter JSON results from API: ')
obj = json.loads(json_str)

with open('certs/device.crt', 'w') as f:
    f.write(obj['cert'])
with open('certs/private.key', 'w') as f:
    f.write(obj['private_key'])
with open('certs/public.key', 'w') as f:
    f.write(obj['public_key'])
