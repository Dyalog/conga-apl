 ErrorCleanup;ret
⍝ Flush all Conga Activity.
 :While 0<⍴iConga.Names'.'
     {}iConga.(Close¨Names'.')
     :If ~∨/0 100∊⊃ret←iConga.Wait'.' 2000
         'ErrorCleanup'Log'Wait failed: ',,⍕ret
         :Leave
     :EndIf
     'ErrorCleanup'Log'Cleanup'
 :EndWhile
