#!/bin/bash

action=$1
repo=$2

execute() {
  substring="#!/bin/bash"
  sha=$(curl -sSL https://api.github.com/repos/WildePizza/kubernetes-dashboard/commits?per_page=2 | jq -r '.[1].sha')
  url="https://raw.githubusercontent.com/WildePizza/$repo/HEAD/.commits/$sha/scripts/$action.sh"
  output=$(curl -fsSL $url 2>&1)
  if [[ $output =~ $substring ]]; then
    curl -fsSL $url | bash -s $sha
  else
    sleep 1
    execute
  fi
}
execute
