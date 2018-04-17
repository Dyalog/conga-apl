 r←test_fifolist dummy;Host;Port;maxwait;data;connections;messages;Connect;Load;ret;s1;now;cons;Cnt;CntRecv;CntBlck;err;obj;evt;dat;tim;z;FlushPending;mode
⍝ Test Fifo list
 Host←'localhost' ⋄ Port←5000
 maxwait←1000
 data←'May the force be with you'
 connections←20
 messages←40

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
         {}{Cnt+←messages SendReceive ⍵}&¨cons{⍺ ⍵}¨⊂data
⍝         {}{Cnt+←Load ⍵}&¨(messages/cons){⍺ ⍵}¨⊂data

         CntRecv←CntBlck←0
         :While 0=⊃ret←iConga.Waitt s1 maxwait
             err obj evt dat tim←5↑ret
             :If 0 Check(0≠2⊃tim)∧now>2⊃tim
                 →fail Because'not chronological '
             :Else
                 now←2⊃tim
             :EndIf
             :Select evt
             :Case 'Timeout'
                 :Leave
             :CaseList 'Connect' 'Closed' 'Error'
             :Case 'Receive'
                 CntRecv+←1
⍝                 :If ∨/s1⍷obj
                 :If 0 Check⊃ret←iConga.Respond obj(⌽dat)
                     →fail Because' Respond failed: ',,⍕ret ⋄ :EndIf
⍝                 :Else
⍝                     :If (0(⌽data))Check err dat
⍝                         →fail Because'Wrong data returned: ',,⍕ret ⋄ :EndIf
⍝                 :EndIf
             :Case 'Block'
                 CntBlck+←1
⍝                 :If ∨/s1⍷obj
                 :If 0 Check⊃ret←iConga.Send obj(⌽dat)
                     →fail Because' Send failed: ',,⍕ret ⋄ :EndIf
⍝                 :Else
⍝                     :If (0(⌽data))Check err dat
⍝                         →fail Because'Wrong data returned: ',,⍕ret ⋄ :EndIf
⍝                 :EndIf
             :EndSelect
         :EndWhile

         :If ('clear')Check ret←FlushPending s1 cons
             →fail Because'Flush  failed: ',,⍕ret ⋄ :EndIf

         :If 0 Check⊃ret←iConga.Close s1
             →fail Because'Close failed: ',,⍕ret ⋄ :EndIf
         ⎕DL 0.1

         :If (2×connections×messages)Check Cnt+CntRecv+CntBlck
             →fail Because'No all messages was accounted for' ⋄ :EndIf

     :EndFor ⍝ mode
 :EndFor ⍝ fifo

 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨cons,⊂s1
 ErrorCleanup
