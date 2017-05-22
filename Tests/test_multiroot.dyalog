 r←test_multiroot dummy;ret;z;c;iC2;data
⍝∇Test: group=Basic
⍝ Basic test using different roots for Client and Server

 r←''
 →(9.1=⎕NC⊂'iConga')⍴0 ⍝ Bypass this test if iConga is the v2 compatibility NS

 data←'hello'
 :Trap 0
     iC2←#.Conga.Init'R2'
 :Else
     →fail⊣r←'Conga.Init of 2nd root failed: ',⊃⎕DMX.DM
 :EndTrap

 :If 0≠⊃ret←iConga.Srv'S1' '' 5000 'Text'
     →fail⊣r←'Srv failed: ',,⍕ret ⋄ :EndIf
 :If 0≠⊃ret←iC2.Clt'C1' '127.0.0.1' 5000 'Text'
     →fail⊣r←'Clt failed: ',,⍕ret ⋄ :EndIf
 :If (0 'Connect')≢(⊂1 3)⌷ret←iConga.Wait'S1' 10000
     →fail⊣r←'Wait for Connect failed: ',,⍕ret ⋄ :EndIf
 :If 0≠⊃ret←iC2.Send'C1'data
     →fail⊣r←'Sent failed: ',,⍕ret ⋄ :EndIf
 :If (0 'Block')≢(⊂1 3)⌷c←iConga.Wait'S1' 5000
     →fail⊣r←'Wait for Srv.Block/BlockLast failed: ',,⍕c ⋄ :EndIf
 :If 0≠⊃ret←iConga.Send(2⊃c)(⌽4⊃c)
     →fail⊣r←'Respond failed: ',,⍕ret ⋄ :EndIf
 :If (0 'Block')≢(⊂1 3)⌷ret←iC2.Wait'C1' 5000
     →fail⊣r←'Wait for Clt.Block/BlockLast failed: ',,⍕c ⋄ :EndIf
 :If (4⊃ret)≢⌽data
     →fail⊣r←'Data not faithfully returned' ⋄ :EndIf
 :If (,⊂'S1')≢iConga.Names'.'
 :OrIf (,⊂'C1')≢iC2.Names'.'
     →fail⊣r←'Roots did not contain expected names'
 :EndIf

fail:

 :Trap 0
     z←iConga.Close'S1'
     z←iC2.Close'C1'
 :EndTrap
