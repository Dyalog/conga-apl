﻿ r←ServerAuth con;tok;rr;kp;err;rc;ct;ck;ce
 err←SetProp con'IWA'('NTLM' '')
 ck←kp←1
 :Repeat
     rr←Wait con 1000
     :If 0=⊃rr
         (ce ck ct)←3↑4⊃rr
         :If 0<⍴ct
         :AndIf ce=0
             err←SetProp con'Token'(ct)
             kp tok←2⊃GetProp con'Token'
             rc←Respond(2⊃rr)(err kp tok)
         :Else
             rc←Respond(2⊃rr)(0 0 ⍬)
             kp←0
         :EndIf
     :Else
         kp←1
     :EndIf
 :Until (0=kp)∨(ck=0)
 r←GetProp con'IWA'
