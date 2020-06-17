# PowerBI-CICD

[Find the Presentation deck here](https://github.com/jayendranarumugam/PowerBI-CICD/blob/master/CICD%20for%20PowerBI%20Reports.pdf)

![](https://social.technet.microsoft.com/wiki/cfs-filesystemfile.ashx/__key/communityserver-components-imagefileviewer/communityserver-wikis-components-files-00-00-00-00-05/1222.Feature.jpg_2D00_550x0.jpg)

This sample script is used to call PowerBI API's using PBI Powershell Modules from Azure DevOps Pipelines. I've written a Detailed Article https://social.technet.microsoft.com/wiki/contents/articles/53172.azuredevops-cicd-for-powerbi-reports.aspx on how you can implement this with Azure DevOps, Read the article for the full reference.

 

## Modules need to be installed 



1. MicrosoftPowerBIMgmt.Workspaces
2. MicrosoftPowerBIMgmt.Profile
 

## Actions Implemented by this Scripts

1. PowerBI SPN Autentication
2. PowerBI Take Over a dataset
3. PowerBI  Update Data Source Credentials
4. PowerBI  Update Parameters


The below Script you can run in your local machine for internal testing, for integrating this script with Azure DevOps, please download the file which have been attached here.


````
$applicationId = "" # Need to pass the clientid from devops variable 
$clientsec = "" | ConvertTo-SecureString -AsPlainText -Force # Need to pass from devops secret variable 
 
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationId, $clientsec 
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credential -TenantId "" # Need to pass from devops variable  
 
 
 
$workspacename="PowerBI_CICD_PROD" 
$datasetname="AdventureReports" 
 
 
## user credentials 
 
$username= "sadmin" 
$password= "Password@123" # Need to pass from devops secret variable  
 
 
##Getworksapce 
 
$workspace =Get-PowerBIWorkspace -Name $workspacename 
 
# GetDataSets 
$DatasetResponse=Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets" -Method Get | ConvertFrom-Json 
 
 
# Get DataSet 
$datasets = $DatasetResponse.value 
 
     foreach($dataset in $datasets){ 
                if($dataset.name -eq $datasetname){ 
                $datasetid= $dataset.id; 
                break; 
                } 
 
            } 
 
## Take Over DataSet 
 
Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets/$($datasetid)/Default.TakeOver" -Method Post 
 
## update data source credentials 
 
$BounGateway=Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets/$($datasetid)/Default.GetBoundGatewayDataSources" -Method GET | ConvertFrom-Json 
 
 
$UpdateUserCredential = @{ 
            credentialType ="Basic" 
            basicCredentials = @{             
            username= $username 
            password=$password 
            } 
} | ConvertTo-Json 
 
 
 
Invoke-PowerBIRestMethod -Url "gateways/$($BounGateway.value.gatewayId)/datasources/$($BounGateway.value.id)" -Method PATCH -Body $UpdateUserCredential | ConvertFrom-Json 
 
 
## update parameter API 
 
   $postParams = @{ 
            updateDetails =@( 
            @{ 
            name="blob" 
            newValue="https://demo.blob.core.windows.net/" 
            } 
            ) 
} | ConvertTo-Json 
 
 
 
Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets/$($datasetid)/Default.UpdateParameters" -Method Post -Body $postParams | ConvertFrom-Json ````
 

 

 

