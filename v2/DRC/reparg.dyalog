 r←reparg a;arglist;ix;cert
 arglist←'Name' 'Address' 'Port' 'Mode' 'BufferSize' 'SSLValidation' 'EOM' 'IgnoreCase' 'Protocol' 'PublicCertData' 'PrivateKeyFile' 'PrivateKeyPass' 'PublicCertFile' 'PublicCertPass' 'PrivateKeyData' 'X509'
 ix←a getargix('X509' 'PublicCertData' 'PrivateKeyFile' 'PrivateKeyPass' 'PublicCertFile' 'PublicCertPass' 'PrivateKeyData')(arglist)
 :If (⍴a)≥|⊃ix
     cert←a getarg⊃ix

     :If 9=⎕NC'cert'
          ⍝:AndIf 0<cert.IsCert   ⍝Accept empty certificates.
         a←(~(⍳⍴a)∊|ix)/a
         a,←cert.AsArg
     :EndIf
 :EndIf
 r←a
