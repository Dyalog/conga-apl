 r←test_protocol dummy;Host;Port;TestConnect;ret;srvs;tests;expect;rr;z;maxwait
⍝ Test Protocol
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

 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)Check ret←iConga.GetProp'.' 'EventMode'
     →fail Because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 ⍝ Start Server
 srvs←('SA' ''Port)('S4' ''(Port+4)('Protocol' 'ipv4'))('S6' ''(Port+6)('Protocol' 'ipv6'))

 :If (0,¨1⌷¨srvs)Check ret←iConga.Srv¨srvs
     →fail Because'Failed to start all servers ',,⍕ret ⋄ :EndIf

 tests←((⊂Host){⍺ ⍵}¨⍬'ip' 'ipv4' 'ipv6')∘.{(⍺,⍵)[1 3 4 2]}{⍵[3 1]}¨srvs


 expect←(⍴tests)⍴1
 :If 'IPv4'≡2 1⊃iConga.GetProp'SA' 'localAddr'
     expect[4;1 2]←0
 :Else
     expect[3;3]←0  ⍝ No ip v4 clt to ip v6 srv
     expect[4;2]←0  ⍝ No ip v6 clt to ip v4 srv
 :EndIf

 rr←TestConnect¨tests
 :If expect Check ret←0=⊃∘⍴¨rr
     →fail Because'Tests did not provide expected results: ',,⍕(,expect≠ret)/,tests ⋄ :EndIf

 :If ((⍴srvs)⍴0)Check⊃¨ret←iConga.Close¨1⊃¨srvs
     →fail Because'Failed to close all servers: ',,⍕ret ⋄ :EndIf

 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨1⊃¨srvs
 ErrorCleanup
