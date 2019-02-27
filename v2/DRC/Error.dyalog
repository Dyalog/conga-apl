 r←Error no;i
      ⍝ Return error text
        :If 0≠⎕NC'ErrorText'
          r←ErrorText no 100 100 256 256
      :Else
          r←no'? Unknown Error' ''
      :EndIf
