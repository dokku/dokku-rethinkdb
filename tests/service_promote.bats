#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
  dokku apps:create my_app >&2
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my_app
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" l my_app
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
  rm -rf "$DOKKU_ROOT/my_app"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the app argument is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l
  assert_contains "${lines[*]}" "Please specify an app to run the command on"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the app does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l not_existing_app
  assert_contains "${lines[*]}" "App not_existing_app does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" not_existing_service my_app
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the service is already promoted" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  assert_contains "${lines[*]}" "already promoted as RETHINKDB_URL"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) changes RETHINKDB_URL" {
  dokku config:set my_app "RETHINKDB_URL=rethinkdb://host:28015" "DOKKU_RETHINKDB_BLUE_URL=rethinkdb://dokku-rethinkdb-l:28015/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  url=$(dokku config:get my_app RETHINKDB_URL)
  assert_equal "$url" "rethinkdb://dokku-rethinkdb-l:28015/l"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) creates new config url when needed" {
  dokku config:set my_app "RETHINKDB_URL=rethinkdb://host:28015" "DOKKU_RETHINKDB_BLUE_URL=rethinkdb://dokku-rethinkdb-l:28015/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  run dokku config my_app
  assert_contains "${lines[*]}" "DOKKU_RETHINKDB_"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) uses RETHINKDB_DATABASE_SCHEME variable" {
  dokku config:set my_app "RETHINKDB_DATABASE_SCHEME=rethinkdb2" "RETHINKDB_URL=rethinkdb://u:p@host:28015" "DOKKU_RETHINKDB_BLUE_URL=rethinkdb2://dokku-rethinkdb-l:28015/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  url=$(dokku config:get my_app RETHINKDB_URL)
  assert_equal "$url" "rethinkdb2://dokku-rethinkdb-l:28015/l"
}
