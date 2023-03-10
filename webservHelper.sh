#!/bin/bash

# number of tabs you want to open
# or `0` for default test
ClientNumber=10

# if you want to use your own interface ip, you can leave this empty
IP=""
IP="127.0.0.1"

# port
PORT="4444"
# Uri with no /, example: "index.html", "hi/world/index.html"
URI=""
URI="111.mp4"
# Browser full path
Browser="/Applications/Firefox.app/Contents/MacOS/firefox"

# test list response
TEST_LIST_RESPONSE=(
            "HTTP/1.1 200 OK"
            "HTTP/1.1 404 Not Found"
)

# test list uri
TEST_LIST_URI=(
                ""
                "no_nage"
)

# if IP is `null` get host address
[[ -z "${IP}" ]] && IP=$(ifconfig | grep 'inet ' | grep bro | awk '{ print($2) }')

SERVER="\"http://$IP:$PORT/$URI\""

function defaultTest () {

    printf "Clients number: $ClientNumber\n"
    printf "URL used in browser: $SERVER\n\n"

    ITER=0
    VAL=""
    for VAL in "${TEST_LIST_URI[@]}"; do

        TEST="$( curl -i $IP:$PORT/$VAL 2> /dev/null | sed -n '1p' | sed 's/.$//' )"
        [[ "$TEST" == "${TEST_LIST_RESPONSE[$ITER]}" ]] && printf "\e[32mOK\e[00m\t\t" || printf "\e[31mNO\e[00m\t\t" 
        printf "\e[33m${TEST_LIST_RESPONSE[$ITER]}\e[0m\n"
        ITER=$(( ITER + 1 ))
    done
}

ping -c 1 $IP &> /dev/null
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

    [[ "$ClientNumber" -ne "0" ]] && $(bash -c "$CMD_ARGS"  &> /dev/null &)
    clear
    defaultTest
    printf "\nEnter [q] to quit,\n[default] reset browser: "
    read OUT
    pkill -f $Browser
    [[ "$OUT" == "q"  ||  "$OUT" == "Q" ]] && exit 0
done 2> /dev/null
