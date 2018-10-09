#!/bin/bash -xe

if [[ ! $UID == 0 ]];then
  echo "please run as root"
  exit 1
fi

id=$(date +"%Y%m%d-%H%M%S")
proj_dir=$(realpath $(dirname $0))
backup_dir=${proj_dir}/data

target_vg=ubuntu-vg
target_lv=root
target_dev=/dev/${target_vg}/${target_lv}

snap_vg=$target_vg
snap_lv=snap_$id
snap_dev=/dev/${snap_vg}/${snap_lv}
snap_mount_base=/snapshot
snap_mount_dir=${snap_mount_base}/${snap_lv}

# clean this
cleanup(){
  umount ${snap_dev}
  rm -d ${snap_mount_dir}
  lvremove -f ${snap_dev}
}
trap cleanup EXIT

# clean old
for old_snap in $(ls $snap_mount_base);do
  umount $snap_mount_base/$old_snap
  rm -d $snap_mount_base/$old_snap
done
for old_snap in $(ls /dev/ubuntu-vg/snap*);do
  lvremove -f $old_snap
done

mkdir -p $backup_dir

if [[ -z $(lvs | grep ${snap_lv}) ]];then
  lvcreate -L 30G -s -n $snap_lv ${target_dev}
fi

mkdir -p ${snap_mount_dir}

if [[ -z $(mount | grep ${snap_mount_dir}) ]];then
  mount ${snap_dev} ${snap_mount_dir}
fi


echo "start timemachine at $(date) -> ${backup_dir}"
timemachine --verbose ${snap_mount_dir}/. ${backup_dir} -- -aAXHS --exclude-from=${proj_dir}/exclude.list
#timemachine --verbose ${snap_mount_dir}/. ${backup_dir} -- -aAXHS --progress --exclude-from=${proj_dir}/exclude.list
echo "end timemachine at $(date) -> ${backup_dir}"

