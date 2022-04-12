[CmdletBinding(DefaultParameterSetName = 'None')]
param()
gci env:

Get-Module -Name "FitNesseConvert" | Remove-Module
Import-Module -Name "$PSScriptRoot/FitNesseConvert.psm1"
$rawResultsPath = "result.xml"
$content = Get-Content -Path "$rawResultsPath"
[xml]$testResult = [xml](Read-Xml -RawInput $content)
$details = (Convert-Xml -InputXml $testResult -XsltFile "FitNesseToDetailedResults.xslt")
$detailsPath = "DetailedResults.html"
$details | Out-File -FilePath $detailsPath | Out-Null

#Get-Module -Name "FitNesseConvert" | Remove-Module
#Import-Module -Name "$PSScriptRoot/FitNesseConvert.psm1"
#$root = Split-Path -Path $PSScriptRoot -Parent
#$testresultsPath = Join-Path -Path $root -ChildPath "testresult"
#$rawResultsPath = Join-Path -Path $testresultsPath -ChildPath "result.xml"
#$content = Get-Content -Path "$rawResultsPath"
#[xml]$testResult = [xml](Read-Xml -RawInput $content)
#$details = (Convert-Xml -InputXml $testResult -XsltFile "FitNesseToDetailedResults.xslt")
#$detailsPath = "$testResultsPath/DetailedResults.html"
#$details | Out-File -FilePath $detailsPath | Out-Null
#$nUnitOutput = Convert-Xml -InputXml $testResult -XsltFile "FitNesseToNUnit3.xslt"
#$nUnitOutputWithEnv = [xml](Edit-Environment -NUnitXml $nUnitOutput)
#$nUnitOutputFinal = [xml](Edit-Attachments -NUnitXml $nUnitOutputWithEnv -RawResults $RawResultsPath -Details $detailsPath)
#$nUnitOutputFinal.Save("$testResultsPath/results_nunit.xml")
