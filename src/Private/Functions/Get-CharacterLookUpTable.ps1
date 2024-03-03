function Get-CharacterLookUpTable {
    [CmdletBinding()]
    [Alias()]
    
    param (

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [switch]$AsHashTable
    )
    
    begin {
        try {
            #################################
            # Opening Message
            Write-Verbose -Message "Function Start: ""$($MyInvocation.MyCommand.Name)""" -Verbose:$VerbosePreference
        }
        catch {
            throw $PSItem
        }
    }
    
    process {
        
        #################################
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
                Debug       = $DebugAllEnabled
                ErrorAction = "Stop"
                Verbose     = $VerboseAllEnabled
            }
            If ($DebugInternalEnabled -eq $true) {
                Write-Debug -Message "ExternalCommandSplat: $(ConvertTo-Json @ExternalCommandSplat -InputObject $ExternalCommandSplat)" -Debug:$DebugPreference
            }
            
            $InternalCommandSplat = $null
            $InternalCommandSplat = @{
                Debug       = $DebugInternalEnabled
                ErrorAction = "Stop"
                Verbose     = $VerboseInternalEnabled
            }
            If ($DebugInternalEnabled -eq $true) {
                Write-Debug -Message "InternalCommandSplat: $(ConvertTo-Json @ExternalCommandSplat -InputObject $InternalCommandSplat)" -Debug:$DebugPreference
            }

            $CharacterLookupTableFilePath = $null
            $CharacterLookupTableFilePath = Join-Path @ExternalCommandSplat -Path $PrivateLookupTablesDirectoryPath -ChildPath 'CharacterLookupTable.json' -Resolve
            If ($DebugInternalEnabled -eq $true) {
                Write-Debug @InternalCommandSplat -Message "CharacterLookupTableFilePath: ""$($CharacterLookupTableFilePath)"""
            }
        }
        catch {
            throw $PSItem
        }
        
        #################################
        # Import lookup table
        try {
            Write-Verbose @InternalCommandSplat -Message "Importing the lookup table"
            $CharacterLookupTableContent = $null
            $CharacterLookupTableContent = Get-Content @ExternalCommandSplat -Path $CharacterLookupTableFilePath -Raw

            $CharacterLookupTableSplat = $null
            $CharacterLookupTableSplat = @{
                Depth = 100
                InputObject = $CharacterLookupTableContent
            }

            If ($PSBoundParameters.AsHashTable.IsPresent -eq $true) {
                $CharacterLookupTableSplat.Add("AsHashTable", $true)
            }
            
            $CharacterLookupTable = $null
            $CharacterLookupTable = ConvertFrom-Json @ExternalCommandSplat @CharacterLookupTableSplat
        }
        catch {
            throw $PSItem
        }

        #################################
        # Return object
        try {
            Write-Output @ExternalCommandSplat -InputObject $CharacterLookupTable
        }
        catch {
            throw $PSItem
        }
    
    
    }
    
    end {
        #################################
        # Closing Message
        try {
            Write-Verbose -Message "Function End: ""$($MyInvocation.MyCommand.Name)""" -Verbose:$VerbosePreference
        }
        catch {
            Throw $PSItem
        }
    }
}



