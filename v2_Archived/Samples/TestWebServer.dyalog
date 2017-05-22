 {r}←TestWebServer;files;folder;tid
     ⍝ Start a web server, request a page from it, kill it

 {}1 ##.DRC.Init'' ⍝ Kill all Conga objects
 folder←+2 ⎕NQ'.' 'GetEnvironment' 'Dyalog'
 folder,←'samples\asp.net\tutorial'

 tid←##.WebServer.Run&folder 8080 'HTTPSRV'
 ⎕DL 1 ⍝ Give the server a chance to wake up

     ⍝ Fetch n pages using a separate client thread for each
 files←(⊂'notthere.htm'),{'intro',(⍕⍵),'.htm'}¨⍳10
 r←{⎕TSYNC HTTPGet&'http://localhost:8080/',⍵}¨files
 :If 0∨.≠⊃¨1⊃¨r ⋄ ∘:EndIf ⍝ Errors
     {}##.DRC.Close'HTTPSRV'
     r←files,[1.5]3⊃¨r

     :While tid∊⎕TNUMS ⋄ ⎕DL 1 ⋄ :EndWhile ⍝ Wait for server thread to close down
