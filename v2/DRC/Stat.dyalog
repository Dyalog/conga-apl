 Stat arg;m;NewTS;⎕IO;fopen;loginfo
 :Trap 0
     fopen←{                              ⍝ handle on null file.
         0::⎕SIGNAL ⎕EN                  ⍝ signal error to caller.
         22::⍵ ⎕FCREATE 0                ⍝ ~exists: create.
         ⍵ ⎕FSTIE 0                      ⍝  exists: tie.
     }
     loginfo←{_←(⍙PID ⍙Stat ⎕TS(Micros)(⍙Cnts)(Tree'.'))⎕FAPPEND tie←fopen ⍵ ⋄ ⎕FUNTIE tie}
     ⎕IO←1
     NewTS←⌊Micros÷300000000
      ⍝NewTS←5↑⎕TS
     :If ∨/0=⎕NC'⍙LastTS' '⍙Cnts' '⍙MaxCnts' '⍙Items'
         ⍙Items←'Error' 'Receive' 'Progress' 'Connect' 'Block' 'BlockLast' 'Sent'
         ⍙LastTS←NewTS
         ⍙MaxCnts←⍙Cnts←(2+⍴⍙Items)⍴0
         ⍙PID←GetPid ⍬
         :If 0=⎕NC'⍙Stat'
             ⍙Stat←1
         :EndIf
     :EndIf
     :If ⍙LastTS≡NewTS
         ⍙Cnts[⍙Items⍳(4↑arg)[2]]+←1
         ⍙Cnts[2+⍴⍙Items]+←{⎕SIZE'⍵'}(4↑arg)[4]
     :Else
         loginfo'congastat.dcf'
         ⍙MaxCnts⌈←⍙Cnts
         ⍙LastTS←NewTS
         ⍙Cnts←(2+⍴⍙Items)⍴0

     ⍝ Save
     :EndIf
 :EndTrap
