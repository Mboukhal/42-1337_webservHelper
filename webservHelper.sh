#!/bin/bash

# number of tabs you want to open
# or `0` for default test
ClientNumber=10

# if you want to use your own interface ip, you can leave this empty
IP="127.0.0.1"
# port
PORT="4444"
# Uri with no /, example: "index.html", "hi/world/index.html"
URI=""
# Browser full path
Browser="/Applications/Firefox.app/Contents/MacOS/firefox"

SERVER=""

# if IP is `null` get host address
if [[ -z "${IP}" ]]; then
    IP=$(ifconfig | grep 'inet ' | grep bro | awk '{ print($2) }')
fi
SERVER="\"http://$IP:$PORT/$URI\""



function defaultTest () {

    printf "Clients number: $ClientNumber\n"
    printf "URL used in browser: $SERVER\n\n"

    RES_LIST=(
                "HTTP/1.1 200 OK"
                "HTTP/1.1 404 Not Found"
    )
    TEST_LIST_URI=(
                    ""
                    "no_nage"
    )

    ITER=0
    VAL=""
    for VAL in "${TEST_LIST_URI[@]}"; do

        TEST="$( curl -i $IP:$PORT/$VAL 2> /dev/null | sed -n '1p' | sed 's/.$//' )"
        [[ "$TEST" == "${RES_LIST[$ITER]}" ]] && printf "\e[32mOK\e[00m\t\t" || printf "\e[31mNO\e[00m\t\t" 
        printf "\e[33m${RES_LIST[$ITER]}\e[0m\n"
        ITER=$(( ITER + 1 ))
    done
}

ping -c 1 $IP 2> /dev/null > /dev/null
ERR="$?"
[[ "$ERR" -eq "0" ]] || printf "\e[31mServer [$IP:$PORT] is not available!\n\e[00m" || exit "$ERR"

CMD_ARGS="$Browser $SERVER"

OUT=""

pkill -f $Browser

i=0
while [ $ClientNumber -ne $i ]; do

    CMD_ARGS+=" $SERVER"
    i=$(( i + 1 ))
done

while [ 1 ]; do
    if [[ $ClientNumber -ne 0 ]]; then
        bash -c "$CMD_ARGS"  2> /dev/null 1> /dev/null &
    fi
    clear
    defaultTest
    printf "\nEnter [q] to quit,\n[default] reset browser: "
    read OUT
    pkill -f $Browser
    if [ "$OUT" == "q" ]; then
        exit 0
    fi
done 2> /dev/null
