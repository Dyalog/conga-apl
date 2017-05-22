 BuildDRC;Path;Common
 Path←{(1-⌊/'/\'⍳⍨⌽⍵)↓⍵}4↓,¯1↑⎕CR⊃⎕SI
 Common←Path,'Common/'

 '#.DRC' ⎕NS ''
 '#.HTTPUtils' ⎕NS ''
 '#.Samples' ⎕NS ''

 ⎕SE.SALT.Load Path,'v2/DRCFns/*.dyalog -target=#.DRC'
 ⎕SE.SALT.Load Common,'X509Cert.dyalog -target=#.DRC'
 DRC.ErrorTable←⎕CSV (Common,'/ErrorTable.csv') 'UTF-8' (2 1 1)

 ⎕SE.SALT.Load Path,'v2/HTTPUtils/*.dyalog -target=#.HTTPUtils'
 ⎕SE.SALT.Load Path,'v2/Samples/*.dyalog -target=#.Samples'   

 ⎕←'Now please:'            
 ⎕←'      ⎕EX ''BuildDRC'''
 ⎕←'      )WSID ',Path,'..\WSS\DRC.dws'
 ⎕←'      )SAVE'
