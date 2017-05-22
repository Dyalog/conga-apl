 r←Describe name;enum;state;type
      ⍝ Return description of object

 :If 0=1↑r←Tree name
     r←2 1⊃r
     enum←{2↓¨(⍵=1↑⍵)⊂⍵}
     state←enum',SNew,SIncoming,SRootInit,SListen,SConnected,SAPL,SReadyToSend,SSending,SProcessing,SReadyToRecv,SReceiving,SFinished,SMarkedForDeletion,SError,SDoNotChange,SShutdown,SSocketClosed,SAPLLast,SSSL,SSent,SListenPaused'
     type←enum',TRoot,TServer,TClient,TConnection,TCommand,TMessage'

     :If 0=2⊃r ⍝ Root
         r←0('[DRC]'(4⊃r)('State=',(1+3⊃r)⊃state)('Threads=',⍕5⊃r))
     :Else     ⍝ Something else
         (2⊃r)←(1+2⊃r)⊃type
         (3⊃r)←(1+3⊃r)⊃state
         r←0 r
     :EndIf
 :EndIf
