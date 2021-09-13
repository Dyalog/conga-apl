 r←NewSrv arg;port;addr
 port←3⊃arg
 :If port≠0
     r←iConga.Srv arg
     r,←port
 :Else
     r←iConga.Srv arg
     :If 0=1⊃r
         addr←iConga.GetProp(2⊃r)'Localaddr'
         :If 0=1⊃addr
             port←2 4⊃addr
         :EndIf
     :EndIf
     r,←port
 :EndIf
