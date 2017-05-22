 user←GetUserFromCerts cert;user

 :If 0≠⍴cert
     user←(⊃cert).Formatted.(Subject Issuer)
     ⍝user←'CN'∘{⊃⍵[⍵[;1]⍳⊂⍺;2]}¨cert
     ⍝user←(1⊃user)(1↓,⍕'/',¨1↓user)
 :Else ⋄ user←'UNKNOWN' 'UNKNOWN'
 :EndIf
 user←'User' 'C.A.',[1.5]user
