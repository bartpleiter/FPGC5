#!/bin/sh

mkdocs build --clean

# Obviously I use public key authentication to login.
# No secret server information is displayed here :P
ssh 192.168.0.201 'rm -rf /var/www/b4rt.nl/html/fpgc4/'
rsync -r site/ 192.168.0.201:/var/www/b4rt.nl/html/fpgc4/
ssh 192.168.0.201 'chown bart:www-data -R /var/www/b4rt.nl/html/fpgc4/'