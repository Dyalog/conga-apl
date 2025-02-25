 r←teardown dummy;tree;z
⍝ Teardown "iConga"

 r←verify_empty iConga

 :If 9=⎕NC'#.Conga' ⍝ Check we don't have lingering instances
     :If 0≠≢z←⎕INSTANCES #.Conga.Server
         r←r,((0≠≢r)/' '),(⍕≢z),' instances of #.Conga.Server still exist.'
     :EndIf

     :If 0≠≢z←⎕INSTANCES #.Conga.Client
         r←r,((0≠≢r)/' '),(⍕≢z),' instances of #.Conga.Client still exist.'
     :EndIf
 :EndIf
 {}⎕EX'iConga'  ⍝ expunge the iConga used for the test
