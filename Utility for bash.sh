#!/bin/bash

show_help() {
  echo "Использование: $0 [OPTIONS]"
  echo ""
  echo "OPTIONS:"
  echo " -u, --users              Показать перечень пользователей и их домашних директорий"
  echo " -p, --processes          Показать перечень запущенных процессов"
  echo " -h, --help               Показать справку"
  echo " -l PATH, --log PATH      Путь для записи вывода"
  echo " -e PATH, --errors PATH   Путь для записи ошибок"
}

# Вывод пользователей и директорий
get_users(){
  local output
  output=$(awk -F: '{print $1, $6}' /etc/passwd | sort)
  echo "$output"
}

# Вывод списка процессов
get_processes(){
  local output
  output=$(ps -eo pid,cmd --sort pid)
  echo "$output"
}

log_file=""
error_file=""
mode=""

while [["$1" != ""]]; do
  case $1 in
    -u | --users )  mode="users"
                    ;;
    -p | --processes ) mode="processes"
                       ;;
    -l )                shift
                       log_file="$1"
                       ;;
    -e )                shift
                       error_file="$1"
                       ;;
    -h | --help )      usage
                       exit
                       ;;
    * )                echo "Неизвестный параметр: $1"
                       usage
                       exit 1
                       ;;
  esac
  shift
done

if [[ -z "$mode"]]; then
  echo "Ошибка: Необходимо выбрать опцию"
  usage
  exit 1
fi

if [[ -n "$log_file"]]; then
  exec 2>"$error_file"
fi

case $mode in
  users) get_users
         ;;
  processes) get_processes
             ;;
esac