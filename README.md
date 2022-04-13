# fitnesse-composite-action

This is a GitHub Composite Action allowing you to run a FitNesse test or suite.
It does the following:
* Download FitNesse
* Download FitSharp
* Run a test suite
* Transform the raw results into HT and NUnit3 format
* Return the test results in the run artifacts.

Available parameters:
* Required:
  * test-spec: the test/suite to run in the format that FitNesse uses (e.g. `GameManagementSuite?suite`)
  * fixture-folder: the location where the FitSharp foxture assemblies and config.xml are expected. Typical is `${{github.workspace}}/fixtures`
* Optional:
  * include-html: whether or not to include the test details in suites (otherwise it returns page summaries only). Default: `true`. Can be useful to make `false` for very large suites, but it will disable creation of the HTML results.
  * fitnesse-port: the port that the FitNesse wiki runs at. Default: `8080` and it's probably not very often needed to change this
  * fitnesse-release: the FitNesse release to use. Default: `20220319`
  * fitsharp-release: the FitSharp release to use. Default: `2022.3.29`
  * fitsharp-folder: the foilder where FitSharp needs to end up. Default: `${{github.workspace}}/fitsharp`
  * test-result-folder: the folder where the test result needs to end up. Default: `${{github.workspace}}/testresult`
  * test-result-artifact: the name of the resulting artifact container. Default: `test-result`

## Example
For an example of how to use this composite action see the [FitNesseAction](../../../FitNesseAction) repo.

## Contribute
Enter an [issue](../../issues) or provide a [pull request](../../pulls). 
