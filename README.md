# backupScript

Simple backup script I am using to backup encrypted backups to my NAS. 
Makes it easier to do more fun changes on my PC without breaking things.

Things I did:
openssl was easier to use than GPG to just encrypt a file  
I couldn't use scp to send the files to my NAS so thats why I used rsync  
pigz was used because tar is really slow  to archive files  
