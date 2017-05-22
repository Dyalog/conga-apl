 r←{options}Table data;NL
     ⍝ Format an HTML Table

 NL←⎕AV[4 3]
 :If 0=⎕NC'options' ⋄ options←'' ⋄ :EndIf

 r←,∘⍕¨data                     ⍝ make strings
 r←,/(⊂'<td>'),¨r,¨⊂'</td>'     ⍝ enclose cells to make rows
 r←⊃,/(⊂'<tr>'),¨r,¨⊂'</tr>',NL ⍝ enclose table rows
 r←'<table ',options,'>',r,'</table>'
