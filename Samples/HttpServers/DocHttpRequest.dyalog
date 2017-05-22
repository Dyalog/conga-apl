:Class DocHttpRequest: HttpServerBase

    NL←⎕UCS 13 10
    ∇ MakeN arg
      :Access Public
      :Implements Constructor :Base arg
    ∇

    ∇ onHtmlReq;html;headers;hdr;e
      :Access public override
      html←'<!DOCTYPE html><html><head><title>Page Title</title></head><body><h1>Requesting: ',Page,'</h1><p>',(Table Headers),'</p></body></html>'
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
