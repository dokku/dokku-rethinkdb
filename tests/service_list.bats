#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:list) with no exposed ports" {
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "l (running)"
}

@test "($PLUGIN_COMMAND_PREFIX:list) with exposed ports" {
  dokku "$PLUGIN_COMMAND_PREFIX:expose" l 4242 4243 4244
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "l (running), exposed port(s): 28015->4242 29015->4243 8080->4244"
}

@test "($PLUGIN_COMMAND_PREFIX:list) when there are no services" {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "There are no RethinkDB services"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}
