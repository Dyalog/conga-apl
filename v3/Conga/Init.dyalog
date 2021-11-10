 ref←{libpath}Init arg;rootname;inst;ix;r;z;isLoaded;x
 :If 0=⎕NC'libpath' ⋄ libpath←'' ⋄ :EndIf

 :Trap 0
     lcase←0∘(819⌶)
     z←lcase'A' ⍝ Try to use it
 :Else
     lowerAlphabet←'abcdefghijklmnopqrstuvwxyzáâãçèêëìíîïðòóôõùúûýàäåæéñöøü'
     upperAlphabet←'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÂÃÇÈÊËÌÍÎÏÐÒÓÔÕÙÚÛÝÀÄÅÆÉÑÖØÜ'
     fromto←{n←⍴1⊃(t f)←⍺ ⋄ ~∨/b←n≥i←f⍳s←,⍵:s ⋄ (b/s)←t[b/i] ⋄ (⍴⍵)⍴s} ⍝ from-to casing fn
     lc←lowerAlphabet upperAlphabet∘fromto ⍝ :Includable Lower-casification of simple array
     lcase←{2=≡⍵:∇¨⍵ ⋄ lc ⍵}
 :EndTrap

 ncase←{(lcase ⍺)⍺⍺(lcase ⍵)} ⍝ case-insensitive operator

 rootname←⊃((0≠≢arg)/enc arg)defaults,⊂'DEFAULT'

 :Hold 'Conga.Init'
     isLoaded←3=⎕NC'⍙InitRPC'
     :If 0=⊃r←LoadSharedLib libpath ⍝ Sets LibPath as side-effect
         :If isLoaded≠3=⎕NC'⍙InitRPC' ⍝ the shared lib has been loaded revitalize all the instances
         :AndIf 0<≢x←⎕INSTANCES⊃⊃⎕CLASS LIB
             x.LibPath←⊂LibPath
             x.InitInstance
         :EndIf

         :If ⍬≡ref←FindInst rootname
             ref←##.⎕NEW LIB(LibPath rootname) ⍝ NB always create instances in the parent space
         :EndIf
     :Else
         ('Unable to load shared library: ',⍕r)⎕SIGNAL 999
     :EndIf
 :EndHold
