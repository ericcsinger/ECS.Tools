[CmdletBinding()]
param ()


try {
    #################################
    # Opening Message
    Write-Verbose -Message "Script Start: ""$($MyInvocation.MyCommand.Name)""" -Verbose:$VerbosePreference

    #################################
    # Variables

    $Script:DebugAllEnabled = $null
    $Script:DebugAllEnabled = $Global:DebugPreference -eq 'Continue'
    Write-Debug -Message "DebugAllEnabled: ""$($DebugAllEnabled)""" -Debug:$DebugPreference

    $Script:VerboseAllEnabled = $null
    $Script:VerboseAllEnabled = $Global:VerbosePreference -eq 'Continue'
    Write-Debug -Message "VerboseAllEnabled: ""$($VerboseAllEnabled)""" -Debug:$DebugPreference

    $Script:DebugInternalEnabled = $null
    $Script:DebugInternalEnabled = $PSBoundParameters.Debug.IsPresent -eq $true -or $DebugAllEnabled -eq $true
    Write-Debug -Message "DebugInternalEnabled: ""$($DebugInternalEnabled)""" -Debug:$DebugPreference

    $Script:VerboseInternalEnabled = $null
    $Script:VerboseInternalEnabled = $PSBoundParameters.Verbose.IsPresent -eq $true -or $VerboseAllEnabled -eq $true
    Write-Debug -Message "VerboseInternalEnabled: ""$($VerboseInternalEnabled)""" -Debug:$DebugPreference

    $Script:ExternalCommandSplat = $null
    $Script:ExternalCommandSplat = @{
        Debug = $DebugAllEnabled
        ErrorAction = "Stop"
        Verbose = $VerboseAllEnabled
    }
    If ($DebugInternalEnabled -eq $true) {
        Write-Debug -Message "ExternalCommandSplat: $(ConvertTo-Json @ExternalCommandSplat -InputObject $ExternalCommandSplat)" -Debug:$DebugPreference
    }

    $Script:InternalCommandSplat = $null
    $Script:InternalCommandSplat = @{
        Debug = $DebugInternalEnabled
        ErrorAction = "Stop"
        Verbose = $VerboseInternalEnabled
    }
    If ($DebugInternalEnabled -eq $true) {
        Write-Debug -Message "InternalCommandSplat: $(ConvertTo-Json @ExternalCommandSplat -InputObject $InternalCommandSplat)" -Debug:$DebugPreference
    }

    $ModuleDirectoryPath = $null
    $ModuleDirectoryPath = $($PSScriptRoot)
    Write-Debug @InternalCommandSplat -Message "ModuleDirectoryPath: ""$($ModuleDirectoryPath)""" -Debug:$DebugPreference

    $BinariesDirectoryPath = $null
    $BinariesDirectoryPath = Join-Path @ExternalCommandSplat -Path $ModuleDirectoryPath -ChildPath 'Binaries' -Resolve
    Write-Debug @InternalCommandSplat -Message "BinariesDirectoryPath: ""$($BinariesDirectoryPath)""" -Debug:$DebugPreference

    $PrivateDirectoryPath = $null
    $PrivateDirectoryPath = Join-Path @ExternalCommandSplat -Path $ModuleDirectoryPath -ChildPath 'Private' -Resolve
    Write-Debug @InternalCommandSplat -Message "PrivateDirectoryPath: ""$($PrivateDirectoryPath)""" -Debug:$DebugPreference

    $PrivateFunctionsDirectoryPath = $null
    $PrivateFunctionsDirectoryPath = Join-Path @ExternalCommandSplat -Path $PrivateDirectoryPath -ChildPath 'Functions' -Resolve
    Write-Debug @InternalCommandSplat -Message "PrivateFunctionsDirectoryPath: ""$($PrivateFunctionsDirectoryPath)""" -Debug:$DebugPreference

    $PrivateLookupTablesDirectoryPath = $null
    $PrivateLookupTablesDirectoryPath = Join-Path @ExternalCommandSplat -Path $PrivateDirectoryPath -ChildPath 'LookupTables' -Resolve
    Write-Debug @InternalCommandSplat -Message "PrivateLookupTablesDirectoryPath: ""$($PrivateLookupTablesDirectoryPath)""" -Debug:$DebugPreference

    $PublicDirectoryPath = $null
    $PublicDirectoryPath = Join-Path @ExternalCommandSplat -Path $ModuleDirectoryPath -ChildPath 'Public' -Resolve
    Write-Debug @InternalCommandSplat -Message "PublicDirectoryPath: ""$($PublicDirectoryPath)""" -Debug:$DebugPreference

    $PublicFunctionsDirectoryPath = $null
    $PublicFunctionsDirectoryPath = Join-Path @ExternalCommandSplat -Path $PublicDirectoryPath -ChildPath 'Functions' -Resolve
    Write-Debug @InternalCommandSplat -Message "PublicFunctionsDirectoryPath: ""$($PublicFunctionsDirectoryPath)""" -Debug:$DebugPreference


}
catch {
    Throw $PSItem
}

#################################
# Load Functions
try {
    $AllPublicFunctions = $null
    $AllPublicFunctions = Get-ChildItem @ExternalCommandSplat -Path $PublicFunctionsDirectoryPath -Filter "*.ps1" -File

    Foreach ($PublicFunction in $AllPublicFunctions) {
        Write-Verbose @InternalCommandSplat -Message "Loading public function file ""$($PublicFunction.FullName)"""
        . $PublicFunction.FullName
    }

    $AllPrivateFunctions = $null
    $AllPrivateFunctions = Get-ChildItem @ExternalCommandSplat -Path $PrivateFunctionsDirectoryPath -Filter "*.ps1" -File

    Foreach ($PrivateFunction in $AllPrivateFunctions) {
        Write-Verbose @InternalCommandSplat -Message "Loading private function file ""$($PrivateFunction.FullName)"""
        . $PrivateFunction.FullName
    }

}
catch {
    Throw $PSItem
}

#################################
# Closing Message
try {
    Write-Verbose -Message "Exporting module members" -Verbose:$VerbosePreference
    Export-ModuleMember @ExternalCommandSplat -Function * -Alias *
}
catch {
    Throw $PSItem
}

#################################
# Closing Message
try {
    Write-Verbose -Message "Script End: ""$($MyInvocation.MyCommand.Name)""" -Verbose:$VerbosePreference
}
catch {
    Throw $PSItem
}
    
