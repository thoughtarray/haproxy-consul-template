#!/usr/bin/env sh

# Create environment nodes
curl -sf -X PUT "http://${1}:8500/v1/kv/sd/env/dev" --data "{}" > /dev/null
if [ $? -ne 0 ]; then
    echo -e 'Something went wrong: curl -X PUT "http://${1}/v1/kv/sd/env/dev" --data "..."'
    exit 1
fi
echo -e 'Created node:\t\t/sd/env/dev'

curl -sf -X PUT "http://${1}:8500/v1/kv/sd/env/prod" --data "{}" > /dev/null
if [ $? -ne 0 ]; then
    echo -e 'Something went wrong: curl -X PUT "http://${1}/v1/kv/sd/env/dev" --data "..."'
    exit 1
fi
echo -e 'Created node:\t\t/sd/env/prod'

# Create service definitions
curl -sf -X PUT "http://${1}:8500/v1/kv/sd/env/dev/definitions/test-app" --data "{\"consumes\": [], \"haproxy\": {\"path\": \"test\"}}" > /dev/null
if [ $? -ne 0 ]; then
    echo -e 'Something went wrong: curl -X PUT "http://${1}/v1/kv/sd/env/dev/definitions/test-app" --data "..."'
    exit 1
fi
echo -e 'Created node:\t\t/sd/env/dev/definitions/test-app'

# Create service
curl -sf -X PUT "http://${1}:8500/v1/agent/service/register" --data "{
  \"ID\": \"dev_test-app:5000\",
  \"Name\": \"dev_test-app\",
  \"Tags\": [],
  \"Address\": \"${1}\",
  \"Port\": 5000
}" > /dev/null
if [ $? -ne 0 ]; then
    echo -e 'Something went wrong: curl -s -X PUT "http://${1}/v1/agent/service/register" --data "..."'
    exit 1
fi
echo -e 'Created service:\tdev_test-app'

echo -e ''
