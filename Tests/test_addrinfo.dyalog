 r←test_addrinfo dummy;Host;Port;TestConnect;ret;srvs;tests;expect;rr;z;maxwait
⍝ Test Protocol
 Port←5000
 maxwait←5000

 TestConnect←{
     (addr port srv prot)←⍵
     0≢⊃rc←iConga.Clt''addr port,(0<⍴prot)/(⊂'Protocol'prot):'Clt failed: ',,⍕rc
     (0 'Connect' 0)≢(⊂1 3 4)⌷ret←4↑iConga.Wait srv maxwait:'Srv wait failed: ',,⍕ret
     0≢⊃ret←iConga.Close 2⊃rc:'Close failed: ',,⍕ret
     (0 'Closed' 1119)≢(⊂1 3 4)⌷ret←4↑iConga.Wait srv maxwait:'Srv Wait failed: ',,⍕ret
     ''
 }

 :If 0 check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)check ret←iConga.GetProp'.' 'EventMode'
     →fail because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 ⍝ Start Server
 srvs←('SA' ''Port)('S4' ''(Port+4)('Protocol' 'ipv4'))('S6' ''(Port+6)('Protocol' 'ipv6'))

 :If (0,¨1⌷¨srvs)check ret←iConga.Srv¨srvs
     →fail becaues'Failed to start all servers ',,⍕ret ⋄ :EndIf

 tests←('localhost' '127.0.0.1' '::1' '')∘.{(⊂⍺),⍵,⊂''}{⍵[3 1]}¨srvs

 expect←(⍴tests)⍴1
 expect[2;3]←0  ⍝ No ip v4 clt to ip v6 srv
 expect[3;2]←0  ⍝ No ip v6 clt to ip v4 srv

 rr←TestConnect¨tests
 :If expect check ret←0=⊃∘⍴¨rr
     →fail because'Tests did not provide expected results: ',,⍕(,expect≠ret)/,tests ⋄ :EndIf

 :If ((⍴srvs)⍴0)check⊃¨ret←iConga.Close¨1⊃¨srvs
     →fail because'Failed to close all servers: ',,⍕ret ⋄ :EndIf

 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨1⊃¨srvs
