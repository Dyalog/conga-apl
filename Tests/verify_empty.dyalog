 r←verify_empty iConga;fulltree;tree;one;obs
⍝ Verify that root is empty

 :If 0≠⍴tree←2 2⊃fulltree←iConga.Tree'.'
     obs←↑3↑¨1⊃¨tree
    ⍝ Ignore connection & clients which are in states Finished, MarkedForDeletion, Shutdown, Socketclosed
 :AndIf 0≠≢obs←(~(obs[;2]∊2 3)∧obs[;3]∊11 12 15 16)⌿obs
     one←1=≢obs
     r←(⍕≢tree),' object',((~one)/'s'),' exist',(one/'s'),' under root: ',,⍕obs[;1]
 :Else ⋄ r←''
 :EndIf
