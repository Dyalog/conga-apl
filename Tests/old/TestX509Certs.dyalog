 TestX509Certs;certpath;srvcert;srvkey;cltcert;cltkey;ic;ifcs;iscs


 john←ReadCert'client/john'
 geoff←ReadCert'client/geoff'
 client←ReadCert'client/client'
 ca←ReadCert'ca/ca'
 server←ReadCert'server/server'

 hellebak←ReadCert'client/hellebak'
 bhcbak←ReadCert'client/bhcbak'
 bhcbakc←ReadCert'client/bhcbakc'



     ⍝ ifcs←#.DRC.X509Cert.ReadCertFromFolder certpath,'client/*-cert.pem'

 iscs←#.DRC.X509Cert.ReadCertFromStore'My'
 :If 0<⍴iscs
     ↑iscs.Formatted.Subject
 :EndIf
     ⍝'My Store certificates'DisplayCert 0 iscs
