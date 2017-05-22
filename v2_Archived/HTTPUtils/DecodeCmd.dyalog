 HTTPCmd←DecodeCmd req;split;buf;input;args;z
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
