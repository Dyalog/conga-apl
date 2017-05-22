:Namespace HTTPUtils 
⍝ *** WARNING ***
⍝ This namespace is provided for backwards compatibility with pre-v3 CONGA / pre-v16 Dyalog APL
⍝      HTTPUtils is used by some methods in Samples, such as HttpGet
⍝      Dyalog recommends switching to new tools provided in apllib/HttpCommand 
⍝      The Samples & HTTPUtils namespaces will eventually be removed from the CONGA workspace

⍝ === VARIABLES ===

    ⎕IO←⎕ML←1
    NL←(⎕ucs 13 10)

    ∇ HTTPCmd←DecodeCmd req;split;buf;input;args;z
     ⍝ Decode an HTTP command line: get /page&arg1=x&arg2=y
     ⍝ Return namespace containing:
     ⍝ Command: HTTP Command ('get' or 'post')
     ⍝ Headers: HTTP Headers as 2 column matrix or name/value pairs
     ⍝ Page:    Requested page
     ⍝ Arguments: Arguments to the command (cmd?arg1=value1&arg2=value2) as 2 column matrix of name/value pairs
     
      input←1⊃,req←2⊃##.HTTPUtils.DecodeHeader req
      'HTTPCmd'⎕NS'' ⍝ Make empty namespace
      HTTPCmd.Input←input
      HTTPCmd.Headers←{(0≠⊃∘⍴¨⍵[;1])⌿⍵}1 0↓req
     
      split←{p←(⍺⍷⍵)⍳1 ⋄ ((p-1)↑⍵)(p↓⍵)} ⍝ Split ⍵ on first occurrence of ⍺
     
      HTTPCmd.Command buf←' 'split input
      buf z←'http/'split buf
      HTTPCmd.Page args←'?'split buf
     
      HTTPCmd.Arguments←(args∨.≠' ')⌿↑'='∘split¨{1↓¨(⍵='&')⊂⍵}'&',args ⍝ Cut on '&'
    ∇

    ∇ r←DecodeHeader buf;len;d;dlb;i
⍝ Decode HTML Header
      r←0(0 2⍴⊂'')
      dlb←{(+/∧\' '=⍵)↓⍵} ⍝ delete leading blanks
      :If 0<i←⊃{((NL,NL)⍷⍵)/⍳⍴⍵}buf
          len←(¯1+⍴NL,NL)+i
          d←(⍴NL)↓¨{(NL⍷⍵)⊂⍵}NL,len↑buf
          d←↑{((p-1)↑⍵)((p←⍵⍳':')↓⍵)}¨d
          d[;1]←lc¨d[;1]
          d[;2]←dlb¨d[;2]
          r←len d
      :EndIf
    ∇

    ∇ code←Encode strg;raw;rows;cols;mat;alph
     ⍝ Base64 Encode
      raw←⊃,/11∘⎕DR¨strg
      cols←6
      rows←⌈(⊃⍴raw)÷cols
      mat←rows cols⍴(rows×cols)↑raw
      alph←'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      alph,←'abcdefghijklmnopqrstuvwxyz'
      alph,←'0123456789+/'
      code←alph[⎕IO+2⊥⍉mat],(4|-rows)⍴'='
    ∇

    ∇ r←header GetValue(name type);i;h
     ⍝ Extract value from HTTP Header structure returned by DecodeHeader
     
      :If (1↑⍴header)<i←header[;1]⍳⊂lc name
          r←⍬ ⍝ Not found
      :Else
          r←⊃header[i;2]
          :If 'Numeric'≡type
              r←1⊃2⊃⎕VFI r
          :EndIf
      :EndIf
    ∇

    ∇ r←port HostPort host;z
     ⍝ Split host from port
     
      :If (⍴host)≥z←host⍳':'
          port←1⊃2⊃⎕VFI z↓host ⋄ host←(z-1)↑host  ⍝ Use :port if found in host name
      :EndIf
     
      r←host port
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

    ∇ r←lc x;t
      t←⎕AV ⋄ t[⎕AV⍳⎕A]←'abcdefghijklmnopqrstuvwxyz'
      r←t[⎕AV⍳x]
    ∇

    ∇ r←URLEncode data;⎕IO;z;ok;nul;m;enlist
      nul←⎕UCS ⎕IO←0
      enlist←{⎕ML←3 ⋄ ∊⍵}
      ok←nul,enlist ⎕UCS¨(⎕UCS'aA0')+⍳¨26 26 10
     
      z←⎕UCS'UTF-8'⎕UCS enlist nul,¨,data
      :If ∨/m←~z∊ok
          (m/z)←↓'%',(⎕D,⎕A)[⍉16 16⊤⎕UCS m/z]
          data←(⍴data)⍴1↓¨{(⍵=nul)⊂⍵}enlist z
      :EndIf
     
      r←¯1↓enlist data,¨(⍴data)⍴'=&'
    ∇


:EndNamespace 
