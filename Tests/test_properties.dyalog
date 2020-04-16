 r←test_properties dummy;iConga;Port;Host;Srv;Clt;clv;cv;srv;sc;clt;cc;ret;bhdt
⍝∇Test: group=Basic
⍝ Test fundamental Conga functionality

 Port←5000 ⋄ Host←'localhost'
 r←Srv←Clt←''


 :For clv :In ¯1+⍳10  ⍝ 0..9
     bhdt←0  ⍝ been here, done that => avoid being caught in a loop of problems between teardown and fail below...
     iConga←#.Conga.Init'complevel_test ',⍕clv
     ret←iConga.SetProp'.' 'CompLevel'clv ⍝ set compression level  for root
     :If 0 Check⊃ret
         →fail Because'SetProp returned unexpected result: ',⍕ret ⋄ :EndIf

     cv←iConga.GetProp'.' 'CompLevel'  ⍝ check it...
     :If clv Check 2⊃cv ⋄ →fail Because'Root did not report the compression-level that was set (',(⍕clv),')' ⋄ :EndIf

     srv←iConga.Srv Srv''Port'raw'  ⍝ create a server
     :If 0 Check 1⊃srv ⋄ →fail Because'Could not create server - ret=',⍕srv ⋄ :EndIf

     srv←2⊃srv
     sc←iConga.GetProp srv'complevel'  ⍝ retrieve it (using different casing)
     :If clv Check 2⊃sc ⋄ →fail Because'Server did not inherit CompLevel of root (',(⍕clv),' vs. ',(⍕2⊃sc),')' ⋄ :EndIf

     clt←iConga.Clt'' ''Port'raw'   ⍝ create a clienbt
     :If 0 Check 1⊃clt ⋄ →fail Because'Could not create client  - ret=',⍕clt ⋄ :EndIf
     clt←2⊃clt
     cc←iConga.GetProp clt'complevel'  ⍝ retrieve it (using different casing)
     :If clv Check 2⊃cc ⋄ →fail Because'Client did not inherit CompLevel of root (',(⍕clv),' vs. ',(⍕2⊃cc),')' ⋄ :EndIf
     →teardown
fail:
     r,←', CompLevel=',(⍕clv),' '

teardown:
     :If (2=⎕nc'srv')^(bhdt=0)∧0 Check⊃ret←iConga.Close srv ⋄ bhdt←1 ⋄ →fail Because'Unexpected return value closing server (',(⍕ret),')' ⋄ :EndIf
     :If 2=⎕nc'clt' ⋄ :andif (bhdt≠2)∧0 Check⊃ret←iConga.Close clt ⋄ bhdt←2 ⋄ →fail Because'Unexpected return value closing client (',(⍕ret),')' ⋄ :EndIf
     :If (⊃ret←iConga.Wait'.' 0)IsNotElement 0 100⋄         {}0 Because'Unexpected return value on final Wait (',(⍕ret),')' ⋄ :EndIf
     ⎕EX'iConga'   ⍝ delete root
 :EndFor
