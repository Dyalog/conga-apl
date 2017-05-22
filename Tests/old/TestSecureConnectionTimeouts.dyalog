 TestSecureConnectionTimeouts;ret;certpath;c;flags;srvcert;srvkey;cltkey;cltcert;z;data;y;i;yy;zz;type;port
     ⍝ Test connecting a secure client to an insecure server - should timeout
 type←⍬ ⍝ Type of connection to create
 port←5001 ⍝ Port to use for tests

     ⍝ Prepare certificates and keys

 certpath←CertPath

 srvcert←certpath,'server/server-cert.pem'
 srvkey←certpath,'server/server-key.pem'

 cltcert←certpath,'client/client-cert.pem'
 cltkey←certpath,'client/client-key.pem'

 1 ##.DRC.Init''
 ##.DRC.SetProp'.' 'RootCertDir'(certpath,'ca')

     ⍝ Create a secure server
 flags←64+32 ⍝ Request ClientCertificate, don't validate it

 ⎕←'Secure client, insecure server'
 ret←##.DRC.Srv'S1' ''port,type

 :If 0≠1⊃ret
     ⎕←'Server returned error:'ret
 :EndIf

 ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('CertFiles'cltcert)('KeyFile'cltkey)('SSLValidation' 16)
 :If 0≠1⊃ret
     ⎕←'Error creating Client:'ret
 :EndIf


 {}##.DRC.Close¨'C1' 'S1'


     ⍝ Now test connecting an insecure client to a secure server
 ⎕←'Insecure client, secure server'
     ⍝ Create a secure server
 flags←64+32 ⍝ Request ClientCertificate, don't validate it
 ret←##.DRC.Srv'S1' ''port,type,('PublicCert'srvcert)('PrivateCert'srvkey)('SSLValidation'flags)

 :If 0≠1⊃ret
     ⎕←'Server returned error:'ret?
 :EndIf

     ⍝ Create a client of the secure server
 ret←##.DRC.Clt'C1' '127.0.0.1'port,type
 :If 0≠1⊃ret
     ⎕←'Error creating Client:'ret
 :EndIf


 ⎕←'Done'
