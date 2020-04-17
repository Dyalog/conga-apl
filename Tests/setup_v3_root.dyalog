 r←setup_v3_root dummy
⍝ Setup test using v3 DRC
⍝ Set #.CONGALIB to point to non-default Conga DLLs
 :If 0=⎕NC'#.Conga'
     ⍝→0⊣r←'#.Conga not present.'
     #.⎕CY'conga'
     Conga←#.Conga
 :Else
     Conga←#.Conga
 :EndIf
 InitCongaLog

 :Trap 0
     iConga←('CONGALIB'{0=#.⎕NC ⍺:⍵ ⋄ ⍎'#.',⍺}'')Conga.Init'TEST'
 :Else
     →0⊣r←'Conga.Init failed: ',⊃⎕DMX.DM
 :EndTrap

 r←verify_empty iConga
