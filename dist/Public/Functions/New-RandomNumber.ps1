function New-RandomNumber {
    <#
    .SYNOPSIS
    Generate a cryptographically secure number

    .DESCRIPTION
    Generate a cryptographically secure number based on System.Security.Cryptography.RNGCryptoServiceProvider 

    .INPUTS
    [int]Minimum
    [int]Maximum 

    .OUTPUTS
    [int] : Cryptographically secure random number

    .EXAMPLE
    # Will generate a random number between 0 and 2147483647
    New-RandomNumber 

    .EXAMPLE
    # Will generate a random number between 10 and 50
    New-RandomNumber -Minimum 10 -Maximum 50
    
    #>
    [CmdletBinding()]
    
    param (
        <#
        Sets the minimum number that should be returned within a possible range
        #>
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Minimum = 0,

        <#
        Sets the maximum number that should be returned within a possible range
        #>
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Maximum = [int]::MaxValue
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

            $BufferSize = $null
            $BufferSize = 4
            Write-Debug @InternalCommandSplat -Message "BufferSize: ""$($BufferSize)"""

        }
        catch {
            Throw $PSItem
        }


        #################################
        # Validate range
        try {
            
            if ($Minimum -ge $Maximum) {
                Throw  "Invalid range: Minimum ""$($Minimum)"" must be less than Maximum ""$($Maximum)""."
            }
        }
        catch {
            Throw $PSItem
        }

        #################################
        # Generate the random number
        try {
            Write-Verbose @InternalCommandSplat -Message "Creating the RNGCryptoServiceProvider object"
            $RNGCryptoServiceProvider = $null
            $RNGCryptoServiceProvider = New-Object @ExternalCommandSplat -TypeName "System.Security.Cryptography.RNGCryptoServiceProvider"

            Write-Verbose @InternalCommandSplat -Message "Creating a buffer of bytes"
            $Buffer = $null
            $Buffer = New-Object @ExternalCommandSplat -TypeName "byte[]" -ArgumentList $BufferSize

            Write-Verbose @InternalCommandSplat -Message "Getting bytes"
            $RNGCryptoServiceProvider.GetBytes($Buffer)

            Write-Verbose @InternalCommandSplat -Message "Getting random value"
            $RandomValue = $null
            $RandomValue = [BitConverter]::ToUInt32($Buffer, 0)
            
            Write-Verbose @InternalCommandSplat -Message "Setting the range"
            $Range = $null
            $Range = $Maximum - $Minimum

            Write-Verbose @InternalCommandSplat -Message "Generating the random number"
            $RandomNumber = $null
            $RandomNumber = $Minimum + $RandomValue % ($Range + 1)

            Write-Verbose @InternalCommandSplat -Message "Returning the random number"
            Write-Output @ExternalCommandSplat -InputObject $RandomNumber
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
