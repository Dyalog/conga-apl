 r←a getarg ixs;m
 m←0<ixs
 r←(⍴ixs)⍴⍬
 :If ∨/m
     (m/r)←a[m/ixs]
 :EndIf
 m←~m
 :If ∨/m
     (m/r)←2⊃¨a[-m/ixs]
 :EndIf
