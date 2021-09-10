 r←test_basic dummy;z;clt;srv;rootprops;ret;Port;Host;Clt;Srv;mode;maxwait;modes;propsmode;modeix;con;res;port
⍝∇Test: group=Basic
⍝ Test fundamental Conga Certificate functionality

 Port←0 ⋄ Host←'localhost'
 Srv←'' ⋄ Clt←''
 maxwait←5000

 :If 3 Check≢ret←iConga.Version
     →fail Because'Version failed',,⍕ret ⋄ :EndIf

 :If 3 Check 2⊃⍴2⊃ret←iConga.GetProp'.' 'ipv4addrs'
     →fail Because'IPV4Addrs failed',,⍕ret ⋄ :EndIf

 :If 4 Check 2⊃⍴↑2⊃ret←iConga.GetProp'.' 'TCPLookup' 'localhost' 80
     →fail Because'TCPLookup failed :',,⍕ret ⋄ :EndIf

 :If 645 Check ⎕DR ret←iConga.Micros
     →fail Because'Micros not floating point',⍕ret ⋄ :EndIf
 modes←'Text' 'BlkText' 'Command' 'Http'

 rootprops←'Certificates' 'CompLevel' 'DecodeCert' 'ErrorText' 'HttpDate' 'PropList' 'Protocol' 'ReadyStrategy' 'RootCertDir' 'Stores' 'TCPLookup' 'EventMode'
 propsmode←(≢modes)2⍴⍬

 propsmode[1;1]←⊂'CompLevel' 'ConnectionOnly' 'Hostname' 'LocalAddr' 'KeepAlive' 'Options' 'OwnCert' 'Pause' 'PropList'
 propsmode[1;2]←⊂'CompLevel' 'LocalAddr' 'Magic' 'Options' 'OwnCert' 'PeerAddr' 'PeerCert' 'PropList'
 propsmode[2;]←propsmode[1;]
 propsmode[3;]←propsmode[1;]
 propsmode[4;]←propsmode[1;] ⍝ I think this is wrong

 :If 0 rootprops Check ret←iConga.GetProp'.' 'PropList'
     →fail Because'Root properties ',,⍕ret ⋄ :EndIf

 :If 0 Check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail Because'Set EventMode to 0 failed: ',,⍕ret ⋄ :EndIf

 :For modeix :In ⍳≢modes
     :If 0 Check⊃ret←NewSrv Srv''Port(modeix⊃modes)
         →fail Because'Srv failed: ',,⍕ret ⋄ :EndIf
     srv←2⊃ret
     port←3⊃ret
     :If 0 Check⊃ret←iConga.Clt Clt Host port(modeix⊃modes)
         →fail Because'Clt failed: ',,⍕ret ⋄ :EndIf
     clt←2⊃ret
     :If (0 'Connect' 0)Check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
         →fail Because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf
     con←2⊃ret
     :If 0(⊃propsmode[modeix;1])Check ret←iConga.GetProp srv'PropList'
         →fail Because'Srv properties for ',(modeix⊃modes),' failed ',,⍕ret ⋄ :EndIf

     :If 0(⊃propsmode[modeix;2])Check ret←iConga.GetProp clt'PropList'
         →fail Because'Clt properties for ',(modeix⊃modes),' failed ',,⍕ret ⋄ :EndIf

     :If 0(⊃propsmode[modeix;2])Check ret←iConga.GetProp con'PropList'
         →fail Because'Con properties for ',(modeix⊃modes),' failed ',,⍕ret ⋄ :EndIf

     :If 0 Check⊃ret←iConga.Close clt
         →fail Because'Clt close failed: ',,⍕ret ⋄ :EndIf
     :If 0 Check⊃res←iConga.Wait srv maxwait
         →fail Because'Did not get Closed event from Srv Wait: ',,⍕res ⋄ :EndIf
     :If 0 Check⊃ret←iConga.Close srv
         →fail Because'Srv close failed: ',,⍕ret ⋄ :EndIf
     ⎕DL 1  ⍝ give it a moment so that the port if free indeed (when we go into the next round of our loop)
 :EndFor

 r←''
 →0

fail:
 ⍝CongaTrace 0 0
⍝ r←'with protocol="',prot,'", secure=',(⍕secure),': ',r
 :If 2=⎕NC'clt'
     z←iConga.Close clt ⋄ :EndIf
 {}iConga.Wait'.' 0
 :If 2=⎕NC'srv'
     z←iConga.Close srv ⋄ :EndIf

 {}iConga.Wait'.' 0
