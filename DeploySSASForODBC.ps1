<#
   Running this script will deploy the SSAS Tabular Model to the SSAS Server mentioned by using the build files of the SSAS Tabular Model Project

   Sample Execution: D:\Projects\Kaiser\DeploySSASForODBC.ps1 -path "D:\Projects\Kaiser" -SSASServer "localhost\sqltabular"  -bimmodelname "Model" -CubeDB "SSASDev_demo1"   -AnalysisServicesDeploymentExePath   "C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\Microsoft.AnalysisServices.Deployment.exe" -SourceDBUserName "phanir@microsoftcom" -SourceDBPassword "aaadd2992"
#>

Param
(
    [Parameter(Mandatory = $true)]
    [String]$path,
    [Parameter(Mandatory = $true)]
    [String]$SSASServer,
    [String]$BimModelName,
    [Parameter(Mandatory = $true)]
    [String]$CubeDB,
    [Parameter(Mandatory = $true)]
    [String]$AnalysisServicesDeploymentExePath,
    [Parameter(Mandatory = $true)]
    [String]$SourceDBUserName,
    [Parameter(Mandatory = $true)]
    [String]$SourceDBPassword
)

<#
$path="D:\Projects\Kaiser"
$SSASServer= "localhost\sqltabular"
$BimModelName = "Model"
$CubeDB = "Hitesh_SSASDB"
$AnalysisServicesDeploymentExePath="C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\Microsoft.AnalysisServices.Deployment.exe"
$SourceDBUserName="phanir@microsft.com"
$SourceDBPassword="sadsadasd"
#>

Write-Host "------------------------------------"

$pwd = pwd
Write-Host "Path of PowerShell Script = $pwd"

$AsDBpath             = "$path\$BimModelName.asdatabase"
$DepTargetpath        = "$path\$BimModelName.deploymenttargets"
$ConfigPath           = "$path\$BimModelName.configsettings"
$DeployOptionPath     = "$path\$BimModelName.deploymentoptions"
$SSASConnectionString         = "DataSource=$SsasServer;Timeout=0"
$SourceDBConnectionString     = "Provider=SQLNCLI11.1;Data Source=$DatabaseServerName;Integrated Security=SSPI;Initial Catalog=$SourceDBname"


if (!(Test-Path $AsDBpath))  {
  Write-Warning "$AsDBpath absent from location passed to the input parameter"
  Write-Host "Exiting..."
  continue
}
 

 #Adjust .deploymenttargets file  for SSAS database connectionstring
 $xml  = [xml](Get-Content $DepTargetpath)
 $xml.Data.Course.Subject
 $node = $xml.DeploymentTarget
 $node.Database = $CubeDB
 $node = $xml.DeploymentTarget
 $node.Server = $SsasServer
 $node = $xml.DeploymentTarget
 $node.ConnectionString = $SSASConnectionString
 $xml.Save($DepTargetpath)


 #Adjust .deploymentoptions file database connectionstring
 $xml = [xml](Get-Content $DeployOptionPath)
 $xml.Data.Course.Subject
 $node = $xml.DeploymentOptions
 $node.ProcessingOption = "DoNotProcess"
 $xml.Save($DeployOptionPath)



  # Create the xmla script with AnalysisServices.Deployment wizard
 Write-Host "Creating XMLA for : $CubeDB"
 $path = $path
 cd $path 
 $path
 $exe = "$AnalysisServicesDeploymentExePath"  #"C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\Microsoft.AnalysisServices.Deployment.exe"
 $param1 = $BimModelName+".asdatabase"
 $param2 = "/s:" + $BimModelName+ ".txt"
 $param3 = "/o:" + $BimModelName+".xmla"
 $param4 = "/d"
 &($exe)($param1)($param2)($param3)($param4)

 $xmlafilepath = $BimModelName+".xmla"



 $xmladata = Get-Content -Path $xmlafilepath | ConvertFrom-Json


    foreach ($ds in $xmladata.createOrReplace.database.model.dataSources){
    
        $ds.Credential.Username = $SourceDBUserName
    
        #Adding password property to the object.
    
        $ds.credential | Add-Member -NotePropertyName Password -NotePropertyValue $SourceDBPassword
    
    }



$xmladata | ConvertTo-Json -depth 100 | Out-File $xmlaFilePath



  Write-Host "Importing SQL modules..."

  #Get the location of the libarary file location

  #if ((Get-Module -ListAvailable | where-object {($_.Name -eq 'SqlServer') -and ($_.Version.Major -gt 20) } |Measure).Count -eq 1){
      Import-Module SqlServer -DisableNameChecking
  #}
  
  
  Write-Host "Importing SQL modules...Done"


  Write-Host "Path = $path"
  Write-Host "Deploying XMLA script to the $SSASServer with DB name as $CubeDB..."
  
  Invoke-ASCmd -InputFile $path\$BimModelName.xmla -Server:$SsasServer  | Out-File $path\$BimModelName.xml
  Write-Host "Deploying XMLA script done..."

  
  Write-Host "Please check $path\$BimModelName.xmla as this is XMLA output of this Script"
  Write-Host "Done."
  Write-Host "------------------------------------"

  Write-Host "Process the databases started :$CubeDB "
  Invoke-ProcessASDatabase -Server $SsasServer -RefreshType Full -DatabaseName $CubeDB | Out-File $path\$BimModelNameFullProcess.xml
  Write-Host "Full Process Done for the database $CubeDB \n \n"
  Write-Host "------------------------------------\n"

  # Changing to the path where the PowerShell Script is saved
  cd $pwd