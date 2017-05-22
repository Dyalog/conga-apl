 cert←ReadCert relfilename;certpath;fn
 ss←{⎕ML←1                           ⍝ Approx alternative to xutils' ss.
     srce find repl←,¨⍵              ⍝ source, find and replace vectors.
     mask←find⍷srce                  ⍝ mask of matching strings.
     prem←(⍴find)↑1                  ⍝ leading pre-mask.
     cvex←(prem,mask)⊂find,srce      ⍝ partitioned at find points.
     (⍴repl)↓∊{repl,(⍴find)↓⍵}¨cvex  ⍝ collected with replacements.
 }
 certpath←CertPath
 fn←certpath,relfilename,'-cert.pem'
 cert←⊃##.DRC.X509Cert.ReadCertFromFile fn
 cert.KeyOrigin←{(1⊃⍵)(ss(2⊃⍵)'-cert' '-key')}cert.CertOrigin
