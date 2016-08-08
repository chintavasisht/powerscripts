#checking the image details.
#Get-AzureVMImage -ImageName 'centosimage-centosimage-01-20-2016-22-30-55'
$svcname="trysome11"
$vnetname="demovnet"
#$imageName="finalcademo-centosimagedemo-07-19-2016-15-07-10"
$vmname="trysome11vm3"
$vmsize="Standard_A1"
$subnetName = "Subnet-1"
$availset ="createav"
#creating VM Configuration
$vm1 = New-AzureVMConfig -Name $vmname -InstanceSize $vmsize -ImageName $imageName -AvailabilitySetName $availset
#popup asking for credentials
$cred=Get-Credential -Message "Type the name and password of the initial Linux account."
#provisioning Configuration for Linux VM with user and passwork
$vm1 | Add-AzureProvisioningConfig -Linux -LinuxUser $cred.GetNetworkCredential().Username -Password $cred.GetNetworkCredential().Password
#optinoal if needed the VM in a Subnet
$vm1 | Set-AzureSubnet -SubnetNames $subnetName
#create VM command with service Name and in a specified Virtual Network
New-AzureVM –ServiceName $svcname -VMs $vm1 -VNetName $vnetname -Location "East US"
#add a data disk to this virtual machine 
#Get-AzureVM $svcname -Name $vmname | Add-AzureDataDisk -ImportFrom -MediaLocation "https://newlinuxstore.blob.core.windows.net/vhds/finalcademo-centosimagedemo-newdatadisk-2016-7-19-14-6-36-636-0.vhd" -DiskLabel "main" -LUN 0 | Update-AzureVM



#$vms = Get-AzureVM -Name $vmName -ServiceName $svcname
 
# get Disk Location from VM
#$MediaLocation = Get-AzureDataDisk -VM $vms