:Class HttpServerStatic : HttpServerBase
⍝ An example of an Http Server capable of servicing requests for files

     FOLDER←'/root/folder/' ⍝ /// Should be a constructor argument

        NL←⎕UCS 13 10   
        dtb←{                                           ⍝ Drop Trailing Blanks.
     ⍺←' ' ⋄ 1<|≡⍵:(⊂⍺)∇¨⍵                       ⍝ nested?
     2<⍴⍴⍵:(¯1↓⍴⍵){(⍺,1↓⍴⍵)⍴⍵}⍺ ∇,[¯1↓⍳⍴⍴⍵]⍵     ⍝ array
     1≥⍴⍴⍵:(-+/∧\⌽⍵∊⍺)↓⍵                         ⍝ vector
     (~⌽∧\⌽∧⌿⍵∊⍺)/⍵                              ⍝ matrix
 }

        ∇ct←ContentType page;ext;list
          list ← 2 2 ⍴'pdf' 'application/pdf' 'txt' 'text/html'
         
          ext← dtb  {(1-(⌽⍵)⍳'.')↑⍵ }page 
          
        ct←⊃(list[;2],⊂'text/html')[    list[;1]⍳⊂ext]
        ∇

        ∇ MakeN arg
          :Access Public
          :Implements Constructor :Base arg
        ∇
    
        ∇ onHtmlReq;html;headers;hd;e
          :Access public override 
          headers← 0 2 ⍴⍬
          headers⍪←'Server' 'ClassyDyalog'
          headers⍪←'Content-Type' (ContentType Page)
          hdr←(-⍴NL)↓⊃,/{⍺,': ',⍵,NL}/headers
          e←SendFile 0 hdr (FOLDER,Page)
          :if 1039=⊃e
               SendAnswer '404 Not Found' hdr ''
          :endif
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
   
