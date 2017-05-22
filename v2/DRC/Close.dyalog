 r←Close con;_
     ⍝ arg:  Connection id
 r←check ⍙CallR RootName'AClose'con 0
 :If ((,'.')≡,con)∧(0<⎕NC'⍙naedfns')  ⍝ Close root and unload share lib
     _←⎕EX¨⍙naedfns
     _←⎕EX'⍙naedfns'
 :EndIf
