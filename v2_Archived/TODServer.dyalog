:Namespace TODServer
    DONE←1
    
∇ Run port;wait;data;event;obj;rc;r
 ⍝ Time of Day Server Example (use port 13)

 ##.DRC.Init'' ⋄ DONE←0 ⍝ Global DONE used to stop service
 :If 0≠1⊃r←##.DRC.Srv'TOD' ''port'Text'
     ⎕←'Unable to start TOD server: ',⍕r
 :Else
     ⎕←'TOD Server started on port ',⍕port
     :While ~DONE
         rc obj event data←4↑wait←##.DRC.Wait'TOD' 1000 ⍝ Time out now and again
         :Select rc
         :Case 0
             :Select event
             :Case 'Connect'
                 r←(,'ZI2,<:>,ZI2,<:>,ZI2,< >,ZI2,<->,ZI2,<->,ZI4'⎕FMT 1 6⍴⎕TS[4 5 6 3 2 1]),⎕AV[4 3]
                 {}##.DRC.Send obj r 1 ⍝ 1=Close connection
             :Else
                 {}##.DRC.Close obj ⍝ Anything unexpected
             :EndSelect
         :Case 100  ⍝ Time out - Housekeeping Here
         :Else
             ⎕←'Error in Wait: ',⍕wait ⋄ DONE←1
         :EndSelect
     :EndWhile
     {}##.DRC.Close'TOD' ⋄ ⎕←'TOD Server terminated.'
 :EndIf
∇
    
:EndNamespace 