 r←name DisplayCert z
     ⍝ Display information about a certificate
 dc←{,[1.5](2⊃⍵)[1 2 3 4 5 6]}
 nc←,[1.5]name'Version' 'SerialNo' 'Subject' 'Issuer' 'ValidFrom' 'ValidTo'
 dc←{⍵.(Formatted.(Version SerialNo Subject Issuer),Elements.(ValidFrom ValidTo))}
 :If 0=1⊃z
 :AndIf 0<⊃⍴2⊃z
     r←nc,' '⍪⍉↑dc¨2⊃z
     ⍝    ⎕←name,':'
     ⍝    ⎕←dc 1⊃z←2⊃z ⋄ ⎕←''
     ⍝    :If 1<⍴z ⋄ ⎕←'Signing chain for ',name,':' ⋄ ⎕←dc¨1↓z ⋄ ⎕←''
     ⍝    :EndIf
 :Else ⋄ r←('Unable to retrieve ',name)z
 :EndIf
