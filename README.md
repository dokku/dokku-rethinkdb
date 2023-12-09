# dokku rethinkdb [![Build Status](https://img.shields.io/github/actions/workflow/status/dokku/dokku-rethinkdb/ci.yml?branch=master&style=flat-square "Build Status")](https://github.com/dokku/dokku-rethinkdb/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official rethinkdb plugin for dokku. Currently defaults to installing [rethinkdb 2.4.2](https://hub.docker.com/_/rethinkdb/).

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
rethinkdb:app-links <app>                          # list all rethinkdb service links for a given app
rethinkdb:connect <service>                        # connect to the service via the rethinkdb connection tool
rethinkdb:create <service> [--create-flags...]     # create a rethinkdb service
rethinkdb:destroy <service> [-f|--force]           # delete the rethinkdb service/data/container if there are no links left
rethinkdb:enter <service>                          # enter or run a command in a running rethinkdb service container
rethinkdb:exists <service>                         # check if the rethinkdb service exists
rethinkdb:expose <service> <ports...>              # expose a rethinkdb service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
rethinkdb:info <service> [--single-info-flag]      # print the service information
rethinkdb:link <service> <app> [--link-flags...]   # link the rethinkdb service to the app
rethinkdb:linked <service> <app>                   # check if the rethinkdb service is linked to an app
rethinkdb:links <service>                          # list all apps linked to the rethinkdb service
rethinkdb:list                                     # list all rethinkdb services
rethinkdb:logs <service> [-t|--tail] <tail-num-optional> # print the most recent log(s) for this service
rethinkdb:pause <service>                          # pause a running rethinkdb service
rethinkdb:promote <service> <app>                  # promote service <service> as RETHINKDB_URL in <app>
rethinkdb:restart <service>                        # graceful shutdown and restart of the rethinkdb service container
rethinkdb:set <service> <key> <value>              # set or clear a property for a service
rethinkdb:start <service>                          # start a previously stopped rethinkdb service
rethinkdb:stop <service>                           # stop a running rethinkdb service
rethinkdb:unexpose <service>                       # unexpose a previously exposed rethinkdb service
rethinkdb:unlink <service> <app>                   # unlink the rethinkdb service from the app
rethinkdb:upgrade <service> [--upgrade-flags...]   # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to rethinkdb:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `rethinkdb:help` command for any undocumented commands.

### Basic Usage

### create a rethinkdb service

```shell
# usage
dokku rethinkdb:create <service> [--create-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit in megabytes (default: unlimited)
- `-N|--initial-network INITIAL_NETWORK`: the initial network to attach the service to
- `-p|--password PASSWORD`: override the user-level service password
- `-P|--post-create-network NETWORKS`: a comma-separated list of networks to attach the service container to after service creation
- `-r|--root-password PASSWORD`: override the root-level service password
- `-S|--post-start-network NETWORKS`: a comma-separated list of networks to attach the service container to after service start
- `-s|--shm-size SHM_SIZE`: override shared memory size for rethinkdb docker container

Create a rethinkdb service named lollipop:

```shell
dokku rethinkdb:create lollipop
```

You can also specify the image and image version to use for the service. It _must_ be compatible with the rethinkdb image.

```shell
export RETHINKDB_IMAGE="rethinkdb"
export RETHINKDB_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku rethinkdb:create lollipop
```

You can also specify custom environment variables to start the rethinkdb service in semi-colon separated form.

```shell
export RETHINKDB_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku rethinkdb:create lollipop
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
- `--initial-network`: show the initial network being connected to
- `--links`: show the service app links
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku rethinkdb:info lollipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku rethinkdb:info lollipop --config-dir
dokku rethinkdb:info lollipop --data-dir
dokku rethinkdb:info lollipop --dsn
dokku rethinkdb:info lollipop --exposed-ports
dokku rethinkdb:info lollipop --id
dokku rethinkdb:info lollipop --internal-ip
dokku rethinkdb:info lollipop --initial-network
dokku rethinkdb:info lollipop --links
dokku rethinkdb:info lollipop --post-create-network
dokku rethinkdb:info lollipop --post-start-network
dokku rethinkdb:info lollipop --service-root
dokku rethinkdb:info lollipop --status
dokku rethinkdb:info lollipop --version
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
dokku rethinkdb:logs <service> [-t|--tail] <tail-num-optional>
```

flags:

- `-t|--tail [<tail-num>]`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku rethinkdb:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku rethinkdb:logs lollipop --tail
```

The default tail setting is to show all logs, but an initial count can also be specified:

```shell
dokku rethinkdb:logs lollipop --tail 5
```

### link the rethinkdb service to the app

```shell
# usage
dokku rethinkdb:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link
- `-n|--no-restart "false"`: whether or not to restart the app on link (default: true)

A rethinkdb service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku rethinkdb:link lollipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_RETHINKDB_LOLLIPOP_NAME=/lollipop/DATABASE
DOKKU_RETHINKDB_LOLLIPOP_PORT=tcp://172.17.0.1:28015
DOKKU_RETHINKDB_LOLLIPOP_PORT_28015_TCP=tcp://172.17.0.1:28015
DOKKU_RETHINKDB_LOLLIPOP_PORT_28015_TCP_PROTO=tcp
DOKKU_RETHINKDB_LOLLIPOP_PORT_28015_TCP_PORT=28015
DOKKU_RETHINKDB_LOLLIPOP_PORT_28015_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
RETHINKDB_URL=rethinkdb://dokku-rethinkdb-lollipop:28015/lollipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku rethinkdb:link other_service playground
```

It is possible to change the protocol for `RETHINKDB_URL` by setting the environment variable `RETHINKDB_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground RETHINKDB_DATABASE_SCHEME=rethinkdb2
dokku rethinkdb:link lollipop playground
```

This will cause `RETHINKDB_URL` to be set as:

```
rethinkdb2://dokku-rethinkdb-lollipop:28015/lollipop
```

### unlink the rethinkdb service from the app

```shell
# usage
dokku rethinkdb:unlink <service> <app>
```

flags:

- `-n|--no-restart "false"`: whether or not to restart the app on unlink (default: true)

You can unlink a rethinkdb service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku rethinkdb:unlink lollipop playground
```

### set or clear a property for a service

```shell
# usage
dokku rethinkdb:set <service> <key> <value>
```

Set the network to attach after the service container is started:

```shell
dokku rethinkdb:set lollipop post-create-network custom-network
```

Set multiple networks:

```shell
dokku rethinkdb:set lollipop post-create-network custom-network,other-network
```

Unset the post-create-network value:

```shell
dokku rethinkdb:set lollipop post-create-network
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the rethinkdb connection tool

```shell
# usage
dokku rethinkdb:connect <service>
```

Connect to the service via the rethinkdb connection tool:

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku rethinkdb:connect lollipop
```

### enter or run a command in a running rethinkdb service container

```shell
# usage
dokku rethinkdb:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku rethinkdb:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku rethinkdb:enter lollipop touch /tmp/test
```

### expose a rethinkdb service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku rethinkdb:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku rethinkdb:expose lollipop 28015 29015 8080
```

Expose the service on the service's normal ports, with the first on a specified ip adddress (127.0.0.1):

```shell
dokku rethinkdb:expose lollipop 127.0.0.1:28015 29015 8080
```

### unexpose a previously exposed rethinkdb service

```shell
# usage
dokku rethinkdb:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku rethinkdb:unexpose lollipop
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
DOKKU_RETHINKDB_SILVER_URL=rethinkdb://lollipop:SOME_PASSWORD@dokku-rethinkdb-lollipop:28015/lollipop
```

### start a previously stopped rethinkdb service

```shell
# usage
dokku rethinkdb:start <service>
```

Start the service:

```shell
dokku rethinkdb:start lollipop
```

### stop a running rethinkdb service

```shell
# usage
dokku rethinkdb:stop <service>
```

Stop the service and removes the running container:

```shell
dokku rethinkdb:stop lollipop
```

### pause a running rethinkdb service

```shell
# usage
dokku rethinkdb:pause <service>
```

Pause the running container for the service:

```shell
dokku rethinkdb:pause lollipop
```

### graceful shutdown and restart of the rethinkdb service container

```shell
# usage
dokku rethinkdb:restart <service>
```

Restart the service:

```shell
dokku rethinkdb:restart lollipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku rethinkdb:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-N|--initial-network INITIAL_NETWORK`: the initial network to attach the service to
- `-P|--post-create-network NETWORKS`: a comma-separated list of networks to attach the service container to after service creation
- `-R|--restart-apps "true"`: whether or not to force an app restart (default: false)
- `-S|--post-start-network NETWORKS`: a comma-separated list of networks to attach the service container to after service start
- `-s|--shm-size SHM_SIZE`: override shared memory size for rethinkdb docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku rethinkdb:upgrade lollipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all rethinkdb service links for a given app

```shell
# usage
dokku rethinkdb:app-links <app>
```

List all rethinkdb services that are linked to the `playground` app.

```shell
dokku rethinkdb:app-links playground
```

### check if the rethinkdb service exists

```shell
# usage
dokku rethinkdb:exists <service>
```

Here we check if the lollipop rethinkdb service exists.

```shell
dokku rethinkdb:exists lollipop
```

### check if the rethinkdb service is linked to an app

```shell
# usage
dokku rethinkdb:linked <service> <app>
```

Here we check if the lollipop rethinkdb service is linked to the `playground` app.

```shell
dokku rethinkdb:linked lollipop playground
```

### list all apps linked to the rethinkdb service

```shell
# usage
dokku rethinkdb:links <service>
```

List all apps linked to the `lollipop` rethinkdb service.

```shell
dokku rethinkdb:links lollipop
```

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `RETHINKDB_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
