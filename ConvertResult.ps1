[CmdletBinding(DefaultParameterSetName = 'None')]
param()
Get-Module -Name "FitNesseConvert" | Remove-Module
Import-Module -Name "$PSScriptRoot/FitNesseConvert.psm1"
$rawResultsPath = "result.xml"
$content = Get-Content -Path "$rawResultsPath"
[xml]$testResult = [xml](Read-Xml -RawInput $content)
if (!$testResult.InnerXml) { 
    throw "No XML output detected. This could happen when the test page was not found. Check the error log." 
}
$details = (Convert-Xml -InputXml $testResult -XsltFile "FitNesseToDetailedResults.xslt")
$detailsPath = "DetailedResults.html"
$details | Out-File -FilePath $detailsPath | Out-Null

$nUnitOutput = Convert-Xml -InputXml $testResult -XsltFile "FitNesseToNUnit3.xslt"
$nUnitOutputWithEnv = [xml](Edit-Environment -NUnitXml $nUnitOutput)
$nUnitOutputFinal = [xml](Edit-Attachments -NUnitXml $nUnitOutputWithEnv -RawResults $RawResultsPath -Details $detailsPath)
$nUnitOutputFinal.Save("results_nunit.xml")
