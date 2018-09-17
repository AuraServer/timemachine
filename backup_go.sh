#!/bin/bash -xe

backup_dir=$(realpath .)

if [[ ! $UID == 0 ]];then
  echo "please run as root"
  exit 1
fi

if [[ ! -d ${backup_dir} ]];then
  echo "cannot connect samba"
  exit 1
fi

id=$(date +"%Y%m%d-%H%M%S")
proj_dir=$(dirname $0)

target_vg=ubuntu-vg
target_lv=root
target_dev=/dev/${target_vg}/${target_lv}

snap_vg=$target_vg
snap_lv=snap_$id
snap_dev=/dev/${snap_vg}/${snap_lv}
snap_mount_dir=/snapshot/${snap_lv}

if [[ -z $(lvs | grep ${snap_lv}) ]];then
  lvcreate -L 30G -s -n $snap_lv ${target_dev}
fi

mkdir -p ${snap_mount_dir}

if [[ -z $(mount | grep ${snap_mount_dir}) ]];then
  mount ${snap_dev} ${snap_mount_dir}
fi


echo "start timemachine at $(date)"
timemachine --verbose ${snap_mount_dir}/. ${backup_dir} -- -aAXHS --exclude-from=${proj_dir}/exclude.list
#timemachine --verbose ${snap_mount_dir}/. ${backup_dir} -- -aAXHS --progress --exclude-from=${proj_dir}/exclude.list
echo "end timemachine at $(date)"

umount ${snap_dev}

rm -r ${snap_mount_dir}

lvremove -f ${snap_dev}

