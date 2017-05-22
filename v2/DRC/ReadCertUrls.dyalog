 certs←ReadCertUrls;certurls;list
 :Access Public Instance

 certurls←Certs'Urls' ''
 :If 0=1⊃certurls
 :AndIf 0<1⊃⍴2⊃certurls
     certs←{⎕NEW X509Cert((4⊃⍵)('URL'(1⊃⍵))('URL'(2⊃⍵)))}¨↓2⊃certurls
 :Else
     certs←⍬
 :EndIf
