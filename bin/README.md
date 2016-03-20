Customized interpreter for Alk
==============================

Prerequisites:
-------------

* The K framework - use the version of K indicated [here](https://github.com/alk-language/k-semantics).
  It is highly recommended to put the paths to K's binaries in your system's `PATH` environment variable.

* Perl and CPAN - for Linux/Unix/MacOS users.
* The `Getopt::Long::Descriptive` package - for Linux/Unix/MacOS users. It can be installed in command line by typing `cpan -i Getopt::Long::Descriptive` (warning: you may need `sudo` to do this). 

Note: instructions about using CPAN can be found [here](http://www.cpan.org/modules/INSTALL.html).

How to use?
-----------

First, make sure that Alk is compiled, that is, check if `pathToAlk/alk/alk-kompiled` exists. Otherwise,
compile the K definition of Alk that resides in the `alk` directory of this repo:

```> kompile alk.k```

or 

```> pathToK/bin/kompile alk.k```

This will generate `alk-kompiled` in the same directory.

2. Add `bin` (the folder where this README file resides) into your system's PATH.

3. Run `alk` (or `alk.exe` on Windows) for the first time:

```> alk```

and you'll get:
```
Please provide an Alk file.
Usage: alk [OPTIONS]... [file.alk]
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

Now, we can simply run `gcd.alk` (this assumes that `krun` is in your system's PATH):
```
State:

    x |-> 14


```

By default, `alk` displays the program state. The tool also allows us to send an initial state for a program directly in the command line. For instance, let's modify our `gcd.alk` program like this:

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
> alk gcd.alk  --init "u|-> 42 v |-> 56"
State:

    u |-> 42
    v |-> 56
    x |-> 14

```

If no initial state is provided the default value of `--init` is `.Map`, i.e., the empty state. 
In that case, we get an error:
```
> alk gcd.alk
Program execution failed; the following code got stuck during execution:
u ~> evaluate HOLE, v wrt a, b to .ValueList ~> bindParams a, b to
      HOLE ~> { (while ( a != b ) { (if ( a > b ) (a = a - b) ;) (if ( b >
       a ) (b = b - a) ;) }) (return a ;) } ~> return 0 ;
State:

    gcd |-> lambda ( a, b ) . { (while ( a != b ) { (if ( a > b ) (a = a -
       b) ;) (if ( b > a ) (b = b - a) ;) }) (return a ;) }


```

If the program execution fails, as above (since it cannot evaluate `u` for this program), `alk` displays the rest of the program to be executed and the current state. 
In such situations it is often needed to inspect the execution stack.
For this, we use `--stack`, which shows the current stack (if available):

```
> alk gcd.alk --stack
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
* If you ever get this error:
```
> alk tests\miscelanea\gcd.alk
'krun' is not recognized as an internal or external command,
operable program or batch file.
Program execution failed.
```
then `alk` is not able to find the path to `krun`. In this case, you can either edit the `PATH` environment variable or use the `--krun` when running `alk`.

* Also, if you get this error:
```
> alk tests/miscelanea/gcd.alk --directory alk 
[Error] Critical: Kompiled definition is out of date with the latest version of
the K tool. Please re-run kompile and try again.
Program execution failed.
```
then you probably compiled `alk.k` with a different version of `K` than the one `alk` is trying to use (which, by default, is taken from `PATH`). To fix this, you can either edit the `PATH` variable or use the `--krun` when running `alk`.


Remarks
-------

The `alk.exe` file is generated using the `pp` tool (yes, `alk` is just a `Perl` script). 
However, if you encounter problems when running it you can install Perl on Windows (Straberry Perl is preferred), and then the `Getopt::Long::Descriptive` package using `cpan` (i.e., `cpan -i Getopt::Long::Descriptive`). 
If the installation is successful, you can run directly the script by typing `perl alk` instead of `alk.exe`. For further details, please send an email to `andrei.arusoaie@gmail.com`.
