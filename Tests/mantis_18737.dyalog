 r←mantis_18737

 ⍝ not policing blocksize  no big block
 →(0<≢r←mantis_18737_test 0 0 0)/0
 ⍝ not policing blocksize  big body
 →(0<≢r←mantis_18737_test 0 1 0)/0
 ⍝ not policing blocksize  big chunk
 →(0<≢r←mantis_18737_test 0 1 1)/0



 :If 1544<3⊃iConga.Version
     ⍝ Policing blocksize no big blocks
     →(0<≢r←mantis_18737_test 1 0 0 0)/0
     ⍝ Policing blocksize big body
     →(0<≢r←mantis_18737_test 1 1 0 0)/0
    ⍝ Policing blocksize no big chunk
     →(0<≢r←mantis_18737_test 1 0 1 0)/0
     ⍝ Not policing blocksize no big blocks DOSLimit at 20000
     →(0<≢r←mantis_18737_test 0 0 0 1)/0
     ⍝ Not policing blocksize big body DOSLimit at 20000
     →(0<≢r←mantis_18737_test 0 1 0 1)/0
     ⍝ Not policing blocksize big chunk DOSLimit at 20000
     →(0<≢r←mantis_18737_test 0 0 1 1)/0
 :EndIf
