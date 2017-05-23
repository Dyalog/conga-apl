 r←test_sendcomplete dummy;Host;Port;maxwait;ret;srv;c1;cmd1;cmd2;cmd3;res;z;Magic
 ⍝ Test Send complete event
 Host←'localhost' ⋄ Port←5000
 maxwait←5000
 Magic←{(4/256)⊥⎕UCS 4↑⍵}

 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)Check ret←iConga.GetProp'.' 'EventMode'
     →fail Because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 :If 0 Check⊃ret←iConga.SetProp'.' 'ReadyStrategy' 3
     →fail Because'Set ReadyStrategy to 3 failed: ',,⍕ret ⋄ :EndIf

 :If (0 3)Check ret←iConga.GetProp'.' 'ReadyStrategy'
     →fail Because'Verify ReadyStrategy failed: ',,⍕ret ⋄ :EndIf

 testname←'Command mode'
 :If (0)Check⊃ret←iConga.Srv'' ''Port
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret

 :If 0 Check⊃ret←iConga.Clt''Host Port
     →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
 c1←2⊃ret

 :If (0)Check⊃ret←iConga.Send c1'test 1 1'
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf
 cmd1←2⊃ret

 :If (0)Check⊃ret←iConga.Send c1'test 1 2' 3
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf
 cmd2←2⊃ret

 :If (0)Check⊃ret←iConga.Send c1'test 1 3' 3
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf
 cmd3←2⊃ret

 :If (0 'Sent' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait(cmd2)maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 1')Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Respond(2⊃res)(4⊃res)
     →fail Because'Respond failed: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 2')Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Respond(2⊃res)(4⊃res)
     →fail Because'Respond failed: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 3')Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Respond(2⊃res)(4⊃res)
     →fail Because'Respond failed: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 1')Check(⊂1 3 4)⌷4↑res←iConga.Wait cmd1 maxwait
     →fail Because'Bad result from clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 2')Check(⊂1 3 4)⌷4↑res←iConga.Wait cmd2 maxwait
     →fail Because'Bad result from clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 3')Check(⊂1 3 4)⌷4↑res←iConga.Wait cmd3 maxwait
     →fail Because'Bad result from clt Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Close c1
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Closed' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Close srv
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

 testname←'Block Text mode'

 :If (0)Check⊃ret←iConga.Srv'' ''Port'BlkText' 10000('Magic'(Magic'TRex'))
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret

 :If 0 Check⊃ret←iConga.Clt''Host Port'BlkText' 10000('Magic'(Magic'TRex'))
     →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
 c1←2⊃ret

 :If (0)Check⊃ret←iConga.Send c1'test 1 1'
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf
 cmd1←2⊃ret

 :If (0)Check⊃ret←iConga.Send c1'test 1 2' 3
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf
 cmd2←2⊃ret

 :If (0)Check⊃ret←iConga.Send c1'test 1 3' 3
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf
 cmd3←2⊃ret

 :If (0 'Sent' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait c1 maxwait
     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Block' 'test 1 1')Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Send(2⊃res)(4⊃res)
     →fail Because'Respond failed: ',,⍕res ⋄ :EndIf

 :If (0 'Block' 'test 1 2')Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Send(2⊃res)(4⊃res)
     →fail Because'Respond failed: ',,⍕res ⋄ :EndIf

 :If (0 'Block' 'test 1 3')Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Send(2⊃res)(4⊃res)
     →fail Because'Respond failed: ',,⍕res ⋄ :EndIf

 :If (0 'Sent' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait c1 maxwait
     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Block' 'test 1 1')Check(⊂1 3 4)⌷4↑res←iConga.Wait c1 maxwait
     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Block' 'test 1 2')Check(⊂1 3 4)⌷4↑res←iConga.Wait c1 maxwait
     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Block' 'test 1 3')Check(⊂1 3 4)⌷4↑res←iConga.Wait c1 maxwait
     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf


 :If 0 Check⊃ret←iConga.Close c1
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Closed' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Close srv
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨c1 srv
