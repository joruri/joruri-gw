#!/bin/bash
DONE_FLAG="/tmp/$0_done"

echo '#### Configure delayed_job ####'
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

  cp /var/share/jorurigw/config/samples/delayed_job /etc/init.d/
  chmod +x /etc/init.d/delayed_job
  /sbin/chkconfig --add delayed_job
  /sbin/chkconfig delayed_job on
  /etc/init.d/delayed_job start

}

others() {
  echo 'This OS is not supported.'
  exit
}

if [ -f /etc/centos-release ]; then
  centos
elif [ -f /etc/lsb-release ]; then
  if grep -qs Ubuntu /etc/lsb-release; then
    ubuntu
  else
    others
  fi
else
  others
fi

touch $DONE_FLAG
