#!/bin/bash
#
# healthd -- 	This is a simple daemon which can be used to alert you in the
#		event of a hardware health monitoring alarm by sending an 
#		email to the value of ADMIN_EMAIL (defined below).
#
# To Use  --	Simply start the daemon from a shell (may be backgrounded)
#
# Other details -- Checks status every 15 seconds.  Sends warning emails every
#		   ten minutes during alarm until the alarm is cleared.
#		   It won't start up if there is a pending alarm on startup.
#		   Very low loading on the machine (sleeps almost all the time).
#		   This is just an example.  It works, but hopefully we can
#		   get something better written. :')
#
# Requirements -- mail, sensors, bash, sleep
#
# Written & Copyrighten by Philip Edelbrock, 1999.
#
# Version: 1.1
#

ADMIN_EMAIL="nicolas@morey-chaisemartin.com"
CPU_LIMIT=75
DISK_LIMIT=45
DELAY=60
ALARM_DELAY=600
RRDFILE=/var/lib/rrdmon/health.rrd

alert()
{
  echo "Temperature alarm" >&2
  rrdtool lastupdate $RRDFILE | mail -s '**** Hardware Health Warning ****' $ADMIN_EMAIL
}

alert_too_old()
{
  echo "RRD is too old. Something went wrong" >&2
  (
    echo "Date = $(date)  // $(date '+%s')"
    echo "Last RRD Update:"
    rrdtool lastupdate $RRDFILE
  ) | mail -s '**** Hardware Health Warning - RRD Out-of-date ****' $ADMIN_EMAIL

}
# Try loading the built-in sleep implementation to avoid spawning a
# new process every 15 seconds
enable -f sleep.so sleep >/dev/null 2>&1


LABELS=$(rrdtool lastupdate $RRDFILE | head -n 1)
read -r -a array <<< "$LABELS"

while true
do
 i=0
 temps=$(rrdtool lastupdate $RRDFILE | tail -n 1 | sed -e 's/://g')
 set -- $temps
 ts=$1
 if [ $(expr $ts + $DELAY + $DELAY + $DELAY) -lt $(date '+%s') ]; then
	alert_too_old
        sleep $DELAY
	continue
 fi

 shift
 while [ $# -ne 0 ]; do
        LIMIT=99
	if [[ "${array[$i]}" =~ "CPU" ]] || [[ "${array[$i]}" =~ "Core" ]]; then
	  LIMIT=$CPU_LIMIT
	elif [[ "${array[$i]}" =~ "sd" ]]; then
	  LIMIT=$DISK_LIMIT
        fi

	sane_temp=$(echo $1 | sed -e 's/\.[0-9]\+//')

	if [ $sane_temp -ge $LIMIT ]; then
		alert
		sleep $ALARM_DELAY
		break
	fi
	shift
	i=$(expr $i + 1)
 done
 sleep $DELAY
done
