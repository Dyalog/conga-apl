 r←test_sendcomplete dummy;Host;Port;maxwait;ret;srv;c1;cmd1;cmd2;cmd3;res;z;Magic
 ⍝ Test Send complete event
 Host←'localhost' ⋄ Port←5000
 maxwait←5000
 Magic←{(4/256)⊥⎕UCS 4↑⍵}

 :If 0 check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)check ret←iConga.GetProp'.' 'EventMode'
     →fail because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.SetProp'.' 'ReadyStrategy' 3
     →fail because'Set ReadyStrategy to 3 failed: ',,⍕ret ⋄ :EndIf

 :If (0 3)check ret←iConga.GetProp'.' 'ReadyStrategy'
     →fail because'Verify ReadyStrategy failed: ',,⍕ret ⋄ :EndIf

 testname←'Command mode'
 :If (0)check⊃ret←iConga.Srv'' ''Port
     →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret

 :If 0 check⊃ret←iConga.Clt''Host Port
     →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
 c1←2⊃ret

 :If (0)check⊃ret←iConga.Send c1'test 1 1'
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf
 cmd1←2⊃ret

 :If (0)check⊃ret←iConga.Send c1'test 1 2' 3
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf
 cmd2←2⊃ret

 :If (0)check⊃ret←iConga.Send c1'test 1 3' 3
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf
 cmd3←2⊃ret

 :If (0 'Sent' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait(cmd2)maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 1')check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Respond(2⊃res)(4⊃res)
     →fail because'Respond failed: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 2')check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Respond(2⊃res)(4⊃res)
     →fail because'Respond failed: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 3')check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Respond(2⊃res)(4⊃res)
     →fail because'Respond failed: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 1')check(⊂1 3 4)⌷4↑res←iConga.Wait cmd1 maxwait
     →fail because'Bad result from clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 2')check(⊂1 3 4)⌷4↑res←iConga.Wait cmd2 maxwait
     →fail because'Bad result from clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Receive' 'test 1 3')check(⊂1 3 4)⌷4↑res←iConga.Wait cmd3 maxwait
     →fail because'Bad result from clt Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Close c1
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Close srv
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 testname←'Block Text mode'

 :If (0)check⊃ret←iConga.Srv'' ''Port'BlkText' 10000('Magic'(Magic'TRex'))
     →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret

 :If 0 check⊃ret←iConga.Clt''Host Port'BlkText' 10000('Magic'(Magic'TRex'))
     →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
 c1←2⊃ret

 :If (0)check⊃ret←iConga.Send c1'test 1 1'
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf
 cmd1←2⊃ret

 :If (0)check⊃ret←iConga.Send c1'test 1 2' 3
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf
 cmd2←2⊃ret

 :If (0)check⊃ret←iConga.Send c1'test 1 3' 3
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf
 cmd3←2⊃ret

 :If (0 'Sent' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait c1 maxwait
     →fail because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Block' 'test 1 1')check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Send(2⊃res)(4⊃res)
     →fail because'Respond failed: ',,⍕res ⋄ :EndIf

 :If (0 'Block' 'test 1 2')check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Send(2⊃res)(4⊃res)
     →fail because'Respond failed: ',,⍕res ⋄ :EndIf

 :If (0 'Block' 'test 1 3')check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Send(2⊃res)(4⊃res)
     →fail because'Respond failed: ',,⍕res ⋄ :EndIf

 :If (0 'Sent' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait c1 maxwait
     →fail because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Block' 'test 1 1')check(⊂1 3 4)⌷4↑res←iConga.Wait c1 maxwait
     →fail because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Block' 'test 1 2')check(⊂1 3 4)⌷4↑res←iConga.Wait c1 maxwait
     →fail because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Block' 'test 1 3')check(⊂1 3 4)⌷4↑res←iConga.Wait c1 maxwait
     →fail because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf


 :If 0 check⊃ret←iConga.Close c1
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Close srv
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨c1 srv
