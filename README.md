# dokku rethinkdb (beta)

Official rethinkdb plugin for dokku. Currently installs rethinkdb 2.1.1.

## requirements

- dokku 0.3.25+
- docker 1.6.x

## installation

```
cd /var/lib/dokku/plugins
git clone https://github.com/dokku/dokku-rethinkdb-plugin.git rethinkdb
dokku plugins-install-dependencies
dokku plugins-install
```

## commands

```
rethinkdb:alias <name> <alias>     Set an alias for the docker link
rethinkdb:clone <name> <new-name>  NOT IMPLEMENTED
rethinkdb:connect <name>           Connect via telnet to a rethinkdb service
rethinkdb:create <name>            Create a rethinkdb service
rethinkdb:destroy <name>           Delete the service and stop its container if there are no links left
rethinkdb:export <name>            NOT IMPLEMENTED
rethinkdb:expose <name> <port>     NOT IMPLEMENTED
rethinkdb:import <name> <file>     NOT IMPLEMENTED
rethinkdb:info <name>              Print the connection information
rethinkdb:link <name> <app>        Link the rethinkdb service to the app
rethinkdb:list                     List all rethinkdb services
rethinkdb:logs <name> [-t]         Print the most recent log(s) for this service
rethinkdb:restart <name>           Graceful shutdown and restart of the service container
rethinkdb:unexpose <name> <port>   NOT IMPLEMENTED
rethinkdb:unlink <name> <app>      Unlink the rethinkdb service from the app
```

## usage

```shell
# create a rethinkdb service named lolipop
dokku rethinkdb:create lolipop

# you can also specify the image and image
# version to use for the service
# it *must* be compatible with the
# official rethinkdb image
export RETHINKDB_IMAGE="rethinkdb"
export RETHINKDB_IMAGE_VERSION="2.0.4"
dokku rethinkdb:create lolipop

# get connection information as follows
dokku rethinkdb:info lolipop

# lets assume the ip of our rethinkdb service is 172.17.0.1

# a rethinkdb service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku rethinkdb:link lolipop playground

# the above will expose the following environment variables
#
#   RETHINKDB_URL=rethinkdb://172.17.0.1:28015
#   RETHINKDB_NAME=/playground/DATABASE
#   RETHINKDB_PORT=tcp://172.17.0.1:28015
#   RETHINKDB_PORT_28015_TCP=tcp://172.17.0.1:28015
#   RETHINKDB_PORT_28015_TCP_PROTO=tcp
#   RETHINKDB_PORT_28015_TCP_PORT=28015
#   RETHINKDB_PORT_28015_TCP_ADDR=172.17.0.1

# you can customize the environment
# variables through a custom docker link alias
dokku rethinkdb:alias lolipop RETHINKDB_DATABASE

# you can also unlink a rethinkdb service
# NOTE: this will restart your app
dokku rethinkdb:unlink lolipop playground

# you can tail logs for a particular service
dokku rethinkdb:logs lolipop
dokku rethinkdb:logs lolipop -t # to tail

# finally, you can destroy the container
dokku rethinkdb:destroy playground
```

## todo

- implement rethinkdb:clone
- implement rethinkdb:expose
- implement rethinkdb:import
