 (count mean median mode)←StatCalc nums;sorted;n
     ⍝ Clever Statistical Calculations!

 count←⍬⍴⍴nums
 sorted←{⍵[⍋⍵]}nums
 n←{-⍵-1↓⍵,1+⍴sorted}{⍵/⍳⍴⍵}1,2≠/sorted ⍝ # occurrences of each

 mean←⍬⍴{(+/⍵)÷⍴⍵}nums                  ⍝ mean: the average
 median←⍬⍴sorted[⌈0.5×⍴sorted]          ⍝ median: number which splits set in two equal halves
 mode←sorted[+/(n⍳⌈/n)↑n]               ⍝ mode: most frequently occurring number
