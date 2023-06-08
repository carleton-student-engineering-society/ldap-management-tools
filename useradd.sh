#!/bin/bash

if [ "$#" -ne 3 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: $0 USERNAME FIRSTNAME LASTNAME" >&2
  exit 1
fi


USERNAME=$1
FIRSTNAME=$2
LASTNAME=$3
UIDnumber=`expr $(ldapsearch -x -h $LDAPHOST -b "ou=users,dc=example,dc=org" |grep uidNumber |cut -f2 -d" " |sort -n |tail -n1) + 1`
echo -n "Bind User: "
BINDUSER="cn=Directory Manager"
read BINDUSER
BINDUSER="$BINDUSER,ou=users,dc=mycses,dc=ca"
LDAPHOST=10.7.0.4

echo \
"dn: uid=$USERNAME,ou=users,dc=mycses,dc=ca
cn: $FIRSTNAME $LASTNAME
objectClass: top
objectClass: person
objectClass: organizationalperson
objectClass: inetorgperson
objectClass: posixaccount
objectclass: ldapPublicKey
objectclass: host-oid
objectclass: ldapProfile
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
| ldapadd -x -ZZ -h $LDAPHOST -D "$BINDUSER" &>/dev/null && echo "Success! The $USERNAME account was created. You probably want to run 'ldap-sshkeyadd' next." || echo "FAIL! The $USERNAME account was not created successfully"
