 r←test_endpoints dummy;Host;Port;maxwait;Magic;ret;EndPoints;Allowed;s1;s2;ep;c1;c2;res
 ⍝ Test endpoints
 Host←'localhost' ⋄ Port←5000
 maxwait←1000
 Magic←{(4/256)⊥⎕UCS 4↑⍵}

 :If 0 check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)check ret←iConga.GetProp'.' 'EventMode'
     →fail because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.SetProp'.' 'ReadyStrategy' 2
     →fail because'Set ReadyStrategy to 2 failed: ',,⍕ret ⋄ :EndIf

 :If (0 2)check ret←iConga.GetProp'.' 'ReadyStrategy'
     →fail because'Verify ReadyStrategy failed: ',,⍕ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.GetProp'.' 'TCPLookup' '' 80
 :AndIf 0 check⊃ret←iConga.GetProp'.' 'TCPLookup' 'localhost' 80
     →fail because'Verify ReadyStrategy failed: ',,⍕ret ⋄ :EndIf


 EndPoints←⍬~⍨{'IPv6'≡1⊃⍵:(1⊃⍵)(1↓¯4↓2⊃⍵) ⋄ 'IPv4'≡1⊃⍵:(1⊃⍵)(¯3↓2⊃⍵) ⋄ ⍬}¨2⊃ret
 Allowed←((⍴EndPoints)⍴1 0)/EndPoints

 :If (0)check⊃ret←iConga.Srv'' ''Port'BlkText' 10000('Magic'(Magic'TRex'))
     →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
 s1←2⊃ret

 :If (0)check⊃ret←iConga.Srv'' ''(1+Port)'BlkText' 10000('Magic'(Magic'TRex'))('AllowEndpoints'(↓{(⊃⍺)(¯1↓⊃,/(2⊃¨Allowed[⍵]),¨('/29,' '/120,')[⎕IO+⍺≡⊂'IPv6'])}⌸1⊃¨Allowed))
     →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
 s2←2⊃ret

 :For ep :In EndPoints
     :If 0 check⊃ret←iConga.Clt''(2⊃ep)Port'BlkText' 10000('Magic'(Magic'TRex'))
         →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
     c1←2⊃ret

     :If 0 check⊃ret←iConga.Clt''(2⊃ep)(Port+1)'BlkText' 10000('Magic'(Magic'TRex'))
         →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
     c2←2⊃ret

     :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
         →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

     :If ∨/Allowed∊⊂ep
         :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait s2 maxwait
             →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
         :If 0 check⊃ret←iConga.Close c2
             →fail because'Close failed: ',,⍕ret ⋄ :EndIf

         :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait s2 maxwait
             →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
     :Else
         :If (0 'Timeout' 100)check(⊂1 3 4)⌷4↑res←iConga.Wait s2 maxwait
             →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

         :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait c2 maxwait
             →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

     :EndIf

     :If 0 check⊃ret←iConga.Close c1
         →fail because'Close failed: ',,⍕ret ⋄ :EndIf

     :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
         →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf


 :EndFor
 :If 0 check⊃ret←iConga.Close s1
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf
 :If 0 check⊃ret←iConga.Close s2
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf
 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨c1 c2 s1 s2
