# geonode_install
Install CityData 2.8 using Ansible.

![Cloudformation Designer diagram](citydata-designer.png "Cloudformation Designer diagram")

## Pre-requisites
Ansible control machine running:
* boto3
* ansible 2.6 or greater

Check if boto3 is installed:  
```bash
python -c "import boto3"
```
If this gives no output message, boto3 is installed.

If needed, install boto3:  

```bash
pip install boto3
```

Check Ansible version:  
```bash
ansible-playbook --version
```

If older than 2.6, upgrade Ansible:  
```bash
sudo apt-get update
sudo apt-get install ansible
```

## Create AWS resources

On the AWS EC2 Console, under **NETWORK & SECURITY > Key Pairs**:  
* Create a key pair called `CityData`

Download and save the pem file.

If working on Windows, use PuTTYGen to convert the pem to a ppk for use in PuTTY.

Now create the stack, including EC2 instance, volumes and security group:

```bash
ansible-playbook stack.yml -i localhost_ENV --ask-vault-pass
```
...where ENV = dev, test or prod. E.g. localhost_test

When prompted, enter the Ansible vault password for your VPN.

If this step fails, correct the error and delete the CityData stack via the Cloudformation service on the AWS Console. Wait for deletion to complete before retrying.

**Notes:**  
* to test the template without actually creating the stack, use `"mode=test"`

If successful this step will print the private IP address of the CityData EC2 instance created.

Copy these IP addresses into the relevant inventory and group_vars files for the environment you are creating (dev, test or prod).

No longer needed (uses prv_ip):
* Also copy the IP address of the new server into the `data_dest` variable in the host_vars file for the CityData server of the previous environment. This tells Ansible where the data on that previous server needs to be copied to.

## Prepare the EC2 instances

### Authorise the control machine to SSH to the server

Use PuTTY or similar to SSH from your laptop into the new CityData server. You will need a local copy of the key file CityData.ppk (or CityData.pem for Macs).

For PuTTY use the following settings:  
* Session > Host name: *CityData's private IP*
* Session > Connection type: SSH
* Connection > Seconds between keepalives: 120
* Connection > Data > Auto-login username: ubuntu
* Connection > SSH > Auth > Private key file for authentication: *path/to/CityData.ppk*

The first time you SSH to the new server you will be asked to confirm.

On the Ansible control machine:
```bash
cat ~/.ssh/id_rsa.pub
```

Copy the content of id_rsa.pub to your clipboard.

On the CityData server:
```bash
vi ~/.ssh/authorized_keys
```
Paste from the clipboard to a new line at the end of the file.

Now test the connection. On the Ansible control machine:
```bash
ssh <CityData private IP>
```

You will see a warning that the authenticity of the host can't be established.

Type `yes` when prompted to permanently add the IP address of the CityData server to the list of known hosts.

You should now be logged into the CityData server.

Type `exit` to return to the Ansible control machine.

### Run the prep playbook

The `prep.yml` playbook sets the hostname and timezone and installs python2.7 on both servers. It then mounts the large disk on the CityData server and installs Nodejs on the NODE server.

Make sure your inventory file (dev, test or prod) contains the IP addresses of the server.

Run the playbook with:

```bash
ansible-playbook prep.yml -i ENV
```

...where ENV = dev, test or prod.

## Load the S3 buckets

The `s3.yml` playbook downloads the four front-end repos from GitHub to the Ansible control machine, removes the .git folders from each and uploads them to the S3 buckets in the specified environment.

Run the playbook with:

```bash
ansible-playbook s3.yml -i localhost_ENV --ask-vault-pass
```

...where ENV = dev, test or prod. E.g. localhost_test

When prompted, enter the CityData Ansible vault password.

## Save encrypted passwords

Save the admin passwords as encrypted variables:

```bash
ansible-playbook -i localhost_ENV passwd.yml
```

Where ENV = dev, test or prod

You will be prompted for four passwords:
* existing Ansible vault password (Prompt is 'New Vault password:'. Prompt and confirm 3 times)
* new database password (user: postgres)
* new Django admin password
* new Tomcat admin password

The passwords will be saved to the group_vars/ENV file

Where ENV = dev, test or prod

## Install CityData to EC2 server

```bash
ansible-playbook -i ENV geonode.yml --ask-vault-pass
```
Where:  
* ENV = dev, test or prod

### Manually install SSH public keys

#### Sync user
When the playbook gets to `TASK [merge_dev_code : Display sync user public key]` it will display an SSH key (beginning with `ssh-rsa`).

As instructed, copy this key and add it to your GitHub account under Settings > [SSH and GPG keys](https://github.com/account/public_keys).

Give the key a meaningful name such as `merge_dev_code: sync user public key`.

#### Site user
When the playbook gets to TASK `[install_raise : Display site user public key]` it will display an SSH key (beginning with `ssh-rsa`).

As instructed, copy this key and add it to your GitHub account under Settings > [SSH and GPG keys](https://github.com/account/public_keys).

Give the key a meaningful name such as `install_raise: site user public key`.

When done, return to your control server and press `Enter` to continue.

#### If your host has changed

If you have recreated the server since a previous attempt to install RAISE, the playbook may fail with the message:
```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @  
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
```

In that case, as it says, remove the previous fingerprint with:
```bash
ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R IP_ADDRESS
```
...where `IP_ADDRESS` is the private IP address of the server.

Then rerun the playbook.

#### Install complete

If you see the message below, you''ve installed RAISE and can now test the endpoints and continue configuration (below):

`Django RAISE installed on http://RAISE_API_IP_ADDRESS/api`  

...where `IP_ADDRESS` is the private IP address of the server.


When installation is complete you will see the following completion message:  

`Nodejs RAISE installed on http://RAISE_NODE_IP_ADDRESS/`

...where `RAISE_NODE_IP_ADDRESS` is the IP address of the RAISE-NODE server.

# Configuration

## Configure Geoserver

Now login to http://`RAISE_API_IP_ADDRESS`/geoserver as admin using the Geoserver admin password.

Change raise db store password in:  
* Stores > raise_ps > Connection Parameters > passwd

Now test the password by going to Layer Preview > Search: `lga` > OpenLayers

If you see a new tab with a map, the password is OK.

Also set a new Geoserver admin password by going to:  
* Users, Groups, Roles > Users/Groups > default > admin

**Tip**: the `default` link is at the bottom.

## Disable Geoserver console

Once done, on Ansible control run this playbook to disable geoserver admin console for improved security:  

`ansible-playbook console_off.yml -i ENV`

...where ENV = dev, test or prod.

**Tip**: Use `console_on.yml` in the same way if you need to enable the console later.

## Add Django users and groups

Login as Django admin at http://`RAISE_API_IP_ADDRESS`/admin:  
* add users (e.g. `guest`)
* add them to RAISE_GEOSERVER_READERS group

## Cache complex layers

**TODO** Geowebcache for Land Value. Could use my geoWebCache script as used in CityData AWS.

## Name your servers

Request or create an HTTPS-secured public domain, with subdomains for your server. E.g. https://api.raisetoolkit.com and https://node.raisetoolkit.com.

Once the public URLs resolve to your server, update the servers to use the new names:

`ansible-playbook name.yml -i ENV`

...where ENV = dev, test or prod.

## Troubleshooting

### Log file locations

Web server log files are in:
`/var/log/nginx/`

Application logins and Django admin logins are logged with username to:

`/mnt/webapps/raise/code/PropertyValuation/landproperty-user-activity-file.log`

### Servers respond with Welcome to nginx!

If the server root responds to http/s requests with a page headed *Welcome to nginx!*, it may mean you need to name your servers (see above).

# YIPPEE! YOU'RE DONE!

# Speeding up the CityData server

You may change the AWS instance type of the server, for example to speed up the dev server temporarily for data processing.

**On the ansible control machine:**  
Stop services and unmount the big disk:  
```
ansible-playbook unmount.yml -i ENV
```
...where ENV is dev, test or prod

**On the AWS EC2 console Instances page:**  

Stop the server, change instance type and restart:

Select the instance (e.g. CityData-dev).

Stop the server:  
`Actions > Instance State > Stop`

Change Instance Type:  
`Actions > Instance Settings > Change Instance Type`  

   Select new type e.g.:
   * t2.xlarge *- standard*
   * c5.4xlarge *- high-performance*

Restart the server:  
`Actions > Instance State > Start`

**On the ansible control machine:**  
Mount the big disk again:
```
ansible-playbook prep.yml -i ENV
ansible-playbook services.yml -i ENV
```
...where ENV is dev, test or prod

---
