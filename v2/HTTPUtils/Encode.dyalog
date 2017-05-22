 code←Encode strg;raw;rows;cols;mat;alph
     ⍝ Base64 Encode
 raw←⊃,/11∘⎕DR¨strg
 cols←6
 rows←⌈(⊃⍴raw)÷cols
 mat←rows cols⍴(rows×cols)↑raw
 alph←'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
 alph,←'abcdefghijklmnopqrstuvwxyz'
 alph,←'0123456789+/'
 code←alph[⎕IO+2⊥⍉mat],(4|-rows)⍴'='
