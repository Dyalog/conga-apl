 check←{
     0≠⊃⍵:('DLL Error: ',,⍕⍵)⎕SIGNAL 999  ⍝ return code from Call non zero
     3≠10|⎕DR⊃2⊃⍵:('DLL result Error: ',,⍕⍵)⎕SIGNAL 999  ⍝ first element of Z is not numeric we expect errorcode
     0≠⊃2⊃⍵:(Error⊃2⊃⍵),1↓2⊃⍵             ⍝ first element of Z is non zero, Error
     2=⍴⍵:(⎕IO+1)⊃⍵
     1↓⍵}
