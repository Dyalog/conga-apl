:Namespace RPCServer
    cmd←'End'
    
    ∇ r←End x
      r←done←x ⍝ Will cause server to shut down
    ∇
    
    ∇ r←Reverse arg
      r←⌽arg
    ∇

    ∇ r←Foo arg
      ⍝ Something for the server to do
      ⎕DL 1
      r←'Foo: 'arg
    ∇
    
    ∇ r←Goo arg
      ⍝ Something for Server to do
      ⎕DL 1
      r←'Goo: 'arg
    ∇
    
    ∇ Process(obj data);r
⍝ Process a call. data[1] contains function name, data[2] an argument
     
      {}##.DRC.Progress obj('    Thread ',(⍕⎕TID),' started to run: ',,⍕data) ⍝ Send progress report
     
      :Trap 0 ⋄ r←0((⍎1⊃data)(2⊃data))
      :Else ⋄ r←⎕EN ⎕DM
      :EndTrap
     
      {}##.DRC.Respond obj r
    ∇
    
    ∇ r←{start}Run arg;sink;done;data;event;obj;rc;wait;z;cmd;name;port;cert;rootcertdir;flags;secure;secargs;PeerCert;x
      ⍝ Ultra simple RPC Server
      ⍝ Assumes Congo available in ##.DRC
      ⍝ Args   1: name Server name
      ⍝        2: port Port to listen on
      ⍝        3: certificate  Default empty not running as secure server.
      ⍝        4: RootCertDir directory for root certificates. Default ca from TestCertificates
      ⍝        5: Flags to use for certificate validation. default 32+64  Accept Without Validating, RequestClientCertificate
     
      :If 0=⎕NC'start' ⋄ start←1 ⋄ :EndIf
      {}##.DRC.Init''
     
      name port cert rootcertdir flags←5↑arg,(⍴arg)↓'RPCSRV' 5000(⎕NEW ##.DRC.X509Cert)(##.Samples.CertPath,'ca')(32+64)
      secure←1<cert.IsCert
      secargs←⍬
      :If secure
          :If 0<⍴rootcertdir
              {}##.DRC.SetProp'.' 'RootCertDir'(rootcertdir)
          :EndIf
          secargs←('X509'cert)('SSLValidation'flags)
      :EndIf
     
     
      :If start
          →(0≠1⊃r←##.DRC.Srv name''port'Command',secure/secargs)⍴0 ⍝ Exit if unable to start server
          'Server ''',name,''', listening on port ',⍕port
          ' Handler thread started: ',⍕0 Run&name port
          ⍝ Above line starts handler on separate thread (which continues from :Else below)
     
      :Else ⍝ Handle the server (in a new thread)
          ' Thread ',(⍕⎕TID),' is now handing server ''',name,'''.'
          done←0 ⍝ Done←1 in function "End"
          :While ~done
              rc obj event data←4↑wait←##.DRC.Wait name 3000 ⍝ Time out now and again
     
              :Select rc
              :Case 0
                  :Select event
                  :Case 'Error'
                      ⎕←'Error ',(⍕data),' on ',obj
                      :If ~done∨←name≡obj ⍝ Error on the listener itself?
                          {}##.DRC.Close obj ⍝ Close connection in error
                      :EndIf
     
                  :Case 'Receive'
                      :If 2≠⍴data ⍝ Command is expected to be (function name)(argument)
                          {}##.DRC.Respond obj(99999 'Bad command format') ⋄ :Leave
                      :EndIf
     
                      :If 3≠⎕NC cmd←1⊃data ⍝ Command is expected to be a function in this ws
                          {}##.DRC.Respond obj(99999('Illegal command: ',cmd)) ⋄ :Leave
                      :EndIf
     
                      Process&obj data ⍝ Handle each call in new thread
     
                  :Case 'Connect' ⍝ Ignored
                      x←##.DRC.GetProp(obj)'PeerCert'
                      :If 0=⊃x
                      :AndIf 9=⎕NC 2⊃x
                          PeerCert←2⊃x
                          PeerCert.UseMSStoreAPI←1
                          ⎕←'Connected: '(PeerCert.Formatted.(SerialNo Issuer Subject))
                      :EndIf     
                   :case 'Timeout'
                       ⍝ Conga 30 move timeout up as an event
                  :Else ⍝ Unexpected result?
                      ∘
                  :EndSelect
     
              :Case 100  ⍝ Time out - Insert code for housekeeping tasks here
     
              :Case 1010 ⍝ Object Not Found
                  ⎕←'Object ''',name,''' has been closed - RPC Server shutting down' ⋄ done←1
     
              :Else
                  ⎕←'Error in RPC.Wait: ',⍕wait
              :EndSelect
          :EndWhile
          ⎕DL 1 ⍝ Give responses time to complete
          {}##.DRC.Close name
          ⎕←'Server ',name,' terminated.'
     
      :EndIf
    ∇
    
    ∇ r←RPCClientInit arg;rootcertdir
      rootcertdir←arg
      :If 0=⊃r←##.DRC.Init''
          :If 0<⍴rootcertdir
              {}##.DRC.SetProp'.' 'RootCertDir'(rootcertdir)
          :EndIf
      :EndIf
    ∇
      
      

    ∇ r←RPCConnect arg;address;port;cert;rootcertdir;flags;secure;secargs
      ⍝ Assumes Congo available in ##.DRC
      ⍝ Args   1: address Server address
      ⍝        2: port Port
      ⍝        3: certificate  Default empty not running as secure server.
      ⍝        4: RootCertDir directory for root certificates. Default ca from TestCertificates
      ⍝        5: Flags to use for certificate validation. default 32+64  Accept Without Validating, RequestClientCertificate
     
      address port cert rootcertdir flags←5↑arg,(⍴arg)↓'localhost' 5000(⎕NEW ##.DRC.X509Cert)(##.Samples.CertPath,'ca')(32+64)
      secure←1<cert.IsCert
      secargs←⍬
      :If secure
          :If 0<⍴rootcertdir
              {}##.DRC.SetProp'.' 'RootCertDir'(rootcertdir)
          :EndIf
          secargs←('X509'cert)('SSLValidation'flags)
      :EndIf
      r←##.DRC.Clt''address port'Command',secure/secargs ⍝ Exit if unable to connect
     
    ∇

    ∇ r←RPCGet(client cmd);c;done;wr;z
⍝ Send a command to an RPC server (on an existing connection) and wait for the answer.
     
      :If 0=1⊃r c←##.DRC.Send client cmd
          :Repeat
              :If ~done←∧/100 0≠1⊃r←##.DRC.Wait c 10000 ⍝ Only wait 10 seconds
     
                  :Select 3⊃r
                  :Case 'Error'
                      done←1
                  :Case 'Progress'
                      ⍝ progress report - update your GUI with 4⊃r?
                      ⎕←'Progress: ',4⊃r
                  :Case 'Receive'
                      r←0(4⊃r)
                      done←1
                  :EndSelect
              :EndIf
          :Until done
      :EndIf
    ∇
    ∇ r←carg RPC cmd;rc;err;con
      :If 0=⊃err con←2↑r←RPCConnect carg
      :AndIf 0=⊃r←RPCGet(con)(cmd)
          r←2⊃r
          ##.DRC.Close con
      :Else
          'RPCCall failed'⎕SIGNAL 999
      :EndIf
    ∇
:EndNamespace 
