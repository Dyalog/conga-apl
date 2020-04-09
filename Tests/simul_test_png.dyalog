 r←simul_test_png;Host;Port;maxwait;Magic;MakeFile;ret;s1;c1;res;size;rs;z;mode;s2;c2;oc;file;iConga
⍝ run test_png w/o DTest!
 ⎕CY'conga' ⋄ iConga←Conga.Init''
 Host←'localhost' ⋄ Port←5000
 maxwait←1000
 Magic←{(4/256)⊥⎕UCS 4↑⍵}
 file←(2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'),'/help/resources/dyaloglogo.png'
 oc←{r←⎕NREAD tie,(⎕DR' '),⎕NSIZE tie←⍵ ⎕NTIE 0 ⋄ sink←⎕NUNTIE tie ⋄ r}file
 ⍝ enmulate testing-DSL:
 Check←{⍺≡⍵:0 ⋄ ⎕←⍺,'≢ ',⍵ ⋄ 1}
 Because←{⎕←⍵ ⋄ ⍺}
 IsNotElement←{({1<≢⍵:⊂⍵ ⋄ ⍵}⍺)∊⍵:0 ⋄ ⎕←⍺,' not∊ ',⍵ ⋄ 1}
 :For mode :In 'BlkText' 'Text'
     ⍝Log'mode=',mode
     :If 0 Check⊃ret←iConga.Srv'' ''Port mode(5000)
         →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
     s1←2⊃ret

     :If 0 Check⊃ret←iConga.Clt''Host Port mode(5000)
         →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
     c1←2⊃ret

     :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
         →fail Because'Unexpected result from Srv Wait (mode=',mode,'): ',,⍕res ⋄ :EndIf

     :If 0 Check⊃ret←iConga.Send c1(''file)1
         →fail Because'Send failed: ',,⍕ret ⋄ :EndIf

     rs←⍬
     :Repeat
         res←iConga.Wait s1 maxwait
         :If mode≡'BlkText'
             :If res[1 3 4]Check 0 'Error' 1135
                 →fail Because'Srv Wait handled big block w/o error: ',,⍕res ⋄ :EndIf
         :Else
             :If res[1 3]IsNotElement(0 'Block')(100 'Timeout')(0 'BlockLast')
                 →fail Because'Unexpected result from Srv Wait in mode=',mode,',: ',,⍕res[1 3] ⋄ :EndIf
         :EndIf
         :If 3<≢res
         :AndIf 0<≢4⊃res
             :If res[3]∊'Block' 'BlockLast'
                 rs,←4⊃res
             :EndIf
         :EndIf
     :Until 'Block'≢3⊃res
     :If rs≢⍬
     :AndIf oc Check rs
         →fail Because'Content sent & received via Conga does not match original file-content' ⋄ :EndIf

     :If (⊃ret←iConga.Wait s1 maxwait)IsNotElement 0 100 ⍝ Wait for srv to receive Close-event of client (0 or 100 "TIMEOUT" are ok)
         →fail Because'Error during Wait of Srv:',⍕ret ⋄ :EndIf

     :If 0 Check⊃ret←iConga.Close s1
         →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

 :EndFor ⍝ mode

 r←''
 →0
fail:
 z←iConga.Close¨c1 s1
