Login-AzureRmAccount
$SubscriptionName = "Phani US"
$ResourceGroupName = "asrtestgrp"
$Geo = "East US"
$Vaultname = "asrtestvault"
$Storageaccnt = "storageaccountname"
$Vnet = "Virtual network Name" 
Select-AzureRmSubscription -SubscriptionName $SubscriptionName
Get-AzureRmResourceProvider -ProviderNamespace Microsoft.RecoveryServices
Get-AzureRmResourceProvider -ProviderNamespace Microsoft.SiteRecovery
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Geo  
$vault = New-AzureRmRecoveryServicesVault -Name $Vaultname -ResourceGroupName $ResourceGroupName -Location $Geo
Set-AzureRmSiteRecoveryVaultSettings -ARSVault $vault

#Specify site friendly name
$sitename = "MySite"         
New-AzureRmSiteRecoverySite -Name $sitename
Get-AzureRmSiteRecovery

#Generate and Download a Site registration key
$Path = "C:\"
$SiteIdentifier = Get-AzureRmSiteRecoverySite -Name $sitename | Select -ExpandProperty SiteIdentifier
Get-AzureRmRecoveryServicesVaultSettingsFile -Vault $vault -SiteIdentifier $SiteIdentifier -SiteFriendlyName $sitename -Path $Path

#Download the provider from Microsoft. Once after downloading, run the installer and at the end of installation continue to the registration step. When prompted, provide the downloaded site registration key, and complete registration of the Hyper-V host to the site.
https://aka.ms/downloaddra

#Verify that the Hyper-V host is registered to the site 
$server =  Get-AzureRmSiteRecoveryServer -FriendlyName $server-friendlyname

#Create a replication policy
$ReplicationFrequencyInSeconds = "300";     #options are 30,300,900
$PolicyName = “replicapolicy”
$Recoverypoints = 6                 #specify the number of recovery points
$storageaccountID = Get-AzureRmStorageAccount -Name $Storageaccnt -ResourceGroupName $ResourceGroupName | Select -ExpandProperty Id

$PolicyResult = New-AzureRmSiteRecoveryPolicy -Name $PolicyName -ReplicationProvider “HyperVReplicaAzure” -ReplicationFrequencyInSeconds $ReplicationFrequencyInSeconds  -RecoveryPoints $Recoverypoints -ApplicationConsistentSnapshotFrequencyInHours 1 -RecoveryAzureStorageAccountId $storageaccountID

#Get the Protection container corresponding to the site
$protectionContainer = Get-AzureRmSiteRecoveryProtectionContainer

#Associate the container with the Replication policy
$Policy = Get-AzureRmSiteRecoveryPolicy -FriendlyName $PolicyName
$associationJob  = Start-AzureRmSiteRecoveryPolicyAssociationJob -Policy $Policy -PrimaryProtectionContainer $protectionContainer

#Enable protection of virtual machines
$VMFriendlyName = "VM Name"                    #Name of the VM you want to protect
$protectionEntity = Get-AzureRmSiteRecoveryProtectionEntity -ProtectionContainer $protectionContainer -FriendlyName $VMFriendlyName

#Start protection 
$Ostype = "Windows"                                 # "Windows" or "Linux"
$DRjob = Set-AzureRmSiteRecoveryProtectionEntity -ProtectionEntity $protectionEntity -Policy $Policy -Protection Enable -RecoveryAzureStorageAccountId $storageaccountID  -OS $OStype -OSDiskName $protectionEntity.Disks[0].Name

#Check if protection has finished successfully
Get-AzureRmSiteRecoveryJob -Job $DRjob
$DRjob | Select-Object -ExpandProperty State
$DRjob | Select-Object -ExpandProperty StateDescription

#Update recovery properties like the VM roles size, the VNet to which the NIC of the VM should be attached upon failover
$nw1 = Get-AzureRmVirtualNetwork -Name $Vnet -ResourceGroupName "MyRG"
$VMFriendlyName = "Name of VM post failover"
$VM = Get-AzureRmSiteRecoveryVM -ProtectionContainer $protectionContainer -FriendlyName $VMFriendlyName

$UpdateJob = Set-AzureRmSiteRecoveryVM -VirtualMachine $VM -PrimaryNic $VM.NicDetailsList[0].NicId -RecoveryNetworkId $nw1.Id -RecoveryNicSubnetName $nw1.Subnets[0].Name
$UpdateJob = Get-AzureRmSiteRecoveryJob -Job $UpdateJob
$UpdateJob

#Now run the TEST FAILOVER on the protection group
$nw = Get-AzureRmVirtualNetwork -Name "TestFailoverNw" -ResourceGroupName "MyRG" #Specify Azure vnet name and resource group

$protectionEntity = Get-AzureRmSiteRecoveryProtectionEntity -FriendlyName $VMFriendlyName -ProtectionContainer $protectionContainer

$TFjob = Start-AzureRmSiteRecoveryTestFailoverJob -ProtectionEntity $protectionEntity -Direction PrimaryToRecovery -AzureVMNetworkId $nw.Id
$TFjob = Resume-AzureRmSiteRecoveryJob -Job $TFjob