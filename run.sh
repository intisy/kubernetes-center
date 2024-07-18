#!/bin/bash

# default options:
using_kubernetes=true
using_ui=true
using_docker_ui_test=false
gererate_password=false
using_nfs=true
yaml=false
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
    raw_args=*)
      raw_args="${1#*=}"
      shift
      ;;
    pat=*)
      pat="${1#*=}"
      shift
      ;;
    sha=*)
      sha="${1#*=}"
      shift
      ;;
    yaml=*)
      yaml="${1#*=}"
      shift
      ;;
    repo=*)
      repo="${1#*=}"
      shift
      ;;
    *)
      echo2 "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [ -n "$repo" ]; then
  read -a args_array <<< "$args"
  for element in "${args_array[@]}"
  do
    case "$element" in
      username=*)
        username="${element#*=}"
        shift
        ;;
      password=*)
        password="${element#*=}"
        shift
        ;;
      using_kubernetes=*)
        using_kubernetes="${element#*=}"
        shift
        ;;
      using_ui=*)
        using_ui="${element#*=}"
        shift
        ;;
      using_docker_ui_test=*)
        using_docker_ui_test="${element#*=}"
        shift
        ;;
      gererate_password=*)
        gererate_password="${element#*=}"
        shift
        ;;
      using_nfs=*)
        using_nfs="${element#*=}"
        shift
        ;;
      *)
        echo2 "Unknown option: $element"
        exit 1
        ;;
    esac
  done
else
  read -p "repo has to be set"  
  exit
fi

echo2() {
  echo -e "\033[0;33m$@\033[0m"
}

execute() {
  substring="#!/bin/bash"
  if [ ! -n "$sha" ]; then
    if [ -n "$pat" ]; then
      sha=$(curl -X GET -H "Authorization: Bearer $pat" -H "Content-Type: application/json" -fsSL https://api.github.com/repos/WildePizza/$repo/commits | jq -r '.[1].sha')
      echo2 "Last SHA: $sha"
    else
      echo2 "As of now you have to set the pat or sha, this will be fixed soon"
      exit 1
      # sha=$(curl -fsSL https://api.github.com/repos/WildePizza/$repo/commits | jq -r '.[1].sha')
    fi
  fi
  if [ -n "$args" ]; then
    if [ "$repo" = "docker-registry" ]; then
      raw_args="$username $password $using_kubernetes $using_ui $using_docker_ui_test $gererate_password $using_nfs"
    elif [ "$repo" = "mysql-kubernetes" ]; then
      raw_args="$password $using_nfs"
    elif [ "$repo" = "nfs-kubernetes" ]; then
      raw_args=""
    elif [ "$repo" = "kubernetes-dashboard" ]; then
      raw_args=""
    fi
    raw_args="$pat $sha $raw_args"
  fi
  if [ "$yaml" = true ]; then
    url="https://raw.githubusercontent.com/WildePizza/$repo/$sha/yaml/$action.yaml"
  else
    url="https://raw.githubusercontent.com/WildePizza/$repo/$sha/scripts/$action.sh"
  fi
  echo2 "Running script: $url"
  output=$(curl -fsSL $url 2>&1)
  if [[ $output =~ $substring ]]; then
    if [ "$yaml" = true ]; then
      kubectl apply -f $url
    else
      if [ -n "$pat" ]; then
        curl -X GET -H "Authorization: Bearer $pat" -H "Content-Type: application/json" -fsSL $url | bash -s $raw_args
      else
        curl -fsSL $url | bash -s $raw_args
      fi
    fi
  else
    echo2 "Error: $output"
    sleep 1
    execute
  fi
}
execute
