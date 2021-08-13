﻿:Class LIB
⍝ NB instances are always created as siblings of the Conga namespace

    :Field Public LibPath
    :Field Public RootName
    :Field Public WsAutoUpgrade
    :Field Public RawAsByte
    :Field Public DecodeHttp
    :Field Public RawAsInt


      check←{
          0≠⊃⍵:('DLL Error: ',,⍕⍵)⎕SIGNAL 999  ⍝ return code from Call non zero
          3≠10|⎕DR⊃2⊃⍵:('DLL result Error: ',,⍕⍵)⎕SIGNAL 999  ⍝ first element of Z is not numeric we expect errorcode
          0≠⊃2⊃⍵:(Error⊃2⊃⍵),1↓2⊃⍵             ⍝ first element of Z is non zero, Error
          2=⍴⍵:(⎕IO+1)⊃⍵
          1↓⍵
      }


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

    ∇ r←bit2problem a      ⍝ returned by DRC.Clt in case secure connection fails with error 1202
      r←a{(((⍴⍵)/2)⊤⍺)/⍵}'' 'CERT_INVALID' '' '' 'REVOKED' 'SIGNER_NOT_FOUND' 'SIGNER_NOT_CA' 'INSECURE_ALGORITHM' 'NOT_ACTIVATED' 'CERT_EXPIRED' 'SIGNATURE_FAILURE' 'REVOCATION_DATA_SUPERSEDED' '' 'UNEXPECTED_OWNER' 'REVOCATION_DATA_ISSUED_IN_FUTURE' 'SIGNER_CONSTRAINTS_FAILURE' 'MISMATCH'
    ∇

    ∇ r←X509Cert
      :Access Public Instance
      r←##.Conga.X509Cert
    ∇

    ∇ vc←SetParents vc;ix;m
      :Access Public Instance
      ix←vc.Elements.Subject⍳vc.Elements.Issuer  ⍝ find the index of the parents
      :If ∨/m←(ix≤⍴vc)∧ix≠⍳⍴ix                   ⍝ Mask the found items with parents and not selfsigned
          (m/vc).ParentCert←vc[m/ix]             ⍝ Set the parent
      :EndIf                                     ⍝ NB the :If prevents creation of an empty cert to allow above line to work
      vc←vc~vc.ParentCert                        ⍝ remove all parents from list
    ∇

    ∇ InitInstance;z;s
      :Access public
      :If 3=##.Conga.⎕NC'⍙InitRPC'
          z←##.Conga.⍙InitRPC RootName LibPath
          :Select ⊃z
          :Case 0
              :If 80≠⎕DR' '
                  s←##.Conga.(SetXlate DefaultXlate)
              :EndIf
          :Else
              (,⍕Error z)⎕SIGNAL 999
          :EndSelect
      :EndIf
    ∇

    ∇ MakeN arg;rootname;z;s
      :Access Public
      :Implements Constructor
      WsAutoUpgrade←1
      RawAsByte←2
      DecodeHttp←4
      RawAsInt←8
      :Trap 0
          lcase←0∘(819⌶)
          z←lcase'A' ⍝ Try to use it
      :Else
          lowerAlphabet←'abcdefghijklmnopqrstuvwxyzáâãçèêëìíîïðòóôõùúûýàäåæéñöøü'
          upperAlphabet←'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÂÃÇÈÊËÌÍÎÏÐÒÓÔÕÙÚÛÝÀÄÅÆÉÑÖØÜ'
          fromto←{n←⍴1⊃(t f)←⍺ ⋄ ~∨/b←n≥i←f⍳s←,⍵:s ⋄ (b/s)←t[b/i] ⋄ (⍴⍵)⍴s} ⍝ from-to casing fn
          lc←lowerAlphabet upperAlphabet∘fromto ⍝ :Includable Lower-casification of simple array
          lcase←{2=≡⍵:∇¨⍵ ⋄ lc ⍵}
      :EndTrap
     
      ncase←{(lcase ⍺)⍺⍺(lcase ⍵)} ⍝ case-insensitive operator
     
      (LibPath RootName)←2↑arg
     
      InitInstance
    ∇

    ∇ vc←SetParentCerts vc;ix;m
    ⍝ Set parent certificates
      ix←vc.Elements.Subject⍳vc.Elements.Issuer  ⍝ find the index of the parents
      :If ∨/m←(ix≤⍴vc)∧ix≠⍳⍴ix                   ⍝ Mask the found items with parents and not selfsigned
          (m/vc).ParentCert←vc[m/ix]             ⍝ Set the parent
      :EndIf                                     ⍝ NB the :If prevents creation of an empty cert to allow above line to work
      vc←vc~vc.ParentCert                        ⍝ remove all parents from list
    ∇

    ∇ UnMake
      :Implements Destructor
      :Trap 0
          _←Close'.'
      :EndTrap
    ∇

    ∇ m←Magic arg
      :Access public
      m←(4/256)⊥⎕UCS 4↑arg
    ∇

    ∇ r←Srv a;ix;arglist;cert
      :Access public
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
      r←check ##.Conga.⍙CallR RootName'ASrv'a 0
    ∇

    ∇ r←Send a;⎕IO
      :Access public
     ⍝ Name data {CloseConnection}
      ⎕IO←1
      r←check ##.Conga.⍙CallRL RootName'ASendZ'((a,0)[1 3])(2⊃a)
    ∇

    ∇ r←Clt a
      :Access public
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
      r←check ##.Conga.⍙CallR RootName'AClt'a 0
    ∇

    ∇ r←Close con;_
      :Access Public
     ⍝ arg:  Connection id
     
      r←check ##.Conga.⍙CallR RootName'AClose'con 0
 ⍝     :If ((,'.')≡,con)∧(0<⎕NC'⍙naedfns')  ⍝ Close root and unload share lib
 ⍝         _←⎕EX¨⍙naedfns
 ⍝         _←⎕EX'⍙naedfns'
 ⍝     :EndIf
    ∇

    ∇ r←Certs a
      :Access public
      ⍝ Working with certificates.
      ⍝ ListMSStores
      ⍝ MSStore storename Issuer subject details api password
      ⍝ Folder not implemented
      ⍝ DER  not implemented
      ⍝ PK#12 not implemented
      r←check ##.Conga.⍙CallR RootName'ACerts'a 0
    ∇

    ∇ r←Names root
      :Access public
     ⍝ Return list of top level names
     
      :If 0=1↑r←Tree root
          r←{0=⍴⍵:⍬ ⋄ (⊂1 1)⊃¨⍵}2 2⊃r
      :EndIf
    ∇

    ∇ r←Progress a;cmd;data;⎕IO
      :Access public
     ⍝ cmd data
      ⎕IO←1 ⋄ r←check ##.Conga.⍙CallRL RootName'ARespondZ'(a[1],0)(2⊃a)
    ∇

    ∇ r←Respond a;⎕IO
      :Access public
     ⍝  cmd  data
      ⎕IO←1 ⋄ r←check ##.Conga.⍙CallRL RootName'ARespondZ'(a[1],1)(2⊃a)
    ∇

    ∇ r←SetProp a
      :Access public
      ⍝ Name Prop Value
      ⍝ '.' 'CertRootDir' 'c:\certfiles\ca'
     
      r←check ##.Conga.⍙CallR RootName'ASetProp'a 0
    ∇

    ∇ r←SetRelay a
      :Access public
      ⍝ Name Prop Value
      ⍝ 'RelayFrom' 'RelayTo' [blocksize=16384 [oneway=0]]
     
      r←check ##.Conga.⍙CallR RootName'ASetRelay'a 0
    ∇

    ∇ r←SetPropnt a
      :Access public
      ⍝ Name Prop Value
      ⍝ '.' 'CertRootDir' 'c:\certfiles\ca'
     
      r←check ##.Conga.⍙CallRnt RootName'ASetProp'a 0
    ∇

    ∇ r←Tree a
      :Access public
      ⍝ Name
      r←check ##.Conga.⍙CallR RootName'ATree'a 0
    ∇

    ∇ r←Micros
      :Access public
      r←##.Conga.Micros
    ∇

    ∇ v←Version;version;err
      :Access public
      :Trap 0
          :If 0≠⎕NC'##.Conga.⍙Version'
              (err v)←##.Conga.⍙Version 3
          :Else
              version←{no←(¯1+(⍵∊⎕D)⍳1)↓⍵ ⋄ 3↑⊃¨2⊃¨⎕VFI¨'.'{1↓¨(⍺=⍵)⊂⍵}'.',no}
              v←version 2 1 4⊃Tree'.'
          :EndIf
      :Else
          'Try DRC.Init '⎕SIGNAL 16
          v←0 0 0
      :EndTrap
    ∇

    ∇ r←Describe name;enum;state;type
      :Access public
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

    ∇ r←Exists root
      :Access public
     ⍝ 1 if a Conga object name is in use
      r←0≡⊃⊃Tree root
    ∇

    ∇ r←GetProp a
      :Access public
      ⍝ Name Prop
      ⍝ Root: DefaultProtocol  PropList  ReadyStrategy  RootCertDir
      ⍝ Server: OwnCert  LocalAddr  PropList
      ⍝ Connection: OwnCert  PeerCert  LocalAddr  PeerAddr  PropList
     
      r←check ##.Conga.⍙CallR RootName'AGetProp'a 0
     
      :If 0=⊃r
      :AndIf ∨/'OwnCert' 'PeerCert'∊a[2]
      :AndIf 0<⊃⍴2⊃r
          (2⊃r)←SetParentCerts{##.⎕NEW X509Cert(,⊂⍵)}¨2⊃r
      :EndIf
    ∇

    ∇ r←Error no;i
      :Access public
      ⍝ Return error text
      :If 0≠##.Conga.⎕NC'ErrorText'
          r←##.Conga.ErrorText no 100 100 256 256
      :Else
          r←no'? Unknown Error' ''
      :EndIf
    ∇

    ∇ r←Wait a;⎕IO
      :Access public
     ⍝ Name [timeout]
     ⍝ returns: err Obj Evt Data
      ⎕IO←1
      :If (1≥≡a)∧∨/80 82∊⎕DR a
          a←(a)1000
      :EndIf
      →(0≠⊃⊃r←check ##.Conga.⍙CallRLR RootName'AWaitZ'a 0)⍴0
      ⍝:If 0=⊃⊃r ⋄ timing,←⊂(4⊃4↑⊃r),Micros ⋄ :EndIf
      r←(3↑⊃r),r[2]
      :If 0<⎕NC'⍙Stat' ⋄ Stat r ⋄ :EndIf
     
    ∇

    ∇ r←Waitt a;⎕IO
      :Access public
     ⍝ Name [timeout]
     ⍝ returns: err Obj Evt Data
      ⎕IO←1
      :If (1≥≡a)∧∨/80 82∊⎕DR a
          a←(a)1000
      :EndIf
      →(0≠⊃⊃r←check ##.Conga.⍙CallRLR RootName'AWaitZ'a 0)⍴0
      ⍝:If 0=⊃⊃r ⋄ timing,←⊂(4⊃4↑⊃r),Micros ⋄ :EndIf
      r←(3↑⊃r),r[2],⊂(4⊃4↑⊃r),Micros
    ∇

    ∇ certs←ReadCertFromFile filename;c;base64;tie;size;cert;ixs;ix;d;pc;temp
      :Access Public Instance
     
      certs←⍬
      c←'-----BEGIN X509 CERTIFICATE-----' '-----BEGIN CERTIFICATE-----'
      base64←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
      tie←filename ⎕NTIE 0
      size←⎕NSIZE tie
      cert←⎕NREAD tie 82 size
      ixs←c{⊃,/{(⍳⍴⍵),¨¨⍵}⍺{(⍺⍷⍵)/⍳⍴⍵}¨⊂⍵}cert
      :If 0<⍴ixs
          :For ix :In ixs
              d←((2⊃ix)+⍴⊃c[1⊃ix])↓cert
              d←(¯1+⊃d⍳'-')↑d
              d←(d∊base64)/d
              d←base64 Decode d
              certs,←⎕NEW X509Cert(d('DER'filename))
          :EndFor
      :Else
          cert←⎕NREAD tie 83 size 0
          certs,←⎕NEW X509Cert(cert('DER'filename))
      :EndIf
     
      ⎕NUNTIE tie
      certs←SetParents certs
    ∇

    ∇ certs←ReadCertFromFolder wildcardfilename;files;f;filelist
      :Access Public Instance
     
      filelist←1 0(⎕NINFO ⎕OPT 1)wildcardfilename
      files←filelist[;1]
      certs←⍬
     
      :For f :In files
          certs,←ReadCertFromFile f
      :EndFor
    ∇

    ∇ certs←ReadCertFromStore storename;cs
      :Access Public Instance
     
      cs←Certs(⊂'MSStore'),⊆storename
      :If 0=1⊃cs
      :AndIf 0<⍴2⊃cs
          certs←⎕NEW¨(2⊃cs){X509Cert(⍺ ⍵)}¨⊂'MSStore'(⊃⊆storename)
      :Else
          certs←⍬
      :EndIf
    ∇

    ∇ certs←ReadCertUrls;certurls;list
      :Access Public Instance
     
      certurls←Certs'Urls' ''
      :If 0=1⊃certurls
      :AndIf 0<1⊃⍴2⊃certurls
          certs←{⎕NEW X509Cert((4⊃⍵)('URL'(1⊃⍵))('URL'(2⊃⍵)))}¨↓2⊃certurls
      :Else
          certs←⍬
      :EndIf
    ∇
    ∇ r←ClientAuth arg;con;tok;cmd;rc;rr;kp;err;se;sk;st
    :Access Public Instance
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
    ∇ r←ServerAuth con;tok;rr;kp;err;rc;ct;ck;ce
      :Access Public Instance
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
    ∇ r←base Decode code;ix;bits;size;s
      ix←¯1+base⍳code
     
      bits←,⍉((2⍟⍴base)⍴2)⊤ix
      size←{(⌊(¯1+⍺+⊃⍴⍵)÷⍺),⍺}
     
      s←8 size bits
     
      r←(8⍴2)⊥⍉s⍴(×/s)↑bits
      r←(-0=¯1↑r)↓r
    ∇

      base64←{⎕IO ⎕ML←0 1             ⍝ Base64 encoding and decoding as used in MIME.
     
          chars←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
          bits←{,⍉(⍺⍴2)⊤⍵}                   ⍝ encode each element of ⍵ in ⍺ bits,
                                       ⍝   and catenate them all together
          part←{((⍴⍵)⍴⍺↑1)⊂⍵}                ⍝ partition ⍵ into chunks of length ⍺
     
          0=2|⎕DR ⍵:2∘⊥∘(8∘↑)¨8 part{(-8|⍴⍵)↓⍵}6 bits{(⍵≠64)/⍵}chars⍳⍵
                                       ⍝ decode a string into octets
     
          four←{                             ⍝ use 4 characters to encode either
              8=⍴⍵:'=='∇ ⍵,0 0 0 0           ⍝   1,
              16=⍴⍵:'='∇ ⍵,0 0               ⍝   2
              chars[2∘⊥¨6 part ⍵],⍺          ⍝   or 3 octets of input
          }
          cats←⊃∘(,/)∘((⊂'')∘,)              ⍝ catenate zero or more strings
          cats''∘four¨24 part 8 bits ⍵
      }

    ∇ r←DecodeOptions value;bits;opts;inds;⎕IO
    ⍝ returns the meaning of an Options value
      :Access Public Shared
      ⎕IO←1
      opts←{↑⍵{(⍺⍎⍵)⍵}¨⍵.⎕NL ¯3}Options
      'DOMAIN ERROR: Invalid Options'⎕SIGNAL((,1)≢,value∊0,⍳+/opts[;1])/11
      bits←⌽2*¯1+⍸⌽2⊥⍣¯1⊢value
      inds←opts[;1]⍳bits
      r←1↓∊'+',¨opts[inds;2]
    ∇

    :Namespace Options
        ∇ r←WSAutoUpgrade
        ⍝ value to add to the client or server Options parameter in order to automatically access a WebSocket upgrade request on an HTTP connection
        ⍝ this replaces the use of WSFeatures in Conga versions
          r←1
        ∇

        ∇ r←RawAsByte
        ⍝ value to add to the client or server Options parameter in order return type 83, single byte integer (¯128-127) on a raw or blkraw connection
          r←2
        ∇

        ∇ r←DecodeHttp
        ⍝ value to add to the client or server Options parameter in order to decode HTTP messages on an HTTP connection
        ⍝ this replaces the use of DecodeBuffers in Conga versions prior to v3.3
          r←4
        ∇

        ∇ r←EnableFifo
        ⍝ value to add to server Options parameter in order to enable FIFO mode. This is Conga 3.4.
          r←32
        ∇

        ∇ r←EnableBufferSizeHttp
        ⍝ value to add to the client or server Options parameter to have the BufferSize parameter limit the size of data received by all HTTP mode events
          r←16
        ∇

    :EndNamespace

:EndClass
