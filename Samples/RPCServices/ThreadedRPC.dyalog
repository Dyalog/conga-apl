    :Class ThreadedRPC : #.Conga.Connection

        ∇ sp←srv ServerProperties name
          :Access Public Shared
          sp←,⊂'ConnectionOnly' 1
        ∇
    

        ∇ MakeN arg
          :Access Public
          :Implements Constructor :Base arg
          done←0
          HError←0
          name←⊃arg
          DRC←srv.DRC
          timeout←srv.timeout
          htid←Handler&name         
        ∇
     
        ∇ onReceive(obj data)
          :Access public override
          Respond obj(data(⌽data))
        ∇
  
        ∇ Remove name
          srv.Remove name
        ∇

        ∇ Handler name;r;newcon;err;obj;evt;data
          events←2↓¨'on'{((⊂⍺)≡¨(⍴,⍺)↑¨⍵)/⍵}⎕NL ¯3
          :While ~done
              :If 0=⊃r←DRC.Wait name timeout
                  (err obj evt data)←4↑r
                  :Select evt
                  :CaseList 'Error' 'Close'
                      :If 0<⎕NC'onError'
                          onError obj data
                      :EndIf
                      :Leave
         
                  :Case 'Receive'
                      onReceive obj data
                  :Case 'Timeout'
                      :If 0<⎕NC'onTimeout'
                          onTimeout
                      :EndIf
                  :Else
                      :If ∨/events∊⊂evt
                          ⍎obj,'.on',evt,'& obj data'
                      :Else
                          _←DRC.Close name
                          'unexpected event'⎕SIGNAL 999
                      :EndIf
                  :EndSelect
              :Else
                  HError←⊃r
                  done←1
              :EndIf
          :EndWhile
          htid←0
          Remove name
        ∇

    :EndClass  
