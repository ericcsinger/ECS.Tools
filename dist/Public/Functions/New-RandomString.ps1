function New-RandomString {
    <#
    .SYNOPSIS
    Generates a cryptographically random string

    .DESCRIPTION
    Generates a cryptographically random string

    .OUTPUTS
    [system.string] or [system.securestring]

    .EXAMPLE
    # Generate a 255 character long random string which includes whitespace.
    New-RandomString -MaximumLength 255 -IncludeWhiteSpace

    .EXAMPLE
    # Generate an AlphaNumeric string.
    New-RandomString -DisableASCIIPunctuation -DisableASCIISymbols

    .EXAMPLE
    # Generate a random string, but exclude brackets
    New-RandomString -CharactersToExclude @('[',']','{','}')
    
    #>
    [CmdletBinding()]
    [Alias(
    "Get-RandomString"
    )]

    param (
    
    # Maximum length you want the string to be
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [ValidateRange(1, [int]::MaxValue)]
    [int]$MaximumLength = 16,
    
    # Disables all numeric characters
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [switch]$DisableASCIIDigits,

    # Minimum number of numeric characters
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [ValidateRange(1, [int]::MaxValue)]
    [int]$MinimumASCIIDigits = 1,
    
    # Disables all punctuation characters
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [switch]$DisableASCIIPunctuation,

    # Minimum number of punctuation characters
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [ValidateRange(1, [int]::MaxValue)]
    [int]$MinimumASCIIPunctuation = 1,

    # Disables all symbol characters
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [switch]$DisableASCIISymbols,

    # Minimum number of symbols
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [ValidateRange(1, [int]::MaxValue)]
    [int]$MinimumASCIISymbols = 1,
    
    # Disables all lowercase letter characters
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [switch]$DisableLatinAlphabetLowerCase,

    # Minimum number of lowercase letter characters
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [ValidateRange(1, [int]::MaxValue)]
    [int]$MinimumLatinAlphabetLowerCase = 1,
    
    # Disables all uppercase letter characters
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [switch]$DisableLatinAlphabetUpperCase,

    # Minimum number of uppercase characters
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [ValidateRange(1, [int]::MaxValue)]
    [int]$MinimumLatinAlphabetUpperCase = 1,

    # includes a space character
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [switch]$IncludeWhiteSpace,

    # Minimum number of space characters
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [int]$MinimumIncludeWhiteSpace = 1,

    <#
    This should be a string array of characters you wish to exclude.  Examples include

    @("A","b")

    @('1','/')

    #>
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$CharactersToExclude,

    # Use this to return a secure string instead of clear text
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [switch]$AsSecureString

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

            $EnableASCIIDigits = $null
            $EnableASCIIDigits = If ($PSBoundParameters.DisableASCIIDigits.IsPresent -eq $true) {$false} else {$true}
            Write-Debug @InternalCommandSplat -Message "EnableASCIIDigits: ""$($EnableASCIIDigits)"""

            $EnableASCIIPunctuation = $null
            $EnableASCIIPunctuation = If ($PSBoundParameters.DisableASCIIPunctuation.IsPresent -eq $true) {$false} else {$true}
            Write-Debug @InternalCommandSplat -Message "EnableASCIIPunctuation: ""$($EnableASCIIPunctuation)"""

            $EnableASCIISymbols = $null
            $EnableASCIISymbols = If ($PSBoundParameters.DisableASCIISymbols.IsPresent -eq $true) {$false} else {$true}
            Write-Debug @InternalCommandSplat -Message "EnableASCIISymbols: ""$($EnableASCIISymbols)"""

            $EnableLatinAlphabetLowerCase = $null
            $EnableLatinAlphabetLowerCase = If ($PSBoundParameters.DisableLatinAlphabetLowerCase.IsPresent -eq $true) {$false} else {$true}
            Write-Debug @InternalCommandSplat -Message "EnableLatinAlphabetLowerCase: ""$($EnableLatinAlphabetLowerCase)"""

            $EnableLatinAlphabetUpperCase = $null
            $EnableLatinAlphabetUpperCase = If ($PSBoundParameters.DisableLatinAlphabetUpperCase.IsPresent -eq $true) {$false} else {$true}
            Write-Debug @InternalCommandSplat -Message "EnableLatinAlphabetUpperCase: ""$($EnableLatinAlphabetUpperCase)"""

            $EnableWhiteSpace = $null
            $EnableWhiteSpace = $PSBoundParameters.IncludeWhiteSpace.IsPresent -eq $true
            Write-Debug @InternalCommandSplat -Message "EnableWhiteSpace: ""$($EnableWhiteSpace)"""

            $EnableSecureString = $null
            $EnableSecureString = $PSBoundParameters.AsSecureString.IsPresent -eq $true
            Write-Debug @InternalCommandSplat -Message "EnableWhiteSpace: ""$($EnableWhiteSpace)"""

            $RandomCharacters = $null
            $RandomCharacters = [System.Collections.ArrayList]::new()

        }
        catch {
            throw $PSItem
        }
        
        #################################
        # Validate minimums vs maximums
        try {
            Write-Verbose @InternalCommandSplat -Message "Validating the minimum vs maximum length"

            $MinimumLength = $null
            $MinimumLength = 0

            If ($EnableASCIIDigits -eq $true) {
                $MinimumLength = $MinimumLength + $MinimumASCIIDigits
            }

            If ($EnableASCIIPunctuation -eq $true) {
                $MinimumLength = $MinimumLength + $MinimumASCIIPunctuation
            }

            If ($EnableASCIISymbols -eq $true) {
                $MinimumLength = $MinimumLength + $MinimumASCIISymbols
            }

            If ($EnableLatinAlphabetLowerCase -eq $true) {
                $MinimumLength = $MinimumLength + $MinimumLatinAlphabetLowerCase
            }

            If ($EnableLatinAlphabetUpperCase -eq $true) {
                $MinimumLength = $MinimumLength + $MinimumLatinAlphabetUpperCase
            }

            If ($EnableWhiteSpace -eq $true) {
                $MinimumLength = $MinimumLength + $MinimumIncludeWhiteSpace
            }

            Write-Debug @InternalCommandSplat -Message "MinimumLength: ""$($MinimumLength)"""

            if ($MinimumLength -gt $MaximumLength) {
                Throw "You have elected to have a MinimumLength of ""$($MinimumLength)"" which is greater than the ""$($MaximumLength)"".  Either increase the MaximumLength, or adjust / disable certain character types."
            }

        }
        catch {
            throw $PSItem
        }

        #################################
        # Get Random Character LookUp Table
        try {
            Write-Verbose @InternalCommandSplat -Message "Get Character LookUp Table"
            $CharacterLookUpTable = $null
            $CharacterLookUpTable = Get-CharacterLookUpTable @ExternalCommandSplat -AsHashTable
        }
        catch {
            throw $PSItem
        }
        
        #################################
        # Populate all allowed characters and seed random string
        try {
            Write-Verbose @InternalCommandSplat -Message "Remove Character types excluded from lookup table"

            $AllCharactersMerged = $null
            $AllCharactersMerged = [System.Collections.ArrayList]::new()

            #################################
            # ASCIIDigits

            If ($EnableASCIIDigits -eq $true) {

                #################################
                # Variables

                $CharacterCounter = $null
                $CharacterCounter = 1..$MinimumASCIIDigits

                $CharactersToLookup = $null
                $CharactersToLookup = $CharacterLookUpTable.ASCIIDigits

                $AllCharactersToRandomlySelect = $null
                $AllCharactersToRandomlySelect = [System.Collections.ArrayList]::new()

                #################################
                # Repeatable process

                Foreach ($Character in $CharactersToLookup) {
                    if ($CharactersToExclude -cnotcontains $Character) {
                        [void]$AllCharactersMerged.Add($Character)
                        [void]$AllCharactersToRandomlySelect.Add($Character)
                    }
                    Else {
                        Write-Debug @InternalCommandSplat -Message "Excluding Character: ""$($Character)"""
                    }
                }

                $CharacterRange = $null
                $CharacterRange = Get-ArrayIndexRange @ExternalCommandSplat -InputObject $AllCharactersToRandomlySelect

                Foreach ($LoopCounter in $CharacterCounter) {
                    $RandomCharacterSelector = $null
                    $RandomCharacterSelector = New-RandomNumber @ExternalCommandSplat -Minimum $CharacterRange.Start -Maximum $CharacterRange.End

                    [void]$RandomCharacters.Add( $AllCharactersToRandomlySelect[$RandomCharacterSelector] )

                }
            }

            #################################
            # ASCIIPunctuation

            $AllASCIIPunctuation = $null
            $AllASCIIPunctuation = [System.Collections.ArrayList]::new()

            If ($EnableASCIIPunctuation -eq $true) {
                #################################
                # Variables

                $CharacterCounter = $null
                $CharacterCounter = 1..$MinimumASCIIPunctuation

                $CharactersToLookup = $null
                $CharactersToLookup = $CharacterLookUpTable.ASCIIPunctuation

                $AllCharactersToRandomlySelect = $null
                $AllCharactersToRandomlySelect = [System.Collections.ArrayList]::new()

                #################################
                # Repeatable process

                Foreach ($Character in $CharactersToLookup) {
                    if ($CharactersToExclude -cnotcontains $Character) {
                        [void]$AllCharactersMerged.Add($Character)
                        [void]$AllCharactersToRandomlySelect.Add($Character)
                    }
                    Else {
                        Write-Debug @InternalCommandSplat -Message "Excluding Character: ""$($Character)"""
                    }
                }

                $CharacterRange = $null
                $CharacterRange = Get-ArrayIndexRange @ExternalCommandSplat -InputObject $AllCharactersToRandomlySelect

                Foreach ($LoopCounter in $CharacterCounter) {
                    $RandomCharacterSelector = $null
                    $RandomCharacterSelector = New-RandomNumber @ExternalCommandSplat -Minimum $CharacterRange.Start -Maximum $CharacterRange.End

                    [void]$RandomCharacters.Add( $AllCharactersToRandomlySelect[$RandomCharacterSelector] )

                }
            }

            #################################
            # ASCIISymbols

            $AllASCIISymbols = $null
            $AllASCIISymbols = [System.Collections.ArrayList]::new()

            If ($EnableASCIISymbols -eq $true) {
                
                #################################
                # Variables

                $CharacterCounter = $null
                $CharacterCounter = 1..$MinimumASCIISymbols

                $CharactersToLookup = $null
                $CharactersToLookup = $CharacterLookUpTable.ASCIISymbols

                $AllCharactersToRandomlySelect = $null
                $AllCharactersToRandomlySelect = [System.Collections.ArrayList]::new()

                #################################
                # Repeatable process

                Foreach ($Character in $CharactersToLookup) {
                    if ($CharactersToExclude -cnotcontains $Character) {
                        [void]$AllCharactersMerged.Add($Character)
                        [void]$AllCharactersToRandomlySelect.Add($Character)
                    }
                    Else {
                        Write-Debug @InternalCommandSplat -Message "Excluding Character: ""$($Character)"""
                    }
                }

                $CharacterRange = $null
                $CharacterRange = Get-ArrayIndexRange @ExternalCommandSplat -InputObject $AllCharactersToRandomlySelect

                Foreach ($LoopCounter in $CharacterCounter) {
                    $RandomCharacterSelector = $null
                    $RandomCharacterSelector = New-RandomNumber @ExternalCommandSplat -Minimum $CharacterRange.Start -Maximum $CharacterRange.End

                    [void]$RandomCharacters.Add( $AllCharactersToRandomlySelect[$RandomCharacterSelector] )

                }
            }

            #################################
            # LatinAlphabetLowerCases

            $AllLatinAlphabetLowerCases = $null
            $AllLatinAlphabetLowerCases = [System.Collections.ArrayList]::new()

            If ($EnableLatinAlphabetLowerCase -eq $true) {
                #################################
                # Variables

                $CharacterCounter = $null
                $CharacterCounter = 1..$MinimumLatinAlphabetLowerCase

                $CharactersToLookup = $null
                $CharactersToLookup = $CharacterLookUpTable.LatinAlphabetLowerCase

                $AllCharactersToRandomlySelect = $null
                $AllCharactersToRandomlySelect = [System.Collections.ArrayList]::new()

                #################################
                # Repeatable process

                Foreach ($Character in $CharactersToLookup) {
                    if ($CharactersToExclude -cnotcontains $Character) {
                        [void]$AllCharactersMerged.Add($Character)
                        [void]$AllCharactersToRandomlySelect.Add($Character)
                    }
                    Else {
                        Write-Debug @InternalCommandSplat -Message "Excluding Character: ""$($Character)"""
                    }
                }

                $CharacterRange = $null
                $CharacterRange = Get-ArrayIndexRange @ExternalCommandSplat -InputObject $AllCharactersToRandomlySelect

                Foreach ($LoopCounter in $CharacterCounter) {
                    $RandomCharacterSelector = $null
                    $RandomCharacterSelector = New-RandomNumber @ExternalCommandSplat -Minimum $CharacterRange.Start -Maximum $CharacterRange.End

                    [void]$RandomCharacters.Add( $AllCharactersToRandomlySelect[$RandomCharacterSelector] )

                }
            }

            #################################
            # LatinAlphabetUpperCases

            $AllLatinAlphabetUpperCases = $null
            $AllLatinAlphabetUpperCases = [System.Collections.ArrayList]::new()

            If ($EnableLatinAlphabetUpperCase -eq $true) {
                #################################
                # Variables

                $CharacterCounter = $null
                $CharacterCounter = 1..$MinimumLatinAlphabetUpperCase

                $CharactersToLookup = $null
                $CharactersToLookup = $CharacterLookUpTable.LatinAlphabetUpperCase

                $AllCharactersToRandomlySelect = $null
                $AllCharactersToRandomlySelect = [System.Collections.ArrayList]::new()

                #################################
                # Repeatable process

                Foreach ($Character in $CharactersToLookup) {
                    if ($CharactersToExclude -cnotcontains $Character) {
                        [void]$AllCharactersMerged.Add($Character)
                        [void]$AllCharactersToRandomlySelect.Add($Character)
                    }
                    Else {
                        Write-Debug @InternalCommandSplat -Message "Excluding Character: ""$($Character)"""
                    }
                }

                $CharacterRange = $null
                $CharacterRange = Get-ArrayIndexRange @ExternalCommandSplat -InputObject $AllCharactersToRandomlySelect

                Foreach ($LoopCounter in $CharacterCounter) {
                    $RandomCharacterSelector = $null
                    $RandomCharacterSelector = New-RandomNumber @ExternalCommandSplat -Minimum $CharacterRange.Start -Maximum $CharacterRange.End

                    [void]$RandomCharacters.Add( $AllCharactersToRandomlySelect[$RandomCharacterSelector] )

                }
            }

            #################################
            # WhiteSpace

            If ($EnableWhiteSpace -eq $true) {
                #################################
                # Variables

                $CharacterCounter = $null
                $CharacterCounter = 1..$MinimumIncludeWhiteSpace

                #################################
                # Repeatable process

                [void]$AllCharactersMerged.Add(' ')

                Foreach ($LoopCounter in $CharacterCounter) {
                   
                    [void]$RandomCharacters.Add( ' ' )

                }
            }

        }
        catch {
            throw $PSItem
        }

        #################################
        # Fill random string
        try {
            Write-Verbose @InternalCommandSplat -Message "Filling the rest of the random string"

            $MergedCharacterRange = $null
            $MergedCharacterRange = Get-ArrayIndexRange @ExternalCommandSplat -InputObject $AllCharactersMerged
            
            $RandomCharactersCount = $null
            $RandomCharactersCount = $RandomCharacters | Measure-Object @ExternalCommandSplat | Select-Object @ExternalCommandSplat -ExpandProperty Count
            Write-Debug @InternalCommandSplat -Message "RandomStringCount: ""$($RandomCharactersCount)"""

            While ($RandomCharactersCount -lt $MaximumLength) {

                $RandomCharacterSelector = $null
                $RandomCharacterSelector = New-RandomNumber @ExternalCommandSplat -Minimum $MergedCharacterRange.Start -Maximum $MergedCharacterRange.End

                [void]$RandomCharacters.Add($AllCharactersMerged[$RandomCharacterSelector])

                $RandomCharactersCount = $null
                $RandomCharactersCount = $RandomCharacters | Measure-Object @ExternalCommandSplat | Select-Object @ExternalCommandSplat -ExpandProperty Count
                Write-Debug @InternalCommandSplat -Message "RandomStringCount: ""$($RandomCharactersCount)"""
            }

            #Write-Debug @InternalCommandSplat -Message "RandomCharacters: ""$(ConvertTo-Json @ExternalCommandSplat -InputObject $RandomCharacters)"""

        }
        catch {
            throw $PSItem
        }

        #################################
        # Randomize the the array of random characters
        try {
            Write-Verbose @InternalCommandSplat -Message "Randomize the the array of random characters"

            $RandomCharactersRandomSort = $null
            $RandomCharactersRandomSort = ConvertTo-RandomArrayList @ExternalCommandSplat -InputObject $RandomCharacters 
            #Write-Debug @InternalCommandSplat -Message "RandomCharactersRandomSort: ""$(ConvertTo-Json @ExternalCommandSplat -InputObject $RandomCharactersRandomSort)"""
        }
        catch {
            Throw $PSItem
        }

        #################################
        # Convert to string, and return output
        try {
            Write-Verbose @InternalCommandSplat -Message "Convert to string, and return output"

            $RandomString = $null
            $RandomString = $RandomCharactersRandomSort -join ''
            
            If ($EnableSecureString -eq $false) {
                Write-Verbose @InternalCommandSplat -Message "Return plain text string"

                Write-Output @ExternalCommandSplat -InputObject $RandomString
            }
            Else {
                Write-Verbose @InternalCommandSplat -Message "Return secure text string"

                $RandomSecureString = $null
                $RandomSecureString = ConvertTo-SecureString @ExternalCommandSplat -String $RandomString -AsPlainText -Force

                Write-Output @ExternalCommandSplat -InputObject $RandomSecureString
            }

            

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



