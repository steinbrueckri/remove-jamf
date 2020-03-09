# REMOVE JAMF RESTRICTIONS ON MAC

## REMOVE ONLY RESTRICTIONS

`sudo jamf removeMDMProfile` removes all restrictions

`sudo jamf manage` brings back all restrictions and profiles

## REMOVE ALL RESTRICTIONS AND DISABLE JAMF BINARIES WHILE KEEPING YOUR ACCESS TO VPN AND OTHER SERVICES

`sudo jamf removeMDMProfile` removes all restrictions

`cd /usr/local/jamf/` this is where jamf binary lives

`mkdir backup`

`mv jamf jamfAgent backup/` keeping a backup of binaries if something goes wrong

Now you need to create this file at `/usr/local/jamf/jamf`

Add the following content

```
#!/bin/sh
echo 'dummy' > /dev/null
```

finally give it the permission

`sudo chmod a+x /usr/local/jamf/jamf`

Thats it you are done!

restart your laptop and you will no longer be tracked and no restrictions but you will have access to all vpn services

Incase you want to go back just restore original binaries and do

`sudo jamf manage`
