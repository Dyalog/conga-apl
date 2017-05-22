:Namespace WebServer
    stop←1
    HOME←'c:\aplweb\sites\ckk\'
    NL←⎕av[⎕io+3 2]
    
      int←{                       ⍝ Signed from unsigned integer.
          ↑⍵{(⍺|⍵+⍺⍺)-⍵}/2*⍺-0 1
      }
    
      uns←{           ⍝ Unsigned from signed integer.
          (2*⍺)|⍵
      }
    
    ∇ z←FromRaw z;⎕IO
      :If 82=⊃⎕DR' '
          ⎕IO←0
          z←⎕AV[(⎕NXLATE 0)⍳8 uns z]
      :Else
          z←⎕UCS 8 uns z ⍝ 8-but unsigned integers
      :EndIf
    ∇
    
    ∇ r←{DefHome}GetAnswer(CMD BUF);URL;I;Status;Content
     ⍝ Default file handler.
     
     ⍝ Needs to return:
     ⍝  [1] - (charvec) HTTP status code.         This can be 0 to just mean standard success.
     ⍝  [2] - (charvec) Additional HTTP headers.  If none, just set to ''.
     ⍝  [3] - (charvec) HTTP content.             If none, just set to ''.
     
      :If (⊂##.HTTPUtils.lc(I←CMD⍳' ')↑CMD)∊'get ' 'post '
          URL←I↓CMD
          URL←(¯1+URL⍳' ')↑URL
          :If 'http:'≡##.HTTPUtils.lc 5↑URL ⍝ Drop leading server address
              URL←(¯1+(+\'/'=URL)⍳3)↓URL
          :EndIf
          URL←('/'=1↑URL)↓URL
          ⎕←'URL Requested: ',URL
          :If 0=⎕NC'DefHome'
              DefHome←HOME
          :EndIf
          :If 0=⍴Content←GetFile DefHome,URL,(0=⍴URL)/'index.htm'
              Status←'404 File Not Found'
          :Else
              Status←0
          :EndIf
     
      :Else
          Status←'500 Invalid command: ',CMD ⋄ Content←''
      :EndIf
     
      r←Status''Content
    ∇
    
    ∇ R←GetFile NAME
      :Trap 0
          NAME ⎕NTIE ¯1
          R←⎕NREAD ¯1(⎕DR'A'),2↑⎕NSIZE ¯1
          ⎕NUNTIE ¯1
      :Else
          R←''
      :EndTrap
    ∇
    
    ∇ conns HandleRequestOld arg;buf;m;Answer;obj;CMD;URL;pos;req;Data;z;r;FindFirst;hdr;I;rarg;status;content
 ⍝ Handle a Web Server Request
     
      FindFirst←{(⍺⍷⍵)⍳1}
     
      obj buf←arg
      buf←FromRaw buf
     
      :If 0=conns.⎕NC'Buffer'
          conns.Buffer←⍬
      :EndIf
      conns.Buffer,←buf
     
      pos←3+(NL,NL)FindFirst conns.Buffer
     
      :If pos>⍴conns.Buffer ⍝ Have we got everything ?
          :Return
      :ElseIf pos>I←(z←NL[2],'content-length:')FindFirst hdr←##.HTTPUtils.lc pos↑conns.Buffer
      :AndIf (⍴conns.Buffer)<pos+↑2⊃⎕VFI(¯1+z⍳NL[1])↑z←(¯1+I+⍴z)↓hdr
          :Return ⍝ a content-length was specified but we haven't yet gotten what it says to ==> go back for more
      :EndIf
     
      req←pos↑conns.Buffer
      conns.Buffer←pos↓conns.Buffer
      CMD←(¯1+req⍳NL[1])↑req
     
          ⍝ The function called is reponsible for returning:
             ⍝  [1] - (charvec) HTTP status code.         This can be 0 to just mean standard success.
             ⍝  [2] - (charvec) Additional HTTP headers.  If none, just set to ''.
             ⍝  [3] - (charvec) HTTP content.             If none, just set to ''.
     
      :If '\'=¯1↑HOME
          (status hdr content)←GetAnswer req conns.Buffer
      :Else
          :Trap 0 ⍝ be sure to cover any problems during ⍎ and cover a possibly-bogus result from it
              (status hdr content)←⍎HOME,' (cmd←##.HTTPUtils.DecodeCmd req) conns'
          :Else
              (status hdr content)←'500 Internal Server Error' '' ''
          :EndTrap
      :EndIf
     
      rarg←req conns.Buffer ⍝ (<rarg> is for HOME to utilize, e.g. HOME≡'##.SOAP.CongaSOAP rarg'
      :If 0≡status ⋄ status←'200 OK' ⋄ :EndIf
      :If 0≠⍴hdr ⋄ hdr←(-+/∧\(⌽hdr)∊NL)↓hdr ⋄ :EndIf
      Answer←'HTTP/1.0 ',status,NL,'Content-Length: ',(⍕2+⍴content),NL,hdr,NL,NL
      Answer←Answer,content
     
      Answer←ToRaw Answer
      :If ~0=1⊃z←##.DRC.Send obj Answer 1 ⍝ Send response and close connection
          ⎕←'Closed socket ',obj,' due to error: ',⍕z
      :EndIf
    ∇

    ∇ conns HandleRequest arg;buf;m;Answer;obj;CMD;URL;pos;req;Data;z;r;FindFirst;hdr;I;rarg;status;content
 ⍝ Handle a Web Server Request
     
      FindFirst←{(⍺⍷⍵)⍳1}
     
      obj buf←arg
      buf←FromRaw buf
     
      :If 0=conns.⎕NC'Buffer'
          conns.Buffer←⍬
          conns.HttpVer←'HTTP/1.0'
          conns.ConnectionClose←1
          conns.websocket←0
      :EndIf
      conns.Buffer,←buf
      conns.con←obj
      :If 3=conns.⎕NC'HandleWSFrames'
          conns.HandleWSFrames conns
          :Return
      :EndIf
      pos←3+(NL,NL)FindFirst conns.Buffer
     
      :If pos>⍴conns.Buffer ⍝ Have we got everything ?
          :Return
      :ElseIf pos>I←(z←NL[2],'content-length:')FindFirst hdr←##.HTTPUtils.lc pos↑conns.Buffer
      :AndIf (⍴conns.Buffer)<pos+↑2⊃⎕VFI(¯1+z⍳NL[1])↑z←(¯1+I+⍴z)↓hdr
          :Return ⍝ a content-length was specified but we haven't yet gotten what it says to ==> go back for more
      :EndIf
     
      req←pos↑conns.Buffer
      conns.Buffer←pos↓conns.Buffer
      CMD←(¯1+req⍳NL[1])↑req
     
          ⍝ The function called is reponsible for returning:
             ⍝  [1] - (charvec) HTTP status code.         This can be 0 to just mean standard success.
             ⍝  [2] - (charvec) Additional HTTP headers.  If none, just set to ''.
             ⍝  [3] - (charvec) HTTP content.             If none, just set to ''.
     
      :If '\'=¯1↑HOME
          (status hdr content)←GetAnswer req conns.Buffer
      :Else
          :Trap 0 ⍝ be sure to cover any problems during ⍎ and cover a possibly-bogus result from it
              (status hdr content)←⍎HOME,' (cmd←##.HTTPUtils.DecodeCmd req) conns'
          :Else
              (status hdr content)←'500 Internal Server Error' '' ''
          :EndTrap
      :EndIf
     
      rarg←req conns.Buffer ⍝ (<rarg> is for HOME to utilize, e.g. HOME≡'##.SOAP.CongaSOAP rarg'
      :If 0≡status ⋄ status←'200 OK' ⋄ :EndIf
      :If 0≠⍴hdr ⋄ hdr←(-+/∧\(⌽hdr)∊NL)↓hdr ⋄ :EndIf
      Answer←conns.HttpVer,' ',status,NL,((0<⍴content)/'Content-Length: ',(⍕2+⍴content),NL),hdr,NL,NL
      Answer←Answer,content
     
      Answer←ToRaw Answer
      :If ~0=1⊃z←##.DRC.Send obj Answer conns.ConnectionClose ⍝ Send response and close connection
          ⎕←'Closed socket ',obj,' due to error: ',⍕z
      :EndIf
    ∇
    
⍝    ∇ r←Run arg;Common;cmd;name;port;wres;ref;nspc;sink;HOME;stop
⍝      ⍝ Ultra simple HTTP (Web) Server
⍝      ⍝ Assumes Conga available in ##.DRC
⍝     
⍝      {}##.DRC.Init''
⍝      HOME port name←3↑arg,(⍴arg)↓'' 8080 'HTTPSRV'
⍝     
⍝      :If 0=⍴HOME ⋄ :OrIf '\'∊HOME ⍝ *** NEW - Keep old behavior unless what was passed is an executable expression that doesn't contain '\'.
⍝                                   ⍝           Perhaps the expression should just be a separate argument?
⍝          HOME←HOME,(0=⍴HOME)/'c:\dyalog90\samples\tcpip\homepage\'
⍝          HOME←HOME,('\'≠¯1↑HOME)/'\'
⍝      :EndIf
⍝     
⍝      →(0≠1⊃r←##.DRC.Srv name''port'Raw' 10000)⍴0 ⍝
⍝      ⎕←'Web server ''',name,''' started on port ',⍕port
⍝      :If '\'=¯1↑HOME ⍝ *** NEW - check this first
⍝          ⎕←'Root folder: ',HOME
⍝      :Else
⍝          ⎕←'Handling requests using ',HOME
⍝      :EndIf
⍝     
⍝      Common←⎕NS'' ⋄ stop←0
⍝     
⍝      :While ~stop
⍝          wres←##.DRC.Wait name 10000 ⍝ Tick every 10 secs
⍝          ⍝ wres: (return code) (object name) (command) (data)
⍝     
⍝          :Select 1⊃wres
⍝          :Case 0 ⍝ Good data from RPC.Wait
⍝              :Select 3⊃wres
⍝     
⍝              :Case 'Error'
⍝                  :If name≡2⊃wres
⍝                      stop←1
⍝                  :EndIf
⍝                  ⎕←'Error ',(⍕4⊃wres),' on ',2⊃wres
⍝                  ⎕EX SpaceName 2⊃wres
⍝     
⍝              :CaseList 'Block' 'BlockLast'
⍝     
⍝                  :If 0=⎕NC nspc←SpaceName 2⊃wres
⍝                      nspc ⎕NS''
⍝                  :EndIf
⍝     
⍝                  r←(⍎nspc)HandleRequest&wres[2 4] ⍝ Run page handler in new thread
⍝     
⍝                  :If 'BlockLast'≡3⊃wres
⍝                      ⎕EX nspc
⍝                  :EndIf
⍝     
⍝              :Case 'Connect' ⍝ Ignore
⍝     
⍝              :Else
⍝                  ⎕←'Error ',⍕wres
⍝              :EndSelect
⍝     
⍝          :Case 100 ⍝ Time out - put "housekeeping" code here
⍝              ⍝ This runs every 10 secs
⍝              ⍝ ⎕←'Tick...'
⍝     
⍝          :Case 1010 ⍝ Object Not found
⍝              ⎕←'Object ''',name,''' has been closed - Web Server shutting down'
⍝              →0
⍝     
⍝          :Else
⍝              ⎕←'#.RPC.Wait failed:'
⍝              ⎕←wres
⍝              ∘
⍝     
⍝          :EndSelect
⍝     
⍝      :EndWhile
⍝      {}##.DRC.Close name
⍝      ⎕←'Web server ''',name,''' stopped '
⍝    ∇
    
    ∇ r←SpaceName cmd
     ⍝ Generate namespace name from rpc command name
     
      r←'Common.C',Subst(2⊃{1↓¨('.'=⍵)⊂⍵}'.',cmd)'-=' '_∆'
    ∇
    
    ∇ r←Subst arg;i;m;str;c;rep
      ⍝ Substictute character c in str with rep
      str c rep←arg
     
      i←c⍳str
      m←i≤⍴c
      (m/str)←rep[m/i]
      r←str
    ∇
    
    ∇ r←TimeServer(CMD BUF);t
⍝ Example function for "RPC Server".
     
⍝ Needs to return:
⍝  [1] - (charvec) HTTP status code.         This can be 0 to just mean standard success.
⍝  [2] - (charvec) Additional HTTP headers.  If none, just set to ''.
⍝  [3] - (charvec) HTTP content.             If none, just set to ''.
     
      :If (⊂##.HTTPUtils.lc CMD.Command)∊'get' 'post'
          t←,'ZI2,<:>,ZI2,<:>,ZI2'⎕FMT 1 3⍴3↓⎕TS
          r←0 ''('The time is ',t,' and you asked for the page:',CMD.Page)
     
      :Else
          r←('500 Invalid command: ',CMD.Command)'' ''
      :EndIf
    ∇
    
    ∇ z←ToRaw z;⎕IO
      :If ⊃80≠⎕DR' '
          ⎕IO←0
          z←(⎕NXLATE 0)[⎕AV⍳z]
      :Else
          z←8 int ⎕UCS z ⍝ 8-bit signed integers
      :EndIf
    ∇
    ∇ r←Run arg
      r←HttpsRun arg
    ∇
    ∇ r←HttpsRun arg;Common;cmd;name;port;wres;ref;nspc;sink;HOME;stop;certpath;flags;z;cert;secargs;secure;rootcertdir
      ⍝ Ultra simple HTTPS (Web) Server
      ⍝ Assumes Congo available in ##.DRC
      ⍝ Args   1: HOME directory to present or Function to handle request
      ⍝        2: port Port to listen on
      ⍝        3: name Server name
      ⍝        4: certificate  Default empty not running as secure server.
      ⍝        5: RootCertDir directory for root certificates. Default ca from TestCertificates
      ⍝        6: Flags to use for certificate validation. default 32+64  Accept Without Validating, RequestClientCertificate
     
      {}##.DRC.Init''
      HOME port name cert rootcertdir flags←6↑arg,(⍴arg)↓'' 445 'HTTPSRV'(⎕NEW ##.DRC.X509Cert)(##.Samples.CertPath,'ca')(32+64)
     
      :If 0=⍴HOME ⋄ :OrIf '\'∊HOME ⍝ *** NEW - Keep old behavior unless what was passed is an executable expression that doesn't contain '\'.
                              ⍝           Perhaps the expression should just be a separate argument?
          HOME←HOME,(0=⍴HOME)/'c:\dyalog90\samples\tcpip\homepage\'
          HOME←HOME,('\'≠¯1↑HOME)/'\'
      :EndIf
     
      secure←1<cert.IsCert
      secargs←⍬
      :If secure
          :If 0<⍴rootcertdir
              {}##.DRC.SetProp'.' 'RootCertDir'(rootcertdir)
          :EndIf
          secargs←('X509'cert)('SSLValidation'flags)
      :EndIf
     
      →(0≠1⊃r←##.DRC.Srv name''port'Raw' 10000,secure/secargs)⍴0
      ⎕←'Web server ''',name,''' started on port ',⍕port
      :If '\'=¯1↑HOME ⍝ *** NEW - check this first
          ⎕←'Root folder: ',HOME
      :Else
          ⎕←'Handling requests using ',HOME
      :EndIf
     
      Common←⎕NS'' ⋄ stop←0
     
      :While ~stop
          wres←##.DRC.Wait name 10000 ⍝ Tick every 10 secs
          ⍝ wres: (return code) (object name) (command) (data)
     ⍝⎕←3⊃wres
          :Select 1⊃wres
          :Case 0 ⍝ Good data from RPC.Wait
              :Select 3⊃wres
     
              :Case 'Error'
                  :If name≡2⊃wres
                      stop←1
                  :EndIf
                  ⎕←'Error ',(⍕4⊃wres),' on ',2⊃wres
                  ⎕EX SpaceName 2⊃wres
     
              :CaseList 'Block' 'BlockLast'
     
                  nspc←SpaceName 2⊃wres
                  r←(⍎nspc)HandleRequest&wres[2 4] ⍝ Run page handler in new thread
     
                  :If 'BlockLast'≡3⊃wres
                      ⎕EX nspc
                  :EndIf
     
              :Case 'Connect'
             ⍝ ⎕DL 1
             ⍝⎕←'New connection',⍕2⊃wres
                  nspc←SpaceName 2⊃wres
                  nspc ⎕NS''
                  :If secure
                      (⍎nspc).PeerCert←2⊃##.DRC.GetProp(2⊃wres)'PeerCert'
                      (⍎nspc).OwnCert←2⊃##.DRC.GetProp(2⊃wres)'OwnCert'
     
                  :EndIf
              :Else
                  ⎕←'Error ',⍕wres
              :EndSelect
     
          :Case 100 ⍝ Time out - put "housekeeping" code here
              ⍝ This runs every 10 secs
              ⍝ ⎕←'Tick...'
     
          :Case 1010 ⍝ Object Not found
              ⎕←'Object ''',name,''' has been closed - Web Server shutting down'
              →0
     
          :Else
              ⎕←'#.RPC.Wait failed:'
              ⎕←wres
              ∘
     
          :EndSelect
     
      :EndWhile
      {}##.DRC.Close name
      ⎕←'Web server ''',name,''' stopped '
    ∇
:EndNamespace 