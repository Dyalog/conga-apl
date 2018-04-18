:namespace CongaQA

   ∇ root←defRoot
     ⍝ Root of application is filepath of workspace or .dyapp file
     ⍝ (Might differ from root during assembly of a saved ws.)
     ⍝ eg (1) loading from SALT and (2) running a saved ws
     ⍝ We keep the value in a global, this allows us to )SAVE the ws and continue running
      :If 2=#.⎕NC'ROOT' ⋄ root←#.ROOT
      :Else
          root←#.ROOT←{⍵↓⍨1-'\'⍳⍨⌽⍵}⎕WSID{⍺≢'CLEAR WS':⍺ ⋄ ⍵}2 ⎕NQ'.'  'GetEnvironment' 'dyapp'
      :EndIf
    ∇




∇r←QA 

 path←defRoot
'test'⎕NS''
test ⎕SE.UCMD'dbuild ',path,'/conga-apl'
test ⎕SE.UCMD'zz←dtest ',path,'/tests/all -verbose -filter=test_core' 
zz
⎕EX'test'
∇            

:endnamespace

⍝)(!QA!bhc!2018 4 18 8 34 14 0!0
⍝)(!defRoot!bhc!2018 4 18 8 36 12 0!0
