 r←Send a;⎕IO
     ⍝ Name data {CloseConnection}
 ⎕IO←1
 r←check ⍙CallRL RootName'ASendZ'((a,0)[1 3])(2⊃a)
