[CmdletBinding()]
param ()

#################################
# Opening Message
try {
    
    Write-Verbose -Message "Start: ""$($MyInvocation.MyCommand.Name)""" -Verbose:$VerbosePreference
}
catch {
    throw $PSItem
}

#################################
# Debug and tracing
try {
    Write-Verbose -Message "Debug and tracing" -Verbose:$VerbosePreference

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
}
catch {
    throw $PSItem
}

#################################
# Variables: General
try {
    $UnicodeOrgLatestExtractedURI = $null
    $UnicodeOrgLatestExtractedURI = "https://www.unicode.org/Public/UCD/latest/ucd/extracted"
    Write-Debug @InternalCommandSplat -Message "UnicodeOrgLatestExtractedURI: ""$($UnicodeOrgLatestExtractedURI)"""

}
catch {
    Throw $PSItem
}

#################################
# Variables: Directories
try {
    Write-Verbose @InternalCommandSplat -Message "Variables: Directories"

    If ([System.String]::IsNullOrEmpty($PSScriptRoot) -eq $true) {
        $BuildDirectoryPath = $null
        $BuildDirectoryPath = Join-Path @ExternalCommandSplat -Path "." -ChildPath "Build" -Resolve
        Write-Debug @InternalCommandSplat -Message "BuildDirectoryPath: ""$($BuildDirectoryPath)"""

        $BuildLookupTablesDirectoryPath = $null
        $BuildLookupTablesDirectoryPath = Join-Path @ExternalCommandSplat -Path $BuildDirectoryPath -ChildPath "LookupTables" -Resolve
        Write-Debug @InternalCommandSplat -Message "BuildLookupTablesDirectoryPath: ""$($BuildLookupTablesDirectoryPath)"""

        $BuildLookupTablesUnicodeDirectoryPath = $null
        $BuildLookupTablesUnicodeDirectoryPath = Join-Path @ExternalCommandSplat -Path $BuildLookupTablesDirectoryPath -ChildPath "Unicode" -Resolve
        Write-Debug @InternalCommandSplat -Message "BuildLookupTablesUnicodeDirectoryPath: ""$($BuildLookupTablesUnicodeDirectoryPath)"""
    }
    Else {
        $BuildLookupTablesUnicodeDirectoryPath = $null
        $BuildLookupTablesUnicodeDirectoryPath = $PSScriptRoot
        Write-Debug @InternalCommandSplat -Message "BuildLookupTablesUnicodeDirectoryPath: ""$($BuildLookupTablesUnicodeDirectoryPath)"""

        $BuildLookupTablesDirectoryPath = $null
        $BuildLookupTablesDirectoryPath = Split-Path -Path $PSScriptRoot -Resolve
        Write-Debug @InternalCommandSplat -Message "BuildLookupTablesDirectoryPath: ""$($BuildLookupTablesDirectoryPath)"""

        $BuildDirectoryPath = $null
        $BuildDirectoryPath = Split-Path -Path $BuildLookupTablesDirectoryPath -Resolve
        Write-Debug @InternalCommandSplat -Message "BuildDirectoryPath: ""$($BuildDirectoryPath)"""
    }

    $BuildLookupTablesUnicodeUnicodeOrgDirectoryPath = $null
    $BuildLookupTablesUnicodeUnicodeOrgDirectoryPath = Join-Path @ExternalCommandSplat -Path $BuildLookupTablesUnicodeDirectoryPath -ChildPath 'UnicodeOrg_Latest_Extracted'
    Write-Debug @InternalCommandSplat -Message "BuildLookupTablesUnicodeUnicodeOrgDirectoryPath: ""$($BuildLookupTablesUnicodeUnicodeOrgDirectoryPath)"""


}
catch {
    throw $PSItem
}

#################################
# Unicode.org: Get the latest versions of the files
try {
    Write-Verbose @InternalCommandSplat -Message "Unicode.org: Get the latest versions of the files"
    
    $UnicodeOrgLatestExtractedRoot = $null
    $UnicodeOrgLatestExtractedRoot = Invoke-WebRequest @ExternalCommandSplat -Uri $UnicodeOrgLatestExtractedURI

    $AllUnicodeOrgLatestExtractedTextFilesToDownload = $null
    $AllUnicodeOrgLatestExtractedTextFilesToDownload = $UnicodeOrgLatestExtractedRoot.Links | Where-Object @ExternalCommandSplat -FilterScript {$PSItem.href -like "*.txt" -and $PSItem.href -notlike "http*"} 

    Foreach ($UnicodeOrgLatestExtractedTextFileToDownload in $AllUnicodeOrgLatestExtractedTextFilesToDownload) {
        Write-Verbose @InternalCommandSplat -Message "Downloading file ""$($UnicodeOrgLatestExtractedTextFileToDownload.href)"""
        
        $UnicodeOrgLatestExtractedTextFileToDownloadURI = $null
        $UnicodeOrgLatestExtractedTextFileToDownloadURI = "$($UnicodeOrgLatestExtractedURI)/$($UnicodeOrgLatestExtractedTextFileToDownload.href)"
        Write-Debug @InternalCommandSplat -Message "UnicodeOrgLatestExtractedTextFileToDownloadURI: ""$($UnicodeOrgLatestExtractedTextFileToDownloadURI)"""

        $DownloadUnicodeOrgLatestExtractedTextFilePath = $null
        $DownloadUnicodeOrgLatestExtractedTextFilePath = Join-Path @ExternalCommandSplat -Path $BuildLookupTablesUnicodeUnicodeOrgDirectoryPath -ChildPath $UnicodeOrgLatestExtractedTextFileToDownload.href
        Write-Debug @InternalCommandSplat -Message "DownloadUnicodeOrgLatestExtractedTextFilePath: ""$($DownloadUnicodeOrgLatestExtractedTextFilePath)"""

        $DownloadUnicodeOrgLatestExtractedTextFile = $null
        $DownloadUnicodeOrgLatestExtractedTextFile = Invoke-WebRequest @ExternalCommandSplat -Uri $UnicodeOrgLatestExtractedTextFileToDownloadURI -OutFile $DownloadUnicodeOrgLatestExtractedTextFilePath

    }

    Write-Verbose @InternalCommandSplat -Message "Variables: Directories"
}
catch {
    Throw $PSItem
}

#################################
# Create a variable for each file we're enumerating to make lookups faster
try {
    Write-Verbose @InternalCommandSplat -Message "Create a variable for each file we're enumerating to make lookups faster"

    Foreach ($UnicodeOrgLatestExtractedTextFileToDownload in $AllUnicodeOrgLatestExtractedTextFilesToDownload) {
        $DownloadUnicodeOrgLatestExtractedTextFilePath = $null
        $DownloadUnicodeOrgLatestExtractedTextFilePath = Join-Path @ExternalCommandSplat -Path $BuildLookupTablesUnicodeUnicodeOrgDirectoryPath -ChildPath $UnicodeOrgLatestExtractedTextFileToDownload.href
        Write-Debug @InternalCommandSplat -Message "DownloadUnicodeOrgLatestExtractedTextFilePath: ""$($DownloadUnicodeOrgLatestExtractedTextFilePath)"""

        $UnicodeOrgLatestExtractedTextFileBaseName = $null
        $UnicodeOrgLatestExtractedTextFileBaseName = Split-Path @ExternalCommandSplat -Path $UnicodeOrgLatestExtractedTextFileToDownload.href -LeafBase
    
        $UnicodeOrgLatestExtractedTextFileContents = $null
        $UnicodeOrgLatestExtractedTextFileContents = Get-Content @ExternalCommandSplat -Path $DownloadUnicodeOrgLatestExtractedTextFilePath -Raw

        $UnicodeOrgLatestExtractedTextFileVariable = $null
        $UnicodeOrgLatestExtractedTextFileVariable = New-Variable -Name "UnicodeOrgLatestExtracted$($UnicodeOrgLatestExtractedTextFileBaseName)" -Value $UnicodeOrgLatestExtractedTextFileContents -Force -Confirm:$false
    }

}
catch {
    Throw $PSItem
}

#################################
# ListAvailable
try {

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
    $AllUnicodeCharacters = Foreach ($UnicodeCodePointDecimalToLookup in $AllUnicodeCodePointDecimalsToLookupToLookup[100]) {
        
        Write-Debug @InternalCommandSplat -Message "UnicodeCodePointDecimalToLookup: ""$($UnicodeCodePointDecimalToLookup)"""

        $UnicodeCharacter = $null
        $UnicodeCharacter = [Ordered]@{
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
catch {
    Throw $PSItem
}

#################################
# Closing Message
Write-Verbose -Message "End: ""$($MyInvocation.MyCommand.Name)""" -Verbose:$VerbosePreference


