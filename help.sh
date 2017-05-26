#!/bin/bash
echo "ansible-playbook geonode.yml -i [dev | test | prod] --extra-vars=\"admin_pass=PASSWORD\" --step --start-at-task=\"FIRST_TASK\""