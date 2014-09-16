esxi-large-deployment
=====================

Scripts to deploy and manage a lot of VMs on a (free-licensed) Esxi


How to use ESXI Scripts
-------------------------
To be able to execute a script on an ESXI, edit the file /etc/ssh/sshd_config
set PasswordAuthentication no to yes
you can use the following command :
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
create_VM.sh
Important:
This script need to be located in /vmfs/volumes/datastore1/
and be executable by root : chmod +x create_VM.sh
This script create a Virtual Machines for each turret in a range
Options
-n: name of VMs before the number 000x-y (needed)
-t: network interface number : the interface name need to be InterfaceXX with XX=t (needed)
-x: Start of the range of VM to create (needed)
-y: End of the range of VM to create (needed)
-d: Delay between each VM creation (default: 8seconds)
Exemple:
./create_VM.sh -VM_ -t50 -x1 -y10 -d6 will create 10 virtual VM with network interface Interface50, with a 6 seconds delay between each creation
-------------------------
start_VM.sh
This script start a range of VM in a user-defined range
Options:
-x: Start of the range of VM to start: number of turret (VM_xxxx) (needed)
-y: End of the range of VM to start: number of turret (VM_yyyy) (needed)
Exemple:
./start_VM.sh -x1 -y12 will start every VM between VM_0001 and VM_0012
-------------------------
shut_VM.sh
This script shut a range of VM in a user-defined range
Options:
-x: Start of the range of VM to shut: number of turret (VM_xxxx) (needed)
-y: End of the range of VM to shut: number of turret (VM_yyyy) (needed)
Exemple:
./shut_VM.sh -x1 -y12 will shut every VM between VM_0001 and VM_0012
