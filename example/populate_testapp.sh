#!/usr/bin/env sh

# Create foo service definitions
curl -sf -X PUT "http://${1}:8500/v1/kv/sd/env/dev/definitions/foo" --data "{\"consumes\": [], \"haproxy\": {\"path\": \"foo\"}}" > /dev/null
if [ $? -ne 0 ]; then
    echo -e 'Something went wrong: curl -X PUT "http://${1}/v1/kv/sd/env/dev/definitions/foo" --data "..."'
    exit 1
fi
echo -e 'Created node:\t\t/sd/env/dev/definitions/foo'

# Create bar service definitions
curl -sf -X PUT "http://${1}:8500/v1/kv/sd/env/dev/definitions/bar" --data "{\"consumes\": [], \"haproxy\": {\"path\": \"bar\"}}" > /dev/null
if [ $? -ne 0 ]; then
    echo -e 'Something went wrong: curl -X PUT "http://${1}/v1/kv/sd/env/dev/definitions/bar" --data "..."'
    exit 1
fi
echo -e 'Created node:\t\t/sd/env/dev/definitions/bar'

# Create baz service definitions
curl -sf -X PUT "http://${1}:8500/v1/kv/sd/env/dev/definitions/baz" --data "{\"consumes\": [], \"haproxy\": {\"path\": \"baz\"}}" > /dev/null
if [ $? -ne 0 ]; then
    echo -e 'Something went wrong: curl -X PUT "http://${1}/v1/kv/sd/env/dev/definitions/baz" --data "..."'
    exit 1
fi
echo -e 'Created node:\t\t/sd/env/dev/definitions/baz'

echo -e ''
