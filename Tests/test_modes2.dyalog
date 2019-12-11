 r←test_modes2 dummy;Host;Port;maxwait;Magic;sizes;convdata;ret;mode;args;tdata;types;s1;c1;res;type;size;rs;rdata;sdata;data;rai
⍝ Test raw blkraw text blktext
 Host←'localhost' ⋄ Port←5000
 maxwait←1000
 Magic←{(4/256)⊥⎕UCS 4↑⍵}
 sizes←,(2*1+⍳20)∘.+¯1 0 1

 convdata←{
     (⍺=163)∧(82=⎕DR ⍵):(⎕NXLATE 0)[⎕AV⍳⍵]
     (⍺=83)∧(82=⎕DR ⍵):83 ∇ 163 ∇ ⍵
     ⍺=83:⍵-256×⍵>127
     (⍺=80)∧(80≠⎕DR ⍵):⎕UCS ⍵
     (⍺=82)∧(82≠⎕DR ⍵):⎕AV[(⎕NXLATE 0)⍳⍵] ⍝⎕aV[⎕IO+⍵]
     ⍺=163:⍵
     ⍵
 }

 s1←c1←⍬
 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)Check ret←iConga.GetProp'.' 'EventMode'
     →fail Because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf


 :For RAB :In 0 iConga.RawAsByte

     :For mode :In 'raw' 'blkraw' 'text' 'blktext'
         :If ∨/'blk'⍷mode
             args←(40+⌈/sizes)('Magic'(Magic'BlkT'))
         :Else
             args←,⊂2*16
         :EndIf
         tdata←(-⎕IO)+⍳256

         types←(⎕DR' '),83 163

         :If (0)Check⊃ret←iConga.Srv'' ''Port mode,args,(RAB≠0)/⊂('Options'RAB)
             →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
         s1←2⊃ret

         :If 0 Check⊃ret←iConga.Clt''Host Port mode,args,(RAB≠0)/⊂('Options'RAB)
             →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
         c1←2⊃ret

         :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
             →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf


         :For type :In types
             sdata←type convdata tdata

             :If ∨/'raw'⍷mode
                 :If type=82
                     rdata←(163 83[⎕IO+RAB=2])convdata sdata
                 :Else
                     rdata←(163 83[⎕IO+RAB=2])convdata tdata
                 :EndIf
             :Else
                 rdata←(⎕DR' ')convdata tdata
             :EndIf

             :For size :In sizes
                 data←size⍴sdata

                 :If 0 Check⊃ret←iConga.Send c1 data
                     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf

                 rs←0
                 :While (rs<size)
                     :If (0 'Block')Check(⊂1 3)⌷4↑res←iConga.Wait s1 maxwait
                         →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
                     :If ~∨/(⊃(2 2/((1+RAB≠2)↑83 163)(⎕DR' '))['raw' 'blkraw' 'text' 'blktext'⍳⊂mode])∊⎕DR 4⊃res
                         →fail Because'datatype is wrong ' ⋄ :EndIf
                     :If 1 Check(4⊃res){⍺≡(⍴⍺)⍴⍵}rs{((⍴⍵)|⍺)⌽⍵}rdata
                         →fail Because'filedata is wrong ' ⋄ :EndIf
                     rs+←⍴4⊃res

                 :EndWhile
             :EndFor
         :EndFor

         :If 0 Check⊃ret←iConga.Close c1
             →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

         :If ∨/'blk'⍷mode
             :If (0 'Closed' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
                 →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
         :Else
             :If (0 'BlockLast')Check(⊂1 3)⌷4↑res←iConga.Wait s1 maxwait
                 →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
         :EndIf

         :If 0 Check⊃ret←iConga.Close s1
             →fail Because'Close failed: ',,⍕ret ⋄ :EndIf
         ⎕DL 0.5
     :EndFor
 :EndFor
 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨c1 s1
 ErrorCleanup
