#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
  dokku apps:create my-app
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my-app
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" l my-app
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
  dokku --force apps:destroy my-app
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
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
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" not_existing_service my-app
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the service is already promoted" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l my-app
  assert_contains "${lines[*]}" "already promoted as RETHINKDB_URL"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) changes RETHINKDB_URL" {
  dokku config:set my-app "RETHINKDB_URL=rethinkdb://host:28015" "DOKKU_RETHINKDB_BLUE_URL=rethinkdb://dokku-rethinkdb-l:28015/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my-app
  url=$(dokku config:get my-app RETHINKDB_URL)
  assert_equal "$url" "rethinkdb://dokku-rethinkdb-l:28015/l"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) creates new config url when needed" {
  dokku config:set my-app "RETHINKDB_URL=rethinkdb://host:28015" "DOKKU_RETHINKDB_BLUE_URL=rethinkdb://dokku-rethinkdb-l:28015/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my-app
  run dokku config my-app
  assert_contains "${lines[*]}" "DOKKU_RETHINKDB_"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) uses RETHINKDB_DATABASE_SCHEME variable" {
  dokku config:set my-app "RETHINKDB_DATABASE_SCHEME=rethinkdb2" "RETHINKDB_URL=rethinkdb://u:p@host:28015" "DOKKU_RETHINKDB_BLUE_URL=rethinkdb2://dokku-rethinkdb-l:28015/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my-app
  url=$(dokku config:get my-app RETHINKDB_URL)
  assert_equal "$url" "rethinkdb2://dokku-rethinkdb-l:28015/l"
}
