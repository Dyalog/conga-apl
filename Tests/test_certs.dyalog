 r←test_certs dummy;ret;win;srvx509;cltx509;cltx509a;cltx509b;cltx509c;cax509;raw;format;caurl;srvurl;clturl;m;count;urls;ixs;prots;Port;Srv;Host;Clt;data;compare;maxwait;Cert;s;c;rcd;tests;certs;srvcert;cltcert;srv;clt;con;srvcertp;cltcertp;res;pa;la;z;Priority;cltstore;srvstore;cas;port
⍝∇Test: group=Basic
⍝ Test fundamental Conga Certificate functionality

 ret←iConga.Certs'ListMSStore'
 :If ~∨/0 1205 1005∊⊃ret
     →fail Because'ListMSStore failed: ',,⍕ret ⋄ :EndIf

 :If 1205=⊃ret
     →fail Because'CongaSSL is not loaded ' ⋄ :EndIf

 win←1005≠⊃ret



 :Trap ##.halt↓0
     srvx509←ReadCert'server/localhost'
     cltx509←ReadCert'client/Jane Doe' ⍝ Cert as data key as filename
     cltx509a←ReadCert'client/Jane Doe'⍝ Cert as filename and key as filname
     cltx509b←⎕NEW iConga.X509Cert cltx509a.Cert ⍝ Cert as data key as data
     ⍝cltx509b←ReadCert'client/Jane Doe'⍝ Cert as data key as data
     cltx509c←ReadCert'client/Jane Doe'⍝ Cert as filename key as data

     cax509←ReadCert'ca/ca'
     cltx509a.Cert←''
     cltx509c.Cert←''
     cltx509b.Key←cltx509c.Key←ReadKey 2⊃cltx509.KeyOrigin

 :Else
     →fail Because'Could not read TestCertificates'
 :EndTrap

 raw←48 84 49 11 48 9 6 3 85 4 6 19 2 85 75 49 14 48 12 6 3 85 4 10 19 5 77 121 79 114 103 49 13 48 11 6 3 85 4 11 19 4 84 101
 raw,←115 116 49 18 48 16 6 3 85 4 8 19 9 72 97 109 112 115 104 105 114 101 49 18 48 16 6 3 85 4 3 19 9 108 111 99 97 108
 raw,←104 111 115 116
 format←'C=UK,O=MyOrg,OU=Test,ST=Hampshire,CN=localhost'

 :If raw Check ret←srvx509.Elements.Subject
     →fail Because'Raw Subject is not as expected' ⋄ :EndIf

 :If format Check ret←srvx509.Formatted.Subject
     →fail Because'Formatted Subject is not as expected',,⍕ret ⋄ :EndIf

 :If format Check ret←srvx509.Extended.Subject
     →fail Because'Extended Subject is not as expected',,⍕ret ⋄ :EndIf




 caurl←srvurl←clturl←⍬
 srvstore←cltstore←⍬
 cas←,⊂'ca'

 :If win
     :If 0 Check⊃ret←iConga.Certs'ListMSStore'
         →fail Because'ListMSStore failed: ',,⍕ret ⋄ :EndIf

     :If ~∧/'My' 'Root' 'CA'∊2⊃ret
         →fail Because'Common stores ( My, Root and CA) are not present ',,⍕ret ⋄ :EndIf

     :If 0=≢ret←iConga.ReadCertFromStore'Root'
         →fail Because'ReadCertFromStore retured no certs: ' ⋄ :EndIf
     m←ret.Formatted.Subject∊⊂cax509.Formatted.Subject
     count←+/ret[⍸m].Cert≡¨⊂{⍵+¯256×⍵>127}cax509.Cert

     :If (+/m)≠≢ret←iConga.ReadCertFromStore'Root'('Subject'({⍵+¯256×⍵>127}cax509.Elements.Subject))
         →fail Because'ReadCertFromStore retured wrong number of certs: ' ⋄ :EndIf
     :If 0<+/m
         :If ~∧/ret.Formatted.Subject∊⊂cax509.Formatted.Subject
             →fail Because'ReadCertFromStore returned wrong certificates' ⋄ :EndIf
         cas,←,⊂''
     :EndIf
     urls←iConga.ReadCertUrls

     :If 0<≢urls
         ixs←urls.Cert⍳{⍵+¯256×⍵>127}¨(cax509 srvx509 cltx509).Cert
         (caurl srvurl clturl)←(urls,⊂⍬)[ixs]
     :EndIf
     certs←iConga.ReadCertFromStore'My'

     ixs←certs.Cert⍳{⍵+¯256×⍵>127}¨(srvx509 cltx509).Cert
     (srvstore cltstore)←(certs,⊂⍬)[ixs]

     cltx509.UseMSStoreAPI←1
     :If 0=≢cltx509.Formatted.Subject
     :OrIf 0=≢cltx509.Extended.Subject
         →fail Because'Cert decode failed:' ⋄ :EndIf
 :EndIf



 prots←∪⊃¨2⊃iConga.GetProp'.' 'TCPLookup' 'localhost' 80 ⍝ Available protocols takes from IP addresses
 Port←0 ⋄ Host←'localhost'
 Priority←''
 Srv←'' ⋄ Clt←''
 data←'hello' '⍺∊⍵'(1 2 3)(○1 2 3)(0J1×⍳100) ⍝ test data

 compare←{1=⍴∪1⊃¨⍵:1=≢∪2⊃¨⍵ ⋄ 1=≢∪{¯7↑255 255,⊃,/⍵[3 4]}¨⍵}

 maxwait←5000
 Cert←{({⍵+¯256×⍵>127}⍺.Cert)⍺⍺{⍵+¯256×⍵>127}⍵.Cert}

 s←(srvx509 srvurl srvstore)~⊂⍬
 c←(cltx509 cltx509a cltx509b cltx509c clturl cltstore)~⊂⍬
 rcd←∪cas

 tests←,(,s∘.,c)∘.,⊂¨rcd
 ⍝tests←(srvx509 cltx509'ca')(srvx509 clturl'')
 :For certs :In tests
               ⍝ insecure tests, then secure

     :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 0
         →fail Because'Set EventMode to 0 failed: ',,⍕ret ⋄ :EndIf

     :If 0 Check⊃ret←iConga.SetProp'.' 'InvalidateCache' 100
         →fail Because'Set InvalidateCache to 100 failed: ',,⍕ret ⋄ :EndIf

     ⍝CongaTrace 1034 40
     srvcert←1⊃certs
     cltcert←2⊃certs

     :If (0 1208)[1+0=≢3⊃certs]Check⊃ret←iConga.SetProp'.' 'RootCertDir'(CertPath,3⊃certs)
         →fail Because'Set RootCertDir failed: ',,⍕ret ⋄ :EndIf
⍝     ret
⍝     {(1 1⊃⍵)(2 1⊃⍵)(2 2 1⊃⍵)}¨(cltcert srvcert).AsArg

         ⍝ Establish Connections & send request data
     :If 0 Check⊃ret←NewSrv Srv''Port,('X509'srvcert)('SSLValidation' 64)⍝('Priority'Priority)
         →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
     srv←2⊃ret
     port←3⊃ret
     :If 0 Check⊃ret←iConga.Clt Clt Host port,('x509'cltcert)('SSLValidation' 0)⍝('Priority'Priority)
         →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
     clt←2⊃ret
     ⍝CongaTrace 0 0
     :If 0 Check⊃ret←iConga.Send clt data
         →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf
     :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
         →fail Because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf

     con←2⊃ret ⍝ Server-side connection name

⍝     :If (srvcert)(Check Cert)2 1⊃iConga.GetProp con'OwnCert'
⍝     :OrIf (cltcert)(Check Cert)2 1⊃iConga.GetProp clt'OwnCert'
⍝         →fail Because'Peer certificates not correct: ',,⍕ret ⋄ :EndIf

     srvcertp←iConga.GetProp clt'PeerCert' ⍝ debug: 'server' FormatCert srvcert
     cltcertp←iConga.GetProp con'PeerCert'

     :If (2 1⊃srvcertp)(Check Cert)2 1⊃iConga.GetProp con'OwnCert'
         →fail Because'Peer certificates not correct: ',,⍕ret ⋄ :EndIf
     :If ⍬≡2⊃cltcertp
         'test_certs'Log'No client certificate present'
     :Else
         :If (2 1⊃cltcertp)(Check Cert)2 1⊃iConga.GetProp clt'OwnCert'
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
     ⎕DL 0.1
     :If 0<≢ret←iConga.Names'.'
         ⎕DL 0.1 ⋄ :EndIf
 :EndFor ⍝ secure
 r←''
 →0

fail:
 ⍝CongaTrace 0 0
⍝ r←'with protocol="',prot,'", secure=',(⍕secure),': ',r
 :If 2=⎕NC'clt'
     z←iConga.Close clt ⋄ :EndIf
 {}iConga.Wait'.' 0
 :If 2=⎕NC'srv'
     z←iConga.Close srv ⋄ :EndIf

 {}iConga.Wait'.' 0
