 v←Version;version

 :Trap 0
     version←{no←(¯1+(⍵∊⎕D)⍳1)↓⍵ ⋄ 3↑⊃¨2⊃¨⎕VFI¨'.'{1↓¨(⍺=⍵)⊂⍵}'.',no}
     v←version 2 1 4⊃Tree'.'
 :Else
     'Try DRC.Init '⎕SIGNAL 16
     v←0 0 0
 :EndTrap
