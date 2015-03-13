# Introduction #

Copy and paste the code below in MATLAB/Octave in order
to perform unit testing from the trunk (replace release number
accordingly).

Note: If functions in the unit tests are update, make sure to run
'make package' at the root of the project.


# Details #

```

clear all;clc;close all

wfdb_url='http://wfdb-app-toolbox.googlecode.com/svn/trunk/wfdb-app-toolbox-0-9-7.zip';
[filestr,status] = urlwrite(wfdb_url,'wfdb-app-toolbox-0-9-7.zip');
unzip('wfdb-app-toolbox-0-9-7.zip');

wfdb_url='http://wfdb-app-toolbox.googlecode.com/svn/trunk/unit-test.zip';
[filestr,status] = urlwrite(wfdb_url,'unit-test.zip');
unzip('unit-test.zip');

cd mcode
addpath(pwd)
cd ../UnitTests
BatchTest

```