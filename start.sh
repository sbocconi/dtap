#!/bin/bash
conda_env=ws
env_type=${1}
db_backup=db_backup.json

if [ "${env_type} " == "PROD " ]
then
    settings=dtap.settingsP
elif [ "${env_type} " == "DEV " ]
then
    settings=dtap.settingsD
else
    echo -e "Environment unknown: ${env_type}"
    exit 1
fi

if [ "$(uname)" == "Darwin" ]
then
    conda_shell=/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh
else
    conda_shell=/miniconda3/etc/profile.d/conda.sh
fi

if [ ! -f ./manage.py ]
then
    echo "Wrong directory, needs to be where manage.py is"
    exit 1
fi

if [ "${CONDA_DEFAULT_ENV} " != "${conda_env} " ]
then
    source ${conda_shell}
    conda activate ${conda_env}
fi

pip install -r ./pip_requirements.txt

if [ "${env_type} " == "PROD " -a ! -f ./.secret_key ]
then
    echo "File .secret_key missing, generating one"
    python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())' > ./.secret_key
fi


if [ "${env_type} " == "PROD " ]
then
    export SECRET_KEY=$(cat .secret_key)
    python manage.py collectstatic --noinput --settings=${settings}
fi

python manage.py makemigrations --settings=${settings}
python manage.py migrate --settings=${settings}

if [ -f ${db_backup} ]
then
    python manage.py loaddata ${db_backup} --settings=${settings}
fi

# . ./util_functions.sh

# create_user_cmd superuser | python manage.py shell --settings=${settings}
# create_user_cmd user | python manage.py shell --settings=${settings}
# create_researcher_cmd | python manage.py shell --settings=${settings}

python -m manage runserver -v2 --settings=${settings}

# if ! check_restroom
# then
#    exit 1
# fi

# if [ "${env_type} " == "PROD " ]
# then
#     SECRET_KEY=$(cat .secret_key) python manage.py runserver --settings=${settings}
# else
#     python manage.py runserver -v2 --settings=${settings}
# fi



