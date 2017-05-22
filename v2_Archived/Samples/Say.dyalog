 r←Say(cmd send tails);done;data;wr
     ⍝ On an open conversation (see OpenConversation), send something and wait for expected "tails"

 :If 0=1⊃r←##.DRC.Send cmd(⎕←send)           ⍝ Send something
     data done←'' 0
     :Repeat
         :Select 1⊃wr←##.DRC.Wait cmd 1000
         :Case 100 ⋄ ⍞←'.' ⍝ Time out
         :Case 0 ⋄ ⍞←4⊃wr
             data,←4⊃wr
             :If done←∨/((-⍴¨tails)↑¨⊂data)≡¨tails   ⍝ We found a tail
                 r←0 data
             :Else
                 done←done∨'BlockLast'≡3⊃wr
             :EndIf
         :Else
             →0
         :EndSelect
     :Until done
 :EndIf
