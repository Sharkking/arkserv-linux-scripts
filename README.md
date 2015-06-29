# arkserv-linux-scripts
Script repo for ARK Survival Linux Server Scripts

Setup: 

1) create a backup directory in the users home and change BACKUPPATH

2) create 3 cronjobs to ensure backups, start after machine reboot and alive checks are running:

@reboot sleep 90 && cd /home/arkserv && ./arkserver.sh start >/dev/null 2>&1

*/15 * * * * /home/arkserv/arkserver.sh backup >/dev/null 2>&1

*/5 * * * * /home/arkserv/arkserver.sh check >/dev/null 2>&1


The script creates a lockfile (arklock_$USERNAME) when using manuall shutdown/update that is checked when the script is called with "check" parameter to aviod start from cron during updates or manually planned downtimes

