 r←test_tcp_hello dummy;Host;Port;maxwait;s1;con1;ret;res;hello;sock;mode
⍝ Test communication between Conga and a Dyalog TCP-Socket

 Host←'localhost' ⋄ Port←5000
 maxwait←1000

 :For mode :In 'Raw' 'Text'
     :If 0 Check⊃ret←iConga.Srv'' ''Port mode 5000
         →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
     s1←2⊃ret

     'sock'⎕WC'TCPSocket'('Style'(mode{⍺≡'Text':⍵ ⋄ ⍺}'Char'))('Encoding'((1+mode≡'Text')⊃'None' 'UTF-8'))('RemoteAddr' '127.0.0.1')('RemotePort'Port)('Event' 'All' 1)
     :If (ret←'sock'⎕WG'CurrentState')IsNotElement'Open' 'Connected'
         →fail Because'SocketState ≢ Connected after creation (="',ret,'")' ⋄ :EndIf

     :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
         →fail Because'Unexpected result from Srv Wait: ',,⍕res ⋄ :EndIf
     con1←2⊃res
     ret←⎕DQ sock
     ⎕DL 0.2  ⍝ give it time to change state...
     :If 'Connected'Check ret←'sock'⎕WG'CurrentState'
         →fail Because'SocketState ≢ Connected after connecting (="',ret,'")' ⋄ :EndIf

     hello←'Hello APL! ',(mode≡'Raw')/'{⍵≡⍳≢⍵}⍳10'
     :If mode≡'Raw' ⋄ hello←'UTF-8'⎕UCS hello ⋄ :EndIf
     res←iConga.Send con1 hello
     :If 0 Check⊃res
         →fail Because'Send failed: ',⍕ret ⋄ :EndIf

     :Repeat
         ret←⎕DQ sock
     :Until 'TCPRecv'≡2⊃ret
     :If hello Check 3⊃ret
         →fail Because'Received text ("',(3⊃ret),'") did not match sent text ("',(⍕hello),'")' ⋄ :EndIf

     {}2 ⎕NQ sock'TCPSend'(hello←mode{⍺≡'Text':⍵ ⋄ 'UTF-8'⎕UCS ⍵}'Hello world!')
     ret←iConga.Wait s1 maxwait

     :If hello Check 4⊃ret
         →fail Because'Received text ("',(4⊃ret),'") did not match sent text ("',hello,'")' ⋄ :EndIf

     {}⎕EX'sock'
     :If (⊃ret←iConga.Wait s1 maxwait)IsNotElement 0 100 ⍝ Wait for srv to receive Close-event of client (0 or 100 "TIMEOUT" are ok)
         →fail Because'Error during Wait of Srv:',⍕ret ⋄ :EndIf

     {}iConga.Close s1
     ⎕dl 1   ⍝ give it time to close...
 :EndFor
 r←''
 →0
fail:
 ErrorCleanup
