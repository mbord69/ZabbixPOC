
# stockage du chemin de téléchargement du package Zabbix agent

$version500ssl ="https://cdn.zabbix.com/zabbix/binaries/stable/5.4/5.4.5/zabbix_agent-5.4.5-windows-amd64-openssl.zip"


#Récupérer l'hostname de la machine
$serverHostname =  Invoke-Command -ScriptBlock {hostname}


# stockage de l'adresse IP du serveur dans la variable
$ServerIP = 10.34.1.41


# création du répertoire Zabbix
mkdir c:\zabbix


# Téléchargement du package depuis le serveur zabbix 
Invoke-WebRequest "$version500ssl" -outfile c:\zabbix\zabbix.zip

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

# décompression de l'archivage dans le dossier C:\Zabbix
Unzip "c:\Zabbix\zabbix.zip" "c:\zabbix" 

#Création du fichier psk contenant la clé 
ADD-content -path "C:\zabbix\psk.key" -value "0643a0cf2f878cfec59dff76018906605e55a3e8f6a235c73ac4e2e443240f29"     

# trier les fichiers à la racine du dossier   c:\zabbix
Move-Item c:\zabbix\bin\zabbix_agentd.exe -Destination c:\zabbix

# trier les fichiers à la racine du dossier   c:\zabbix
Move-Item c:\zabbix\conf\zabbix_agentd.conf -Destination c:\zabbix

# remplacement des valeurs dans le fichiers de configuration
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '127.0.0.1', "$ServerIP"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace 'Windows host', "$ServerHostname"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '# ListenPort=10050', "ListenPort=10051"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace 'ServerActive=', "ServerActive=10.34.1.41"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace 'Server=', "Server=10.34.1.41"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '# LogType=file',"LogType=file"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '# TLSConnect=unencrypted',"TLSConnect=psk"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '# TLSAccept=unencrypted',"TLSAccept=psk"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '# TLSPSKIdentity=',"TLSPSKIdentity=POC-Autoregistration"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '# TLSPSKFile=',"TLSPSKFile=C:\zabbix\psk.key"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '# LogType=file=',"LogType=file"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '# HostMetadata=',"HostMetadataItem=system.uname"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf



# installation de l'agent zabbix avec le fichier de configuration dans C:/zabbix
c:\zabbix\zabbix_agentd.exe --config c:\zabbix\zabbix_agentd.conf --install

# démarrage de l'agent zabbix
c:\zabbix\zabbix_agentd.exe --start

# création régle parfeu , activer si utile 
#New-NetFirewallRule -DisplayName "Allow Zabbix communication" -Direction Inbound -Program "c:\zabbix\zabbix_agentd.exe" -RemoteAddress LocalSubnet -Action Allow
