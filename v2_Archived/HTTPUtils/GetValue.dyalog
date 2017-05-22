 r←header GetValue(name type);i;h
     ⍝ Extract value from HTTP Header structure returned by DecodeHeader

 :If (1↑⍴header)<i←header[;1]⍳⊂lc name
     r←⍬ ⍝ Not found
 :Else
     r←⊃header[i;2]
     :If 'Numeric'≡type
         r←1⊃2⊃⎕VFI r
     :EndIf
 :EndIf
