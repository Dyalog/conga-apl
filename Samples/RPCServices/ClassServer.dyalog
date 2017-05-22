:Class ClassServer
⍝ /// This example looks very interesting but needs a lot of tidying up
  
    :field Public Done      ⍝ State of server
    :field Public Name
    :field Public Port 
    :field Public Timeout
    :field Public Class
    :field Private ConnectionObjects  
    
    
    ∇ r←connection RExec cmd;c;done;wr;z;data
      :Access Shared public
⍝ Send a command to an RPC server and wait for the answer
⍝ format is command { rightarg { left arg}}
     
     
      :If 0=1⊃r c←LDRC.Send connection cmd
          done←0
          :Repeat
              :If 0=1⊃r←LDRC.Wait c 10000 ⍝ Only wait 10 seconds
                  :Select 3⊃r
                  :Case 'Error'
     
                      ⎕←r←9999 'Communication error'
                      done←1
                  :Case 'Progress'
                 ⍝ progress report - update your GUI with 4⊃r?
     
                  :Case 'Receive'
                      done←1
                      data←4⊃r
                      :If 0=⊃data
                          r←2⊃data
                      :Else
                          (⍕2⊃data)⎕SIGNAL⊃data
                      :EndIf
                  :EndSelect
              :Else
     
                  done←100≠1⊃r
                  :If ~done
                      done←12=2 1 3⊃LDRC.Tree connection
                  :EndIf
                  :If done
                      ⎕←r
                  :EndIf
              :EndIf
          :Until done
      :Else
          ('Communication error: ',⍕⊃r)⎕SIGNAL 999
      :EndIf
     
     
    ∇

    ∇ NewServer(name port class classinit);err;r
      :Access Public
      :Implements Constructor
      Name←name
      Port←port
      Class←class
      Timeout←5000
      LDRC←#.DRC
      ConnectionObjects←0 2⍴⍬   ⍝ Empty Connection List
     
      err←Class.Init classinit
      :If err≠0 ⋄ ('Server Init failed: ',⍕err)⎕SIGNAL 999 ⋄ :EndIf
      ⍝Class.classserverref←⎕THIS
      Class.LDRC←LDRC
      :If 0≠1⊃r←LDRC.Srv Name''Port'Command' ⋄ 'Srv failed'⎕SIGNAL 999 ⋄ :EndIf   ⍝ Unable to start server
     
      Class.Log'ServerHandler started: ',⍕HandleRequests&1
    ∇
    
    ∇ EndServer
      :Implements Destructor
      ConnectionObjects←0 2⍴⍬
      :While 0=⊃LDRC.Wait Name 100  ⍝ sink all waiting responses
      :EndWhile
      {}LDRC.Close Name
     
    ∇
      
    ∇ HandleRequests dummy;rc;obj;event;ts;data;cix;con;curobj;fi;cmd;bo;z;wait
     
      Class.Log'Thread ',(⍕⎕TID),' listening on server ',Name
      Done←0
      :While ~Done
          rc obj event data←4↑wait←LDRC.Wait Name Timeout ⍝ Time out now and again
     
          :If 2000<(3⊃⎕AI)-Class.LastIntegrityCheck
              :If Done←Class.Integrity
                  :Continue
              :EndIf
          :EndIf
     
          :Select rc
          :Case 0
              :Select event
              :Case 'Error'
                  Class.Log'Error ',(⍕data),' on ',obj
     
                  cix←ConnectionObjects[;1]⍳⊂con←(2 indexby'.')obj
                  :If cix≤⊃⍴ConnectionObjects
                      ConnectionObjects←(cix≠⍳⊃⍴ConnectionObjects)⌿ConnectionObjects
                  :EndIf
                  :If Done←Name≡obj ⍝ Error on the listener itself?
                      LDRC.Close obj ⍝ Close connection in error
                  :EndIf
     
              :Case 'Receive'
                  :If 0≠⎕NC'#.Status'
                  :AndIf 0<⍴#.Status  ⍝ All requests gets status info
                      Done←'Stopped'≡#.Status
     
                      LDRC.Respond obj(990 #.Status) ⋄ :Continue
                  :EndIf
     
                  :If (⊃⍴ConnectionObjects)<cix←ConnectionObjects[;1]⍳⊂con←(2 indexby'.')obj
                      Class.Log'New Connection: ',con
                      curobj←⎕NEW Class con
                      curobj.classserverref←⎕THIS
                      ConnectionObjects⍪←con curobj
                  :Else
                      curobj←ConnectionObjects[cix;2]
                  :EndIf
     
                  :If '$$$AUTH$$$'{⍺≡(⊃⌊/⍴¨⍺ ⍵)↑⍵}(3 indexby'.')obj
                      ⍝ answer the authorization request
                      AuthorizeAnswer&curobj obj data
                      :Continue
                  :EndIf
     
                  :If 82=⎕DR data
                      data←,⊂data
                  :EndIf
     
                  :If 3<⍴data ⍝ Command is expected to be (function name)(argument)
                      LDRC.Respond obj(999 'Bad command format') ⋄ :Continue
                  :EndIf
     
                  :If 3≠1⊃fi←curobj.FnsInfo cmd←1⊃data ⍝ Command is expected to be a function in this ws
                      LDRC.Respond obj(999('Illegal command: ',cmd)) ⋄ :Continue
                  :EndIf
     
                  :If (2 2⊃fi)≠¯1+⍴data  ⍝ Number of argument need to match the intance methode
                      LDRC.Respond obj(999('Wrong number of arguments: ',cmd)) ⋄ :Continue
                  :EndIf
     
     
     
                 ⍝ ↓↓↓ Make call in separate thread
                  :Select ⊃⍴data
                  :Case 1
                      bo←obj{(⎕SIZE't'),{⍬}LDRC.Respond ⍺(t←(2⊃⍵)(1⊃⍵).{0::⎕EN ⎕DM ⋄ r←0(⍎⍺)⍬}⍬)}curobj,data
                  :Case 2
                      bo←obj{(⎕SIZE't'),{⍬}LDRC.Respond ⍺(t←(2⊃⍵)(1⊃⍵).{0::⎕EN ⎕DM ⋄ r←0((⍎⍺)⍵)}(3⊃⍵))}curobj,data
                  :Case 3
                      bo←obj{(⎕SIZE't'),{⍬}LDRC.Respond ⍺(t←(2⊃⍵)(1⊃⍵).{0::⎕EN ⎕DM ⋄ r←0((2⊃⍵)(⍎⍺)(1⊃⍵))}(2↓⍵))}curobj,data
                  :Else
                  :EndSelect
              :Case 'Connect'
                  Class.Log'Connect: ',⍕obj
              :Else
                  ∘ ⍝ Unexpected result?
              :EndSelect
          :Case 100  ⍝ Time out
             ⍝ Insert code for housekeeping tasks here
              z←LDRC.Tree Name
              :If 0<⍴2 2⊃z
                  ConnectionObjects←(ConnectionObjects[;1]∊(⊂1 1)⊃¨2 2⊃z)⌿ConnectionObjects
              :EndIf
          :Case 1010 ⍝ Object Not Found
              Class.Log'Server object closed - server shutting down'
              Done←1
     
          :Else
              Class.Log'Error in DRC.Wait: ',⍕wait
          :EndSelect
      :EndWhile
     
    ∇
    
    
    ∇ r←(n indexby c)str;t
      r←⊃(1↓¨(c=t)⊂t←c,str)[n]
    ∇
    
    
    ∇ r←Authorize con;tok;kp;rc;cmd;rr;i;cmd1
      :Access public shared
      i←0
      LDRC.SetProp con'IWA'('Negotiate' 'Administrator')
      :Repeat
          cmd←(con,'.$$$AUTH$$$',⍕i←i+1)
          kp tok←2⊃LDRC.GetProp con'Token'
          rc cmd1←LDRC.Send cmd tok
          rr←LDRC.Wait cmd 10000
          LDRC.SetProp con'Token'(4⊃rr)
      :Until 0=kp
      r←LDRC.GetProp con'IWA'
    ∇
    
    
    
    ∇ r←AuthorizeAnswer(curobj obj data);kp;tok;con
      con←{(-(⌽⍵)⍳'.')↓⍵}obj
      :If 0=⎕NC'curobj.AUTH'     ⍝ set first time
          LDRC.SetProp con'IWA'('Negotiate' 'Administrator')
          curobj.AUTH←'InProgress: ',⍕obj
      :Else
          curobj.AUTH←'InProgress: ',⍕obj
      :EndIf
      LDRC.SetProp con'Token'(data)
      kp tok←2⊃LDRC.GetProp con'Token'
      LDRC.Respond(obj)(tok)
     
      :If kp=0
          curobj.AUTH←LDRC.GetProp con'IWA'
      :EndIf
     
    ∇


   
:EndClass
