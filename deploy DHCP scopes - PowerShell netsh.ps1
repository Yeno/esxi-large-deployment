# DHCP Scope deployment
#
# This script will create a DHCP scope CLn for each cluster between 10.10.1.0 and 10.10.7.255 with 27 netmask
# Parameters :
# iprange: 10.10.x.x(+1) to 10.10.x.x(+29): 29 addresses
# gateway: 10.10.x.x(+30)
# option 139

# For more subnets, edit '-le' parameters from the for instruction
# y subnet size: $i = $i + y and $endip $router
# 

$ID = 0
$cluster = 1

for($b=1;$b -le 7 ; $b++){
    for($i=0;$i -le 255){ 
		netsh Dhcp Server add scope 10.10.$b.$i 255.255.255.224 CL$cluster
        $startip = $i+1
        $endip = $i+29
        $router = $i+30
		netsh Dhcp Server Scope 10.10.$b.$i Add iprange 10.10.$b.$startip 10.10.$b.$endip 
		netsh Dhcp Server Scope 10.10.$b.$i set optionvalue 3 IPADDRESS 10.10.$b.$router 
  		netsh Dhcp Server Scope 10.10.$b.$i set optionvalue 139 STRING vendor="VENDORNAME" YOURSTRING_CL$($cluster)
		$i = $i +32
		
		$ID = $ID +1
		
		if ($ID -eq 5) { $cluster = $cluster + 1; $ID=0 }
		
    }
}


