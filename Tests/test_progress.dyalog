 r←test_progress dummy;Host;Port;maxwait;data;ret;srv;c1;ccmd;con1;res;scmd;lp
⍝  Test progress
 Host←'localhost' ⋄ Port←5000
 maxwait←5000
 data←'Testing 1 2 3'
 srv←c1←⍬
 lp←'.'∘{(1-(⌽⍵)⍳⍺)↑⍵}
 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)Check ret←iConga.GetProp'.' 'EventMode'
     →fail Because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Srv'' ''Port
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret

 :If 0 Check⊃ret←iConga.Clt''Host Port
     →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
 c1←2⊃ret

 :If (0)Check⊃ret←iConga.Send c1 data
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf
 ccmd←2⊃ret

 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 con1←2⊃res

 :If (0 'Receive'data)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 scmd←2⊃res

 :If (lp ccmd)Check(lp scmd)
     →fail Because'Command names does not match' ⋄ :EndIf


 :If (0)Check⊃ret←iConga.Progress scmd('10%')
     →fail Because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Progress scmd('20%')
     →fail Because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Progress scmd('30%')
     →fail Because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Progress scmd('40%')
     →fail Because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Progress scmd('50%')
     →fail Because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Progress scmd('60%')
     →fail Because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Progress scmd('70%')
     →fail Because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Progress scmd('80%')
     →fail Because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Progress scmd('90%')
     →fail Because'Progress failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Progress' '10%')Check(⊂1 3 4)⌷4↑res←iConga.Wait ccmd maxwait
     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Progress' '20%')Check(⊂1 3 4)⌷4↑res←iConga.Wait ccmd maxwait
     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Progress' '30%')Check(⊂1 3 4)⌷4↑res←iConga.Wait ccmd maxwait
     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Progress' '40%')Check(⊂1 3 4)⌷4↑res←iConga.Wait ccmd maxwait
     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (0)Check⊃ret←iConga.Respond scmd(⌽data)
     →fail Because'Respond failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Progress' '50%')≡(⊂1 3 4)⌷4↑res←iConga.Wait ccmd maxwait
     ⍝'test_progress'Log'Got 50% expected answer delay and retry'
     ⎕DL 1
     res←iConga.Wait ccmd maxwait
 :EndIf

 :If (0 'Receive'(⌽data))Check(⊂1 3 4)⌷4↑res
     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf


 :If (1010)Check⊃res←iConga.Wait ccmd maxwait
     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Close c1
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Closed' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Timeout' 100)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Close srv
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf
 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨c1 srv
 ErrorCleanup
⍝)(!test_progress!bhc!2018 4 17 15 4 51 0!0
