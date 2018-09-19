from __future__ import print_function
import sys
import yaml

identities = {}
with open(sys.argv[1]) as fident:
	identities = yaml.load(fident)
users = yaml.load(sys.stdin)
users_uid = dict([ (u['metadata']['name'], u['metadata']['uid']) for u in users['items'] ])

for ident in identities.get('items'):
	username = ident['user']['name']
	uid = users_uid[username]
	print('%s %s -> %s' % (username, ident['user'].get('uid'), uid), file=sys.stderr)
	ident['user']['uid'] = uid

yaml.dump(identities, sys.stdout, default_flow_style=False)
