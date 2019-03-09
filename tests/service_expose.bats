#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:expose) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:expose) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:expose) success when not providing custom ports" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose" l
  [[ "${lines[*]}" =~ exposed\ on\ port\(s\)\ \[container\-\>host\]\:\ [[:digit:]]+ ]]
}

@test "($PLUGIN_COMMAND_PREFIX:expose) success when providing custom ports" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose" l 4242 4243 4244
  assert_contains "${lines[*]}" "exposed on port(s) [container->host]: 28015->4242 29015->4243 8080->4244"
}
