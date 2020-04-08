 r←setup_v3 dummy
⍝ Setup test using v3 DRC
⍝ Set #.CONGALIB to point to non-default Conga DLLs

 :If 0=⎕NC'#.Conga'
     ⍝→0⊣r←'#.Conga not present.'
     #.⎕cy'Conga'
     Conga←#.Conga
 :Else
     Conga←#.Conga
 :EndIf
 :If 0=⎕NC'verify_empty'  ⍝ when running individual tests, make sure this fn is around!
     ⎕FIX'file://',##.TESTSOURCE,'verify_empty.dyalog'
 :EndIf
 :Trap 0
     iConga←('CONGALIB'{0=#.⎕NC ⍺:⍵ ⋄ ⍎'#.',⍺}'')Conga.Init''
 :Else
     →0⊣r←'Conga.Init failed: ',⊃⎕DMX.DM
 :EndTrap

 :If 0=⎕NC'verify_empty'⋄     ⎕SE.UCMD'nul←load ',##.TESTSOURCE,'\verify_empty.dyalog'⋄ :EndIf
 :if 0=⎕nc'ErrorCleanup'⋄⎕SE.UCMD'nul←load ',##.TESTSOURCE,'\ErrorCleanup.dyalog'⋄:endif
 r←verify_empty iConga
