 {r}←TestWebFunctionServer;files
     ⍝ Start a web server, request a page from it, kill it

 {}1 ##.DRC.Init'' ⍝ Kill all Conga objects
 ##.WebServer.Run&'#.WebServer.TimeServer' 8080 'HTTPSRV'
 ⎕DL 1 ⍝ Give the server a change to wake up

     ⍝ Fetch n pages using a separate client thread for each
 files←(⊂'notthere'),{'page&id=',⍕⍵}¨⍳3
 r←{⎕TSYNC HTTPGet&'http://localhost:8080/',⍵}¨files
 :If 0∨.≠⊃¨1⊃¨r ⋄ ∘:EndIf ⍝ Errors
     {}##.DRC.Close'HTTPSRV'
     r←files,[1.5]3⊃¨r
