 r←test_tcp_file dummy;Host;Port;maxwait;ret;s1;c1;res;size;rs;z;mode;s2;c2;oc;file;sock;socket;conn;_
⍝ Test communication between Conga and a Dyalog TCP-Socket
 Host←'localhost' ⋄ Port←5000
 maxwait←1000
 file←(2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'),'/help/resources/dyaloglogo.png'
 oc←{r←⎕NREAD tie 83,⎕NSIZE tie←⍵ ⎕NTIE 0 ⋄ sink←⎕NUNTIE tie ⋄ r}file

 :If 0 Check⊃ret←iConga.Srv'' ''Port'Raw'(5000)
     →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
 s1←2⊃ret

 socket←'sock'⎕WC'TCPSocket'('Style' 'Raw')('RemoteAddr' '127.0.0.1')('RemotePort'Port)('Event' 'All' 1)
 :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑res←iConga.Wait s1 maxwait
     →fail Because'Unexpected result from Srv Wait: ',,⍕res ⋄ :EndIf
 conn←2⊃res

 :If 0 Check⊃ret←iConga.Send conn(''file)0
     →fail Because'Send failed: ',,⍕ret ⋄ :EndIf

 :Repeat
     ret←⎕DQ socket
 :Until ret[2]∊'TCPRecv' 'TCPClose'
 :If ({(⍵×⍵>0)+(256+⍵)×⍵<0}oc)Check 3⊃ret  ⍝ negative integers ¯128..¯1 are mapped to 128..255
     →fail Because'Received data did not match expected content' ⋄ :EndIf
 {}⎕EX socket
 _←iConga.Close s1
 r←''
 →0
fail:
 z←iConga.Close s1
 ErrorCleanup
