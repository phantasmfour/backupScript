#!/bin/bash

# Capture the start time
start_time=$(date +%s)

# Make sure the backups directory exists
if [ ! -d "/backups" ]; then
  echo "The backup directory does not exist. Creating it now"
  mkdir /backups
fi

# Make sure this exists as well to store recents so rsync is a little more efficient
if [ ! -d "/backups/current" ]; then
  echo "The backup current directory does not exist. Creating it now"
  mkdir /backups/current
fi


# Backup app list installed
dpkg --get-selections > /backups/current/appList.txt

# Backup important directories
backupDirs=("/home" "/etc" "/var/spool" "/usr/local")
for directory in "${backupDirs[@]}"; do
    echo "Rsyncing Dir $directory"
    rsync -a --exclude '.*' $directory /backups/current/
done

# Pigz will thread the tar since it is really slow
echo "Archiving Backup Files"
tar -cf - /backups/current | pigz -c -p 12 > /backups/currentBackup.tar.gz
#tar cfz /backups/currentBackup.tar.gz /backups/current

# Make your backup phrase. I would suggest changing the perms to root only reading and owning. If you already have root on my system you can see these files already.
backupPhrase=$(</backups/backupPhrase)

echo "Encrypt the backup with passphrase"
openssl enc -aes-256-cbc -in /backups/currentBackup.tar.gz -out /backups/currentBackup.enc -k $backupPhrase

# Send it to the nas
echo "Rsync to nas"
rsync -av -e ssh /backups/currentBackup.enc backups@nas::Backup/backups/

# Remove old backup tar's
echo "Removing old backups"
rm /backups/currentBackup.tar.gz
rm /backups/currentBackup.enc

# Capture the end time
end_time=$(date +%s)
# Calculate the runtime
runtime=$((end_time - start_time))
# Print the total runtime
echo "Script completed in $runtime seconds."

# Created a new user on the nas. Added them as an admin to ssh, then uploaded the private key so I could rsync without issue. 
# then jsut enabled rsync perms on them and gave them access to the directory.
# Cannot use scp easily so rsync was second best even though it really does not give me anything since my backup is encrypted. 