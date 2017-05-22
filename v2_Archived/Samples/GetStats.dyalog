 r←GetStats arg;noatt;result;input;count;mode;median;mean;nums
     ⍝ WebService Method to return statistics

 input←(arg[;2]⍳⊂'Input')⊃arg[;3],⊂'' ⍝ Extract Name from argument
 nums←⊃(//)⎕VFI input                 ⍝ Convert to numbers

 noatt←0 2⍴⊂'' ⍝ We do not set any attributes
 result←1 4⍴1 'Stats' ''noatt
 result⍪←2,(('Count' 'Mean' 'Median' 'Mode'),[1.5]←StatCalc nums),⊂noatt
 r←1 result
