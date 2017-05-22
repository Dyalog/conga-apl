 r←GetProp a
      ⍝ Name Prop
      ⍝ Root: DefaultProtocol  PropList  ReadyStrategy  RootCertDir
      ⍝ Server: OwnCert  LocalAddr  PropList
      ⍝ Connection: OwnCert  PeerCert  LocalAddr  PeerAddr  PropList

 r←check ⍙CallR RootName'AGetProp'a 0

 :If 0=⊃r
 :AndIf ∨/'OwnCert' 'PeerCert'∊a[2]
 :AndIf 0<⊃⍴2⊃r
     (2⊃r)←SetParents ##.⎕NEW¨X509Cert,∘⊂¨2⊃r
 :EndIf
