#!/usr/bin/env bash

if [ "X$1" == X ]; then
  echo "prepares a new container does the following:"
  echo "- installs ssh keys from $KEYS"
  echo "- sets random root passwords"
  echo "- deletes the 'ubuntu' user"
  echo
  echo "usage: 'lxc-prep <container_name>'"
  echo
  echo ". or do them all with 'lxc-prep all'"
  echo ".. note.. they must be running"
  exit
fi


prep(){
  ROOTFS=/var/lib/lxc/$NAME/rootfs
  KEYS=~/.ssh/authorized_keys

  if [ ! -d "$ROOTFS" ] ; then
    echo cannot find the rootfs : $ROOTFS
    exit 1
  else
    #check its up
    STATE="$(lxc-info -n $NAME | grep ^State | awk '{print $2}')"
    if [ "X$STATE" == XRUNNING ]; then
      echo "$NAME: prepping"
      FOO=$(cat $KEYS)
      lxc-attach -n $NAME -- mkdir -p /root/.ssh
      lxc-attach -n $NAME -- chmod 700 /root/.ssh
      lxc-attach -n $NAME -- tee /root/.ssh/authorized_keys <$KEYS 1>/dev/null
      lxc-attach -n $NAME -- chmod 600 /root/.ssh/authorized_keys
      #used to set a random password
      PASS="$(head -1000 /dev/urandom | tr -dc A-Za-z0-9 | tail -1 | cut -c 1-32)"
      STRING="root:$PASS"
      lxc-attach -n $NAME -- chpasswd <<<"$STRING"
      lxc-attach -n $NAME -- userdel ubuntu 2>/dev/null
    else
      echo "$NAME: skipping (not running)"
    fi
  fi
}

NAME="$1"
if [ "$NAME" == all ]; then
  cd /var/lib/lxc
  FOO="$(find ./  -maxdepth 1 -type d | sed "s+./++g" | grep -v "^$")"
  for NAME in $FOO ; do
    prep $NAME
  done
else
  prep $NAME
fi

