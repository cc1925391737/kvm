#!/bin/bash

# Create configuration file.
if [ -f kvm_vm_backup.conf ]; then
        cat<<EOF
POOLDIR=""
BACKUPDIR="\$POOLDIR/Backups"
EOF
fi

# Load variables
CONFFILE="./kvm_vm_backup.conf"
source kvm_vm_backup.conf
IMG_FILE="$1"
NOM_VM="$(basename ${IMG_FILE} .img)"

increment_renaming(){
        TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
        NOM_INC="${NOM_VM}_${TIMESTAMP}"

        mv ${NOM_VM}.img ${NOM_INC}.inc.img
}


        ## Rename snapshot.
        increment_renaming

        ## Back-up snapsot using hard link.
        ln ${NOM_INC}.img Backups/${NOM_INC}.inc.img

        ## Create a new snapshot using previous one as backing file.
        qemu-img create -b ${NOM_INC}.img -f qcow2 ${NOM_VM}.inc.img

        ## For non-privileged users, add read and write permisions to others.
        chmod o=rw ${NOM_VM}.img

        echo "Snapshot ${NOM_INC}.img created, a copy has been created at $PWD/Backups."

rebase(){
        echo "Rebasing the snapshots."
        # Rename snapshot.
        increment_renaming

        # Rebasing the last snapshot and backing it up as a hard link.
        qemu-img convert -O qcow2 ${NOM_INC}.img ${NOM_INC}.rebase.img
        ln ${NOM_INC}.img.rebase Backups/${NOM_INC}.rebase.img

        echo "The new base (${NOM_INC}.img.rebase) has been created."

        # Deleting old unnecesary snapshots.
        REBASE_FILE="$(ls ${NOM_VM}* | grep rebase)"
        if [ -n "${REBASE_FILE}" ]; then
                REMOVE_LIST=$(ls -l ${NOM_VM}_*.img | grep -v "rebase")
                for f in $REMOVE_LIST ; do
                        rm "$f"
                done
                NEW_BASE="$(basename ${REBASE_FILE} .rebase)"
                mv "${REBASE_FILE}" "${NEW_BASE}"
        fi

        # Creating a new snapshot with the new base as backing file.
        qemu-img create -b ${NEW_BASE} -f qcow2 ${NOM_VM}.img
        echo -e "Old snapshots have been deleted.\nA new snapshot (${NOM_VM}.img) have been created and ready to be used."
}


if [ ${COUNTER} -ge ${MAX_COUNTER} ]; then  
        rebase                                  
else
        incremental                             
fi
