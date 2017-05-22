:Namespace Samples
⍝ === VARIABLES ===

    NL←(⎕ucs 13 10)

    TestCertificates←'../'

⍝ === End of variables definition ===

    (⎕IO ⎕ML ⎕WX)←1 0 3


    ∇ r←CertPath;droptail;exists;file;ws
     ⍝ Return the path to the certificates
     
      file←'server/localhost-server-cert.pem' ⍝ Search for this file
      droptail←{(-⌊/(⌽⍵)⍳'\/')↓⍵}
      exists←{0::0 ⋄ 1{⍺}⎕NUNTIE ⍵ ⎕NTIE 0}
     
      :If exists(r←{⍵,('/'≠¯1↑⍵)/'/'}{(-'\'=¯1↑⍵)↓⍵}TestCertificates),file
      :ElseIf exists(r←'/TestCertificates/',⍨ws←droptail ⎕WSID),file
      :ElseIf exists(r←'/TestCertificates/',⍨ws←droptail ws),file
      :ElseIf exists(r←'/TestCertificates/',⍨ws←droptail+2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'),file
      :ElseIf exists(r←'../TestCertificates/'),file
      :Else
          ('Unable to locate file ',file)⎕SIGNAL 22
      :EndIf
    ∇

    ∇ ClientServerTest;ret
      1 ##.DRC.Init''
      ret←##.DRC.Srv'S1' '' 5000
      :If 0≠⊃ret
          ⎕←'Server returned error:'ret
          →0
      :EndIf
      ret←##.DRC.Clt'C1' '127.0.0.1' 5000
      :If 0≠⊃ret
          ⎕←'Client returned error:'ret
          →0
      :EndIf
      ##.DRC.Wait'S1' 10000
      ##.DRC.Send'C1'('hello' 'this' 'is' 'a' 'test')
      c←##.DRC.Wait'S1' 1000
      ##.DRC.Respond(2⊃c)(⌽4⊃c)
      ##.DRC.Wait'C1' 10000
    ∇

    ∇ r←name DisplayCert z
     ⍝ Display information about a certificate
      dc←{,[1.5](2⊃⍵)[1 2 3 4 5 6]}
      nc←,[1.5]name'Version' 'SerialNo' 'Subject' 'Issuer' 'ValidFrom' 'ValidTo'
      dc←{⍵.(Formatted.(Version SerialNo Subject Issuer),Elements.(ValidFrom ValidTo))}
      :If 0=1⊃z
      :AndIf 0<⊃⍴2⊃z
          r←nc,' '⍪⍉↑dc¨2⊃z
     ⍝    ⎕←name,':'
     ⍝    ⎕←dc 1⊃z←2⊃z ⋄ ⎕←''
     ⍝    :If 1<⍴z ⋄ ⎕←'Signing chain for ',name,':' ⋄ ⎕←dc¨1↓z ⋄ ⎕←''
     ⍝    :EndIf
      :Else ⋄ r←('Unable to retrieve ',name)z
      :EndIf
    ∇

    ∇ r←{send}GetSimpleServiceData(host port);done;wr;cmd;header;data;z
     ⍝ Open a socket, send something, get response.
     ⍝ Suitable for simple services like daytime (13) and QOTD (17) which simply return data and close connection
     
      :If 0=⎕NC'send' ⋄ send←'' ⋄ :EndIf
      {}##.DRC.Init''
     
      :If 0=1⊃r←##.DRC.Clt''host port'Text' 1000  ⍝ Create an Ascii client with max buffer size 1000
          cmd←2⊃r
          :If 0≠⍴send ⋄ r←##.DRC.Send cmd send ⋄ :EndIf
      :AndIf 0=1⊃r                                       ⍝ Send something
          data←''
          :Repeat
              :If 0≠1⊃wr←##.DRC.Wait cmd 10000           ⍝ Wait for max 10 secs
                  r←(1⊃wr)data ⋄ →0 ⍝ Error
              :Else
                  data,←4⊃wr
                  done←'BlockLast'≡3⊃wr                  ⍝ Socket closed as this block was received
              :EndIf
          :Until done
          r←0 data
      :EndIf
      :If 2=⎕NC'cmd'
          z←##.DRC.Close cmd
      :EndIf
    ∇

    ∇ r←GetStats arg;noatt;result;input;count;mode;median;mean;nums
     ⍝ WebService Method to return statistics
     
      input←(arg[;2]⍳⊂'Input')⊃arg[;3],⊂'' ⍝ Extract Name from argument
      nums←⊃(//)⎕VFI input                 ⍝ Convert to numbers
     
      noatt←0 2⍴⊂'' ⍝ We do not set any attributes
      result←1 4⍴1 'Stats' ''noatt
      result⍪←2,(('Count' 'Mean' 'Median' 'Mode'),[1.5]←StatCalc nums),⊂noatt
      r←1 result
    ∇

    ∇ user←GetUserFromCerts cert;user
     
      :If 0≠⍴cert
          user←(⊃cert).Formatted.(Subject Issuer)
     ⍝user←'CN'∘{⊃⍵[⍵[;1]⍳⊂⍺;2]}¨cert
     ⍝user←(1⊃user)(1↓,⍕'/',¨1↓user)
      :Else ⋄ user←'UNKNOWN' 'UNKNOWN'
      :EndIf
      user←'User' 'C.A.',[1.5]user
    ∇


    ∇ r←{certs}(cmd HTTPCmdNew)args;U;DRC;fromutf8;h2d;getchunklen;eis;getHeader;addHeader;makeHeaders;fmtHeaders;url;parms;hdrs;b;p;secure;port;host;page;x509;flags;priority;pars;auth;req;err;chunked;chunk;buffer;chunklength;header;datalen;data;done;wr;len;cmd;urlparms
⍝ issue an HTTP command
⍝ certs - optional PublicCert PrivateKey SSLValidation
⍝ args  - [1] URL in format [HTTP[S]://][user:pass@]url[:port][/page]
⍝         {2} parameters is using POST - either a namespace or URL-encoded string
⍝         {3} HTTP headers in form {↑}(('hdr1' 'val1')('hdr2' 'val2'))
⍝ Makes secure connection if left arg provided or URL begins with https:
     
⍝ Result: (return code) (HTTP headers) (HTTP body) [PeerCert if secure]
      (U DRC)←##.(HTTPUtils DRC) ⍝ Uses utils from here
      fromutf8←{0::(⎕AV,'?')[⎕AVU⍳⍵] ⋄ 'UTF-8'⎕UCS ⍵} ⍝ Turn raw UTF-8 input into text
      h2d←{⎕IO←0 ⋄ 16⊥'0123456789abcdef'⍳U.lc ⍵} ⍝ hex to decimal
      getchunklen←{¯1=len←¯1+⊃(NL⍷⍵)/⍳⍴⍵:¯1 ¯1 ⋄ chunklen←h2d len↑⍵ ⋄ (⍴⍵)<len+chunklen+4:¯1 ¯1 ⋄ len chunklen}
      eis←{⍺←1 ⋄ ,(⊂⍣(⍺=|≡⍵))⍵} ⍝ enclose if simple
      getHeader←{(⍺[;2],⊂'')⊃⍨⍺[;1]⍳eis ⍵}
      addHeader←{0∊⍴⍺⍺ getHeader ⍺:⍺⍺⍪⍺ ⍵ ⋄ ⍺⍺}
      makeHeaders←{⎕ML←1 ⋄ 0∊⍴⍵:0 2⍴⊂'' ⋄ 2=⍴⍴⍵:⍵ ⋄ ↑2 eis ⍵}
      fmtHeaders←{⎕ML←1 ⋄ 0∊⍴⍵:'' ⋄ ∊{NL,⍨(1⊃⍵),': ',⍕2⊃⍵}¨↓⍵}
      {}DRC.Init''
      args←eis args
     
      (url parms hdrs)←args,(⍴args)↓''(⎕NS'')''
      urlparms←''
      cmd←{(⎕A,⍵)[⍵⍳⍨'abcdefghijklmnopqrstuvwxyz',⍵]},cmd
     
      :If 326=⎕DR parms ⍝ if parms are a namespace, format them
          :If 'POST'≡cmd
              parms←{0∊⍴t←⍵.⎕NL ¯2:'' ⋄ 1↓⊃,/⍵{'&',⍵,'=',(⍕⍺⍎⍵)}¨t}parms
          :Else
              urlparms←{0∊⍴⍵:'' ⋄ '?',⍵}{0∊⍴t←⍵.⎕NL ¯2:'' ⋄ 1↓⊃,/⍵{'&',⍵,'=',(⍕⍺⍎⍵)}¨t}parms
              parms←''
          :EndIf
      :EndIf
     
     GET:
      p←(∨/b)×1+(b←'//'⍷url)⍳1
      secure←{6::⍵ ⋄ ⍵∨0<⍴,certs}(U.lc(p-2)↑url)≡'https:'
      port←(1+secure)⊃80 443 ⍝ Default HTTP/HTTPS port
      url←p↓url              ⍝ Remove HTTP[s]:// if present
      (host page)←'/'split url,(~'/'∊url)/'/'    ⍝ Extract host and page from url
     
      :If 0=⎕NC'certs' ⋄ certs←'' ⋄ :EndIf
     
      :If secure
          x509 flags priority←3↑certs,(⍴,certs)↓(⎕NEW ##.DRC.X509Cert)32 'NORMAL:!CTYPE-OPENPGP'  ⍝ 32=Do not validate Certs
          pars←('x509'x509)('SSLValidation'flags)('Priority'priority)
      :Else ⋄ pars←''
      :EndIf
     
      :If '@'∊host ⍝ Handle user:password@host...
          auth←'Authorization: Basic ',(U.Encode(¯1+p←host⍳'@')↑host),NL
          host←p↓host
      :Else ⋄ auth←''
      :EndIf
     
      host port←port U.HostPort host ⍝ Check for override of port number
     
      hdrs←makeHeaders hdrs
      hdrs←'User-Agent'(hdrs addHeader)'Dyalog/Conga'
      hdrs←'Accept'(hdrs addHeader)'*/*'
     
      :If ~0∊⍴parms
          :If cmd≡'POST'
              hdrs←'Content-Length'(hdrs addHeader)⍴parms
              hdrs←'Content-Type'(hdrs addHeader)'application/x-www-form-urlencoded'
          :EndIf
      :EndIf
     
      req←cmd,' ',(page,urlparms),' HTTP/1.1',NL,'Host: ',host,NL
      req,←fmtHeaders hdrs
      req,←auth
     
      :If DRC.flate.IsAvailable ⍝ if compression is available
          req,←'Accept-Encoding: deflate',NL ⍝ indicate we can accept it
      :EndIf
     
      :If 0=⊃(err cmd)←2↑r←DRC.Clt''host port'http' 100000,pars ⍝ 100,000 is max receive buffer size
      :AndIf 0=⊃r←DRC.Send cmd(req,NL,parms)
     
          chunked chunk buffer chunklength←0 '' '' 0
          done data datalen header←0 ⍬ 0(0 ⍬)  
          
          :Repeat
              :If ~done←0≠1⊃wr←DRC.Wait cmd 5000            ⍝ Wait up to 5 secs
                  (err obj evt dat)←4↑wr
                  :select evt
                     :case 'HTTPHeader' 
                      header←U.DecodeHeader dat 
                      datalen←⊃((2⊃header)U.GetValue'Content-Length' 'Numeric'),¯1 ⍝ ¯1 if no content length not specified
                      chunked←∨/'chunked'⍷(2⊃header)U.GetValue'Transfer-Encoding' ''
                      done←(~chunked)∧datalen<1
                     :case 'HTTPBody'
                       data←dat
                     :case 'HTTPChunk'
                       data,←dat 
                     :case 'HTTPTrailer'  
                       header[2]←⊂(2⊃header)⍪2⊃U.DecodeHeader dat
                       done←1
                  :endselect
              :EndIf
          :Until done
     
          :Trap 0 ⍝ If any errors occur, abandon conversion
              :If ∨/'deflate'⍷(2⊃header)U.GetValue'content-encoding' '' ⍝ was the response compressed?
                  data←fromutf8 DRC.flate.Inflate 120 156{(2×⍺≡2↑⍵)↓⍺,⍵}256|83 ⎕DR data ⍝ append 120 156 signature because web servers strip it out due to IE
              :ElseIf ∨/'charset=utf-8'⍷(2⊃header)U.GetValue'content-type' ''
                  data←'UTF-8'⎕UCS ⎕UCS data ⍝ Convert from UTF-8
              :EndIf
          :EndTrap
     
          :If {(⍵[3]∊'12357')∧'30 '≡⍵[1 2 4]}4↑{⍵↓⍨⍵⍳' '}(⊂1 1)⊃2⊃header ⍝ redirected? (HTTP status codes 301, 302, 303, 305, 307)
              →GET⍴⍨0<⍴url←'location'{(⍵[;1]⍳⊂⍺)⊃⍵[;2],⊂''}2⊃header ⍝ use the "location" header field for the URL
          :EndIf
     
          r←(1⊃wr)(2⊃header)data
     
          :If secure ⋄ r←r,⊂DRC.GetProp cmd'PeerCert' ⋄ :EndIf
      :Else
          'Connection failed ',,⍕r
      :EndIf
     
      {}DRC.Close cmd
    ∇





    ∇ r←{certs}(cmd HTTPCmd)args;U;DRC;fromutf8;h2d;getchunklen;eis;getHeader;addHeader;makeHeaders;fmtHeaders;url;parms;hdrs;b;p;secure;port;host;page;x509;flags;priority;pars;auth;req;err;chunked;chunk;buffer;chunklength;header;datalen;data;done;wr;len;cmd;urlparms
⍝ issue an HTTP command
⍝ certs - optional PublicCert PrivateKey SSLValidation
⍝ args  - [1] URL in format [HTTP[S]://][user:pass@]url[:port][/page]
⍝         {2} parameters is using POST - either a namespace or URL-encoded string
⍝         {3} HTTP headers in form {↑}(('hdr1' 'val1')('hdr2' 'val2'))
⍝ Makes secure connection if left arg provided or URL begins with https:
     
⍝ Result: (return code) (HTTP headers) (HTTP body) [PeerCert if secure]
      (U DRC)←##.(HTTPUtils DRC) ⍝ Uses utils from here
      fromutf8←{0::(⎕AV,'?')[⎕AVU⍳⍵] ⋄ 'UTF-8'⎕UCS ⍵} ⍝ Turn raw UTF-8 input into text
      h2d←{⎕IO←0 ⋄ 16⊥'0123456789abcdef'⍳U.lc ⍵} ⍝ hex to decimal
      getchunklen←{¯1=len←¯1+⊃(NL⍷⍵)/⍳⍴⍵:¯1 ¯1 ⋄ chunklen←h2d len↑⍵ ⋄ (⍴⍵)<len+chunklen+4:¯1 ¯1 ⋄ len chunklen}
      eis←{⍺←1 ⋄ ,(⊂⍣(⍺=|≡⍵))⍵} ⍝ enclose if simple
      getHeader←{(⍺[;2],⊂'')⊃⍨⍺[;1]⍳eis ⍵}
      addHeader←{0∊⍴⍺⍺ getHeader ⍺:⍺⍺⍪⍺ ⍵ ⋄ ⍺⍺}
      makeHeaders←{⎕ML←1 ⋄ 0∊⍴⍵:0 2⍴⊂'' ⋄ 2=⍴⍴⍵:⍵ ⋄ ↑2 eis ⍵}
      fmtHeaders←{⎕ML←1 ⋄ 0∊⍴⍵:'' ⋄ ∊{NL,⍨(1⊃⍵),': ',⍕2⊃⍵}¨↓⍵}
      {}DRC.Init''
      args←eis args
     
      (url parms hdrs)←args,(⍴args)↓''(⎕NS'')''
      urlparms←''
      cmd←{(⎕A,⍵)[⍵⍳⍨'abcdefghijklmnopqrstuvwxyz',⍵]},cmd
     
      :If 326=⎕DR parms ⍝ if parms are a namespace, format them
          :If 'POST'≡cmd
              parms←{0∊⍴t←⍵.⎕NL ¯2:'' ⋄ 1↓⊃,/⍵{'&',⍵,'=',(⍕⍺⍎⍵)}¨t}parms
          :Else
              urlparms←{0∊⍴⍵:'' ⋄ '?',⍵}{0∊⍴t←⍵.⎕NL ¯2:'' ⋄ 1↓⊃,/⍵{'&',⍵,'=',(⍕⍺⍎⍵)}¨t}parms
              parms←''
          :EndIf
      :EndIf
     
     GET:
      p←(∨/b)×1+(b←'//'⍷url)⍳1
      secure←{6::⍵ ⋄ ⍵∨0<⍴,certs}(U.lc(p-2)↑url)≡'https:'
      port←(1+secure)⊃80 443 ⍝ Default HTTP/HTTPS port
      url←p↓url              ⍝ Remove HTTP[s]:// if present
      (host page)←'/'split url,(~'/'∊url)/'/'    ⍝ Extract host and page from url
     
      :If 0=⎕NC'certs' ⋄ certs←'' ⋄ :EndIf
     
      :If secure
          x509 flags priority←3↑certs,(⍴,certs)↓(⎕NEW ##.DRC.X509Cert)32 'NORMAL:!CTYPE-OPENPGP'  ⍝ 32=Do not validate Certs
          pars←('x509'x509)('SSLValidation'flags)('Priority'priority)
      :Else ⋄ pars←''
      :EndIf
     
      :If '@'∊host ⍝ Handle user:password@host...
          auth←'Authorization: Basic ',(U.Encode(¯1+p←host⍳'@')↑host),NL
          host←p↓host
      :Else ⋄ auth←''
      :EndIf
     
      host port←port U.HostPort host ⍝ Check for override of port number
     
      hdrs←makeHeaders hdrs
      hdrs←'User-Agent'(hdrs addHeader)'Dyalog/Conga'
      hdrs←'Accept'(hdrs addHeader)'*/*'
     
      :If ~0∊⍴parms
          :If cmd≡'POST'
              hdrs←'Content-Length'(hdrs addHeader)⍴parms
              hdrs←'Content-Type'(hdrs addHeader)'application/x-www-form-urlencoded'
          :EndIf
      :EndIf
     
      req←cmd,' ',(page,urlparms),' HTTP/1.1',NL,'Host: ',host,NL
      req,←fmtHeaders hdrs
      req,←auth
     
      :If DRC.flate.IsAvailable ⍝ if compression is available
          req,←'Accept-Encoding: deflate',NL ⍝ indicate we can accept it
      :EndIf
     
      :If 0=⊃(err cmd)←2↑r←DRC.Clt''host port'Text' 100000,pars ⍝ 100,000 is max receive buffer size
      :AndIf 0=⊃r←DRC.Send cmd(req,NL,parms)
     
          chunked chunk buffer chunklength←0 '' '' 0
          done data datalen header←0 ⍬ 0(0 ⍬)
          :Repeat
              :If ~done←0≠1⊃wr←DRC.Wait cmd 5000            ⍝ Wait up to 5 secs
                  :If wr[3]∊'Block' 'BlockLast'             ⍝ If we got some data
                      :If chunked
                          chunk←4⊃wr
                      :ElseIf 0<⍴data,←4⊃wr
                      :AndIf 0=1⊃header
                          header←U.DecodeHeader data
                          :If 0<1⊃header
                              data←(1⊃header)↓data
                              :If chunked←∨/'chunked'⍷(2⊃header)U.GetValue'Transfer-Encoding' ''
                                  chunk←data
                                  data←''
                              :Else
                                  datalen←⊃((2⊃header)U.GetValue'Content-Length' 'Numeric'),¯1 ⍝ ¯1 if no content length not specified
                              :EndIf
                          :EndIf
                      :EndIf
                  :Else
                      ⎕←wr ⍝ Error?
                      ∘∘∘
                  :EndIf
                  :If chunked
                      buffer,←chunk
                      :While done<¯1≠⊃(len chunklength)←getchunklen buffer
                          :If (⍴buffer)≥4+len+chunklength
                              data,←chunklength↑(len+2)↓buffer
                              buffer←(chunklength+len+4)↓buffer
                              :If done←0=chunklength ⍝ chunked transfer can add headers at the end of the transmission
                                  header[2]←⊂(2⊃header)⍪2⊃U.DecodeHeader buffer
                              :EndIf
                          :EndIf
                      :EndWhile
                  :Else
                      done←done∨'BlockLast'≡3⊃wr                        ⍝ Done if socket was closed
                      :If datalen>0
                          done←done∨datalen≤⍴data ⍝ ... or if declared amount of data rcvd
                      :Else
                          done←done∨(∨/'</html>'⍷data)∨(∨/'</HTML>'⍷data)
                      :EndIf
                  :EndIf
              :EndIf
          :Until done
     
          :Trap 0 ⍝ If any errors occur, abandon conversion
              :If ∨/'deflate'⍷(2⊃header)U.GetValue'content-encoding' '' ⍝ was the response compressed?
                  data←fromutf8 DRC.flate.Inflate 120 156{(2×⍺≡2↑⍵)↓⍺,⍵}256|83 ⎕DR data ⍝ append 120 156 signature because web servers strip it out due to IE
              :ElseIf ∨/'charset=utf-8'⍷(2⊃header)U.GetValue'content-type' ''
                  data←'UTF-8'⎕UCS ⎕UCS data ⍝ Convert from UTF-8
              :EndIf
          :EndTrap
     
          :If {(⍵[3]∊'12357')∧'30 '≡⍵[1 2 4]}4↑{⍵↓⍨⍵⍳' '}(⊂1 1)⊃2⊃header ⍝ redirected? (HTTP status codes 301, 302, 303, 305, 307)
              →GET⍴⍨0<⍴url←'location'{(⍵[;1]⍳⊂⍺)⊃⍵[;2],⊂''}2⊃header ⍝ use the "location" header field for the URL
          :EndIf
     
          r←(1⊃wr)(2⊃header)data
     
          :If secure ⋄ r←r,⊂DRC.GetProp cmd'PeerCert' ⋄ :EndIf
      :Else
          'Connection failed ',,⍕r
      :EndIf
     
      {}DRC.Close cmd
    ∇

    ∇ r←{certs}HTTPReq args;U;DRC;fromutf8;h2d;getchunklen;eis;getHeader;addHeader;makeHeaders;fmtHeaders;url;parms;hdrs;b;p;secure;port;host;page;x509;flags;priority;pars;auth;req;err;chunked;chunk;buffer;chunklength;header;datalen;data;done;wr;len;cmd
          ⍝ issue an HTTP GET or POST request
          ⍝ certs - optional PublicCert PrivateKey SSLValidation
          ⍝ args  - [1] URL in format [HTTP[S]://][user:pass@]url[:port][/page]
          ⍝         {2} parameters is using POST - either a namespace or URL-encoded string
          ⍝         {3} HTTP headers in form {↑}(('hdr1' 'val1')('hdr2' 'val2'))
          ⍝ Makes secure connection if left arg provided or URL begins with https:
     
          ⍝ Result: (return code) (HTTP headers) (HTTP body) [PeerCert if secure]
      (U DRC)←##.(HTTPUtils DRC) ⍝ Uses utils from here
      fromutf8←{0::(⎕AV,'?')[⎕AVU⍳⍵] ⋄ 'UTF-8'⎕UCS ⍵} ⍝ Turn raw UTF-8 input into text
      h2d←{⎕IO←0 ⋄ 16⊥'0123456789abcdef'⍳U.lc ⍵} ⍝ hex to decimal
      getchunklen←{¯1=len←¯1+⊃(NL⍷⍵)/⍳⍴⍵:¯1 ¯1 ⋄ chunklen←h2d len↑⍵ ⋄ (⍴⍵)<len+chunklen+4:¯1 ¯1 ⋄ len chunklen}
      eis←{⍺←1 ⋄ ,(⊂⍣(⍺=|≡⍵))⍵} ⍝ enclose if simple
      getHeader←{(⍺[;2],⊂'')⊃⍨⍺[;1]⍳eis ⍵}
      addHeader←{0∊⍴⍺⍺ getHeader ⍺:⍺⍺⍪⍺ ⍵ ⋄ ⍺⍺}
      makeHeaders←{⎕ML←1 ⋄ 0∊⍴⍵:0 2⍴⊂'' ⋄ 2=⍴⍴⍵:⍵ ⋄ ↑2 eis ⍵}
      fmtHeaders←{⎕ML←1 ⋄ 0∊⍴⍵:'' ⋄ ∊{NL,⍨(1⊃⍵),': ',⍕2⊃⍵}¨↓⍵}
      {}DRC.Init''
      args←eis args
     
      (url parms hdrs)←args,(⍴args)↓''(⎕NS'')''
     
      :If 326=⎕DR parms ⍝ if parms are a namespace, format them
          parms←{0∊⍴t←⍵.⎕NL ¯2:'' ⋄ 1↓⊃,/⍵{'&',⍵,'=',(⍕⍺⍎⍵)}¨t}parms
      :EndIf
     
      cmd←(1+0∊⍴parms)⊃'POST' 'GET' ⍝ set command based on whether we've passed POST parameters
     
     GET:
      p←(∨/b)×1+(b←'//'⍷url)⍳1
      secure←{6::⍵ ⋄ ⍵∨0<⍴,certs}(U.lc(p-2)↑url)≡'https:'
      port←(1+secure)⊃80 443 ⍝ Default HTTP/HTTPS port
      url←p↓url              ⍝ Remove HTTP[s]:// if present
      (host page)←'/'split url,(~'/'∊url)/'/'    ⍝ Extract host and page from url
     
      :If 0=⎕NC'certs' ⋄ certs←'' ⋄ :EndIf
     
      :If secure
          x509 flags priority←3↑certs,(⍴,certs)↓(⎕NEW ##.DRC.X509Cert)32 'NORMAL:!CTYPE-OPENPGP'  ⍝ 32=Do not validate Certs
          pars←('x509'x509)('SSLValidation'flags)('Priority'priority)
      :Else ⋄ pars←''
      :EndIf
     
      :If '@'∊host ⍝ Handle user:password@host...
          auth←'Authorization: Basic ',(U.Encode(¯1+p←host⍳'@')↑host),NL
          host←p↓host
      :Else ⋄ auth←''
      :EndIf
     
      host port←port U.HostPort host ⍝ Check for override of port number
     
      hdrs←makeHeaders hdrs
      hdrs←'User-Agent'(hdrs addHeader)'Dyalog/Conga'
      hdrs←'Accept'(hdrs addHeader)'*/*'
     
      :If ~0∊⍴parms
          hdrs←'Content-Length'(hdrs addHeader)⍴parms
          hdrs←'Content-Type'(hdrs addHeader)'application/x-www-form-urlencoded'
      :EndIf
     
      req←cmd,' ',page,' HTTP/1.1',NL,'Host: ',host,NL
      req,←fmtHeaders hdrs
      req,←auth
     
      :If DRC.flate.IsAvailable ⍝ if compression is available
          req,←'Accept-Encoding: deflate',NL ⍝ indicate we can accept it
      :EndIf
     
      :If 0=⊃(err cmd)←2↑r←DRC.Clt''host port'Text' 100000,pars ⍝ 100,000 is max receive buffer size
      :AndIf 0=⊃r←DRC.Send cmd(req,NL,parms)
     
          chunked chunk buffer chunklength←0 '' '' 0
          done data datalen header←0 ⍬ 0(0 ⍬)
          :Repeat
              :If ~done←0≠1⊃wr←DRC.Wait cmd 5000            ⍝ Wait up to 5 secs
                  :If wr[3]∊'Block' 'BlockLast'             ⍝ If we got some data
                      :If chunked
                          chunk←4⊃wr
                      :ElseIf 0<⍴data,←4⊃wr
                      :AndIf 0=1⊃header
                          header←U.DecodeHeader data
                          :If 0<1⊃header
                              data←(1⊃header)↓data
                              :If chunked←∨/'chunked'⍷(2⊃header)U.GetValue'Transfer-Encoding' ''
                                  chunk←data
                                  data←''
                              :Else
                                  datalen←⊃((2⊃header)U.GetValue'Content-Length' 'Numeric'),¯1 ⍝ ¯1 if no content length not specified
                              :EndIf
                          :EndIf
                      :EndIf
                  :Else
                      ⎕←wr ⍝ Error?
                      ∘∘∘
                  :EndIf
                  :If chunked
                      buffer,←chunk
                      :While done<¯1≠⊃(len chunklength)←getchunklen buffer
                          :If (⍴buffer)≥4+len+chunklength
                              data,←chunklength↑(len+2)↓buffer
                              buffer←(chunklength+len+4)↓buffer
                              :If done←0=chunklength ⍝ chunked transfer can add headers at the end of the transmission
                                  header[2]←⊂(2⊃header)⍪2⊃U.DecodeHeader buffer
                              :EndIf
                          :EndIf
                      :EndWhile
                  :Else
                      done←done∨'BlockLast'≡3⊃wr                        ⍝ Done if socket was closed
                      :If datalen>0
                          done←done∨datalen≤⍴data ⍝ ... or if declared amount of data rcvd
                      :Else
                          done←done∨(∨/'</html>'⍷data)∨(∨/'</HTML>'⍷data)
                      :EndIf
                  :EndIf
              :EndIf
          :Until done
     
          :Trap 0 ⍝ If any errors occur, abandon conversion
              :If ∨/'deflate'⍷(2⊃header)U.GetValue'content-encoding' '' ⍝ was the response compressed?
                  data←fromutf8 DRC.flate.Inflate 120 156{(2×⍺≡2↑⍵)↓⍺,⍵}256|83 ⎕DR data ⍝ append 120 156 signature because web servers strip it out due to IE
              :ElseIf ∨/'charset=utf-8'⍷(2⊃header)U.GetValue'content-type' ''
                  data←'UTF-8'⎕UCS ⎕UCS data ⍝ Convert from UTF-8
              :EndIf
          :EndTrap
     
          :If {(⍵[3]∊'12357')∧'30 '≡⍵[1 2 4]}4↑{⍵↓⍨⍵⍳' '}(⊂1 1)⊃2⊃header ⍝ redirected? (HTTP status codes 301, 302, 303, 305, 307)
              →GET⍴⍨0<⍴url←'location'{(⍵[;1]⍳⊂⍺)⊃⍵[;2],⊂''}2⊃header ⍝ use the "location" header field for the URL
          :EndIf
     
          r←(1⊃wr)(2⊃header)data
     
          :If secure ⋄ r←r,⊂DRC.GetProp cmd'PeerCert' ⋄ :EndIf
      :Else
          'Connection failed ',,⍕r
      :EndIf
     
      {}DRC.Close cmd
    ∇

    ∇ r←{certs}HTTPGet url;U;DRC;protocol;wr;key;flags;pars;secure;data;z;header;datalen;host;port;done;cmd;b;page;auth;p;x509;priority;err;req;fromutf8;chunked;chunk;h2d;buffer;chunklength;len;getchunklen
          ⍝ Get an HTTP page, format [HTTP[S]://][user:pass@]url[:port][/page]
          ⍝ Opional Left argument: PublicCert PrivateKey SSLValidation
          ⍝ Makes secure connection if left arg provided or URL begins with https:
     
          ⍝ Result: (return code) (HTTP headers) (HTTP body) [PeerCert if secure]
     
      (U DRC)←##.(HTTPUtils DRC) ⍝ Uses utils from here
      fromutf8←{0::(⎕AV,'?')[⎕AVU⍳⍵] ⋄ 'UTF-8'⎕UCS ⍵} ⍝ Turn raw UTF-8 input into text
      h2d←{⎕IO←0 ⋄ 16⊥'0123456789abcdef'⍳U.lc ⍵} ⍝ hex to decimal
      getchunklen←{¯1=len←¯1+⊃(NL⍷⍵)/⍳⍴⍵:¯1 ¯1 ⋄ chunklen←h2d len↑⍵ ⋄ (⍴⍵)<len+chunklen+4:¯1 ¯1 ⋄ len chunklen}
     
      {}DRC.Init''
     
     GET:
      p←(∨/b)×1+(b←'//'⍷url)⍳1
      secure←{6::⍵ ⋄ ⍵∨0<⍴,certs}(U.lc(p-2)↑url)≡'https:'
      port←(1+secure)⊃80 443 ⍝ Default HTTP/HTTPS port
      url←p↓url              ⍝ Remove HTTP[s]:// if present
      host page←'/'split url,(~'/'∊url)/'/'    ⍝ Extract host and page from url
     
      :If 0=⎕NC'certs' ⋄ certs←'' ⋄ :EndIf
     
      :If secure
          x509 flags priority←3↑certs,(⍴,certs)↓(⎕NEW ##.DRC.X509Cert)32 'NORMAL:!CTYPE-OPENPGP'  ⍝ 32=Do not validate Certs
          pars←('x509'x509)('SSLValidation'flags)('Priority'priority)
      :Else ⋄ pars←''
      :EndIf
     
      :If '@'∊host ⍝ Handle user:password@host...
          auth←NL,'Authorization: Basic ',(U.Encode(¯1+p←host⍳'@')↑host)
          host←p↓host
      :Else ⋄ auth←''
      :EndIf
     
      host port←port U.HostPort host ⍝ Check for override of port number
     
      req←'GET ',page,' HTTP/1.1',NL,'Host: ',host,NL,'User-Agent: Dyalog/Conga',NL,'Accept: */*',auth,NL ⍝ build the request
     
      :If DRC.flate.IsAvailable ⍝ if compression is available
          req,←'Accept-Encoding: deflate',NL ⍝ indicate we can accept it
      :EndIf
     
      :If 0=⊃(err cmd)←2↑r←DRC.Clt''host port'Text' 100000,pars ⍝ 100,000 is max receive buffer size
      :AndIf 0=⊃r←DRC.Send cmd(req,NL)
     
          chunked chunk buffer chunklength←0 '' '' 0
          done data datalen header←0 ⍬ 0(0 ⍬)
          :Repeat
              :If ~done←0≠1⊃wr←DRC.Wait cmd 5000            ⍝ Wait up to 5 secs
                  :If wr[3]∊'Block' 'BlockLast'             ⍝ If we got some data
                      :If chunked
                          chunk←4⊃wr
                      :ElseIf 0<⍴data,←4⊃wr
                      :AndIf 0=1⊃header
                          header←U.DecodeHeader data
                          :If 0<1⊃header
                              data←(1⊃header)↓data
                              :If chunked←∨/'chunked'⍷(2⊃header)U.GetValue'Transfer-Encoding' ''
                                  chunk←data
                                  data←''
                              :Else
                                  datalen←⊃((2⊃header)U.GetValue'Content-Length' 'Numeric'),¯1 ⍝ ¯1 if no content length not specified
                              :EndIf
                          :EndIf
                      :EndIf
                  :Else
                      ⎕←wr ⍝ Error?
                      ∘∘∘
                  :EndIf
                  :If chunked
                      buffer,←chunk
                      :While done<¯1≠⊃(len chunklength)←getchunklen buffer
                          :If (⍴buffer)≥4+len+chunklength
                              data,←chunklength↑(len+2)↓buffer
                              buffer←(chunklength+len+4)↓buffer
                              :If done←0=chunklength ⍝ chunked transfer can add headers at the end of the transmission
                                  header[2]←⊂(2⊃header)⍪2⊃U.DecodeHeader buffer
                              :EndIf
                          :EndIf
                      :EndWhile
                  :Else
                      done←done∨'BlockLast'≡3⊃wr                        ⍝ Done if socket was closed
                      :If datalen>0
                          done←done∨datalen≤⍴data ⍝ ... or if declared amount of data rcvd
                      :Else
                          done←done∨(∨/'</html>'⍷data)∨(∨/'</HTML>'⍷data)
                      :EndIf
                  :EndIf
              :EndIf
          :Until done
     
          :Trap 0 ⍝ If any errors occur, abandon conversion
              :If ∨/'deflate'⍷(2⊃header)U.GetValue'content-encoding' '' ⍝ was the response compressed?
                  data←fromutf8 DRC.flate.Inflate 120 156{(2×⍺≡2↑⍵)↓⍺,⍵}256|83 ⎕DR data ⍝ append 120 156 signature because web servers strip it out due to IE
              :ElseIf ∨/'charset=utf-8'⍷(2⊃header)U.GetValue'content-type' ''
                  data←'UTF-8'⎕UCS ⎕UCS data ⍝ Convert from UTF-8
              :EndIf
          :EndTrap
     
          :If {(⍵[3]∊'12357')∧'30 '≡⍵[1 2 4]}4↑{⍵↓⍨⍵⍳' '}(⊂1 1)⊃2⊃header ⍝ redirected? (HTTP status codes 301, 302, 303, 305, 307)
              →GET⍴⍨0<⍴url←'location'{(⍵[;1]⍳⊂⍺)⊃⍵[;2],⊂''}2⊃header ⍝ use the "location" header field for the URL
          :EndIf
     
          r←(1⊃wr)(2⊃header)data
     
          :If secure ⋄ r←r,⊂DRC.GetProp cmd'PeerCert' ⋄ :EndIf
      :Else
          'Connection failed ',,⍕r
      :EndIf
     
      z←DRC.Close cmd
    ∇

    ∇ r←{certs}HTTPPost args;U;DRC;protocol;wr;key;flags;pars;secure;data;z;header;datalen;host;port;done;cmd;b;page;auth;p;x509;priority;err;req;fromutf8;chunked;chunk;h2d;buffer;chunklength;len;getchunklen;parms;url
     ⍝ Get an HTTP page, format [HTTP[S]://][user:pass@]url[:port][/page] {namespace of parameters}
     ⍝ Opional Left argument: PublicCert PrivateKey SSLValidation
     ⍝ Makes secure connection if left arg provided or URL begins with https:
     
     ⍝ Result: (return code) (HTTP headers) (HTTP body) [PeerCert if secure]
     
      (U DRC)←##.(HTTPUtils DRC) ⍝ Uses utils from here
      fromutf8←{0::(⎕AV,'?')[⎕AVU⍳⍵] ⋄ 'UTF-8'⎕UCS ⍵} ⍝ Turn raw UTF-8 input into text
      h2d←{⎕IO←0 ⋄ 16⊥'0123456789abcdef'⍳U.lc ⍵} ⍝ hex to decimal
      getchunklen←{¯1=len←¯1+⊃(NL⍷⍵)/⍳⍴⍵:¯1 ¯1 ⋄ chunklen←h2d len↑⍵ ⋄ (⍴⍵)<len+chunklen+4:¯1 ¯1 ⋄ len chunklen}
     
      {}DRC.Init''
      args←{,(⊂⍣(1=≡⍵))⍵}args
     
      (url parms)←args,(⍴args)↓''(⎕NS'')
      :If 326=⎕DR parms
          parms←{0∊⍴t←⍵.⎕NL ¯2:'' ⋄ 1↓⊃,/⍵{'&',⍵,'=',(⍕⍺⍎⍵)}¨t}parms
      :EndIf
     
     GET:
      p←(∨/b)×1+(b←'//'⍷url)⍳1
      secure←{6::⍵ ⋄ ⍵∨0<⍴,certs}(U.lc(p-2)↑url)≡'https:'
      port←(1+secure)⊃80 443 ⍝ Default HTTP/HTTPS port
      url←p↓url              ⍝ Remove HTTP[s]:// if present
      host page←'/'split url,(~'/'∊url)/'/'    ⍝ Extract host and page from url
     
      :If 0=⎕NC'certs' ⋄ certs←'' ⋄ :EndIf
     
      :If secure
          x509 flags priority←3↑certs,(⍴,certs)↓(⎕NEW ##.DRC.X509Cert)32 'NORMAL:!CTYPE-OPENPGP'  ⍝ 32=Do not validate Certs
          pars←('x509'x509)('SSLValidation'flags)('Priority'priority)
      :Else ⋄ pars←''
      :EndIf
     
      :If '@'∊host ⍝ Handle user:password@host...
          auth←NL,'Authorization: Basic ',(U.Encode(¯1+p←host⍳'@')↑host)
          host←p↓host
      :Else ⋄ auth←''
      :EndIf
     
      host port←port U.HostPort host ⍝ Check for override of port number
     
      req←'POST ',page,' HTTP/1.1',NL,'Host: ',host,NL,'User-Agent: Dyalog/Conga',NL,'Accept: */*',auth,NL ⍝ build the request
     
      :If DRC.flate.IsAvailable ⍝ if compression is available
          req,←'Accept-Encoding: deflate',NL ⍝ indicate we can accept it
      :EndIf
     
      req,←'Content-Length: ',(⍕⍴parms),NL
      req,←'Content-Type: application/x-www-form-urlencoded',NL
     
      :If 0=⊃(err cmd)←2↑r←DRC.Clt''host port'Text' 100000,pars ⍝ 100,000 is max receive buffer size
      :AndIf 0=⊃r←DRC.Send cmd(req,NL,parms)
     
          chunked chunk buffer chunklength←0 '' '' 0
          done data datalen header←0 ⍬ 0(0 ⍬)
          :Repeat
              :If ~done←0≠1⊃wr←DRC.Wait cmd 5000            ⍝ Wait up to 5 secs
                  :If wr[3]∊'Block' 'BlockLast'             ⍝ If we got some data
                      :If chunked
                          chunk←4⊃wr
                      :ElseIf 0<⍴data,←4⊃wr
                      :AndIf 0=1⊃header
                          header←U.DecodeHeader data
                          :If 0<1⊃header
                              data←(1⊃header)↓data
                              :If chunked←∨/'chunked'⍷(2⊃header)U.GetValue'Transfer-Encoding' ''
                                  chunk←data
                                  data←''
                              :Else
                                  datalen←⊃((2⊃header)U.GetValue'Content-Length' 'Numeric'),¯1 ⍝ ¯1 if no content length not specified
                              :EndIf
                          :EndIf
                      :EndIf
                  :Else
                      ⎕←wr ⍝ Error?
                      ∘∘∘
                  :EndIf
                  :If chunked
                      buffer,←chunk
                      :While done<¯1≠⊃(len chunklength)←getchunklen buffer
                          :If (⍴buffer)≥4+len+chunklength
                              data,←chunklength↑(len+2)↓buffer
                              buffer←(chunklength+len+4)↓buffer
                              :If done←0=chunklength ⍝ chunked transfer can add headers at the end of the transmission
                                  header[2]←⊂(2⊃header)⍪2⊃U.DecodeHeader buffer
                              :EndIf
                          :EndIf
                      :EndWhile
                  :Else
                      done←done∨'BlockLast'≡3⊃wr                        ⍝ Done if socket was closed
                      :If datalen>0
                          done←done∨datalen≤⍴data ⍝ ... or if declared amount of data rcvd
                      :Else
                          done←done∨(∨/'</html>'⍷data)∨(∨/'</HTML>'⍷data)
                      :EndIf
                  :EndIf
              :EndIf
          :Until done
     
          :Trap 0 ⍝ If any errors occur, abandon conversion
              :If ∨/'deflate'⍷(2⊃header)U.GetValue'content-encoding' '' ⍝ was the response compressed?
                  data←fromutf8 DRC.flate.Inflate 120 156{(2×⍺≡2↑⍵)↓⍺,⍵}256|83 ⎕DR data ⍝ append 120 156 signature because web servers strip it out due to IE
              :ElseIf ∨/'charset=utf-8'⍷(2⊃header)U.GetValue'content-type' ''
                  data←'UTF-8'⎕UCS ⎕UCS data ⍝ Convert from UTF-8
              :EndIf
          :EndTrap
     
          :If {(⍵[3]∊'12357')∧'30 '≡⍵[1 2 4]}4↑{⍵↓⍨⍵⍳' '}(⊂1 1)⊃2⊃header ⍝ redirected? (HTTP status codes 301, 302, 303, 305, 307)
              →GET⍴⍨0<⍴url←'location'{(⍵[;1]⍳⊂⍺)⊃⍵[;2],⊂''}2⊃header ⍝ use the "location" header field for the URL
          :EndIf
     
          r←(1⊃wr)(2⊃header)data
     
          :If secure ⋄ r←r,⊂DRC.GetProp cmd'PeerCert' ⋄ :EndIf
      :Else
          'Connection failed ',,⍕r
      :EndIf
     
      z←DRC.Close cmd
    ∇

    ∇ {r}←RPCGet(client cmd);c;done;wr;z
     ⍝ Send a command to an RPC server (on an existing connection) and wait for the answer.
     
      :If 0=1⊃r c←##.DRC.Send client cmd
          :Repeat
              :If ~done←∧/100 0≠1⊃r←##.DRC.Wait c 10000 ⍝ Only wait 10 seconds
     
                  :Select 3⊃r
                  :Case 'Error'
                      done←1
                  :Case 'Progress'
     ⍝ progress report - update your GUI with 4⊃r?
                      ⎕←'Progress: ',4⊃r
                  :Case 'Receive'
                      done←1
                  :EndSelect
              :EndIf
          :Until done
      :EndIf
    ∇

    ∇ cert←ReadCert relfilename;certpath;fn
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
    ∇

    ∇ ret←ResetTest;count;error;msg;ret
      count←0
      error←0
      msg←''
     
      :While error=0
          ret←1 ##.DRC.Init''
          error←⊃ret
          :If error≠0
              msg←'init:'
              :Continue
          :EndIf
          ret←##.DRC.Srv'S1' '' 5000
          error←⊃ret
          :If error≠0
              msg←'server:'
              :Continue
          :EndIf
          ret←##.DRC.Clt'C1' '127.0.0.1' 5000
          error←⊃ret
          :If error≠0
              msg←'client: '
              :Continue
          :EndIf
          count+←1
      :EndWhile
      ret←count'succesful iterations. Failed with 'msg(⊃ret)(2⊃ret)
    ∇

    ∇ cmd SaveResult result
     ⍝ Collect results inside TestRPCServer
      results←results,⊂(2⊃cmd)'returned:'result
    ∇

    ∇ r←Say(cmd send tails);done;data;wr
     ⍝ On an open conversation (see OpenConversation), send something and wait for expected "tails"
     
      :If 0=1⊃r←##.DRC.Send cmd(⎕←send)           ⍝ Send something
          data done←'' 0
          :Repeat
              :Select 1⊃wr←##.DRC.Wait cmd 1000
              :Case 100 ⋄ ⍞←'.' ⍝ Time out
              :Case 0 ⋄ ⍞←4⊃wr
                  data,←4⊃wr
                  :If done←∨/((-⍴¨tails)↑¨⊂data)≡¨tails   ⍝ We found a tail
                      r←0 data
                  :Else
                      done←done∨'BlockLast'≡3⊃wr
                  :EndIf
              :Else
                  →0
              :EndSelect
          :Until done
      :EndIf
    ∇

    ∇ r←SecureCallback(cmd session);⎕TRAP;cert;rc;cmd;head;call;r;html;user
     ⍝ An example of a simple function to handle web server requests
     ⍝ ⎕TRAP←0 'S' ⋄ ∘ ⍝ Debug Stop
     
      r←'Command:' 'Page:',[1.5]cmd.(Command Page)
      r←r⍪cmd.Arguments
      r←(GetUserFromCerts session.PeerCert)⍪r
     
      ⎕←'SecureServerFn:'r
     
      html←'border=1'##.HTTPUtils.Table r
     
     ⍝ --- Add "nice" formatting ---
     
      html←'<p class="heading1">Secure Web Server Demo</p><br>',html
      html←'<div id="content">',html,'</div>'
     
      head←Style,'<title>Secure Server Function</title>'
      html←'<html><head>',head,'</head><body>',html,'</body></html>'
     
      r←0 ''html
    ∇

    ∇ (count mean median mode)←StatCalc nums;sorted;n
     ⍝ Clever Statistical Calculations!
     
      count←⍬⍴⍴nums
      sorted←{⍵[⍋⍵]}nums
      n←{-⍵-1↓⍵,1+⍴sorted}{⍵/⍳⍴⍵}1,2≠/sorted ⍝ # occurrences of each
     
      mean←⍬⍴{(+/⍵)÷⍴⍵}nums                  ⍝ mean: the average
      median←⍬⍴sorted[⌈0.5×⍴sorted]          ⍝ median: number which splits set in two equal halves
      mode←sorted[+/(n⍳⌈/n)↑n]               ⍝ mode: most frequently occurring number
    ∇

    ∇ r←Style;NL
     ⍝ Return a reasonably nice style
     
      NL←⎕AV[4 3]
      r←'<style type="text/css">'
     
      r,←NL,'BODY { color: #000000; background-color: white; font-family: Verdana; margin-left: 0px; margin-top: 0px; }'
      r,←NL,'#content { margin-left: 30px; font-size: .70em; padding-bottom: 2em; }'
      r,←NL,'A:link { color: #336699; font-weight: bold; text-decoration: underline; }'
      r,←NL,'A:visited { color: #6699cc; font-weight: bold; text-decoration: underline; }'
      r,←NL,'A:active { color: #336699; font-weight: bold; text-decoration: underline; }'
      r,←NL,'A:hover { color: cc3300; font-weight: bold; text-decoration: underline; }'
      r,←NL,'P { color: #000000; margin-top: 0px; margin-bottom: 12px; font-family: Verdana; }'
      r,←NL,'pre { background-color: #e5e5cc; padding: 5px; font-family: Courier New; font-size: x-small; margin-top: -5px; border: 1px #f0f0e0 solid; }'
      r,←NL,'td { color: #000000; font-family: Verdana; font-size: .7em; }'
      r,←NL,'h2 { font-size: 1.5em; font-weight: bold; margin-top: 25px; margin-bottom: 10px; border-top: 1px solid #003366; margin-left: -15px; color: #003366; }'
      r,←NL,'h3 { font-size: 1.1em; color: #000000; margin-left: -15px; margin-top: 10px; margin-bottom: 10px; }'
      r,←NL,'ul { margin-top: 10px; margin-left: 20px; }'
      r,←NL,'ol { margin-top: 10px; margin-left: 20px; }'
      r,←NL,'li { margin-top: 10px; color: #000000; }'
      r,←NL,'font.value { color: darkblue; font: bold; }'
      r,←NL,'font.key { color: darkgreen; font: bold; }'
      r,←NL,'font.error { color: darkred; font: bold; }'
      r,←NL,'.heading1 { color: #ffffff; font-family: Tahoma; font-size: 26px; font-weight: normal; background-color: #003366; margin-top: 0px; margin-bottom: 0px; margin-left: -30px; padding-top: 10px; padding-bottom: 3px; padding-left: 15px; width: 105%; }'
      r,←NL,'.button { background-color: #dcdcdc; font-family: Verdana; font-size: 1em; border-top: #cccccc 1px solid; border-bottom: #666666 1px solid; border-left: #cccccc 1px solid; border-right: #666666 1px solid; }'
      r,←NL,'.frmheader { color: #000000; background: #dcdcdc; font-family: Verdana; font-size: .7em; font-weight: normal; border-bottom: 1px solid #dcdcdc; padding-top: 2px; padding-bottom: 2px; }'
      r,←NL,'.frmtext { font-family: Verdana; font-size: .7em; margin-top: 8px; margin-bottom: 0px; margin-left: 32px; }'
      r,←NL,'.frmInput { font-family: Verdana; font-size: 1em; }'
      r,←NL,'.intro { margin-left: -15px; }'
     
      r,←NL,'</style>'
    ∇

    ∇ TestAll
      ⎕←'*** Running all tests ***'
     
      TestFTPClient
      TestRPCServer
      TestSimpleServices''
      {}TestWebClient''
      TestWebServer
    ∇

    ∇ TestAllSecure;certpath
     ⍝ Run all Secure tests
      {}1 ##.DRC.Init''
      :Trap 22 ⍝ Check that we can find the certificates
          certpath←CertPath
      :Else
          ⎕←'Secure tests cancelled...' ⋄ →0
      :EndTrap
     
      TestX509Certs   ⍝ Read certificates from files into X509Cert instances
     
     
      TestSecureConnection
      TestSecureWebServer
      TestSecureWebServerCB 1
      TestSecureTelnetServer
      2↑TestSecureWebClient
    ∇

    ∇ TestCompression;Data;CompData9;test;d;r;b;de;BlockSizes;in;bs;comp;bsi;bso;DataSets;compressions;testQ;ts;tl
      DataSets←(⎕UCS 2000⍴'Dette er en test ')(¯1+?3000⍴256)
      :If 0=⊃r←HTTPGet'http://www.dyalog.com'
          DataSets,←⊂⎕UCS 3⊃r
      :EndIf
      Data←⊃DataSets
      CompData9←120 156 115 73 45 41 73 85 72 45 82 72 205 83 40 73 45 46 81 112 25 21 24 21 24 21 24 21 24 21 24 21 24 21 24 106 2 0 67 195 179 95
      BlockSizes←10 100 1000 10000 100000⍝5 11 17 37 67 131 257 521 1031 2053 4099 8209 16411 32771 65537,2*1+⍳10
      BlockSizes←BlockSizes[⍋BlockSizes]
      compressions←¯1,⍳9
      test←{⍺,('Failed' 'OK')[⎕IO+⍵]}
      testQ←{0=⍵:⍺,'Failed'}
     
      'Deflate 'test CompData9≡##.DRC.flate.Deflate Data
      'Inflate 'test Data≡##.DRC.flate.Inflate CompData9
     ⍝      :For Data :In DataSets
     ⍝
     ⍝          ('Deflate   ',8 0⍕(⍴Data),(100-100×(⍴r)÷⍴Data))test Data≡##.DRC.flate.Inflate r←##.DRC.flate.Deflate Data
     ⍝      :EndFor
     
      tl←ts←##.DRC.Micros
      :For Data :In DataSets
     
     
     
          :For comp :In compressions
              ##.DRC.flate.defaultcomp←comp
              ('Deflate   ',8 0⍕(comp),(⍴Data),(100-100×(⍴r)÷⍴Data),((##.DRC.Micros-tl)÷1000))test Data≡##.DRC.flate.Inflate r←##.DRC.flate.Deflate Data
              tl←##.DRC.Micros
              :For bsi :In BlockSizes
     
                  :For bso :In BlockSizes
     
                      d←Data
                      r←⍬
                      de←⎕NEW ##.DRC.flate(0 comp bso)
     
                      :Repeat
     
                          b←(bsi⌊⍴d)↑d
                          d←(⍴b)↓d
                          :If 0=⍴d ⋄ de.EndOfInput ⋄ ⋄ :EndIf
                          r,←de.Process b
                      :Until de.EndOfOutput
                      ('Deflate compression ',(2 0⍕comp),' buffersize ',8 0⍕bsi bso,(⍴r))testQ Data≡##.DRC.flate.Inflate r
                      ⎕EX'de'
     
                      d←r
                      r←⍬
                      in←⎕NEW ##.DRC.flate(1 ¯1 bso)
     
                      :Repeat
     
                          b←(bsi⌊⍴d)↑d
                          d←(⍴b)↓d
                          :If 0=⍴d ⋄ in.EndOfInput ⋄ :EndIf
                          r,←in.Process b
                      :Until in.EndOfOutput
                      ('Inflate compression ',(2 0⍕comp),' buffersize ',8 0⍕bsi bso,(⍴r))testQ Data≡r
                      ⎕EX'in'
     
     
                  :EndFor
              :EndFor
          :EndFor
      :EndFor
      'TestCompression Ends ',8 0⍕(##.DRC.Micros-ts)÷1000
    ∇

    ∇ TestFTPClient;z;pub;CR;readme;host;user;pass;folder;file;sub;⎕ML;path
⍝ Test the FTP Client
     
      CR←1⊃NL ⋄ ⎕ML←1
      host user pass←'ftp.mirrorservice.org' 'anonymous' 'testing'
      path←∊(folder sub file)←'pub/' 'FreeBSD/' 'README.TXT'
     
      :Trap 0
          z←⎕NEW ##.FTPClient(host user pass)
      :Else
          ⎕←'Unable to connect to ',host ⋄ →0
      :EndTrap
     
     
      :If 0≠1⊃pub←z.List folder
          ⎕←'Unable to list contents of folder: ',,⍕pub ⋄ →0
      :EndIf
     
      :If ~∨/(¯1↓sub)⍷2⊃pub
          ⎕←'Sub folder ',sub,' not found in folder ',folder,': ',file ⋄ →0
      :EndIf
     
      :If 0≠1⊃readme←z.Get path
          ⎕←'File not found in folder ',folder,': ',file ⋄ →0
      :EndIf
     
      ⎕←path,' from ',host,':',CR
      ⎕←(⍕⍴2⊃readme),' characters read'
    ∇

    ∇ r←TestRPCServer;cmds;name;z;i;tnums;results
     ⍝ Start an RPC server, ask it some things
     
      {}1 ##.DRC.Init''
      :If 0=1⊃r←##.RPCServer.Run'RPCSRV' 5050
          ⎕DL 1 ⍝ Give the server a change to wake up
     
     ⍝ Fetch n pages using a separate client thread for each
      :AndIf 0=1⊃r←##.DRC.Clt'' 'localhost' 5050 ⍝ Make one client!
          name←2⊃r ⍝ Client name
          cmds←('Foo' 1)('Goo' 2)('Foo' 3)('Goo' 4)
          results←tnums←⍬
          :For i :In ⍳⍴cmds
              tnums,←{⍵ SaveResult RPCGet ⍵}&name(i⊃cmds)
          :EndFor
          ⎕TSYNC tnums
          :If 0∨.≠(⊂3 1)⊃¨results ⋄ ∘ :EndIf ⍝ Errors
          r←↑results ⋄ r[;3]←4⊃¨r[;3]
          {}RPCGet name('End' 1) ⍝ Shut down the server
          {}##.DRC.Wait name 5000 ⍝ Give server time to shut down
      :EndIf
      {}##.DRC.Close name
    ∇

    ∇ TestSecureConnection;ret;certpath;c;flags;srvcert;srvkey;cltkey;cltcert;z;data;y;i;yy;zz;type;port
     ⍝ Test the ability to create a Secure Connection
      type←⍬ ⍝ Type of connection to create
      port←5001 ⍝ Port to use for tests
     
     
      1 ##.DRC.Init''
      ##.DRC.SetProp'.' 'RootCertDir'(CertPath,'ca')
     
     ⍝ Create a secure server
      flags←64+32 ⍝ Request ClientCertificate, don't validate it
      ret←##.DRC.Srv'S1' ''port,type,('X509'server)('SSLValidation'flags)
      :If 0≠1⊃ret
          ⎕←'Server returned error:'ret
          →0
      :EndIf
     
     ⍝ Create a client of the secure server
      ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('SSLValidation' 16)('X509'client)
      :If 0≠1⊃ret
          ⎕←'Error creating Client:'ret
          →0
      :EndIf
     
      'Server Certificate'DisplayCert ##.DRC.GetProp'C1' 'PeerCert'
     
      c←##.DRC.Wait'S1' 10000 ⍝ First event on the server should be the connect event
      'Client Certificate'DisplayCert z←##.DRC.GetProp(2⊃c)'PeerCert'
     
      :If ~(1↑2⊃z)≡Cert 1↑y←2⊃##.DRC.GetProp'C1' 'OwnCert'
          ⎕←'Serverside Connections PeerCert does not match Clients OwnCert - that''s odd!'
          ∘
      :EndIf
     
      zz←##.DRC.GetProp(2⊃c)'OwnCert'
      :If ~(1↑2⊃zz)≡Cert 1↑yy←2⊃##.DRC.GetProp'C1' 'PeerCert'
          ⎕←'Serverside Connections OwnCert does not match Clients PeerCert - that''s odd!'
          ∘
      :EndIf
     
      data←'hello' 'this' 'is' 'a' 'test'(⍳3)
      {}##.DRC.Send'C1'data
      c←##.DRC.Wait'S1' 1000
     
      ##.DRC.Respond(2⊃c)(⌽4⊃c)
      z←##.DRC.Wait'C1' 10000
      :If data≡⌽4⊃z
          ⎕←'Secure Connection Test Successful'
      :Else
          ⎕←'Oops - sent:' 'Received:',[1.5]data z
      :EndIf
     
      {}##.DRC.Close¨'C1' 'S1'
    ∇

    ∇ {flags}TestSecureConnectionBHC(sm cm);ret;certpath;c;flags;srvcert;srvkey;cltkey;cltcert;z;data;y;i;yy;zz;type;port
     ⍝ Test the ability to create a Secure Connection
      type←⍬ ⍝ Type of connection to create
      port←5001 ⍝ Port to use for tests
     
      :If 0=⎕NC'flags'
          flags←128+64
      :EndIf
     ⍝ Prepare certificates and keys
     
      certpath←CertPath
     
      srvcert←certpath,'server/server-cert.pem'
      srvkey←certpath,'server/server-key.pem'
     
      cltcert←certpath,'client/client-cert.pem'
      cltkey←certpath,'client/client-key.pem'
     
      1 ##.DRC.Init''
      ##.DRC.SetProp'.' 'RootCertDir'(certpath,'ca')
     
     ⍝ Create a secure server
     ⍝flags←128+64
     ⍝flags←64+32 ⍝ Request ClientCertificate, don't validate it
      :Select sm
      :Case 0 ⍝ no security
          ret←##.DRC.Srv'S1' ''port,type
      :Case 1 ⍝ original way two certificate files in PEM format
          ret←##.DRC.Srv'S1' ''port,type,('PublicCertFile'('DER'srvcert))('PrivateKeyFile'('DER'srvkey))('SSLValidation'flags)
      :Case 2 ⍝ use X509 class
          server←⊃##.DRC.X509Cert.ReadCertFromFile srvcert
          server.KeyOrigin←'DER'srvkey
          ret←##.DRC.Srv'S1' ''port,type,('SSLValidation'flags)('X509'server)
      :Case 3 ⍝ Passing certificate in raw format
          server←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'server/server-cert.der'
          server.KeyOrigin←'DER'srvkey
          ret←##.DRC.Srv'S1' ''port,type,('PublicCertData'(server.Cert))('PrivateKeyFile'('DER'srvkey))('SSLValidation'flags)
     
      :Case 4 ⍝ Passing certificate in raw format with chain
          server←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'server/server-cert.der'
          server.KeyOrigin←'DER'srvkey
          ca←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'ca/ca-cert.pem'
          ret←##.DRC.Srv'S1' ''port,type,('PublicCertData'(server.Cert ca.Cert))('PrivateKeyFile'('DER'srvkey))('SSLValidation'flags)
      :EndSelect
     
      :If 0≠1⊃ret
          ⎕←'Server returned error:'ret
          →0
      :EndIf
     
     ⍝ Create a client of the secure server
      :Select cm
      :Case 0 ⍝ no Certificate
          ret←##.DRC.Clt'C1' '127.0.0.1'port,type
      :Case 1 ⍝ Original way two files
          ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('PublicCertFile'('DER'cltcert))('PrivateKeyFile'('DER'cltkey))('SSLValidation' 16)
      :Case 2 ⍝ use X509 class
          john←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/john-cert.pem'
          john.KeyOrigin←'DER'(certpath,'client/john-key.pem')
          ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('SSLValidation' 16)('X509'john)
      :Case 3 ⍝ Pasing raw certificate
          john←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/john-cert.pem'
          ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('PublicCertdata'(john.Cert))('PrivateKeyFile'('DER'(certpath,'Client/john-key.pem')))('SSLValidation' 16)
      :Case 4 ⍝ Certificate with chain
          ca←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'ca/ca-cert.pem'
          john←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/john-cert.pem'
          john.KeyOrigin←'DER'(certpath,'client/john-key.pem')
          ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('PublicCertdata'(john.Cert ca.Cert))('PrivateKeyFile'('DER'(certpath,'Client/john-key.pem')))('SSLValidation' 16)
      :Case 5 ⍝ read from MS Store
          certs←##.DRC.X509Cert.ReadCertFromStore'My'
          bhcca←certs{⊃(⍺.Formatted.Subject∊⊂⍵)/⍺}'C=DK,O=Insight Systems ApS,OU=Development,CN=Bjørn Christensen,UID=bhc'
          ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('SSLValidation' 16)('X509'bhcca)
      :Case 6
          certs←##.DRC.X509Cert.ReadCertFromStore'My'
          bhctdc←certs{⊃(⍺.Formatted.Subject∊⊂⍵)/⍺}'C=DK,O=Ingen organisatorisk tilknytning,CN=#426af8726e2048656c76696720436872697374656e73656e+serialNumber=PID:9208-2002-2-871917342843'
          ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('SSLValidation' 16)('X509'bhctdc)
      :Case 7
          hellebak←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/hellebak-cert.pem'
          hellebak.KeyOrigin←'DER'(certpath,'client/hellebak-key.pem')
          ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('SSLValidation' 16)('X509'hellebak)
      :Case 8
          bhcbak←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/bhcbak-cert.pem'
          bhcbak.KeyOrigin←'DER'(certpath,'client/bhcbak-key.pem')
          ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('SSLValidation' 16)('X509'bhcbak)
      :Case 9
          bhcbak←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/bhcbak-cert.pem'
          bhcbak.KeyOrigin←'DER'(certpath,'client/bhcbak-key.pem')
          hellebak←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'client/hellebak-cert.pem'
          hellebak.KeyOrigin←'DER'(certpath,'client/hellebak-key.pem')
          ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('PublicCertdata'(bhcbak.Cert hellebak.Cert))('PrivateKeyFile'('DER'(certpath,'Client/bhcbak-key.pem')))('SSLValidation' 16)
      :Case 10 ⍝ Original way two files
          ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('PublicCertFile'('DER'(certpath,'client/bhcbakc-cert.pem')))('PrivateKeyFile'('DER'(certpath,'client/bhcbak-key.pem')))('SSLValidation' 16)
     
      :EndSelect
     
      :If 0≠1⊃ret
          ⎕←'Error creating Client:'ret
          →0
      :EndIf
     
      'Server Certificate'DisplayCert ##.DRC.GetProp'C1' 'PeerCert'
     
      c←##.DRC.Wait'S1' 10000 ⍝ First event on the server should be the connect event
      'Client Certificate'DisplayCert z←##.DRC.GetProp(2⊃c)'PeerCert'
      :If 0<⊃⍴2⊃z
      :AndIf ~(1↑2⊃z)≡Cert 1↑y←2⊃##.DRC.GetProp'C1' 'OwnCert'
          ⎕←'Serverside Connections PeerCert does not match Clients OwnCert - that''s odd!'
          ∘
      :EndIf
     
      zz←##.DRC.GetProp(2⊃c)'OwnCert'
      :If 0<⊃⍴2⊃zz
      :AndIf ~(1↑2⊃zz)≡Cert 1↑yy←2⊃##.DRC.GetProp'C1' 'PeerCert'
          ⎕←'Serverside Connections OwnCert does not match Clients PeerCert - that''s odd!'
          ∘
      :EndIf
     
      data←'hello' 'this' 'is' 'a' 'test'(⍳3)
      {}##.DRC.Send'C1'data
      c←##.DRC.Wait'S1' 1000
     
      ##.DRC.Respond(2⊃c)(⌽4⊃c)
      z←##.DRC.Wait'C1' 10000
      :If data≡⌽4⊃z
          ⎕←'Secure Connection Test Successful'
      :Else
          ⎕←'Oops - sent:' 'Received:',[1.5]data z
      :EndIf
     
      {}##.DRC.Close¨'C1' 'S1'
    ∇

    ∇ TestSecureConnectionTimeouts;ret;certpath;c;flags;srvcert;srvkey;cltkey;cltcert;z;data;y;i;yy;zz;type;port
     ⍝ Test connecting a secure client to an insecure server - should timeout
      type←⍬ ⍝ Type of connection to create
      port←5001 ⍝ Port to use for tests
     
     ⍝ Prepare certificates and keys
     
      certpath←CertPath
     
      srvcert←certpath,'server/server-cert.pem'
      srvkey←certpath,'server/server-key.pem'
     
      cltcert←certpath,'client/client-cert.pem'
      cltkey←certpath,'client/client-key.pem'
     
      1 ##.DRC.Init''
      ##.DRC.SetProp'.' 'RootCertDir'(certpath,'ca')
     
     ⍝ Create a secure server
      flags←64+32 ⍝ Request ClientCertificate, don't validate it
     
      ⎕←'Secure client, insecure server'
      ret←##.DRC.Srv'S1' ''port,type
     
      :If 0≠1⊃ret
          ⎕←'Server returned error:'ret
      :EndIf
     
      ret←##.DRC.Clt'C1' '127.0.0.1'port,type,('CertFiles'cltcert)('KeyFile'cltkey)('SSLValidation' 16)
      :If 0≠1⊃ret
          ⎕←'Error creating Client:'ret
      :EndIf
     
     
      {}##.DRC.Close¨'C1' 'S1'
     
     
     ⍝ Now test connecting an insecure client to a secure server
      ⎕←'Insecure client, secure server'
     ⍝ Create a secure server
      flags←64+32 ⍝ Request ClientCertificate, don't validate it
      ret←##.DRC.Srv'S1' ''port,type,('PublicCert'srvcert)('PrivateCert'srvkey)('SSLValidation'flags)
     
      :If 0≠1⊃ret
          ⎕←'Server returned error:'ret?
      :EndIf
     
     ⍝ Create a client of the secure server
      ret←##.DRC.Clt'C1' '127.0.0.1'port,type
      :If 0≠1⊃ret
          ⎕←'Error creating Client:'ret
      :EndIf
     
     
      ⎕←'Done'
    ∇

    ∇ {flags}TestSecureServer sm;ret;certpath;c;flags;srvcert;srvkey;cltkey;cltcert;z;data;y;i;yy;zz;type;port
     ⍝ Test the ability to create a Secure Connection
      type←⊂'Text'  ⍝ Type of connection to create
      port←5001 ⍝ Port to use for tests
     
      :If 0=⎕NC'flags'
          flags←128+64
      :EndIf
     ⍝ Prepare certificates and keys
     
      certpath←CertPath
     
      srvcert←certpath,'server/server-cert.pem'
      srvkey←certpath,'server/server-key.pem'
     
      cltcert←certpath,'client/client-cert.pem'
      cltkey←certpath,'client/client-key.pem'
     
      1 ##.DRC.Init''
      ##.DRC.SetProp'.' 'RootCertDir'(certpath,'ca')
     
     ⍝ Create a secure server
     ⍝flags←128+64
     ⍝flags←64+32 ⍝ Request ClientCertificate, don't validate it
      :Select sm
      :Case 0 ⍝ no security
          ret←##.DRC.Srv'S1' ''port,type
      :Case 1 ⍝ original way two certificate files in PEM format
          ret←##.DRC.Srv'S1' ''port,type,('PublicCertFile'('DER'srvcert))('PrivateKeyFile'('DER'srvkey))('SSLValidation'flags)
      :Case 2 ⍝ use X509 class
          server←⊃##.DRC.X509Cert.ReadCertFromFile srvcert
          server.KeyOrigin←'DER'srvkey
          ret←##.DRC.Srv'S1' ''port,type,('SSLValidation'flags)('X509'server)
      :Case 3 ⍝ Passing certificate in raw format
          server←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'server/server-cert.der'
          server.KeyOrigin←'DER'srvkey
          ret←##.DRC.Srv'S1' ''port,type,('PublicCertData'(server.Cert))('PrivateKeyFile'('DER'srvkey))('SSLValidation'flags)
     
      :Case 4 ⍝ Passing certificate in raw format with chain
          server←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'server/server-cert.der'
          server.KeyOrigin←'DER'srvkey
          ca←⊃##.DRC.X509Cert.ReadCertFromFile certpath,'ca/ca-cert.pem'
          ret←##.DRC.Srv'S1' ''port,type,('PublicCertData'(server.Cert ca.Cert))('PrivateKeyFile'('DER'srvkey))('SSLValidation'flags)
      :EndSelect
     
      :If 0≠1⊃ret
          ⎕←'Server returned error:'ret
          →0
      :EndIf
     
     
      :While 1
          rs←##.DRC.Wait'S1' 10000
          :If 0=⊃rs
              :If 'Connect'≡3⊃rs
                  'Client Certificate'DisplayCert z←##.DRC.GetProp(2⊃rs)'PeerCert'
              :EndIf
          :EndIf
      :EndWhile
     
     
      {}##.DRC.Close¨'C1' 'S1'
    ∇

    ∇ TestSecureTelnetServer;cmd2;rc;cmd1;port;host;i;cmds;cmd;prompt;CR;certpath;tid
     ⍝ Test the Secure Telnet Server
     
      host port←'localhost' 5023 ⍝ Default port is 23
      tid←##.TelnetServer.Run&server
      ⎕DL 2
     
      cmds←⍬
      prompt←NL,'    '
      CR←1⊃NL
     
      :For i :In ⍳2 ⍝ Login to two sessions
          rc cmd←2↑##.DRC.Clt''host port'Text' 10000('X509'geoff)('SSLValidation' 16)
          {}Say cmd''(⊂prompt)
     ⍝{}Say cmd''(⊂'User: ')
     ⍝{}Say cmd('mkrom',CR)(⊂'Password: ')
     ⍝{}Say cmd('secret',CR)(⊂prompt)
          cmds←cmds,⊂cmd
      :EndFor
     
      :For i :In ⍳⍴cmds ⍝ Make the sessions do something
          {}Say(i⊃cmds)('2+2',CR)(⊂prompt)
      :EndFor
     
      ##.DRC.Send(1⊃cmds)(')END',CR)
      :While tid∊⎕TNUMS ⋄ ⎕DL 1 ⋄ :EndWhile ⍝ Wait for server thread to close down
      ##.DRC.Close¨cmds
    ∇

    ∇ z←TestSecureWebClient;certpath
     ⍝ Read a sample secure page from the internet
     
      {}1 ##.DRC.Init''
      ##.DRC.SetProp'.' 'RootCertDir'(CertPath,'ca')
      z←HTTPGet'https://test.gnutls.org:5556'
    ∇

    ∇ {r}←TestSecureWebServer;files;folder;cmd;tid;port;cert
     ⍝ Start a web server, request a page from it, kill it
     
      port←8080
      {}1 ##.DRC.Init'' ⍝ Kill all Conga objects
      ##.DRC.SetProp'.' 'RootCertDir'(CertPath,'ca')
     
      folder←+2 ⎕NQ'.' 'GetEnvironment' 'Dyalog'
      folder,←'samples\asp.net\tutorial'
     
      tid←##.WebServer.HttpsRun&folder port'HTTPSRV'server
      ⎕DL 1 ⍝ Give the server a chance to wake up
     
      :If 0=1⊃(r cmd)←2↑##.DRC.Clt'' 'localhost'port'Text' 10000('X509'client)('SSLValidation' 16)
          'Web Server Certificate:'DisplayCert ##.DRC.GetProp cmd'PeerCert'
      :Else
          r cmd ⋄ →
      :EndIf
     
     ⍝ Fetch n pages using a separate client thread for each
      files←(⊂'notthere.htm'),{'intro',(⍕⍵),'.htm'}¨⍳10
      r←{⎕TSYNC client HTTPGet&'https://localhost:8080/',⍵}¨files
      :If 0∨.≠⊃¨1⊃¨r ⋄ ∘ :EndIf ⍝ Errors
     
      {}##.DRC.Close¨cmd'HTTPSRV'
      r←files,[1.5]4⊃¨r
     
      :While tid∊⎕TNUMS ⋄ ⎕DL 1 ⋄ :EndWhile ⍝ Wait for server thread to close down
    ∇

    ∇ {r}←TestSecureWebServerCB stop;files;folder;cmd;cltcert;cltkey;certpath;tid;port
     ⍝ Start a web server, request a page from it, kill it
     
      port←8081
     
      {}1 ##.DRC.Init'' ⍝ Kill all Conga objects
      ##.DRC.SetProp'.' 'RootCertDir'(CertPath,'ca')
     
      tid←##.WebServer.HttpsRun&'#.Samples.SecureCallback'port'HTTPSRV'server
      ⎕DL 1 ⍝ Give the server a change to wake up
     
      :If 0=1⊃(r cmd)←2↑##.DRC.Clt'' 'localhost'port'Text' 10000('X509'john)('SSLValidation' 16)
          ⎕←'Web Server Certificate:' ⋄ 'Cert'DisplayCert ##.DRC.GetProp cmd'PeerCert'
      :Else
          r cmd ⋄ →
      :EndIf
     
     ⍝ Fetch a page
      r←john 16 HTTPGet'https://localhost:8081/foo?arg1=1 2 3&arg2=4 5 6'
     
      {}##.DRC.Close cmd
     
      :If stop ⋄ {}##.DRC.Close'HTTPSRV'
      :Else ⋄ 'Server still running - to stop it:' ⋄ '' ⋄ '      ##.DRC.Close''HTTPSRV'''
      :EndIf
     
      :While tid∊⎕TNUMS ⋄ ⎕DL 1 ⋄ :EndWhile ⍝ Wait for server thread to close down
    ∇

    ∇ TestSimpleServices host;fmt
     ⍝ Test some common simple TCP Services
     
      host←host,(0=⍴host)/'localhost'
      fmt←{0=1⊃⍵:(2⊃⍵)~⎕AV[4] ⋄ ⍵} ⍝ Format result of GetSocket
     
      'daytime (port 13): ' ⋄ fmt GetSimpleServiceData host 13
      'quote of the day (port 17):' ⋄ fmt GetSimpleServiceData host 17
    ∇

    ∇ TestTelnetServer;cmd2;rc;cmd1;port;host;i;cmds;cmd;prompt;CR
     ⍝ Test the Telnet Server
     
      host port←'localhost' 5023 ⍝ Default port is 23
      ##.TelnetServer.Run&⍬
      ⎕DL 2 ⍝ Give it time to start
     
      cmds←⍬
      prompt←NL,'    '
      CR←1⊃NL
     
      :For i :In ⍳2 ⍝ Login to two sessions
          rc cmd←##.DRC.Clt''host port'Text' 10000
          {}Say cmd''(⊂'User: ')
          {}Say cmd('mkrom',CR)(⊂'Password: ')
          {}Say cmd('secret',CR)(⊂prompt)
          cmds←cmds,⊂cmd
      :EndFor
     
      :For i :In ⍳⍴cmds ⍝ Make the sessions do something
          {}Say cmd('2+2',CR)(⊂prompt)
      :EndFor
     
      ##.DRC.Send(1⊃cmds)(')END',CR)
      ⎕DL 2
      ##.DRC.Close¨cmds
    ∇

    ∇ z←TestWebClient url
     ⍝ Get something from "the web"
     
      url←url,(0=⍴url)/'http://www.dyalog.com/'
      z←HTTPGet url
    ∇

    ∇ {r}←TestWebFunctionServer;files
     ⍝ Start a web server, request a page from it, kill it
     
      {}1 ##.DRC.Init'' ⍝ Kill all Conga objects
      ##.WebServer.Run&'#.WebServer.TimeServer' 8080 'HTTPSRV'
      ⎕DL 1 ⍝ Give the server a change to wake up
     
     ⍝ Fetch n pages using a separate client thread for each
      files←(⊂'notthere'),{'page&id=',⍕⍵}¨⍳3
      r←{⎕TSYNC HTTPGet&'http://localhost:8080/',⍵}¨files
      :If 0∨.≠⊃¨1⊃¨r ⋄ ∘ :EndIf ⍝ Errors
      {}##.DRC.Close'HTTPSRV'
      r←files,[1.5]3⊃¨r
    ∇

    ∇ {r}←TestWebServer;files;folder;tid
     ⍝ Start a web server, request a page from it, kill it
     
      {}1 ##.DRC.Init'' ⍝ Kill all Conga objects
      folder←+2 ⎕NQ'.' 'GetEnvironment' 'Dyalog'
      folder,←'samples\asp.net\tutorial'
     
      tid←##.WebServer.Run&folder 8080 'HTTPSRV'
      ⎕DL 1 ⍝ Give the server a chance to wake up
     
     ⍝ Fetch n pages using a separate client thread for each
      files←(⊂'notthere.htm'),{'intro',(⍕⍵),'.htm'}¨⍳10
      r←{⎕TSYNC HTTPGet&'http://localhost:8080/',⍵}¨files
      :If 0∨.≠⊃¨1⊃¨r ⋄ ∘ :EndIf ⍝ Errors
      {}##.DRC.Close'HTTPSRV'
      r←files,[1.5]3⊃¨r
     
      :While tid∊⎕TNUMS ⋄ ⎕DL 1 ⋄ :EndWhile ⍝ Wait for server thread to close down
    ∇

    ∇ TestX509Certs;certpath;srvcert;srvkey;cltcert;cltkey;ic;ifcs;iscs
     
     
      john←ReadCert'client/john'
      geoff←ReadCert'client/geoff'
      client←ReadCert'client/client'
      ca←ReadCert'ca/ca'
      server←ReadCert'server/server'
     
      hellebak←ReadCert'client/hellebak'
      bhcbak←ReadCert'client/bhcbak'
      bhcbakc←ReadCert'client/bhcbakc'
     
     
     
     ⍝ ifcs←#.DRC.X509Cert.ReadCertFromFolder certpath,'client/*-cert.pem'
     
      iscs←#.DRC.X509Cert.ReadCertFromStore'My'
      :If 0<⍴iscs
          ↑iscs.Formatted.Subject
      :EndIf
     ⍝'My Store certificates'DisplayCert 0 iscs
    ∇

    split←{(p↑⍵)((p←¯1+⍵⍳⍺)↓⍵)}

    Cert←{(⍺.Cert)⍺⍺ ⍵.Cert}


:EndNamespace
