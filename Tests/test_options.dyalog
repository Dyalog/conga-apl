 r←test_options dummy;WSAutoUpgrade;RawAsByte;DecodeHttp;RawAsInt;ops;modes;m;o;Port;Srv;Clt;Host;ret;exp;err;srv;r2
⍝∇Test: group=Basic
⍝ Test fundamental Conga functionality

 Port←5000 ⋄ Host←'localhost'
 Srv←'' ⋄ Clt←''

 WSAutoUpgrade←1
 RawAsByte←2
 DecodeHttp←4
 ops←WSAutoUpgrade RawAsByte DecodeHttp

 modes←'Raw' 'Text' 'BlkRaw' 'BlkText' 'http' 'Command'

 :If 0 Check⊃ret←iConga.Srv Srv''Port'raw'
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret


 :For m :In modes
     :For o :In {⍵+.×((≢⍵)/2)⊤¯1+⍳(≢⍵)*2}ops
         applicable←(o=0)∨((m≡'http')∧~⊃2 2⊤o)∨(o=2)∧(⊂m)∊'Raw' 'BlkRaw'  ⍝ can this option be set for current mode? (assuming 2 needs [Blk]Raw and everything else http)
         ret←iConga.Clt'' '' 5000 m('Options'o)
         err←1⊃ret
         :If err=0
             r2←iConga.GetProp(2⊃ret)'Options'
             :If o Check(2⊃r2)
                 →fail Because'GetProp Options did not return ',(⍕o),' (which was set before): ',,⍕r2 ⋄ :EndIf
             _←iConga.Close 2⊃ret
         :EndIf
         :If ~∨/0 1037∊err ⋄ →fail Because'Clt Failed: ',,⍕ret ⋄ :EndIf
         exp←1037×~applicable

         :If exp Check err
             →fail Because'Clt did (not) error as expected in mode ',m,' when attempting to set Options=',(⍕o),': expected result=',(⍕exp),', got ',(,⍕err) ⋄ :EndIf

     :EndFor ⍝ o
 :EndFor ⍝ m

 _←iConga.Close srv
 {}iConga.Wait'.' 0

 r←''
 →0

fail:
 r←'Mode="',m,'", Option=',(⍕o),': ',r
 z←iConga.Close srv
 {}iConga.Wait'.' 0
