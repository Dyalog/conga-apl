:Namespace DRC
⍝ DRC for Conga 3.0 and Dyalog APL versions starting with 16.0

    RootName←'DRC'
    
    check←{
          0≠⊃⍵:('DLL Error: ',,⍕⍵)⎕SIGNAL 999
          0≠⊃2⊃⍵:(Error⊃2⊃⍵),1↓2⊃⍵
          2=⍴⍵:(⎕IO+1)⊃⍵
          1↓⍵}
    
    ∇ p←DefPath p;ds;trunkds;addds;isWin;subst
      subst←{((1⊃⍺),⍵)[1+(⍳⍴⍵)×⍵≠2⊃⍺]}
      isWin←{'Window'{⍺≡(⍴⍺)↑⍵}⎕IO⊃'.'⎕WG'aplversion'}
      ds←'/\'[⎕IO+isWin ⍬]
      trunkds←{⍺←ds ⋄ (1-(⌽⍵)⍳⍺)↓⍵}
      addds←{⍺←ds ⋄ ⍵,(⍺≠¯1↑⍵)/⍺}
     
      :Select p
      :Case '⍵' ⍝ means path of the ws
          p←trunkds ⎕WSID
      :Case '↓' ⍝ means current path
          :If isWin ⍬
              p←addds⊃⎕CMD'cd'
          :Else
              p←addds⊃⎕CMD'pwd'
          :EndIf
      :Case '⍺' ⍝ means the path of the interpreter
          p←trunkds ⎕IO⊃+2 ⎕NQ'.' 'GetCommandlineArgs'
      :Case ''
          p←p
      :Else
          p←addds((isWin ⍬)⌽'/\')subst p
      :EndSelect
     
    ∇

    ∇ r←arg getargix(args list);mn;mp;ixs;nix
      ⍝ Finds argumenst in a list of positional and named arguments
     
      ixs←list⍳ncase args
     
      nix←+/∧\2>|≡¨arg ⍝ identify where the named arguments starts
     
      r←(⍴ixs)⍴1+⍴list      ⍝ prefill the result
      mp←ixs≤nix
      :If ∨/mp        ⍝ for positionals args
          (mp/r)←mp/ixs
      :EndIf
      mn←(~mp)∧ixs<1+⍴list
      :If ∨/mn       ⍝ for named args.
      :AndIf nix<⍴arg
          (mn/r)←-nix+(1⊃¨nix↓arg)⍳ncase mn/args
     
      :EndIf
    ∇

    ∇ r←a getarg ixs;m
      m←0<ixs
      r←(⍴ixs)⍴⍬
      :If ∨/m
          (m/r)←a[m/ixs]
      :EndIf
      m←~m
      :If ∨/m
          (m/r)←2⊃¨a[-m/ixs]
      :EndIf
    ∇

    ∇ r←reparg a;arglist;ix;cert
      arglist←'Name' 'Address' 'Port' 'Mode' 'BufferSize' 'SSLValidation' 'EOM' 'IgnoreCase' 'Protocol' 'PublicCertData' 'PrivateKeyFile' 'PrivateKeyPass' 'PublicCertFile' 'PublicCertPass' 'PrivateKeyData' 'X509'
      ix←a getargix('X509' 'PublicCertData' 'PrivateKeyFile' 'PrivateKeyPass' 'PublicCertFile' 'PublicCertPass' 'PrivateKeyData')(arglist)
      :If (⍴a)≥|⊃ix
          cert←a getarg⊃ix
     
          :If 9=⎕NC'cert'
          ⍝:AndIf 0<cert.IsCert   ⍝Accept empty certificates.
              a←(~(⍳⍴a)∊|ix)/a
              a,←cert.AsArg
          :EndIf
      :EndIf
      r←a
    ∇

    ∇ r←Close con;_
     ⍝ arg:  Connection id
      r←check ⍙CallR RootName'AClose'con 0
      :If ((,'.')≡,con)∧(0<⎕NC'⍙naedfns')  ⍝ Close root and unload share lib
          _←⎕EX¨⍙naedfns
          _←⎕EX'⍙naedfns'
      :EndIf
    ∇

    ∇ v←Version;version
     
      :Trap 0
          version←{no←(¯1+(⍵∊⎕D)⍳1)↓⍵ ⋄ 3↑⊃¨2⊃¨⎕VFI¨'.'{1↓¨(⍺=⍵)⊂⍵}'.',no}
          v←version 2 1 4⊃Tree'.'
      :Else
          'Try DRC.Init '⎕SIGNAL 16
          v←0 0 0
      :EndTrap
    ∇

    ∇ r←Describe name;enum;state;type
      ⍝ Return description of object
     
      :If 0=1↑r←Tree name
          r←2 1⊃r
          enum←{2↓¨(⍵=1↑⍵)⊂⍵}
          state←enum',SNew,SIncoming,SRootInit,SListen,SConnected,SAPL,SReadyToSend,SSending,SProcessing,SReadyToRecv,SReceiving,SFinished,SMarkedForDeletion,SError,SDoNotChange,SShutdown,SSocketClosed,SAPLLast,SSSL,SSent,SListenPaused'
          type←enum',TRoot,TServer,TClient,TConnection,TCommand,TMessage'
     
          :If 0=2⊃r ⍝ Root
              r←0('[DRC]'(4⊃r)('State=',(1+3⊃r)⊃state)('Threads=',⍕5⊃r))
          :Else     ⍝ Something else
              (2⊃r)←(1+2⊃r)⊃type
              (3⊃r)←(1+3⊃r)⊃state
              r←0 r
          :EndIf
      :EndIf
    ∇

    ∇ r←Error no;i
      ⍝ Return error text
     
      :If (1↑⍴ErrorTable)≥i←ErrorTable[;1]⍳no
          r←ErrorTable[i;]
      :ElseIf (no<1000)∨no>10000
          r←no('OS Error #',⍕no)'Consult TCP documentation'
      :Else
          r←no'? Unknown Error' ''
      :EndIf
    ∇

    ∇ r←Exists root
     ⍝ 1 if a Conga object name is in use
      r←0≡⊃⊃Tree root
    ∇

    ∇ r←GetProp a
      ⍝ Name Prop
      ⍝ Root: DefaultProtocol  PropList  ReadyStrategy  RootCertDir
      ⍝ Server: OwnCert  LocalAddr  PropList
      ⍝ Connection: OwnCert  PeerCert  LocalAddr  PeerAddr  PropList
     
      r←check ⍙CallR RootName'AGetProp'a 0
     
      :If 0=⊃r
      :AndIf ∨/'OwnCert' 'PeerCert'∊a[2]
      :AndIf 0<⊃⍴2⊃r
          (2⊃r)←SetParents ⎕NEW¨X509Cert,∘⊂¨2⊃r
      :EndIf
    ∇

    ∇ r←Certs a
      ⍝ Return certificates. Arguments can be:
      ⍝ 'ListMSStores': return list of Microsoft Certificate Stores
      ⍝ 'MSStore' storename Issuer subject details api password: Certs in a named store
      r←check ⍙CallR RootName'ACerts'a 0
    ∇

    ∇ r←InitRawIWA dllname
      ⍙naedfns,←⊂'IWAStart'⎕NA dllname,'IFAuthClientStart >P <0T1 <0T1'
      ⍙naedfns,←⊂'IWAGet'⎕NA dllname,'IFAuthGetToken P >U4 =U4 >C1[]'
      ⍙naedfns,←⊂'IWASet'⎕NA dllname,'IFAuthSetToken P U4  <C1[]'
      ⍙naedfns,←⊂'IWAFree'⎕NA dllname,'IFAuthFree P '
      ⍙naedfns,←⊂'IWAName'⎕NA dllname,'IFAuthName P >0T1'
      r←0
    ∇

    ∇ r←{reset}Init path;dllname;z;Path;ZSetHeader;unicode;bit64;filename;Paths;win;s;dirsep;mac;rootarg
     ⍝ Initialize Conga v3.0.0
     
      :If 2=⎕NC'reset' ⋄ :AndIf 2=⎕NC'⍙naedfns' ⋄ :AndIf reset=¯1    ⍝ Reload the dll
          {}Close'.'
      :EndIf
     
      :If 3=⎕NC'⍙InitRPC' ⍝ Library already loaded
          r←0 'Conga already loaded'
          :If 2=⎕NC'reset' ⋄ :AndIf reset=1
              {}Close¨Names'.'
              r←0 'Conga reset'
          :EndIf
     
      :Else ⍝ Not loaded
          {}⎕WA  ⍝ If there is garbage holding the shared library loaded get rid of it
          unicode←⊃80=⎕DR' '
          mac win bit64←∨/¨'Mac' 'Windows' '64'⍷¨⊂1⊃'.'⎕WG'APLVersion'
     ⍝ Dllname is Conga[x64 if 64-bit][Uni if Unicode][.so if UNIX]
          filename←'conga30',(⊃'__CU'[⎕IO+unicode]),(⊃('32' '64')[⎕IO+bit64]),⊃('' '.so' '.dylib')[⎕IO+mac+~win]
          dirsep←'/\'[⎕IO+win]
          :If win
             ⍝ if path is empty windows finds the .dll next to the .exe
              Path←DefPath path
          :Else
          ⍝ if unix/linux rely on the setting of LIBPATH/LD_LIBRARY_PATH
              Path←''
          :EndIf
          s←''
     
          :Trap 0
              ⍙naedfns←⍬
              dllname←'I4 "',Path,filename,'"|'
              :If win∧0<⍴Path
                  :Trap 0
                      {}'cheat'⎕NA'I4 "',Path,(7↑filename),'ssl',((⎕IO+bit64)⊃'32' '64'),'"|congasslversion >0T1 I4'
                  :EndTrap
              :EndIf
              :Trap 0
                  ⍙naedfns,←⊂'⍙Version'⎕NA dllname,'Version'
              :Else
                  ⎕FX'r←⍙Version' 'r←20700000'
              :EndTrap
              
              ⍙naedfns,←⊂'⍙CallR'⎕NA dllname,'Call& <0T1 <0T1 =Z <U',⍕4×1+bit64  ⍝ No left arg
              :If 0<⎕NC'cheat'
                  {}⎕EX'cheat'
              :EndIf
              ⍙naedfns,←⊂'⍙CallRL'⎕NA dllname,'Call& <0T1 <0T1 =Z <Z'  ⍝ Left input
              ⍙naedfns,←⊂'⍙CallRnt'⎕NA dllname,'Call <0T1 <0T1 =Z <U',⍕4×1+bit64  ⍝ No left arg
              ⍙naedfns,←⊂'⍙CallRLR'⎕NA dllname,'Call1& <0T1 <0T1 =Z >Z' ⍝ Left output
              ⍙naedfns,←⊂'KickStart'⎕NA dllname,'KickStart& <0T1'
              ⍙naedfns,←⊂'SetXlate'⎕NA dllname,'SetXLate <0T <0T <C[256] <C[256]'
              ⍙naedfns,←⊂'GetXlate'⎕NA dllname,'GetXLate <0T <0T >C[256] >C[256]'
              :Trap 0
                  ⍙naedfns,←⊂⎕NA'F8',2↓dllname,'Micros'
                  ⍙naedfns,←⊂⎕NA dllname,'cflate  I4  =P  <U1[] =U4 >U1[] =U4 I4'
              :EndTrap
              :Trap 0
                  z←InitRawIWA dllname
              :EndTrap
              ⍙naedfns,←⊂'⍙InitRPC'⎕NA dllname,'Init <0T1 <0T1'
     
              z←⍙InitRPC RootName Path
              :If 1091=⊃z
                  :If ~unicode
                      s←SetXlate DefaultXlate
                  :EndIf
                  s←' using default translation aplunicd.ini not present'
                  r←,0
              :Else
                  r←Error z
              :EndIf
     
          :EndTrap
     
     
          :If 3=⎕NC'⍙InitRPC'
     
              :If 0=⊃r
                  r←0('Conga loaded from: ',Path,filename,s)
                  X509Cert.LDRC←⎕THIS            ⍝ Set LDRC so X509Cert can find DRC
                  flate.LDRC←⎕THIS
              :Else
                  z←⎕EX¨⍙naedfns
              :EndIf
          :Else
              r←1000('Unable to find DLL "',filename,'"')('Tried: ',,⍕Path)
          :EndIf
      :EndIf
    ∇

    ∇ r←Names root
     ⍝ Return list of top level names
     
      :If 0=1↑r←Tree root
          r←{0=⍴⍵:⍬ ⋄ (⊂1 1)⊃¨⍵}2 2⊃r
      :EndIf
    ∇

    ∇ r←Progress a;cmd;data;⎕IO
     ⍝ cmd data
      ⎕IO←1 ⋄ r←check ⍙CallRL RootName'ARespondZ'(a[1],0)(2⊃a)
    ∇

    ∇ r←Respond a;⎕IO
     ⍝  cmd  data
      ⎕IO←1 ⋄ r←check ⍙CallRL RootName'ARespondZ'(a[1],1)(2⊃a)
    ∇


    ∇ r←SetProp a
      ⍝ Name Prop Value
      ⍝ '.' 'CertRootDir' 'c:\certfiles\ca'
     
      r←check ⍙CallR RootName'ASetProp'a 0
    ∇

    ∇ r←SetRelay a
      ⍝ Name Prop Value
      ⍝ 'RelayFrom' 'RelayTo' [blocksize=16384 [oneway=0]]
     
      r←check ⍙CallR RootName'ASetRelay'a 0
    ∇

    ∇ r←SetPropnt a
      ⍝ Name Prop Value
      ⍝ '.' 'CertRootDir' 'c:\certfiles\ca'
     
      r←check ⍙CallRnt RootName'ASetProp'a 0
    ∇

    ∇ r←Tree a
      ⍝ Name
      r←check ⍙CallR RootName'ATree'a 0
    ∇

    ∇ r←isWindows;n;s
      n←⍴s←'Windows'
      r←s≡n↑⎕IO⊃'.'⎕WG'aplversion'
    ∇
    ∇ pid←WinPid;gcp
      _←'gcp'⎕NA'I kernel32|GetCurrentProcessId'
      pid←gcp
    ∇
    ∇ pid←NixPid
      pid←2⊃⎕VFI ⎕SH'echo $PPID'
    ∇

      GetPid←{
          isWindows:WinPid
          NixPid
      }
    
    ∇ Stat arg;m;NewTS;⎕IO;fopen;loginfo
      :Trap 0
          fopen←{                              ⍝ handle on null file.
              0::⎕SIGNAL ⎕EN                  ⍝ signal error to caller.
              22::⍵ ⎕FCREATE 0                ⍝ ~exists: create.
              ⍵ ⎕FSTIE 0                      ⍝  exists: tie.
          }
          loginfo←{_←(⍙PID ⍙Stat ⎕TS(Micros)(⍙Cnts)(Tree'.'))⎕FAPPEND tie←fopen ⍵ ⋄ ⎕FUNTIE tie}
          ⎕IO←1
          NewTS←⌊Micros÷300000000
      ⍝NewTS←5↑⎕TS
          :If ∨/0=⎕NC'⍙LastTS' '⍙Cnts' '⍙MaxCnts' '⍙Items'
              ⍙Items←'Error' 'Receive' 'Progress' 'Connect' 'Block' 'BlockLast' 'Sent'
              ⍙LastTS←NewTS
              ⍙MaxCnts←⍙Cnts←(2+⍴⍙Items)⍴0
              ⍙PID←GetPid ⍬
              :If 0=⎕NC'⍙Stat'
                  ⍙Stat←1
              :EndIf
          :EndIf
          :If ⍙LastTS≡NewTS
              ⍙Cnts[⍙Items⍳(4↑arg)[2]]+←1
              ⍙Cnts[2+⍴⍙Items]+←{⎕SIZE'⍵'}(4↑arg)[4]
          :Else
              loginfo'congastat.dcf'
              ⍙MaxCnts⌈←⍙Cnts
              ⍙LastTS←NewTS
              ⍙Cnts←(2+⍴⍙Items)⍴0
     
     ⍝ Save
          :EndIf
      :EndTrap
    ∇

    ∇ r←Wait a;⎕IO
     ⍝ Name [timeout]
     ⍝ returns: err Obj Evt Data
      ⎕IO←1
      :If (1≥≡a)∧∨/80 82∊⎕DR a
          a←(a)1000
      :EndIf
      →(0≠⊃⊃r←check ⍙CallRLR RootName'AWaitZ'a 0)⍴0
      ⍝:If 0=⊃⊃r ⋄ timing,←⊂(4⊃4↑⊃r),Micros ⋄ :EndIf
      r←(3↑⊃r),r[2]
      :If 0<⎕NC'⍙Stat' ⋄ Stat r ⋄ :EndIf
     
    ∇

    ∇ r←Waitt a;⎕IO
     ⍝ Name [timeout]
     ⍝ returns: err Obj Evt Data
      ⎕IO←1
      :If (1≥≡a)∧∨/80 82∊⎕DR a
          a←(a)1000
      :EndIf
      →(0≠⊃⊃r←check ⍙CallRLR RootName'AWaitZ'a 0)⍴0
      ⍝:If 0=⊃⊃r ⋄ timing,←⊂(4⊃4↑⊃r),Micros ⋄ :EndIf
      r←(3↑⊃r),r[2],⊂(4⊃4↑⊃r),Micros
    ∇



    ∇ r←DefaultXlate;⎕IO;x1;x2
    ⍝ Retrieve Default translate tables for Dyalog APL
     
      ⎕IO←0
      x1←⎕NXLATE 0
      x2←x1⍳⍳⍴x1
     
      r←'DYA_IN' 'ASCII'(⎕AV[x1])(⎕AV[x2])
    ∇

    ∇ r←Srv a;ix;arglist;cert
⍝ Create a Server
⍝    "Name",            // string
⍝    "Address",         // string
⍝    "Port",            // Integer or service name
⍝    "Mode",            // command,raw,text
⍝    "BufferSize",
⍝    "SSLValidation",   // integer
⍝    "EOM",             // Vector of stop strings
⍝    "IgnoreCase",      // boolean
⍝    "Protocol",        // ipv4,ipv6
⍝    "PublicCertData",
⍝    "PrivateKeyFile",
⍝    "PrivateKeyPass",
⍝    "PublicCertFile",
⍝    "PublicCertPass",
⍝    "PrivateKeyData'
     
      a←reparg a
      r←check ⍙CallR RootName'ASrv'a 0
    ∇
    ∇ r←Clt a
⍝ Create a Client
⍝    "Name",            // string
⍝    "Address",         // string
⍝    "Port",            // Integer or service name
⍝    "Mode",            // command,raw,text
⍝    "BufferSize",
⍝    "SSLValidation",   // integer
⍝    "EOM",             // Vector of stop strings
⍝    "IgnoreCase",      // boolean
⍝    "Protocol",        // ipv4,ipv6
⍝    "PublicCertData",
⍝    "PrivateKeyFile",
⍝    "PrivateKeyPass",
⍝    "PublicCertFile",
⍝    "PublicCertPass",
⍝    "PrivateKeyData'
     
      a←reparg a
      r←check ⍙CallR RootName'AClt'a 0
    ∇

    ∇ r←Send a;⎕IO
     ⍝ Name data {CloseConnection}
      ⎕IO←1
      r←check ⍙CallRL RootName'ASendZ'((a,0)[1 3])(2⊃a)
    ∇

    ∇ vc←SetParents vc;ix;m
      ix←vc.Elements.Subject⍳vc.Elements.Issuer  ⍝ find the index of the parents
      m←(ix≤⍴vc)∧ix≠⍳⍴ix                         ⍝ Mask the found items with parents and not selfsigned
      (m/vc).ParentCert←vc[m/ix]                 ⍝ Set the parent
      vc←vc~vc.ParentCert                        ⍝ remove all parents from list
    ∇

    ∇ r←ServerAuth con;tok;rr;kp;err;rc;ct;ck;ce
      err←SetProp con'IWA'('NTLM' '')
      :Repeat
          rr←Wait con 1000
          :If 0=⊃rr
              (ce ck ct)←3↑4⊃rr
              :If 0<⍴ct
              :AndIf ce=0
                  err←SetProp con'Token'(ct)
                  kp tok←2⊃GetProp con'Token'
                  rc←Respond(2⊃rr)(err kp tok)
              :Else
                  rc←Respond(2⊃rr)(0 0 ⍬)
                  kp←0
              :EndIf
          :Else
              kp←1
          :EndIf
      :Until (0=kp)∨(ck=0)
      r←GetProp con'IWA'
    ∇

    ∇ r←ClientAuth arg;con;tok;cmd;rc;rr;kp;err;se;sk;st
      :If 1=≡arg
          arg←,⊂arg
      :EndIf
      con←1⊃arg
      err←SetProp con'IWA'('NTLM' '',1↓arg)
      :Repeat
          kp tok←2⊃GetProp con'Token'
          rc cmd←Send con(err kp tok)
          rr←Wait cmd 10000
          :If 0=⊃rr
              (se sk st)←3↑4⊃rr
     
              :If 0<⍴st
              :AndIf se=0
                  err←SetProp con'Token'(st)
              :Else
                  kp←0
              :EndIf
          :EndIf
      :Until (0=kp)∨(sk=0)
      r←GetProp con'IWA'
    ∇


    ∇ r←IWAAuth con;tok;cmd;rc;rr;kp
      err HANDLE←IWAStart 1 'NTLM' ''
      :Repeat
          err kp len tok←IWAGet HANDLE 1 200 200
          tok←len↑tok
          rc cmd←Send con tok
          rr←Wait cmd 10000
          tok←4⊃rr
          IWASet HANDLE(⍴tok)tok
      :Until 0=kp
      r←IWAName HANDLE 100
     ⍝ r←GetProp con'IWA'
    ∇
    ∇ r←toAv a;⎕IO
      ⎕IO←0
      r←⎕AV[((⎕NXLATE 0)⍳⍳256)[⎕AV⍳a]]
    ∇
    ∇ r←toAnsi a;⎕IO
      ⎕IO←0
      r←⎕AV[(⎕NXLATE 0)[⎕AV⍳a]]
    ∇

    ∇ r←IWAAuthVBtxt con;tok;rr;kp;header;size;tokout
      SetProp con'IWA'('NTLM' '')
      :Repeat
          header←''
          size←0
          tok←''
          :Repeat
              rr←Wait con 1000
              :If 0=⊃rr
                  :If size>0
                      tok,←4⊃rr
                  :Else
                      :If 16>⍴header
                          header,←(16-⍴header)↑4⊃rr
                      :EndIf
                      :If 16=⍴header         ⍝ header form '<IWA     nnnnn>'
                      :AndIf '<'=1↑header
                      :AndIf '>'=¯1↑header
                          size←2⊃⎕VFI 5↓15↑header
                          tok←16↓4⊃rr
     
                      :EndIf
                  :EndIf
              :EndIf
          :Until (size>0)∧size=⍴tok
          :If 0=⊃rr
              SetProp con'Token'(toAnsi tok)
              kp tokout←2⊃GetProp con'Token'
              :If kp=1
                  Send con('<IWA',(¯11↑(⍕⍴tokout)),'>')
                  Send con(toAv tokout)
              :Else
                  r←GetProp con'IWA'
                  Send con('<IWAc',(¯10↑(⍕⍴2⊃r)),'>')
                  Send con(2⊃r)
              :EndIf
          :Else
              kp←1
          :EndIf
      :Until 0=kp     
    ∇

:EndNamespace

