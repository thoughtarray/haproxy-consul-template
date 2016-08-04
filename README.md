# haproxy-consul-template
The purpose of this is to serve as the TH of the CRTH (Consul, Registrator, Consul [T]emplate, [H]AProxy) stack for service discovery.

## About
### Disclaimer
This project is _not_ production ready and is _not_ tested throughly...yet.

### Architecture
This image uses [S6](http://skarnet.org/software/s6/) (specifically [s6-overlay](https://github.com/just-containers/s6-overlay)) as its supervisor.  I recommend using this image on a per-machine level (such as a ECS instance in an ECS cluster) as apposed to a per-app level (like a side-kick process).

## How to use
### Required (probably) settings
The main two settings to customize is the  Consul location environment variables `CONSUL_ADDR` and `CONSUL_PORT`, and the Consul Template template for HAProxy `/usr/local/etc/consul-template/templates/haproxy.ctmpl`.

### Optional settings
Another component that you may be interested in customizing is the Consul Template config file which lives here: `/usr/local/etc/consul-template/consul-template.conf`.

### Example
```sh
docker run --name service-proxy -p 80:80 -p 443:443 \
  -e "CONSUL_ADDR=<ip/host of Consul>" \
  -e "CONSUL_PORT=8500" \
  -v "/path/on/host:/usr/local/etc/consul-template/templates/haproxy.ctmpl:ro" \
  haproxy-consul-template

# Optionally:
# -v "/path/on/host:/usr/local/etc/consul-template/consul-template.conf:ro"
```

## Harder decisions
The hardest decision is how your HAProxy template is to be written and now the data is to be designed in Consul's key-value store.  I've written a sample in this project's `./example` directory.  You can run the `curl` commands _**on a test Consul instance**_ to populate the test data.  You can use the `haproxy.example.ctmpl` file in your `docker run ...` command to test what the config would look like.

To view the product, you can do something like this:
```sh
# You are on the host
docker exec -ti haproxy-consul-template ash

# You are now in the container
less /usr/local/etc/haproxy/haproxy.cfg

# If the OS bitches at you and less doesn't work, do this and try again:
export TERM=xterm
```

## Testing reload performance
```sh
cd /path/to/this/repo

# Start test Consul instance
docker run -d --name consul -p 8500:8500 \
  progrium/consul -server -bootstrap -ui-dir /ui
# ^ UI accessible at http://localhost:8500/ui/

# Build KV tree on test Consul
./example/populate_consul.sh "<ip/host of Consul>"

# Start test app
docker run --name test-app -d -p 5000:5000 alpine sh \
  -c "(echo 'Hello, world' > /tmp/index.html) && httpd -v -f -p 5000 -h /tmp/"

# Start service proxy
docker run -d --name service-proxy -p 80:80 -p 1936:1936 \
  -e "CONSUL_ADDR=<ip/host of Consul>" \
  -v "$(pwd)/example/haproxy.example.ctmpl:/usr/local/etc/consul-template/templates/haproxy.ctmpl:ro" \
  haproxy-consul-template

# Get baseline performance
ab -c 10 -n 10000 -H "X-IDS-ENV: dev" "http://127.0.0.1/test/"

# Now for the tricky part.  You'll want to run the `ab` program again.  After
#   about 1/3 of the requests go through, you'll want to trigger a reload on the
#   service-proxy container.  Use the `curl` command at the appropriate time
#   during the `ab` test to simulate reloading HAProxy in an actual environment.
#   You may have to up the number "-n" of requests if it happens too quickly.

# Test it
ab -c 10 -n 10000 -H "X-IDS-ENV: dev" "http://127.0.0.1/test/"

# Reload it by editing a watched node on Consul
curl -X PUT 'http://localhost:8500/v1/kv/sd/env/dev/definitions/test-app' --data '{"consumes": ["foo"], "haproxy": {"path": "test"}}'

# Teardown
docker kill service-proxy test-app consul \
  && docker rm service-proxy test-app consul
```

## Known issues
* Docker for Mac (or maybe OSX) is a load-testing bottleneck?
* Sometimes Consul Template's reload commands out-pace HAProxy's reloading speed (might be related to lingering connections in old instance)
