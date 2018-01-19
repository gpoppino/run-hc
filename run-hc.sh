#!/bin/bash

VERSION=1.0

HOSTS="localhost"
HC_HOME="/home/gpoppino/scripts/hc-master"
RECIPIENTS="gpoppino root"
REMOTE_USER=gpoppino
SMTP_USER=gpoppino
SMTP_PASS=mypassword
SMTP=localhost
MAIL_SUBJECT="Failed Health Checks!"

HC_OUTPUT="/tmp/hc_output.$(date +%s)${RANDOM}"
HC_FAILED_OUTPUT="/tmp/hc_failed_output.$(date +%s)${RANDOM}"

REMOTE_EXECUTION_FLAG=0
SMTP_AUTH_FLAG=0


function _run_hc_local()
{
    bash ./main_healthcheck.sh
}

function _run_hc_remote()
{
    bash ./healthcheck.sh $REMOTE_USER@$1
}

function _run_hc()
{
    eval $1 > ${HC_OUTPUT} 2>&1
    RETVAL=$?

    [ $RETVAL -ne 0 ] && cat ${HC_OUTPUT} | grep -iv probes >> ${HC_FAILED_OUTPUT}
}

function run_hc()
{
    cd $HC_HOME

    if [ ${REMOTE_EXECUTION_FLAG} -eq 1 ];
    then

        for h in $HOSTS
        do
            _run_hc "_run_hc_remote $h"
        done

    else
        _run_hc "_run_hc_local"
    fi

    rm -f ${HC_OUTPUT}

    [ -e ${HC_FAILED_OUTPUT} ] && return 1
    return 0
}

function send_email()
{
    if [ ${SMTP_AUTH_FLAG} -eq 1 ];
    then
        cat ${HC_FAILED_OUTPUT} | \
         env MAILRC=/dev/null smtp=$SMTP smtp-auth-user=$SMTP_USER smtp-auth-password=$SMTP_PASS \
            smtp-auth=login mailx -n -s "$MAIL_SUBJECT" $RECIPIENTS
    else
        cat ${HC_FAILED_OUTPUT} | \
         env MAILRC=/dev/null smtp=$SMTP mailx -n -s "$MAIL_SUBJECT" $RECIPIENTS
    fi
}

function clean_up()
{
    [ -e ${HC_FAILED_OUTPUT} ] && rm -f ${HC_FAILED_OUTPUT}
}

function usage()
{
    echo ""
    echo "Usage:"
    echo "  $0 [ -h | -a | -r ]"
    echo ""
    echo "OPTIONS:"
    echo "  -h  Shows this help."
    echo "  -a  Enables SMTP authentication."
    echo "  -r  Enables remote SSH execution."
    echo ""
}

while getopts "hra" OPTION
do
    case $OPTION in
        h)
            usage
            exit 0
            ;;
        r)
            REMOTE_EXECUTION_FLAG=1
            ;;
        a)
            SMTP_AUTH_FLAG=1
            ;;
        ?)
            usage
            exit 0
            ;;
    esac
done

run_hc || send_email
clean_up

