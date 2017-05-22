 TestTelnetServer;cmd2;rc;cmd1;port;host;i;cmds;cmd;prompt;CR
     ⍝ Test the Telnet Server

 host port←'localhost' 5023 ⍝ Default port is 23
 ##.TelnetServer.Run&⍬
 ⎕DL 2 ⍝ Give it time to start

 cmds←⍬
 prompt←NL,'    '
 CR←1⊃NL

 :For i :In ⍳2 ⍝ Login to two sessions
     rc cmd←##.DRC.Clt''host port'Text' 10000
     {}Say cmd''(⊂'User: ')
     {}Say cmd('mkrom',CR)(⊂'Password: ')
     {}Say cmd('secret',CR)(⊂prompt)
     cmds←cmds,⊂cmd
 :EndFor

 :For i :In ⍳⍴cmds ⍝ Make the sessions do something
     {}Say cmd('2+2',CR)(⊂prompt)
 :EndFor

 ##.DRC.Send(1⊃cmds)(')END',CR)
 ⎕DL 2
 ##.DRC.Close¨cmds
