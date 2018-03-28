 r←test_fifodelete dummy;Host;Port;maxwait;data;connections;messages;Connect;Load;ret;s1;now;cons;Cnt;CntRecv;CntBlck;err;obj;evt;dat;tim;z;FlushPending;mode;fifo;scon;scons;Ready;maxdel;ready;results
⍝  Test Fifo list
 Host←'localhost' ⋄ Port←5000
 maxwait←5000
 data←'May the force be with you'
 connections←20
 messages←40

 Ready←{0≠⊃⍵:⍬
     {0=≢⍵:⍬ ⋄ s←↑1⊃¨⍵ ⋄ (s[;3]=5)/s[;1]}2 2⊃⍵}


 ⍝ sink all connect events on server , Close all clients and sink all Close events
 FlushPending←{⍺←0 'Connect' 0
     srv clts←⍵
     ⍺≡(⊂1 3 4)⌷4↑iConga.Wait srv 100:⍺ ∇ srv clts
     0<⍴clts:(0 'Closed' 1119)∇(srv ⍬)⊣iConga.Close¨clts
     'clear'
 }

 Connect←{
     (addr port mode)←⍵
     0≢⊃rc←iConga.Clt''addr port mode:'Clt failed: ',,⍕rc
     rc
 }

 Load←{con data←⍵
     0≢⊃ret←iConga.Send con data:'Send failed: ',,⍕ret
     1
 }
 cons←⍬
 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)Check ret←iConga.GetProp'.' 'EventMode'
     →fail Because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 :For maxdel :In 0 3 6
     :For mode :In 'Command' 'BlkText'
         :For fifo :In 0 1
             :If (0)Check⊃ret←iConga.Srv'' ''Port mode
                 →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
             s1←2⊃ret

             :If 0 Check⊃ret←iConga.SetProp'.' 'ReadyStrategy' 2
                 →fail Because'Set ReadyStategy to 2  failed: ',,⍕ret ⋄ :EndIf

             :If 0 Check⊃ret←iConga.SetProp s1'FifoMode'fifo
                 →fail Because'Set FifoMode to ',(⍕fifo),' failed: ',,⍕ret ⋄ :EndIf

             :If (0(,fifo))Check ret←iConga.GetProp s1'FifoMode'
                 →fail Because'Verify FifoMode to ',(⍕fifo),' failed: ',,⍕ret ⋄ :EndIf

             :If (0 2)Check ret←iConga.GetProp'.' 'ReadyStrategy'
                 →fail Because'Verify ReadyStategy to 2  failed: ',,⍕ret ⋄ :EndIf


             now←iConga.Micros

             cons←Connect¨connections⍴⊂(Host Port mode)
             cons←{(0=1⊃¨⍵)/2⊃¨⍵}cons

             Cnt←0
             {}{Cnt+←Load ⍵}&¨(messages/cons){⍺ ⍵}¨⊂data

             results←0 5⍴⍬
             CntRecv←CntBlck←0
             :While 0=⊃ret←iConga.Waitt'.'maxwait
                 (err obj evt dat tim)←5↑ret
                 results⍪←5↑ret

⍝                 :If 0 Check(0≠2⊃tim)∧now>2⊃tim
⍝                     ⎕←err obj evt dat
⍝                     →fail Because'not chronological ',,⍕(now-2⊃tim)maxdel mode fifo
⍝                 :Else
⍝                     now←2⊃tim
⍝                 :EndIf
                 :Select evt
                 :Case 'Timeout'
                     results←¯1 0↓results
                     :Leave
                 :CaseList 'Connect' 'Closed' 'Error'
                 :Case 'Receive'
                     CntRecv+←1
                     :If ∨/s1⍷obj
                         :If 0 Check⊃ret←iConga.Respond obj(⌽dat)
                             →fail Because' Respond failed: ',,⍕ret ⋄ :EndIf
                     ⍝ delete 20% but max 3 commands from the fifo queue
                         :If 0<≢scons←(⊂scon,'.'),¨maxdel{⍵[(⍺⌊⌊0.2×≢⍵)?≢⍵]}Ready iConga.Tree scon←'.'{⍵↓⍨-⍺⍳⍨⌽⍵}obj
                             CntRecv+←2×+/0=iConga.Close¨scons
                         :EndIf
                     :Else
                         :If (0(⌽data))Check err dat
                             →fail Because'Wrong data returned: ',,⍕ret ⋄ :EndIf
                     :EndIf
                 :Case 'Block'
                     CntBlck+←1
                     :If ∨/s1⍷obj
                         :If 0 Check⊃ret←iConga.Send obj(⌽dat)
                             →fail Because' Send failed: ',,⍕ret ⋄ :EndIf
                     ⍝ delete 20% but max 3 commands from the fifo queue
                         :If 0<≢scons←(⊂scon,'.'),¨maxdel{⍵[(⍺⌊⌊0.2×≢⍵)?≢⍵]}Ready iConga.Tree scon←obj
                             CntBlck+←2×+/0=iConga.Close¨scons
                         :EndIf

                     :Else
                         :If (0(⌽data))Check err dat
                             →fail Because'Wrong data returned: ',,⍕ret ⋄ :EndIf
                     :EndIf
                 :EndSelect
             :EndWhile

             :If ('clear')Check ret←FlushPending s1 cons
                 →fail Because'Flush  failed: ',,⍕ret ⋄ :EndIf

             :If 0 Check⊃ret←iConga.Close s1
                 →fail Because'Close failed: ',,⍕ret ⋄ :EndIf
             ⎕DL 0.1

             ready←(↑results[;5])[;2]
             :If ~∧/1,(1↓ready)>¯1↓ready
                 ∘∘∘
                 →fail Because'Results are not chronological '
             :EndIf
             ⎕←connections messages CntRecv CntBlck
         :EndFor ⍝ mode
     :EndFor ⍝ fifo
 :EndFor ⍝ maxdel

 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨cons,⊂s1
 ErrorCleanup
⍝)(!test_fifodelete!bhc!2018 3 27 15 35 10 0!0
