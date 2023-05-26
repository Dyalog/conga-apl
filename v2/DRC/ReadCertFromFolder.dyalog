 certs←ReadCertFromFolder wildcardfilename;fnames;ftypes;f
 :Access Public Instance
 :If ~∨/'?*'∊wildcardfilename
     wildcardfilename,←'/*' ⍝ add wildcard if none present
 :EndIf
 (fnames ftypes)←0 1(⎕NINFO ⎕OPT 1)wildcardfilename
 fnames/⍨←ftypes=2 ⍝ keep files only
 certs←⍬

 :For f :In fnames
     :Trap 11
         certs,←ReadCertFromFile f
     :EndTrap
 :EndFor
