 r←test_http_coding dummy;Port;Host;srv;maxwait;crlf;lf;hex;hr;FmtHeader;SplitInChunks;FmtChunk;size;Header;Trailer;chunkext;Chunks;ret;test;sep;header;chunks;trailer;testdata;clt;probe;res;cc;Body;body;con;Request;Status
⍝  Test http chunked transfere

 Port←5000 ⋄ Host←'localhost'
 srv←'S1'
 maxwait←5000
 size←10000

 crlf←⎕UCS 13 10
 lf←⎕UCS 10

 hex←{⎕CT ⎕IO←0                          ⍝ Hexadecimal from decimal.
     ⍺←⊢                                 ⍝ no width specification.
     1≠≡,⍵:⍺ ∇¨⍵                         ⍝ simple-array-wise:
     1∊⍵=1+⍵:'Too big'⎕SIGNAL 11         ⍝ loss of precision.
     n←⍬⍴⍺,⌈16⍟1+⌈/|⍵              ⍝ default width.
     ↓[0]'0123456789abcdef'[(n/16)⊤⍵]    ⍝ character hex numbers.
 }
 hr←{0=≢2⊃⍵:(1⊃⍵),⍺ ⋄ (1⊃⍵),': ',(2⊃⍵),⍺}
 FmtHeader←{0=≢⍵:'' ⋄ (⊃,/(⊂⍺)hr¨↓⍵)}
 SplitInChunks←{s←(⍴⍵)⍴0 ⋄ s[1,⍺?⍴⍵]←1 ⋄ s⊂⍵}
 FmtChunk←{0<⍴⍵:(⊃hex⍴⍵),⍺,⍵,⍺ ⋄ '0',⍺}

 Body←size⍴⎕A,⎕D

 Request←'GET' 'Index.html' 'HTTP/1.1'
 Status←'HTTP/1.1' '200' 'OK'

 Header←0 2⍴⍬
 Header⍪←'Date'(2⊃iConga.GetProp'.' 'HttpDate')
 Header⍪←'Server' 'Apache/2.4.7 (Guanix)'
 Header⍪←'Last-Modified' 'Sat, 07 Mar 2015 16:19:33 GMT'
 Header⍪←'ETag' '"388-510b52a9de2c8"'
 Header⍪←'Accept-Ranges' 'bytes'
 Header⍪←'Vary' 'Accept-Encoding'
 Header⍪←'Content-Type' 'text/html'
⍝ Header⍪←'Transfer-Encoding' 'chunked'

 Trailer←0 2⍴⍬
 Trailer⍪←'Chunks' 'Apache/2.4.7 (Guanix)'
 Trailer⍪←'OS' 'Guanix'

 chunkext←0 2⍴⍬
 chunkext⍪←'CRC' ''



 Chunks←15 SplitInChunks Body

 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 srv)Check ret←iConga.Srv srv''Port'http'(8×size)
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf

 :If 0 Check⊃ret←iConga.SetProp srv'DecodeBuffers' 0
     →fail Because'Set DecodeBuffers to 0 failed: ',,⍕ret ⋄ :EndIf


 :For test :In (Header Body ⍬(0 2⍴''))(Header ⍬ Chunks Trailer)(Header ⍬ Chunks(0 2⍴''))

     (header body chunks trailer)←test

     :If (0)Check⊃ret←iConga.Clt''Host Port'http'(4×size)
         →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
     clt←2⊃ret

     :If 0 Check⊃ret←iConga.SetProp clt'DecodeBuffers' 15
         →fail Because'Set DecodeBufers to 15 failed: ',,⍕ret ⋄ :EndIf

     :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
         →fail Because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf
     con←2⊃ret

     :If 0<≢body
         :If 0 Check⊃ret←iConga.Send clt(Request,header body)
             →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf

         header⍪←'Content-Length'(⍕⍴body)
         :If (0 con'HTTPHeader'((¯1↓⊃,/Request,¨' '),crlf,(crlf FmtHeader header),crlf))Check 4↑res←iConga.Wait srv maxwait
             →fail Because'Bad result from srv Wait: ',,⍕res ⋄ :EndIf

         :If 0 Check⊃ret←iConga.Send(2⊃res)(4⊃res)
             →fail Because'Connection Send failed: ',,⍕ret ⋄ :EndIf

         :If (0 con'HTTPBody'(body))Check 4↑res←iConga.Wait srv maxwait
             →fail Because'Bad result from srv Wait: ',,⍕res ⋄ :EndIf

         :If 0 Check⊃ret←iConga.Send(2⊃res)(4⊃res)1
             →fail Because'Connection Send failed: ',,⍕ret ⋄ :EndIf

         :If (0 clt'HTTPHeader'(Request,⊂header))Check 4↑res←iConga.Wait clt maxwait
             →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

         :If (0 clt'HTTPBody'(body))Check 4↑res←iConga.Wait clt maxwait
             →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

     :Else
         header⍪←'Transfer-Encoding' 'chunked'
         :If 0 Check⊃ret←iConga.Send clt(Request,(header''))
             →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf

         :If (0 con'HTTPHeader'((¯1↓⊃,/Request,¨' '),crlf,(crlf FmtHeader header),crlf))Check 4↑res←iConga.Wait srv maxwait
             →fail Because'Bad result from srv Wait: ',,⍕res ⋄ :EndIf

         :If 0 Check⊃ret←iConga.Send(2⊃res)(4⊃res)
             →fail Because'Connection Send failed: ',,⍕ret ⋄ :EndIf

         :If (0 clt'HTTPHeader'(Request,⊂header))Check 4↑res←iConga.Wait clt maxwait
             →fail Because'Bad result from clt Wait: ',,⍕res ⋄ :EndIf


         :For cc :In chunks
             :If 0 Check⊃ret←iConga.Send clt(cc(0 2⍴''))
                 →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf

             :If (0 con'HTTPChunk'(crlf FmtChunk cc))Check 4↑res←iConga.Wait srv maxwait
                 →fail Because'Bad result from srv Wait: ',,⍕res ⋄ :EndIf

             :If 0 Check⊃ret←iConga.Send(2⊃res)(4⊃res)
                 →fail Because'Connection Send failed: ',,⍕ret ⋄ :EndIf

             :If (0 clt'HTTPChunk'(cc(0 2⍴'')))Check 4↑res←iConga.Wait clt maxwait
                 →fail Because'Bad result from clt Wait: ',,⍕res ⋄ :EndIf

         :EndFor
         :If 0 Check⊃ret←iConga.Send clt(⍬(trailer))
             →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf

         :If (0 con'HTTPTrailer'('0',crlf,(crlf FmtHeader trailer),crlf))Check 4↑res←iConga.Wait srv maxwait
             →fail Because'Bad result from srv Wait: ',,⍕res ⋄ :EndIf

         :If 0 Check⊃ret←iConga.Send(2⊃res)(4⊃res)1
             →fail Because'Connection Send failed: ',,⍕ret ⋄ :EndIf

         :If (0 clt'HTTPTrailer'(trailer))Check 4↑res←iConga.Wait clt maxwait
             →fail Because'Bad result from clt Wait: ',,⍕res ⋄ :EndIf

     :EndIf


     :If (0 clt'Closed' 1119)Check 4↑res←iConga.Wait clt maxwait
         →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

 :EndFor

 z←iConga.Close srv
 r←''   ⍝ surprise all worked!
 →0
fail:
 ErrorCleanup
