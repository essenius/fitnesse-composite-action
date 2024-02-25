# fitnesse-composite-action

This is a GitHub Composite Action allowing you to run a FitNesse test or suite.
It does the following:
* Download FitNesse
* Download FitSharp
* Run a test suite
* Transform the raw results into HT and NUnit3 format
* Return the test results in the run artifacts.

## Parameters
Required|Description|Example value
:--|:--|:--
test-spec|the test/suite specification to run in the format that FitNesse uses|GameManagementSuite?suite
fixture-folder|the location where the FitSharp foxture assemblies and config.xml are expected.|${{github.workspace}}/fixtures

Optional|Description|Default value
:--|:--|:--
include-html|whether or not to include the test details in suites (1.)|true 
fitnesse-port|the port that the FitNesse wiki runs at (2.)|8080
fitnesse-release|the FitNesse release to use|20240219
fitsharp-release|the FitSharp release to use|2022.11.13
fitsharp-folder|the folder where FitSharp needs to end up|${{github.workspace}}/fitsharp
test-result-folder|the folder where the test result needs to end up|${{github.workspace}}/testresult
test-result-artifact|the name of the resulting artifact container|test-result

1) This can be useful to make `false` for very large suites, as it will only report back summaries per page and not the individual tests.
2) Might be useful for non-hosted runners using that port already

## Example
For an example of how to use this composite action see the [FitNesseAction](../../../FitNesseAction) repo.

## Contribute
Enter an [issue](../../issues) or provide a [pull request](../../pulls). 
