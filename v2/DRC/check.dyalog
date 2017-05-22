 check←{
     0≠⊃⍵:('DLL Error: ',Error⊃⍵)⎕SIGNAL 999
     0≠⊃2⊃⍵:(Error⊃2⊃⍵),1↓2⊃⍵
     2=⍴⍵:(⎕IO+1)⊃⍵
     1↓⍵}
