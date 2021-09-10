 r←test_endpoints dummy;Host;Port;maxwait;Magic;ret;EndPoints;Allowed;s1;s2;ep;c1;c2;res;P0;P1
 ⍝ Test endpoints
 Host←'localhost' ⋄ Port←0
 maxwait←1000
 Magic←{(4/256)⊥⎕UCS 4↑⍵}

 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)Check ret←iConga.GetProp'.' 'EventMode'
     →fail Because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 :If 0 Check⊃ret←iConga.SetProp'.' 'ReadyStrategy' 2
     →fail Because'Set ReadyStrategy to 2 failed: ',,⍕ret ⋄ :EndIf

 :If (0 2)Check ret←iConga.GetProp'.' 'ReadyStrategy'
     →fail Because'Verify ReadyStrategy failed: ',,⍕ret ⋄ :EndIf

 :If 0 Check⊃ret←iConga.GetProp'.' 'TCPLookup' '' 80
 :AndIf 0 Check⊃ret←iConga.GetProp'.' 'TCPLookup' 'localhost' 80
     →fail Because'TCPLookup failed failed: ',,⍕ret ⋄ :EndIf


 EndPoints←⍬~⍨{'IPv6'≡1⊃⍵:(1⊃⍵)(1↓¯4↓2⊃⍵) ⋄ 'IPv4'≡1⊃⍵:(1⊃⍵)(¯3↓2⊃⍵) ⋄ ⍬}¨2⊃ret
 Allowed←((⍴EndPoints)⍴1 0)/EndPoints

 :If (0)Check⊃ret←NewSrv'' ''Port'BlkText' 10000('Magic'(Magic'TRex'))
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 s1←2⊃ret
 P0←3⊃ret

 :If 0 Check⊃res←iConga.SetProp s1'KeepAlive'(17 47)
     →fail Because'SetProp Keepalive failed: ',,⍕ret ⋄ :EndIf

 :If 0(17 47)Check res←iConga.GetProp s1'KeepAlive'
     →fail Because'GetProp Keepalive failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←NewSrv'' ''(Port+1×|×Port)'BlkText' 10000('Magic'(Magic'TRex'))('AllowEndpoints'(↓{(⊃⍺)(¯1↓⊃,/(2⊃¨Allowed[⍵]),¨('/29,' '/120,')[⎕IO+⍺≡⊂'IPv6'])}⌸1⊃¨Allowed))
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 s2←2⊃ret
 P1←3⊃ret

 :For ep :In EndPoints
     :If 0 Check⊃ret←iConga.Clt''(2⊃ep)P0'BlkText' 10000('Magic'(Magic'TRex'))
         →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
     c1←2⊃ret

     :If 0 Check⊃ret←iConga.Clt''(2⊃ep)(P1)'BlkText' 10000('Magic'(Magic'TRex'))
         →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
     c2←2⊃ret

     :If 0 Check⊃res←iConga.SetProp c1'KeepAlive'(19 37)
         →fail Because'SetProp Keepalive failed: ',,⍕ret ⋄ :EndIf

     :If 1037 Check⊃res←iConga.GetProp c1'KeepAlive'
         →fail Because'GetProp Keepalive failed: ',,⍕ret ⋄ :EndIf


     :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
         →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

     :If ∨/Allowed∊⊂ep
         :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait s2 maxwait
             →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
         :If 0 Check⊃ret←iConga.Close c2
             →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

         :If (0 'Closed' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait s2 maxwait
             →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
     :Else
         :If (0 'Timeout' 100)Check(⊂1 3 4)⌷4↑res←iConga.Wait s2 maxwait
             →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

         :If (0 'Closed' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait c2 maxwait
             →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

     :EndIf

     :If 0 Check⊃ret←iConga.Close c1
         →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

     :If (0 'Closed' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
         →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf


 :EndFor
 :If 0 Check⊃ret←iConga.Close s1
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf
 :If 0 Check⊃ret←iConga.Close s2
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf
 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨c1 c2 s1 s2
