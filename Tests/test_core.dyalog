 r←test_core dummy;prots;Port;Host;srv;clt;maxwait;Cert;secure;prot;ret;srvx509;cltx509;con;srvcert;cltcert;protocol;z;res;data;pa;la
⍝∇Test: group=Basic
⍝ Test fundamental Conga functionality

 prots←∪⊃¨2⊃iConga.GetProp'.' 'TCPLookup' 'localhost' 80 ⍝ Available protocols takes from IP addresses
 Port←5000 ⋄ Host←'localhost'
 srv←'S1' ⋄ clt←'C1'
 data←'hello' '⍺∊⍵'(1 2 3)(○1 2 3)(0J1×⍳100) ⍝ test data

 maxwait←5000
 Cert←{(⍺.Cert)⍺⍺ ⍵.Cert}

 :For secure :In 0 1             ⍝ insecure tests, then secure
     :For prot :In (⊂''),prots   ⍝ all protocol variants, but first "auto"
         protocol←(prot≢'')/⊂('Protocol'prot)

         :If 0 check⊃ret←iConga.SetProp'.' 'EventMode' 0
             →fail because'Set EventMode to 0 failed: ',,⍕ret ⋄ :EndIf

         :If secure
             :Trap ##.halt↓0
                 srvx509←ReadCert'server/localhost'
                 cltx509←ReadCert'client/client'
             :Else
                 →fail because'Unable to load certificates'
             :EndTrap
             :If 0 check⊃ret←iConga.SetProp'.' 'RootCertDir'(CertPath,'ca')
                 →fail because'Set RootCertDir failed: ',,⍕ret ⋄ :EndIf
         :Else
             srvx509←cltx509←⍬
         :EndIf

         ⍝ Establish Connections & send request data
         :If 0 check⊃ret←iConga.Srv srv''Port,protocol,secure/('X509'srvx509)('SSLValidation' 64)
             →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
         :If 0 check⊃ret←iConga.Clt clt Host Port,protocol,secure/('x509'cltx509)('SSLValidation' 0)
             →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
         :If 0 check⊃ret←iConga.Send clt data
             →fail because'Clt Send failed: ',,⍕ret ⋄ :EndIf
         :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
             →fail because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf

         con←2⊃ret ⍝ Server-side connection name

         :If secure ⍝ Validate Peer Certificates
             srvcert←iConga.GetProp clt'PeerCert' ⍝ debug: 'server' FormatCert srvcert
             cltcert←iConga.GetProp con'PeerCert'
             :If (2 1⊃srvcert)(check Cert)2 1⊃iConga.GetProp con'OwnCert'
             :OrIf (2 1⊃cltcert)(check Cert)2 1⊃iConga.GetProp clt'OwnCert'
                 →fail because'Peer certificates not correct: ',,⍕ret ⋄ :EndIf
         :EndIf

         ⍝ Respond to request
         :If (0 'Receive'data)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
             →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
         :If 0 check⊃ret←iConga.Respond(2⊃res)(⌽data)
             →fail because'Respond failed: ',,⍕ret ⋄ :EndIf
         :If (0 'Receive'(⌽data))check(⊂1 3 4)⌷4↑res←iConga.Wait clt maxwait
             →fail because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

         ⍝ Validate Peer Addresses
         :If 0 check⊃pa←iConga.GetProp clt'PeerAddr'
             →fail because'Unable to get Client PeerAddr: ',,⍕pa ⋄ :EndIf
         :If 0 check⊃la←iConga.GetProp con'LocalAddr'
             →fail because'Unable to get Server LocalAddr: ',,⍕la ⋄ :EndIf
         :If (2 2⊃la)check 2 2⊃pa
             →fail because'Client Peer & Server Local addresses did not match: ',,⍕(2 2∘⊃¨pa la) ⋄ :EndIf

         :If 0 check⊃pa←iConga.GetProp con'PeerAddr'
             →fail because'Unable to get Server PeerAddr: ',,⍕pa ⋄ :EndIf
         :If 0 check⊃la←iConga.GetProp clt'LocalAddr'
             →fail because'Unable to get Client LocalAddr: ',,⍕la ⋄ :EndIf
         :If (2 2⊃la)check 2 2⊃pa
             →fail because'Server Peer & Client Local addresses did not match: ',,⍕(2 2∘⊃¨pa la) ⋄ :EndIf
         :If (clt srv)check{⍵[⍋↑⍵]}z←iConga.Names'.'
             →fail because'List of names not as expected: ',,⍕z ⋄ :EndIf

         ⍝ Close down
         :If 0 check⊃ret←iConga.Close clt
             →fail because'Clt close failed: ',,⍕ret ⋄ :EndIf
         :If (0 'Error' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
             →fail because'Did not get 1119 from Srv Wait: ',,⍕res ⋄ :EndIf
         :If 0 check⊃ret←iConga.Close srv
             →fail because'Srv close failed: ',,⍕ret ⋄ :EndIf

     :EndFor ⍝ protocol
 :EndFor ⍝ secure
 r←''
 →0

fail:
 r←'with protocol="',prot,'", secure=',(⍕secure),': ',r
 z←iConga.Close¨srv clt
