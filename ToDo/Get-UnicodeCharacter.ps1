function Get-UnicodeCharacter {
    [CmdletBinding(
        DefaultParameterSetName = 'ListAvailable'
    )]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = 'ListAvailable')]
        [switch]$ListAvailable,

        [Parameter(Mandatory = $true, ParameterSetName = 'UnicodeCodePointDecimal', ValueFromPipelineByPropertyName = $true)]
        [ValidateRange([int]([System.Char]::MinValue), [int]([System.Char]::MaxValue) )]
        [int[]]$UnicodeCodePointDecimal  = -1,

        [Parameter(Mandatory = $true, ParameterSetName = 'UnicodeCharacter', ValueFromPipelineByPropertyName = $true)]
        [string[]]$UnicodeCharacter = $null
    )

    begin {
        try {
            #################################
            # Opening Message
            Write-Verbose -Message "Function Start: ""$($MyInvocation.MyCommand.Name)""" -Verbose:$VerbosePreference

            #################################
            # Variables

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
                Write-Debug -Message "InternalCommandSplat: $(ConvertTo-Json @ExternalCommandSplat -InputObject $InternalCommandSplat)" -Debug:$DebugPreference
            }

            $ModuleDirectoryPath = $null
            $ModuleDirectoryPath = Split-Path

        }
        catch {
            throw $PSItem
        }
    }

    process {

        Write-Debug @InternalCommandSplat -Message "ParameterSetName: ""$($PSCmdlet.ParameterSetName)"""

        #################################
        # ListAvailable
        try {
            If ($PSCmdlet.ParameterSetName -eq 'ListAvailable') {
                Write-Verbose @InternalCommandSplat -Message "Getting all unicode characters and their properties properties"

                $UnicodeCodePointDecimalMinValue = $null
                $UnicodeCodePointDecimalMinValue = [int]([System.Char]::MinValue)
                Write-Debug @InternalCommandSplat -Message "UnicodeCodePointDecimalMinValue: ""$($UnicodeCodePointDecimalMinValue)"""

                $UnicodeCodePointDecimalMaxValue = $null
                $UnicodeCodePointDecimalMaxValue = [int]([System.Char]::MaxValue)
                Write-Debug @InternalCommandSplat -Message "UnicodeCodePointDecimalMaxValue: ""$($UnicodeCodePointDecimalMaxValue)"""

                $AllUnicodeCodePointDecimalsToLookupToLookup = $null
                $AllUnicodeCodePointDecimalsToLookupToLookup = $UnicodeCodePointDecimalMinValue..$UnicodeCodePointDecimalMaxValue
                
                Write-Verbose @InternalCommandSplat -Message "Looping through all UnicodeCodePointDecimals, starting at ""$($UnicodeCodePointDecimalMinValue)"" and ending with ""$($UnicodeCodePointDecimalMaxValue)"""
               
                $AllUnicodeCharacters = $null
                $AllUnicodeCharacters = Foreach ($UnicodeCodePointDecimalToLookup in $AllUnicodeCodePointDecimalsToLookupToLookup) {
                    
                    Write-Debug @InternalCommandSplat -Message "UnicodeCodePointDecimalToLookup: ""$($UnicodeCodePointDecimalToLookup)"""

                    [PSCustomObject][Ordered]@{
                        CodePointDecimal = $UnicodeCodePointDecimalToLookup
                        CodePointHex = [System.Convert]::ToString($UnicodeCodePointDecimalToLookup, 16).PadLeft(4, '0')
                        Character = [System.Char]$UnicodeCodePointDecimalToLookup
                        Category = [System.Char]::GetUnicodeCategory($UnicodeCodePointDecimalToLookup)
                        IsAscii = [System.Char]::IsAscii($UnicodeCodePointDecimalToLookup)
                        IsAsciiDigit = [System.Char]::IsAsciiDigit($UnicodeCodePointDecimalToLookup)
                        IsAsciiHexDigit = [System.Char]::IsAsciiHexDigit($UnicodeCodePointDecimalToLookup)
                        IsAsciiHexDigitLower = [System.Char]::IsAsciiHexDigitLower($UnicodeCodePointDecimalToLookup)
                        IsAsciiHexDigitUpper = [System.Char]::IsAsciiHexDigitUpper($UnicodeCodePointDecimalToLookup)
                        IsAsciiLetter = [System.Char]::IsAsciiLetter($UnicodeCodePointDecimalToLookup)
                        IsAsciiLetterLower = [System.Char]::IsAsciiLetterLower($UnicodeCodePointDecimalToLookup)
                        IsAsciiLetterOrDigit = [System.Char]::IsAsciiLetterOrDigit($UnicodeCodePointDecimalToLookup)
                        IsAsciiLetterUpper = [System.Char]::IsAsciiLetterUpper($UnicodeCodePointDecimalToLookup)
                        IsControl = [System.Char]::IsControl($UnicodeCodePointDecimalToLookup)
                        IsDigit = [System.Char]::IsDigit($UnicodeCodePointDecimalToLookup)
                        IsHighSurrogate = [System.Char]::IsHighSurrogate($UnicodeCodePointDecimalToLookup)
                        IsLetter = [System.Char]::IsLetter($UnicodeCodePointDecimalToLookup)
                        IsLetterOrDigit = [System.Char]::IsLetterOrDigit($UnicodeCodePointDecimalToLookup)
                        IsLower = [System.Char]::IsLower($UnicodeCodePointDecimalToLookup)
                        IsLowSurrogate = [System.Char]::IsLowSurrogate($UnicodeCodePointDecimalToLookup)
                        IsNumber = [System.Char]::IsNumber($UnicodeCodePointDecimalToLookup)
                        IsPunctuation = [System.Char]::IsPunctuation($UnicodeCodePointDecimalToLookup)
                        IsSeparator = [System.Char]::IsSeparator($UnicodeCodePointDecimalToLookup)
                        IsSurrogate = [System.Char]::IsSurrogate($UnicodeCodePointDecimalToLookup)
                        IsSymbol = [System.Char]::IsSymbol($UnicodeCodePointDecimalToLookup)
                        IsUpper = [System.Char]::IsUpper($UnicodeCodePointDecimalToLookup)
                        IsWhiteSpace = [System.Char]::IsWhiteSpace($UnicodeCodePointDecimalToLookup)
                    }
                }

                Write-Verbose @InternalCommandSplat -Message "Returning AllUnicodeCharacters"
                Write-Output @ExternalCommandSplat -InputObject $AllUnicodeCharacters -NoEnumerate
            }
        }
        catch {
            Throw $PSItem
        }
    }

    end {
         #################################
        # Closing Message
        Write-Verbose -Message "Function End: ""$($MyInvocation.MyCommand.Name)""" -Verbose:$VerbosePreference
    }

}