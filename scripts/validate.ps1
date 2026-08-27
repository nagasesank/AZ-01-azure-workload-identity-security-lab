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

try {
    $account = az account show --output json | ConvertFrom-Json
}
catch {
    throw "Azure CLI authentication was not found. Run 'az login' and retry."
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

Push-Location $terraformDirectory
try {
    terraform fmt -check
    terraform init
    terraform validate
    terraform plan
}
finally {
    Pop-Location
}
