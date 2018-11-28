# geonode_install
Ansible playbook to install Geonode 2.4 on Ubuntu 16.04.

Automates installation, configuration and house-styling of Geonode on a bare Ubuntu server.

Based on the documentation [GeoNode (v2.4) installation on Ubuntu 14.04](http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/index.html).

Additional configuration added to resolve issues found while uploading and viewing data, e.g. increased JVM memory, updated admin password for OGC server, adding SSL, establishing a backup regime.

### Disclaimer
This code was created for use on our own servers and is shared here to help others.

It creates a server with the branding 'CityData', which fits our own house style at [City Futures Research Centre](https://cityfutures.be.unsw.edu.au).

# Installation instructions

These instructions are for the test environment. For dev or prod environment, substitute dev or prod for test below.

## Launch EC2 instance

AMI: Canonical, Ubuntu, 16.04 LTS, amd64 xenial image build on 2018-05-22

3 volumes:  
* dev/sda1 - root
* /dev/sdb - data
* /dev/sdg - Geowebcache

security group: cftest

Tags:
* Name
* Owner

## Install SSH key
PuTTY to the Ansible control server (`control`)

PuTTY to the new server (`target`)

Copy content of control:~ubuntu/.ssh/rsa_id.pub to target:~ubuntu/.ssh/authorized_keys

SSH from control to target and confirm new host/key

## Install python2

From control:~ubuntu\geonode_install

Set IP address of target in test and test-python3 inventory files

Create host_vars/`ip_address` like existing files

Run:  
```
TOBECONTINUED
```
