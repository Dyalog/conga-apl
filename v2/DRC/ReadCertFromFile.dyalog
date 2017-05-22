 certs←ReadCertFromFile filename;c;base64;tie;size;cert;ixs;ix;d;pc;temp

 certs←⍬
 c←'-----BEGIN X509 CERTIFICATE-----' '-----BEGIN CERTIFICATE-----'
 base64←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
 tie←filename ⎕NTIE 0
 size←⎕NSIZE tie
 cert←⎕NREAD tie 82 size
 ixs←c{⊃,/{(⍳⍴⍵),¨¨⍵}⍺{(⍺⍷⍵)/⍳⍴⍵}¨⊂⍵}cert
 :If 0<⍴ixs
     :For ix :In ixs
         d←((2⊃ix)+⍴⊃c[1⊃ix])↓cert
         d←(¯1+⊃d⍳'-')↑d
         d←(d∊base64)/d
         d←base64 Decode d
         certs,←⎕NEW X509Cert(d('DER'filename))
     :EndFor
 :Else
     cert←⎕NREAD tie 83 size 0
     certs,←⎕NEW X509Cert(cert('DER'filename))
 :EndIf

 ⎕NUNTIE tie
 certs←SetParents certs
