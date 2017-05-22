 r←base Decode code;ix;bits;size;s
 ix←¯1+base⍳code

 bits←,⍉((2⍟⍴base)⍴2)⊤ix
 size←{(⌊(¯1+⍺+⊃⍴⍵)÷⍺),⍺}

 s←8 size bits

 r←(8⍴2)⊥⍉s⍴(×/s)↑bits
 r←(-0=¯1↑r)↓r
