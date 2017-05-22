 TestSimpleServices host;fmt
     ⍝ Test some common simple TCP Services

 host←host,(0=⍴host)/'localhost'
 fmt←{0=1⊃⍵:(2⊃⍵)~⎕AV[4] ⋄ ⍵} ⍝ Format result of GetSocket

 'daytime (port 13): ' ⋄ fmt GetSimpleServiceData host 13
 'quote of the day (port 17):' ⋄ fmt GetSimpleServiceData host 17
