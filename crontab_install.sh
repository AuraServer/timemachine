#!/bin/bash
if [[ $UID != 0 ]];then
  echo "please run as root"
  exit 1
fi

script_dir=$(pwd)/backup_go.sh
if [[ ! -f $script_dir ]];then
  echo "$script_dir not found"
  exit 1
fi

line="0 0 * * * $script_dir"
all=$(crontab -l)
all=$(uniq <(echo -e "$all\n$line"))
(echo "$all")| crontab -
