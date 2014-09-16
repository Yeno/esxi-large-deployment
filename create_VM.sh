#!/bin/sh

#paratmers: machine name (required), CPU (number of cores), RAM (memory size in MB), HDD Disk size (in GB), ISO (Location of ISO image, optional)
#default params: CPU: 2, RAM: 4096, DISKSIZE: 20GB, ISO: 'blank'

phelp() {
	echo "Script for automatic Virtual Machine creation for ESX"
	echo "Usage: ./create.sh options: n <|c|i|r|s>"
	echo "Where n: Name of VM (required), c: Number of virtual CPUs, i: location of an ISO image, r: RAM size in MB, s: Disk size in GB, t: Network interface number ie Interface50, x: start range, y: end range, d: delay, a: datastore name"
	echo "Default values are: CPU: 2, RAM: 4096MB, HDD-SIZE: 20GB"
}

#Setting up some of the default variables
CPU=1
RAM=1024
SIZE=4
ISO=""
FLAG=true
ERR=false
STARTRANGE=1
ENDRANGE=1
INTERFACE=1
DELAY=8
DATASTORE=""

#Error checking will take place as well
#the NAME has to be filled out (i.e. the $NAME variable needs to exist)
#The CPU has to be an integer and it has to be between 1 and 32. Modify the if statement if you want to give more than 32 cores to your Virtual Machine, and also email me pls :)
#You need to assign more than 1 MB of ram, and of course RAM has to be an integer as well
#The HDD-size has to be an integer and has to be greater than 0.
#If the ISO parameter is added, we are checking for an actual .iso extension
while getopts n:c:i:r:s:x:y:t:d:a: option
do
        case $option in
                n)
					NAME=${OPTARG};
					FLAG=false;
					if [ -z $NAME ]; then
						ERR=true
						MSG="$MSG | Please make sure to enter a VM name."
					fi
					;;
                c)
					CPU=${OPTARG}
					if [ `echo "$CPU" | egrep "^-?[0-9]+$"` ]; then
						if [ "$CPU" -le "0" ] || [ "$CPU" -ge "32" ]; then
							ERR=true
							MSG="$MSG | The number of cores has to be between 1 and 32."
						fi
					else
						ERR=true
						MSG="$MSG | The CPU core number has to be an integer."
					fi
					;;
				i)
					ISO=${OPTARG}
					if [ ! `echo "$ISO" | egrep "^.*\.(iso)$"` ]; then
						ERR=true
						MSG="$MSG | The extension should be .iso"
					fi
					;;
                r)
					RAM=${OPTARG}
					if [ `echo "$RAM" | egrep "^-?[0-9]+$"` ]; then
						if [ "$RAM" -le "0" ]; then
							ERR=true
							MSG="$MSG | Please assign more than 1MB memory to the VM."
						fi
					else
						ERR=true
						MSG="$MSG | The RAM size has to be an integer."
					fi
					;;
                s)
					SIZE=${OPTARG}
					if [ `echo "$SIZE" | egrep "^-?[0-9]+$"` ]; then
						if [ "$SIZE" -le "0" ]; then
							ERR=true
							MSG="$MSG | Please assign more than 1GB for the HDD size."
						fi
					else
						ERR=true
						MSG="$MSG | The HDD size has to be an integer."
					fi
					;;
					
				x)
					STARTRANGE=${OPTARG}
					
					if [ `echo "$STARTRANGE" | egrep "^-?[0-9]+$"` ]; then
						if [ "$STARTRANGE" -le "0" ]; then
							ERR=true
							MSG="$MSG | >0."
						fi
					else
						ERR=true
						MSG="$MSG | The start range number has to be an integer."
					fi
					;;
					
				y)
					ENDRANGE=${OPTARG}					
								
					if [ `echo "$ENDRANGE" | egrep "^-?[0-9]+$"` ]; then
						if [ "$ENDRANGE" -le "0" ]; then
							ERR=true
							MSG="$MSG | >0."
						fi
					else
						ERR=true
						MSG="$MSG | The end range number has to be an integer."
					fi
					;;
				t)
					INTERFACE=${OPTARG}
					if [ `echo "$INTERFACE" | egrep "^-?[0-9]+$"` ]; then
						if [ "$INTERFACE" -le "0" ]; then
							ERR=true
							MSG="$MSG | >0."
						fi
					else
						ERR=true
						MSG="$MSG | The Interface id has to be an integer."
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
				a)
					DATASTORE=${OPTARG}
				
					if [ -z $DATASTORE ]; then
						ERR=true
						MSG="$MSG | Please make sure to enter a datastore name."
					fi
					;;
				\?) echo "Unknown option: -$OPTARG" >&2; phelp; exit 1;;
        		:) echo "Missing option argument for -$OPTARG" >&2; phelp; exit 1;;
        		*) echo "Unimplemented option: -$OPTARG" >&2; phelp; exit 1;;
        esac
done

if $FLAG; then
	echo "You need to at least specify the name of the machine with the -n parameter."
	exit 1
fi

if $ERR; then
	echo $MSG
	exit 1
fi


for TURRETNUMBER in `seq $STARTRANGE $ENDRANGE`
do

if [ $TURRETNUMBER -lt 1000 ] && [ $TURRETNUMBER -ge 100 ]
then TEMPNAME="${NAME}0${TURRETNUMBER}"
elif [ $TURRETNUMBER -lt 100 ] && [ $TURRETNUMBER -ge 10 ]
then TEMPNAME="${NAME}00${TURRETNUMBER}"
elif [ $TURRETNUMBER -lt 10 ]
then TEMPNAME="${NAME}000${TURRETNUMBER}"
else TEMPNAME=$NAME$TURRETNUMBER
fi

	if [ -d "$TEMPNAME" ]; then
		echo "Directory - ${TEMPNAME} already exists, can't recreate it."
		exit
	fi

	#Creating the folder for the Virtual Machine
	mkdir /vmfs/volumes/${DATASTORE}/${TEMPNAME}

	#Creating the actual Virtual Disk file (the HDD) with vmkfstools
	vmkfstools -c "${SIZE}"G -a ide /vmfs/volumes/${DATASTORE}/${TEMPNAME}/${TEMPNAME}.vmdk

	#Creating the config file
	touch /vmfs/volumes/${DATASTORE}/${TEMPNAME}/${TEMPNAME}.vmx

	#writing information into the configuration file
	cat << EOF > /vmfs/volumes/${DATASTORE}/${TEMPNAME}/${TEMPNAME}.vmx

	config.version = "8"
	virtualHW.version = "8"
	vmci0.present = "TRUE"
	displayName = "${TEMPNAME}"
	floppy0.present = "FALSE"
	numvcpus = "${CPU}"
	memsize = "${RAM}"
	ide0:0.present = "TRUE"
	ide0:0.fileName = "${TEMPNAME}.vmdk"
	ide0:0.redo = ""
	pciBridge4.present = "TRUE"
	pciBridge4.virtualDev = "pcieRootPort"
	pciBridge4.functions = "8"
	pciBridge5.present = "TRUE"
	pciBridge5.virtualDev = "pcieRootPort"
	pciBridge5.functions = "8"
	pciBridge6.present = "TRUE"
	pciBridge6.virtualDev = "pcieRootPort"
	pciBridge6.functions = "8"
	pciBridge7.present = "TRUE"
	pciBridge7.virtualDev = "pcieRootPort"
	pciBridge7.functions = "8"
	pciBridge0.pciSlotNumber = "17"
	pciBridge4.pciSlotNumber = "21"
	pciBridge5.pciSlotNumber = "22"
	pciBridge6.pciSlotNumber = "23"
	pciBridge7.pciSlotNumber = "24"
	ethernet0.pciSlotNumber = "160"
	ethernet1.pciSlotNumber = "192"
	vmci0.pciSlotNumber = "32"
	ethernet0.emuRxMode = "1"
	ethernet0.virtualDev = "e1000"
	ethernet0.networkName = "Interface${INTERFACE}"
	ethernet0.addressType = "generated"
	ethernet0.present = "TRUE"
	ethernet1.virtualDev = "e1000"
	ethernet1.networkName = "Interface${INTERFACE}"
	ethernet1.addressType = "generated"
	ethernet1.emuRxMode = "1"
	ethernet1.present = "TRUE"
	ethernet1.startConnected = "FALSE"
	guestOS = "sles11"
	logging = "false" 
EOF

	#Adding Virtual Machine to VM register - modify your path accordingly!!
	MYVM=`vim-cmd solo/registervm /vmfs/volumes/${DATASTORE}/${TEMPNAME}/${TEMPNAME}.vmx`
	#Powering up virtual machine:
	#vim-cmd vmsvc/power.on $MYVM

	echo "The Virtual Machine is now setup. Your have the following configuration:"
	echo "Name: ${TEMPNAME}"
	echo "CPU: ${CPU}"
	echo "RAM: ${RAM}"
	echo "HDD-size: ${SIZE}"
	echo "Datastore: ${DATASTORE}"
	if [ -n "$ISO" ]; then
		echo "ISO: ${ISO}"
	else
		echo "No ISO added."
	fi
	echo "NETWORK INTERFACE: Interface${INTERFACE}"
	echo "----------------------------------------"

sleep $DELAY
	
done
	
echo "Thank you."
exit
