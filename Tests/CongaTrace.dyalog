 r←CongaTrace arg;LDRC;level;delay;nopen;fopen;loginfo;congatrace;gnutlstrace
 :Trap 0
     (congatrace gnutlstrace)←2↑arg
     nopen←{                              ⍝ handle on null file.
         0::⎕SIGNAL ⎕EN                  ⍝ signal error to caller.
         22::⍵ ⎕NCREATE 0                ⍝ ~exists: create.
         ⍵ ⎕NTIE 0                      ⍝  exists: tie.
     }
     r←0
⍝ make sure the conga.log file exists, so that conga.so will write to it.
     ⎕NUNTIE nopen'conga.log'

     :If ∨/congatrace gnutlstrace>0   ⍝ Switch trace on
         iConga.SetProp'.' 'Invalidatecache' 100
         :If 0<congatrace
             r←⊃iConga.SetProp'.' 'trace'(congatrace)
         :EndIf

         :If 0<gnutlstrace
             r←⊃iConga.SetProp'.' 'tracegnutls'gnutlstrace
         :EndIf


     :Else   ⍝ Switch trace off
         r←⊃iConga.SetProp'.' 'trace' 0
         r←⊃iConga.SetProp'.' 'tracegnutls' 0
     :EndIf

 :Else
     ⎕←'***ERROR IN Conga Trace ***'
     ⎕←↑⎕DM
     r←⎕EN
 :EndTrap
