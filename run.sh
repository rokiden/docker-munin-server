#!/bin/sh

TZ=${TZ:UTC}
SOCK=/run/fcgi/fcgi.sock

# set timezone
if [[ -e /usr/share/zoneinfo/${TZ} ]]; then
  rm -f /etc/localtime
  ln -s /usr/share/zoneinfo/${TZ} /etc/localtime
  echo ${TZ} > /etc/timezone
fi

if [[ -x $SOCK ]]; then
  rm $SOCK
fi

munin-check -f

/munin_cron.sh

spawn-fcgi -s $SOCK -u munin -g munin /usr/share/webapps/munin/cgi/munin-cgi-graph
chmod 777 $SOCK

crond

LOG=/var/log/munin/munin-update.log
touch $LOG
chown munin:munin $LOG
tail -F $LOG & tail_pid=$!

trap "echo 'stopping cron' ; kill $tail_pid $(cat /var/run/crond.pid)" SIGTERM SIGINT
echo "Waiting for signal SIGINT/SIGTERM"
wait
