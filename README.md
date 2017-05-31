# geonode_install
Ansible playbook to install Geonode 2.4 on Ubuntu 16.04.

Automates installation, configuration and house-styling of Geonode on a bare Ubuntu server.

Based on the documentation [GeoNode (v2.4) installation on Ubuntu 14.04](http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/index.html).

Additional configuration added to resolve issues found while uploading and viewing data, e.g. increased JVM memory, updated admin password for OGC server, adding SSL, establishing a backup regime.

### Disclaimer
This code was created for use on our own servers and is shared here to help others.

It creates a server with the branding 'CityData', which fits own house style at [City Futures Research Centre](https://cityfutures.be.unsw.edu.au).