# Tetra's Interface with Jenkins

## Overview

Jenkins and Tetra work together in order to run post-build tests. This is done by using the Tetra worker server to execute tests and generate JUnit format test reports which Jenkins can read and interpret.

Because Jenkins doens't directly integrate with the Tetra implementation, instead Jenkins builds request Rake tasks defined specifically for them.

---

**Jenkins execution order for tetra:**

1. Jenkins calls the Test Build
2. The Build calls a batch file with certain parameters matching the rake task that defines its test.
3. The batch file executes the rake task
4. The rake task starts a minitest suite, which generates a JUnit test result .xml file upon completion (using a library called CI Reporter for Ruby).
5. The task returns a complete status, and then the batch returns a success response.
6. The build collects the .xml file using a post-build step
7. These results are interpreted by Jenkins, resulting in either a pass or fail based on results, and stores the results on the build server.

---

## Calling a Jenkins enabled test after a build

First, create a recurring test in Tetra that matches the test you want to run.

To call a test suite, you should have its test script setup in Tetra, marking off which tests should be run, and map that to the recurring test ID you created above.

The .xml file generated is generated based on the test suite name, so you should either put all tests into one suite, or be prepared to list multiple files in your post-build XML collection step.

To call a Jenkins build, you will need to also make sure the test build you are requesting has a entry in tetra/lib/tasks/tests.rake
If you do not, you will need to add one and map it to the script file you entered.

Now, with those steps completed, you just need to call the batch command build step, and give the jenkins.bat your suite name. (the task name created in previous step, stored in tests.rake)

And then add the .xml locations to your post build steps, using the JUnit report step. These must be created within the "workspace" given for Jenkins.
