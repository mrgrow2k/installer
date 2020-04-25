# installer
 Multi masternode installer script

## Installation:
Script start.sh contains some useful tools to install, analize and repair your masternode from a command line menu.
```
wget https://raw.githubusercontent.com/mrgrow2k/installer/master/start.sh -O start.sh && chmod 755 start.sh && ./start.sh
```

## Commands:
Start: 	
```
./bin/ragnarokd_mn1.sh
```
Stop:	
```
./bin/ragnarok-cli_mn1.sh stop
```
Status:	
```
./bin/ragnarok-cli_mn1.sh masternode status
```
Debug:	
```
cat ~/.ragnarok_mn1/debug.log
```
### Check masternode status on server side
Command:
```
./bin/ragnarok-cli_mn1.sh startmasternode local false
```
– A message “masternode successfully started” should appear
***
