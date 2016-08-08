#Copy VHD from one Storage to another storage
#VHD Name - Copy from Storage account
$diskName = "DiskName.VHD"
$diskBlob = $diskName
#backup VHD Name
$backupDiskBlob = "Backup-Disk.vhd"
#Enter Storage account Name
$storageAccount="Storage account Name"
Stop-AzureVM -ServiceName $cloudservice -Name $vmname -Force -Verbose
#Storage Key from Azure Portal -> Go to Storage -> Click on Storage and below you will find Manage Access Keys, Copy and Paste below
$storageAccountKey="Storage Account Key"
$ctx = New-AzureStorageContext -StorageAccountName $storageAccount -StorageAccountKey $storageAccountKey
$blobCount = Get-AzureStorageBlob -Container vhds -Context $ctx | where { $_.Name -eq $backupDiskBlob } | Measure | % { $_.Count }

if ($blobCount -eq 0)
{
#Copying the VHD Blob for Backup using $backupDiskBlob name above
  $copy = Start-AzureStorageBlobCopy -SrcBlob $diskBlob -SrcContainer "vhds" -DestBlob $backupDiskBlob -DestContainer "vhds" -Context $ctx -Verbose
  $status = $copy | Get-AzureStorageBlobCopyState 
  $status 

  While($status.Status -eq "Pending"){
    $status = $copy | Get-AzureStorageBlobCopyState 
    Start-Sleep 10
    $status
   }
 }

