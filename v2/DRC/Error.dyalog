 r←Error no;i
      ⍝ Return error text
 :If 0=⊃r←GetProp'.' 'ErrorText'no
 :AndIf no=2 1⊃r
     r←2⊃r
 :Else
     r←no'? Unknown Error' ''
 :EndIf
