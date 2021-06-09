# Conga-apl

This repository contains the APL source code, build and test scripts used to build and test conga.dws from Dyalog APL version 16.0 onwards.

It is essentially for internal Dyalog use but visible to the public. Comments and suggestions are welcome!

To build a workspace from code checked out to [folder]:

]dbuild [folder]\conga-apl.dyalogbuild

At this point, you should be able to run the QA suite using:

]dtest [folder]/Tests/all

Note: the appropriate Conga shared libraries need to installed in the Dyalog installation folder.