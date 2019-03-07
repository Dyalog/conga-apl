 r←racecondition_httpdecode dummy;Port;Host;srv;maxwait;crlf;lf;hex;hr;FmtHeader;SplitInChunks;FmtChunk;size;data;Header;Trailer;chunkext;Chunks;ret;test;sep;header;chunks;trailer;testdata;clt;probe;res;cc;empty
⍝∇Test: group=mantis
⍝ Racecondition when setting decode buffers


 Port←5000 ⋄ Host←'localhost'
 srv←'S1'
 maxwait←5000
 size←10000

 crlf←⎕UCS 13 10
 lf←⎕UCS 10
 empty←0 2⍴''
 hex←{⎕CT ⎕IO←0                          ⍝ Hexadecimal from decimal.
     ⍺←⊢                                 ⍝ no width specification.
     1≠≡,⍵:⍺ ∇¨⍵                         ⍝ simple-array-wise:
     1∊⍵=1+⍵:'Too big'⎕SIGNAL 11         ⍝ loss of precision.
     n←⍬⍴⍺,2*⌈2⍟2⌈16⍟1+⌈/|⍵              ⍝ default width.
     ↓[0]'0123456789abcdef'[(n/16)⊤⍵]    ⍝ character hex numbers.
 }
 hr←{0=≢2⊃⍵:(1⊃⍵),⍺ ⋄ (1⊃⍵),': ',(2⊃⍵),⍺}
 FmtHeader←{0=≢⍵:'' ⋄ (⊃,/(⊂⍺)hr¨↓⍵)}
 SplitInChunks←{s←(⍴⍵)⍴0 ⋄ s[1,⍺?⍴⍵]←1 ⋄ s⊂⍵}
 FmtChunk←{0<⍴⍵:('000',⊃hex⍴⍵),⍺,⍵,⍺ ⋄ '0',⍺}

 data←size⍴⎕A,⎕D

 Header←0 2⍴⍬
 Header⍪←'HTTP/1.1_200 OK' ''
 Header⍪←'Date'(2⊃iConga.GetProp'.' 'HttpDate')
 Header⍪←'Server' 'Apache/2.4.7 (Guanix)'
 Header⍪←'Last-Modified' 'Sat, 07 Mar 2015 16:19:33 GMT'
 Header⍪←'ETag' '"388-510b52a9de2c8"'
 Header⍪←'Accept-Ranges' 'bytes'
 ⍝Header⍪←'Content-Length' '904'
 Header⍪←'Vary' 'Accept-Encoding'
 Header⍪←'Content-Type' 'text/html'
 Header⍪←'Transfer-Encoding' 'chunked'

 Trailer←0 2⍴⍬
 Trailer⍪←'Chunks' 'Apache/2.4.7 (Guanix)'
 Trailer⍪←'OS' 'Guanix'

 chunkext←0 2⍴⍬
 chunkext⍪←'CRC' ''



 Chunks←15 SplitInChunks data

 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 srv)Check ret←iConga.Srv srv''Port'text'(8×size)
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf


 :For test :In (crlf(1 2↑Header)⍬ empty)(crlf Header Chunks Trailer)(crlf Header Chunks(0 2⍴''))(lf Header Chunks Trailer)(lf Header Chunks(0 2⍴''))

     (sep header chunks trailer)←test
     testdata←sep FmtHeader header
     testdata,←sep
     :If 0<≢chunks
         testdata,←⊃,/(⊂sep)FmtChunk¨chunks,⊂''
         :If 0<≢trailer
             testdata,←sep FmtHeader trailer
         :EndIf
         testdata,←sep
     :EndIf

     clt←'C1'
     probe←'Request'

     :If (1009 'ERR_NAME_IN_USE')≡2↑ret←iConga.Clt clt Host Port'http'(4×size)
         'BlockSize'Log'Client still there delay and retry'
         ⎕DL 1
         ret←iConga.Clt clt Host Port'http'(4×size)
     :EndIf
     :If (0 clt)Check ret
         →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf


     :If 0 Check⊃ret←iConga.Send clt probe
         →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf

     :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
         →fail Because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf

     :If (0 'Block'probe)Check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
         →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

     :If 0 Check⊃ret←iConga.Send(2⊃res)(testdata)1
         →fail Because'Send failed: ',,⍕ret ⋄ :EndIf

     :If 0 Check⊃ret←iConga.SetProp clt'DecodeBuffers' 15
         →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

     :If (0 clt'HTTPHeader'((3↑(' '{1↓¨(⍺=⍺,⍵)⊂⍺,⍵}⊃header),3⍴⊂''),⊂(2 0↓header⍪⍨⊂'')))Check 4↑res←iConga.Wait clt maxwait
         →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

     :If 0<≢chunks
         :For cc :In chunks

             :If (0 clt'HTTPChunk'(cc(0 2⍴'')))Check 4↑res←iConga.Wait clt maxwait
                 →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
         :EndFor

         :If (0 clt'HTTPTrailer'(trailer))Check 4↑res←iConga.Wait clt maxwait
             →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
     :EndIf

     :If (0 clt'Closed' 1119)Check 4↑res←iConga.Wait clt maxwait
         →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :EndFor

 z←iConga.Close srv
 r←''   ⍝ surprise all worked!
 →0
fail:
 ErrorCleanup
