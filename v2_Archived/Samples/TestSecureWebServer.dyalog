 {r}←TestSecureWebServer;files;folder;cmd;tid;port;cert
     ⍝ Start a web server, request a page from it, kill it

 port←8080
 {}1 ##.DRC.Init'' ⍝ Kill all Conga objects
 ##.DRC.SetProp'.' 'RootCertDir'(CertPath,'ca')

 folder←+2 ⎕NQ'.' 'GetEnvironment' 'Dyalog'
 folder,←'samples\asp.net\tutorial'

 tid←##.WebServer.HttpsRun&folder port'HTTPSRV'server
 ⎕DL 1 ⍝ Give the server a chance to wake up

 :If 0=1⊃(r cmd)←2↑##.DRC.Clt'' 'localhost'port'Text' 10000('X509'client)('SSLValidation' 16)
     'Web Server Certificate:'DisplayCert ##.DRC.GetProp cmd'PeerCert'
 :Else
     r cmd ⋄ →
 :EndIf

     ⍝ Fetch n pages using a separate client thread for each
 files←(⊂'notthere.htm'),{'intro',(⍕⍵),'.htm'}¨⍳10
 r←{⎕TSYNC client HTTPGet&'https://localhost:8080/',⍵}¨files
 :If 0∨.≠⊃¨1⊃¨r ⋄ ∘:EndIf ⍝ Errors

     {}##.DRC.Close¨cmd'HTTPSRV'
     r←files,[1.5]4⊃¨r

     :While tid∊⎕TNUMS ⋄ ⎕DL 1 ⋄ :EndWhile ⍝ Wait for server thread to close down
