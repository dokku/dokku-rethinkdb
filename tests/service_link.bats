#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" ls
  dokku "$PLUGIN_COMMAND_PREFIX:create" ms
  dokku apps:create my-app
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" ms
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" ls
  dokku --force apps:destroy my-app
}

@test "($PLUGIN_COMMAND_PREFIX:link) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:link"
  echo "output: $output"
  echo "status: $status"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:link) error when the app argument is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:link" ls
  echo "output: $output"
  echo "status: $status"
  assert_contains "${lines[*]}" "Please specify an app to run the command on"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:link) error when the app does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:link" ls not_existing_app
  echo "output: $output"
  echo "status: $status"
  assert_contains "${lines[*]}" "App not_existing_app does not exist"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:link) error when the service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:link" not_existing_service my-app
  echo "output: $output"
  echo "status: $status"
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:link) error when the service is already linked to app" {
  dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app
  run dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app
  echo "output: $output"
  echo "status: $status"
  assert_contains "${lines[*]}" "Already linked as RETHINKDB_URL"
  assert_failure

  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
}

@test "($PLUGIN_COMMAND_PREFIX:link) exports RETHINKDB_URL to app" {
  run dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app
  echo "output: $output"
  echo "status: $status"
  url=$(dokku config:get my-app RETHINKDB_URL)
  assert_contains "$url" "rethinkdb://dokku-rethinkdb-ls:28015"
  assert_success
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
}

@test "($PLUGIN_COMMAND_PREFIX:link) generates an alternate config url when RETHINKDB_URL already in use" {
  dokku config:set my-app RETHINKDB_URL=rethinkdb://host:28015
  dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app
  run dokku config my-app
  assert_contains "${lines[*]}" "DOKKU_RETHINKDB_AQUA_URL"
  assert_success

  dokku "$PLUGIN_COMMAND_PREFIX:link" ms my-app
  run dokku config my-app
  assert_contains "${lines[*]}" "DOKKU_RETHINKDB_BLACK_URL"
  assert_success
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ms my-app
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
}

@test "($PLUGIN_COMMAND_PREFIX:link) links to app with docker-options" {
  dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app
  run dokku docker-options:report my-app
  assert_contains "${lines[*]}" "--link dokku.rethinkdb.ls:dokku-rethinkdb-ls"
  assert_success
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
}

@test "($PLUGIN_COMMAND_PREFIX:link) uses apps RETHINKDB_DATABASE_SCHEME variable" {
  dokku config:set my-app RETHINKDB_DATABASE_SCHEME=rethinkdb2
  dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app
  url=$(dokku config:get my-app RETHINKDB_URL)
  assert_contains "$url" "rethinkdb2://dokku-rethinkdb-ls:28015"
  assert_success
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
}

@test "($PLUGIN_COMMAND_PREFIX:link) adds a querystring" {
  dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app --querystring "pool=5"
  url=$(dokku config:get my-app RETHINKDB_URL)
  assert_contains "$url" "?pool=5"
  assert_success
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
}

@test "($PLUGIN_COMMAND_PREFIX:link) uses a specified config url when alias is specified" {
  dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app --alias "ALIAS"
  url=$(dokku config:get my-app ALIAS_URL)
  assert_contains "$url" "rethinkdb://dokku-rethinkdb-ls:28015"
  assert_success
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
}

@test "($PLUGIN_COMMAND_PREFIX:link) respects --no-restart" {
  run dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app
  echo "output: $output"
  echo "status: $status"
  assert_output_contains "Skipping restart of linked app" 0
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app --no-restart
  echo "output: $output"
  echo "status: $status"
  assert_output_contains "Skipping restart of linked app"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
  echo "output: $output"
  echo "status: $status"
  assert_success
}
