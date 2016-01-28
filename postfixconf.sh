#!/usr/bin/env bash

MAIN_CF=/etc/postfix/main.cf
SASL_PASSWD=/etc/postfix/sasl_passwd
HOSTNAME_PORT=
USERNAME=
PASSWORD=

#Lame attempt at sed portability
if [ "$(uname)" == "Darwin" ]; then
    SEDi="sed -i .bak "
else
    SEDi="sed -i "
fi

function updateLineContaining() {
    $SEDi -i .bak "/$1/d" $3
    echo "$2" >> $3
}

echo -n "Type the SMTP hostname and port (example: smtp.gmail.com:587): "
read HOSTNAME_PORT
HOSTNAME_PORT="${HOSTNAME_PORT//[[:space:]]/}"
HOSTNAME=$(echo $HOSTNAME_PORT | cut -d":" -f1)

echo -n "Type the full username (example: whatmeworry@gmail.com): "
read USERNAME
USERNAME="${USERNAME//[[:space:]]/}"

ATTEMPT=0
while true
do
    if [ $ATTEMPT -gt 3 ]; then
        echo "Failed authentication."
        exit
    fi
    let ATTEMPT=ATTEMPT+1 

    echo -n "$USERNAME's Password: "
    read -s PASSWORD

    echo ""

    echo -n "Confirm $USERNAME's Password: "
    read -s CONFIRM_PASSWORD

    echo ""

    if [ -z $PASSWORD ]; then
        echo "Password can not be blank. Try again."
        continue
    fi

    if [[ "$PASSWORD" != "$CONFIRM_PASSWORD" ]]; then
        echo "Passwords do not match. Try again."
        continue
    else
        break
    fi
done

echo ""
echo ""
echo "Working..."

function configure_smtp() {
    echo "Updating $MAIN_CF"
    updateLineContaining "#postfixconf relayhost"            "#postfixconf relayhost $HOSTNAME_PORT"           $MAIN_CF
    updateLineContaining "relayhost[ ]*=[ ]*$HOSTNAME"       "relayhost = $HOSTNAME_PORT"                      $MAIN_CF
    updateLineContaining "smtp_sasl_auth_enable"             "smtp_sasl_auth_enable = yes"                     $MAIN_CF
    updateLineContaining "smtp_sasl_password_maps"           "smtp_sasl_password_maps = hash:$SASL_PASSWD"     $MAIN_CF
    updateLineContaining "smtp_sasl_security_options"        "smtp_sasl_security_options = noanonymous"        $MAIN_CF
    updateLineContaining "smtp_sasl_mechanism_filter"        "smtp_sasl_mechanism_filter = plain"              $MAIN_CF
    updateLineContaining "smtp_use_tls"                      "smtp_use_tls = yes"                              $MAIN_CF
    updateLineContaining "smtp_tls_security_level"           "smtp_tls_security_level = encrypt"               $MAIN_CF
    updateLineContaining "tls_random_source"                 "tls_random_source = dev:/dev/urandom"            $MAIN_CF

    echo "Updating $SASL_PASSWD"
    updateLineContaining $HOSTNAME                           "$HOSTNAME_PORT $USERNAME:$PASSWORD"              $SASL_PASSWD
}

function configure_gmail() {
    echo "Configuring gmail smtp"
    configure_smtp
    echo "NOTE! For gmail you must enable less secure apps for postfix to work: https://www.google.com/settings/security/lesssecureapps"
}

function configure_yahoo() {
    echo "Configuring yahoo smtp"
    configure_smtp
}

function configure_hotmail() {
    echo "Configuring hotmail/live smtp"
    configure_smtp
}

if grep -q "$HOSTNAME_PORT" "$MAIN_CF"; then
    echo "That relay host $HOSTNAME_PORT is already in $MAIN_CF. Attempting to update."
fi

if grep -q "$HOSTNAME_PORT" "$SASL_PASSWD"; then
    echo "That relay host is already in $SASL_PASSWD. Attempting to update."
fi

if echo "$HOSTNAME_PORT" | grep -q "gmail.com"; then
    configure_gmail
elif echo "$HOSTNAME_PORT" | grep -q "yahoo"; then
    configure_yahoo
elif echo "$HOSTNAME_PORT" | grep -q "live.com"; then
    configure_hotmail
else
    echo "Configuring smtp"
    configure_smtp
fi

sudo chmod 600 /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd

echo "Restarting postfix"
sudo launchctl stop org.postfix.master
sudo launchctl start org.postfix.master

echo "Sending test email to $USERNAME"
echo "42" | mail -s "The answer to life the universe and everything" $USERNAME

#Pretend like you are working. People can be impatient waiting for the test email.
spin() {
   local -a marks=( '/' '-' '\' '|' )
   COUNTER=0
   while [  $COUNTER -lt $1 ]; do
       printf '%s\r' "${marks[i++ % ${#marks[@]}]}"
       sleep 1
       let COUNTER=COUNTER+1 
   done
}
spin 10

echo "You are done. Check $USERNAME's email."

echo -n "Do you want to tail /var/log/mail.log [y|n]:"
read input
if [[ "$input" == "y" ]]; then
    echo "Tailing /var/log/mail.log (ctrl-c to quit)"
    tail -f /var/log/mail.log
fi
