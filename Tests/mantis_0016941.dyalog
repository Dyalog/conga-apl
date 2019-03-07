 r←mantis_0016941 dummy;Port;Host;protocol;Srv;Clt;ret;srvx509;cltx509;srv;clt;data;maxwait;con;res;z;secure
⍝∇Test: group=Mantis
⍝ pause on secure server

 Port←5000 ⋄ Host←'localhost' ⋄ protocol←''
 Srv←'' ⋄ Clt←''
 data←'hello' '⍺∊⍵'(1 2 3)(○1 2 3)(0J1×⍳100) ⍝ test data
 maxwait←2000
 secure←1

 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 0
     →fail Because'Set EventMode to 0 failed: ',,⍕ret ⋄ :EndIf

 :If secure
     :Trap ##.halt↓0
         srvx509←ReadCert'server/localhost'
         cltx509←ReadCert'client/John Doe'
     :Else
         →fail Because'Unable to load certificates'
     :EndTrap
 :Else
     srvx509←cltx509←⍬
 :EndIf

 :If 0 Check⊃ret←iConga.SetProp'.' 'RootCertDir'(CertPath,'ca')
     →fail Because'Set RootCertDir failed: ',,⍕ret ⋄ :EndIf

         ⍝ Establish Connections & send request data
 :If 0 Check⊃ret←iConga.Srv Srv''Port,protocol,secure/('X509'srvx509)('SSLValidation' 64)
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret

 :For i :In ⍳10

     :If 0=4|i
         ret←iConga.SetProp srv'Pause' 2
         :If 0=⊃ret
             ⎕DL 3
             ret←iConga.SetProp srv'Pause' 0
         :EndIf
         :If 0 Check⊃ret
           →fail Because'Pause failed: ',,⍕ret ⋄ :EndIf
     :EndIf

     :If 0 Check⊃ret←iConga.Clt Clt Host Port,protocol,secure/('x509'cltx509)('SSLValidation' 0)
         →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
     clt←2⊃ret

     :If 0 Check⊃ret←iConga.Send clt data
         →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf
     :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
         →fail Because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf

     con←2⊃ret ⍝ Server-side connection name

         ⍝ Respond to request
     :If (0 'Receive'data)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
         →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
     :If 0 Check⊃ret←iConga.Respond(2⊃res)(⌽data)
         →fail Because'Respond failed: ',,⍕ret ⋄ :EndIf
     :If (0 'Receive'(⌽data))Check(⊂1 3 4)⌷4↑res←iConga.Wait clt maxwait
         →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf


         ⍝ Close down
     :If 0 Check⊃ret←iConga.Close clt
         →fail Because'Clt close failed: ',,⍕ret ⋄ :EndIf
     :If (0 'Error' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
         →fail Because'Did not get 1119 from Srv Wait: ',,⍕res ⋄ :EndIf

 :EndFor

 :If 0 Check⊃ret←iConga.Close srv
     →fail Because'Srv close failed: ',,⍕ret ⋄ :EndIf


 r←''
 →0

fail:
 r←' at the ',(⍕i),' iteration: ',r
 z←iConga.Close¨srv clt
 {}iConga.Wait'.' 0
