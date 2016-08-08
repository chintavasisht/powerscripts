Login-AzureRmAccount 
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionName "Phani US"
$VNetName = "TestVNet"
$FESSubName = "Frontend"
$BESubName = "Backend"
$GWSubName = "GatewaySubnet"
$VNetPrefix1 = "192.168.0.0/16"
$VNetPrefix2 = "10.254.0.0/16"
$FESubPrefix = "192.168.1.0/24"
$BESubPrefix = "10.254.1.0/24"
$GWSubPrefix = "192.168.0.0/24"
$VPNClientAddressPool = "172.16.201.0/24"
$RG = "TestRG"
$Location = "East US"
$DNS = "8.8.8.8"
$GWName = "GW"
$GWIPName = "GWIP"
$GWIPconfName = "gwipconf"
$P2SRootCertName = "ClientCertificateName.cer"
New-AzureRmResourceGroup -Name $RG -Location $Location
$fesub = New-AzureRmVirtualNetworkSubnetConfig -Name $FESSubName -AddressPrefix $FESubPrefix

$besub = New-AzureRmVirtualNetworkSubnetConfig -Name $BESubName -AddressPrefix $BESubPrefix

$gwsub = New-AzureRmVirtualNetworkSubnetConfig -Name $GWSubName -AddressPrefix $GWSubPrefix
New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RG -Location $Location -AddressPrefix $VNetPrefix1,$VNetPrefix2 -Subnet $fesub, $besub, $gwsub -DnsServer $DNS
$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RG
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet
$pip = Get-AzureRmPublicIpAddress -Name $GWIPName -ResourceGroupName $RG 
$ipconf = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName -Subnet $subnet -PublicIpAddress $pip
$MyP2SRootCertPubKeyBase64 = "MIIDEzCCAf+gAwIBAgIQH+SKz9bLXIlGI4tsUSLjmTAJBgUrDgMCHQUAMB4xHDAaBgNVBAMTE1Jvb3RDZXJ0aWZpY2F0ZU5hbWUwHhcNMTYwNjIyMTc1MzEzWhcNMjQwNjIyMTc1MzEyWjAgMR4wHAYDVQQDExVDbGllbnRDZXJ0aWZpY2F0ZU5hbWUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0Nr5fm+qFNJrD/pP3kY07Ol0bgO6BzuWeG7gjMrmZhAXhmyzD1dqlmzs3IKJXPVNP37KKmYWKek6SuiTd4q8LjA/mx9ETZeDhJjTE25TttXk2wswGZP3zheV+XuB7u1+SqIJzbaSbT/ldLgTlkfvr83R8+bpYvn6dMLlK1CWmFDtexPdQwqk8yrV0xvPNfeH85pAoZh4YzncBZKaNmX7SN6cNaIUjjTpWh0/ms+RzEdjdXFRUeqGaIXa5gE7X167j4Z2HitSYMUKXiqCB1agoKZJu73CMlzJ0/pENn5s9fok9d/qvufE7njQeK7s83GVpc3dxOtw+DyWR22cwfJ0zAgMBAAGjUzBRME8GA1UdAQRIMEaAENYFaHfYmOIm/MRfmgxwCz+hIDAeMRwwGgYDVQQDExNSb290Q2VydGlmaWNhdGVOYW1lghAHrKWHBYNhi0GChLJ0ucNTMAkGBSsOAwIdBQADggEBAFk9CcLDcOtzFP9OVVO39JsyuqBeklEivfE2mHIzEG1/X+PdJ2rFnkevnTB37xoT+r21cEYSukPMAhxVd00qbDcuEnzBg6bspy3xxNwzTjBe5QIXR+OJJKvaEa8X9zePkzzRB+GG6OInId4u61SigU8sYYIEhdJRE+M+ZbnAjBtQb8HLktIVTC3r0uwg1fo8oEmyXKS4GrMVC1u8uhWdJAvmrRXL+E08Cfc41G1uVnPzzKcAwu+kZRi4pSkrf0B+FPzLlsjLOkWMo5ed3RnMfzbN9h9OHMsVpv6WMWKaAUh7XVraMZbS23pGsXCNaangRa+ffsFekH6/brHZVlLBJic="
$p2srootcert = New-AzureRmVpnClientRootCertificate -Name $P2SRootCertName -PublicCertData $MyP2SRootCertPubKeyBase64
New-AzureRmVirtualNetworkGateway -Name $GWName -ResourceGroupName $RG -Location $Location -IpConfigurations $ipconf -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku Standard -VpnClientAddressPool $VPNClientAddressPool -VpnClientRootCertificates $p2srootcert
Get-AzureRmVpnClientPackage -ResourceGroupName $RG -VirtualNetworkGatewayName $GWName -ProcessorArchitecture Amd64