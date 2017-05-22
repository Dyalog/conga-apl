 r←test_threaded dummy;Host;maxwait;Port;ret;srv;c1;c2;c3;res;con1;con2;con3;z
 ⍝ Test ConnectionOnly from threaded APL Application
 Host←'localhost' ⋄ Port←5000
 maxwait←5000

 :If 0 check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)check ret←iConga.GetProp'.' 'EventMode'
     →fail because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.SetProp'.' 'ReadyStrategy' 4
     →fail because'Set ReadyStrategy to 4 failed: ',,⍕ret ⋄ :EndIf

 :If (0 4)check ret←iConga.GetProp'.' 'ReadyStrategy'
     →fail because'Verify ReadyStrategy failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Srv'' ''Port
     →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret

 :If 0 check⊃ret←iConga.SetProp srv'ConnectionOnly' 1
     →fail because'Set ConnectionOnly to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0(,1))check ret←iConga.GetProp srv'ConnectionOnly'
     →fail because'Verify ConnectionOnly failed: ',,⍕ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.Clt''Host Port
     →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
 c1←2⊃ret

 :If (0)check⊃ret←iConga.Send c1'test 1 1'
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Send c1'test 1 2'
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.Clt''Host Port
     →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
 c2←2⊃ret

 :If (0)check⊃ret←iConga.Send c2'test 2 1'
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Send c2'test 2 2'
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.Clt''Host Port
     →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
 c3←2⊃ret

 :If (0)check⊃ret←iConga.Send c3'test 3 1'
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Send c3'test 3 2' 1
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 con1←2⊃res

 :If (0 'Receive' 'test 1 1')check(⊂1 3 4)⌷4↑res←iConga.Wait con1 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 con2←2⊃res

 :If (0 'Receive' 'test 2 1')check(⊂1 3 4)⌷4↑res←iConga.Wait con2 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 con3←2⊃res

 :If (0 'Receive' 'test 3 1')check(⊂1 3 4)⌷4↑res←iConga.Wait con3 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Timeout' 100)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 2')check(⊂1 3 4)⌷4↑res←iConga.Wait con1 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 2 2')check(⊂1 3 4)⌷4↑res←iConga.Wait con2 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Closed' 1119)≡(⊂1 3 4)⌷4↑res←iConga.Wait con3 maxwait
     res←iConga.Wait con3 maxwait ⋄ :EndIf

 :If (0 'Receive' 'test 3 2')check(⊂1 3 4)⌷4↑res
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Timeout' 100)check(⊂1 3 4)⌷4↑res←iConga.Wait con1 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Timeout' 100)check(⊂1 3 4)⌷4↑res←iConga.Wait con2 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait con3 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Timeout' 100)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf


 :If 0 check⊃ret←iConga.Close c1
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.Close c2
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait con1 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait con2 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Close srv
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨c1 c2 c3 srv
