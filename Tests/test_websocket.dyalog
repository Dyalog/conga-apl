 r←test_websocket dummy;Port;Host;nl;maxwait;Features;MaxSize;to83;utf8;ret;srv;clt;res;Continuation;drt;len;data;Fin;testname;offset;z;wscon;cf;sf
⍝ Test upgrade of http connection to websocket
 Port←8088 ⋄ Host←'localhost'
 nl←⎕UCS 13 10
 maxwait←5000 ⋄ MaxSize←450000
 Features←1   ⍝ Feature 0=APL negotiate 1=AutoUpgrade
 to83←{⍵+¯256×⍵>127}

 utf8←{
     b←127 2047 65535 2097151 67108863 2147483647
     us←1 2 3 4 5 6
     d←1 2 2 4 4 4
     ⍺=80:⎕UCS ⍵↑(,⍉0 1∘.+1↑b),?⍵⍴255
     ⍺=160:⎕UCS ⍵↑(,⍉0 1∘.+2↑b),(3⊃b),?⍵⍴65535
     ⍺=320:⎕UCS ⍵↑(,⍉0 1∘.+3↑b),1114111,?⍵⍴1114111
     ⎕SIGNAL 11
 }
 testname←''
 :For (cf sf) :In ,¯1+⍳2 2  ⍝ test all for combinations of Auto Upgrade
     testname←⊃,/'Client ' 'Server ',¨(0 0){(1+⍺)⊃⍵}¨⊂'Auto ' 'Manual '

     :If 0 check⊃ret←iConga.SetProp'.' 'EventMode' 1
         →fail because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

     :If (0)check⊃ret←iConga.Srv'' ''Port'http'MaxSize
         →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
     srv←2⊃ret

 ⍝ Set feature for server applies to all incomming connections
     :If 0 check⊃ret←iConga.SetProp srv'WSFeatures'sf
         →fail beacuse'SetProp failed: ',,⍕ret ⋄ :EndIf

     :If 0 check⊃ret←iConga.Clt''Host Port'http'MaxSize
         →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
     clt←2⊃ret

     :If 0 check⊃ret←iConga.SetProp clt'WSFeatures'cf
         →fail beacuse'SetProp failed: ',,⍕ret ⋄ :EndIf

     :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
         →fail because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf

 ⍝ Client requests to upgrade the connection 4th arg is extra headers remember to add nl
     :If 0 check⊃ret←iConga.SetProp clt'WSUpgrade'('/' 'localhost'('BHCHeader: Gil',nl))
         →fail beacuse'SetProp failed: ',,⍕ret ⋄ :EndIf


     res←iConga.Wait srv maxwait
     :If sf
         ⍝ Auto upgrade event 4⊃res is the Incomming request but connection have been upgraded
         :If 0 'WSUpgrade'check res[1 3]
             →fail because'Server WebSocket auto upgrade failed',,⍕res ⋄ :EndIf
         wscon←2⊃res
     :Else
         :If 0 'WSUpgradeReq'check res[1 3]
             →fail because'Server WebSocket manual upgrade failed',,⍕res ⋄ :EndIf
         ⍝ Negotiate inspect headers (4⊃res) and accept request with the extra headers you need.
         wscon←2⊃res
         :If 0 check⊃ret←iConga.SetProp wscon'WSAccept'((4⊃res)('GILHeader: bhc',nl))
             →fail beacuse'SetProp failed: ',,⍕ret ⋄ :EndIf
     :EndIf

     res←iConga.Wait clt maxwait
     :If cf
         :If 0 'WSUpgrade'check res[1 3]
             →fail because'Client Websocket auto upgrade failed',,⍕res ⋄ :EndIf
         ⍝ Auto upgrade event 4⊃res is the Incomming request but connection have been upgraded
     :Else
         :If 0 'WSResponse'check res[1 3]
             →fail because'Client Websocket maunal upgrade failed',,⍕res ⋄ :EndIf
      ⍝ Negotiate inspect headers (4⊃res) and accept request by returning the headers or close the connection
         :If 0 check⊃ret←iConga.SetProp clt'WSAccept'((4⊃res)'')
             →fail because'SetProp failed: ',,⍕ret ⋄ :EndIf
     :EndIf

     :For Continuation :In 0 1
  ⍝ Test text (utf8) buffers
         :For drt :In 80 160 320
             :For len :In 0 10 124 125 126 127 128 65535 65536 70000
                 data←drt utf8 len ⍝
                 Fin←⊃(1(len=70000))[⎕IO+Continuation]
                 testname←' WebSocket Text APL Datatype ',(⍕⎕DR data),' buffer length ',(⍕len),Continuation/' and Continuation '

                 :If (0)check⊃ret←iConga.Send clt(data Fin)
                     →fail because'Send failed: ',,⍕ret ⋄ :EndIf

                 :If (0 'WSReceive'(data Fin 1))check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
                     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

                 :If (0)check⊃ret←iConga.Send wscon(data Fin)
                     →fail because'Send failed: ',,⍕ret ⋄ :EndIf

                 :If (0 'WSReceive'(data Fin 1))check(⊂1 3 4)⌷4↑res←iConga.Wait clt maxwait
                     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
             :EndFor
         :EndFor

 ⍝ Test binary  buffers
         :For offset :In -⎕IO+0 128
             :For len :In 0 10 124 125 126 127 128 65535 65536 70000
                 data←offset+len⍴⍳256
                 testname←' WebSocket Text APL Datatype ',(⍕⎕DR data),' and buffer length ',(⍕len),Continuation/' and Continuation '
                 Fin←⊃(1(len=70000))[⎕IO+Continuation]

                 :If (0)check⊃ret←iConga.Send clt(data Fin)
                     →fail because'Send failed: ',,⍕ret ⋄ :EndIf

                 :If (0 'WSReceive'((to83 data)Fin 2))check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
                     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

                 :If (0)check⊃ret←iConga.Send wscon(data Fin)
                     →fail because'Send failed: ',,⍕ret ⋄ :EndIf

                 :If (0 'WSReceive'((to83 data)Fin 2))check(⊂1 3 4)⌷4↑res←iConga.Wait clt maxwait
                     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
             :EndFor
         :EndFor
     :EndFor
 ⍝ Shutdown
     :If 0 check⊃ret←iConga.Close clt
         →fail because'Close failed: ',,⍕ret ⋄ :EndIf

     :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
         →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

     :If 0 check⊃ret←iConga.Close srv
         →fail because'Close failed: ',,⍕ret ⋄ :EndIf
 :EndFor ⍝ Features
 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨clt srv
 r←r,' for ',testname
