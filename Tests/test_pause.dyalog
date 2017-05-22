 r←test_pause dummy;Host;Port;maxwait;ret;s1;stnum;tests;z;sret
⍝ Test Server pause
 Host←'localhost' ⋄ Port←5000
 maxwait←5000

 TestConnect←{
     (addr port srv prot)←⍵
     0≢⊃rc←iConga.Clt''addr port,(0<⍴prot)/(⊂'Protocol'prot):'Clt failed: ',,⍕rc
     (0 'Connect' 0)≢(⊂1 3 4)⌷ret←4↑iConga.Wait srv maxwait:'Srv wait failed: ',,⍕ret
     0≢⊃ret←iConga.Close 2⊃rc:'Close failed: ',,⍕ret
     (0 'Closed' 1119)≢(⊂1 3 4)⌷ret←4↑iConga.Wait srv maxwait:'Srv Wait failed: ',,⍕ret
     ''
 }



 FlushPending←{⍺←0 'Connect' 0
     srv clts←⍵
     ⍺≡(⊂1 3 4)⌷4↑iConga.Wait srv maxwait:⍺ ∇ srv clts
     0<⍴clts:(0 'Closed' 1119)∇(srv ⍬)⊣iConga.Close¨clts
     'clear'
 }


 :If 0 check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)check ret←iConga.GetProp'.' 'EventMode'
     →fail because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Srv'' ''Port
     →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
 s1←2⊃ret
 ⍝ Start the server thread
⍝ stnum←{sret←Server}&s1 maxwait

 tests←10⍴⊂(Host Port s1'')

 :If ((⍴tests)⍴0)check⊃∘⍴¨ret←TestConnect¨tests
     →fail because'Connection failed :',,⍕(⊃∘⍴¨ret)/ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.SetProp s1'Pause' 1
     →fail because'Set Pause to 1 failed: ',,⍕ret ⋄ :EndIf

 :If ((⍴tests)⍴0)check 0=⊃∘⍴¨ret←TestConnect¨tests
     →fail because'Connection failed :',,⍕(⊃∘⍴¨ret)/ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.SetProp s1'Pause' 0
     →fail because'Set Pause to 0 failed: ',,⍕ret ⋄ :EndIf

 :While 0<⍴iConga.Names s1
     ret←FlushPending s1((iConga.Names'.')~⊂s1)
     ⎕←'.'
 :EndWhile

 :If ((⍴tests)⍴0)check⊃∘⍴¨ret←TestConnect¨tests
     →fail because'Connection failed :',,⍕(⊃∘⍴¨ret)/ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.SetProp s1'Pause' 2
     →fail because'Set Pause to 2 failed: ',,⍕ret ⋄ :EndIf

 :If ((⍴tests)⍴0)check 0=⊃∘⍴¨ret←TestConnect¨tests
     →fail because'Connection failed :',,⍕(⊃∘⍴¨ret)/ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.SetProp s1'Pause' 0
     →fail because'Set Pause to 0 failed: ',,⍕ret ⋄ :EndIf

 :If ((⍴tests)⍴0)check⊃∘⍴¨ret←TestConnect¨tests
     →fail because'Connection failed :',,⍕(⊃∘⍴¨ret)/ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.Close s1
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close s1
