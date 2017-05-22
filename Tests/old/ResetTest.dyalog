 ret←ResetTest;count;error;msg;ret
 count←0
 error←0
 msg←''

 :While error=0
     ret←1 ##.DRC.Init''
     error←⊃ret
     :If error≠0
         msg←'init:'
         :Continue
     :EndIf
     ret←##.DRC.Srv'S1' '' 5000
     error←⊃ret
     :If error≠0
         msg←'server:'
         :Continue
     :EndIf
     ret←##.DRC.Clt'C1' '127.0.0.1' 5000
     error←⊃ret
     :If error≠0
         msg←'client: '
         :Continue
     :EndIf
     count+←1
 :EndWhile
 ret←count'succesful iterations. Failed with 'msg(⊃ret)(2⊃ret)
