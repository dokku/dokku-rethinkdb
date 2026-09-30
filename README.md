# dokku rethinkdb [![Build Status](https://img.shields.io/github/actions/workflow/status/dokku/dokku-rethinkdb/ci.yml?branch=master&style=flat-square "Build Status")](https://github.com/dokku/dokku-rethinkdb/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official rethinkdb plugin for dokku. Currently defaults to installing [rethinkdb 2.4.3](https://hub.docker.com/_/rethinkdb/).

## Requirements

- dokku 0.35.x+
- docker 1.8.x

## Installation

```shell
# on 0.35.x+
sudo dokku plugin:install https://github.com/dokku/dokku-rethinkdb.git --name rethinkdb
```

## Commands

```
rethinkdb:app-links [<app>]                        # list all RethinkDB service links for a given app
rethinkdb:create <service> [--create-flags...]     # create a RethinkDB service
rethinkdb:destroy <service> [-f|--force]           # delete the RethinkDB service/data/container if there are no links left
rethinkdb:enter <service>                          # enter or run a command in a running RethinkDB service container
rethinkdb:exists <service>                         # check if the RethinkDB service exists
rethinkdb:expose <service> <ports...>              # expose a RethinkDB service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
rethinkdb:info [<service>] [--info-flags...]       # print the service information
rethinkdb:link <service> [<app>] [--link-flags...] # link the RethinkDB service to the app
rethinkdb:linked <service> [<app>]                 # check if the RethinkDB service is linked to an app
rethinkdb:links <service>                          # list all apps linked to the RethinkDB service
rethinkdb:list                                     # list all RethinkDB services
rethinkdb:logs <service> [-t|--tail [<tail-num>]]  # print the most recent log(s) for this service
rethinkdb:mount [--replace] <service> <source:container-dir[:options]>... # mount a host path or docker volume into the service container
rethinkdb:pause <service>                          # pause a running RethinkDB service
rethinkdb:promote <service> [<app>]                # promote service <service> as RETHINKDB_URL in <app>
rethinkdb:reexpose <service>                       # reexpose a RethinkDB service, applying its expose settings
rethinkdb:restart <service>                        # graceful shutdown and restart of the RethinkDB service container
rethinkdb:set <service> <key> <value>              # set or clear a property for a service
rethinkdb:start <service>                          # start a previously stopped RethinkDB service
rethinkdb:stop <service>                           # stop a running RethinkDB service
rethinkdb:unexpose <service>                       # unexpose a previously exposed RethinkDB service
rethinkdb:unlink <service> [<app>] [-n|--no-restart] # unlink the RethinkDB service from the app
rethinkdb:unmount [--all] <service> [<source:container-dir>...] # remove one or all mounts from the service container
rethinkdb:upgrade <service> [--upgrade-flags...]   # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to rethinkdb:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `rethinkdb:help` command for any undocumented commands.

### Basic Usage

### create a RethinkDB service

```shell
# usage
dokku rethinkdb:create <service> [--create-flags...]
```

flags:

- `-c|--config-options <string>`: extra arguments for the process the service container runs, not docker flags; use mount for mounts
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `--definition <string>`: the definition to run the service on, instead of the one its image and version resolve to
- `-i|--image <string>`: the image name to start the service with
- `-I|--image-version <string>`: the image version to start the service with
- `-N|--initial-network <string>`: the initial network to attach the service to
- `--log-driver <string>`: the docker logging driver to run the service container with (default: the daemon's own)
- `--log-opt <strings>`: a comma-separated list of key=value docker log options for the service container
- `-m|--memory <int>`: container memory limit in megabytes (default: unlimited)
- `-p|--password <string>`: override the user-level service password, for datastores that have one
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `--restart <string>`: the docker restart policy to run the service container with (default: always)
- `-r|--root-password <string>`: override the root-level service password, for datastores that have one
- `-s|--shm-size <string>`: override shared memory size for the service docker container
- `--volume <stringArray>`: a host path or docker volume to mount into the service container, as <source>:<container-dir>[:<options>], repeatable
- `--volume-target <stringArray>`: mount one of the definition's volumes at another container path, as <volume>=<container-dir>, repeatable
- `--wait-timeout <string>`: seconds to wait for the service to become ready (default: the datastore's own)

Create a rethinkdb service named lollipop:

```shell
dokku rethinkdb:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the rethinkdb image.

```shell
export RETHINKDB_IMAGE="rethinkdb"
export RETHINKDB_IMAGE_VERSION="2.4.3"
dokku rethinkdb:create lollipop
```

An image other than rethinkdb has no version to fall back on, because the version this plugin pins belongs to rethinkdb, so name one alongside it.

```shell
dokku rethinkdb:create lollipop --image <image> --image-version <version>
```

You can also specify custom environment variables to start the rethinkdb service in semicolon-separated form.

```shell
export RETHINKDB_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku rethinkdb:create lollipop
```

The container log is bounded by whatever `dokku logs:set --global max-size` says, and by dokku's own default where it says nothing, which a service may override for itself.

```shell
dokku rethinkdb:create lollipop --log-opt max-size=20m,max-file=3
```

The container is restarted by docker whenever it stops, which a service may change for itself.

```shell
dokku rethinkdb:create lollipop --restart unless-stopped
```

The service is waited on until it answers, for as long as the datastore's own default, which a slow host may raise for every service with `RETHINKDB_WAIT_TIMEOUT` or a service may raise for itself.

```shell
dokku rethinkdb:create lollipop --wait-timeout 120
```

The config options are handed to the process the container runs, not to docker, so a host path or docker volume is mounted with --volume, which may be repeated.

```shell
dokku rethinkdb:create lollipop --volume /var/lib/dokku/data/storage/lollipop:/opt/extra:ro
```

The definition's own volumes can be mounted at another path in the container, for an image that keeps its data somewhere else, with --volume-target, which may be repeated.

```shell
export RETHINKDB_VOLUME_TARGETS="data=/srv/rethinkdb"
dokku rethinkdb:create lollipop --volume-target data=/srv/rethinkdb
```

The service passwords are generated unless they are given. A datastore without a root password refuses --root-password rather than dropping it.

```shell
dokku rethinkdb:create lollipop --password <password> --root-password <root-password>
```

### delete the RethinkDB service/data/container if there are no links left

```shell
# usage
dokku rethinkdb:destroy <service> [-f|--force]
```

flags:

- `-f|--force`: force the destruction of the service

Destroy the service, it's data, and the running container:

```shell
dokku rethinkdb:destroy lollipop
```

A service that is still linked to an app is not destroyed, and the apps it is linked to are named. Unlink them first.

### print the service information

```shell
# usage
dokku rethinkdb:info [<service>] [--info-flags...]
```

flags:

- `--backend`: show the execution backend the service was created with
- `--backup-auth-fingerprint`: show a sha256 fingerprint of the stored backup access key id and secret
- `--backup-authenticated`: show whether backup credentials are stored for the service
- `--backup-bucket`: show the bucket scheduled backups are shipped to
- `--backup-default-region`: show the region backups authenticate against
- `--backup-encrypted`: show whether scheduled backups are encrypted with a passphrase
- `--backup-encryption-fingerprint`: show a sha256 fingerprint of the stored backup passphrase
- `--backup-endpoint-url`: show the s3-compatible endpoint backups are shipped to
- `--backup-keyserver`: show the keyserver backup public keys are fetched from
- `--backup-public-key-id`: show the gpg public key id backups are encrypted with
- `--backup-schedule`: show the cron schedule backups run on
- `--backup-signature-version`: show the signature version backups authenticate with
- `--backup-storage-class`: show the s3 storage class backups are uploaded with
- `--backup-use-iam`: show whether scheduled backups authenticate with an instance role
- `--config-dir`: show the service configuration directory
- `--config-options`: show the config options the service container is run with
- `--custom-env`: show the custom environment the service container is run with
- `--data-dir`: show the service data directory
- `--database-name`: show the name of the database inside the service
- `--definition`: show the definition the service was created with
- `--dsn`: show the service DSN
- `--export-args`: show the extra arguments every export of the service is run with
- `--expose-host`: show the host the exposed DSN names
- `--expose-mode`: show whether exposed ports are published through an ambassador or directly by the service container
- `--exposed-dsn`: show the DSN the service is reached at through its exposed ports
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--image`: show the image the service runs
- `--image-version`: show the image version the service was created with
- `--import-args`: show the extra arguments every import into the service is run with
- `--initial-network`: show the initial network being connected to
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--log-driver`: show the docker logging driver the service container is run with
- `--log-opt`: show the docker log options the service container is run with
- `--memory`: show the memory limit the service container is run with
- `--mounts`: show the host paths and docker volumes mounted into the service container
- `--port-bind-address`: show the address exposed ports without one of their own are bound on
- `--port-source-range`: show the only range of client addresses the exposed ports accept
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--restart-policy`: show the restart policy the service container is run with
- `--service`: show the name of the service
- `--service-root`: show the service root directory
- `--shm-size`: show the shared memory size the service container is run with
- `--status`: show the service running status
- `--version`: show the service image version
- `--volume-targets`: show the container paths the service's volumes are mounted at in place of the definition's
- `--wait-timeout`: show the seconds the service is waited on to become ready

Get connection information as follows:

```shell
dokku rethinkdb:info lollipop
```

Alongside the connection information this reports the properties set on the service, the state it was created with, and its backup settings. A property that was never set, or that was unset, reports as empty. Omit the service to report on every rethinkdb service:

```shell
dokku rethinkdb:info
```

The information can be read by machine, one json object per service:

```shell
dokku rethinkdb:info lollipop --format json
```

You can also retrieve a specific piece of service info via a flag, which prints it on its own:

```shell
dokku rethinkdb:info lollipop --dsn
dokku rethinkdb:info lollipop --status
dokku rethinkdb:info lollipop --internal-ip
dokku rethinkdb:info lollipop --initial-network
```

> NOTE: a flag cannot be combined with --format, and only one may be given

The exposed dsn is the one a client off the host connects with. It names the expose-host, or the first global domain without one, and is empty until the service is exposed and there is a host to name:

```shell
dokku rethinkdb:info lollipop --exposed-dsn
```

The properties rethinkdb:set writes are reported under the names it takes, so a value read here can be written back:

```shell
dokku rethinkdb:set lollipop initial-network my-network
```

The stored backup credentials and passphrase are never printed. Each is reported as a lowercase hex sha256 fingerprint of the stored value, with surrounding whitespace trimmed, so a copy of the values can be compared against it:

```shell
dokku rethinkdb:info lollipop --backup-auth-fingerprint
dokku rethinkdb:info lollipop --backup-encryption-fingerprint
```

The same fingerprints can be computed from the values that were passed to backup-auth and backup-set-encryption:

```
printf '%s\n%s' "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" | sha256sum
printf '%s' "$PASSPHRASE" | sha256sum
```

### list all RethinkDB services

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
dokku rethinkdb:logs <service> [-t|--tail [<tail-num>]]
```

flags:

- `-t|--tail <int>`: tail the logs, optionally showing this many lines

You can tail logs for a particular service:

```shell
dokku rethinkdb:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku rethinkdb:logs lollipop --tail
```

By default the last 100 lines are shown, but a different count can be specified:

```shell
dokku rethinkdb:logs lollipop --tail=5
```

### link the RethinkDB service to the app

```shell
# usage
dokku rethinkdb:link <service> [<app>] [--link-flags...]
```

flags:

- `-a|--alias <string>`: the prefix of the config variable the service url is set as on the app, which is suffixed with _URL
- `-e|--env-var <string>`: the full name of the config variable the service url is set as on the app, used instead of an alias and not suffixed with _URL
- `-n|--no-restart`: whether to skip restarting the app
- `-q|--querystring <string>`: ampersand delimited querystring arguments to append to the service url after a ?

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
RETHINKDB_URL=rethinkdb://:SOME_PASSWORD@dokku-rethinkdb-lollipop:28015
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku rethinkdb:link other_service playground
```

The url can be set under another name with the `--alias` flag. The value given is the prefix of the config variable, which is suffixed with `_URL` and holds the same url:

```shell
dokku rethinkdb:link lollipop playground --alias BLUE_RETHINKDB
```

This will set the following on the linked application instead of `RETHINKDB_URL`:

```
BLUE_RETHINKDB_URL=rethinkdb://:SOME_PASSWORD@dokku-rethinkdb-lollipop:28015
```

An alias whose variable is already set on the app is refused, and unlink removes the variable whatever alias it was set under. An app that expects the url under a name that does not end in `_URL` can be given that name in full with the `--env-var` flag, which cannot be combined with `--alias`:

```shell
dokku rethinkdb:link lollipop playground --env-var MB_DB_CONNECTION_URI
```

This will set the following on the linked application instead of `RETHINKDB_URL`:

```
MB_DB_CONNECTION_URI=rethinkdb://:SOME_PASSWORD@dokku-rethinkdb-lollipop:28015
```

A name already set on the app is refused. Arguments can be appended to the url as a querystring with the `--querystring` flag:

```shell
dokku rethinkdb:link lollipop playground --querystring "foo=bar&baz=qux"
```

This will cause `RETHINKDB_URL` to be set as:

```
rethinkdb://:SOME_PASSWORD@dokku-rethinkdb-lollipop:28015?foo=bar&baz=qux
```

It is possible to change the protocol for `RETHINKDB_URL` by setting the environment variable `RETHINKDB_DATABASE_SCHEME` on the app. Link records the variable it set, so unlink still removes it after the scheme or querystring on it changes. A link made by an earlier version of the plugin is recorded the next time link or promote runs for it, and until then we advise you to unlink before changing the scheme.

```shell
dokku config:set playground RETHINKDB_DATABASE_SCHEME=rethinkdb2
dokku rethinkdb:link lollipop playground
```

This will cause `RETHINKDB_URL` to be set as:

```
rethinkdb2://:SOME_PASSWORD@dokku-rethinkdb-lollipop:28015
```

### unlink the RethinkDB service from the app

```shell
# usage
dokku rethinkdb:unlink <service> [<app>] [-n|--no-restart]
```

flags:

- `-n|--no-restart`: whether to skip restarting the app

You can unlink a rethinkdb service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku rethinkdb:unlink lollipop playground
```

An app is still linked after its `RETHINKDB_URL` is changed to point elsewhere, and is unlinked the same way. The variable it now holds is not the service's, so it is left alone, nothing is unset, the app is not restarted, and a warning says so. A variable link set that has only had its scheme or querystring changed still points at the service, and is unset.

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

Set the keyserver a public key for backup encryption is fetched from:

```shell
dokku rethinkdb:set lollipop backup-keyserver hkp://keys.example.com
```

Set the s3 storage class backups are uploaded with, one of `STANDARD,` `REDUCED_REDUNDANCY,` `STANDARD_IA,` `ONEZONE_IA,` `INTELLIGENT_TIERING,` `GLACIER,` `DEEP_ARCHIVE` or `GLACIER_IR`:

```shell
dokku rethinkdb:set lollipop backup-storage-class STANDARD_IA
```

Go back to uploading backups with the bucket's default storage class:

```shell
dokku rethinkdb:set lollipop backup-storage-class
```

Cap the container log at a size of your own rather than the one it inherits:

```shell
dokku rethinkdb:set lollipop log-opt max-size=20m,max-file=3
```

Keep the log unbounded, which is what a service had before there was anything to say here:

```shell
dokku rethinkdb:set lollipop log-opt max-size=unlimited
```

Send the container log somewhere other than the daemon's own driver:

```shell
dokku rethinkdb:set lollipop log-driver journald
```

Restart the container unless it was stopped on purpose, including across a docker restart:

```shell
dokku rethinkdb:set lollipop restart-policy unless-stopped
```

Go back to always restarting the container:

```shell
dokku rethinkdb:set lollipop restart-policy
```

Wait up to two minutes for the service to answer, used the next time it is started:

```shell
dokku rethinkdb:set lollipop wait-timeout 120
```

Go back to the wait timeout the host or the datastore sets:

```shell
dokku rethinkdb:set lollipop wait-timeout
```

Publish exposed ports that have no address of their own on one address rather than on every interface:

```shell
dokku rethinkdb:set lollipop port-bind-address 10.0.0.5
```

Only accept connections to the exposed ports from clients in one `IP` address or `CIDR`:

```shell
dokku rethinkdb:set lollipop port-source-range 10.0.0.0/8
```

Go back to accepting every client:

```shell
dokku rethinkdb:set lollipop port-source-range
```

Name the host the exposed dsn points clients at, when they reach the server by a name or address other than its global domain. It does not change where the ports are bound:

```shell
dokku rethinkdb:set lollipop expose-host db.example.com
```

Go back to naming the first global domain:

```shell
dokku rethinkdb:set lollipop expose-host
```

Publish the exposed ports on the service container itself rather than through an ambassador container, which relays every connection. A port-source-range cannot be used with it:

```shell
dokku rethinkdb:set lollipop expose-mode direct
```

Go back to publishing the exposed ports through an ambassador container:

```shell
dokku rethinkdb:set lollipop expose-mode
```

Mount one of the definition's volumes at another path in the container, for an image that keeps its data somewhere else. Each volume is named by where it lives in the service directory (data), and several are separated by spaces:

```shell
dokku rethinkdb:set lollipop volume-targets data=/srv/rethinkdb
```

Go back to mounting every volume where the definition does:

```shell
dokku rethinkdb:set lollipop volume-targets
```

> NOTE: a log setting, a restart policy or a volume target reaches the container the next time one is built. rethinkdb:restart keeps the container it has, so use rethinkdb:stop and then rethinkdb:start on a service that is already running.
> NOTE: a port-bind-address or port-source-range reaches an exposed service with rethinkdb:reexpose, which replaces the container publishing its ports and leaves the service container running.
> NOTE: an expose-mode, or a port-bind-address for a service exposed directly, reaches an exposed service with rethinkdb:reexpose, which stops and starts a running service after asking. It also reaches the service the next time it is restarted, or stopped and started.

### mount a host path or docker volume into the service container

```shell
# usage
dokku rethinkdb:mount [--replace] <service> <source:container-dir[:options]>...
```

flags:

- `--replace`: replace the service's entire set of mounts with the ones given
- `--volume-chown <string>`: who to hand the mounted directory to, for a host path inside the service's directory; not valid with --replace
- `--volume-options <string>`: comma-separated docker mount options, such as z or nocopy; not valid with --replace
- `--volume-readonly`: mount the volume read only; not valid with --replace
- `--volume-subpath <string>`: a subpath within the source to mount rather than the source itself; not valid with --replace

Mount a host directory into the service container:

```shell
dokku rethinkdb:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra
```

The source is an absolute host path, which must already exist, or the name of a docker volume. Options follow a second colon: ro or rw, docker's own mount options, volume-subpath=<path> and volume-chown=<option>:

```shell
dokku rethinkdb:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra:ro,z
```

A subpath mounts a directory within the source rather than the source itself. A docker volume mounted from a subpath needs Docker Engine 26.0 or newer, and takes no mount option but nocopy.

```shell
dokku rethinkdb:mount lollipop my-volume:/opt/extra:volume-subpath=uploads
```

A chown hands the mounted directory to a user before the container is made: herokuish, heroku, paketo, root or a uid. It is only taken for a host path inside the service's own directory.

```shell
dokku rethinkdb:mount lollipop /var/lib/dokku/services/rethinkdb/lollipop/extra:/opt/extra:volume-chown=heroku
```

The same can be said with flags instead:

```shell
dokku rethinkdb:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra --volume-readonly --volume-options z
```

Mounting the same source at the same directory again rewrites its options:

```shell
dokku rethinkdb:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra
```

Replace every mount the service has with the ones given:

```shell
dokku rethinkdb:mount --replace lollipop /srv/a:/opt/a:ro /srv/b:/opt/b
```

> NOTE: a mount cannot land where one of the definition's volumes is mounted, which for a volume moved with the volume-targets property is where it was moved to.
> NOTE: a mount reaches the container the next time one is built. rethinkdb:restart keeps the container it has, so use rethinkdb:stop and then rethinkdb:start on a service that is already running.

### remove one or all mounts from the service container

```shell
# usage
dokku rethinkdb:unmount [--all] <service> [<source:container-dir>...]
```

flags:

- `--all`: remove every mount the service has

Remove a mount, naming it the way it was mounted:

```shell
dokku rethinkdb:unmount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra
```

Remove every mount the service has:

```shell
dokku rethinkdb:unmount --all lollipop
```

> NOTE: the mount is removed from the container the next time one is built. rethinkdb:restart keeps the container it has, so use rethinkdb:stop and then rethinkdb:start on a service that is already running.

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### enter or run a command in a running RethinkDB service container

```shell
# usage
dokku rethinkdb:enter <service>
```

A shell can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku rethinkdb:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku rethinkdb:enter lollipop touch /tmp/test
```

### expose a RethinkDB service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku rethinkdb:expose <service> <ports...>
```

flags:

- `-f|--force`: stop and start a running service without asking when its container has to publish other ports

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku rethinkdb:expose lollipop 28015 29015 8080
```

Expose the service on the service's normal ports, with the first on a specified ip address (127.0.0.1):

```shell
dokku rethinkdb:expose lollipop 127.0.0.1:28015 29015 8080
```

Expose the service on random ports on a single address, and only to clients in one network:

```shell
dokku rethinkdb:set lollipop port-bind-address 10.0.0.5
dokku rethinkdb:set lollipop port-source-range 10.0.0.0/8
dokku rethinkdb:expose lollipop
```

Expose the service by publishing its ports on the service container itself rather than through an ambassador container. A running service is stopped and started to publish them, after asking, or without asking when --force is given:

```shell
dokku rethinkdb:set lollipop expose-mode direct
dokku rethinkdb:expose lollipop --force
```

Print the dsn a client off the host connects with, which names the expose-host or the first global domain:

```shell
dokku rethinkdb:info lollipop --exposed-dsn
```

### unexpose a previously exposed RethinkDB service

```shell
# usage
dokku rethinkdb:unexpose <service>
```

flags:

- `-f|--force`: stop and start a running service without asking when its container has to publish other ports

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku rethinkdb:unexpose lollipop
```

Unexpose a running service exposed directly, stopping and starting it without asking so that its container stops publishing the ports:

```shell
dokku rethinkdb:unexpose lollipop --force
```

### reexpose a RethinkDB service, applying its expose settings

```shell
# usage
dokku rethinkdb:reexpose <service>
```

flags:

- `-f|--force`: stop and start a running service without asking when its container has to publish other ports

Apply a changed port-bind-address or port-source-range to an exposed service, on the ports it is already exposed on:

```shell
dokku rethinkdb:set lollipop port-source-range 10.0.0.0/8
dokku rethinkdb:reexpose lollipop
```

Move an exposed service between being published through an ambassador and directly, stopping and starting it without asking:

```shell
dokku rethinkdb:set lollipop expose-mode direct
dokku rethinkdb:reexpose lollipop --force
```

> NOTE: a service published through an ambassador only has the ambassador replaced, so the service keeps running, though connections made through the exposed ports are dropped. An ambassador that already matches the service's settings and is publishing is left alone.
> NOTE: a service whose container has to publish other ports, because it is exposed directly or is being moved between expose modes, is stopped and started. A running service is asked about first, and nothing is changed if the answer is no.
> NOTE: A service that is not exposed is refused, as is one published through an ambassador that is not running.

### promote service <service> as RETHINKDB_URL in <app>

```shell
# usage
dokku rethinkdb:promote <service> [<app>]
```

If you have a rethinkdb service linked to an app and try to link another rethinkdb service another link environment variable will be generated automatically:

```
DOKKU_RETHINKDB_AQUA_URL=rethinkdb://:ANOTHER_PASSWORD@dokku-rethinkdb-other-service:28015/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku rethinkdb:promote other_service playground
```

This will replace `RETHINKDB_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
RETHINKDB_URL=rethinkdb://:ANOTHER_PASSWORD@dokku-rethinkdb-other-service:28015/other_service
DOKKU_RETHINKDB_AQUA_URL=rethinkdb://:ANOTHER_PASSWORD@dokku-rethinkdb-other-service:28015/other_service
DOKKU_RETHINKDB_BLACK_URL=rethinkdb://:SOME_PASSWORD@dokku-rethinkdb-lollipop:28015/lollipop
```

### start a previously stopped RethinkDB service

```shell
# usage
dokku rethinkdb:start <service>
```

Start the service:

```shell
dokku rethinkdb:start lollipop
```

A service comes back on the version it was created with, or was last upgraded to, whatever version the plugin ships now. The image is fetched if the host no longer has it. A service that has never recorded a version and has no container left to read one from cannot be placed, and is reported rather than started on a guess. Use rethinkdb:upgrade to say which version it should run.

### stop a running RethinkDB service

```shell
# usage
dokku rethinkdb:stop <service>
```

Stop the service and removes the running container:

```shell
dokku rethinkdb:stop lollipop
```

### pause a running RethinkDB service

```shell
# usage
dokku rethinkdb:pause <service>
```

Pause the running container for the service:

```shell
dokku rethinkdb:pause lollipop
```

### graceful shutdown and restart of the RethinkDB service container

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

- `-c|--config-options <string>`: extra arguments for the process the service container runs, not docker flags; use mount for mounts
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `--definition <string>`: the definition to move the service onto, instead of the one its image and version resolve to
- `-i|--image <string>`: the image to upgrade the service to
- `-I|--image-version <string>`: the image version to upgrade the service to
- `-N|--initial-network <string>`: the initial network to attach the service to
- `--log-driver <string>`: the docker logging driver to run the service container with (default: the daemon's own)
- `--log-opt <strings>`: a comma-separated list of key=value docker log options for the service container
- `-m|--memory <int>`: container memory limit in megabytes, 0 for unlimited
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `--restart <string>`: the docker restart policy to run the service container with (default: always)
- `-R|--restart-apps`: whether to stop and start the linked apps around the upgrade
- `-s|--shm-size <string>`: override shared memory size for the service docker container
- `--volume <stringArray>`: a host path or docker volume to mount into the service container, as <source>:<container-dir>[:<options>], repeatable
- `--volume-target <stringArray>`: mount one of the definition's volumes at another container path, as <volume>=<container-dir>, repeatable
- `--wait-timeout <string>`: seconds to wait for the service to become ready (default: the datastore's own)

You can upgrade an existing service to a new image or image-version:

```shell
dokku rethinkdb:upgrade lollipop
```

This is the only command that changes the version a service runs. With no version named it moves to the newest the service's own major version ships, which leaves the data where it is.

```shell
dokku rethinkdb:upgrade lollipop --image-version 1.2.3
```

Moving across a major version has to be asked for by name, because it is not a tag change: the data is mounted somewhere different under the new one, and pointing the version back does not undo it. A service keeps the mounts it has unless --volume is passed, which replaces them, and each one is checked against the new container before the old one is taken away.

```shell
dokku rethinkdb:upgrade lollipop --volume /var/lib/dokku/data/storage/lollipop:/opt/extra:ro
```

A service keeps the volume targets it has unless --volume-target is passed, which replaces them, and an upgrade onto a definition that does not mount a volume the service moved is refused before the old container is taken away. --volume-target "" puts every volume back where the new definition mounts it.

```shell
dokku rethinkdb:upgrade lollipop --volume-target ""
```

A service keeps its memory limit unless --memory is passed, and --memory 0 removes it.

```shell
dokku rethinkdb:upgrade lollipop --memory 512
```

### Service Automation

Service scripting can be executed using the following commands:

### list all RethinkDB service links for a given app

```shell
# usage
dokku rethinkdb:app-links [<app>]
```

List all rethinkdb services that are linked to the `playground` app.

```shell
dokku rethinkdb:app-links playground
```

### check if the RethinkDB service exists

```shell
# usage
dokku rethinkdb:exists <service>
```

Here we check if the lollipop rethinkdb service exists.

```shell
dokku rethinkdb:exists lollipop
```

### check if the RethinkDB service is linked to an app

```shell
# usage
dokku rethinkdb:linked <service> [<app>]
```

Here we check if the lollipop rethinkdb service is linked to the `playground` app.

```shell
dokku rethinkdb:linked lollipop playground
```

### list all apps linked to the RethinkDB service

```shell
# usage
dokku rethinkdb:links <service>
```

List all apps linked to the `lollipop` rethinkdb service.

```shell
dokku rethinkdb:links lollipop
```

Renaming an app moves its link onto the new name, and cloning an app links the clone as well as the original.

### Limiting where and to whom a service is exposed

An exposed service's ports are published on every interface unless they are given an address of their own. To publish them on one address instead, set the service's `port-bind-address` property with `dokku rethinkdb:set`, and to accept connections only from clients in one IP address or CIDR, set its `port-source-range` property. Either reaches a running service with `dokku rethinkdb:reexpose`, which leaves the service running when its ports are published through an ambassador.

Only one source range can be given. The range is checked against the address a connection reaches the service from, which for a connection to the exposed port on the loopback interface, or an IPv6 connection to a service network without IPv6, is the docker network's gateway rather than the client, so with a range that leaves the gateway out, connecting to `127.0.0.1` from the dokku host itself is refused.

### Exposing a service without an ambassador

An exposed service's ports are published by an ambassador, a container that relays every connection on to the service. The ambassador can be replaced without touching the service and can hold clients to a `port-source-range`, but relaying adds latency to every request.

To publish the ports on the service container itself instead, set the service's `expose-mode` property to `direct` with `dokku rethinkdb:set`. Docker has no way of changing the ports a container publishes, so the container is made again whenever what it publishes changes: when the service is exposed or unexposed, when its `port-bind-address` changes, and when it moves between expose modes. For a running service, `dokku rethinkdb:expose`, `dokku rethinkdb:unexpose` and `dokku rethinkdb:reexpose` ask before stopping and starting it, and change nothing if the answer is no. Pass `--force` to stop and start it without being asked. A change also reaches the service the next time it is restarted, or stopped and started.

A `port-source-range` cannot be enforced on a port the service container publishes itself, so it cannot be set on a service exposed directly, and a service with one cannot be exposed directly.

### Connecting to an exposed service from outside the host

`dokku rethinkdb:info lollipop --exposed-dsn` prints the dsn a client off the dokku host connects with. It is the dsn a linked app is handed, with the exposed ports in place of the container's and a public host in place of the service container's name, so it carries the same credentials. The host is the service's `expose-host` property, set with `dokku rethinkdb:set`, or the first global domain when it has none. The `port-bind-address`, or an address given with a port, is never used as the host, since it is where the port is bound rather than where a client elsewhere reaches it. The dsn is empty until the service is exposed and there is a host to name.

### Waiting for a service to become ready

A service is waited on until it answers on its port after it is created, cloned, started, restarted, upgraded or exposed. If it takes longer than that to start - on a slow host, or with an image that does more on its first boot - the command fails with `ERROR: unable to connect`.

To wait longer for every rethinkdb service on the host, set the `RETHINKDB_WAIT_TIMEOUT` environment variable to a number of seconds. To wait longer for a single service, set its `wait-timeout` property with `dokku rethinkdb:set` or pass `--wait-timeout` to `create`, `clone` or `upgrade`. The service's own setting is used first, then the environment variable, then the datastore's default.

### Moving where a service's volumes are mounted

Each volume a service mounts is named by the directory it lives in under the service's own directory, and is mounted where the datastore's definition says. To mount one somewhere else in the container, for an image that keeps its data at another path, set the service's `volume-targets` property with `dokku rethinkdb:set`, pass `--volume-target` to `create`, `clone` or `upgrade`, or set the `RETHINKDB_VOLUME_TARGETS` environment variable before `create`. Each is written as `<volume>=<container-path>`, several separated by spaces, and `dokku rethinkdb:info lollipop --volume-targets` shows the ones a service moved.

| Definition | Volume | Mounted at |
| --- | --- | --- |
| rethinkdb | data | `/data` |

Moving a volume changes where it is mounted, not where the image reads and writes. The datastore's own commands and the paths it is started with follow the volume, but an image that keeps writing to its own path writes into the container rather than into the volume, and what it writes is lost when the container is rebuilt, so only move a volume to where the image expects its data. The data stays in the same directory on the host, and a move reaches the container the next time one is built, so use `dokku rethinkdb:stop` and then `dokku rethinkdb:start` on a running service. An upgrade onto a definition that does not mount a volume the service moved is refused until the move is cleared or replaced.

### Reserved service names

A service's database is named after the service, with hyphens replaced by underscores. So that an app is never handed a database RethinkDB keeps for itself, `dokku rethinkdb:create` and `dokku rethinkdb:clone` refuse a name that is, or whose database would be, one of `rethinkdb`, in any case. A service that already has such a name is not affected.

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `RETHINKDB_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
