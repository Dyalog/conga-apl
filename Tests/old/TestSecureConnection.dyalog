 TestSecureConnection;ret;certpath;c;flags;srvcert;srvkey;cltkey;cltcert;z;data;y;i;yy;zz;type;port
     ⍝ Test the ability to create a Secure Connection
 type←⍬ ⍝ Type of connection to create
 port←5001 ⍝ Port to use for tests


 1 ##.DRC.Init''
 ##.DRC.SetProp'.' 'RootCertDir'(CertPath,'ca')

     ⍝ Create a secure server
 flags←64+32 ⍝ Request ClientCertificate, don't validate it
 ret←##.DRC.Srv'S1' ''port,type,('X509'server)('SSLValidation'flags)
 :If 0≠1⊃ret
     ⎕←'Server returned error:'ret
     →0
 :EndIf

     ⍝ Create a client of the secure server
 ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('SSLValidation' 16)('X509'client)
 :If 0≠1⊃ret
     ⎕←'Error creating Client:'ret
     →0
 :EndIf

 'Server Certificate'DisplayCert ##.DRC.GetProp'C1' 'PeerCert'

 c←##.DRC.Wait'S1' 10000 ⍝ First event on the server should be the connect event
 'Client Certificate'DisplayCert z←##.DRC.GetProp(2⊃c)'PeerCert'

 :If ~(1↑2⊃z)≡Cert 1↑y←2⊃##.DRC.GetProp'C1' 'OwnCert'
     ⎕←'Serverside Connections PeerCert does not match Clients OwnCert - that''s odd!'
     ∘
 :EndIf

 zz←##.DRC.GetProp(2⊃c)'OwnCert'
 :If ~(1↑2⊃zz)≡Cert 1↑yy←2⊃##.DRC.GetProp'C1' 'PeerCert'
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
