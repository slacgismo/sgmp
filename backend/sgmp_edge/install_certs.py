import json

json_str = input('Enter JSON results from API: ')
obj = json.loads(json_str)

with open('certs/device.crt', 'w') as f:
    f.write(obj['cert'])
with open('certs/private.key', 'w') as f:
    f.write(obj['private_key'])
with open('certs/public.key', 'w') as f:
    f.write(obj['public_key'])