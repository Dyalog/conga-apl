 r←test_modes dummy;Host;Port;maxwait;Magic;data;sizes;convdata;ret;mode;args;tdata;types;s1;c1;res;type;size;rs
⍝ Test raw blkraw text blktext
 Host←'localhost' ⋄ Port←5000
 maxwait←1000
 Magic←{(4/256)⊥⎕UCS 4↑⍵}
 sizes←,(2*1+⍳20)∘.+¯1 0 1

 convdata←{
     ⍺=83:⍵-256×⍵>127
     (⍺=80)∧(80≠⎕DR ⍵):⎕UCS ⍵
     (⍺=82)∧(80≠⎕DR ⍵):⎕AV[⎕IO+⍵]
     ⍺=163:⍵
     ⍵
 }

 :If 0 check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)check ret←iConga.GetProp'.' 'EventMode'
     →fail because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf



 :For mode :In 'raw' 'blkraw' 'text' 'blktext'
     :If ∨/'blk'⍷mode
         args←(40+⌈/sizes)('Magic'(Magic'BlkT'))
     :Else
         args←,⊂2*16
     :EndIf
     tdata←(-⎕IO)+⍳256

     :If ∨/'raw'⍷mode
         types←83 163
     :Else
         types←⎕DR' '
         tdata←(⊃types)convdata tdata
     :EndIf


     :If (0)check⊃ret←iConga.Srv'' ''Port mode,args
         →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
     s1←2⊃ret

     :If 0 check⊃ret←iConga.Clt''Host Port mode,args
         →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
     c1←2⊃ret

     :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
         →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf


     :For type :In types
         :For size :In sizes
             data←size⍴tdata

             :If 0 check⊃ret←iConga.Send c1(type convdata data)
                 →fail because'Send failed: ',,⍕ret ⋄ :EndIf

             rs←0
             :While (rs<size)
                 :If (0 'Block')check(⊂1 3)⌷4↑res←iConga.Wait s1 maxwait
                     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
                 :If 1 check(4⊃res){⍺≡(⍴⍺)⍴⍵}rs{((⍴⍵)|⍺)⌽⍵}tdata
                     →fail because'filedata is wrong ' ⋄ :EndIf
                 rs+←⍴4⊃res

             :EndWhile


         :EndFor
     :EndFor
     :If 0 check⊃ret←iConga.Close c1
         →fail because'Close failed: ',,⍕ret ⋄ :EndIf

     :If ∨/'blk'⍷mode
         :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
             →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
     :Else
         :If (0 'BlockLast')check(⊂1 3)⌷4↑res←iConga.Wait s1 maxwait
             →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
     :EndIf

     :If 0 check⊃ret←iConga.Close s1
         →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 :EndFor
 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨c1 s1
