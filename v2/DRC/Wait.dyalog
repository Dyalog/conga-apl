 r←Wait a;⎕IO
     ⍝ Name [timeout]
     ⍝ returns: err Obj Evt Data
 ⎕IO←1
 :If (1≥≡a)∧∨/80 82∊⎕DR a
     a←(a)1000
 :EndIf
 →(0≠⊃⊃r←check ⍙CallRLR RootName'AWaitZ'a 0)⍴0
      ⍝:If 0=⊃⊃r ⋄ timing,←⊂(4⊃4↑⊃r),Micros ⋄ :EndIf
 r←(3↑⊃r),r[2]
 :If 0<⎕NC'⍙Stat' ⋄ Stat r ⋄ :EndIf
