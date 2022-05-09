 r←test_http_jetty dummy;Port;Host;srv;maxwait;crlf;lf;hex;hr;FmtHeader;SplitInChunks;FmtChunk;size;Header;Trailer;chunkext;Chunks;ret;test;sep;header;chunks;trailer;testdata;clt;probe;res;cc;Body;body;con;Request;Status;MakeFile;hplus;Bodylf;Bodycrlf
⍝  Test http data from jetty (Jenkins)

 Port←0 ⋄ Host←'localhost'
 srv←'S1'
 maxwait←5000
 size←10000

 crlf←⎕UCS 13 10
 lf←⎕UCS 10
 MakeFile←{
     nopen←{                              ⍝ handle on null file.
         0::⎕SIGNAL ⎕EN                  ⍝ signal error to caller.
         22::⍵ ⎕NCREATE 0                ⍝ ~exists: create.
         ⍵ ⎕NTIE 0                      ⍝  exists: tie.
     }
     (name size data)←⍵
     tie←nopen name
     _←0 ⎕NRESIZE tie
     _←(size⍴data)⎕NAPPEND tie
     ⎕NUNTIE tie
 }

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




 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 srv)Check 2↑ret←NewSrv srv''Port'http'(8×size)('Options'iConga.DecodeHttp)
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 Port←3⊃ret


 ⍝ test with different form of data
 :For Body :In ⌽(size⍴⎕A,⎕D)(size⍴⎕A,⎕D,2⍴lf)(size⍴⎕A,⎕D,4⍴crlf)

     MakeFile'test.dat'(⍴Body)Body
     Chunks←15 SplitInChunks Body

     :For test :In (Header Body ⍬(0 2⍴''))(Header('' 'test.dat')⍬(0 2⍴''))(Header ⍬ Chunks Trailer)(Header ⍬ Chunks(0 2⍴''))

         (header body chunks trailer)←test

         :If (0)Check⊃ret←iConga.Clt''Host Port'http'(4×size)('Options'iConga.DecodeHttp)
             →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
         clt←2⊃ret

         :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
             →fail Because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf
         con←2⊃ret



     ⍝ Send Request to Server
         :If 0 Check⊃ret←iConga.Send clt(Request,header'')
             →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf

         :If (0 con'HTTPHeader'(Request,⊂header))Check 4↑res←iConga.Wait srv maxwait
             →fail Because'Bad result from srv Wait: ',,⍕res ⋄ :EndIf



         :If 0<≢body
             hplus←1 2⍴'Connection' 'close'
         ⍝ We have a body but will return it without content-length but with Connection close
             :If 0 Check⊃ret←iConga.Send con(((¯1↓⊃,/Status,¨' '),crlf,(crlf FmtHeader header⍪hplus),crlf))
                 →fail Because'Connection Send failed: ',,⍕ret ⋄ :EndIf

             :If 0 Check⊃ret←iConga.Send con body 1
                 →fail Because'Connection Send failed: ',,⍕ret ⋄ :EndIf

             :If (0 clt'HTTPHeader'(Status,⊂header⍪hplus))Check 4↑res←iConga.Wait clt maxwait
                 →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

             :If (0 clt'HTTPError'(Body))Check 4↑res←iConga.Wait clt maxwait
                 →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

         :Else
         ⍝ Returning data in chunks
             hplus←2 2⍴'Transfer-Encoding' 'chunked' 'Connection' 'close'

             :If 0 Check⊃ret←iConga.Send con(((¯1↓⊃,/Status,¨' '),crlf,(crlf FmtHeader header⍪hplus),crlf))
                 →fail Because'Connection Send failed: ',,⍕ret ⋄ :EndIf


             :If (0 clt'HTTPHeader'(Status,⊂header⍪hplus))Check 4↑res←iConga.Wait clt maxwait
                 →fail Because'Bad result from clt Wait: ',,⍕res ⋄ :EndIf


             :For cc :In chunks
                 :If 0 Check⊃ret←iConga.Send con(cc(0 2⍴''))
                     →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf

                 :If (0 clt'HTTPChunk'(cc(0 2⍴'')))Check 4↑res←iConga.Wait clt maxwait
                     →fail Because'Bad result from clt Wait: ',,⍕res ⋄ :EndIf

             :EndFor
             :If 0 Check⊃ret←iConga.Send con(⍬(trailer))1
                 →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf


             :If (0 clt'HTTPTrailer'(trailer))Check 4↑res←iConga.Wait clt maxwait
                 →fail Because'Bad result from clt Wait: ',,⍕res ⋄ :EndIf

         :EndIf

         res←iConga.Wait clt maxwait
         :If 1010 Check⊃res
         :AndIf (0 clt'Closed' 1119)Check 4↑res
             →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

     :EndFor
 :EndFor
 z←iConga.Close srv
 r←''   ⍝ surprise all worked!
 →0
fail:
 ErrorCleanup
