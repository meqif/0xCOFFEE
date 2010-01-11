SYNOPSIS
--------

0xCOFFEE (or 0xC0FFEE, if the "O" bothers you ;)) is a toy programming language implemented using Ruby, TreeTop and LLVM. It currently aims to be a kind of sandbox where I can have some fun trying to create an interesting language, but I hope it will grow to be a decent language (probably functional, with some OO-concepts sprinkled here and there).

Currently, it does very little, but I have several things planned, like:

- type inference
- optional type annotation (Haskell- or OCaml-style)
- metaprogramming (like Ruby's `attr_reader` and `attr_accessor`)
- lazy evaluation
- strings as utf-8, ALWAYS
- bracket-less, mandatory source code indentation (I know some people hate Python because of this, but I think it enforces readable code)
- [Grand Central Dispatch](http://en.wikipedia.org/wiki/Grand_Central_Dispatch) support where available

FEATURE LIST
------------

- can generate native code, courtesy of LLVM

USAGE
-----

To emit to LLVM-IR

    $ coffee -s cappuccino.cof

To compile to LLVM bitcode

    $ coffee creamy.cof

Then, to compile the generated bitcode to native code

    $ llvm-ld --native creamy.bc -o creamy

And there you go, your source code is compiled to native bitcode!

SEE ALSO
--------

 * [Caliper & metric\_fu report][calip]
 * [RDoc.info Documentation][rdoci]

[calip]: http://getcaliper.com/caliper/project?repo=git://github.com/meqif/0xCOFFEE.git
[rdoci]: http://rdoc.info/projects/meqif/0xCOFFEE

COPYRIGHT
---------

0xCOFFEE &copy; 2009-2010 by Ricardo Martins. Licensed under the MIT license. Please see the {file:LICENSE} for more information.
