# Naval Observatory Vector Astrometry Software
## C Edition C3.1 (31 March 2011)

This repository is an import of the USNO NOVAS C v3.1 library, with the simple
goal of making an easy to find, self-contained, turn-key version of this library
on Linux.

The [official library](https://aa.usno.navy.mil/software/novasc_intro) is none of these things, to put it mildly.

See README.txt for the official readme documenation.

The following changes have been made:

1. The source code was modified to remove warnings. The most noticeable of these
changes is to not pass names as arrays to novas.c which was a well intentioned
change but is poor practice. The modified functions all check the length of the
passed strings before copying.
2. Makefiles have been added to handle building a separate static library (libnovas.a) as
well as the self-check applications with appropriate dependency checking.
There are two Makefiles:
   1. `Makefile` builds the library to use `solsys1.c` and `eph_manager.c` which expects to open a binary ephemeris file named `JPLEPH` in the current directory.
   2. `Makefile3` builds the library to use `solsys3.c` which is self-contained for use with just the Sun and stars.
3. `Makefile` automatically fetches an x86 (little-endian) binary ephemeris file from its current location at https://ssd.jpl.nasa.gov/ftp/eph/planets/Linux/.

## Building using an ephemeris file
If you are interested in building an application to perform astronomical operations
involving any of the planets, then you can build the library by:
* Running `make`

Run the self-check tool or example application by:
* Running `make check` or
* Running `make example`

To build your own application, you should have it include `eph_manager.h` and `novas.h` and link
with lib/libnovas.a. For simple applications, it would be trivial to just add a
Makefile target for your application, similar to the `example` target.

For applications in another location, add the appropriate `-I` include path
to this repo directory and a `-L` link path to the `lib/` subdirectory. Your
application will be responsible for calling `ephem_open()` with a path to the
ephemeris file (you may wish to make a copy or link in your application directory
or a well-known location), as well as `ephem_close()`.

## Building without an ephemeris file
If your application only requires data for the Sun and stars, then you can build
a library without any dependency on an external ephemeris file by.
* Running `make -f Makefile3`

Run the self-check tool by:
* Running `make check`

The steps to build your own application are the same as above except there is no
need to make any calls to `ephem_open()` or `ephem_close()` and no dependency on an
ephemeris file.

## A word on binary ephemeris files
The NOVAS library originally claimed that ephemeris files could only be distributed
in ASCII form because binary data is not portable between machines. This is really a
legacy from the dark ages of using Fortran for this library. In C, or any modern
language, this statement is only true if your software makes no effort to serialize and deserialize your data correctly.
That's a solved problem, as demonstrated by every network application that exchanges binary data.

Because the NOVAS library still depends on ephemeris files in native binary format, there
are conversion tools that convert the ASCII files into binary for given machine architecture.
However, the official version of this tool is only provided in Fortran. My attempts to use it
generated ephemeris files that didn't pass the self-check test (the self-check test itself
aborts with a floating point exception even on the official binary DE405 files). [Others](https://github.com/axd1967/erik-de-man-cn)
have tried to rewrite it in C but I found those implementations to also have bugs that
caused the self-test checks to fail even after I fixed the format bugs that prevented this
library from parsing those files.

Fortunately, JPL does host some pregenerated binary files for both big and little-endian
architectures, which is what this project uses instead (although these are not
mentioned in any of the documentation that I came across). The downside is that
there is less flexibility with the data ranges provided and the files are larger than
needed for many applications. I think a tool for trimming binary files would be
straightforward, so I may add that at some point.

If you are building for a big-endian Unix platform, then you will want to modify the
ephemeris URL (ie https://ssd.jpl.nasa.gov/ftp/eph/planets/SunOS/de405/unxp1900.405) in `Makefile`.


