 TestCompression;Data;CompData9;test;d;r;b;de;BlockSizes;in;bs;comp;bsi;bso;DataSets;compressions;testQ;ts;tl
 DataSets←(⎕UCS 2000⍴'Dette er en test ')(¯1+?3000⍴256)
 :If 0=⊃r←HTTPGet'http://www.dyalog.com'
     DataSets,←⊂⎕UCS 3⊃r
 :EndIf
 Data←⊃DataSets
 CompData9←120 156 115 73 45 41 73 85 72 45 82 72 205 83 40 73 45 46 81 112 25 21 24 21 24 21 24 21 24 21 24 21 24 21 24 106 2 0 67 195 179 95
 BlockSizes←10 100 1000 10000 100000⍝5 11 17 37 67 131 257 521 1031 2053 4099 8209 16411 32771 65537,2*1+⍳10
 BlockSizes←BlockSizes[⍋BlockSizes]
 compressions←¯1,⍳9
 test←{⍺,('Failed' 'OK')[⎕IO+⍵]}
 testQ←{0=⍵:⍺,'Failed'}

 'Deflate 'test CompData9≡##.DRC.flate.Deflate Data
 'Inflate 'test Data≡##.DRC.flate.Inflate CompData9
     ⍝      :For Data :In DataSets
     ⍝
     ⍝          ('Deflate   ',8 0⍕(⍴Data),(100-100×(⍴r)÷⍴Data))test Data≡##.DRC.flate.Inflate r←##.DRC.flate.Deflate Data
     ⍝      :EndFor

 tl←ts←##.DRC.Micros
 :For Data :In DataSets



     :For comp :In compressions
         ##.DRC.flate.defaultcomp←comp
         ('Deflate   ',8 0⍕(comp),(⍴Data),(100-100×(⍴r)÷⍴Data),((##.DRC.Micros-tl)÷1000))test Data≡##.DRC.flate.Inflate r←##.DRC.flate.Deflate Data
         tl←##.DRC.Micros
         :For bsi :In BlockSizes

             :For bso :In BlockSizes

                 d←Data
                 r←⍬
                 de←⎕NEW ##.DRC.flate(0 comp bso)

                 :Repeat

                     b←(bsi⌊⍴d)↑d
                     d←(⍴b)↓d
                     :If 0=⍴d ⋄ de.EndOfInput ⋄ ⋄ :EndIf
                     r,←de.Process b
                 :Until de.EndOfOutput
                 ('Deflate compression ',(2 0⍕comp),' buffersize ',8 0⍕bsi bso,(⍴r))testQ Data≡##.DRC.flate.Inflate r
                 ⎕EX'de'

                 d←r
                 r←⍬
                 in←⎕NEW ##.DRC.flate(1 ¯1 bso)

                 :Repeat

                     b←(bsi⌊⍴d)↑d
                     d←(⍴b)↓d
                     :If 0=⍴d ⋄ in.EndOfInput ⋄ :EndIf
                     r,←in.Process b
                 :Until in.EndOfOutput
                 ('Inflate compression ',(2 0⍕comp),' buffersize ',8 0⍕bsi bso,(⍴r))testQ Data≡r
                 ⎕EX'in'


             :EndFor
         :EndFor
     :EndFor
 :EndFor
 'TestCompression Ends ',8 0⍕(##.DRC.Micros-ts)÷1000
