 r←test_png_HTTP dummy;Host;Port;maxwait;Magic;file;oc;mode;s1;c1;rs;res;len;z;lastsz;cl;ai3;ret;cpu
⍝ Test sending & receiving a .PNG-file in HTTP-Mode
 Host←'localhost' ⋄ Port←5000
 maxwait←1000
 Magic←{(4/256)⊥⎕UCS 4↑⍵}
 file←(2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'),'/help/resources/dyaloglogo.png'
 oc←{r←⎕NREAD tie,(⎕DR' '),⎕NSIZE tie←⍵ ⎕NTIE 0 ⋄ sink←⎕NUNTIE tie ⋄ r}file

 mode←'HTTP'
 :If 0 Check⊃ret←iConga.Srv'' ''Port mode(5000)
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 s1←2⊃ret

 :If 0 Check⊃ret←iConga.Clt''Host Port mode(5000)
     →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
 c1←2⊃ret

 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
     →fail Because'Unexpected result from Srv Wait: ',,⍕res ⋄ :EndIf

 lastsz←≢oc
 cpu←⍬
 :For cl :In ¯1+⍳10
     :If 0=Check⊃ret←iConga.SetProp s1'CompLevel'cl ⍝ set compression level  for root
         →fail Because'Error setting CompLevel=',(⍕cl),', ret=',⍕ret ⋄ :EndIf

     ai3←⎕AI[3]
     ret←iConga.Send c1('HTTP/1.1' '200' 'OK'(0 2⍴0)(''file))
     ai3←⎕AI[3]-ai3 ⋄ cpu←cpu,ai3

     :If (0)Check⊃ret
         →fail Because'Send failed: ',,⍕ret ⋄ :EndIf

     rs←⍬
     :Repeat
         res←iConga.Wait s1 maxwait
         :If res[1 3]IsNotElement(0 'Block')(100 'TIMEOUT')(0 'HTTPHeader')(0 'HTTPBody')
             →fail Because'Unexpected result from Srv Wait: ',,⍕res[1 3] ⋄ :EndIf
         :If 3<≢res
         :AndIf 0<≢4⊃res
             :Select 3⊃res
             :Case 'HTTPHeader'
                 len←2⊃⎕VFI⊃('Content-Length:\s?(\d*)'⎕S'\1')4⊃res
                 :If (,≢oc)Check len
                     →fail Because'Content-Length of HTTPHeader (',(⍕len),' did not expect fize of submitted file (',(⍕≢oc),')' ⋄ :EndIf
             :Case 'HTTPBody' ⋄ rs←4⊃res
             :Else
                 →fail Because'Received unexpected message "',(3⊃res),'" while waiting for HTTPHeader or HTTPBody'
             :EndSelect
         :EndIf
     :Until ~res[3]∊'Block' 'HTTPHeader' 'Timeout'

     :If rs≢⍬
     :AndIf oc Check rs
         →fail Because'Content sent & received via Conga does not match original file-content' ⋄ :EndIf
 :EndFor
 ⎕←'cpu=',cpu
 :If 0 Check⊃ret←iConga.Close s1
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

 :If 0 Check⊃ret←iConga.Close c1
     →fail Because'Close failed: ',,⍕ret ⋄ :EndIf

 r←''
 →0
fail:
 z←iConga.Close¨c1 s1
 ErrorCleanup
