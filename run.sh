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

execute() {
  substring="#!/bin/bash"
  if [ -n "$pat" ]; then
    sha=$(curl -X GET -H "Authorization: Bearer $pat" -H "Content-Type: application/json" -fsSL https://api.github.com/repos/WildePizza/$repo/commits?per_page=2 | jq -r '.[1].sha')
  else
    sha=$(curl -fsSL https://api.github.com/repos/WildePizza/$repo/commits?per_page=2 | jq -r '.[1].sha')
  fi
  url="https://raw.githubusercontent.com/WildePizza/$repo/HEAD/.commits/$sha/scripts/$action.sh"
  echo "Running script: $url"
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
