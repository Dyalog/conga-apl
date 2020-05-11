 r←test_options dummy;WSAutoUpgrade;RawAsByte;DecodeHttp;RawAsInt;ops;modes;m;o;Port;Srv;Clt;Host;ret;exp;err;srv;r2;clt;o∆;applicable;o∆
⍝∇Test: group=Basic
⍝ Test fundamental Conga functionality

 Port←5000 ⋄ Host←'localhost'
 Srv←'' ⋄ Clt←''

 WSAutoUpgrade←1
 RawAsByte←2
 DecodeHttp←4
 ops←WSAutoUpgrade RawAsByte DecodeHttp
 m←o←'(undefined)'
 modes←'Raw' 'Text' 'BlkRaw' 'BlkText' 'http' 'Command'

 :If 0 Check⊃ret←iConga.Srv Srv''Port'raw'
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret


 :For m :In modes
     :For o :In {⍵+.×((≢⍵)/2)⊤¯1+⍳(≢⍵)*2}ops
         o∆←o
         :If o>0
         :AndIf o Check⍎ret←iConga.DecodeOptions o
             →fail Because'DecodeOptions ',(⍕o),' returned ',ret,' which was evaluated as ',⍕⍎ret ⋄ :EndIf
         applicable←(o=0)∨((m≡'http')∧~⊃2 2⊤o)∨(o=2)∧(⊂m)∊'Raw' 'BlkRaw' ⍝ can this option be set for current mode? (assuming 2 needs [Blk]Raw (or http! *undocumented*) and everything else http)
         ⍝applicable←(o=0)∨()∧((⊂m)∊'Raw' 'BlkRaw' 'http') ⍝ can this option be set for current mode? (assuming 2 needs [Blk]Raw (or http! *undocumented*) and everything else http)
         ⍝applicable←(o=0)∨((o=2)∧((⊂m)∊'Raw' 'BlkRaw'))∨m≡'http' ⍝ can this option be set for current mode? (assuming 2 needs [Blk]Raw (or http! *undocumented*) and everything else http)
         ret←iConga.Clt'' '' 5000 m('Options'o)
         err←1⊃ret
         :If ~∨/0 1037∊err ⋄ →fail Because'Clt Failed with unexpected return-code: ',,⍕ret ⋄ :EndIf
         :If err=0
             clt←2⊃ret

             r2←iConga.GetProp(2⊃ret)'Options'
             :If o Check(2⊃r2)
                 →fail Because'GetProp Options did not return ',(⍕o),' (which was set before): ',,⍕r2 ⋄ :EndIf
             o∆←o ⍝ remember original o before messing with it ("o" is shown in err-msg..)
             :If 1084 Check⊃ret←iConga.SetProp clt'Options'(o←+0.001)
                 →fail Because'SetProp''Options'' did not err when called with floating point number' ⋄ :EndIf

             :If 1084 Check⊃ret←iConga.SetProp clt'Options'(o←'RawAsByte')
                 →fail Because'SetProp''Options'' did not err when called with string argument' ⋄ :EndIf
             o←o∆
             :If o>0
             :AndIf 1037 Check⊃ret←iConga.SetProp clt'Options'(o←-o∆)   ⍝ Mantis 18034
                 →fail Because'It was possible to SetProp"Options" with negative o, ret=',(⍕ret),'⍝  m18034' ⋄ :EndIf
             _←iConga.Close 2⊃ret
         :EndIf
         exp←1037×~applicable
         o←o∆   ⍝ reset to initial value
         :If exp Check err
             →fail Because'Clt did ',((err>0)/' not '),' error as expected in mode ',m,' when attempting to set Options=',(⍕|o),': expected result=',(⍕exp),', got ',(,⍕err) ⋄ :EndIf

         :If err=0
         :AndIf o>0
         :AndIf 1037 Check⊃ret←iConga.Clt'' '' 5000 m('Options'(-o))  ⍝ Mantis 18034
             →fail Because'Clt did not refuse to create client with negative value in options and returned ',(⍕ret),' ⍝18034' ⋄ :EndIf

         _←iConga.Close clt
     :EndFor ⍝ o

 :EndFor ⍝ m

 _←iConga.Close srv
 _←iConga.Wait'.' 0

 r←''
 →0

fail:
 r←'Mode="',m,'", Option=',(⍕o),': ',r
 ErrorCleanup
