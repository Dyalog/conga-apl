 iSyntax←{⍺←⊢
     ⎕←'iSyntax'(⍺ ⍵)
     c←⊣/⍵
     '('=c:⊢3 32                            ⍝ if '(expr)' ⍝ 1 0 0 0 0 0
     '{'=c:⊢3 52                            ⍝ if '{defn}' ⍝ 1 1 0 1 0 0
     '#'∊⍵:⊢0 0                             ⍝ # in anything un-parenthesised is an error
     '⎕'=c:⊢{0::0 0 ⋄ x←⍎⍵ ⋄ c←⎕NC'x' ⋄ (2 3⍳c)⊃(2 0)(3 52)(0 0)}⍵ ⍝ assumes ⎕FNS ambi
                                                    ⍝ ↑ reject ops & nss
     f←',⊢-⊂⍴⊃≡+!=⍳⊣↓↑|⍪⍕⍎∊⌽~×≠>⌊∨?⌷<≢⌈≥⍷⍉∪÷⍒⊥∧⍋⊖*○⍲⍱⍟⌹⊤≤∩'

     c∊f:⊢3 52
     0>⎕NC ⍵:⊢0 0                           ⍝ primitive operators

     res←⍎'((2⍴⎕nc∘⊂,⎕at),''',⍵,''')'      ⍝ then what is it?
     (nc at)←res                            ⍝ ⎕NC ⎕AT - rc?
     nc∊3.2 3.3:⊢3 52                       ⍝ 3,32+16+4 res ambi omega
     c←⌊nc                                  ⍝ class
     c∊0 2:⊢2 0                             ⍝ undef, var
     (r fv ov)←at                           ⍝ result, valence
     w←∨/(a d w)←fv=¯2 2 1                  ⍝ (ambi, dyad, omega)
     r←c,2⊥r a d w 0 0                      ⍝ class, encoded syntax
     1:⊢r
        ⍝ return nameclass and syntax for supplied name (string)
 }
