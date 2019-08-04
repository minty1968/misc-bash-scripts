#!/bin/sh
#
# Script to create full and incremental backups (for all databases on server) using innobackupex from Percona.
# http://www.percona.com/doc/percona-xtrabackup/innobackupex/innobackupex_script.html
#
# Every time it runs will generate an incremental backup except for the first time (full backup).
# FULLBACKUPLIFE variable will define your full backups schedule.
#
# (C)2010 Owen Carter @ Mirabeau BV
# This script is provided as-is; no liability can be accepted for use.
# You are free to modify and reproduce so long as this attribution is preserved.
#
# Modifications by Mehmet Can
# 20121130 - Now includes preparing data post backup

INNOBACKUPEX=innobackupex
INNOBACKUPEXFULL=/usr/bin/$INNOBACKUPEX
USEROPTIONS="--user=root --password=550rtps"
TMPFILE="/tmp/innobackupex-runner.$$.tmp"
MYCNF=/etc/my.cnf
MYSQL=/usr/bin/mysql
MYSQLADMIN=/usr/bin/mysqladmin
BACKUPDIR=/mnt/backup/$HOSTNAME # Backups base directory
FULLBACKUPDIR=$BACKUPDIR/full # Full backups directory
INCRBACKUPDIR=$BACKUPDIR/incr # Incremental backups directory
FULLBACKUPLIFE=86400 # Lifetime of the latest full backup in seconds
KEEP=1 # Number of full backups (and its incrementals) to keep
MEMORY=1024M # Amount of memory to use when preparing the backup

# Grab start time
STARTED_AT=`date +%s`

#############################################################################
# Check for errors in innobackupex output
#############################################################################
check_innobackupex_error()
{
if [ -z "`tail -1 $TMPFILE | grep 'completed OK!'`" ] ; then
echo "$INNOBACKUPEX failed:"; echo
echo "---------- ERROR OUTPUT from $INNOBACKUPEX ----------"
    cat $TMPFILE
    rm -f $TMPFILE
    exit 1
  fi
}

#############################################################################
# Display error message and exit
#############################################################################
error()
{
  echo "$1" 1>&2
  exit 1
}

# Check options before proceeding
if [ ! -x $INNOBACKUPEXFULL ]; then
  error "$INNOBACKUPEXFULL does not exist."
fi

if [ ! -d $BACKUPDIR ]; then
  error "Backup destination folder: $BACKUPDIR does not exist."
fi

if [ -z "`$MYSQLADMIN -h 127.0.0.1 $USEROPTIONS status | grep 'Uptime'`" ] ; then
 error "HALTED: MySQL does not appear to be running."
fi

if ! `echo 'exit' | $MYSQL -s $USEROPTIONS` ; then
 error "HALTED: Supplied mysql username or password appears to be incorrect (not copied here for security, see script)."
fi

# Some info output
echo "----------------------------"
echo
echo "$0: MySQL backup script"
echo "started: `date`"
echo

# Create full and incr backup directories if they not exist.
mkdir -p $FULLBACKUPDIR
mkdir -p $INCRBACKUPDIR

# Find latest full backup
LATEST_FULL=`find $FULLBACKUPDIR -mindepth 1 -maxdepth 1 -type d -printf "%P\n" | sort -nr | head -1`

# Get latest backup last modification time
LATEST_FULL_CREATED_AT=`stat -c %Y $FULLBACKUPDIR/$LATEST_FULL`

# Run an incremental backup if latest full is still valid. Otherwise, run a new full one.
if [ "$LATEST_FULL" -a `expr $LATEST_FULL_CREATED_AT + $FULLBACKUPLIFE + 5` -ge $STARTED_AT ] ; then
  # Create incremental backups dir if not exists.
  TMPINCRDIR=$INCRBACKUPDIR/$LATEST_FULL
  mkdir -p $TMPINCRDIR

  # Find latest incremental backup.
  LATEST_INCR=`find $TMPINCRDIR -mindepth 1 -maxdepth 1 -type d | sort -nr | head -1`

  # If this is the first incremental, use the full as base. Otherwise, use the latest incremental as base.
  if [ ! $LATEST_INCR ] ; then
    INCRBASEDIR=$FULLBACKUPDIR/$LATEST_FULL
  else
    INCRBASEDIR=$LATEST_INCR
  fi

  echo "Running new incremental backup using $INCRBASEDIR as base."
  $INNOBACKUPEXFULL --defaults-file=$MYCNF $USEROPTIONS --incremental $TMPINCRDIR --incremental-basedir $INCRBASEDIR > $TMPFILE 2>&1
  check_innobackupex_error
else
  echo "Running new full backup."
  $INNOBACKUPEXFULL --defaults-file=$MYCNF $USEROPTIONS $FULLBACKUPDIR > $TMPFILE 2>&1
  check_innobackupex_error

  echo "Preparing full backup..."
  $INNOBACKUPEXFULL --defaults-file=$MYCNF $USEROPTIONS --apply-log --use-memory=$MEMORY $FULLBACKUP > $TMPFILE 2>&1
  check_innobackupex_error
fi
# Grab start time
STARTED_AT=`date +%s`

#############################################################################
# Check for errors in innobackupex output
#############################################################################
check_innobackupex_error()
{
if [ -z "`tail -1 $TMPFILE | grep 'completed OK!'`" ] ; then
echo "$INNOBACKUPEX failed:"; echo
echo "---------- ERROR OUTPUT from $INNOBACKUPEX ----------"
    cat $TMPFILE
    rm -f $TMPFILE
    exit 1
  fi
}

#############################################################################
# Display error message and exit
#############################################################################
error()
{
  echo "$1" 1>&2
  exit 1
}

# Check options before proceeding
if [ ! -x $INNOBACKUPEXFULL ]; then
  error "$INNOBACKUPEXFULL does not exist."
fi

if [ ! -d $BACKUPDIR ]; then
  error "Backup destination folder: $BACKUPDIR does not exist."
fi

if [ -z "`$MYSQLADMIN -h 127.0.0.1 $USEROPTIONS status | grep 'Uptime'`" ] ; then
 error "HALTED: MySQL does not appear to be running."
fi

if ! `echo 'exit' | $MYSQL -s $USEROPTIONS` ; then
 error "HALTED: Supplied mysql username or password appears to be incorrect (not copied here for security, see script)."
fi

# Some info output
echo "----------------------------"
echo
echo "$0: MySQL backup script"
echo "started: `date`"
echo

# Create full and incr backup directories if they not exist.
mkdir -p $FULLBACKUPDIR
mkdir -p $INCRBACKUPDIR



#if [ -z "`tail -1 $TMPFILE | grep 'completed OK!'`" ] ; then
# echo "$INNOBACKUPEX failed:"; echo
# echo "---------- ERROR OUTPUT from $INNOBACKUPEX ----------"
# cat $TMPFILE
# rm -f $TMPFILE
# exit 1
#fi

THISBACKUP=`awk -- "/Backup created in directory/ { split( \\\$0, p, \"'\" ) ; print p[2] }" $TMPFILE`
rm -f $TMPFILE

echo "Databases backed up successfully to: $THISBACKUP"
echo

# Cleanup
echo "Cleanup. Keeping only $KEEP full backups and its incrementals."
AGE=$(($FULLBACKUPLIFE * $KEEP / 60))
find $FULLBACKUPDIR -maxdepth 1 -type d -mmin +$AGE -execdir echo "removing: "$FULLBACKUPDIR/{} \; -execdir rm -rf $FULLBACKUPDIR/{} \; -execdir echo "removing: "$INCRBACKUPDIR/{} \; -execdir rm -rf $INCRBACKUPDIR/{} \;

echo
echo "completed: `date`"
exit 0

