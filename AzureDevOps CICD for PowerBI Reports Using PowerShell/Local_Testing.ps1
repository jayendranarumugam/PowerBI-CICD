
$applicationId = ""
$clientsec = "" | ConvertTo-SecureString -AsPlainText -Force

$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationId, $clientsec
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credential -TenantId ""



$workspacename="PowerBI_CICD_PROD"
$datasetname="AdventureReports"


## user credentials

$username= "sadmin"
$password= "Password@123"


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



Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets/$($datasetid)/Default.UpdateParameters" -Method Post -Body $postParams | ConvertFrom-Json






