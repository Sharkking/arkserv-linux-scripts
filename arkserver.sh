#!/bin/bash

#ARK specific Server Settings

Map='TheIsland'
QueryPort='27015'
SessionName='my nice linux ARK'
MaxPlayers='70'
ServerPassword='SERVERPASSWORD'
ServerAdminPassword='ADMINPASSWORD'
Mod='' ## for later use

#Script Settings, please edit to your needs

APPPATH='/home/arkserv/ShooterGame'             #path to where the server is installed
SERVERPATH='Binaries/Linux'                     #path to the server binary
SERVICE='ShooterGameServer'                     #server binary name
USERNAME='arkserv'                              #unix username to run the script
SAVEPATH='/Saved'                               #map saves
HISTORY=1024                                    #history to keep in screen (lines)
BACKUPPATH='arkbackup/'                         #where do backups get stored
HISTORY=1                                       #How much backups (days) should be stored

# Main script

OPTIONS="\"$Map?QueryPort=$QueryPort?SessionName=$SessionName?MaxPlayers=$MaxPlayers?listen?ServerPassword=$ServerPassword?ServerAdminPassword=$ServerAdminPassword\" -game -server -log"
INVOCATION="$APPPATH/$SERVERPATH/$SERVICE $OPTIONS"

ME=`whoami`

as_user() {
  if [ $ME == $USERNAME ] ; then
    bash -c "$1"
  else
    su - $USERNAME -c "$1"
  fi
}

ark_start() {
  if  pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "$SERVICE is already running! Aborting Start"
    exit 1
  else
    rm ~/arklock_$USERNAME
    echo "Starting $SERVICE..."
    as_user "screen -L -h $HISTORY -dmS ark $INVOCATION"
    sleep 2
    if pgrep -u $USERNAME -f $SERVICE > /dev/null
    then
      echo "$SERVICE is now running."
    else
      echo "Error! Could not start $SERVICE!"
    fi
  fi
}

ark_stop() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    kill `pgrep -u $USERNAME -f $SERVICE -l | grep -v screen | cut -d ' ' -f 1`
    touch ~/arklock_$USERNAME
  else
    echo "$SERVICE is not running, nothing to stop"
    exit 0
  fi
}

ark_update() {
  if  pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "$SERVICE is running! Aborting Update"
    exit 1
  else
    echo "Starting Update"
    sleep 2
    touch ~/arklock_$USERNAME
    steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/arkserv +app_update 376030 +quit
    rm ~/arklock_$USERNAME
    exit 0
  fi
}
ark_backup() {
 find $BACKUPPATH/ -type f -mtime +$HISTORY -exec rm -v {} \;
 tar -cf $BACKUPPATH/SavedArk-$(date +%Y-%m-%d_%H%M).tar $APPPATH/Saved
 gzip $BACKUPPATH/SavedArk-$(date +%Y-%m-%d_%H%M).tar
}
ark_check() {
  if  pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    exit 0;
  else
    if [ -f "~/arklock_$USERNAME" ]
    then
      exit 0
    else
      echo "$(date +%Y-%m-%d_%H%M): $SERIVE was not running, restarting" >> ~/check.log
      ark_start
    fi
  fi
}

ark_stop() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    kill `pgrep -u $USERNAME -f $SERVICE -l | grep -v screen | cut -d ' ' -f 1`
    touch ~/arklock
  else
    echo "$SERVICE is not running, nothing to stop"
    exit 0
  fi
}

ark_update() {
  if  pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "$SERVICE is running! Aborting Update"
    exit 1
  else
    echo "Starting Update"
    sleep 2
    touch ~/arklock
    steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/arkserv +app_update 376030 +quit
    rm ~/arklock
    exit 0
  fi
}

ark_backup() {
 find $BACKUPPATH/ -type f -mtime +$HISTORY -exec rm -v {} \;
 tar -cf $BACKUPPATH/SavedArk-$(date +%Y-%m-%d_%H%M).tar $APPPATH/Saved
 gzip $BACKUPPATH/SavedArk-$(date +%Y-%m-%d_%H%M).tar
}
ark_check() {
  if  pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    exit 0;
  else
    if [ -f "~/arklock" ]
    then
      exit 0
    else
      echo "$(date +%Y-%m-%d_%H%M): $SERIVE was not running, restarting" >> ~/check.log
      ark_start
    fi
  fi
}

#Start-Stop here
case "$1" in
  start)
    ark_start
    ;;
  stop)
    ark_stop
    ;;
  backup)
    ark_backup
    ;;
  update)
    ark_update
    ;;
  check)
    ark_check
    ;;
  *)
  echo "Usage: $0 {start|stop|backup|update|check}"
  exit 1
  ;;
esac

