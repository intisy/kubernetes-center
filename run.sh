#!/bin/bash

action=install

while [[ $# -gt 0 ]]; do
  case "$1" in
    action=*)
      action="${1#*=}"
      shift
      ;;
    args=*)
      args="${1#*=}"
      shift
      ;;
    repo=*)
      repo="${1#*=}"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [ ! -n "$repo" ]; then
  read -p "--repo has to be set"  
  exit
fi
repo=$2
pat=$3

execute() {
  substring="#!/bin/bash"
  sha=$(curl -sSL https://api.github.com/repos/WildePizza/kubernetes-dashboard/commits?per_page=2 | jq -r '.[1].sha')
  url="https://raw.githubusercontent.com/WildePizza/$repo/HEAD/.commits/$sha/scripts/$action.sh"
  output=$(curl -fsSL $url 2>&1)
  if [[ $output =~ $substring ]]; then
    if [ -n "$pat" ]; then
      curl -X GET -H "Authorization: Bearer $pat" -H "Content-Type: application/json" -fsSL $url | bash -s $sha $args
    else
      curl -fsSL $url | bash -s $sha $args
    fi
  else
    echo "Error: $output"
    sleep 1
    execute
  fi
}
execute
