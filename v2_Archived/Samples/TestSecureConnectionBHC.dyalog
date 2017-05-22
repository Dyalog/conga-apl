 {flags}TestSecureConnectionBHC(sm cm);ret;certpath;c;flags;srvcert;srvkey;cltkey;cltcert;z;data;y;i;yy;zz;type;port
     ⍝ Test the ability to create a Secure Connection
 type←⍬ ⍝ Type of connection to create
 port←5001 ⍝ Port to use for tests

 :If 0=⎕NC'flags'
     flags←128+64
 :EndIf
     ⍝ Prepare certificates and keys

 certpath←CertPath

 srvcert←certpath,'server/server-cert.pem'
 srvkey←certpath,'server/server-key.pem'

 cltcert←certpath,'client/client-cert.pem'
 cltkey←certpath,'client/client-key.pem'

 1 ##.DRC.Init''
 ##.DRC.SetProp'.' 'RootCertDir'(certpath,'ca')

     ⍝ Create a secure server
     ⍝flags←128+64
     ⍝flags←64+32 ⍝ Request ClientCertificate, don't validate it
 :Select sm
 :Case 0 ⍝ no security
     ret←##.DRC.Srv'S1' ''port,type
 :Case 1 ⍝ original way two certificate files in PEM format
     ret←##.DRC.Srv'S1' ''port,type,('PublicCertFile'('DER'srvcert))('PrivateKeyFile'('DER'srvkey))('SSLValidation'flags)
 :Case 2 ⍝ use X509 class
     server←⊃##.DRC.X509Cert.ReadCertFromFile srvcert
     server.KeyOrigin←'DER'srvkey
     ret←##.DRC.Srv'S1' ''port,type,('SSLValidation'flags)('X509'server)
 :Case 3 ⍝ Passing certificate in raw format
     server←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'server/server-cert.der'
     server.KeyOrigin←'DER'srvkey
     ret←##.DRC.Srv'S1' ''port,type,('PublicCertData'(server.Cert))('PrivateKeyFile'('DER'srvkey))('SSLValidation'flags)

 :Case 4 ⍝ Passing certificate in raw format with chain
     server←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'server/server-cert.der'
     server.KeyOrigin←'DER'srvkey
     ca←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'ca/ca-cert.pem'
     ret←##.DRC.Srv'S1' ''port,type,('PublicCertData'(server.Cert ca.Cert))('PrivateKeyFile'('DER'srvkey))('SSLValidation'flags)
 :EndSelect

 :If 0≠1⊃ret
     ⎕←'Server returned error:'ret
     →0
 :EndIf

     ⍝ Create a client of the secure server
 :Select cm
 :Case 0 ⍝ no Certificate
     ret←##.DRC.Clt'C1' '127.0.0.1'port,type
 :Case 1 ⍝ Original way two files
     ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('PublicCertFile'('DER'cltcert))('PrivateKeyFile'('DER'cltkey))('SSLValidation' 16)
 :Case 2 ⍝ use X509 class
     john←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/john-cert.pem'
     john.KeyOrigin←'DER'(certpath,'client/john-key.pem')
     ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('SSLValidation' 16)('X509'john)
 :Case 3 ⍝ Pasing raw certificate
     john←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/john-cert.pem'
     ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('PublicCertdata'(john.Cert))('PrivateKeyFile'('DER'(certpath,'Client/john-key.pem')))('SSLValidation' 16)
 :Case 4 ⍝ Certificate with chain
     ca←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'ca/ca-cert.pem'
     john←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/john-cert.pem'
     john.KeyOrigin←'DER'(certpath,'client/john-key.pem')
     ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('PublicCertdata'(john.Cert ca.Cert))('PrivateKeyFile'('DER'(certpath,'Client/john-key.pem')))('SSLValidation' 16)
 :Case 5 ⍝ read from MS Store
     certs←##.DRC.X509Cert.ReadCertFromStore'My'
     bhcca←certs{⊃(⍺.Formatted.Subject∊⊂⍵)/⍺}'C=DK,O=Insight Systems ApS,OU=Development,CN=Bjørn Christensen,UID=bhc'
     ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('SSLValidation' 16)('X509'bhcca)
 :Case 6
     certs←##.DRC.X509Cert.ReadCertFromStore'My'
     bhctdc←certs{⊃(⍺.Formatted.Subject∊⊂⍵)/⍺}'C=DK,O=Ingen organisatorisk tilknytning,CN=#426af8726e2048656c76696720436872697374656e73656e+serialNumber=PID:9208-2002-2-871917342843'
     ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('SSLValidation' 16)('X509'bhctdc)
 :Case 7
     hellebak←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/hellebak-cert.pem'
     hellebak.KeyOrigin←'DER'(certpath,'client/hellebak-key.pem')
     ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('SSLValidation' 16)('X509'hellebak)
 :Case 8
     bhcbak←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/bhcbak-cert.pem'
     bhcbak.KeyOrigin←'DER'(certpath,'client/bhcbak-key.pem')
     ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('SSLValidation' 16)('X509'bhcbak)
 :Case 9
     bhcbak←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/bhcbak-cert.pem'
     bhcbak.KeyOrigin←'DER'(certpath,'client/bhcbak-key.pem')
     hellebak←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/hellebak-cert.pem'
     hellebak.KeyOrigin←'DER'(certpath,'client/hellebak-key.pem')
     ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('PublicCertdata'(bhcbak.Cert hellebak.Cert))('PrivateKeyFile'('DER'(certpath,'Client/bhcbak-key.pem')))('SSLValidation' 16)
 :Case 10 ⍝ Original way two files
     ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('PublicCertFile'('DER'(certpath,'client/bhcbakc-cert.pem')))('PrivateKeyFile'('DER'(certpath,'client/bhcbak-key.pem')))('SSLValidation' 16)

 :EndSelect

 :If 0≠1⊃ret
     ⎕←'Error creating Client:'ret
     →0
 :EndIf

 'Server Certificate'DisplayCert ##.DRC.GetProp'C1' 'PeerCert'

 c←##.DRC.Wait'S1' 10000 ⍝ First event on the server should be the connect event
 'Client Certificate'DisplayCert z←##.DRC.GetProp(2⊃c)'PeerCert'
 :If 0<⊃⍴2⊃z
 :AndIf ~(1↑2⊃z)≡Cert 1↑y←2⊃##.DRC.GetProp'C1' 'OwnCert'
     ⎕←'Serverside Connections PeerCert does not match Clients OwnCert - that''s odd!'
     ∘
 :EndIf

 zz←##.DRC.GetProp(2⊃c)'OwnCert'
 :If 0<⊃⍴2⊃zz
 :AndIf ~(1↑2⊃zz)≡Cert 1↑yy←2⊃##.DRC.GetProp'C1' 'PeerCert'
     ⎕←'Serverside Connections OwnCert does not match Clients PeerCert - that''s odd!'
     ∘
 :EndIf

 data←'hello' 'this' 'is' 'a' 'test'(⍳3)
 {}##.DRC.Send'C1'data
 c←##.DRC.Wait'S1' 1000

 ##.DRC.Respond(2⊃c)(⌽4⊃c)
 z←##.DRC.Wait'C1' 10000
 :If data≡⌽4⊃z
     ⎕←'Secure Connection Test Successful'
 :Else
     ⎕←'Oops - sent:' 'Received:',[1.5]data z
 :EndIf

 {}##.DRC.Close¨'C1' 'S1'
