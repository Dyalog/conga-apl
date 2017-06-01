 r←blksize BlockSize(Host Port srv hh hb);c;n;r2;mask;clt;maxwait;probe;data;ret;res;names;match
⍝ Test different block sizes in the http protocol
 clt←'C1'
 maxwait←5000
 probe←'Request'
 data←hh,hb,hh,hb
 :If (1009 'ERR_NAME_IN_USE')≡2↑ret←iConga.Clt clt Host Port'http'blksize
     'BlockSize'Log'Client still there delay and retry'
     ⎕DL 1
     ret←iConga.Clt clt Host Port'http'blksize
 :EndIf
 :If (0 clt)Check ret
     →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Send clt probe
     →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
     →fail Because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf

 :If (0 'Block'probe)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Send(2⊃res)(data)1
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf


 :If blksize<⍴hh
      ⍝ Block size too small
     :If (0 clt'Error' 1135)Check(⊂1 2 3 4)⌷4↑res←iConga.Wait clt maxwait
         →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
 :Else
      ⍝ only expect the body if there is a content length in the header and body have a size
     mask←4⍴1((∨/'Content-Length'⍷hh)∧0<⊃⍴hb)
     :For n :In ⍳100
         ⎕DL 0.005
         names←iConga.Names clt
         match←0
         :If (+/mask)=⍴names
             :If 1 Check match←(mask/'HTTPHeader' 'HTTPBody' 'HTTPHeader' 'HTTPBody')≡{(¯1+⍵⍳'0')↑⍵}¨names
                 →fail Because'Received blocks does not match expected' ⋄ :EndIf
             :Leave
         :EndIf
     :EndFor

     :If (0 clt'HTTPHeader'hh)Check 4↑res←iConga.Wait clt maxwait
         →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

     :If 0<⍴hb
         :If (0 clt'HTTPBody'hb)Check 4↑res←iConga.Wait clt maxwait
             →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
     :EndIf

     :If (0 clt'HTTPHeader'hh)Check 4↑res←iConga.Wait clt maxwait
         →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

     :If 0<⍴hb
         :If (0 clt'HTTPBody'hb)Check 4↑res←iConga.Wait clt maxwait
             →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
     :EndIf

     :If (0 clt'Error' 1119)Check 4↑res←iConga.Wait clt maxwait
         →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
 :EndIf

 r←''
 →0
fail:
 r←r,' with blocksize = ',(⍕blksize),' header size = ',(⍕⍴hh),' body size = ',⍕⍴hb
 z←iConga.Close clt
