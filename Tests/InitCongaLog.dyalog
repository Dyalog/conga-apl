 InitCongaLog
 :If ⎕NEXISTS'conga.log'         ⍝ if conga.log exists
 :AndIf 0<2 ⎕NINFO'conga.log'    ⍝ and has content
     {}'conga.log'{⎕nuntie t⊣⍵⎕NRENAME t←⍺⎕ntie 0}'conga.bak',(⍕1+≢⊃0(⎕NINFO⍠'Wildcard' 1)'conga.*.log'),'.log'  ⍝ rename it...
 :EndIf
 ''⎕NPUT'conga.log' 1   ⍝ make sure we have an empty conga.log
