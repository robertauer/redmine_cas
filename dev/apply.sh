#!/bin/bash
DOGU="${1}"

rm -rf ./redmine_cas
../bundle/bundle_plugin.rb
docker exec -it "${DOGU}" rm -rf "usr/share/webapps/${DOGU}/plugins/redmine_cas"
docker cp ./redmine_cas "redmine:usr/share/webapps/${DOGU}/plugins/"
docker restart "${DOGU}"
tail -f "/var/log/docker/${DOGU}.log"
