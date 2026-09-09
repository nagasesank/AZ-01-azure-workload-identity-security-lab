[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDirectory = Split-Path -Parent $PSCommandPath
$repositoryDirectory = Split-Path -Parent $scriptDirectory
$terraformDirectory = Join-Path $repositoryDirectory "terraform"
$identityTerraformPath = Join-Path $terraformDirectory "identity.tf"

$probeTagName = "az01_phase5_probe"
$writeProbeBlobName = "az01-phase5-write-probe.txt"

function Write-Outcome {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,

        [Parameter(Mandatory = $true)]
        [ValidateSet("PASS", "FAIL", "INCONCLUSIVE")]
        [string]$Outcome
    )

    Write-Host "${Label}: ${Outcome}"
}

function Stop-Preflight {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,

        [Parameter(Mandatory = $true)]
        [ValidateSet("FAIL", "INCONCLUSIVE")]
        [string]$Outcome
    )

    Write-Outcome -Label $Label -Outcome $Outcome
    exit 1
}

function Require-Command {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command unavailable."
    }
}

function Invoke-CapturedNative {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $stderrPath = [System.IO.Path]::GetTempFileName()

    try {
        $stdout = & $Command @Arguments 2> $stderrPath
        $exitCode = $LASTEXITCODE

        if ($exitCode -ne 0) {
            throw "Native command failed."
        }

        return (($stdout | ForEach-Object { "$_" }) -join [Environment]::NewLine)
    }
    finally {
        Remove-Item -LiteralPath $stderrPath -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-AzJson {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $text = Invoke-CapturedNative `
        -Command "az" `
        -Arguments ($Arguments + @("--only-show-errors", "--output", "json"))

    try {
        return ($text | ConvertFrom-Json)
    }
    catch {
        throw "Azure CLI returned unreadable JSON."
    }
}

function Invoke-AzNoOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    [void](Invoke-CapturedNative `
        -Command "az" `
        -Arguments ($Arguments + @("--only-show-errors", "--output", "none")))
}

function Get-TerraformOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $value = Invoke-CapturedNative `
        -Command "terraform" `
        -Arguments @(
            "-chdir=$terraformDirectory",
            "output",
            "-raw",
            $Name
        )

    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Required Terraform output unavailable."
    }

    return $value.Trim()
}

function Get-ApplicableRoleAssignments {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PrincipalObjectId,

        [Parameter(Mandatory = $true)]
        [string]$Scope
    )

    $result = Invoke-AzJson -Arguments @(
        "role", "assignment", "list",
        "--assignee-object-id", $PrincipalObjectId,
        "--scope", $Scope,
        "--include-inherited",
        "--include-groups",
        "--all"
    )

    return @($result)
}

#
# PF-01 — owner context + Terraform target acquisition
#

try {
    Require-Command -Name "az"
    Require-Command -Name "terraform"

    $terraformSubscriptionId = Get-TerraformOutput -Name "current_subscription_id"
    $terraformTenantId = Get-TerraformOutput -Name "current_tenant_id"
    $ownerObjectId = Get-TerraformOutput -Name "current_object_id"

    $workloadResourceGroup = Get-TerraformOutput -Name "workload_resource_group_name"
    $negativeControlResourceGroup = Get-TerraformOutput -Name "negative_control_resource_group_name"
    $storageAccount = Get-TerraformOutput -Name "workload_storage_account_name"
    $syntheticContainer = Get-TerraformOutput -Name "synthetic_data_container_name"
    $syntheticBlob = Get-TerraformOutput -Name "synthetic_data_blob_name"
    $negativeControlCanary = Get-TerraformOutput -Name "negative_control_canary_name"
    $workloadApplicationClientId = Get-TerraformOutput -Name "workload_application_client_id"

    $account = Invoke-AzJson -Arguments @(
        "account", "show"
    )
}
catch {
    Stop-Preflight -Label "PF-01" -Outcome "INCONCLUSIVE"
}

if (
    [string]::IsNullOrWhiteSpace($account.id) -or
    [string]::IsNullOrWhiteSpace($account.tenantId)
) {
    Stop-Preflight -Label "PF-01" -Outcome "INCONCLUSIVE"
}

if (
    $account.id -cne $terraformSubscriptionId -or
    $account.tenantId -cne $terraformTenantId
) {
    Stop-Preflight -Label "PF-01" -Outcome "FAIL"
}

Write-Outcome -Label "PF-01" -Outcome "PASS"

#
# PF-02 — exact known target existence
#

try {
    $workloadGroup = Invoke-AzJson -Arguments @(
        "group", "show",
        "--name", $workloadResourceGroup
    )

    $negativeControlGroup = Invoke-AzJson -Arguments @(
        "group", "show",
        "--name", $negativeControlResourceGroup
    )

    $storage = Invoke-AzJson -Arguments @(
        "storage", "account", "show",
        "--name", $storageAccount,
        "--resource-group", $workloadResourceGroup
    )

    Invoke-AzNoOutput -Arguments @(
        "storage", "container", "show",
        "--account-name", $storageAccount,
        "--name", $syntheticContainer,
        "--auth-mode", "login"
    )

    Invoke-AzNoOutput -Arguments @(
        "storage", "blob", "show",
        "--account-name", $storageAccount,
        "--container-name", $syntheticContainer,
        "--name", $syntheticBlob,
        "--auth-mode", "login"
    )

    $negativeControlCanaryResource = Invoke-AzJson -Arguments @(
    "identity", "show",
    "--resource-group", $negativeControlResourceGroup,
    "--name", $negativeControlCanary
    )
}
catch {
    Stop-Preflight -Label "PF-02" -Outcome "INCONCLUSIVE"
}

if (
    [string]::IsNullOrWhiteSpace($workloadGroup.id) -or
    [string]::IsNullOrWhiteSpace($negativeControlGroup.id) -or
    [string]::IsNullOrWhiteSpace($storage.id) -or
    [string]::IsNullOrWhiteSpace($negativeControlCanaryResource.id)
) {
    Stop-Preflight -Label "PF-02" -Outcome "INCONCLUSIVE"
}

$workloadGroupId = [string]$workloadGroup.id
$storageAccountId = [string]$storage.id
$negativeControlCanaryId = [string]$negativeControlCanaryResource.id
$containerScope = "${storageAccountId}/blobServices/default/containers/${syntheticContainer}"

Write-Outcome -Label "PF-02" -Outcome "PASS"

#
# PF-03 — application/SP credential absence
#

try {
    $application = Invoke-AzJson -Arguments @(
        "ad", "app", "show",
        "--id", $workloadApplicationClientId
    )

    $servicePrincipal = Invoke-AzJson -Arguments @(
        "ad", "sp", "show",
        "--id", $workloadApplicationClientId
    )
}
catch {
    Stop-Preflight -Label "PF-03" -Outcome "INCONCLUSIVE"
}

if (
    [string]::IsNullOrWhiteSpace($application.id) -or
    [string]::IsNullOrWhiteSpace($servicePrincipal.id)
) {
    Stop-Preflight -Label "PF-03" -Outcome "INCONCLUSIVE"
}

$applicationPasswordCount = @($application.passwordCredentials).Count
$applicationKeyCount = @($application.keyCredentials).Count
$servicePrincipalPasswordCount = @($servicePrincipal.passwordCredentials).Count
$servicePrincipalKeyCount = @($servicePrincipal.keyCredentials).Count

if (
    $applicationPasswordCount -ne 0 -or
    $applicationKeyCount -ne 0 -or
    $servicePrincipalPasswordCount -ne 0 -or
    $servicePrincipalKeyCount -ne 0
) {
    Stop-Preflight -Label "PF-03" -Outcome "FAIL"
}

$applicationObjectId = [string]$application.id
$servicePrincipalObjectId = [string]$servicePrincipal.id

Write-Outcome -Label "PF-03" -Outcome "PASS"

#
# PF-04 — federated trust exactness
#
# Expected issuer/subject/audience are read from Terraform source rather
# than duplicated into this script. No identifier values are printed.
#

try {
    $identityTerraform = Get-Content `
        -LiteralPath $identityTerraformPath `
        -Raw `
        -ErrorAction Stop

    $issuerMatch = [regex]::Match(
        $identityTerraform,
        'issuer\s*=\s*"([^"]+)"'
    )

    $subjectMatch = [regex]::Match(
        $identityTerraform,
        'subject\s*=\s*"([^"]+)"'
    )

    $audienceMatch = [regex]::Match(
        $identityTerraform,
        'audiences\s*=\s*\[\s*"([^"]+)"\s*\]'
    )

    if (
        -not $issuerMatch.Success -or
        -not $subjectMatch.Success -or
        -not $audienceMatch.Success
    ) {
        throw "Expected federation configuration unavailable."
    }

    $expectedIssuer = $issuerMatch.Groups[1].Value
    $expectedSubject = $subjectMatch.Groups[1].Value
    $expectedAudience = $audienceMatch.Groups[1].Value

    $federatedCredentials = @(
        Invoke-AzJson -Arguments @(
            "ad", "app", "federated-credential", "list",
            "--id", $applicationObjectId
        )
    )
}
catch {
    Stop-Preflight -Label "PF-04" -Outcome "INCONCLUSIVE"
}

if ($federatedCredentials.Count -ne 1) {
    Stop-Preflight -Label "PF-04" -Outcome "FAIL"
}

$federatedCredential = $federatedCredentials[0]
$actualAudiences = @($federatedCredential.audiences)

if (
    $federatedCredential.issuer -cne $expectedIssuer -or
    $federatedCredential.subject -cne $expectedSubject -or
    $actualAudiences.Count -ne 1 -or
    $actualAudiences[0] -cne $expectedAudience -or
    $federatedCredential.subject -notlike "*:ref:refs/heads/main"
) {
    Stop-Preflight -Label "PF-04" -Outcome "FAIL"
}

Write-Outcome -Label "PF-04" -Outcome "PASS"

#
# PF-05 — effective workload RBAC
#

try {
    $workloadAssignments = Get-ApplicableRoleAssignments `
        -PrincipalObjectId $servicePrincipalObjectId `
        -Scope $containerScope
}
catch {
    Stop-Preflight -Label "PF-05" -Outcome "INCONCLUSIVE"
}

$expectedAssignments = @(
    $workloadAssignments | Where-Object {
        $_.roleDefinitionName -eq "Storage Blob Data Reader" -and
        $_.scope -ceq $containerScope
    }
)

$unexpectedAssignments = @(
    $workloadAssignments | Where-Object {
        -not (
            $_.roleDefinitionName -eq "Storage Blob Data Reader" -and
            $_.scope -ceq $containerScope
        )
    }
)

if (
    $expectedAssignments.Count -ne 1 -or
    $unexpectedAssignments.Count -ne 0
) {
    Stop-Preflight -Label "PF-05" -Outcome "FAIL"
}

#
# Also inspect the workload principal at the workload RG scope.
# It must have no management-plane authorization there.
#

try {
    $workloadManagementAssignments = Get-ApplicableRoleAssignments `
        -PrincipalObjectId $servicePrincipalObjectId `
        -Scope $workloadGroupId
}
catch {
    Stop-Preflight -Label "PF-05" -Outcome "INCONCLUSIVE"
}

if ($workloadManagementAssignments.Count -ne 0) {
    Stop-Preflight -Label "PF-05" -Outcome "FAIL"
}
try {
    $negativeControlAssignments = Get-ApplicableRoleAssignments `
        -PrincipalObjectId $servicePrincipalObjectId `
        -Scope $negativeControlCanaryId
}
catch {
    Stop-Preflight -Label "PF-05" -Outcome "INCONCLUSIVE"
}

if ($negativeControlAssignments.Count -ne 0) {
    Stop-Preflight -Label "PF-05" -Outcome "FAIL"
}
Write-Outcome -Label "PF-05" -Outcome "PASS"

#
# PF-06 — mutation/cleanup readiness without mutation
#

try {
    $tags = $workloadGroup.tags

    if ($null -ne $tags) {
        $existingProbeTag = $tags.PSObject.Properties[$probeTagName]

        if ($null -ne $existingProbeTag) {
            Stop-Preflight -Label "PF-06" -Outcome "FAIL"
        }
    }

    $probeExistsText = Invoke-CapturedNative `
        -Command "az" `
        -Arguments @(
            "storage", "blob", "exists",
            "--account-name", $storageAccount,
            "--container-name", $syntheticContainer,
            "--name", $writeProbeBlobName,
            "--auth-mode", "login",
            "--only-show-errors",
            "--query", "exists",
            "--output", "tsv"
        )

    if ($probeExistsText.Trim() -ieq "true") {
        Stop-Preflight -Label "PF-06" -Outcome "FAIL"
    }

    if ($probeExistsText.Trim() -ine "false") {
        Stop-Preflight -Label "PF-06" -Outcome "INCONCLUSIVE"
    }

    $ownerManagementAssignments = Get-ApplicableRoleAssignments `
        -PrincipalObjectId $ownerObjectId `
        -Scope $workloadGroupId

    $ownerCanRestoreTag = @(
        $ownerManagementAssignments | Where-Object {
            $_.roleDefinitionName -in @(
                "Owner",
                "Contributor",
                "Tag Contributor"
            )
        }
    ).Count -gt 0

    if (-not $ownerCanRestoreTag) {
        Stop-Preflight -Label "PF-06" -Outcome "INCONCLUSIVE"
    }

    $ownerStorageAssignments = Get-ApplicableRoleAssignments `
        -PrincipalObjectId $ownerObjectId `
        -Scope $containerScope

    $ownerCanCleanProbeBlob = @(
        $ownerStorageAssignments | Where-Object {
            $_.roleDefinitionName -in @(
                "Owner",
                "Storage Blob Data Owner",
                "Storage Blob Data Contributor"
            )
        }
    ).Count -gt 0

    if (-not $ownerCanCleanProbeBlob) {
        Stop-Preflight -Label "PF-06" -Outcome "INCONCLUSIVE"
    }
}
catch {
    Stop-Preflight -Label "PF-06" -Outcome "INCONCLUSIVE"
}

Write-Outcome -Label "PF-06" -Outcome "PASS"
Write-Host "P5-PREFLIGHT: PASS"
