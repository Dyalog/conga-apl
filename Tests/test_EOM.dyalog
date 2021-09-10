 r←test_EOM dummy;Host;Port;maxwait;Magic;data;sizes;convdata;ret;mode;args;tdata;types;s1;c1;res;type;size;rs;seps;smode;cmode;ns;remain;blockcnt;eot;expected;ic;ignorecase;tc;port
⍝ Test raw  text EOM
 Host←'localhost' ⋄ Port←0
 maxwait←1000
 ic←{⍵⍵=0:⍺ ⍺⍺ ⍵ ⋄ ((819⌶)⍺)⍺⍺((819⌶)⍵)}
 s1←c1←⍬
 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)Check ret←iConga.GetProp'.' 'EventMode'
     →fail Because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 eot←'<ENDOFTEST>'
 seps←'<end>' '<END>' '<fin>' '<FIN>' '<ende>' '<ENDE>'

 data←,4{cnt←⍺×≢⍵ ⋄ (((20+cnt?100)↑¨⊂'Messages '),¨⍕¨⍳cnt),[1.5]cnt⍴⍵}seps

⍝  convdata←{
⍝     ⍺=83:⍵-256×⍵>127
⍝     (⍺=80)∧(80≠⎕DR ⍵):⎕UCS ⍵
⍝     (⍺=82)∧(82≠⎕DR ⍵):⎕AV[⎕IO+⍵]
⍝     ⍺=163:⍵
⍝     ⍵
⍝ }

 tc←{⎕AV[((1+⎕NXLATE 0)⍳⍳256)⍳⎕AV⍳⍵]}

 convdata←{(⍺≡'raw')∧(80=⎕DR ⍵):⎕UCS ⍵ ⋄
     (⍺≡'raw')∧(82=⎕DR ⍵):⎕AVU[⎕AV⍳⍵] ⋄
     ⍵}

 args←⍬
 ⍝ Server modes
 :For smode :In 'raw' 'text'
     ⍝ Client modes
     :For cmode :In 'raw' 'text'
         ⍝ Case sensitive
         :For ignorecase :In 0 1
             ⍝ Number of separaters to  consider
             :For ns :In ⍳≢seps

                 args←('EOM'((⊂eot),ns⍴seps))('ignorecase'ignorecase)

                 :If (0)Check⊃ret←NewSrv'' ''Port smode,args
⍝                 :If (0)Check⊃ret←NewSrv'' ''Port smode('EOM'(tc¨(⊂eot),ns⍴seps))('ignorecase'ignorecase)
                     →fail Because'Srv failed with ret=',(,⍕ret),' for mode=',(⍕mode),', args=',⍕args ⋄ :EndIf
                 s1←2⊃ret
                 port←3⊃ret
                 :If 0 Check⊃ret←iConga.Clt''Host port cmode,args
⍝                 :If 0 Check⊃ret←iConga.Clt''Host port cmode('EOM'(tc¨(⊂eot),ns⍴seps))('ignorecase'ignorecase)
                     →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
                 c1←2⊃ret

                 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
                     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

                 tdata←(⊃,/data),eot
                 size←≢tdata

                 ⍝ Calculate expected messages to receive
                 expected←(1 2⊃args){(⊃∨/(-≢¨⍺)⌽¨⍺(⍷ic ignorecase)¨⊂⍵)⊂⍵}tdata
                 ⍝ send all the data in one go
⍝                 :If 0 Check⊃ret←iConga.Send c1(cmode convdata tdata)
                 :If 0 Check⊃ret←iConga.Send c1(tdata)
                     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf

                 remain←size
                 blockcnt←0
                 ⍝ receive blocks on the server side and send them back
                 :While remain>0
                     blockcnt+←1
                     :If (0 'Block'(smode convdata blockcnt⊃expected))Check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
                         →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
                     :If 0 Check⊃ret←iConga.Send(2⊃res)(4⊃res)
                         →fail Because'Send failed: ',,⍕ret ⋄ :EndIf
                     remain-←≢4⊃res
                 :EndWhile


                 remain←size
                 blockcnt←0
                 ⍝ Receive blocks on the client side
                 :While remain>0
                     blockcnt+←1
                     :If (0 'Block'(cmode convdata blockcnt⊃expected))Check(⊂1 3 4)⌷4↑res←iConga.Wait c1 maxwait
                         →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
                     remain-←≢4⊃res
                 :EndWhile



                 :If 0 Check⊃ret←iConga.Close c1
                     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

                 :If ∨/'blk'⍷smode
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
     :EndFor
 :EndFor
 r←''   ⍝ surprise all worked!
 →0
fail:
 r←'smode=',(smode),' cmode=',(cmode),' ignorecase=',(⍕ignorecase),' count seps=',(⍕ns),': ',r
 z←iConga.Close¨c1 s1
 ErrorCleanup
