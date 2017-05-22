:Namespace DRCv1
    ∇ r←Client a
      ⍝ Name Address Port [mode [maxsize [(Stop CutRight IgnoreCase)]]]
      ⍝ Mode: Command Raw Text
     
      a←a,(⍴a)↓'' '' 0 'Command' 100000
      a←'Name' 'Address' 'Port' 'Mode' 'BufferSize'{⍺ ⍵}¨a
     
      r←check ⍙CallR'AClt'a 0
    ∇
    
    ∇ r←SecureClient a
      ⍝ Name Address Port publicPemFile privatePemFile flags [mode [maxsize [(Stop CutRight IgnoreCase)]]]
      ⍝ Mode: Command Raw Text
     
      a←a,(⍴a)↓'' '' 0 '' '' 0 'Command' 100000
      a←'Name' 'Address' 'Port' 'PublicCert' 'PrivateCert' 'SSLValidation' 'Mode' 'BufferSize'{⍺ ⍵}¨a
     
      r←check ⍙CallR'AClt'a 0
    ∇
    
    ∇ r←SecureServer a
      ⍝ Server arguments
      ⍝ Name port publicPemFile privatePemFile flags [ mode  [maxsize [ (Stop CutRight IgnoreCase)]]]
     
      a←a,(⍴a)↓'' 0 '' '' 0 'Command' 100000
      a←'Name' 'Port' 'PublicCert' 'PrivateCert' 'SSLValidation' 'Mode' 'BufferSize'{⍺ ⍵}¨a
     
      r←check ⍙CallR'ASrv'a 0
    ∇
    
    
    ∇ r←Server a
      ⍝ Server arguments
      ⍝ Name port [ mode  [maxsize [ (Stop CutRight IgnoreCase)]]]
     
      a←a,(⍴a)↓'' 0 'Command' 100000
      a←'Name' 'Port' 'Mode' 'BufferSize'{⍺ ⍵}¨a
     
      r←check ⍙CallR'ASrv'a 0
    ∇
    
:EndNamespace 