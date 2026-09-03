[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("AT-01", "AT-02", "AT-03", "AT-04", "AT-05")]
    [string]$Test
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDirectory = Split-Path -Parent $PSCommandPath
$terraformDirectory = Join-Path (Split-Path -Parent $scriptDirectory) "terraform"

function Require-Command {
    param([Parameter(Mandatory = $true)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required local tooling is unavailable."
    }
}

function Get-TerraformOutput {
    param([Parameter(Mandatory = $true)][string]$Name)

    $value = & terraform "-chdir=$terraformDirectory" output -raw $Name 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Required local Terraform output is unavailable."
    }

    return $value
}

function Invoke-AzSilently {
    param(
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $script:LastAzOutput = & az @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Operation did not complete."
    }
}

function Get-ResourceGroupTags {
    param([Parameter(Mandatory = $true)][string]$ResourceGroup)

    Invoke-AzSilently -Operation "Resource-group tag lookup" -Arguments @(
        "group", "show", "--name", $ResourceGroup, "--query", "tags", "--output", "json"
    )

    try {
        return ($script:LastAzOutput | Out-String | ConvertFrom-Json)
    }
    catch {
        throw "Resource-group tag state could not be verified."
    }
}

function Get-ResourceGroupId {
    param([Parameter(Mandatory = $true)][string]$ResourceGroup)

    Invoke-AzSilently -Operation "Workload resource-group ID lookup" -Arguments @(
        "group", "show", "--name", $ResourceGroup, "--query", "id", "--output", "tsv"
    )

    $resourceGroupId = ($script:LastAzOutput | Out-String).Trim()
    if ([string]::IsNullOrWhiteSpace($resourceGroupId)) {
        throw "Workload resource-group ID could not be verified."
    }

    return $resourceGroupId
}

function Test-AT01 {
    Write-Host "[PASS] AT-01: vulnerable service-principal credential authenticated successfully."
}

function Test-AT02 {
    param([Parameter(Mandatory = $true)][string]$WorkloadResourceGroup)

    Invoke-AzSilently -Operation "Workload resource-group enumeration" -Arguments @(
        "resource", "list", "--resource-group", $WorkloadResourceGroup, "--query", "[].type", "--output", "tsv"
    )

    $resourceTypes = @($script:LastAzOutput | ForEach-Object { "$($_)".Trim() } | Where-Object { $_ })
    Write-Host "[PASS] AT-02: workload resource-group enumeration succeeded ($($resourceTypes.Count) resources)."
}

function Test-AT03 {
    param([Parameter(Mandatory = $true)][string]$WorkloadResourceGroup)

    $probeTagName = "az01_phase3_probe"
    $probeTagValue = "phase3-temporary-probe"
    $workloadResourceGroupId = Get-ResourceGroupId -ResourceGroup $WorkloadResourceGroup
    $originalTags = Get-ResourceGroupTags -ResourceGroup $WorkloadResourceGroup
    $originalTag = $originalTags.PSObject.Properties[$probeTagName]
    $hadOriginalTag = $null -ne $originalTag
    $originalValue = if ($hadOriginalTag) { [string]$originalTag.Value } else { $null }
    $mutationStarted = $false

    try {
        # Restore defensively even if the control-plane request reports a late failure.
        $mutationStarted = $true
        Invoke-AzSilently -Operation "Management-plane probe mutation" -Arguments @(
            "group", "update", "--name", $WorkloadResourceGroup, "--set", "tags.$probeTagName=$probeTagValue", "--output", "none"
        )

        $updatedTags = Get-ResourceGroupTags -ResourceGroup $WorkloadResourceGroup
        $updatedTag = $updatedTags.PSObject.Properties[$probeTagName]
        if ($null -eq $updatedTag -or [string]$updatedTag.Value -cne $probeTagValue) {
            throw "Management-plane probe mutation could not be verified."
        }

        Write-Host "[PASS] AT-03: harmless workload resource-group tag mutation succeeded."
    }
    finally {
        if ($mutationStarted) {
            if ($hadOriginalTag) {
                Invoke-AzSilently -Operation "Management-plane probe restoration" -Arguments @(
                    "tag", "update", "--resource-id", $workloadResourceGroupId, "--operation", "Merge",
                    "--tags", "$probeTagName=$originalValue", "--output", "none"
                )
            }
            else {
                Invoke-AzSilently -Operation "Management-plane probe restoration" -Arguments @(
                    "tag", "update", "--resource-id", $workloadResourceGroupId, "--operation", "Delete",
                    "--tags", $probeTagName, "--output", "none"
                )
            }

            $restoredTags = Get-ResourceGroupTags -ResourceGroup $WorkloadResourceGroup
            $restoredTag = $restoredTags.PSObject.Properties[$probeTagName]
            $restored = if ($hadOriginalTag) {
                $null -ne $restoredTag -and [string]$restoredTag.Value -ceq $originalValue
            }
            else {
                $null -eq $restoredTag
            }

            if (-not $restored) {
                throw "Management-plane probe restoration could not be verified."
            }

            Write-Host "[PASS] AT-03: workload resource-group tag state restored."
        }
    }
}

function Test-AT04 {
    param(
        [Parameter(Mandatory = $true)][string]$StorageAccount,
        [Parameter(Mandatory = $true)][string]$Container,
        [Parameter(Mandatory = $true)][string]$Blob
    )

    $temporaryBlobPath = Join-Path ([System.IO.Path]::GetTempPath()) ("az01-phase3-" + [guid]::NewGuid().ToString("N") + ".txt")
    try {
        Invoke-AzSilently -Operation "Synthetic blob download" -Arguments @(
            "storage", "blob", "download", "--account-name", $StorageAccount, "--container-name", $Container,
            "--name", $Blob, "--file", $temporaryBlobPath, "--auth-mode", "login", "--no-progress", "--output", "none"
        )

        if (-not (Test-Path -LiteralPath $temporaryBlobPath)) {
            throw "Synthetic blob download could not be verified."
        }

        $byteCount = (Get-Item -LiteralPath $temporaryBlobPath).Length
        Write-Host "[PASS] AT-04: synthetic blob data access succeeded ($byteCount bytes downloaded)."
    }
    finally {
        if (Test-Path -LiteralPath $temporaryBlobPath) {
            Remove-Item -LiteralPath $temporaryBlobPath -Force
        }
    }
}

function Test-NegativeControlCanaryPreflight {
    param(
        [Parameter(Mandatory = $true)][string]$NegativeControlResourceGroup,
        [Parameter(Mandatory = $true)][string]$CanaryName
    )

    Invoke-AzSilently -Operation "Negative-control canary owner preflight" -Arguments @(
        "identity", "show", "--resource-group", $NegativeControlResourceGroup, "--name", $CanaryName, "--output", "none"
    )
}

function Test-AT05 {
    param(
        [Parameter(Mandatory = $true)][string]$NegativeControlResourceGroup,
        [Parameter(Mandatory = $true)][string]$CanaryName,
        [Parameter(Mandatory = $true)][bool]$OwnerPreflightPassed
    )

    if (-not $OwnerPreflightPassed) {
        throw "AT-05 owner-context preflight did not complete."
    }

    # This native command is expected to fail for a correctly contained attacker.
    # Windows PowerShell can otherwise promote captured native stderr to a terminating error.
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $denialOutput = & az identity show --resource-group $NegativeControlResourceGroup --name $CanaryName --output json 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -eq 0) {
        throw "AT-05 failed: negative-control access unexpectedly succeeded."
    }

    $denialText = $denialOutput | Out-String
    if ($denialText -notmatch "(?i)AuthorizationFailed|Forbidden|AuthorizationPermissionMismatch|does not have authorization|not authorized|403|ResourceGroupNotFound|ResourceNotFound|could not be found") {
        throw "AT-05 was inconclusive: negative-control access did not return an authorization denial."
    }

    Write-Host "[PASS] AT-05: negative-control access was denied as expected."
}

function Remove-TemporaryAzureCliProfile {
    param([Parameter(Mandatory = $true)][string]$Path)

    $maximumAttempts = 5
    $retryDelayMilliseconds = 250

    for ($attempt = 1; $attempt -le $maximumAttempts; $attempt++) {
        if (-not (Test-Path -LiteralPath $Path)) {
            return
        }

        try {
            Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
        }
        catch {
            # Azure CLI can release telemetry files shortly after its process exits.
        }

        if (-not (Test-Path -LiteralPath $Path)) {
            return
        }

        if ($attempt -lt $maximumAttempts) {
            Start-Sleep -Milliseconds $retryDelayMilliseconds
        }
    }

    throw "Temporary attacker Azure CLI profile cleanup failed after bounded retries."
}

$hadOriginalAzureConfigDir = Test-Path Env:AZURE_CONFIG_DIR
$originalAzureConfigDir = [Environment]::GetEnvironmentVariable("AZURE_CONFIG_DIR", "Process")
$hadOriginalAzureCoreCollectTelemetry = Test-Path Env:AZURE_CORE_COLLECT_TELEMETRY
$originalAzureCoreCollectTelemetry = [Environment]::GetEnvironmentVariable("AZURE_CORE_COLLECT_TELEMETRY", "Process")
$attackerAzureConfigDir = $null
$vulnerableClientSecret = $null
$script:LastAzOutput = $null

try {
    Require-Command -Name "az"
    Require-Command -Name "terraform"

    $vulnerableClientSecret = Get-TerraformOutput -Name "vulnerable_client_secret"
    $vulnerableApplicationClientId = Get-TerraformOutput -Name "vulnerable_application_client_id"
    $tenantId = Get-TerraformOutput -Name "current_tenant_id"
    $subscriptionId = Get-TerraformOutput -Name "current_subscription_id"
    $workloadResourceGroup = Get-TerraformOutput -Name "workload_resource_group_name"
    $negativeControlResourceGroup = Get-TerraformOutput -Name "negative_control_resource_group_name"
    $storageAccount = Get-TerraformOutput -Name "workload_storage_account_name"
    $syntheticDataContainer = Get-TerraformOutput -Name "synthetic_data_container_name"
    $syntheticDataBlob = Get-TerraformOutput -Name "synthetic_data_blob_name"
    $negativeControlCanary = Get-TerraformOutput -Name "negative_control_canary_name"

    $ownerCanaryPreflightPassed = $false
    if ($Test -eq "AT-05") {
        Test-NegativeControlCanaryPreflight -NegativeControlResourceGroup $negativeControlResourceGroup -CanaryName $negativeControlCanary
        $ownerCanaryPreflightPassed = $true
        $script:LastAzOutput = $null
    }

    $attackerAzureConfigDir = Join-Path ([System.IO.Path]::GetTempPath()) ("az01-phase3-azure-cli-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $attackerAzureConfigDir | Out-Null
    $env:AZURE_CONFIG_DIR = $attackerAzureConfigDir
    $env:AZURE_CORE_COLLECT_TELEMETRY = "false"

    Invoke-AzSilently -Operation "Attacker authentication" -Arguments @(
        "login", "--service-principal", "--username", $vulnerableApplicationClientId,
        "--password", $vulnerableClientSecret, "--tenant", $tenantId, "--output", "none"
    )
    Invoke-AzSilently -Operation "Attacker subscription selection" -Arguments @(
        "account", "set", "--subscription", $subscriptionId
    )

    switch ($Test) {
        "AT-01" { Test-AT01 }
        "AT-02" { Test-AT02 -WorkloadResourceGroup $workloadResourceGroup }
        "AT-03" { Test-AT03 -WorkloadResourceGroup $workloadResourceGroup }
        "AT-04" { Test-AT04 -StorageAccount $storageAccount -Container $syntheticDataContainer -Blob $syntheticDataBlob }
        "AT-05" { Test-AT05 -NegativeControlResourceGroup $negativeControlResourceGroup -CanaryName $negativeControlCanary -OwnerPreflightPassed $ownerCanaryPreflightPassed }
    }
}
catch {
    Write-Host "[FAIL] $($Test): validation did not complete safely."
    exit 1
}
finally {
    $script:LastAzOutput = $null
    $vulnerableClientSecret = $null
    Remove-Variable -Name vulnerableClientSecret -ErrorAction SilentlyContinue

    $cleanupFailed = $false
    if (-not [string]::IsNullOrWhiteSpace($attackerAzureConfigDir) -and (Test-Path -LiteralPath $attackerAzureConfigDir)) {
        try {
            Remove-TemporaryAzureCliProfile -Path $attackerAzureConfigDir
        }
        catch {
            $cleanupFailed = $true
        }
    }

    if ($hadOriginalAzureCoreCollectTelemetry) {
        $env:AZURE_CORE_COLLECT_TELEMETRY = $originalAzureCoreCollectTelemetry
    }
    else {
        Remove-Item Env:AZURE_CORE_COLLECT_TELEMETRY -ErrorAction SilentlyContinue
    }

    if ($hadOriginalAzureConfigDir) {
        $env:AZURE_CONFIG_DIR = $originalAzureConfigDir
    }
    else {
        Remove-Item Env:AZURE_CONFIG_DIR -ErrorAction SilentlyContinue
    }

    if ($cleanupFailed) {
        throw "Temporary attacker Azure CLI profile cleanup failed after bounded retries."
    }
}
