#!/bin/sh -e
__CURRENT__=`pwd`
__DIR__=$(cd "$(dirname "$0")";pwd)

#-------------PHPT-------------
cd ${__DIR__} && cd ../tests/
# initialization
php ./init.php
# run
retry_failures()
{
    # replace \n to space
    failed_list="`tr '\n' ' ' < failed.list`"

    # and retry
    ./start.sh \
    -m \
    --set-timeout 45 \
    --show-diff \
    -w failed.list \
    "${failed_list}"
}

for dir in "coro*" "e*" "f*" "g*" "http2_client_coro" "http_client_coro" "l*" "m*" "p*" "r*" "s*" "t*" "w*"
do
    ./start.sh \
    -m \
    --set-timeout 25 \
    --show-diff \
    -w failed.list \

    for i in 1 2 3
    do
        if [ "`cat failed.list | grep "phpt"`" ]; then
            echo "retry#${i}..."
            retry_failures
        else
            exit 0
        fi
    done

    if [ "`cat failed.list | grep "phpt"`" ]; then
        exit 255
    fi

done