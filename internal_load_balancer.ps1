#Create a internal load balancer
$svc="secureapi-asm-12639"
$ilb="secureapi"
Add-AzureInternalLoadBalancer -ServiceName $svc -InternalLoadBalancerName $ilb 
#Add endpoints to the internal load balancing instance
$prot="tcp"
$locport=80
$pubport=80
#endpoint name
$epname="TCP-80-80"
$lbsetname="ilbset"

#Add endpoints to the virtual machines
$vmname="secureapi-asm-1"
Get-AzureVM –ServiceName $svc –Name $vmname | Add-AzureEndpoint -Name $epname -Protocol $prot -PublicPort $pubport -LocalPort $locport -LbSetName $lbsetname  -ProbePort 80 -ProbeProtocol http -ProbePath '/' | Update-AzureVM

$epname="TCP-1433-1433-2"
$vmname="DB2"
Get-AzureVM –ServiceName $svc –Name $vmname | Add-AzureEndpoint -Name $epname -LbSetName $lbsetname -Protocol $prot -LocalPort $locport -PublicPort $pubport –DefaultProbe -InternalLoadBalancerName $ilb | Update-AzureVM