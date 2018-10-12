 r←RootName fWait a;⎕IO
     ⍝ Name [timeout]
     ⍝ returns: err Obj Evt Data
 check←{
     0≠⊃⍵:('DLL Error: ',,⍕⍵)⎕SIGNAL 999
     0≠⊃2⊃⍵:(##.Conga.Error⊃2⊃⍵),1↓2⊃⍵
     2=⍴⍵:(⎕IO+1)⊃⍵
     1↓⍵}


 ⎕IO←1
 :If (1≥≡a)∧∨/80 82∊⎕DR a
     a←(a)1000
 :EndIf
 →(0≠⊃⊃r←check ##.Conga.⍙CallRLR RootName'AWaitZ'a 0)⍴0
      ⍝:If 0=⊃⊃r ⋄ timing,←⊂(4⊃4↑⊃r),Micros ⋄ :EndIf
 r←(3↑⊃r),r[2]
