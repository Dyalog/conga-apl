:Class ChatServer : HttpServerBase
    ⍝ Implement a web-socket based chat server

    :Field Public Shared clients←⍬

    NL←⎕UCS 13 10

    ∇ sp←srv ServerProperties name
      :Access Public Shared
      sp←,⊂('WSFeatures' 1) ⍝ Auto-accept WebSocket upgrade requests
    ∇

    ∇ MakeN arg
      :Access Public
      :Implements Constructor :Base arg
     
      DYALOG←'/',⍨2 ⎕NQ'.' 'GetEnvironment' 'Dyalog'
      INDEXHTML←DYALOG,'apllib/conga/HttpServers/chat.html'
      :If ~⎕NEXISTS INDEXHTML
          ('Index page "',INDEXHTML,'" not found')⎕SIGNAL 2
      :EndIf
    ∇

    ∇ Unmake
      :Implements Destructor
      clients←clients{(~⍺∊⊂⍵)/⍺}Name
    ∇

    ⍝ Return the Html/javascript for Browser to run the chat program
    ∇ onHtmlReq;html;headers;hdr;e
      :Access Public Override
      headers←0 2⍴⍬
      headers⍪←'Server' 'ClassyDyalog'
      headers⍪←'Content-Type' 'text/html'
      hdr←(-⍴NL)↓⊃,/{⍺,': ',⍵,NL}/headers
      e←SendFile 0 hdr INDEXHTML
    ∇

    ⍝ If WSFeatures is set to 1 you get a notification when the connection is upgraded
    ∇ onWSUpgrade(obj data)
      :Access Public
      clients,←⊂Name
    ∇

    ⍝ if WSFeatures is 0 You have to accept the upgrade requests
    ∇ onWSUpgradeReq(obj data)
      :Access Public
      _←srv.DRC.SetProp Name'WSAccept'(data'')
      clients,←⊂Name
    ∇

    ⍝ When the Browser sent data to the server
   
    ∇ onWSReceive(obj data);code;msg;ns;resp;final;opcode
      :Access Public                
      
      (msg final opcode)←data
      ns←{2::7159⌶⍵ ⋄ ⎕JSON ⍵}msg
      ns.date←,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2,<.>,ZI3'⎕FMT⍉⍪⎕TS  

      resp←{2::7160⌶⍵ ⋄ ⎕JSON ⍵}ns
      {}clients{srv.DRC.Send ⍺ ⍵}¨⊂resp 1
    ∇
    
:EndClass
