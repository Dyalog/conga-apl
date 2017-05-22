 cmd SaveResult result
     ⍝ Collect results inside TestRPCServer
 results←results,⊂(2⊃cmd)'returned:'result
