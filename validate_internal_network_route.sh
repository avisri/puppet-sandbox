#!/bin/bash 

echo 'for some reason my virtualbox would not add this route 
on its own and i had to add it manually  
$ifconfig vboxnet0
vboxnet0: flags=8943<UP,BROADCAST,RUNNING,PROMISC,SIMPLEX,MULTICAST> mtu 1500
	ether 0a:00:27:00:00:00
	inet 172.16.32.1 netmask 0xffffff00 broadcast 172.16.32.255

After adding the route it showed this:
$ netstat -nr | grep 172.16.32
172.16.32/24       link#13            UCSc            3        0 vboxnet
'
echo
echo
echo 'Your result ---- '
netstat -nr | grep  172.16.32 ||  ( sudo route -nv add -net '172.16.32'  -interface vboxnet0  && netstat -nr | grep  172.16.32 ) 
