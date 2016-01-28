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

function deleteLine() {
    $SEDi -i .bak "/$1/d" $2
}

echo -n "Type the SMTP hostname and port (example: smtp.gmail.com:587): "
read HOSTNAME_PORT

echo -n "Type the full username (example: whatmeworry@gmail.com): "
read USERNAME

while true
do
    echo -n "$USERNAME's Password: "
    read -s PASSWORD

    echo ""

    echo -n "Confirm $USERNAME's Password: "
    read -s CONFIRM_PASSWORD

    echo ""

    if [[ "$PASSWORD" != "$CONFIRM_PASSWORD" ]]; then
        echo "$USERNAME's passwords do not match. Try again."
        continue
    else
        break
    fi
done

result=$(grep -q "$HOSTNAME_PORT" "$MAIN_CF")
if [ $? -eq 0 ]; then
    echo "That relay host $HOSTNAME_PORT is already in $MAIN_CF. Attempting to remove."
    deleteLine $HOSTNAME_PORT $MAIN_CF
    deleteLine "smtp_sasl_auth_enable" $MAIN_CF
    deleteLine "smtp_sasl_password_maps" $MAIN_CF
    deleteLine "smtp_sasl_security_options" $MAIN_CF
    deleteLine "smtp_use_tls" $MAIN_CF
    deleteLine "smtp_sasl_mechanism_filter" $MAIN_CF
fi

result=$(grep -q "$HOSTNAME_PORT" "$SASL_PASSWD")
if [ $? -eq 0 ]; then
    echo "That relay host is already in $SASL_PASSWD. Attempting to remove."
    deleteLine $HOSTNAME_PORT $SASL_PASSWD
fi

echo "Adding relay host $HOSTNAME_PORT to $MAIN_CF"
echo "relayhost = $HOSTNAME_PORT" >> $MAIN_CF
echo "smtp_sasl_auth_enable = yes" >> $MAIN_CF
echo "smtp_sasl_password_maps = hash:$SASL_PASSWD" >> $MAIN_CF
echo "smtp_sasl_security_options = noanonymous" >> $MAIN_CF
echo "smtp_use_tls = yes" >> $MAIN_CF
echo "smtp_sasl_mechanism_filter = plain" >> $MAIN_CF

echo "Adding $HOSTNAME_PORT $USERNAME:******** to $SASL_PASSWD"
echo "$HOSTNAME_PORT $USERNAME:$PASSWORD" >> $SASL_PASSWD

sudo chmod 600 /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd

echo "Restarting postfix"
sudo launchctl stop org.postfix.master
sudo launchctl start org.postfix.master

echo "Sending test email to $USERNAME"
echo "All your base are belong to us." | mail -s "Testing. 1. 2. 3." $USERNAME

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

echo -n "Do you want to tail logs [y|n]:"
read input
if [[ "$input" == "y" ]]; then
    echo "Tailing /var/log/mail.log (ctrl-c to quit)"
    tail -f /var/log/mail.log
fi
