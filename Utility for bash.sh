#!/bin/bash

# Вывод пользователей и директорий
get_users(){
  awk -F: '$3 >= 1000 {print $1 "\t" $6}' /etc/passwd | sort
}

# Вывод списка процессов
get_processes(){
  ps -eo pid,cmd,start --sort=pid
}

show_help() {
  cat <<EOF
 $0
Опции:
  -u, --users                   Вывод списка пользователей и их домашних директорий
  -p, --processes               Вывод списка процессов, отсортированных по ID
  -h, --help                    Вывод справки
  -l PATH, --log PATH           Запись вывода в файл по указанному пути
  -e PATH, --errors PATH        Запись ошибок в файл по указанному пути

EOF
    exit 0
}

main() {
  local log_path=""
  local error_path=""
  local action=""

  TEMP=$(getopt -o upl:e:h --long users,processes,log:,errors:,help -n "$0" -- "$@")
  if [[ $? -ne 0]]; then
    echo "Ошибка: неверные параметры" >$2
    exit 1
  fi
  eval set -- "$TEMP"

  while true; do
    case "$1" in
      -u|--users)
        action="users"
        shift
        ;;
      -p|--processes)
        action="processes"
        shift
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      -l|--log)
        log_path="$2"
        shift 2
        ;;

      -e|--errors)
        errors_path="$2"
        ;;
      --)
        shift
        break
        ;;
      *)
        echo "Ошибка: неизвестный параметр $1" >&2
        exit 1
        ;;
    esac
  done

  if [[ -n "$error_path "]]; then
    validate_path "$error_path" || exit 1
    exec 2>"$error_path"
  fi

  case "$action" in
    users)
      get_users
      ;;
    processes)
      get_processes
      ;;
    *)
      echo "Ошибка: действие не задано" >$2
      show_help
      exit 1
      ;;
  esac
}

main "$@"
