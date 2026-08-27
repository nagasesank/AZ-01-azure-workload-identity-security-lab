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

Require-Command -Name "az"
Require-Command -Name "terraform"

$accountJson = az account show --output json
if ($LASTEXITCODE -ne 0) {
    throw "Azure CLI returned a non-zero exit code while reading the active account. Run 'az login' and retry."
}

try {
    $account = $accountJson | ConvertFrom-Json
}
catch {
    throw "Azure CLI did not return a readable active account. Run 'az login' and retry."
}

if (-not $account -or -not $account.id -or -not $account.tenantId) {
    throw "Azure CLI did not return a usable subscription and tenant context."
}

Write-Host "Selected Azure subscription: $($account.name)"
Write-Host "Subscription state: $($account.state)"

if ([string]::IsNullOrWhiteSpace($env:ARM_SUBSCRIPTION_ID)) {
    throw "ARM_SUBSCRIPTION_ID is not set. Set it from 'az account show --query id -o tsv' and retry."
}

if ([string]::IsNullOrWhiteSpace($env:ARM_TENANT_ID)) {
    throw "ARM_TENANT_ID is not set. Set it from 'az account show --query tenantId -o tsv' and retry."
}

if ($env:ARM_SUBSCRIPTION_ID -cne $account.id) {
    throw "ARM_SUBSCRIPTION_ID does not match the active Azure CLI subscription. Update it from the active Azure CLI account and retry."
}

if ($env:ARM_TENANT_ID -cne $account.tenantId) {
    throw "ARM_TENANT_ID does not match the active Azure CLI tenant. Update it from the active Azure CLI account and retry."
}

Push-Location $terraformDirectory
try {
    Write-Host "[1/4] Checking Terraform formatting..."
    terraform fmt -check
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform formatting check failed."
    }

    Write-Host "[2/4] Initializing Terraform..."
    terraform init
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform initialization failed."
    }

    Write-Host "[3/4] Validating Terraform configuration..."
    terraform validate
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform configuration validation failed."
    }

    Write-Host "[4/4] Running zero-resource Terraform plan..."
    terraform plan -input=false
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform plan failed."
    }

    Write-Host "Phase 0 validation completed successfully."
}
finally {
    Pop-Location
}
