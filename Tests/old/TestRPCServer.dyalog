 r←TestRPCServer;cmds;name;z;i;tnums;results
     ⍝ Start an RPC server, ask it some things

 {}1 ##.DRC.Init''
 :If 0=1⊃r←##.RPCServer.Run'RPCSRV' 5050
     ⎕DL 1 ⍝ Give the server a change to wake up

     ⍝ Fetch n pages using a separate client thread for each
 :AndIf 0=1⊃r←##.DRC.Clt'' 'localhost' 5050 ⍝ Make one client!
     name←2⊃r ⍝ Client name
     cmds←('Foo' 1)('Goo' 2)('Foo' 3)('Goo' 4)
     results←tnums←⍬
     :For i :In ⍳⍴cmds
         tnums,←{⍵ SaveResult RPCGet ⍵}&name(i⊃cmds)
     :EndFor
     ⎕TSYNC tnums
     :If 0∨.≠(⊂3 1)⊃¨results ⋄ ∘:EndIf ⍝ Errors
         r←↑results ⋄ r[;3]←4⊃¨r[;3]
         {}RPCGet name('End' 1) ⍝ Shut down the server
         {}##.DRC.Wait name 5000 ⍝ Give server time to shut down
     :EndIf
     {}##.DRC.Close name
