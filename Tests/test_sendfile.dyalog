 r←test_sendfile dummy;Host;Port;maxwait;Magic;MakeFile;data;ret;s1;c1;s2;c2;res;size;rs;z
⍝ Test Send file
 Host←'localhost' ⋄ Port←5000
 maxwait←1000
 Magic←{(4/256)⊥⎕UCS 4↑⍵}
 MakeFile←{
     nopen←{                              ⍝ handle on null file.
         0::⎕SIGNAL ⎕EN                  ⍝ signal error to caller.
         22::⍵ ⎕NCREATE 0                ⍝ ~exists: create.
         ⍵ ⎕NTIE 0                      ⍝  exists: tie.
     }
     (name size data)←⍵
     tie←nopen name
     _←0 ⎕NRESIZE tie
     _←(size⍴data)⎕NAPPEND tie
     ⎕NUNTIE tie
 }
 data←'dette er en test '

 :If 0 check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)check ret←iConga.GetProp'.' 'EventMode'
     →fail because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Srv'' ''Port'Text'(2*16)
     →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
 s1←2⊃ret

 :If 0 check⊃ret←iConga.Clt''Host Port'Text'(2*16)
     →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
 c1←2⊃ret

 :If (0)check⊃ret←iConga.Srv'' ''(Port+1)'BlkText'(2*30)('Magic'(Magic'BlkT'))
     →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
 s2←2⊃ret

 :If 0 check⊃ret←iConga.Clt''Host(Port+1)'BlkText'(2*30)('Magic'(Magic'BlkT'))
     →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
 c2←2⊃ret


 :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait s2 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :For size :In ,(2*1+⍳20)∘.+¯1 0 1
     MakeFile'test.dat'size data
     :If (0)check⊃ret←iConga.Send c1('' 'test.dat')
         →fail because'Send failed: ',,⍕ret ⋄ :EndIf


     rs←0
     :While (rs<size)
         :If (0 'Block')check(⊂1 3)⌷4↑res←iConga.Wait s1 maxwait
             →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
         :If 1 check(4⊃res){⍺≡(⍴⍺)⍴⍵}rs{((⍴⍵)|⍺)⌽⍵}data
             →fail because'filedata is wrong ' ⋄ :EndIf
         rs+←⍴4⊃res

     :EndWhile

     :If (0)check⊃ret←iConga.Send c2('' 'test.dat')
         →fail because'Send failed: ',,⍕ret ⋄ :EndIf

     :If (0 'Block'(size⍴data))check(⊂1 3 4)⌷4↑res←iConga.Wait s2 maxwait
         →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 :EndFor

 :If 0 check⊃ret←iConga.Close c1
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.Close c2
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 :If (0 'BlockLast')check(⊂1 3)⌷4↑res←iConga.Wait s1 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait s2 maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Close s1
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.Close s2
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 :Trap 0
     {⍵ ⎕NERASE ⍵ ⎕NTIE 0}'test.dat'
 :EndTrap
 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨c1 c2 s1 s2
