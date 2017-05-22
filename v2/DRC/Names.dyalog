 r←Names root
     ⍝ Return list of top level names

 :If 0=1↑r←Tree root
     r←{0=⍴⍵:⍬ ⋄ (⊂1 1)⊃¨⍵}2 2⊃r
 :EndIf
