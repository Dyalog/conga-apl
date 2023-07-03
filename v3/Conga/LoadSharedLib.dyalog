 r←LoadSharedLib path;unicode;mac;win;bit64;filename;dirsep;z;dllname;s
 :If 3=⎕NC'⍙InitRPC' ⍝ Library already loaded
     r←0 'Conga already loaded'
 :Else ⍝ Not loaded
     {}⎕WA  ⍝ If there is garbage holding the shared library loaded get rid of it
     unicode←⊃80=⎕DR' '
     mac win bit64←∨/¨'Mac' 'Windows' '64'⍷¨⊂1⊃'.'⎕WG'APLVersion'
     ⍝ Dllname is Conga[x64 if 64-bit][Uni if Unicode][.so if UNIX]
     filename←'conga',DllVer,(⊃'__CU'[⎕IO+unicode]),(⊃('32' '64')[⎕IO+bit64]),⊃('' '.so' '.dylib')[⎕IO+mac+~win]
     dirsep←'/\'[⎕IO+win]
     LibPath←DefPath path
     s←''

     :Trap 0
         ⍙naedfns←⍬
         dllname←'I4 "',LibPath,filename,'"|'

         ⍙naedfns,←⊂'⍙CallR'⎕NA dllname,'Call <0T1 <0T1 =Z <U',⍕4×1+bit64   ⍝ No left arg
         ⍙naedfns,←⊂'⍙CallRL'⎕NA dllname,'Call <0T1 <0T1 =Z <Z'             ⍝ Left input
         ⍙naedfns,←⊂'⍙CallRnt'⎕NA dllname,'Call <0T1 <0T1 =Z <U',⍕4×1+bit64  ⍝ No left arg
         ⍙naedfns,←⊂'⍙CallRLR'⎕NA dllname,'Call1& <0T1 <0T1 =Z >Z'           ⍝ Left output
         ⍙naedfns,←⊂'KickStart'⎕NA dllname,'KickStart& <0T1'
         ⍙naedfns,←⊂'SetXlate'⎕NA dllname,'SetXLate <0T <0T <C[256] <C[256]'
         ⍙naedfns,←⊂'GetXlate'⎕NA dllname,'GetXLate <0T <0T >C[256] >C[256]'
         :Trap 0
             ⍙naedfns,←⊂'⍙Version'⎕NA dllname,'Version >I4[3]'
             ⍙naedfns,←⊂⎕NA'F8',2↓dllname,'Micros'
             ⍙naedfns,←⊂⎕NA dllname,'cflate  I4  =P  <U1[] =U4 >U1[] =U4 I4'
             ⍙naedfns,←⊂⎕NA dllname,'ErrorText I4 >0T1 <I4 >0T1 <I4'
         :EndTrap
         ⍙naedfns,←⊂'⍙InitRPC'⎕NA dllname,'Init <0T1 <0T1'
     :EndTrap

     :If 3=⎕NC'⍙InitRPC'
         r←0('Conga loaded from: ',LibPath,filename)
     :Else
         :If 0≠≢⍙naedfns ⋄ z←⎕EX¨⍙naedfns ⋄ :EndIf
         r←1000('Unable to find DLL "',filename,'"')((0≠≢LibPath)/'Tried: ',,⍕LibPath)
     :EndIf
 :EndIf
