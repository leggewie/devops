#!/bin/bash
# set up the node just far enough to be able to manage it via ansible going forward

set -e # exit on all errors

SSH_KEY='ssh-dss AAAAB3NzaC1kc3MAAACBAKitW3KR9TG/tgvsYQ+OFJWRjngTGq4TGcSFmX6/wiIiQPARxPnjytXFjRKgIZkb81K/YGNHrHk4W9FVdvY7hYOaP0sdT/KyiLuyh+Q667mcjLGHfkIRHb1dBZSY1gFNCJums4809qBLEbQismHAJb8bSZ7Gu8pDKk5sF8H4bjpdAAAAFQCDfsCC5nfXeijFcg+rLsdf0KvuiQAAAIEApJ0X1t7Xm2bXy99lF1RSY617F2wg2zHJUHos6DlKZ69O3Z+ORtY4xbETYARgTLId/x/4XqoMXISD72NI5f/atxVXB3iZjPvUsIqTMfTDqpMKsAVQGR3nJfAgMj10AKbI87FeX2MuEvKaBZlhW6wMDY3NSUprTlkLuknfZQHwdSIAAACAdrp5My2UntwL5djIdV2ZB1qAKm/Vd9caE3nfvhpPOGydqaiGZG6lJWmB2m/Ezy6TiiyqMhJOUa20X0TpR/Jk7IXlu7jZKFPIbFaM65hXn4+n6sLoPs2ZgweLZ+Ab1++cDKihw2nU0AaUDI4QKfEes/3yaLgUuPb3SYEJD1BAXPo= leggewie@Rolf'
SSH_KEY='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFp4mGpUoB6N88nWHusqCFoan6a7vCa6PjnQ9/Uv5YGl foss@rolf.leggewie.biz'
KEY_FILE=/root/.ssh/authorized_keys

# set up my ssh key for root
mkdir -p $(dirname $KEY_FILE)
touch $KEY_FILE

# add key only if it isn't present yet
grep -q -F "$SSH_KEY" $KEY_FILE 2>/dev/null || echo "$SSH_KEY" >> $KEY_FILE

# ensure proper file permissions on the key
chown root:root $KEY_FILE $(dirname $KEY_FILE)
chmod 600 $KEY_FILE
chmod 700 $(dirname $KEY_FILE)
echo "ssh key set up successfully in" $KEY_FILE

# ansible needs python to run
apt update
apt install python
