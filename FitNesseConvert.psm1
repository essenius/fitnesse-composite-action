# Copyright 2019-2022 Rik Essenius
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

class XsltFunctions {
    static [string]AddSecondsToTimestamp([string]$Timestamp, [double]$Seconds) {
		if ([double]::IsNaN($Seconds)) { $Seconds = 0 }
		$datetime = [DateTime]::Parse($Timestamp);
		return $datetime.AddSeconds($Seconds).ToUniversalTime().ToString("o");    
	}
	
	[bool]EndsWith([string]$Value, [string]$ValueToSearch) {  return $Value.EndsWith($ValueToSearch); }

	[string]Nz([string]$value, [string]$DefaultValue) { if ($Value) { return $Value } else { return $DefaultValue } }

    [string]Zulu([string]$Timestamp) { return [XsltFunctions]::AddSecondsToTimestamp($Timestamp, 0);}
}

function AddNode([xml]$Base, [xml]$Source, [string]$TargetXPath) {
	$targetNode = $Base.SelectSingleNode($TargetXPath)
	$nodeToImport = $Base.ImportNode($Source.DocumentElement, $true)
	$targetNode.AppendChild($nodeToImport) | out-null
}

function Convert-Xml([xml]$InputXml, [string]$XsltFile, [string]$Now = (Get-Date).ToUniversalTime().ToString("o")) {
    $xslt = New-Object Xml.Xsl.XslCompiledTransform
	$xsltSettings = New-Object Xml.Xsl.XsltSettings($true,$false)
	$xsltSettings.EnableScript = $true
	$XmlUrlResolver = New-Object System.Xml.XmlUrlResolver
    $xslt.Load((JoinThisPath -ChildPath $XsltFile), $xsltSettings, $XmlUrlResolver)

    $target = New-Object System.IO.MemoryStream
	$reader = New-Object System.IO.StreamReader($target)
    try {
		$xslArguments = New-Object Xml.Xsl.XsltArgumentList
		$xslArguments.AddExtensionObject("XsltFunctions", [XsltFunctions]::new())
        $xslArguments.AddParam("Now", "", $Now);
		$xslt.Transform($InputXml, $xslArguments, $target)
        $target.Position = $testResultsPath0
		return $reader.ReadToEnd()
    } Finally {
		$reader.Close()
        $target.Close()
    }
}

function Edit-Attachments([xml]$NUnitXml, [string]$RawResults, [string]$Details) {
	$suite = $NUnitXml.SelectSingleNode("test-run/test-suite[1]")
	@($suite.attachments.attachment)[0].filePath = $RawResults
	if ($Details) {
		$attachment = [xml]"<attachment><filePath>$Details</filePath><description>Test results in HTML</description></attachment>"
		AddNode -Base $NUnitXml -Source $attachment -TargetXPath "test-run/test-suite[1]/attachments"
	}
	return $NUnitXml.OuterXml
}

function Edit-Environment([xml]$NUnitXml) {
	$env = $NUnitXml.SelectSingleNode("test-run/test-suite/environment")
	if (!($env)) { return $NUnitXml.OuterXml }
	$command=$NUnitXml.SelectSingleNode("test-run/command-line").'#cdata-section' 
	if ($command) {
		Write-Host "Cmd: $command"
		$assembly = $command.Split(" ") | Where-Object { $_ -match "Runner\."}
		$versionInfo = GetVersionInfo -Assembly $assembly
		if ($versionInfo) {
			$env.SetAttribute("framework-version", $versionInfo)
		}
	}
	$os = (GetPlatform) + " $([System.IntPtr]::Size * 8)-bit"
	$env.SetAttribute("os-architecture", $os)
	$env.SetAttribute("os-version", [Environment]::OSVersion.Version)
	# AzDev can't deal with the platform attribute.
	# $env.SetAttribute("platform", $os.Caption)
	$env.SetAttribute("cwd", ".")
	$env.SetAttribute("machine-name", [Environment]::MachineName)
	$env.SetAttribute("user", [Environment]::UserName)
	$env.SetAttribute("user-domain", [Environment]::UserDomainName)
	$env.SetAttribute("culture", (Get-Culture).Name)
	$env.SetAttribute("uiculture", (Get-UICulture).Name)
	return $NUnitXml.OuterXml
}

# Extract the XML or HTML section from a string (ignore headers etc.)
function Read-Xml([string]$RawInput) {
	$ordinal = [System.StringComparison]::Ordinal
	$startLocation = $RawInput.IndexOf("<?xml", $ordinal);
	$endLocation = $RawInput.LastIndexOf(">", $ordinal) + 1;
	If (($startLocation -eq -1) -or ($endLocation -eq 0)) { return "" }
	$result = $RawInput.Substring($startLocation, $endLocation - $startLocation)
	return $result
}
	


function GetPlatform() {
	$platform = (
		(!(Test-Path -Path "variable:IsWindows"), "Windows"),
		($IsWindows, "Windows"),
		($IsMacOS, "MacOS"),
		($IsLinux, "Linux"),
		($true, $PSVersionEnvironment.Platform)
	)
	foreach ($entry in $platform) {
		if ($entry[0]) { return $entry[1] }
	}
}

function GetVersionInfo([string]$Assembly) {
	$assemblyItem = Get-Item $Assembly -ErrorAction SilentlyContinue
	if (!$assemblyItem) { $assemblyItem = Get-Command -Name $Assembly -ErrorAction SilentlyContinue | Get-Item -ErrorAction SilentlyContinue}
	if ($assemblyItem.VersionInfo.ProductName) {
		return "$($assemblyItem.VersionInfo.ProductName) $($assemblyItem.VersionInfo.ProductVersion)"
	}
	return ""
}

function JoinThisPath([string]$ChildPath) { 
    return (Join-Path -Path $PSScriptRoot -ChildPath $ChildPath) 
}

function Test-AllTestsPassed([string]$FitNesseResults) {
	$counts = ([xml]$FitNesseResults).testResults.finalCounts
	return (([int]$counts.wrong + [int]$counts.exceptions) -eq 0) -and ([int]$counts.right -gt 0)
}

function Test-MissedError([xml]$FitNesseResults) {
	return (!$FitNesseResults.testResults.result) -and (!$FitNesseResults.testResults.executionLog.exception)
}

function Save-ExceptionMessage([xml]$FitNesseResults, [string]$Message, [string]$StackTraceMessage) {
	#We put the message into testResults/executionLog/exception as that is where the history pages keep them too.
	$xPath= "/testResults/executionLog"
	if (!($FitNesseResults.SelectSingleNode($xPath))) {
		$executionLog = [xml]"<executionLog/>"
		AddNode -Base $FitNesseResults -Source $executionLog -TargetXPath "/testResults"
	}
	$exceptionXml = [xml]"<exception><![CDATA[$Message]]></exception>"
	$stackTraceXml = [xml]"<stackTrace><![CDATA[$StackTraceMessage]]></stackTrace>"
	AddNode -Base $FitNesseResults -Source $exceptionXml -TargetXPath $xPath
	AddNode -Base $FitNesseResults -Source $stackTraceXml -TargetXPath $xPath
}

# Export all functions with a dash in them.
Export-ModuleMember -function *-*