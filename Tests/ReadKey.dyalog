 k←ReadKey filename;c;tie;size;key;ixs;ix;d;chars
 base64←{⎕IO ⎕ML←0 1             ⍝ Base64 encoding and decoding as used in MIME.

     chars←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
     bits←{,⍉(⍺⍴2)⊤⍵}                   ⍝ encode each element of ⍵ in ⍺ bits,
                                       ⍝   and catenate them all together
     part←{((⍴⍵)⍴⍺↑1)⊂⍵}                ⍝ partition ⍵ into chunks of length ⍺

     0=2|⎕DR ⍵:2∘⊥∘(8∘↑)¨8 part{(-8|⍴⍵)↓⍵}6 bits{(⍵≠64)/⍵}chars⍳⍵
                                       ⍝ decode a string into octets

     four←{                             ⍝ use 4 characters to encode either
         8=⍴⍵:'=='∇ ⍵,0 0 0 0           ⍝   1,
         16=⍴⍵:'='∇ ⍵,0 0               ⍝   2
         chars[2∘⊥¨6 part ⍵],⍺          ⍝   or 3 octets of input
     }
     cats←⊃∘(,/)∘((⊂'')∘,)              ⍝ catenate zero or more strings
     cats''∘four¨24 part 8 bits ⍵
 }
 chars←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

 c←,⊂'-----BEGIN RSA PRIVATE KEY-----'
 tie←filename ⎕NTIE 0
 size←⎕NSIZE tie
 key←⎕NREAD tie 82 size
 ixs←c{⊃,/{(⍳⍴⍵),¨¨⍵}⍺{(⍺⍷⍵)/⍳⍴⍵}¨⊂⍵}key
 :If 0<⍴ixs
     :For ix :In ixs
         d←((2⊃ix)+⍴⊃c[1⊃ix])↓key
         d←(¯1+⊃d⍳'-')↑d
         d←(d∊chars)/d
         k←base64 d
     :EndFor
 :Else
     k←⎕NREAD tie 83 size 0
 :EndIf
 ⎕NUNTIE tie
