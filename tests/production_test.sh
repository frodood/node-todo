#!/bin/bash
# production-tests.sh
echo "Starting production tests..."
res1=$(curl -s -o /dev/null -w "%{http_code}" http://$1/)

if [ "$res1" != "200" ]; then
 echo "Path / test failed. Aborting..."
 exit 1
fi

res2=$(curl -X POST -H "Content-Type: application/json" -d '{"text":"ass"}' -s -o /dev/null -w "%{http_code}" "http://$1/api/todos")
if [ "$res2" != "200" ]; then
 echo "POST test failed. Aborting..."
 exit 1
fi
echo "Production tests succeeded."
