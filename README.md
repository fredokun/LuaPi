LuaPi: Concurrent programming made simple
=========================================

(C) 2007-2015 by Frederic Peschanski under the MIT Licence
(see COPYRIGHT file)

## OVERVIEW ##

LuaPi is a concise and efficient library for concurrent programming in the Lua language.
The metaphor employed is that of communicating systems. A LuaPi agent (there should generally
 be one LuaPi agent per lua instance) runs a set of LuaPi concurrent processes.
Processes communicate through send/receive or broadcast primitives using communication channels. 
Channels can also be passed around, allowing higher-order concurrent communication.
A higher-level and quite expressive choice construct allows to implement guarded commands, 
select-like behaviors and much more. Technically-speaking, LuaPi is an outcome of a research
work about the efficient implementation of the pi-calculus. LuaPi also implement extensions
 to the basic Pi-calculus: broadcast channels and join patterns.

From a practical point of view, LuaPi greatly simplifies the thinking and programming of concurrent
 behaviors, here in the Lua language. A more Lua-specific aspect is that LuaPi offers an expressive
(but thin) layer above the coroutine mechanism so that programmers do not have to deal with the 
low-level stuff. It also provides an implicit cooperation model so that explicit yield are barely needed.
Although the scheduler can theoretically be parallelized, since Lua does not support OS-level threads this
 is also a limitation of LuaPi.

## INSTALLATION ##

There is no installation procedure per-se. A LuaRock should be created at some point.

To check the library, you can try the (few) provided examples:

    > source ./prepare.sh
    > lua examples/cs.lua
    ...
    > lua examples/rdv.lua
    ...
    > (etc.)

Most examples are (or will be) thoroughly commented, and further documentation should happen
at some point.

## CONTENTS ##

`LuaPi-<VERSION>/`  :  main directory
   `README` : this file
   `HISTORY` : the history of versions
   `COPYRIGHT` : our rights (and few duties)
   `VERSION` : the current version
   `AUTHORS` : the authors of the software
   `doc/` : tutorial and reference documentation
   `lib/` : the library file(s)
   `lib/pi.lua` : the main LuaPi module
   `examples/` : largely commented examples
   `prepare.sh` : to try LuaPi in the repo (cf.

## DOCUMENTATION ##

LuaPi tutorial:

see `doc/tutorial/LuaPiTut-<VERSION>.pdf`
