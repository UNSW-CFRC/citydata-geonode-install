# geonode_install
Simple Ansible playbook to install Geonode 2.4 on Ubuntu 16.04.

Automates installation and configuration of Geonode on a bare Ubuntu server.

Based on the documentation [GeoNode (v2.4) installation on Ubuntu 14.04](http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/index.html).

Package versions modified to run on Ubuntu 16.04.

Additional configuration added to resolve issues found while uploading and viewing data, e.g. increased JVM memory, updated admin password for OGC server.

### Disclaimer
This code was created for use on our servers, and is shared here to help others. Particularly it may assist Geonode developers to write a more robust Ansible role similar to this role to [install Geonode on Ubuntu 14.04](https://github.com/GeoNode/ansible-geonode) (which I discovered after writing this playbook).

Has not been tested end-to-end. While each numbered step has been run and rerun, the main playbook install_geonode.yml has not yet been run. There may be syntax issues. Caveat emptor.

Uses only tasks, does not use handlers or other constructs. 
