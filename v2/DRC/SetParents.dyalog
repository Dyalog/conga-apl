 vc←SetParents vc;ix;m
 ix←vc.Elements.Subject⍳vc.Elements.Issuer  ⍝ find the index of the parents
 :If ∨/m←(ix≤⍴vc)∧ix≠⍳⍴ix                   ⍝ Mask the found items with parents and not selfsigned
     (m/vc).ParentCert←vc[m/ix]             ⍝ Set the parent
 :EndIf                                     ⍝ NB the :If prevents creation of an empty cert to allow above line to work
 vc←vc~vc.ParentCert                        ⍝ remove all parents from list
