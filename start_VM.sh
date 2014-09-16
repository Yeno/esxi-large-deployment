#!/bin/sh

#This script start a range of VM

phelp() {
	echo "Script for automatic startup of Virtual Machine for ESX"
	echo "Usage: ./start_VM.sh options: x|y <|d|>"
}

FLAG=true
ERR=false
STARTRANGE=1
ENDRANGE=20
DELAY=8

while getopts x:y:d: option
do
        case $option in
			x)
			STARTRANGE=${OPTARG};
			FLAG=false;
					if [ -z $STARTRANGE ]; then
						ERR=true
						MSG="$MSG | Please enter a range."
					fi
					;;
			y)
			ENDRANGE=${OPTARG};
			FLAG=false;
					if [ -z $ENDRANGE ]; then
						ERR=true
						MSG="$MSG | Please enter a range."
					fi
				;;
			d) 
			DELAY=${OPTARG}
					if [ `echo "$DELAY" | egrep "^-?[0-9]+$"` ]; then
						if [ "$DELAY" -le "0" ]; then
							ERR=true
							MSG="$MSG | Not 0 ; default 8."
						fi
					else
						ERR=true
						MSG="$MSG | The delay has to be an integer."
					fi
					;;
			\?) echo "Unknown option: -$OPTARG" >&2; phelp; exit 1;;
        	:) echo "Missing option argument for -$OPTARG" >&2; phelp; exit 1;;
        	*) echo "Unimplemented option: -$OPTARG" >&2; phelp; exit 1;;
        esac
done

if $FLAG; then
	echo "You need to specify a range of VMs to start"
	exit 1
fi

if $ERR; then
	echo $MSG
	exit 1
fi

for VMNUM in `seq $STARTRANGE $ENDRANGE` 
do
	echo "Virtual Machine $VMNUM"

if [ $VMNUM -lt 1000 ] && [ $VMNUM -ge 100 ]
then VMNAME="VM_0$VMNUM"
elif [ $VMNUM -lt 100 ] && [ $VMNUM -ge 10 ]
then VMNAME="VM_00$VMNUM"
elif [ $VMNUM -lt 10 ]
then VMNAME="VM_000$VMNUM"
else VMNAME=$NAME$VMNUM
fi

	VMID=$(vim-cmd vmsvc/getallvms | grep "$VMNAME" | awk '{print $1}')
	STATE=$(vim-cmd vmsvc/power.getstate "$VMID" | grep "off")

if [ "$STATE" == "Powered off" ]
then
vim-cmd vmsvc/power.on "$VMID"
echo "$VMNAME is ON"
sleep $DELAY
fi
		

done

exit
