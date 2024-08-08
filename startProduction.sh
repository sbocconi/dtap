#!/bin/bash
screen_name=dtap

if [ ! -f ./.secret_key ]
then
    echo "File .secret_key missing, generating one"
    python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())' > ./.secret_key
fi

if [ -z "$STY" ]
then
    # we are not running in screen
    exec screen -dm -S ${screen_name} -L -Logfile dtap_$(date '+%d_%m_%Y_%H_%M_%S').log /bin/bash "$0";
    
else
    # we are running in screen, provide commands to execute

    ./start.sh PROD

fi


