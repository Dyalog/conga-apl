 z←TestSecureWebClient;certpath
     ⍝ Read a sample secure page from the internet

 {}1 ##.DRC.Init''
 ##.DRC.SetProp'.' 'RootCertDir'(CertPath,'ca')
 z←HTTPGet'https://test.gnutls.org:5556'
