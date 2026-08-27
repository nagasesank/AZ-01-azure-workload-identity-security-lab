param()

$ErrorActionPreference = "Stop"

$scriptDirectory = Split-Path -Parent $PSCommandPath
$terraformDirectory = Join-Path (Split-Path -Parent $scriptDirectory) "terraform"

function Require-Command {
    param([Parameter(Mandatory = $true)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found. Install it and retry."
    }
}

function Assert-NativeSuccess {
    param([Parameter(Mandatory = $true)][string]$Operation)

    if ($LASTEXITCODE -ne 0) {
        throw "$Operation failed with a non-zero exit code."
    }
}

function Get-NonSecretTerraformOutput {
    param([Parameter(Mandatory = $true)][string]$Name)

    $value = terraform output -raw $Name
    Assert-NativeSuccess -Operation "Terraform output '$Name'"
    return $value
}

Require-Command -Name "az"
Require-Command -Name "terraform"

$accountJson = az account show --output json
Assert-NativeSuccess -Operation "Azure CLI active-account lookup"

try {
    $account = $accountJson | ConvertFrom-Json
}
catch {
    throw "Azure CLI did not return a readable active account. Run 'az login' and retry."
}

if (-not $account -or -not $account.id -or -not $account.tenantId) {
    throw "Azure CLI did not return a usable subscription and tenant context."
}

if ([string]::IsNullOrWhiteSpace($env:ARM_SUBSCRIPTION_ID)) {
    throw "ARM_SUBSCRIPTION_ID is not set. Update it from the active Azure CLI account and retry."
}

if ([string]::IsNullOrWhiteSpace($env:ARM_TENANT_ID)) {
    throw "ARM_TENANT_ID is not set. Update it from the active Azure CLI account and retry."
}

if ($env:ARM_SUBSCRIPTION_ID -cne $account.id) {
    throw "ARM_SUBSCRIPTION_ID does not match the active Azure CLI subscription."
}

if ($env:ARM_TENANT_ID -cne $account.tenantId) {
    throw "ARM_TENANT_ID does not match the active Azure CLI tenant."
}

Push-Location $terraformDirectory
try {
    # Only named non-secret outputs are read; vulnerable_client_secret is never requested.
    $workloadResourceGroup = Get-NonSecretTerraformOutput -Name "workload_resource_group_name"
    $negativeControlGroup = Get-NonSecretTerraformOutput -Name "negative_control_resource_group_name"
    $storageAccount = Get-NonSecretTerraformOutput -Name "workload_storage_account_name"
    $syntheticDataContainer = Get-NonSecretTerraformOutput -Name "synthetic_data_container_name"
    $syntheticDataBlob = Get-NonSecretTerraformOutput -Name "synthetic_data_blob_name"
    $negativeControlCanary = Get-NonSecretTerraformOutput -Name "negative_control_canary_name"
    $applicationClientId = Get-NonSecretTerraformOutput -Name "vulnerable_application_client_id"
}
finally {
    Pop-Location
}

$workloadGroupId = az group show --name $workloadResourceGroup --query id --output tsv
Assert-NativeSuccess -Operation "Workload resource-group lookup"

$negativeControlGroupId = az group show --name $negativeControlGroup --query id --output tsv
Assert-NativeSuccess -Operation "Negative-control resource-group lookup"

$storageAccountId = az storage account show --name $storageAccount --resource-group $workloadResourceGroup --query id --output tsv
Assert-NativeSuccess -Operation "Workload storage-account lookup"

$syntheticContainer = az storage container show `
    --account-name $storageAccount `
    --name $syntheticDataContainer `
    --auth-mode login `
    --output json
Assert-NativeSuccess -Operation "Synthetic-data container lookup"

$syntheticBlob = az storage blob show `
    --account-name $storageAccount `
    --container-name $syntheticDataContainer `
    --name $syntheticDataBlob `
    --auth-mode login `
    --output json
Assert-NativeSuccess -Operation "Synthetic-data blob lookup"

$canary = az identity show --name $negativeControlCanary --resource-group $negativeControlGroup --output json
Assert-NativeSuccess -Operation "Negative-control canary lookup"

$servicePrincipalJson = az ad sp show --id $applicationClientId --output json
Assert-NativeSuccess -Operation "Vulnerable service-principal lookup"

try {
    $servicePrincipal = $servicePrincipalJson | ConvertFrom-Json
}
catch {
    throw "Azure CLI did not return a readable vulnerable service principal."
}

if ([string]::IsNullOrWhiteSpace($servicePrincipal.id)) {
    throw "Azure CLI did not return the vulnerable service-principal object ID."
}

$servicePrincipalObjectId = $servicePrincipal.id
$roleAssignmentsJson = az role assignment list `
    --assignee-object-id $servicePrincipalObjectId `
    --all `
    --fill-principal-name false `
    --output json
Assert-NativeSuccess -Operation "Vulnerable service-principal role-assignment lookup"
$roleAssignments = @($roleAssignmentsJson | ConvertFrom-Json)

$contributorAssignments = @($roleAssignments | Where-Object {
    $_.roleDefinitionName -eq "Contributor" -and $_.scope -ceq $workloadGroupId
})
if ($contributorAssignments.Count -ne 1) {
    throw "Contributor must exist exactly once and only at the workload-lab resource-group scope."
}

$blobDataAssignments = @($roleAssignments | Where-Object {
    $_.roleDefinitionName -eq "Storage Blob Data Contributor" -and $_.scope -ceq $storageAccountId
})
if ($blobDataAssignments.Count -ne 1) {
    throw "Storage Blob Data Contributor must exist exactly once and only at the workload storage-account scope."
}

$negativeControlAssignments = @($roleAssignments | Where-Object {
    $_.scope -ieq $negativeControlGroupId -or $_.scope -ilike "$negativeControlGroupId/*"
})
if ($negativeControlAssignments.Count -ne 0) {
    throw "The vulnerable service principal has an unauthorized role assignment in the negative-control boundary."
}

if ($roleAssignments.Count -ne 2) {
    throw "The vulnerable service principal has unexpected direct Azure RBAC assignments."
}

Write-Host "Phase 2 owner-context validation completed successfully."
