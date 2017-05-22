 {r}←RPCGet(client cmd);c;done;wr;z
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
                 done←1
             :EndSelect
         :EndIf
     :Until done
 :EndIf
