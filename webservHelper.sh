#!/bin/bash

# number of tabs you want to open
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
function getIp() {

    # if IP is `null` get host address
    if [[ -z "${IP}" ]]; then
        IP=$(ifconfig | grep 'inet ' | grep bro | awk '{ print($2) }')
    fi
    SERVER="\"http://$IP:$PORT/$URI\""
}
getIp

if [ "${ClientNumber}" -eq "0" ]; then

    echo "Client number can't be less then \`1\`!"
    exit 1
fi

function defaultTest () {

    printf "Clients number: $ClientNumber\n"
    printf "URL used in browser: $SERVER\n\n"
    RES_LIST=(
        "HTTP/1.1 200 OK"
        "HTTP/1.1 404 Not Found"
    )
    TEST_LIST=(
        "$( curl -i $IP:$PORT 2> /dev/null | sed -n '1p' | sed 's/.$//' )"
        "$( curl -i $IP:$PORT/no_page 2> /dev/null | sed -n '1p' | sed 's/.$//' )"
    )

    ITER=0
    TEST_ITER=""
    VAL=""
    for VAL in "${TEST_LIST[@]}"; do

        [[ "$VAL" == "${RES_LIST[$ITER]}" ]] && printf "OK\t\t" || printf "NO\t\t" 
        printf "${RES_LIST[$ITER]}\n"
        ITER=$(( ITER + 1 ))
    done
}

CMD_ARGS="$Browser $SERVER"

OUT=""

pkill -f $Browser

i=0
while [ $ClientNumber -ne $i ]; do

    CMD_ARGS+=" $SERVER"
    i=$(( i + 1 ))
done

while [ 1 ]; do
    bash -c "$CMD_ARGS"  2> /dev/null 1> /dev/null &
    clear
    defaultTest
    printf "\nEnter [q] to quit,\n[default] reset browser: "
    read OUT
    pkill -f $Browser
    if [ "$OUT" == "q" ]; then
        exit 0
    fi
done 2> /dev/null
