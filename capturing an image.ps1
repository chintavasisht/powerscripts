#Capture an Azure VM to an images section with timestamp
$cloudservice="finalcademo"
$vmName="centosimagedemo"
#Recommend to stop first
Stop-AzureVM -ServiceName $cloudservice -Name $vmName
$currentTimeStamp = get-date -f MM-dd-yyyy-HH-mm-ss
$currentTimeStamp = $cloudservice+ "-" +$vmName + "-"+$currentTimeStamp
$currentTimeStamp
#Save the specified virtual machine to a new image.
#Because this VM has NOT had SYSPREP run I use OSState Specialized but if it had been SYSPREP'd I would use -OSState Generalized
Save-AzureVMImage -ServiceName $cloudservice -Name $vmName -ImageName $currentTimeStamp -OSState Generalized
#this commmand will save a copy in images section with a timestamp say like: vm00002-10-16-2015-21-21-05 - VM Name-MM-dd-yyyy-HH-mm-ss
