
<#
   Running this script will read the details about the server name and cube name from the csv file and will deploy the SSAS Tabular Model to the SSAS Server by using the build files of the SSAS Tabular Model Project

Sample Execution:

./DeploySSASMetaDataInput.ps1 -DeploymentMetaDataFilePath "C:\Users\phanir\OneDrive - Microsoft\Projects\Kaiser\DeploySSAS\SSASDeploymentInputFile.csv" -SSASDeploymentScriptFolder "C:\Users\phanir\OneDrive - Microsoft\Projects\Kaiser\DeploySSAS"


DeploymentMetaDataFilePath : This folder path will be the location of the csv file 
SSASDeploymentScriptFolder: This will be the location where DeploySSAS.ps1 PowerShell script is saved
#>

Param
(
    [Parameter(Mandatory = $true)]
    [String]$DeploymentMetaDataFilePath,
    [Parameter(Mandatory = $true)]
    [String]$SSASDeploymentScriptFolder
)

#$DeploymentMetaDataFilePath="C:\Users\phanir\OneDrive - Microsoft\Projects\Kaiser\DeploySSAS\SSASDeploymentInputFile.csv"
#$SSASDeploymentScriptFolder = "C:\Users\phanir\OneDrive - Microsoft\Projects\Kaiser\DeploySSAS"

if (!(Test-Path $DeploymentMetaDataFilePath))  
{
      Write-Warning "$DeploymentMetaDataFilePath absent from location passed to the input parameter"
      Write-Host "Exiting..."
      continue
}

##$csv = Import-Csv "C:\Users\phanir\OneDrive - Microsoft\Projects\Kaiser\DeploySSAS\SSASDeploymentInputFile.csv"

$csv = Import-Csv $DeploymentMetaDataFilePath 
foreach($f in $csv)
{

    $path=$f.BuildFilesPath
    $SSASServerName =$f.SSASServerName
    $CubeDB= $f.SSASCubeDB
    $BimModelName=$f.BimModelName
    $SourceDatabaseServerName = $f.SQLServerName
    $SourceDBname = $f.SQLDatabaseName
    $AnalysisServicesDeploymentExePath = $f.AnalysisServicesDeploymentExePath


        if($path -eq $null -or $SSASServerName -eq $null -or $CubeDB -eq $null -or $BimModelName -eq $null -or $DatabaseServerName -eq $null -or $SourceDBname -eq $null )
        {

          Write-Warning "Some of the columns doesn't exists in the csv file....please check the csv file and esnure  columns with below names are present and has data populated : 
             BuildFilesPath 
             SSASServerName
             SSASCubeDB 
             BimModelName 
             SQLServerName 
             SQLDatabaseName 

     
             "
          Write-Host "Exiting..."
          continue
  
        }

        if (!(Test-Path $SSASDeploymentScriptFolder))  
        {
              Write-Warning "$SSASDeploymentScriptFolder absent from location passed to the input parameter"
              Write-Host "Exiting..."
              continue
        }
    Write-Host(" ")
    Write-Host(" ")
    Write-Host("Started Deploying and Processing the database $CubeDb on the Server $SSASServerName")
    Write-Host(" ")

$username = 'phani_office\ssastestuser'
$Password = 'Password@12345' | ConvertTo-SecureString -Force -AsPlainText
$credential = New-Object System.Management.Automation.PsCredential($username, $Password)   



    # parama mapping is the powershellArgs:localvariable
    $params = @{path=$path;SSASServer=$SSASServerName;SourceDBname=$SourceDBname;DatabaseServerName= $SourceDatabaseServerName;bimmodelname =$BimModelName ;CubeDB =$CubeDB;AnalysisServicesDeploymentExePath=$AnalysisServicesDeploymentExePath}
    & "$SSASDeploymentScriptFolder\DeploySSAS.ps1" @params

    $scriptpath = "$SSASDeploymentScriptFolder\DeploySSAS.ps1"

  

    #Start-Process powershell.exe -ArgumentList @("-NoExit","C:\Users\phanir\Source\Repos\DemoAdventure\DemoAdventure\bin\DeploySSAS.ps1", $path,"$SSASServerName","$SourceDBname","$SourceDatabaseServerName","$BimModelName","$CubeDB","'$AnalysisServicesDeploymentExePath'")  -Credential $credential -Wait #-NoNewWindow 
  

    Write-Host("Completed Deploying and Processing the database $CubeDb on the Server $SSASServerName") 
  
    Write-Host(" ")
    Write-Host(" ")


}
