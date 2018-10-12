 iEvaluate←{⍺←⊢
⍝   ⍺    | ⍵ - n is the syntax code supplied by "syntax"
⍝        |
⍝  1       | arrayname    2 n
⍝  2       | arrayname    2 n newvalue
⍝  3       | arrayname    2 n (PropertyArguments : Indexers IndexersSpecified)
⍝  4       | arrayname    2 n (PropertyArguments : Indexers IndexersSpecified NewValue)
⍝  5       | niladname    3 n
⍝  6       | (expression) 3 n
⍝  7       | {monad}      3 n  rarg
⍝  8  larg | {dyad}       3 n  rarg
⍝  9       | monadname    3 n  rarg
⍝ 10  larg | dyadname     3 n  rarg

     ⎕←'iEvaluate'⍺ ⍵
     3=≢⍵:⍎⊃⍵           ⍝ 1 5 6
     (2=2⊃⍵)∧4=≢⍵:⍎(1⊃⍵),'←4⊃⍵'  ⍝ 2
     ⍺(⍎⊃⍵)4⊃⍵               ⍝ 7 8 9 10
 }
