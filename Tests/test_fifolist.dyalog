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

         :If 1005 Check⊃ret←iConga.SetProp s1'FifoMode'fifo
             →fail Because'Set FifoMode to ',(⍕fifo),' failed: ',,⍕ret ⋄ :EndIf
         ⍝ return from test Fifo has been disabled

         :If 0 Check⊃ret←iConga.Close s1
             →fail Because'Close failed: ',,⍕ret ⋄ :EndIf
         ⎕DL 0.1


     :EndFor ⍝ mode
 :EndFor ⍝ fifo

 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close s1
 ErrorCleanup
