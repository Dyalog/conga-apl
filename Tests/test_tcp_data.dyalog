 r←test_tcp_data dummy;Host;Port;maxwait;MakeFile;ret;s1;c1;res;size;rs;z;mode;s2;c2;sock
⍝ Test communication between Conga and a Dyalog TCP-Socket: any translation happening?
 Host←'localhost' ⋄ Port←0
 maxwait←1000

 :If 0 Check⊃ret←NewSrv'' ''Port'Text'(5000)
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 s1←2⊃ret
 port←3⊃ret
 'sock'⎕WC'TCPSocket'('Style' 'Char')('RemoteAddr' '127.0.0.1')('RemotePort'port)

 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
     →fail Because'Unexpected result from Srv Wait: ',,⍕res ⋄ :EndIf

 hello←(256>⎕UCS ⎕AV)/⎕AV ⍝ test all chars with a ⎕ucs<256
 2 ⎕NQ sock'TCPSend'hello
 :If hello Check 4⊃ret←iConga.Wait s1 maxwait
     →fail Because'Received text did not match expected text' ⋄ :EndIf

 :For sz :In 5000 5001 32767
     2 ⎕NQ sock'TCPSend'(sent←sz⍴hello)
     rcv←''
     :Repeat
         ret←iConga.Wait s1 maxwait
         :If ret[3]∊'Block' 'BlockLast'
             rcv,←4⊃ret
         :EndIf
     :Until ret[3]∊'BlockLast' 'Timeout'
     :If sent Check rcv
         →fail Because'Sent & received text did not match' ⋄ :EndIf
 :EndFor
 :If 0 Check⊃ret←iConga.Close s1
     →fail Because'Unexpected result closing Srv' ⋄ :EndIf



 r←''
 →0
fail:
:if 2=⎕nc's1'  ⍝ avoid VALUE ERROR if we have an early failure
 z←iConga.Close s1
 :endif 
 ErrorCleanup
