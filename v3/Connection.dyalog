:Class Connection
    :field Public srv   ⍝ reference to Server started the Connection
    :field Public Name
    :field Public extra

    ∇ ct←ServerArgs
      :Access Public shared
        ⍝ return the type of connection you want
      ct←,⊂'Command'
    ∇

    ∇ sp←srv ServerProperties name
      :Access Public shared
         ⍝ Return the Properties to set for the server or
         ⍝ use the srv ref to access srv and srv.LIB and do it yourself
      sp←⍬
    ∇

    ∇ e←Progress(obj data)
      :Access public
      e←srv.LIB.Progress obj data
    ∇

    ∇ e←Respond(obj data)
      :Access public
      e←srv.LIB.Respond obj data
    ∇

    ∇ e←Send(data close)
      :Access public
      e←srv.LIB.Send Name data close
    ∇

    ∇ Close obj
      :Access public
      srv.Remove Name
      _←srv.LIB.Close Name
    ∇


    ∇ makeN arg
      :Access public
      :Implements constructor
      enc←{1=≡⍵:⊂⍵ ⋄ ⍵}
      defaults←{⍺,(⍴,⍺)↓⍵}
     
      (Name srv extra)←(enc arg)defaults''⍬(⎕NS'')
    ∇

    ∇ r←Test
      :Access public
      r←42
    ∇

    ∇ onReceive(obj data)
      :Access Public Overridable
      Respond obj(⌽data)
    ∇

    ∇ onError(obj data)
      :Access Public Overridable
      ⍝ ⎕←'Oh no ',obj,' has failed with error ',⍕data
    ∇
    
    ∇ onClose(obj data)
      :Access Public Overridable
      ⎕←'Closed: ',⍕obj
    ∇
    
:EndClass
