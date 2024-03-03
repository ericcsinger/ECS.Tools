function ConvertTo-RandomArrayList {
    <#
    .SYNOPSIS
    Resorts an index of items  in a cryptographically secure random way.

    .DESCRIPTION
    Resorts an index of items  in a cryptographically secure random way,  based on System.Security.Cryptography.RNGCryptoServiceProvider 

    .INPUTS
    [system.collections.arraylist]

    .OUTPUTS
    [system.collections.arraylist]

    .EXAMPLE
    # Sort a random set of strings
    ConvertTo-RandomArrayList -InputObject @("Dog","Cat","Pig","Cow")

    .EXAMPLE
    # Will generate a random number between 10 and 50
    ConvertTo-RandomArrayList -InputObject @(1,2,3,4,5,6,7,8,9) 
    
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

            $NewArray = $null
            $NewArray = [System.Collections.ArrayList]::new()

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

            While ($InputObjectCount -gt 0) {
                
                $InputObjectMaximumArrayIndex = $null
                $InputObjectMaximumArrayIndex = $InputObjectCount - 1
                Write-Debug -Message "InputObjectMaximumArrayIndex: ""$($InputObjectMaximumArrayIndex)"""

                $ArrayIndex = $null
                If ($InputObjectMaximumArrayIndex -gt 0) {
                    
                    $ArrayIndex = New-RandomNumber @ExternalCommandSplat -Minimum 0 -Maximum $InputObjectMaximumArrayIndex
                }
                Else {
                    $ArrayIndex = $InputObjectMaximumArrayIndex
                }

                
                
                [void]$NewArray.Add($InputObject[$ArrayIndex])
                $InputObject.RemoveAt($ArrayIndex)

                $InputObjectCount = $null
                $InputObjectCount = $InputObject | Measure-Object @ExternalCommandSplat | Select-Object -ExpandProperty Count
                Write-Debug -Message "InputObjectCount: ""$($InputObjectCount)"""
            }
            
        }
        catch {
            Throw $PSItem
        }

        #################################
        # Return result
        try {
            
            Write-Output @ExternalCommandSplat -InputObject $NewArray
            
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
