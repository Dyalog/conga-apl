 r←CertPath;droptail;exists;file;ws
     ⍝ Return the path to the certificates

 file←'server/localhost-server-cert.pem' ⍝ Search for this file
 droptail←{(-⌊/(⌽⍵)⍳'\/')↓⍵}
 exists←{0::0 ⋄ 1{⍺}⎕NUNTIE ⍵ ⎕NTIE 0}

 :If exists(r←{⍵,('/'≠¯1↑⍵)/'/'}{(-'\'=¯1↑⍵)↓⍵}TestCertificates),file
 :ElseIf exists(r←'/TestCertificates/',⍨ws←droptail ⎕WSID),file
 :ElseIf exists(r←'/TestCertificates/',⍨ws←droptail ws),file
 :ElseIf exists(r←'/TestCertificates/',⍨ws←droptail+2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'),file
 :ElseIf exists(r←'../TestCertificates/'),file
 :Else
     ('Unable to locate file ',file)⎕SIGNAL 22
 :EndIf
