 {r}←TestSecureWebServerCB stop;files;folder;cmd;cltcert;cltkey;certpath;tid;port
     ⍝ Start a web server, request a page from it, kill it

 port←8081

 {}1 ##.DRC.Init'' ⍝ Kill all Conga objects
 ##.DRC.SetProp'.' 'RootCertDir'(CertPath,'ca')

 tid←##.WebServer.HttpsRun&'#.Samples.SecureCallback'port'HTTPSRV'server
 ⎕DL 1 ⍝ Give the server a change to wake up

 :If 0=1⊃(r cmd)←2↑##.DRC.Clt'' 'localhost'port'Text' 10000('X509'john)('SSLValidation' 16)
     ⎕←'Web Server Certificate:' ⋄ 'Cert'DisplayCert ##.DRC.GetProp cmd'PeerCert'
 :Else
     r cmd ⋄ →
 :EndIf

     ⍝ Fetch a page
 r←john 16 HTTPGet'https://localhost:8081/foo?arg1=1 2 3&arg2=4 5 6'

 {}##.DRC.Close cmd

 :If stop ⋄ {}##.DRC.Close'HTTPSRV'
 :Else ⋄ 'Server still running - to stop it:' ⋄ '' ⋄ '      ##.DRC.Close''HTTPSRV'''
 :EndIf

 :While tid∊⎕TNUMS ⋄ ⎕DL 1 ⋄ :EndWhile ⍝ Wait for server thread to close down
