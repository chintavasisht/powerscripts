Set-AzureRmContext –SubscriptionName ‘vasisht1'

$keyvaultname = ‘mykeyvault’

$rgName = 'newencryption'


$location = 'eastus2'

$keyname= '[unique key name]'

$secretname = '[any distinct secret name]'

New-AzureRmKeyVault –VaultName $keyvaultname –ResourceGroupName $rgName –Location $location

$key = Add-AzureKeyVaultKey –VaultName $keyvaultname –Name ‘Name of the key’ –Destination ‘Software’

#$secretvalue = ConvertTo-SecureString ‘mypassword’ –AsPlainText –Force

#$secret = Set-AzureKeyVaultSecret –VaultName $keyvaultname –Name $keyname –SecretValue $secretvalue

Set-AzureRmKeyVaultAccessPolicy -VaultName $keyvaultname -ResourceGroupName $rgName –EnabledForDiskEncryption


$aadclientsecret = ‘SecretForEncryption’

$aaplicationName = '[unique application name]'

$aadApplication = New-AzureRmADApplication –DisplayName $aaplicationName –HomePage ‘http://uniquehomepageurl’ –IdentifierUris ‘https://uniqueidentifierurl’ –Password $aadclientsecret

$aadClientID = $aadApplication.ApplicationId


$servicePrincipal = New-AzureRmADservicePrincipal –ApplicationId $aadClientID

Set-AzureRMKeyVaultAccesspolicy –VaultName $keyvaultname –ServicePrincipalname $aadClientID   -PermissionsToKey all –PermissionsToSecrets all

$vm= Get-AzureRmVM


$vmname = $vm.name[0]

Set-AzureRmVMDiskEncryptionExtension –ResourceGroupName $rgName –VMName $vmname –AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaulturl -DiskEncryptionKeyVaultId 
$keyVaultResourceId