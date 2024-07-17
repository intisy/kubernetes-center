#!/bin/bash

# default options:
using_kubernetes=true
using_ui=true
using_docker_ui_test=false
gererate_password=false
using_nfs=true
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
    pat=*)
      pat="${1#*=}"
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

if [ -n "$repo" ]; then
  read -a args_array <<< "$args"
  for element in "${args_array[@]}"
  do
    echo $element
    case "$element" in
      username=*)
        username="${1#*=}"
        shift
        ;;
      password=*)
        password="${1#*=}"
        shift
        ;;
      using_kubernetes=*)
        using_kubernetes="${1#*=}"
        shift
        ;;
      using_ui=*)
        using_ui="${1#*=}"
        shift
        ;;
      using_docker_ui_test=*)
        using_docker_ui_test="${1#*=}"
        shift
        ;;
      gererate_password=*)
        gererate_password="${1#*=}"
        shift
        ;;
      using_nfs=*)
        using_nfs="${1#*=}"
        shift
        ;;
      *)
        echo "Unknown option: $element"
        exit 1
        ;;
    esac
  done
else
  read -p "--repo has to be set"  
  exit
fi
echo $username

execute() {
  substring="#!/bin/bash"
  if [ -n "$pat" ]; then
    sha=$(curl -X GET -H "Authorization: Bearer $pat" -H "Content-Type: application/json" -fsSL https://api.github.com/repos/WildePizza/$repo/commits?per_page=2 | jq -r '.[1].sha')
  else
    sha=$(curl -fsSL https://api.github.com/repos/WildePizza/$repo/commits?per_page=2 | jq -r '.[1].sha')
  fi
  if [ "$repo" = "docker-registry" ]; then
    args="$username $password $using_kubernetes $using_ui $using_docker_ui_test $gererate_password $using_nfs"
  elif [ "$repo" = "mysql-kubernetes" ]; then
    args="$sha $password $using_nfs"
  elif [ "$repo" = "nfs-kubernetes" ]; then
    args=""
  fi
  url="https://raw.githubusercontent.com/WildePizza/$repo/HEAD/.commits/$sha/scripts/$action.sh"
  echo "Running script: $url"
  output=$(curl -fsSL $url 2>&1)
  if [[ $output =~ $substring ]]; then
    if [ -n "$pat" ]; then
      curl -X GET -H "Authorization: Bearer $pat" -H "Content-Type: application/json" -fsSL $url | bash -s $args
    else
      curl -fsSL $url | bash -s $args
    fi
  else
    echo "Error: $output"
    sleep 1
    execute
  fi
}
execute
