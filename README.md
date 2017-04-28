toolbox-plan
===========

Prolog program to create a cutting plan to make a japanese toolbox from a sheet of wood of arbitrary size.

Laughlin Dawes 8/3/2014

Japanese toolbox design courtesy Make magazine:
http://makezine.com/projects/make-34/japanese-toolbox/

Code based on block-in-box fitting program from Prolog
Programming for Artifical Intelligence 4th ed, I Bratko, Chapter 7
Constraint Logic Programming.

Using SWI-Prolog version 6.6.1

How to use...

1. Set the size and thickness of your wooden sheet under sheet size.

2. Search can take a long time, so it is a good idea to find an
approximate value. Do this by calling, fit(ply, your_guess, L), where
your_guess is your estimate of box length. This will either succeed or
fail. You can now constrain BoxLen in the first line of the fit
function to the upper bound of your successful guesses - this will
significantly reduce runtime.

3. Call best_fit(X). Wait a while. Ctrl-C & 'a' when bored of waiting, 
this function may not end in any reasonable time. X will be your box's
length, and the program will output the sizes and orientations of all
the parts. You will still have to guess some of the positions of the
parts as some will be variables. If you really want to see the 
constraints you can rerun fit(ply, X, L), where X is the value you got
from best_fit/1, but I've found the constraints to be pretty unhelpful
on the whole.
