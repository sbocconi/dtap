#!/bin/bash

update_packages() {
    tmp_req_file='tmp_req.txt'
    pip freeze > ${tmp_req_file}
    sed -i 's/==/>=/g' ${tmp_req_file}
    pip install -r ${tmp_req_file} --upgrade
}

create_user_cmd() {

    if [ "${1} " == "superuser " ]; then
        settings_file='.superuser.json'
        local operation=create_superuser
    elif [ "${1} " == "user " ]; then
        settings_file='.researcher.json'
        local operation=create_user
    else
        echo "ERROR: ${1} not understood"
        return 1
    fi

    local username=$(cat ${settings_file} | jq '.username')
    local firstname=$(cat ${settings_file} | jq '.firstname')
    local lastname=$(cat ${settings_file} | jq '.lastname')
    local publickey=$(cat ${settings_file} | jq '.public_key')
    local email=$(cat ${settings_file} | jq '.email')
    local password=$(cat ${settings_file} | jq '.password')

    local templ="from django.contrib.auth import get_user_model; \n\
User = get_user_model(); \n\
if not User.objects.filter(username=${username}).exists():\n\
\tuser=User.objects.${operation}(${username}, ${email}, ${password})\n\
\tuser.first_name=${firstname};\n\
\tuser.last_name=${lastname};\n\
\tuser.publickey=${publickey}; \n\
\tuser.save();\n\
"

    echo -e ${templ} 
}

create_researcher_cmd() {
    settings_file='.researcher.json'

    local username=$(cat ${settings_file} | jq '.username')
    local description=$(cat ${settings_file} | jq '.description')
    local institute=$(cat ${settings_file} | jq '.institute')
    local institute_publickey=$(cat ${settings_file} | jq '.institute_publickey')


    local templ="from django.contrib.auth import get_user_model; \n\
from researcher_app.models import Researcher; \n\
User = get_user_model(); \n\
if User.objects.filter(username=${username}).exists(): \n\
\tuser=User.objects.filter(username=${username})[0]; \n\
\tif not Researcher.objects.filter(user=user).exists(): \n\
\t\tresearcher=Researcher(user=user); \n\
\t\tresearcher.description=${description}; \n\
\t\tresearcher.institute=${institute}; \n\
\t\tresearcher.institute_publickey=${institute_publickey}; \n\
\t\tresearcher.save(); \n\
"

  
    echo -e ${templ}
    

}