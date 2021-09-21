 r←test_threaded dummy;Host;maxwait;Port;ret;srv;c1;c2;c3;res;con1;con2;con3;z;port
 ⍝ Test ConnectionOnly from threaded APL Application
 Host←'localhost' ⋄ Port←0
 maxwait←5000
c1←c2←c3←⍬

 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)Check ret←iConga.GetProp'.' 'EventMode'
     →fail Because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 :If 0 Check⊃ret←iConga.SetProp'.' 'ReadyStrategy' 4
     →fail Because'Set ReadyStrategy to 4 failed: ',,⍕ret ⋄ :EndIf

 :If (0 4)Check ret←iConga.GetProp'.' 'ReadyStrategy'
     →fail Because'Verify ReadyStrategy failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←NewSrv'' ''Port
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret
 port←3⊃ret
 :If 0 Check⊃ret←iConga.SetProp srv'ConnectionOnly' 1
     →fail Because'Set ConnectionOnly to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0(,1))Check ret←iConga.GetProp srv'ConnectionOnly'
     →fail Because'Verify ConnectionOnly failed: ',,⍕ret ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Clt''Host port
     →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
 c1←2⊃ret

 :If (0)Check⊃ret←iConga.Send c1'test 1 1'
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Send c1'test 1 2'
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Clt''Host port
     →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
 c2←2⊃ret

 :If (0)Check⊃ret←iConga.Send c2'test 2 1'
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Send c2'test 2 2'
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Clt''Host port
     →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
 c3←2⊃ret

 :If (0)Check⊃ret←iConga.Send c3'test 3 1'
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Send c3'test 3 2' 1
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 con1←2⊃res

 :If (0 'Receive' 'test 1 1')Check(⊂1 3 4)⌷4↑res←iConga.Wait con1 maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 con2←2⊃res

 :If (0 'Receive' 'test 2 1')Check(⊂1 3 4)⌷4↑res←iConga.Wait con2 maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 con3←2⊃res

 :If (0 'Receive' 'test 3 1')Check(⊂1 3 4)⌷4↑res←iConga.Wait con3 maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Timeout' 100)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 2')Check(⊂1 3 4)⌷4↑res←iConga.Wait con1 maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 2 2')Check(⊂1 3 4)⌷4↑res←iConga.Wait con2 maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Closed' 1119)≡(⊂1 3 4)⌷4↑res←iConga.Wait con3 maxwait
     res←iConga.Wait con3 maxwait ⋄ :EndIf

 :If (0 'Receive' 'test 3 2')Check(⊂1 3 4)⌷4↑res
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Timeout' 100)Check(⊂1 3 4)⌷4↑res←iConga.Wait con1 maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Timeout' 100)Check(⊂1 3 4)⌷4↑res←iConga.Wait con2 maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Closed' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait con3 maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Timeout' 100)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf


 :If 0 Check⊃ret←iConga.Close c1
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Close c2
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Closed' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait con1 maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Closed' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait con2 maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Close srv
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨c1 c2 c3 srv
 ErrorCleanup
