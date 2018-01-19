# Installation procedure of the health check script *hc* for Linux and Unix
## Description 
The wrapper script [run-hc.sh](%20https://github.com/gpoppino/run-hc/) provides two features for the [hc](https://github.com/gpoppino/hc) script:
1. Email notifications.
2. Remote execution through SSH.
## Prerequisites
1. Access to a SMTP server that can deliver email for failure notifications.
2. Public and private SSH key pair without a passphrase if remote execution is required.
3. Possibility to edit */etc/sudoers* with *visudo* to add some commands to run in privileged mode as root to the user running the script.
## Configuring SUDO
For illustrative purposes, it is assumed that the script will run as user *gpoppino*. You can run the script as any regular user you wish instead. Just make sure to replace *gpoppino* with the username used by the script in your system.
### SUDO entry
Add the following to your sudoers file:
	gpoppino ALL=(root) NOPASSWD: /usr/sbin/ntpq, /usr/bin/df, /usr/bin/grep, /sbin/multipath, /opt/novell/eDirectory/bin/ndsconfig, /opt/novell/eDirectory/bin/ndsrepair, /usr/bin/systemctl
Some commands are optional, like: ndsconfig, ndsrepair and systemctl. Others commands that might be required are: restart, service, /usr/bin/lsxiv, /usr/sbin/lspath, /usr/bin/datapath, /opt/DynamicLinkManager/bin/dlnkmgr and /usr/DynamicLinkManager/bin/dlnkmgr.
## Installation
The script will be installed under *$HOME/scripts/hc-master*. You can choose any other directory, but this guide will use that directory.
The installation procedure is:
1. Create the install directory: `cd; mkdir scripts`
2. Download the *hc* script: `cd $HOME/scripts; wget https://github.com/gpoppino/hc/archive/master.zip `
3. Unzip the zip file: `unzip master.zip; rm master.zip`
4. Download the *run-hc.sh* script: `wget https://github.com/gpoppino/run-hc/archive/master.zip `
5. Unzip the new zip file: `unzip master.zip`
6. Copy the *run-hc.sh* script into the *$HOME/scripts* directory: `cp run-hc-master/run-hc.sh .`
## Configuration of the *hc* script
The script main configuration file is called **config.general**. Open it with your favorite editor and adjust its variables as desired. The options in the configuration file are as descriptive as possible. The defaults work most of the time. Once you finished with its configuration, just test it by running the script with:
	cd $HOME/scripts/hc-master; bash main_healthcheck.sh. 
It is possible that the DNS resolution check file that resides in the *extensions/* directory should be removed if you do not want it to run. For example: `rm -f extensions/check_name_resolution`.
## Configuration of the *run-hc.sh* script
You will have to configure the *run-hc.sh* script before attempting to execute it successfully.
The variables at the file’s header are the following:
* HC\_HOME: directory where the *hc* script is installed. For example: *$HOME/scripts/hc-master*.
* RECIPIENTS: email recipients of notifications in case of checks failures.
* SMTP\_USER: username of the user that will be sending the email (if option `-a` is used).
* SMTP\_PASS: password of the username sending the email (if option `-a` is used).
* SMTP: hostname or IP address of the email/smtp server.
* HOSTS: hostnames or IP addresses separated by a space where the script will be executed (ir option `-r` is used).
* MAIL\_SUBJECT: email subject.
* REMOTE\_USER: username used to login remotely to every host that appears in the variable HOSTS.
Once configured, you can test it with: `bash $HOME/scripts/run-hc.sh`.
## Installation in CRON
There are two alternatives to run the health check script:
1. Running it locally via CRON.
2. Running it remotely through SSH via CRON.
For instance, if you decide to run it locally, just add the following to your cron file (replace the path and time of execution to accommodate it to your needs):
	0 8 * * * /home/gpoppino/scripts/run-hc.sh
If, on the other hand, you want to run it remotely, just add:
	0 8 * * * /home/gpoppino/scripts/run-hc.sh -r
In case you need to add SMTP authentication, just use the `-a` option. Finally, grant the execution permission to the script: `chmod +x $HOME/scripts/run-hc.sh`
