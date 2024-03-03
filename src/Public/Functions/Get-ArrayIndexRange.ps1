function Get-ArrayIndexRange {
    <#
    .SYNOPSIS
    Gets a start and end index number.

    .DESCRIPTION
    Gets a start and end index number.  This is to make it easer to now how to reference the very first and last index so no math is needed.

    .INPUTS
    [system.collections.arraylist]

    .OUTPUTS
    [system.collections.arraylist]

    .EXAMPLE
    # Provides index count, plus the start and end index number
    Get-ArrayListRange -InputObject @("Dog","Cat","Pig","Cow")
    
    #>
    [CmdletBinding()]
    
    param (
        <#
        Sets the minimum number that should be returned within a possible range
        #>
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.ArrayList]$InputObject
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

        }
        catch {
            Throw $PSItem
        }

        #################################
        # Determine range
        try {
            $InputObjectCount = $null
            $InputObjectCount = $InputObject | Measure-Object @ExternalCommandSplat | Select-Object -ExpandProperty Count
            Write-Debug -Message "InputObjectCount: ""$($InputObjectCount)"""

            $IndexStart = $null
            $IndexStart = 0

            $IndexEnd = $null
            $IndexEnd = $InputObjectCount - 1

            $OutputObject = $null
            $OutputObject = [PSCustomObject]@{
                Count = $InputObjectCount
                Start = $IndexStart
                End = $IndexEnd
            }
            
        }
        catch {
            Throw $PSItem
        }

        #################################
        # Return result
        try {
            
            Write-Output @ExternalCommandSplat -InputObject $OutputObject
            
        }
        catch {
            Throw $PSItem
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
