 r←test_fifodelete dummy;Host;Port;maxwait;data;connections;messages;Connect;Load;ret;s1;now;cons;Cnt;CntRecv;CntBlck;err;obj;evt;dat;tim;z;FlushPending;mode;fifo;scon;scons;Ready;maxdel;ready;results;m;SendRecv;Wait;i;twait;tend;tids;port
⍝  Test Fifo list
 Host←'localhost' ⋄ Port←0
 maxwait←1000
 data←'May the force be with you'
 connections←20
 messages←40
s1←⍬  ⍝ avoid VALUE ERROR on s1
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


 cons←⍬
 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 1)Check ret←iConga.GetProp'.' 'EventMode'
     →fail Because'Verify EventMode failed: ',,⍕ret ⋄ :EndIf

 :For maxdel :In 0 1 3
     :For mode :In ⊆'Command' 'BlkText'
         :For fifo :In 0 1
             :If (0)Check⊃ret←NewSrv'' ''Port mode
                 →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
             s1←2⊃ret
             port←3⊃ret
             :If 0 Check⊃ret←iConga.SetProp'.' 'ReadyStrategy' 2
                 →fail Because'Set ReadyStategy to 2  failed: ',,⍕ret ⋄ :EndIf

             :If 0 Check⊃ret←iConga.SetProp s1'FifoMode'fifo
⍝             :If 1005 Check⊃ret←iConga.SetProp s1'FifoMode'fifo
                 →fail Because'The attempt to set FifoMode to ',(⍕fifo),'  ',,⍕ret ⋄ :EndIf

             :If (0(,fifo))Check ret←iConga.GetProp s1'FifoMode'
                 →fail Because'FifoMode had unexpected value ',(⍕ret) ⋄ :EndIf

             :If (0 2)Check ret←iConga.GetProp'.' 'ReadyStrategy'
                 →fail Because'Verify ReadyStategy to 2  failed: ',,⍕ret ⋄ :EndIf


             now←iConga.Micros

             cons←Connect¨connections⍴⊂(Host port mode)
             cons←{(0=1⊃¨⍵)/2⊃¨⍵}cons

             Cnt←0
             tids←{Cnt+←messages SendReceive ⍵}&¨cons{⍺ ⍵}¨⊂data

             results←0 5⍴⍬
             CntRecv←CntBlck←0
             twait←iConga.Micros
             :While 0=⊃ret←iConga.Waitt s1 maxwait
                 (err obj evt dat tim)←5↑ret
                 results⍪←5↑ret

                 :Select evt
                 :Case 'Timeout'
                     results←¯1 0↓results
                     :Leave
                 :CaseList 'Connect' 'Closed' 'Error'
                 :Case 'Receive'
                     CntRecv+←1
                     :If 0 Check⊃ret←iConga.Respond obj(⌽dat)
                         →fail Because' Respond failed: ',,⍕ret ⋄ :EndIf
                     ⍝ delete 20% but max 3 commands from the fifo queue
                     :If 0<≢scons←(⊂scon,'.'),¨maxdel{⍵[(⍺⌊⌊0.2×≢⍵)?≢⍵]}Ready iConga.Tree scon←'.'{⍵↓⍨-⍺⍳⍨⌽⍵}obj
                         CntRecv+←2×⊃+/0=⊃¨iConga.Close¨scons
                     :EndIf
                 :Case 'Block'
                     CntBlck+←1
                     :If 0 Check⊃ret←iConga.Send obj(⌽dat)
                         →fail Because' Send failed: ',,⍕ret ⋄ :EndIf
                     ⍝ delete 20% but max 3 commands from the fifo queue
                     :If 0<≢scons←(⊂scon,'.'),¨maxdel{⍵[(⍺⌊⌊0.2×≢⍵)?≢⍵]}Ready iConga.Tree scon←obj
                         CntBlck+←2×⊃+/0=⊃¨iConga.Close¨scons
                     :EndIf

                 :EndSelect
             :EndWhile
             tend←iConga.Micros

             :If ('clear')Check ret←FlushPending s1 cons
                 →fail Because'Flush  failed: ',,⍕ret ⋄ :EndIf

             :If 0 Check⊃ret←iConga.Close s1
                 →fail Because'Close failed: ',,⍕ret ⋄ :EndIf
             ⎕DL 0.1

             ready←(↑results[;5])[;2]
             ready-←⊃ready
             :If ~∧/m←1,(1↓ready)>¯1↓ready
                 :If ##.verbose
                     maxdel mode fifo
                     results[;5]←{⍵-1 1⊃⍵}results[;5]
                     :For i :In 1⌈¯5+⍸~m
                         results[i+⍳10;]
                     :EndFor
                 :EndIf

                 →fail Because'Results are not chronological '
             :EndIf
             ⎕TSYNC tids
             :If (2×connections×messages)Check Cnt+CntRecv+CntBlck
                 →fail Because'No all messages was accounted for' ⋄ :EndIf
⍝             ⎕←maxdel fifo mode(tend-twait)
⍝             ⎕←(connections×messages)(Cnt+CntRecv+CntBlck)
         :EndFor ⍝ mode
     :EndFor ⍝ fifo
 :EndFor ⍝ maxdel

 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨cons,⊂s1
 ErrorCleanup
