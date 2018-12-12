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

## Create AWS key pair

On the AWS EC2 Console, under **NETWORK & SECURITY > Key Pairs**:  
* Create a key pair called `CityData`

Download and save the pem file.

If working on Windows, use PuTTYGen to convert the pem to a ppk for use in PuTTY.

## Create stack

Now create the stack, including EC2 instance, volumes and security group:

```bash
ansible-playbook stack.yml -i localhost_ENV --ask-vault-pass
```
where ENV = dev, test or prod. E.g. localhost_test

When prompted, enter the Ansible vault password for your project.

If successful this step will print the private IP address of the CityData EC2 instance created.

Copy this IP address into the relevant inventory and group_vars files for the environment you are creating (dev, test or prod).

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

### Prepare the server

The `prep.yml` playbook sets the hostname and timezone and installs python2.7 on both servers. It then mounts the large disk on the CityData server and installs Nodejs on the NODE server.

Make sure your inventory file (dev, test or prod) contains the IP addresses of the server.

Run the playbook with:

```bash
ansible-playbook prep.yml -i ENV_py3
```

where ENV = dev, test or prod.

#### Timout error

If you see:  
```
TASK [prep_server : Set hostname] **********************************************
fatal: [10.116.2.8]: FAILED! => {"msg": "Timeout (12s) waiting for privilege escalation prompt: "}
        to retry, use: --limit @/home/ubuntu/ansible/geonode_install/prep.retry
```

This means the server is timing out trying to set the hostname because the current hostname is not recorded in `/etc/hosts`.

Easiest response is to SSH into your new server and:  

1. Click on the current hostname which will be part of your shell prompt, e.g. the **bold** part of the prompt string below:

  > ubuntu@**ip10_116_2_8**:~$

2. Edit the hosts file with `vi`:

  ```
  sudo vi /etc/hosts
  ```

3. Once in `vi`, add (or change) second line to:  
```
127.0.1.1 CityData-ENV
```

where ENV is your target environment: dev, test or prod.

## Install CityData

```bash
ansible-playbook geonode.yml -i ENV_py2 --ask-vault-pass
```
where:  
* ENV = dev, test or prod

#### Install complete

If you see the message below, you''ve installed CityData and can now test the endpoints and continue configuration (below):

`Geonode installed on http://YOUR_IP_ADDRESS`

where YOUR_IP_ADDRESS is the IP address of the server.

# Configuration

## Configure Geoserver

Now login to http://`YOUR_IP_ADDRESS`/geoserver as admin using the Geoserver admin password.

Change Master Password db store password in:  
* Security > Passwords > Active master password provider > Change password
