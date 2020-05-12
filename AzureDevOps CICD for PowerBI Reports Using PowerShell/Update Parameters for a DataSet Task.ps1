$datasetname="Demo"
$workspacename="PowerBI_CICD_PROD"



$clientsec = "$(client_secret)" | ConvertTo-SecureString -AsPlainText -Force

$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $env:client_id, $clientsec 
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credential -TenantId $env:tenant_id

$workspace =Get-PowerBIWorkspace -Name $workspacename

$DatasetResponse=Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets" -Method Get | ConvertFrom-Json


$datasets = $DatasetResponse.value

     foreach($dataset in $datasets){
                if($dataset.name -eq $datasetname){
                $datasetid= $dataset.id;
                break;
                }

            }

   $postParams = @{
            updateDetails =@(
            @{
            name="blob"
            newValue="https://demo123.blob.core.windows.net/"
            }
            )
} | ConvertTo-Json

Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets/$($datasetid)/Default.TakeOver" -Method Post

$response=Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets/$($datasetid)/Default.UpdateParameters" -Method Post -Body $postParams | ConvertFrom-Json



