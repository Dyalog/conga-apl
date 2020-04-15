 r←setup_v2 dummy;ret
⍝ Setup test using v2 DRC
⍝ Set #.CONGALIB to point to non-default Conga DLLs
 :If 0=⎕NC'#.Conga'
     #.⎕CY'Conga'
     Conga←#.Conga
 :EndIf
 InitCongaLog
 :If 0=⎕NC'#.DRC'
     r←'#.DRC.Init not present.' ⋄ →0 ⋄ :EndIf

 :If 0≠⊃ret←#.DRC.Init'CONGALIB'{0=#.⎕NC ⍺:⍵ ⋄ ⍎'#.',⍺}''
     r←'#.DRC.Init failed: ',⍕ret ⋄ →0 ⋄ :EndIf
 r←verify_empty iConga←#.DRC
