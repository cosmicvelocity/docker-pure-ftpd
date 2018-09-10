#!/bin/sh

PUREFTPD_OPTIONS=""

if [ ! -z "$PUREFTPD_USER" ] && [ ! -z "$PUREFTPD_PASSWORD" ] && [ ! -z "$PUREFTPD_USER_HOME" ]
then
    echo "Creating a user of pure-ftpd."

    PASSWD_FILE="$(mktemp)"
    echo "$PUREFTPD_PASSWORD
$PUREFTPD_PASSWORD" > "$PASSWD_FILE"

    PASSWD_OPTIONS=""
    if [ ! -z "$PUREFTPD_UID" ]
    then
        PASSWD_OPTIONS="$PASSWD_OPTIONS -u $PUREFTPD_UID"
    fi

    if [ ! -z "$PUREFTPD_GID" ]
    then
        PASSWD_OPTIONS="$PASSWD_OPTIONS -g $PUREFTPD_GID"
    fi

    pure-pw useradd "$PUREFTPD_USER" -f "$PASSWD_FILE" -m -d "$PUREFTPD_USER_HOME" $PASSWD_OPTIONS < "$PASSWD_FILE"

    rm $PASSWD_FILE
fi

if [ -z "$PUREFTPD_MAXCLIENTSNUMBER" ]
then
    PUREFTPD_OPTIONS="$PUREFTPD_OPTIONS --maxclientsnumber 5"
fi

if [ -z "$PUREFTPD_MAXCLIENTSPERIP" ]
then
    PUREFTPD_OPTIONS="$PUREFTPD_OPTIONS --maxclientsperip 5"
fi

if [ -z "$PUREFTPD_PUBLICHOST" ]
then
    PUREFTPD_OPTIONS="$PUREFTPD_OPTIONS --forcepassiveip $PUREFTPD_PUBLICHOST"
fi

PUREFTPD_OPTIONS="$PUREFTPD_OPTIONS --login puredb:/etc/pureftpd.pdb"
PUREFTPD_OPTIONS="$PUREFTPD_OPTIONS --altlog clf:/dev/stdout"
PUREFTPD_OPTIONS="$PUREFTPD_OPTIONS --passiveportrange 30000:30009"
PUREFTPD_OPTIONS="$PUREFTPD_OPTIONS --noanonymous"
PUREFTPD_OPTIONS="$PUREFTPD_OPTIONS --createhomedir"
PUREFTPD_OPTIONS="$PUREFTPD_OPTIONS --nochmod"
PUREFTPD_OPTIONS="$PUREFTPD_OPTIONS --dontresolve"

pure-ftpd $PUREFTPD_OPTIONS
