 r←arg getargix(args list);mn;mp;ixs;nix
⍝ Finds argumenst in a list of positional and named arguments

 ixs←list⍳ncase args

 nix←+/∧\2>|≡¨arg ⍝ identify where the named arguments starts

 r←(⍴ixs)⍴1+⍴list      ⍝ prefill the result
 mp←ixs≤nix
 :If ∨/mp        ⍝ for positionals args
     (mp/r)←mp/ixs
 :EndIf
 mn←(~mp)∧ixs<1+⍴list
 :If ∨/mn       ⍝ for named args.
 :AndIf nix<⍴arg
     (mn/r)←-nix+(1⊃¨nix↓arg)⍳ncase mn/args

 :EndIf
