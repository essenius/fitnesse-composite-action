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
  * include-html: whether or not to include the test details in suites (otherwise it returns page summaries only). Default is `true`
  * fitnesse-port: the port that the FitNesse wiki runs at. Default is `8080` and it's probably not very often needed to change this
  * fitnesse-release: the FitNesse release to use. Default is `20220319`
  * fitsharp-release: the FitSharp release to use. Default is `2022.3.29`
  * fitsharp-folder: the foilder where FitSharp needs to end up. Default is  `${{github.workspace}}/fitsharp`
  * test-result: the folder where the test result needs to end up. Default is `${{github.workspace}}/testresult`
