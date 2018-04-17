 r←{cnt}SendReceive(con data);ret;out;mask;err;obj;evt;dat;tim
 ⍎(0=⎕NC'cnt')/'cnt←1'
 r←0
⍝ send
 ret←iConga.Send¨(cnt/⊂con){⍺ ⍵}¨⊂data
 out←+/mask←0=1⊃¨ret
 :If ~∧/mask
     ⎕←↑(~mask)/ret
 :EndIf

 :While out>0
     (err obj evt dat tim)←5↑ret←iConga.Waitt con 20000
     :If err≠0
⍝   :orif 0 'Timeout' ≡ err evt
         :Leave
     :EndIf
     :If 0 'Timeout'≢err evt
         r+←dat≡⌽data
         out-←1
     :EndIf
 :EndWhile
