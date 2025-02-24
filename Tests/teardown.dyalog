 r←teardown dummy;tree;z
⍝ Teardown "iConga"
 ⎕SE._cita._pLog'starting teardown'
 r←verify_empty iConga
 ⎕SE._cita._pLog'verify_empty=',⍕r
 :If 9=⎕NC'#.Conga' ⍝ Check we don't have lingering instances
     :If 0≠≢z←⎕INSTANCES #.Conga.Server
         r←r,((0≠≢r)/' '),(⍕≢z),' instances of #.Conga.Server still exist.'
     :EndIf

     :If 0≠≢z←⎕INSTANCES #.Conga.Client
         r←r,((0≠≢r)/' '),(⍕≢z),' instances of #.Conga.Client still exist.'
     :EndIf
 :EndIf
 ⎕SE._cita._pLog'ex conga'
 {}⎕EX'iConga'  ⍝ expunge the iConga used for the test
 ⎕SE._cita._pLog'end of teardown'
