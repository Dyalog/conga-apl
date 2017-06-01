 certs←ReadCertFromFolder wildcardfilename;files;f;filelist
 :Access Public Instance

 filelist←1 0(⎕NINFO ⎕OPT 1)wildcardfilename
 files←filelist[;1]
 certs←⍬

 :For f :In files
     certs,←ReadCertFromFile f
 :EndFor
