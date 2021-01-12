 r←mantis_18737_test arg;enableBlockSize;bigBody;bigChunk;Port;srv;clt;maxwait;bodysize;ret;options;con;request;response;cs;chunk;res;clienterror;doslimit;z
 enableBlockSize bigBody bigChunk doslimit←0<4↑arg
 Port←5000
 srv←'S1'
 clt←'C1'
 maxwait←5000
 bodysize←5000+bigBody×20000
 clienterror←0
 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 1 failed: ',,⍕ret ⋄ :EndIf

 z←iConga.SetProp'.' 'DOSLimit'(2*20)
 :If doslimit
     :If 0 Check⊃ret←iConga.SetProp'.' 'DOSLimit' 20000
         →fail Because'Set DOSlimit to 1 failed: ',,⍕ret ⋄ :EndIf
 :EndIf
 options←iConga.Options.DecodeHttp+16×enableBlockSize

 :If (0 srv)Check ret←iConga.Srv srv''Port'http' 10000('Options'options)
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf

 :If (0 clt)Check ret←iConga.Clt clt''Port'http' 20000('Options'options)
     →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
     →fail Because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf
 con←2⊃ret

 request←'GET' '/test.html' 'HTTP1/1'(3 2⍴'Host' 'me' 'Accept' 'All' 'Origin' 'here')''
 :If 0 Check⊃ret←iConga.Send clt request
     →fail Because'Clt Send failed: ',,⍕ret ⋄ :EndIf

 :If (0 con'HTTPHeader'(4↑request))Check 4↑ret←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕ret ⋄ :EndIf

 response←'HTTP1/1' '200' 'OK'(3 2⍴'Date'(2⊃iConga.GetProp'.' 'HttpDate')'Server' 'Conga' 'Content-Type' 'text/html')(bodysize⍴⎕A)

 :If 0 Check⊃ret←iConga.Send con response
     →fail Because'Srv Send failed: ',,⍕ret ⋄ :EndIf



 :If 0 Check⊃ret←iConga.Wait clt maxwait
     →fail Because'Clt Wait failed: ',,⍕ret ⋄ :EndIf

 :If (bigBody∧enableBlockSize∨doslimit)
     :If (0 clt'Error'((1+doslimit)⊃1135 1146))Check 4↑ret
         →fail Because'Clt we did not catch big body: ',,⍕ret ⋄ :EndIf
     clienterror←1
 :Else
     res←4↑response
     (4⊃res)⍪←'Content-Length'(⍕bodysize)
     :If (0 clt'HTTPHeader'(res))Check 4↑ret
         →fail Because'Clt we did not get the header expected: ',,⍕ret ⋄ :EndIf

     :If (0 clt'HTTPBody'(5⊃response))Check 4↑ret←iConga.Wait clt maxwait
         →fail Because'Clt Wait failed: ',,⍕ret ⋄ :EndIf

     response←'HTTP1/1' '200' 'OK'(4 2⍴'Date'(2⊃iConga.GetProp'.' 'HttpDate')'Server' 'Conga' 'Content-Type' 'text/html' 'Transfer-Encoding' 'chunked')('')

     :If 0 Check⊃ret←iConga.Send con response
         →fail Because'Srv Send failed: ',,⍕ret ⋄ :EndIf


     :If (0 clt'HTTPHeader'(4↑response))Check 4↑ret←iConga.Wait clt maxwait
         →fail Because'Clt Wait failed: ',,⍕ret ⋄ :EndIf

     :For cs :In 100 1000 5000 19990,(bigChunk/20000 30000),0
         chunk←(cs⍴⎕A)(0 2⍴'')

         :If 0 Check⊃ret←iConga.Send con(chunk)
             →fail Because'Srv Chunk Send failed: ',,⍕ret ⋄ :EndIf

         :If (0)Check⊃ret←iConga.Wait clt maxwait
             →fail Because'Clt Wait failed: ',,⍕ret ⋄ :EndIf

         :If bigChunk∧(enableBlockSize∨doslimit)∧cs≥20000
             :If (0 clt'Error'((1+doslimit)⊃1135 1146))Check 4↑ret
                 →fail Because'Clt we did not catch the big chunk expected ',(⍕cs),': ',,⍕ret ⋄ :EndIf
             clienterror←1
             :Leave
         :Else
             :If 0<cs
                 :If (0 clt'HTTPChunk'(chunk))Check 4↑ret
                     →fail Because'Clt we did not get the chunk expected: ',,⍕ret ⋄ :EndIf
             :Else
                 :If (0 clt'HTTPTrailer'(2⊃chunk))Check 4↑ret
                     →fail Because'Clt we did not get the chunk expected: ',,⍕ret ⋄ :EndIf

             :EndIf
         :EndIf

     :EndFor

     :If 0=clienterror
         :If 0 Check⊃ret←iConga.Close clt
             →fail Because'Clt close failed: ',,⍕ret ⋄ :EndIf
     :EndIf


 :EndIf

 :If ((1+0<clienterror)⊃(0 con'Closed' 1119)(0 con'Error' 1105))Check 4↑res←iConga.Wait srv maxwait
     →fail Because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 z←iConga.Close srv
 r←''   ⍝ surprise all worked!
 →0
fail:
 ErrorCleanup
