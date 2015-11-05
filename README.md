# dokku rethinkdb (beta) [![Build Status](https://img.shields.io/travis/dokku/dokku-rethinkdb.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-rethinkdb) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official rethinkdb plugin for dokku. Currently defaults to installing [rethinkdb 2.1.1](https://hub.docker.com/_/rethinkdb/).

## requirements

- dokku 0.4.0+
- docker 1.8.x

## installation

```shell
# on 0.3.x
cd /var/lib/dokku/plugins
git clone https://github.com/dokku/dokku-rethinkdb.git rethinkdb
dokku plugins-install

# on 0.4.x
dokku plugin:install https://github.com/dokku/dokku-rethinkdb.git rethinkdb
```

## commands

```
rethinkdb:clone <name> <new-name>  NOT IMPLEMENTED
rethinkdb:connect <name>           Connect via telnet to a rethinkdb service
rethinkdb:create <name>            Create a rethinkdb service with environment variables
rethinkdb:destroy <name>           Delete the service and stop its container if there are no links left
rethinkdb:export <name> > <file>   NOT IMPLEMENTED
rethinkdb:expose <name> [port]     Expose a rethinkdb service on custom port if provided (random port otherwise)
rethinkdb:import <name> <file>     NOT IMPLEMENTED
rethinkdb:info <name>              Print the connection information
rethinkdb:link <name> <app>        Link the rethinkdb service to the app
rethinkdb:list                     List all rethinkdb services
rethinkdb:logs <name> [-t]         Print the most recent log(s) for this service
rethinkdb:promote <name> <app>     Promote service <name> as RETHINKDB_URL in <app>
rethinkdb:restart <name>           Graceful shutdown and restart of the rethinkdb service container
rethinkdb:start <name>             Start a previously stopped rethinkdb service
rethinkdb:stop <name>              Stop a running rethinkdb service
rethinkdb:unexpose <name>          Unexpose a previously exposed rethinkdb service
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

# you can also specify custom environment
# variables to start the rethinkdb service
# in semi-colon separated forma
export RETHINKDB_CUSTOM_ENV="USER=alpha;HOST=beta"

# create a rethinkdb service
dokku rethinkdb:create lolipop

# get connection information as follows
dokku rethinkdb:info lolipop

# a rethinkdb service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku rethinkdb:link lolipop playground

# the following environment variables will be set automatically by docker (not
# on the app itself, so they won’t be listed when calling dokku config)
#
#   DOKKU_RETHINKDB_LOLIPOP_NAME=/lolipop/DATABASE
#   DOKKU_RETHINKDB_LOLIPOP_PORT=tcp://172.17.0.1:28015
#   DOKKU_RETHINKDB_LOLIPOP_PORT_28015_TCP=tcp://172.17.0.1:28015
#   DOKKU_RETHINKDB_LOLIPOP_PORT_28015_TCP_PROTO=tcp
#   DOKKU_RETHINKDB_LOLIPOP_PORT_28015_TCP_PORT=28015
#   DOKKU_RETHINKDB_LOLIPOP_PORT_28015_TCP_ADDR=172.17.0.1
#
# and the following will be set on the linked application by default
#
#   RETHINKDB_URL=rethinkdb://dokku-rethinkdb-lolipop:28015
#
# NOTE: the host exposed here only works internally in docker containers. If
# you want your container to be reachable from outside, you should use `expose`.

# another service can be linked to your app
dokku rethinkdb:link other_service playground

# since RETHINKDB_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_RETHINKDB_BLUE_URL=rethinkdb://dokku-rethinkdb-other-service:28015

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku rethinkdb:promote other_service playground

# this will replace RETHINKDB_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   RETHINKDB_URL=rethinkdb://dokku-rethinkdb-other-service:28015
#   DOKKU_RETHINKDB_BLUE_URL=rethinkdb://dokku-rethinkdb-other-service:28015
#   DOKKU_RETHINKDB_SILVER_URL=rethinkdb://dokku-rethinkdb-lolipop:28015

# you can also unlink an rethinkdb service
# NOTE: this will restart your app and unset related environment variables
dokku rethinkdb:unlink lolipop playground

# you can tail logs for a particular service
dokku rethinkdb:logs lolipop
dokku rethinkdb:logs lolipop -t # to tail

# finally, you can destroy the container
dokku rethinkdb:destroy lolipop
```

## todo

- implement rethinkdb:clone
- implement rethinkdb:import
