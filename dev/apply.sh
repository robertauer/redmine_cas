#!/bin/bash
DOGU="redmine"

../bundle/bundle_plugin.rb
docker exec -it "${DOGU}" rm -rf "usr/share/webapps/${DOGU}/plugins/redmine_cas"
docker cp ./redmine_cas "redmine:usr/share/webapps/${DOGU}/plugins/"
docker restart "${DOGU}"
watch "docker ps |grep ${DOGU}"
