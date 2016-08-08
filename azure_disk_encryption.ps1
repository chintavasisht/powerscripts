login-azurermaccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionName 'Phani US'
Get-AzureRmResourceGroup 
New-AzureRmKeyVault –VaultName 'newvaskeyvault' –ResourceGroupName ‘scdpmressgrp’ –Location 'East US'
$keyvaultname = 'newvaskeyvault'
$key = Add-AzureKeyVaultKey –VaultName $keyvaultname –Name ‘vaskey’ –Destination ‘Software’
$key.key.kid 
$secretvalue = ConvertTo-SecureString ‘mypassword’ –AsPlainText –Force
$secret = Set-AzureKeyVaultSecret –VaultName $keyvaultname –Name ‘vassecret’ –SecretValue $secretvalue
$secret.Id
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyvaultname -ResourceGroupName 'scdpmressgrp' –EnabledForDiskEncryption
$aadclientsecret = ‘vasclientsecret’
$aadApplication = New-AzureRmADApplication –DisplayName ‘vasadapplication’     –HomePage ‘http://vasadapplication’ –IdentifierUris ‘https://vasadapplication’ –Password $aadclientsecret
$aadApplication.ApplicationId
$aadclientID = $aadApplication.ApplicationId
$servicePrincipal = New-AzureRmADservicePrincipal –ApplicationId $aadClientID
Set-AzureRMKeyVaultAccesspolicy –VaultName $keyvaultname –ServicePrincipalname $aadClientID   -PermissionsToKey all –PermissionsToSecrets all
$keyvault = Get-AzureRmKeyVault –VaultName $keyvaultname –ResourceGroupName ‘scdpmressgrp’
$diskEncryptionKeyVaulturl = $keyVault.VaultUri
$keyVaultResourceId = $keyvault.resourceId
$vm = Get-AzureRmVM
$vm.name
$vmname = $vm.name[3]
Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName 'scdpmressgrp' -VMName $vmname -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaulturl -DiskEncryptionKeyVaultId $keyVaultResourceId