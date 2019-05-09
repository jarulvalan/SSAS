$Username="domain/user"

$password =  "Password" | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($Username,$password) 

Invoke-Command -ComputerName "Desttination-Host" -Credential $cred -ScriptBlock {(get-host).version}

To Enable winRM :

run -> services.msc -> Windows Remote Management - > start the service
