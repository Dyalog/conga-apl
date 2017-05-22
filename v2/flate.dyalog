:Class flate
⍝ This class provides access to the deflate/inflate functionality exposed by the Conga DLL
⍝    it is considered obsolete; Dyalog recommends the use of 219⌶

    :Field Public Shared LDRC                ⍝ Save a ref to DRC to be used from flate
    :Field Public Shared defaultcomp ←¯1     ⍝ Default compression 0-9 or ¯1
    :Field Public Shared defaultblocksize←2*15    ⍝ Default block size

    :Field Public Instance handle            ⍝ session handle
    :Field Public Instance direction         ⍝ 0= deflate, 1 = inflate
    :Field Public Instance comp              ⍝ compression level
    :Field Public Instance blocksize         ⍝ blocksize
    :Field Public Instance lastout

    ∇ r←IsAvailable
      :Access Public Shared
      :If 3=⎕NC'LDRC.cflate'
          r←1
      :Else
          r←0
      :EndIf
    ∇

    ∇ r←dir allflate arg;zz;handle
      r←⍬
      handle←0
      :Repeat
               ⍝  (1⌈⍴arg)↑   is a AIX workaround
          zz←LDRC.cflate dir(handle)((1⌈⍴arg)↑arg)(⍴arg)(defaultblocksize)(defaultblocksize)defaultcomp
          r,←(5⊃zz)↑4⊃zz
          handle←2⊃zz
          arg←⍬
      :Until (0=handle)∨(0=3⊃zz)∧(defaultblocksize>5⊃zz) ⍝ carry on until the input is processed and the we have not filled the last output buffer
    ∇

    ∇ r←instflate arg;zz
      r←⍬
      :Repeat
              ⍝  (1⌈⍴arg)↑   is a AIX workaround
          zz←LDRC.cflate direction(handle)((1⌈⍴arg)↑arg)(⍴arg)(blocksize)(blocksize)comp
          r,←(5⊃zz)↑4⊃zz
          arg←⍬
          handle←2⊃zz
          lastout←1 1 1 0 1/zz
      :Until (handle=0)∨(0=3⊃zz)∧(blocksize>5⊃zz) ⍝ carry on until the input is processed and the we have not filled the last output buffer
    ∇

    ∇ r←Deflate arg
      :Access Public Shared
     
      r←2 allflate arg
    ∇

    ∇ r←Inflate arg;zz
      :Access Public Shared
      r←3 allflate arg
    ∇

    ∇ make(d c b)
      :Access Public
      :Implements Constructor
      direction←d
      comp←c
      blocksize←b
      handle←0
      LDRC←FindDRC''
    ∇

    ∇ make0
      :Access Public
      :Implements Constructor
      make(0 defaultcomp defaultblocksize)
    ∇

    ∇ make1(dir)
      :Access Public
      :Implements Constructor
      make(dir defaultcomp defaultblocksize)
    ∇

    ∇ make2(dir c)
      :Access Public
      :Implements Constructor
      make(dir c defaultblocksize)
    ∇

    ∇ ldrc←FindDRC dummy
      :If 0=⎕NC'LDRC' ⍝ Find DRC namespace
          :If 9=⎕NC'#.DRC'
              ldrc←#.DRC
          :ElseIf 9=⎕NC'#.Conga'
              ldrc←#.Conga.Init''
          :EndIf
      :EndIf     
    ∇

    ∇ EndOfInput
      :Access Public
      direction+←2
    ∇

    ∇ r←EndOfOutput
      :Access Public
      r←0=handle
    ∇

    ∇ r←Process arg;zz
      :Access Public
     
      r←instflate arg
    ∇


:EndClass
