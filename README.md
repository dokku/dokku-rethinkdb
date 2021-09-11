# dokku rethinkdb [![Build Status](https://img.shields.io/github/workflow/status/dokku/dokku-rethinkdb/CI/master?style=flat-square "Build Status")](https://github.com/dokku/dokku-rethinkdb/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official rethinkdb plugin for dokku. Currently defaults to installing [rethinkdb 2.4.1](https://hub.docker.com/_/rethinkdb/).

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/dokku/dokku-rethinkdb.git rethinkdb
```

## Commands

```
rethinkdb:app-links <app>                        # list all rethinkdb service links for a given app
rethinkdb:connect <service>                      # connect to the service via the rethinkdb connection tool
rethinkdb:create <service> [--create-flags...]   # create a rethinkdb service
rethinkdb:destroy <service> [-f|--force]         # delete the rethinkdb service/data/container if there are no links left
rethinkdb:enter <service>                        # enter or run a command in a running rethinkdb service container
rethinkdb:exists <service>                       # check if the rethinkdb service exists
rethinkdb:expose <service> <ports...>            # expose a rethinkdb service on custom port if provided (random port otherwise)
rethinkdb:info <service> [--single-info-flag]    # print the service information
rethinkdb:link <service> <app> [--link-flags...] # link the rethinkdb service to the app
rethinkdb:linked <service> <app>                 # check if the rethinkdb service is linked to an app
rethinkdb:links <service>                        # list all apps linked to the rethinkdb service
rethinkdb:list                                   # list all rethinkdb services
rethinkdb:logs <service> [-t|--tail]             # print the most recent log(s) for this service
rethinkdb:promote <service> <app>                # promote service <service> as RETHINKDB_URL in <app>
rethinkdb:restart <service>                      # graceful shutdown and restart of the rethinkdb service container
rethinkdb:start <service>                        # start a previously stopped rethinkdb service
rethinkdb:stop <service>                         # stop a running rethinkdb service
rethinkdb:unexpose <service>                     # unexpose a previously exposed rethinkdb service
rethinkdb:unlink <service> <app>                 # unlink the rethinkdb service from the app
rethinkdb:upgrade <service> [--upgrade-flags...] # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to rethinkdb:help. Please consult the `rethinkdb:help` command for any undocumented commands.

### Basic Usage

### create a rethinkdb service

```shell
# usage
dokku rethinkdb:create <service> [--create-flags...]
```

flags:

- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password

Create a rethinkdb service named lolipop:

```shell
dokku rethinkdb:create lolipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the rethinkdb image. 

```shell
export RETHINKDB_IMAGE="rethinkdb"
export RETHINKDB_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku rethinkdb:create lolipop
```

You can also specify custom environment variables to start the rethinkdb service in semi-colon separated form. 

```shell
export RETHINKDB_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku rethinkdb:create lolipop
```

### print the service information

```shell
# usage
dokku rethinkdb:info <service> [--single-info-flag]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku rethinkdb:info lolipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku rethinkdb:info lolipop --config-dir
dokku rethinkdb:info lolipop --data-dir
dokku rethinkdb:info lolipop --dsn
dokku rethinkdb:info lolipop --exposed-ports
dokku rethinkdb:info lolipop --id
dokku rethinkdb:info lolipop --internal-ip
dokku rethinkdb:info lolipop --links
dokku rethinkdb:info lolipop --service-root
dokku rethinkdb:info lolipop --status
dokku rethinkdb:info lolipop --version
```

### list all rethinkdb services

```shell
# usage
dokku rethinkdb:list 
```

List all services:

```shell
dokku rethinkdb:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku rethinkdb:logs <service> [-t|--tail]
```

flags:

- `-t|--tail`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku rethinkdb:logs lolipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku rethinkdb:logs lolipop --tail
```

### link the rethinkdb service to the app

```shell
# usage
dokku rethinkdb:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link

A rethinkdb service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our 'playground' app. 

> NOTE: this will restart your app

```shell
dokku rethinkdb:link lolipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_RETHINKDB_LOLIPOP_NAME=/lolipop/DATABASE
DOKKU_RETHINKDB_LOLIPOP_PORT=tcp://172.17.0.1:28015
DOKKU_RETHINKDB_LOLIPOP_PORT_28015_TCP=tcp://172.17.0.1:28015
DOKKU_RETHINKDB_LOLIPOP_PORT_28015_TCP_PROTO=tcp
DOKKU_RETHINKDB_LOLIPOP_PORT_28015_TCP_PORT=28015
DOKKU_RETHINKDB_LOLIPOP_PORT_28015_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
RETHINKDB_URL=rethinkdb://lolipop:SOME_PASSWORD@dokku-rethinkdb-lolipop:28015/lolipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the 'expose' subcommand. Another service can be linked to your app:

```shell
dokku rethinkdb:link other_service playground
```

It is possible to change the protocol for `RETHINKDB_URL` by setting the environment variable `RETHINKDB_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding. 

```shell
dokku config:set playground RETHINKDB_DATABASE_SCHEME=rethinkdb2
dokku rethinkdb:link lolipop playground
```

This will cause `RETHINKDB_URL` to be set as:

```
rethinkdb2://lolipop:SOME_PASSWORD@dokku-rethinkdb-lolipop:28015/lolipop
```

### unlink the rethinkdb service from the app

```shell
# usage
dokku rethinkdb:unlink <service> <app>
```

You can unlink a rethinkdb service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku rethinkdb:unlink lolipop playground
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the rethinkdb connection tool

```shell
# usage
dokku rethinkdb:connect <service>
```

Connect to the service via the rethinkdb connection tool:

```shell
dokku rethinkdb:connect lolipop
```

### enter or run a command in a running rethinkdb service container

```shell
# usage
dokku rethinkdb:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk. 

```shell
dokku rethinkdb:enter lolipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk. 

```shell
dokku rethinkdb:enter lolipop touch /tmp/test
```

### expose a rethinkdb service on custom port if provided (random port otherwise)

```shell
# usage
dokku rethinkdb:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku rethinkdb:expose lolipop 28015 29015 8080
```

### unexpose a previously exposed rethinkdb service

```shell
# usage
dokku rethinkdb:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku rethinkdb:unexpose lolipop
```

### promote service <service> as RETHINKDB_URL in <app>

```shell
# usage
dokku rethinkdb:promote <service> <app>
```

If you have a rethinkdb service linked to an app and try to link another rethinkdb service another link environment variable will be generated automatically:

```
DOKKU_RETHINKDB_BLUE_URL=rethinkdb://other_service:ANOTHER_PASSWORD@dokku-rethinkdb-other-service:28015/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku rethinkdb:promote other_service playground
```

This will replace `RETHINKDB_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
RETHINKDB_URL=rethinkdb://other_service:ANOTHER_PASSWORD@dokku-rethinkdb-other-service:28015/other_service
DOKKU_RETHINKDB_BLUE_URL=rethinkdb://other_service:ANOTHER_PASSWORD@dokku-rethinkdb-other-service:28015/other_service
DOKKU_RETHINKDB_SILVER_URL=rethinkdb://lolipop:SOME_PASSWORD@dokku-rethinkdb-lolipop:28015/lolipop
```

### start a previously stopped rethinkdb service

```shell
# usage
dokku rethinkdb:start <service>
```

Start the service:

```shell
dokku rethinkdb:start lolipop
```

### stop a running rethinkdb service

```shell
# usage
dokku rethinkdb:stop <service>
```

Stop the service and the running container:

```shell
dokku rethinkdb:stop lolipop
```

### graceful shutdown and restart of the rethinkdb service container

```shell
# usage
dokku rethinkdb:restart <service>
```

Restart the service:

```shell
dokku rethinkdb:restart lolipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku rethinkdb:upgrade <service> [--upgrade-flags...]
```

flags:

- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-R|--restart-apps "true"`: whether to force an app restart

You can upgrade an existing service to a new image or image-version:

```shell
dokku rethinkdb:upgrade lolipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all rethinkdb service links for a given app

```shell
# usage
dokku rethinkdb:app-links <app>
```

List all rethinkdb services that are linked to the 'playground' app. 

```shell
dokku rethinkdb:app-links playground
```

### check if the rethinkdb service exists

```shell
# usage
dokku rethinkdb:exists <service>
```

Here we check if the lolipop rethinkdb service exists. 

```shell
dokku rethinkdb:exists lolipop
```

### check if the rethinkdb service is linked to an app

```shell
# usage
dokku rethinkdb:linked <service> <app>
```

Here we check if the lolipop rethinkdb service is linked to the 'playground' app. 

```shell
dokku rethinkdb:linked lolipop playground
```

### list all apps linked to the rethinkdb service

```shell
# usage
dokku rethinkdb:links <service>
```

List all apps linked to the 'lolipop' rethinkdb service. 

```shell
dokku rethinkdb:links lolipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `RETHINKDB_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.
