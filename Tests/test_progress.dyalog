 r←test_progress dummy;Host;Port;maxwait;data;ret;srv;c1;ccmd;con1;res;scmd;lp
⍝ Test progress
 Host←'localhost' ⋄ Port←5000
 maxwait←5000
 data←'Testing 1 2 3'

 lp←'.'∘{(1-(⌽⍵)⍳⍺)↑⍵}
 :If 0 check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)check ret←iConga.GetProp'.' 'EventMode'
     →fail because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Srv'' ''Port
     →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret

 :If 0 check⊃ret←iConga.Clt''Host Port
     →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
 c1←2⊃ret

 :If (0)check⊃ret←iConga.Send c1 data
     →fail because'Send failed: ',,⍕ret ⋄ :EndIf
 ccmd←2⊃ret

 :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 con1←2⊃res

 :If (0 'Receive'data)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 scmd←2⊃res

 :If (lp ccmd)check(lp scmd)
     →fail because'Command names does not match' ⋄ :EndIf


 :If (0)check⊃ret←iConga.Progress scmd('10%')
     →fail because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Progress scmd('20%')
     →fail because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Progress scmd('30%')
     →fail because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Progress scmd('40%')
     →fail because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Progress scmd('50%')
     →fail because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Progress scmd('60%')
     →fail because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Progress scmd('70%')
     →fail because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Progress scmd('80%')
     →fail because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Progress scmd('90%')
     →fail because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Progress' '10%')check(⊂1 3 4)⌷4↑res←iConga.Wait ccmd maxwait
     →fail because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Progress' '20%')check(⊂1 3 4)⌷4↑res←iConga.Wait ccmd maxwait
     →fail because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Progress' '30%')check(⊂1 3 4)⌷4↑res←iConga.Wait ccmd maxwait
     →fail because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Progress' '40%')check(⊂1 3 4)⌷4↑res←iConga.Wait ccmd maxwait
     →fail because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0)check⊃ret←iConga.Respond scmd(⌽data)
     →fail because'Respond failed: ',,⍕ret ⋄ :EndIf

 ⎕DL 0.1

 :If (0 'Receive'(⌽data))check(⊂1 3 4)⌷4↑res←iConga.Wait ccmd maxwait
     →fail because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf


 :If (1010)check⊃res←iConga.Wait ccmd maxwait
     →fail because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Close c1
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Timeout' 100)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Close srv
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf
 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨c1 srv
