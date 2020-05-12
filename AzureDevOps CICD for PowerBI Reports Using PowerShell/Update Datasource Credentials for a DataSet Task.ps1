$workspacename="PowerBI_CICD_PROD"
$datasetname="AdventureReports"

## user credentials

$username= "sadmin"


$clientsec = "$(client_secret)" | ConvertTo-SecureString -AsPlainText -Force

$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $env:client_id, $clientsec 
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credential -TenantId $env:tenant_id


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
            password= '$(credentialpassword)'
            }
} | ConvertTo-Json



Invoke-PowerBIRestMethod -Url "gateways/$($BounGateway.value.gatewayId)/datasources/$($BounGateway.value.id)" -Method PATCH -Body $UpdateUserCredential | ConvertFrom-Json