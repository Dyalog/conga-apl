 TestSecureTelnetServer;cmd2;rc;cmd1;port;host;i;cmds;cmd;prompt;CR;certpath;tid
     ⍝ Test the Secure Telnet Server

 host port←'localhost' 5023 ⍝ Default port is 23
 tid←##.TelnetServer.Run&server
 ⎕DL 2

 cmds←⍬
 prompt←NL,'    '
 CR←1⊃NL

 :For i :In ⍳2 ⍝ Login to two sessions
     rc cmd←2↑##.DRC.Clt''host port'Text' 10000('X509'geoff)('SSLValidation' 16)
     {}Say cmd''(⊂prompt)
     ⍝{}Say cmd''(⊂'User: ')
     ⍝{}Say cmd('mkrom',CR)(⊂'Password: ')
     ⍝{}Say cmd('secret',CR)(⊂prompt)
     cmds←cmds,⊂cmd
 :EndFor

 :For i :In ⍳⍴cmds ⍝ Make the sessions do something
     {}Say(i⊃cmds)('2+2',CR)(⊂prompt)
 :EndFor

 ##.DRC.Send(1⊃cmds)(')END',CR)
 :While tid∊⎕TNUMS ⋄ ⎕DL 1 ⋄ :EndWhile ⍝ Wait for server thread to close down
 ##.DRC.Close¨cmds
