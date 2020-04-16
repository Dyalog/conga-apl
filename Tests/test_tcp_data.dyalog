 r←test_tcp_data dummy;Host;Port;maxwait;MakeFile;ret;s1;c1;res;size;rs;z;mode;s2;c2;sock
⍝ Test communication between Conga and a Dyalog TCP-Socket
 Host←'localhost' ⋄ Port←5000
 maxwait←1000

 :If 0 Check⊃ret←iConga.Srv'' ''Port'Text'(5000)
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 s1←2⊃ret

 'sock'⎕WC'TCPSocket'('Style' 'Char')('Encoding' 'UTF-8')('RemoteAddr' '127.0.0.1')('RemotePort'Port)

 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
     →fail Because'Unexpected result from Srv Wait: ',,⍕res ⋄ :EndIf


 2 ⎕NQ sock'TCPSend' 'Hello world!'
 :If 'Hello world!'Check 4⊃ret←iConga.Wait s1 maxwait
     →fail Because'Received text did not match expected text' ⋄ :EndIf

 :For sz :In 5000 5001 32767
     2 ⎕NQ sock'TCPSend'(sent←sz⍴'Hello world!')  
     rcv←''
     :Repeat
         ret←iConga.Wait s1 maxwait
         :If ret[3]∊'Block' 'BlockLast'
             rcv,←4⊃ret
         :EndIf
         ⍝⎕←3⊃ret
⍝         ∘∘∘
     :Until ret[3]∊'BlockLast' 'Timeout'
     ⍝⎕←'got ',≢rcv
     :If sent Check rcv
         →fail Because'Sent & received text did not match' ⋄ :EndIf
 :EndFor
 :If 0 Check⊃ret←iConga.Close s1
     →fail Because'Unexpected result closing Srv' ⋄ :EndIf



 r←''
 →0
fail:
 z←iConga.Close s1
 ErrorCleanup
