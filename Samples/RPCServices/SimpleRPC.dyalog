:Class SimpleRPC : #.Conga.Connection

    enc←{(326≠⎕dr ⍵)∧1=≡⍵:,⊂⍵ ⋄ ⍵} ⍝ ravel-enclose-if-simple

    ∇ MakeN arg
      :Access Public
      :Implements Constructor :Base arg
     
      Methods←{⍵,⍪1 2∘⊃¨⎕AT¨⍵} 'Reverse' 'Rotate' ⍝ Callable methods and valences
    ∇

    ∇ onReceive(obj data);cmd;fi;n
      :Access Public Override
     
      data←enc data
          
      :If (⊃⍴Methods)<fi←Methods[;1]⍳⊂cmd←1⊃data ⍝ Command is expected to be a function in this ws
          _←Respond obj(999('Illegal command: ',cmd)) ⋄ :Return
      :EndIf
     
      :If (n←⊃Methods[fi;2])≠¯1+⍴data  ⍝ Number of argument need to match the intance methode
          _←Respond obj(999(cmd, ' expects ',(⍕n), 'arguments')) ⋄ :Return
      :EndIf
     
      :Select ≢data
      :Case 1 ⍝ Niladic:  fn
          _←Respond obj ({0::⎕EN ⎕DM ⋄ 0(⍎⊃⍵)}data)
      :Case 2 ⍝ Mondadic: fn rarg
          _←Respond obj ({0::⎕EN ⎕DM ⋄ 0((⍎1⊃⍵)(2⊃⍵))}data)
      :Case 3 ⍝ Dyadic:   fn larg rarg
          _←Respond obj ({0::⎕EN ⎕DM ⋄ 0((2⊃⍵)(⍎1⊃⍵)(3⊃⍵))}data)
      :Else
          _←Respond obj (999 'Ill-formed RPC call')
      :EndSelect
    ∇
   
   :Section Exposed Functions

    ∇ r←Reverse arg
      :Access Public Instance
      r←⌽arg
    ∇

    ∇ r←left Rotate right
      :Access Public Instance
      r←left⌽right
    ∇

   :EndSection Exposed Functions

:EndClass
