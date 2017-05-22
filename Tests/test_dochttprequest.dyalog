 r←test_dochttprequest dummy;srv;z;ret;find;table;data
⍝∇Test: group=Classy
⍝ Test Class-based servers

 r←''

 :Trap 0
     srv←Conga.Srv 8088 #.HttpServers.DocHttpRequest
     srv.Start
 :Else
     →fail because'Unable to start server: ',⊃⎕DMX.DM
 :EndTrap

 :If 0≠⊃ret←#.Samples.HTTPGet'http://localhost:8088/index.html'
     →fail⊣r←'HTTPGet failed: ',,⍕ret ⋄ :EndIf

 find←{¯1+(⍺⍷⍵)⍳1}
 table←⎕XML{('<table'find ⍵)↓('</p>'find ⍵)↑⍵}3⊃ret
 data←{(⍵[;2]∊⊂'td')/⍵[;3]}table

 :If 6≠≢data
     →fail⊣r←'Returned table has unexpected format.' ⋄ :EndIf

fail:

 :If 9=⎕NC'srv'
     srv.Stop
 :EndIf
