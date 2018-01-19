# Procedimiento de instalación del script *hc* de health check Linux/Unix
## Prerequisitos
1. Si se desea enviar notificaciones por mail con los resultados de la ejecución del script en caso de haberse detectado algún fallo, se debe utilizar también un script wrapper del script *hc* para realizar esta tarea. Se puede utilizar el script que se encuentra en [https://github.com/gpoppino/run-hc/archive/master.zip](https://github.com/gpoppino/run-hc/archive/master.zip)
2. Si se desea utilizar el modo de ejecución remoto por SSH, es necesario crear un par de llaves cifradas de SSH *sin passphrase* e instalarlas en cada host en el que se desea ejecutar el script para el usuario con el que se va a ejecutar el mismo.
3. Si el script debe ejecutarse con permisos de usuario común y no como root, será necesario agregar los siguientes permisos de SUDO. Por ejemplo, si el script se ejecutará con el usuario _gpoppino_, se debe agregar al /etc/sudoers con visudo lo siguiente:

`gpoppino ALL=(root) NOPASSWD: /usr/sbin/ntpq, /usr/bin/df, /usr/bin/grep, /sbin/multipath, /opt/novell/eDirectory/bin/ndsconfig, /opt/novell/eDirectory/bin/ndsrepair, /usr/bin/systemctl`

También es posible que se tenga que agregar el script de inicialización de un servicio como tomcat en SLES11 o sistemas con System V al /etc/sudoers (en SLES12 o sistemas con SystemD no es necesario) cuando la opción *HANDLE_SERVICES* se encuentre habilitada. Por ejemplo: /etc/init.d/tomcat. Otros comandos opcionales son: *restart, service, /usr/bin/lsxiv, /usr/sbin/lspath, /usr/bin/datapath, /opt/DynamicLinkManager/bin/dlnkmgr y /usr/DynamicLinkManager/bin/dlnkmgr*. Nota: Es recomendado utilizar SUDO para ejecutar el script.
## Premisas
1. Se asume que el script de monitoreo *hc* se instala en
_$HOME/scripts/hc-master_ y _run-hc.sh_ en _$HOME/scripts_.
## Descarga del script
1. Descargar el script desde el siguiente link: [https://github.com/gpoppino/hc/archive/master.zip](https://github.com/gpoppino/hc/archive/master.zip). Por ejemplo: `$ wget https://github.com/gpoppino/hc/archive/master.zip`.
2. Descomprimir el archivo zip con `unzip master.zip`.
3. Repetir el mismo procedimiento para el script *run-hc.sh* ubicado en: [https://github.com/gpoppino/run-hc/archive/master.zip](https://github.com/gpoppino/run-hc/archive/master.zip).
4. Copiar el script *run-hc.sh* a *$HOME/scripts*.
## Configuración del script
1. Configurar el script *hc* editando el archivo _config.general_.
2. Intentar ejecutar el script con `cd $HOME/scripts/hc; bash main_healthcheck.sh`. Luego realizar ajustes a la configuración del mismo. Es posible que el chequeo de resolución DNS que existe en el directorio _extensions/_ deba ser eliminado para que no se ejecute. Por ejemplo:
	`$ rm -f extensions/check_name_resolution`
## Instalación del script en CRON
### Configuración
1. Antes de agregar el script *run-hc.sh* al CRON, este debe ser configurado. En el header del script se deben editar las variables:
* HC\_HOME: directorio donde se encuentra el script instalado. Ejemplo: *$HOME*/scripts/hc-master.
* RECIPIENTS: destinatarios del correo que enviará el script en caso de falla.
* SMTP\_USER: usuario que enviará el correo, en caso de habilitar la opción "-a".
* SMTP\_PASS: password del usuario que enviará el correo, en caso de habilitar la opción "-a".
* SMTP: dirección de IP del servidor de correos SMTP.
* HOSTS: direcciones de IP o nombres de hosts en los que se ejecutará el script remotamente si se utiliza la opción "-r".
* MAIL\_SUBJECT: Título del email.
* REMOTE\_USER: nombre de usuario con que se hará login en el host remoto.
2. Finalmente, ejecutar el script para probarlo:
	`$ bash $HOME/scripts/run-hc.sh`
### Instalación en CRON
Existen dos posibilidades para ejecutar el script desde CRON:
1. Agregar el script `run-hc.sh` al CRON para que se ejecute localmente y envíe notificaciones por email.
2. Agregar el script `run-hc.sh` al CRON para que se ejecute en todos los servidores que figuren en la variable _HOSTS_ y envíe notificaciones por email.

Por ejemplo, si se decide ejecutar el script localmente sin autenticación SMTP, agregar al CRON (si se desea ejecutar cada día a las 8 AM): 

`0 8 * * * /home/gpoppino/scripts/run-hc.sh`

Si, en cambio, se desea efectuar una ejecución remota por SSH (opción *-r*) con autenticación SMTP (opción *-a*):

`0 8 * * * /home/gpoppino/scripts/run-hc.sh -r -a`

Finalmente, se debe otorgar el permiso de ejecución al script:

`$ chmod +x $HOME/scripts/run-hc.sh`

