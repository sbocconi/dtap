#!/opt/homebrew/bin/bash

my_webpage=""  #web page to be loaded
do_debug=n

function std_out {
  [ $do_debug = y ] && echo "${1}"  #stdout
}

function std_err {
  >&2 echo "${1}"  #stderr
  osascript -e "display notification \"${1}\" with title \"DTAP Website\" sound name \"Frog\""
}

while getopts "dw:" options
do
  case "${options}" in
    d)
      do_debug=y
      ;;
    w)
      my_webpage=${OPTARG}
      ;;
    :)
      std_err "ERROR: -${OPTARG} requires an argument"
      exit 1
      ;;
    *)
      std_err "ERROR: unknown option ${options}"
      exit 1
      ;;
  esac
done

if [ "$my_webpage " = " " ]
then
    std_err "ERROR: no website specified"
    exit 1
fi

if /sbin/ping -q -t 1 -c 1 8.8.8.8 > /dev/null 2>&1
then
    std_out "Internet connectivity OK"
else
    std_err "ERROR: internet connectivity not available"
    exit 1
fi


STDOUTFILE=".tempCurlStdOut" # temp file to store stdout
> $STDOUTFILE # cleans the file content

HTTPCODE=$(curl --max-time 5 --silent --write-out %{response_code} --output "$STDOUTFILE" "$my_webpage")
CONTENT=$(<$STDOUTFILE) # if there are no errors, this is the HTML code of the web page

std_out "HTTP CODE: "$HTTPCODE
std_out "CONTENT LENGTH: "${#CONTENT}" chars" # HTML length

if test $HTTPCODE -eq 200; then
    std_out "HTTP STATUS CODE $HTTPCODE -> OK"
else
    std_err "ERROR: HTTP STATUS CODE $HTTPCODE -> Has something gone wrong?"
    exit 1
fi

EXPIREDATE=$(curl --max-time 5 --verbose --head --stderr - "$my_webpage" | grep "expire date" | cut -d":" -f 2- | xargs)

EXPIREEPOC=$(date -j -f '%b %e %H:%M:%S %Y %Z' "${EXPIREDATE}" "+%s")

DAYS=$(( (${EXPIREEPOC} - $(date -j "+%s")) / (60*60*24) ))  #days remaining to expiration
if test ${DAYS} -gt 7; then
    std_out "No need to renew the SSL certificate. It will expire in $DAYS days"
else
    if test $DAYS -gt 0; then
        std_err "The SSL certificate should be renewed as soon as possible (${DAYS} remaining days)"
    else
        std_err "ERROR: The SSL certificate IS ALREADY EXPIRED!"
        exit 1
    fi
fi
