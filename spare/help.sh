#!/bin/bash

echo "ansible-playbook geonode.yml -i [dev | test | prod] --extra-vars=\"admin_pass=PASSWORD secret_key=SECRET_KEY\" --skip-tags "py3" --step --start-at-task=\"FIRST_TASK\""
