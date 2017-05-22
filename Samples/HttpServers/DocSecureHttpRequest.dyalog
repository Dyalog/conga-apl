:Class DocSecureHttpRequest : HttpServerBase

    NL←⎕UCS 13 10

    ∇ MakeN arg;err
      :Access Public
      :Implements Constructor :Base arg
     

      (err Certs)←srv.DRC.GetProp Name'PeerCert'
      :If err=0
      :AndIf 9=⎕NC'Certs'
          Certs.Chain.Formatted.(Issuer Subject)
      :EndIf
      TestCertificates←(2 ⎕NQ '.' 'GetEnvironment' 'Dyalog'),'/Testcertificates/'

    ∇

    ∇ sa←ServerArgs
      :Access public shared
      sa←('mode' 'Http')('BufferSize' 1000000)
      sa,←⊂('PublicCertFile'('DER' (TestCertificates,'server/localhost-cert.pem')))
      sa,←⊂('PrivateKeyFile'('DER' (TestCertificates,'server/localhost-key.pem')))
      sa,←⊂('SSLValidation'(64+128))
         ⍝ sa,←⊂ ('Priority' 'SECURE128:+SECURE192:-VERS-ALL:+VERS-TLS1.1')
    ∇

    ∇ sp←srv ServerProperties name
      :Access Public shared
         ⍝ Return the Properties to set for the server or
         ⍝ use the srv ref to access srv and srv.DRC and do it yourself
      _←srv.DRC.GetProp'.' 'RootCertDir' 'C:\apps\dyalog150U64\TestCertificates\ca\'
      _←srv.DRC.SetProp'.' 'TraceGNUTls' 99
      _←srv.DRC.SetProp'.' 'Trace'(1024+8)
     
      sp←⍬
    ∇


    ∇ r←DecodeCert c
      asText←{'UTF-8'⎕UCS ⎕UCS ⍵}
      split←{(⍴,⍺)↓¨(⍺⍷⍺,⍵)⊂⍺,⍵}
      toMat←{↑'='split¨','split ⍵}
      r←toMat¨asText¨↑c.Formatted.(Subject Issuer)
    ∇

    ∇ onHtmlReq;html;headers;hdr;e
      :Access public override
      ...
      html←'<!DOCTYPE html><html><head><title>Page Title</title></head><body><h1>Requesting: ',Page,'</h1><p>',(Table Headers),'</p>',(Table↑Certs.Chain.Formatted.(Issuer Subject)),'</body></html>'
      headers←0 2⍴⍬
      headers⍪←'Server' 'ClassyDyalog'
      headers⍪←'Content-Type' 'text/html'
      hdr←(-⍴NL)↓⊃,/{⍺,': ',⍵,NL}/headers
      e←SendAnswer 0 hdr html
    ∇

    ∇ r←{options}Table data;NL
     ⍝ Format an HTML Table
     
      NL←⎕AV[4 3]
      :If 0=⎕NC'options' ⋄ options←'' ⋄ :EndIf
     
      r←,∘⍕¨data                     ⍝ make strings
      r←,/(⊂'<td>'),¨r,¨⊂'</td>'     ⍝ enclose cells to make rows
      r←⊃,/(⊂'<tr>'),¨r,¨⊂'</tr>',NL ⍝ enclose table rows
      r←'<table ',options,'>',r,'</table>'
    ∇


:endclass
