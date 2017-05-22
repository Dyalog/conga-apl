 {flags}TestSecureServer sm;ret;certpath;c;flags;srvcert;srvkey;cltkey;cltcert;z;data;y;i;yy;zz;type;port
     ⍝ Test the ability to create a Secure Connection
 type←⊂'Text'  ⍝ Type of connection to create
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


 :While 1
     rs←##.DRC.Wait'S1' 10000
     :If 0=⊃rs
         :If 'Connect'≡3⊃rs
             'Client Certificate'DisplayCert z←##.DRC.GetProp(2⊃rs)'PeerCert'
         :EndIf
     :EndIf
 :EndWhile


 {}##.DRC.Close¨'C1' 'S1'
