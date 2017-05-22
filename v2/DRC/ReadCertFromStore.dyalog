 certs←ReadCertFromStore storename;cs
 :Access Public Instance

 cs←Certs'MSStore'storename
 :If 0=1⊃cs
 :AndIf 0<⍴2⊃cs
     certs←⎕NEW¨(2⊃cs){X509Cert(⍺ ⍵)}¨⊂'MSStore'storename
 :Else
     certs←⍬
 :EndIf
