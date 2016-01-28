# postfixconf - Configure Postfix for Gmail (or any other) SMTP on Mac OSX 
This script will enable and configure command line email on OSX. It basically does what is described [here](http://www.developerfiles.com/how-to-send-emails-from-localhost-mac-os-x-el-capitan/).

# Run
```
$ git clone https://github.com/roubles/postfixconf.git
$ cd postfixconf
$ sudo ./postfixconf.sh
```
Note: This must be done as sudo.

# Sample output
```
$ sudo ./postfixconf.sh 
Type the SMTP hostname and port (example: smtp.gmail.com:587): smtp.gmail.com:587
Type the full username (example: whatmeworry@gmail.com): whatmeworry@gmail.com
whatmeworry@gmail.com's Password: 
Confirm whatmeworry@gmail.com's Password: 


Working...
That relay host smtp.gmail.com:587 is already in /etc/postfix/main.cf. Attempting to update.
That relay host is already in /etc/postfix/sasl_passwd. Attempting to update.
Configuring gmail smtp
Updating /etc/postfix/main.cf
Updating /etc/postfix/sasl_passwd
NOTE! For gmail you must enable less secure apps for postfix to work: https://www.google.com/settings/security/lesssecureapps
Restarting postfix
Sending test email to whatmeworry@gmail.com
You are done. Check whatmeworry@gmail.com's email.
Do you want to tail /var/log/mail.log [y|n]:n 

```

# Now what?
You should now be able to send emails as such:
```
$ echo "42" | mail -s "The answer to life the universe and everything" someone@gmail.com
```

# Trouble in paradise
If you are having issues, checkout /var/log/mail.log
```
$ tail -f /var/log/mail.log
```

You can see your outgoing mail queue as follows:
```
$ mailq
```
