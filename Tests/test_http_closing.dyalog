 r←test_http_closing dummy;Port;Host;srv;maxwait;size;crlf;lf;hex;hr;FmtHeader;SplitInChunks;FmtChunk;Request;Status;Header;Trailer;ret;Body;mt;hcl;hclose;Tests;test;header;body;hplus;blksize;clt;con;res;split;hdr;close;cl;cnt;p;parts
⍝  Test http closing
⍝ with and without Connection close
⍝ with and without Content-Length
⍝ smaller and larger than blocksize
⍝ with and without 2xcrlf in data

 Port←0 ⋄ Host←'localhost'
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
 split←{(≢⍺)↓¨((,⍺)⍷⍺,⍵)⊂⍺,⍵}

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




 ⍝ Initialize and start server
 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 :If (0 srv)Check 2↑ret←NewSrv srv''Port'http'(8×size)('Options'iConga.DecodeHttp)
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 Port←3⊃ret


 ⍝ test with different form of data
 :For Body :In (size⍴⎕A,⎕D)(size⍴⎕A,⎕D,2⍴lf)(size⍴⎕A,⎕D,4⍴crlf)
     Tests←⍬
     hcl←1 2⍴'Content-Length'(⍕¯200+≢Body) ⍝ Data too long
     Tests,←⊂(hcl)100000               ⍝ Normal

     mt←0 2⍴⍬
     hcl←1 2⍴'Content-Length'(⍕≢Body)
     hclose←1 2⍴'Connection' 'close'
     ⍝        (Extra headers)    blksize
     Tests,←⊂(hcl)100000               ⍝ Normal
     Tests,←⊂(hclose)100000            ⍝ Jetty
     Tests,←⊂(hclose⍪hcl)100000        ⍝
     Tests,←⊂(hcl)(size-200)          ⍝ Normal
     Tests,←⊂(hclose)(size-200)       ⍝ Jetty
     Tests,←⊂(hclose⍪hcl)(size-200)    ⍝

     hcl←1 2⍴'Content-Length'(⍕200+≢Body) ⍝ Data short
     Tests,←⊂(hcl)100000               ⍝ Normal
     Tests,←⊂(hclose)100000            ⍝ Jetty
     Tests,←⊂(hclose⍪hcl)100000        ⍝

     hcl←1 2⍴'Content-Length'(⍕¯200+≢Body) ⍝ Data too long
     Tests,←⊂(hcl)100000               ⍝ Normal
     Tests,←⊂(hclose)100000            ⍝ Jetty
     Tests,←⊂(hclose⍪hcl)100000        ⍝


     :For test :In Tests
         header←Header
         body←Body
         (hplus blksize)←test

         ⍝ Connect to server
         :If (0)Check⊃ret←iConga.Clt''Host Port'http'(blksize)('Options'iConga.DecodeHttp)
             →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
         clt←2⊃ret

         ⍝ Connect event serverside
         :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
             →fail Because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf
         con←2⊃ret



     ⍝ Send Request to Server no payload
         :If 0 Check⊃ret←iConga.Send clt(Request,header'')
             →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf
     ⍝ receive request server sice
         :If (0 con'HTTPHeader'(Request,⊂header))Check 4↑res←iConga.Wait srv maxwait
             →fail Because'Bad result from srv Wait: ',,⍕res ⋄ :EndIf




         ⍝ We have a body but will return it without content-length but with Connection close
         :If 0 Check⊃ret←iConga.Send con(((¯1↓⊃,/Status,¨' '),crlf,(crlf FmtHeader header⍪hplus),crlf))
             →fail Because'Connection Send failed: ',,⍕ret ⋄ :EndIf

         :If 0 Check⊃ret←iConga.Send con body 1
             →fail Because'Connection Send failed: ',,⍕ret ⋄ :EndIf

         :If (0 clt'HTTPHeader'(Status,⊂header⍪hplus))Check 4↑res←iConga.Wait clt maxwait
             →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
         hdr←4 4⊃res
         close←hdr{(≢⍺)≥(↓⍺)⍳⍵}⊂'Connection' 'close'
         cl←2⊃⎕VFI⊃(hdr⍪'' '0')[hdr[;1]⍳⊆'Content-Length';2]
         :If cl>0
             :If cl=≢body
             ⍝ Normal we have got Content-Length and all data
                 :If (0 clt'HTTPBody'(body))Check 4↑res←iConga.Wait clt maxwait
                     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
             :ElseIf cl>≢body
             ⍝ Close during receiving the Body
                 :If (0 clt'HTTPError'(body))Check 4↑res←iConga.Wait clt maxwait
                     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
             :Else
             ⍝ Receive the Content-Length of the body
                 :If (0 clt'HTTPBody'(cl↑body))Check 4↑res←iConga.Wait clt maxwait
                     →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
             ⍝ remaining part of the body interpretated as Headers if body includes crlf or lf
             ⍝ last part of the body get received as Header and close ocurs during that
                 :If 1<cnt←≢parts←(crlf,crlf)split cl↓body
                 :OrIf 1<cnt←≢parts←(lf,lf)split cl↓body
                     :For p :In ¯1↓parts
                         :If (0 clt'HTTPHeader'(p'' ''(0 2⍴⊂'')))Check 4↑res←iConga.Wait clt maxwait
                             →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
                     :EndFor
                     :If 0<≢p←⊃¯1↑parts
                         :If (0 clt'HTTPError'p)Check 4↑res←iConga.Wait clt maxwait
                             →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
                     :EndIf
                 :Else
                     :If (0 clt'HTTPError'(cl↓body))Check 4↑res←iConga.Wait clt maxwait
                         →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
                 :EndIf

             :EndIf
         :Else
             :If close
             ⍝ No content-length and Connection close
                 :If blksize>≢body
                 ⍝ body less than MaxBlockSize all is received as an error
                     :If (0 clt'HTTPError'(body))Check 4↑res←iConga.Wait clt maxwait
                         →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
                 :Else
                 ⍝body bigger that MaxBlockSize we receive Bodies until last HttpError
                     :If (0 clt'HTTPBody'(blksize↑body))Check 4↑res←iConga.Wait clt maxwait
                         →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
                     :If (0 clt'HTTPError'(blksize↓body))Check 4↑res←iConga.Wait clt maxwait
                         →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
                 :EndIf
             :EndIf
         :EndIf
         :If 'HTTPError'≢3⊃res
             ⍝ if last receive was not a HTTPError we expect a Closed event
             :If (0 clt'Closed' 1119)Check 4↑res←iConga.Wait clt maxwait
                 →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf
         :EndIf

         ⍝ Make sure the object has gone away
         :If 1010 Check⊃res←iConga.Wait clt maxwait
             →fail Because'Bad result from Clt Wait: ',,⍕res ⋄ :EndIf

     :EndFor
 :EndFor
 z←iConga.Close srv
 r←''   ⍝ surprise all worked!
 →0
fail:
 ErrorCleanup
