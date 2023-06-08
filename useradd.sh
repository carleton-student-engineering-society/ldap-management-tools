#!/bin/bash

if [ "$#" -ne 4 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: $0 USERNAME FIRSTNAME LASTNAME UID" >&2
  exit 1
fi


USERNAME=$1
FIRSTNAME=$2
LASTNAME=$3
UIDnumber=$4
echo -n "Bind User: "
read BINDUSER
BINDUSER="uid=$BINDUSER,ou=users,dc=mycses,dc=ca"
LDAPHOST=10.7.0.4

echo \
"dn: uid=$USERNAME,ou=users,dc=mycses,dc=ca
cn: $FIRSTNAME $LASTNAME
objectClass: top
objectClass: person
objectClass: organizationalperson
objectClass: inetorgperson
objectClass: posixaccount
loginShell: /bin/bash
sn: $LASTNAME
gecos: $FIRSTNAME $LASTNAME
homeDirectory: /home/$USERNAME
givenName: $LASTNAME
uid: $USERNAME
uidNumber: $UIDnumber
gidNumber: $UIDnumber
userPassword: CSESbestSES2023!

# $USERNAME, groups, accounts, example.org
dn: cn=$USERNAME,ou=groups,dc=mycses,dc=ca
description: User private group for $USERNAME
gidNumber: $UIDnumber
objectClass: posixgroup
objectClass: top
cn: $USERNAME" \
\
| ldapadd -x -h $LDAPHOST -D "$BINDUSER" -W && echo "Success! The $USERNAME account was created. You probably want to run 'ldap-sshkeyadd' next." || echo "FAIL! The $USERNAME account was not created successfully"
