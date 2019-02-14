This file describes how to install the K interpreter fo the Alk language.

The first step is to install K3.6:
* download k-distribution-3.6.zip or k-distribution-3.6.tar.gz, depending on your OS, from https://github.com/kframework/k/releases/tag/v3.6;
* unzip (or tar xvfz) the downloaded archive in a folder devoted to used software; let `pathtok` denote this folder;
* add `pathtok` to PATH environment variable;
* try `kompile --version` to test that everithing is fine.

The second step is to download and kompile the K definition of Alk:
* if you have git on your system, then the best is to make a clone of the K definition of alk from https://github.com/alk-language/k-semantics
* otherwise, you may download a zip archive from https://github.com/alk-language/k-semantics (`Clone or download` button);
* go to the `alk` folder and compile the K definition of Alk using the command `kompile alk.k`
* this command will create a subfolder `alk-kompiled`

The third step is to configure the `alki` tool, a script running the compiled definition:
* go to the folder `bin`
* use the prefered text editor to open the file `alki.config` from the `bin` folder;
* add the paths to the K binaries in this file: the path to K bin folder (something like `pathtok/bin`), and the path to the Alk K definition (where is the `alk-kompiled` subfolder);
* add the full path to the `k-semantics/bin/` to the PATH environment variable;
* test the tool using the command `alki`; the output should be a shoert help text:
```
Please provide an Alk file.
Usage: alki [OPTIONS]... [file.alk]
	--init           the initial Alk state
	--search         enable search; works only with transition enabled
	--stack          show stack content if any
	--krun           path to krun executable
	--directory      path to directory where alk-kompiled resides
	               
	-h --help        print usage message and exit
  ```
  * you should be able now to run the first alk algorithm; you find many examples in `tests` folder. Here is an example:
  ```
  $ alki tests/miscelanea/gcd.alk --init="u |-> 42 v |-> 56"
State:
    u |-> 42
    v |-> 56
```
K is a generic tool and its interpreter for ALk is a bit slow. You may use Nailgun (http://martiansoftware.com/nailgun/). "Nailgun is a client, protocol, and server for running Java programs from the command line without incurring the JVM startup overhead."
* clone (using git) or download the zip archive with the sources from the GitHub repository: https://github.com/facebook/nailgun
* follow instructions from the README file for compiling and installing the nailgun tool;
* run `kserver` (from `k3.6/bin` folder) to start the nailgun server for the K. Here is an example how it works:
```
$ kserver&
[1] 14498
$ K server started on 127.0.0.1:2113
$ time alki tests/miscelanea/gcd.alk --init="u |-> 42 v |-> 56"
NGSession 2: 127.0.0.1: org.kframework.main.Main disconnected
NGSession 2: 127.0.0.1: org.kframework.main.Main exited with status 0
State:
    u |-> 42
    v |-> 56

real	0m2.500s
user	0m0.199s
sys	0m0.103s
$ time alki tests/miscelanea/gcd.alk --init="u |-> 42 v |-> 56"
NGSession 4: 127.0.0.1: org.kframework.main.Main disconnected
State:
    u |-> 42
    v |-> 56

NGSession 4: 127.0.0.1: org.kframework.main.Main exited with status 0
real	0m0.483s
user	0m0.192s
sys	0m0.107s
```
Please note the time difference between the two executions.

