#!/opt/homebrew/bin/bash

my_webpage=""  #web page to be loaded
do_debug=n

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
      >&2 echo "ERROR: -${OPTARG} requires an argument"
      exit 1
      ;;
    *)
      >&2 echo "ERROR: unknown option ${options}"
      exit 1
      ;;
  esac
done

if [ "$my_webpage " = " " ]
then
    >&2 echo "ERROR: no website specified"
    exit 1
fi

if /sbin/ping -q -t 1 -c 1 8.8.8.8 > /dev/null 2>&1
then
    [ $do_debug = y ] && echo "Internet connectivity OK"  #stdout
else
    >&2 echo "ERROR: internet connectivity not available" #stderr
    exit 1
fi


STDOUTFILE=".tempCurlStdOut" # temp file to store stdout
> $STDOUTFILE # cleans the file content

HTTPCODE=$(curl --max-time 5 --silent --write-out %{response_code} --output "$STDOUTFILE" "$my_webpage")
CONTENT=$(<$STDOUTFILE) # if there are no errors, this is the HTML code of the web page

[ $do_debug = y ] && echo "HTTP CODE: "$HTTPCODE
[ $do_debug = y ] && echo "CONTENT LENGTH: "${#CONTENT}" chars" # HTML length

if test $HTTPCODE -eq 200; then
    [ $do_debug = y ] && echo "HTTP STATUS CODE $HTTPCODE -> OK"  stdout
else
    >&2 echo "ERROR: HTTP STATUS CODE $HTTPCODE -> Has something gone wrong?" #stderr
    exit 1
fi

EXPIREDATE=$(curl --max-time 5 --verbose --head --stderr - "$my_webpage" | grep "expire date" | cut -d":" -f 2- | xargs)

EXPIREEPOC=$(date -j -f '%b %e %H:%M:%S %Y %Z' "${EXPIREDATE}" "+%s")

DAYS=$(( (${EXPIREEPOC} - $(date -j "+%s")) / (60*60*24) ))  #days remaining to expiration
if test ${DAYS} -gt 7; then
    [ $do_debug = y ] && echo "No need to renew the SSL certificate. It will expire in $DAYS days" # stdout
else
    if test $DAYS -gt 0; then
        >&2 echo "The SSL certificate should be renewed as soon as possible (${DAYS} remaining days)" # stderr
    else
        >&2 echo "ERROR: The SSL certificate IS ALREADY EXPIRED!" # stderr
        exit 1
    fi
fi
