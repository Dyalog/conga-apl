 r←test_core dummy;prots;Port;Host;srv;clt;maxwait;Cert;secure;prot;ret;srvx509;cltx509;con;srvcert;cltcert;protocol;z;res;data;pa;la;compare
⍝∇Test: group=Basic
⍝ Test fundamental Conga functionality

 prots←∪⊃¨2⊃iConga.GetProp'.' 'TCPLookup' 'localhost' 80 ⍝ Available protocols takes from IP addresses
 Port←5000 ⋄ Host←'localhost'
 srv←'' ⋄ clt←'C1'
 data←'hello' '⍺∊⍵'(1 2 3)(○1 2 3)(0J1×⍳100) ⍝ test data

 compare←{1=⍴∪1⊃¨⍵: 1=≢∪2⊃¨⍵⋄ 1=≢∪{¯7↑ 255 255,⊃,/⍵[3 4]   }¨⍵ }

 maxwait←5000
 Cert←{(⍺.Cert)⍺⍺ ⍵.Cert}

 :For secure :In 0 1             ⍝ insecure tests, then secure
     :For prot :In (⊂''),prots   ⍝ all protocol variants, but first "auto"
         protocol←(prot≢'')/⊂('Protocol'prot)

         :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 0
             →fail Because'Set EventMode to 0 failed: ',,⍕ret ⋄ :EndIf

         :If secure
             :Trap ##.halt↓0
                 srvx509←ReadCert'server/localhost'
                 cltx509←ReadCert'client/John Doe'
             :Else
                 →fail Because'Unable to load certificates'
             :EndTrap
             :If 0 Check⊃ret←iConga.SetProp'.' 'RootCertDir'(CertPath,'ca')
                 →fail Because'Set RootCertDir failed: ',,⍕ret ⋄ :EndIf
         :Else
             srvx509←cltx509←⍬
         :EndIf

         ⍝ Establish Connections & send request data
         :If 0 Check⊃ret←iConga.Srv srv''Port,protocol,secure/('X509'srvx509)('SSLValidation' 64)
             →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
         srv←2⊃ret
         :If 0 Check⊃ret←iConga.Clt clt Host Port,protocol,secure/('x509'cltx509)('SSLValidation' 0)
             →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
         :If 0 Check⊃ret←iConga.Send clt data
             →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf
         :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
             →fail Because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf

         con←2⊃ret ⍝ Server-side connection name

         :If secure ⍝ Validate Peer Certificates
             srvcert←iConga.GetProp clt'PeerCert' ⍝ debug: 'server' FormatCert srvcert
             cltcert←iConga.GetProp con'PeerCert'
             :If (2 1⊃srvcert)(Check Cert)2 1⊃iConga.GetProp con'OwnCert'
             :OrIf (2 1⊃cltcert)(Check Cert)2 1⊃iConga.GetProp clt'OwnCert'
                 →fail Because'Peer certificates not correct: ',,⍕ret ⋄ :EndIf
         :EndIf

         ⍝ Respond to request
         :If (0 'Receive'data)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
             →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
         :If 0 Check⊃ret←iConga.Respond(2⊃res)(⌽data)
             →fail Because'Respond failed: ',,⍕ret ⋄ :EndIf
         :If (0 'Receive'(⌽data))Check(⊂1 3 4)⌷4↑res←iConga.Wait clt maxwait
             →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

         ⍝ Validate Peer Addresses
         :If 0 Check⊃pa←iConga.GetProp clt'PeerAddr'
             →fail Because'Unable to get Client PeerAddr: ',,⍕pa ⋄ :EndIf
         :If 0 Check⊃la←iConga.GetProp con'LocalAddr'
             →fail Because'Unable to get Server LocalAddr: ',,⍕la ⋄ :EndIf
         :If 1 Check compare 2⊃¨la pa
             →fail Because'Client Peer & Server Local addresses did not match: ',,⍕(2 2∘⊃¨pa la) ⋄ :EndIf

         :If 0 Check⊃pa←iConga.GetProp con'PeerAddr'
             →fail Because'Unable to get Server PeerAddr: ',,⍕pa ⋄ :EndIf
         :If 0 Check⊃la←iConga.GetProp clt'LocalAddr'
             →fail Because'Unable to get Client LocalAddr: ',,⍕la ⋄ :EndIf
         :If 1 Check compare 2⊃¨la pa
             →fail Because'Server Peer & Client Local addresses did not match: ',,⍕(2 2∘⊃¨pa la) ⋄ :EndIf
         :If (clt srv)Check{⍵[⍋↑⍵]}z←iConga.Names'.'
             →fail Because'List of names not as expected: ',,⍕z ⋄ :EndIf

         ⍝ Close down
         :If 0 Check⊃ret←iConga.Close clt
             →fail Because'Clt close failed: ',,⍕ret ⋄ :EndIf
         :If (0 'Error' 1119)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
             →fail Because'Did not get 1119 from Srv Wait: ',,⍕res ⋄ :EndIf
         :If 0 Check⊃ret←iConga.Close srv
             →fail Because'Srv close failed: ',,⍕ret ⋄ :EndIf

     :EndFor ⍝ protocol
 :EndFor ⍝ secure
 r←''
 →0

fail:
 r←'with protocol="',prot,'", secure=',(⍕secure),': ',r
 z←iConga.Close¨srv clt
 {} iConga.Wait '.' 0
⍝)(!test_core!bhc!2018 5 16 16 12 7 0!0
