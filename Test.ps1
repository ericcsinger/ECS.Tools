Remove-module 'ECS.Tools'
. .\build\build.ps1 -Confirm:$false -verbose -debug

$VerbosePreference = 'Continue'
$DebugPreference = 'Continue'

Import-Module -Name ".\dist\ECS.Tools.psd1"

$VerbosePreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue'

New-RandomString -Verbose -Debug

Get-CharacterLookUpTable -Verbose -Debug

Get-ArrayIndexRange -InputObject @(1,2,3)