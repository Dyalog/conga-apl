 r←{certs}(cmd HTTPCmd)args;U;DRC;fromutf8;h2d;getchunklen;eis;getHeader;addHeader;makeHeaders;fmtHeaders;url;parms;hdrs;b;p;secure;port;host;page;x509;flags;priority;pars;auth;req;err;chunked;chunk;buffer;chunklength;header;datalen;data;done;wr;len;cmd;urlparms
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
