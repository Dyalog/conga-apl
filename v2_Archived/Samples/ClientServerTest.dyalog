 ClientServerTest;ret
 1 ##.DRC.Init''
 ret←##.DRC.Srv'S1' '' 5000
 :If 0≠⊃ret
     ⎕←'Server returned error:'ret
     →0
 :EndIf
 ret←##.DRC.Clt'C1' '127.0.0.1' 5000
 :If 0≠⊃ret
     ⎕←'Client returned error:'ret
     →0
 :EndIf
 ##.DRC.Wait'S1' 10000
 ##.DRC.Send'C1'('hello' 'this' 'is' 'a' 'test')
 c←##.DRC.Wait'S1' 1000
 ##.DRC.Respond(2⊃c)(⌽4⊃c)
 ##.DRC.Wait'C1' 10000
