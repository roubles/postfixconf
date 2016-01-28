# postfixconf - Configure Postfix for Gmail (or any other) SMTP on Mac OSX 
This script will enable and configure command line email on OSX. It basically does what is described in this [gist](https://gist.github.com/roubles/28cb8864df74a8eb06e0).

# Run
```
$ git clone https://github.com/roubles/postfixconf.git
$ cd postfixconf
$ sudo ./postfixconf.sh
```

# Sample output
```
$ sudo ./postfixconf.sh 
Password:
Type the SMTP hostname and port (example: smtp.gmail.com:587): smtp.gmail.com:587
Type the full username (example: whatmeworry@gmail.com): whatever@gmail.com
whatever@gmail.com's Password: 
Confirm whatever@gmail.com's Password: 
That relay host smtp.gmail.com:587 is already in /etc/postfix/main.cf. Attempting to remove.
That relay host is already in /etc/postfix/sasl_passwd. Attempting to remove.
Adding relay host smtp.gmail.com:587 to /etc/postfix/main.cf
Adding smtp.gmail.com:587 whatever@gmail.com:******** to /etc/postfix/sasl_passwd
Restarting postfix
Sending test email to whatever@gmail.com
You are done. Check whatever@gmail.com's email.
Do you want to tail logs [y|n]:n

``
