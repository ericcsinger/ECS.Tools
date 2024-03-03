
#######################################################
# Parameters
[CmdletBinding(
    ConfirmImpact = "High",
    SupportsShouldProcess = $true
)]
param (
    [Parameter(
        Mandatory = $false
    )]
    [ValidateScript({
        Test-Path -Path $PSItem -PathType Container
    })]
    [string]$ModuleDirectoryPath = (Split-Path -Path $PSScriptRoot -Parent -Resolve),

    [Parameter(
        Mandatory = $false
    )]
    [ValidateScript({
        Test-Path -Path $PSItem -PathType Container
    })]
    [string]$BuildDirectoryPath = (Join-Path -Path $ModuleDirectoryPath -ChildPath "build" -Resolve -ErrorAction Stop),

    [Parameter(
        Mandatory = $false
    )]
    [ValidateScript({
        Test-Path -Path $PSItem -PathType Container
    })]
    [string]$DistributionDirectoryPath = (Join-Path -Path $ModuleDirectoryPath -ChildPath "dist" -Resolve -ErrorAction Stop),

    [Parameter(
        Mandatory = $false
    )]
    [ValidateScript({
        Test-Path -Path $PSItem -PathType Container
    })]
    [string]$SourceCodeDirectoryPath = (Join-Path -Path $ModuleDirectoryPath -ChildPath "src" -Resolve -ErrorAction Stop),

    [Parameter(
        Mandatory = $false
    )]
    [ValidateNotNull()]
    [string]$ModuleName = (Split-Path -Path $ModuleDirectoryPath -Leaf -ErrorAction Stop)
)

#######################################################
# Variables
try {
    $DebugAllEnabled = $null
    $DebugAllEnabled = $Global:DebugPreference -eq 'Continue'
    Write-Debug -Message "DebugAllEnabled: ""$($DebugAllEnabled)""" -Debug:$DebugPreference

    $VerboseAllEnabled = $null
    $VerboseAllEnabled = $Global:VerbosePreference -eq 'Continue'
    Write-Debug -Message "VerboseAllEnabled: ""$($VerboseAllEnabled)""" -Debug:$DebugPreference

    $DebugInternalEnabled = $null
    $DebugInternalEnabled = $PSBoundParameters.Debug.IsPresent -eq $true -or $DebugAllEnabled -eq $true
    Write-Debug -Message "DebugInternalEnabled: ""$($DebugInternalEnabled)""" -Debug:$DebugPreference

    $VerboseInternalEnabled = $null
    $VerboseInternalEnabled = $PSBoundParameters.Verbose.IsPresent -eq $true -or $VerboseAllEnabled -eq $true
    Write-Debug -Message "VerboseInternalEnabled: ""$($VerboseInternalEnabled)""" -Debug:$DebugPreference

    $ExternalCommandSplat = $null
    $ExternalCommandSplat = @{
        Debug = $DebugAllEnabled
        ErrorAction = "Stop"
        Verbose = $VerboseAllEnabled
    }
    If ($DebugInternalEnabled -eq $true) {
        Write-Debug -Message "ExternalCommandSplat: $(ConvertTo-Json @ExternalCommandSplat -InputObject $ExternalCommandSplat)" -Debug:$DebugPreference
    }

    $InternalCommandSplat = $null
    $InternalCommandSplat = @{
        Debug = $DebugInternalEnabled
        ErrorAction = "Stop"
        Verbose = $VerboseInternalEnabled
    }
    If ($DebugInternalEnabled -eq $true) {
        Write-Debug -Message "ExternalCommandSplat: $(ConvertTo-Json @ExternalCommandSplat -InputObject $ExternalCommandSplat)" -Debug:$DebugPreference
    }

    $RootModuleFileName = $null
    $RootModuleFileName = "RootModule.psm1"
    If ($DebugInternalEnabled -eq $true) {
        Write-Debug -Message "RootModuleFileName: ""$($RootModuleFileName)"""
    }

    $ModuleManifestParametersFileName = $null
    $ModuleManifestParametersFileName = "ModuleManifest.json"
    If ($DebugInternalEnabled -eq $true) {
        Write-Debug -Message "ModuleManifestParametersFileName: ""$($ModuleManifestParametersFileName)"""
    }

    #######################################################
    # Source Directory / Files

    $ModuleManifestParametersSourceFilePath = $null
    $ModuleManifestParametersSourceFilePath = Join-Path @ExternalCommandSplat -Path $SourceCodeDirectoryPath -ChildPath $ModuleManifestParametersFileName -Resolve
    If ($DebugInternalEnabled -eq $true) {
        Write-Debug -Message "ModuleManifestParametersSourceFilePath: ""$($ModuleManifestParametersSourceFilePath)"""
    }

    #######################################################
    # Exclusions

    $AllSourceDirectoryFilePatternsToExclude = $null
    $AllSourceDirectoryFilePatternsToExclude = @(
        "*ModuleManifest.json"
    )
}
catch {
    throw $PSItem
}

#######################################################
# Debug parameters
try {
    if ($DebugInternalEnabled -eq $true) {
        Write-Debug @InternalCommandSplat -Message "BuildDirectoryPath: ""$($BuildDirectoryPath)"""
        Write-Debug @InternalCommandSplat -Message "DistributionDirectoryPath: ""$($DistributionDirectoryPath)"""
        Write-Debug @InternalCommandSplat -Message "ModuleDirectoryPath: ""$($ModuleDirectoryPath)"""
        Write-Debug @InternalCommandSplat -Message "ModuleName: ""$($ModuleName)"""
        Write-Debug @InternalCommandSplat -Message "SourceCodeDirectoryPath: ""$($SourceCodeDirectoryPath)"""
        Write-Debug @InternalCommandSplat -Message "PSBoundParameters: $(ConvertTo-Json @ExternalCommandSplat -InputObject $PSBoundParameters -Depth 100)"
    }
}
catch {
    throw $PSItem
}

#######################################################
# Clear out the distribution directory
try {
    $DistributionDirectoryPathChildItems = $null
    $DistributionDirectoryPathChildItems = Get-ChildItem @ExternalCommandSplat -Path $DistributionDirectoryPath -Recurse | Sort-Object @ExternalCommandSplat -Descending -Property FullName

    $DistributionDirectoryPathChildItemsCount = $null
    $DistributionDirectoryPathChildItemsCount = $DistributionDirectoryPathChildItems | Measure-Object @ExternalCommandSplat | Select-Object @ExternalCommandSplat -ExpandProperty Count 
    Write-Debug @InternalCommandSplat -Message "DistributionDirectoryPathChildItemsCount: ""$($DistributionDirectoryPathChildItemsCount)"""

    If ($DistributionDirectoryPathChildItemsCount -ge 1) {

        If ($PSCmdlet.ShouldProcess($DistributionDirectoryPath, "Clear Distribution Directory") -eq $true) {
            Write-Verbose @ExternalCommandSplat -Message "Clearing Distribution Directory: ""$($DistributionDirectoryPath)"""
            $DistributionDirectoryPathChildItems | Remove-Item @ExternalCommandSplat -Recurse -Force -Confirm:$false -WhatIf:$WhatIfPreference
        }
        Else {
            Throw "Distribution Directory ""$($DistributionDirectoryPath)"" must be cleared before continuing."
        }
    }
   
}
catch {
    Throw $PSItem
}

#######################################################
# Copy src code to dist
try {
    
    $SourceCodeDirectoryPathWithWildCard = $null
    $SourceCodeDirectoryPathWithWildCard = Join-Path @ExternalCommandSplat -Path $SourceCodeDirectoryPath -ChildPath "*"

    Copy-Item -Path $SourceCodeDirectoryPathWithWildCard -Destination $DistributionDirectoryPath -Container -Exclude $SourceDirectoryFilePatternToExclude -Force -Recurse -WhatIf:$WhatIfPreference -Confirm:$false 

}
catch {
    Throw $PSItem
}

#######################################################
# Import Module Manifest Parameters
try {
    $ModuleManifestParametersContent = $null
    $ModuleManifestParametersContent = Get-Content @ExternalCommandSplat -Path $ModuleManifestParametersSourceFilePath -Raw
    
    $ModuleManifestParameters = $null
    $ModuleManifestParameters = ConvertFrom-Json @ExternalCommandSplat -InputObject $ModuleManifestParametersContent -AsHashtable -Depth 100
}
catch {
    Throw $PSItem
}

#######################################################
# Analyze ModuleVersion
try {

    $ModuleVersion = $null
    If ([string]::IsNullOrEmpty($ModuleManifestParameters.ModuleVersion) -eq $true) {
        $ModuleVersion = [semver]"0.0.0"
        Write-Verbose @InternalCommandSplat -Message "Will set ModuleVersion to ""$($ModuleVersion.ToString())"""
    }
    Else {
        $PreviousModuleVersion = $null
        $PreviousModuleVersion = [semver]$ModuleManifestParameters.ModuleVersion.Clone()

        $NewModulePatchVersion = $null
        $NewModulePatchVersion = $PreviousModuleVersion.Patch + 1
        
        $ModuleVersion = [semver]::New($PreviousModuleVersion.Major, $PreviousModuleVersion.Minor, $NewModulePatchVersion)
        

        Write-Verbose @InternalCommandSplat -Message "Will increment patch version from ""$($PreviousModuleVersion.ToString())"" to ""$($ModuleVersion.ToString())"""
    }

    $ModuleManifestParameters.ModuleVersion = $ModuleVersion.ToString()


}
catch {
    Throw $PSItem
}

#######################################################
# Rename and set Root Module
try {

    $RootModuleFilePath = $null
    $RootModuleFilePath = Join-Path @ExternalCommandSplat -Path $DistributionDirectoryPath -ChildPath $RootModuleFileName -Resolve 

    $RootModuleFileNewName = $null
    $RootModuleFileNewName = "$($ModuleName).psm1"

    Write-Verbose @InternalCommandSplat -Message "Renaming root module from ""$($RootModuleFileName)"" to ""$($RootModuleFileNewName)"""
    Rename-Item @ExternalCommandSplat -Path $RootModuleFilePath -NewName $RootModuleFileNewName -Force -Confirm:$false -WhatIf:$WhatIfPreference

    $ModuleManifestParameters.RootModule = $RootModuleFileNewName.Clone()


}
catch {
    Throw $PSItem
}

#######################################################
# Set GUID if missing
try {

    $NewGUID = $null
    $NewGUID = New-Guid @ExternalCommandSplat | Select-Object -ExpandProperty Guid

    If ($ModuleManifestParameters.Keys -contains 'Guid') {

        if ([string]::IsNullOrEmpty($ModuleManifestParameters.Guid) -eq $true) {
            Write-Verbose -Message "Setting a GUID parameter value in the module manifest"
            $ModuleManifestParameters.Guid = $NewGUID
        }
    }
    Else {
        Write-Verbose -Message "Adding a GUID parameter to the module manifest"
        $ModuleManifestParameters.Add('Guid', $NewGUID)
    }

}
catch {
    Throw $PSItem
}

#######################################################
# Find Public Functions
try {
    $AllPublicFunctionFiles = $null
    $AllPublicFunctionFiles = Get-ChildItem @ExternalCommandSplat -Path $DistributionDirectoryPath -Recurse -Filter *.ps1 -File | Where-Object @ExternalCommandSplat -FilterScript {$PSItem.FullName -like "*Public*Functions*"}

    $AllPublicFunctionFilesCount = $null
    $AllPublicFunctionFilesCount = $AllPublicFunctionFiles | Measure-Object @ExternalCommandSplat | Select-Object @ExternalCommandSplat -ExpandProperty Count
    Write-Debug @InternalCommandSplat -Message "AllPublicFunctionFilesCount: ""$($AllPublicFunctionFilesCount)"""

    Foreach ($PublicFunctionFile in $AllPublicFunctionFiles) {
        Write-Verbose @InternalCommandSplat -Message "Loading Function(s) from path ""$($PublicFunctionFile.FullName)"""
        . $PublicFunctionFile.FullName
    }

    $AllModuleFunctionCommands = $null
    $AllModuleFunctionCommands = Get-ChildItem @ExternalCommandSplat -Path Function:\ -Recurse | Where-Object @ExternalCommandSplat -FilterScript {$PSItem.ScriptBlock.File -like "$($DistributionDirectoryPath)\*Public*Function*"}

    $AllAliasesToExport = $null
    $AllAliasesToExport = [System.Collections.ArrayList]::new()

    Foreach ($AliasToExport in $ModuleManifestParameters.AliasesToExport) {
        [void]$AllAliasesToExport.Add($AliasToExport)
    }

    $AllFunctionsToExport = $null
    $AllFunctionsToExport = [System.Collections.ArrayList]::new()

    Foreach ($FunctionToExport in $ModuleManifestParameters.FunctionsToExport) {
        [void]$AllFunctionsToExport.Add($FunctionToExport)
    }

    Foreach ($ModuleFunctionCommand in $AllModuleFunctionCommands) {

        Foreach ($Alias in $ModuleFunctionCommand.ScriptBlock.Attributes.AliasNames) {
            If ($AllAliasesToExport -notcontains $Alias) {
                [void]$AllAliasesToExport.Add($Alias)
            }
        }

        If ($AllFunctionsToExport -notcontains $ModuleFunctionCommand.Name) {
            [void]$AllFunctionsToExport.Add($ModuleFunctionCommand.Name)
        }
    }

    $ModuleManifestParameters.AliasesToExport = $AllAliasesToExport 
    $ModuleManifestParameters.FunctionsToExport = $AllFunctionsToExport 

}
catch {
    Throw $PSItem
}

#######################################################
# Deal with the remaining module manifest parameters
try {

    $AllModuleManifestParameterKeysToRemove = $null
    $AllModuleManifestParameterKeysToRemove = [System.Collections.ArrayList]::new()

    Foreach ($ModuleManifestParameterKey in $ModuleManifestParameters.Keys) {

        $ModuleManifestParameter = $null
        $ModuleManifestParameter = $ModuleManifestParameters.$ModuleManifestParameterKey

        If ([string]::IsNullOrEmpty($ModuleManifestParameter) -eq $true) {
            [void]$AllModuleManifestParameterKeysToRemove.Add($ModuleManifestParameterKey)
        }
    }

    Foreach ($ModuleManifestParameterKeyToRemove in $AllModuleManifestParameterKeysToRemove) {

        Write-Verbose @InternalCommandSplat -Message "Removing module manifest parameter ""$($ModuleManifestParameterKeyToRemove)"" because its null or empty"
        $ModuleManifestParameters.Remove($ModuleManifestParameterKeyToRemove)
    }

}
catch {
    Throw $PSItem
}

#######################################################
# Export debug information
try {
    
    If ($DebugInternalEnabled -eq $true) {
        Write-Debug @InternalCommandSplat -Message "ModuleManifestParameters: $(ConvertTo-Json @ExternalCommandSplat -InputObject $ModuleManifestParameters -Depth 100)"
    }
}
catch {
    Throw $PSItem
}

#######################################################
# Create the new manifest
try {
    $ModuleManifestFileName = $null
    $ModuleManifestFileName = "$($ModuleName).psd1"

    $ModuleManifestFilePath = $null
    $ModuleManifestFilePath = Join-Path @ExternalCommandSplat -Path $DistributionDirectoryPath -ChildPath $ModuleManifestFileName

    If ($PSCmdlet.ShouldProcess($ModuleManifestFilePath, "Overwrite") -eq $true) {
        Write-Verbose @ExternalCommandSplat -Message "Overwriting module manifest file : ""$($ModuleManifestFilePath)"""
        New-ModuleManifest @ExternalCommandSplat @ModuleManifestParameters -Path $ModuleManifestFilePath -Confirm:$false -WhatIf:$WhatIfPreference 
    }
    Else {
        Throw "ModuleManifestFilePath ""$($ModuleManifestFilePath)"" must be overwritten before continuing"
    }
    
    If ($DebugInternalEnabled -eq $true) {
        Write-Debug @InternalCommandSplat -Message "ModuleManifestParameters: $(ConvertTo-Json @ExternalCommandSplat -InputObject $ModuleManifestParameters -Depth 100)"
    }
}
catch {
    Throw $PSItem
}

#######################################################
# Test the new manifest
try {
    Test-ModuleManifest @ExternalCommandSplat -Path $ModuleManifestFilePath
}
catch {
    Throw $PSItem
}

#######################################################
# Save the GUID and Version back to the ModuleManifest.Json
try {
    $SaveModuleManifestParameters = $null
    $SaveModuleManifestParameters = ConvertFrom-Json @ExternalCommandSplat -InputObject $ModuleManifestParametersContent -AsHashtable -Depth 100

    $SaveModuleManifestParameters.Guid = $ModuleManifestParameters.Guid
    $SaveModuleManifestParameters.ModuleVersion = $ModuleManifestParameters.ModuleVersion.ToString()
    
    ConvertTo-Json @ExternalCommandSplat -InputObject $SaveModuleManifestParameters -Depth 100  | Out-File @ExternalCommandSplat -FilePath $ModuleManifestParametersSourceFilePath -Force -Confirm:$false
}
catch {
    Throw $PSItem
}