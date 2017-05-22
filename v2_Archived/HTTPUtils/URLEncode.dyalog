 r←URLEncode data;⎕IO;z;ok;nul;m;enlist
 nul←⎕UCS ⎕IO←0
 enlist←{⎕ML←3 ⋄ ∊⍵}
 ok←nul,enlist ⎕UCS¨(⎕UCS'aA0')+⍳¨26 26 10

 z←⎕UCS'UTF-8'⎕UCS enlist nul,¨,data
 :If ∨/m←~z∊ok
     (m/z)←↓'%',(⎕D,⎕A)[⍉16 16⊤⎕UCS m/z]
     data←(⍴data)⍴1↓¨{(⍵=nul)⊂⍵}enlist z
 :EndIf

 r←¯1↓enlist data,¨(⍴data)⍴'=&'
