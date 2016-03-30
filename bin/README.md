Customized interpreter for Alk
==============================

Prerequisites:
-------------

* The K framework - use the version of K indicated [here](https://github.com/alk-language/k-semantics).
  It is highly recommended to put the paths to K's binaries in your system's `PATH` environment variable.

* Perl and CPAN - for Linux/Unix/MacOS users.
* The `Getopt::Long::Descriptive` package - for Linux/Unix/MacOS users. It can be installed in command line by typing `cpan -i Getopt::Long::Descriptive` (warning: you may need `sudo` for this). 

Note: instructions about using CPAN can be found [here](http://www.cpan.org/modules/INSTALL.html).

How to use?
-----------

1. Edit the `alki.config` file located in the `bin` directory. You will notice that the default content of this file is

```
ALK=
K=
```

It is expected that the user edits `alki.config` such that:

* `ALK=`the *absolute* path to the directory which contains `alk.k`, and
* `K=` the *absolute* path to the `bin` directory of the K distribution

For example, if `K` is stored at `/home/user/work/k` and `Alk` is stored at `/home/user/work/alk-language/k-semantics` then the content of the `alki.config` file should be:

```
ALK=/home/user/work/alk-language/k-semantics/alk
K=/home/user/work/k/bin
```

Technically, the folder `/home/user/work/alk-language/k-semantics/alk` should contain a file named `alk.k`, and the folder `/home/user/work/k/bin` should contain at least two files: `kompile` and `krun`. 

Note that adding the right paths to `alki.config` is *mandatory*. Otherwise, the tool will probably fail to execute programs. 

2. Add `bin` (the folder where this README file resides) into your system's PATH.

3. Run `alki` (or `alki.exe` on Windows) for the first time:

```> alki```

and you'll get:
```
Please provide an Alk file.
Usage: alki [OPTIONS]... [file.alk]
        --init STR        the initial Alk state
        --stack           show stack content
        --krun STR        path to krun executable
        --directory STR   path to directory where alk-kompiled resides

        -h --help         print usage message and exit
```

The tool typically expects an Alk program as argument. Let's create a file, say `gcd.alk`, with the following content:
```
// Find the greatest common divisor of two numbers
gcd(a, b)
{
  while (a != b) {
    if (a > b)  a = a - b;
    if (b > a) b = b - a;
  }
  return a;
}

x = gcd(42,56);
```

Now, we can simply run `gcd.alk`:
```
$ alki gcd.alk 
Could not detect a compiled version of Alk.
Trying to compile. Please wait...
Compilation complete. Resume...
State:

    x |-> 14

```

By default, `alki` displays the program state. However, when running it for the first time, the tool automatically compiles the `K` definition of `Alk`. This happens only once. If you run the same command again, you'll get only:

```
$ alki gcd.alk 
State:

    x |-> 14

```

The tool also allows us to send an initial state for a program directly in the command line. For instance, let's modify our `gcd.alk` program like this:

```
// Find the greatest common divisor of two numbers
gcd(a, b)
{
  while (a != b) {
    if (a > b)  a = a - b;
    if (b > a) b = b - a;
  }
  return a;
}

x = gcd(u, v);
```

Note that we've introduced two unkonwn variables, `u` and `v`.
Now, we use the `--init` option to pass the initial values of `u` and `v`:

```
> alki gcd.alk  --init "u|-> 42 v |-> 56"
State:

    u |-> 42
    v |-> 56
    x |-> 14

```

If no initial state is provided the default value of `--init` is `.Map`, i.e., the empty state. 
In that case, we get an error:
```
> alki gcd.alk
Program execution failed; the following code got stuck during execution:
u ~> evaluate HOLE, v wrt a, b to .ValueList ~> bindParams a, b to
      HOLE ~> { (while ( a != b ) { (if ( a > b ) (a = a - b) ;) (if ( b >
       a ) (b = b - a) ;) }) (return a ;) } ~> return 0 ;
State:

    gcd |-> lambda ( a, b ) . { (while ( a != b ) { (if ( a > b ) (a = a -
       b) ;) (if ( b > a ) (b = b - a) ;) }) (return a ;) }


```

If the program execution fails, as above (since it cannot evaluate `u` for this program), `alki` displays the rest of the program to be executed and the current state. 
In such situations it is often needed to inspect the execution stack.
For this, we use `--stack`, which shows the current stack (if available):

```
> alki gcd.alk --stack
Program execution failed; the following code got stuck during execution:
u ~> evaluate HOLE, v wrt a, b to .ValueList ~> bindParams a, b to
      HOLE ~> { (while ( a != b ) { (if ( a > b ) (a = a - b) ;) (if ( b >
       a ) (b = b - a) ;) }) (return a ;) } ~> return 0 ;
State:

    gcd |-> lambda ( a, b ) . { (while ( a != b ) { (if ( a > b ) (a = a -
       b) ;) (if ( b > a ) (b = b - a) ;) }) (return a ;) }

Stack:

    ListItem ( [ (x = HOLE) ~> (HOLE ;) , gcd |-> lambda ( a, b ) . { (
      while ( a != b ) { (if ( a > b ) (a = a - b) ;) (if ( b > a ) (b = b
       - a) ;) }) (return a ;) } , a, b ] )

```

Traps
-----
If you get this error:
```
> alki tests/miscelanea/gcd.alk --directory alk 
[Error] Critical: Kompiled definition is out of date with the latest version of
the K tool. Please re-run kompile and try again.
Program execution failed.
```
then you probably compiled `alk.k` with a different version of `K` than the one `alki` is trying to use (which, by default, is taken from `PATH`). To fix this, you can either edit the `PATH` variable or use the `--krun` when running `alki`.


Remarks
-------

The `alki.exe` file is generated using the `pp` tool (yes, `alki` is just a `Perl` script). 
However, if you encounter problems when running it you can install Perl on Windows (Straberry Perl is preferred), and then the `Getopt::Long::Descriptive` package using `cpan` (i.e., `cpan -i Getopt::Long::Descriptive`). 
If the installation is successful, you can run directly the script by typing `perl alki` instead of `alki.exe`. For further details, please send an email to `andrei.arusoaie@gmail.com`.
