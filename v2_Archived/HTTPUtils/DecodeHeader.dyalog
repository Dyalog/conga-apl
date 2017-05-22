 r←DecodeHeader buf;len;d;dlb;i
⍝ Decode HTML Header
 r←0(0 2⍴⊂'')
 dlb←{(+/∧\' '=⍵)↓⍵} ⍝ delete leading blanks
 :If 0<i←⊃{((NL,NL)⍷⍵)/⍳⍴⍵}buf
     len←(¯1+⍴NL,NL)+i
     d←(⍴NL)↓¨{(NL⍷⍵)⊂⍵}NL,len↑buf
     d←↑{((p-1)↑⍵)((p←⍵⍳':')↓⍵)}¨d
     d[;1]←lc¨d[;1]
     d[;2]←dlb¨d[;2]
     r←len d
 :EndIf
