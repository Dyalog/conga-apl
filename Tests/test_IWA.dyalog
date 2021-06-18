 r←test_IWA dummy;Port;Host;Clt;Srv;data;compare;maxwait;Cert;ret;srv;clt;con;srvret;cltret;res;tid;ns
⍝∇Test: group=Basic
⍝ Test fundamental Conga functionality

 Port←5000 ⋄ Host←'localhost'
 Srv←'' ⋄ Clt←''
 data←'hello' '⍺∊⍵'(1 2 3)(○1 2 3)(0J1×⍳100) ⍝ test data

 compare←{1=⍴∪1⊃¨⍵:1=≢∪2⊃¨⍵ ⋄ 1=≢∪{¯7↑255 255,⊃,/⍵[3 4]}¨⍵}

 maxwait←5000


 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 0
     →fail Because'Set EventMode to 0 failed: ',,⍕ret ⋄ :EndIf


         ⍝ Establish Connections & send request data
 :If 0 Check⊃ret←iConga.Srv Srv''Port
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret
 :If 0 Check⊃ret←iConga.Clt Clt Host Port
     →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
 clt←2⊃ret
 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
     →fail Because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf

 con←2⊃ret ⍝ Server-side connection name

 ns←⎕NS''
 tid←ns{⍺.srvret←iConga.ServerAuth ⍵}&con

 cltret←iConga.ClientAuth clt
 ⎕TSYNC tid
 srvret←ns.srvret

 :If cltret Check srvret
     →fail Because'Client and server got different authentication' ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Send clt data
     →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf

         ⍝ Respond to request
 :If (0 'Receive'data)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 :If 0 Check⊃ret←iConga.Respond(2⊃res)(⌽data)
     →fail Because'Respond failed: ',,⍕ret ⋄ :EndIf
 :If (0 'Receive'(⌽data))Check(⊂1 3 4)⌷4↑res←iConga.Wait clt maxwait
     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :If (clt srv)Check{⍵[⍋↑⍵]}z←iConga.Names'.'
     →fail Because'List of names not as expected: ',,⍕z ⋄ :EndIf

         ⍝ Close down
 :If 0 Check⊃ret←iConga.Close clt
     →fail Because'Clt close failed: ',,⍕ret ⋄ :EndIf
 :If (0 'Error' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Did not get 1119 from Srv Wait: ',,⍕res ⋄ :EndIf
 :If 0 Check⊃ret←iConga.Close srv
     →fail Because'Srv close failed: ',,⍕ret ⋄ :EndIf

 r←''
 →0

fail:
 z←iConga.Close¨srv clt
 {}iConga.Wait'.' 0
