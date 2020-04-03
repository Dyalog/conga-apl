 r←test_options dummy;WSAutoUpgrade;RawAsByte;DecodeHttp;RawAsInt;ops;modes;m;o;Port;Srv;Clt;Host;ret;exp;err;srv;r2
⍝∇Test: group=Basic
⍝ Test fundamental Conga functionality

 Port←5000 ⋄ Host←'localhost'
 Srv←'' ⋄ Clt←''

 WSAutoUpgrade←1
 RawAsByte←2
 DecodeHttp←4
 RawAsInt←8
 ops←WSAutoUpgrade RawAsByte DecodeHttp RawAsInt

 modes←'Raw' 'Text' 'BlkRaw' 'BlkText' 'http' 'Command'

 :If 0 Check⊃ret←iConga.Srv Srv''Port'raw'
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret


 :For m :In modes
     :For o :In {⍵+.×((≢⍵)/2)⊤¯1+⍳(≢⍵)*2}ops
         ret←iConga.Clt'' '' 5000 m('Options'o)
         err←1⊃ret
         :If err=0
             r2←iConga.GetProp(2⊃ret)'Options'
             :If o Check r2
                 →fail Because'GetProp Options failed: ',,⍕r2 ⋄ :EndIf
             _←iConga.Close 2⊃ret
         :EndIf
         :If ~∨/0 1037∊err
             -fail Because'Clt Failed: ',,⍕ret ⋄ :EndIf
         exp←1037
         :If (m≡'Command')∧(o=0)
             exp←0 ⋄ :EndIf
         :If (m≡'http')∧(o<16)
             exp←0 ⋄ :EndIf

         :If (∨/'Raw' 'Text' 'BlkRaw' 'BlkText'∊⊂m)∧((o=0)∨(o=RawAsByte))
             exp←0 ⋄ :EndIf
         :If exp Check err
             →fail Because'Clt Failed: ',,⍕ret ⋄ :EndIf

     :EndFor ⍝ o
 :EndFor ⍝ m

 _←iConga.Close srv

 r←''
 →0

fail:
 r←'Mode="',m,'", Option=',(⍕o),': ',r
 z←iConga.Close srv
 {}iConga.Wait'.' 0
