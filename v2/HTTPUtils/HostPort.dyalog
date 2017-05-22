 r←port HostPort host;z
     ⍝ Split host from port

 :If (⍴host)≥z←host⍳':'
     port←1⊃2⊃⎕VFI z↓host ⋄ host←(z-1)↑host  ⍝ Use :port if found in host name
 :EndIf

 r←host port
