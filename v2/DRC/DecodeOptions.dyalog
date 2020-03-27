 r←DecodeOptions value;bits;opts;inds;⎕IO
 ⍝ returns the meaning of an Options value
 :Access Public Shared
 ⎕IO←1
 opts←{↑⍵{(⍺⍎⍵)⍵}¨⍵.⎕NL ¯3}Options
 'DOMAIN ERROR: Invalid Options'⎕SIGNAL((,1)≢,value∊0,⍳+/opts[;1])/11
 bits←⌽2*¯1+⍸⌽2⊥⍣¯1⊢value
 inds←opts[;1]⍳bits
 r←1↓∊'+',¨opts[inds;2]
