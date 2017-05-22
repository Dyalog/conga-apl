 TestAllSecure;certpath
     ⍝ Run all Secure tests
 {}1 ##.DRC.Init''
 :Trap 22 ⍝ Check that we can find the certificates
     certpath←CertPath
 :Else
     ⎕←'Secure tests cancelled...' ⋄ →0
 :EndTrap

 TestX509Certs   ⍝ Read certificates from files into X509Cert instances


 TestSecureConnection
 TestSecureWebServer
 TestSecureWebServerCB 1
 TestSecureTelnetServer
 2↑TestSecureWebClient
