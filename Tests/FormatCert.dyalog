 r←name FormatCert z;getvalues;names
⍝ Return certificate information in human-readable form

 names←,[1.5]name'Version' 'SerialNo' 'Subject' 'Issuer' 'ValidFrom' 'ValidTo'
 getvalues←{⍵.(Formatted.(Version SerialNo Subject Issuer),Elements.(ValidFrom ValidTo))} ⍝ ⍵ will be an instance of X509Cert

 :If 0=1⊃z
 :AndIf 0<⊃⍴2⊃z
     r←names,' '⍪⍉↑getvalues¨2⊃z
 :Else ⋄ r←('Unable to retrieve ',name)z
 :EndIf
