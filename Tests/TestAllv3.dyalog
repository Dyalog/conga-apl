:Namespace TestAllv3
    (⎕IO ⎕ML ⎕WX)←1 0 3
    StopOnError←0
    show←0

    ⍝ here be dragons
    Report←{⍵≠1: 'Failed: ',(2⊃⎕xsi),'[',(⍕2⊃⎕lc),']'⋄  }
    Assert←{⍺≡⍵:1 ⋄ Error 'Failed: ',(2⊃⎕xsi),'[',(⍕2⊃⎕lc),']'  }

    ∇ r←Error arg
      :If show
          ⎕←arg
      :EndIf
      Errors,←⊂arg
      arg ⎕SIGNAL StopOnError/11
      r←0
    ∇

    ∇ Log arg
      :If show
          ⎕←arg
      :EndIf
    ∇

    ∇ At s
      ⎕DL 60|(s-6⊃⎕TS)
      ⎕TS
    ∇

    ∇ r←apltype utf8 len;b;us;d
      r←''
      b←127 2047 65535 2097151 67108863 2147483647
      us←1 2 3 4 5 6
      d←1 2 2 4 4 4
      :Select apltype
      :Case 80
          r←⎕UCS len↑(,⍉0 1∘.+1↑b),?len⍴255
      :Case 160
          r←⎕UCS len↑(,⍉0 1∘.+2↑b),(3⊃b),?len⍴65535
     
      :Case 320
     
        ⍝r←320 ⎕dr  len↑ (,⍉0 1 ∘.+5↑b),(6⊃b) , ?len⍴2147483647
          r←⎕UCS len↑(,⍉0 1∘.+3↑b),1114111,?len⍴1114111
     
      :Else
          ⎕SIGNAL 11
      :EndSelect
    ∇


    ∇ MakeFile(name size data);nopen;tie
      nopen←{                              ⍝ handle on null file.
          0::⎕SIGNAL ⎕EN                  ⍝ signal error to caller.
          22::⍵ ⎕NCREATE 0                ⍝ ~exists: create.
          ⍵ ⎕NTIE 0                      ⍝  exists: tie.
      }
      tie←nopen name
      0 ⎕NRESIZE tie
      (size⍴data)⎕NAPPEND tie
      ⎕NUNTIE tie
    ∇


    ∇ cp←CertPath;instpath
      instpath←2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'
      cp←instpath,'/TestCertificates/'
    ∇

    ∇ cert←ReadCert relfilename;fn
     
      fn←CertPath,relfilename
      cert←⊃#.DRCShared.X509Cert.ReadCertFromFile fn,'-cert.pem'
      cert.KeyOrigin←'DER' (fn,'-key.pem')
    ∇

    ∇ r←name DisplayCert z;dc;nc
⍝ Display information about a certificate
      dc←{,[1.5](2⊃⍵)[1 2 3 4 5 6]}
      nc←,[1.5]name'Version' 'SerialNo' 'Subject' 'Issuer' 'ValidFrom' 'ValidTo'
      dc←{⍵.(Formatted.(Version SerialNo Subject Issuer),Elements.(ValidFrom ValidTo))}
      :If 0=1⊃z
      :AndIf 0<⊃⍴2⊃z
          r←nc,' '⍪⍉↑dc¨2⊃z
      :Else ⋄ r←('Unable to retrieve ',name)z
      :EndIf
    ∇

    ∇ r←TestSimple(prot secure);srvx509;cltx509;Port;c;Host;srv;clt;DefaultWaitTime;rs;con;srvcert;cltcert;pa;la
      r←1
      Port←5000
      Host←'localhost'
      srv←'S1'
      clt←'C1'
      DefaultWaitTime←5000
      Cert←{(⍺.Cert)⍺⍺ ⍵.Cert}
        
      r∧←0 Assert⊃c←#.DRC.SetProp'.' 'EventMode' 0
      :If secure
          srvx509←ReadCert'server/localhost'
          cltx509←ReadCert'client/client'
          r∧←0 Assert⊃c←#.DRC.SetProp'.' 'RootCertDir'(CertPath,'ca')
      :else
         srvx509←cltx509←⍬
      :EndIf
      r∧←0 srv Assert c←#.DRC.Srv srv''Port,((prot≢'')/⊂('Protocol'prot)),secure/('X509'srvx509)('SSLValidation'(64))
      r∧←0 clt Assert c←#.DRC.Clt clt Host Port,((prot≢'')/⊂('Protocol'prot)),secure/('x509'cltx509)('SSLValidation'(0))
     
      r∧←0 Assert⊃c←#.DRC.Send clt'Request1'
     
      r∧←0 'Connect' 0 Assert(⊂1 3 4)⌷rs←#.DRC.Wait srv DefaultWaitTime
      con←2⊃rs
      :If secure
          Log'Server Certificate'DisplayCert srvcert←#.DRC.GetProp clt'PeerCert'
          Log'Client Certificate'DisplayCert cltcert←#.DRC.GetProp con'PeerCert'
          r∧←(2 1⊃srvcert)Assert Cert 2 1⊃#.DRC.GetProp con'OwnCert'
          r∧←(2 1⊃cltcert)Assert Cert 2 1⊃#.DRC.GetProp clt'OwnCert'
      :EndIf
     
      r∧←0 'Receive' 'Request1'Assert(⊂1 3 4)⌷rs←#.DRC.Wait srv DefaultWaitTime
     
      r∧←0 Assert⊃c←#.DRC.Respond(2⊃rs)(⌽4⊃rs)
     
      r∧←0 'Receive'(⌽'Request1')Assert(⊂1 3 4)⌷rs←#.DRC.Wait clt DefaultWaitTime
     
      r∧←0 Assert⊃pa←#.DRC.GetProp clt'PeerAddr'
      r∧←0 Assert⊃la←#.DRC.GetProp con'LocalAddr'
      r∧←(2 2⊃la)Assert 2 2⊃pa
     
     
      r∧←0 Assert⊃la←#.DRC.GetProp clt'LocalAddr'
      r∧←0 Assert⊃pa←#.DRC.GetProp con'PeerAddr'
     
      r∧←(2 2⊃la)Assert 2 2⊃pa
     
     
      r∧←0 Assert⊃c←#.DRC.Close clt
     
      r∧←0 'Error' 1119 Assert(⊂1 3 4)⌷rs←#.DRC.Wait srv DefaultWaitTime
     
      r∧←(,⊂srv) Assert #.DRC.Names'.'
     
     
      r∧←0 Assert⊃c←#.DRC.Close srv
     
    ∇


    ∇ r←TestRaw;port;data;size;rs;c1;type;mode;c
      port←5000
      to83←{⍵-256×⍵>127}
      r←1
      :For mode :In 'Raw' 'Blkraw'
          r∧←0 'S1'Assert c←#.DRC.Srv'S1' ''port mode(40+2*21)
          r∧←0 'C1'Assert c←#.DRC.Clt'C1' 'localhost'port mode(40+2*21)
          r∧←0 'Connect' 0 Assert(⊂1 3 4)⌷c1←#.DRC.Wait'S1' 5000
          :For type :In 83 163
              :For size :In ,(2*1+⍳20)∘.+¯1 0 1
                  data←(-⎕IO)+size⍴⍳256
     
                  r∧←0 Assert 1⊃c←#.DRC.Send'C1'(type{⍺=83:to83 ⍵ ⋄ ⍵}data)
                  rs←0
                  :While (rs<size)
                      :If 0 'Block'≡(⊂1 3)⌷c1←#.DRC.Wait'S1' 10000
                          r∧←(4⊃c1){⍺≡(⍴⍺)⍴⍵}rs{((⍴⍵)|⍺)⌽⍵}data
                          rs+←⍴4⊃c1
                      :Else
                          r←0
                          :Leave
                      :EndIf
                  :EndWhile
                  Log size r
              :EndFor
          :EndFor
          r∧←0 Assert⊃c←#.DRC.Close'C1'
          :If mode≡'Raw'
              r∧←0 'BlockLast'Assert(⊂1 3)⌷c1←#.DRC.Wait'S1' 5000
          :EndIf
          r∧←0 Assert⊃c←#.DRC.Close'S1'
      :EndFor
      Report r
     
    ∇

    ∇ r←TestSendFile;c1;size;rs;port;data
      port←5000
      data←'dette er en test '
      r←1
      r∧←0 'S1'Assert #.DRC.Srv'S1' ''port'Text'(2*16)
      r∧←0 'C1'Assert #.DRC.Clt'C1' 'localhost'port'Text'(2*16)
      r∧←0 'Connect' 0 Assert(⊂1 3 4)⌷c1←#.DRC.Wait'S1' 5000
      :For size :In ,(2*1+⍳20)∘.+¯1 0 1
          MakeFile'test.dat'size data
          r∧←0 Assert 1⊃#.DRC.Send'C1'('' 'test.dat')
          rs←0
          :While (rs<size)
              :If 0 'Block'≡(⊂1 3)⌷c1←#.DRC.Wait'S1' 5000
                  r∧←(4⊃c1){⍺≡(⍴⍺)⍴⍵}rs{((⍴⍵)|⍺)⌽⍵}data
                  rs+←⍴4⊃c1
              :Else
                  r←0
                  :Leave
              :EndIf
          :EndWhile
          Log size r
      :EndFor
      r∧←0=⊃c←#.DRC.Close'C1'
      r∧←0 'BlockLast'Assert(⊂1 3)⌷c1←#.DRC.Wait'S1' 5000
      r∧←0=⊃c←#.DRC.Close'S1'
      :Trap 0
          {⍵ ⎕NERASE ⍵ ⎕NTIE 0}'test.dat'
     
      :EndTrap
      Report r
    ∇

    ∇ r←TestSendFileBlk;c1;size;rs;port;data;c
      port←5000
      data←'dette er en test '
      r←1
      r∧←0 'S1'Assert c1←#.DRC.Srv'S1' ''port'BlkText'(2*30)('Magic'(#.DRC.Magic'BlkT'))
      r∧←0 'C1'Assert c1←#.DRC.Clt'C1' 'localhost'port'BlkText'(2*30)('Magic'(#.DRC.Magic'BlkT'))
      r∧←0 'Connect' 0 Assert(⊂1 3 4)⌷c1←#.DRC.Wait'S1' 5000
      :For size :In ,(2*1+⍳20)∘.+¯1 0 1
          MakeFile'test.dat'size data
          r∧←0=1⊃#.DRC.Send'C1'('' 'test.dat')
          r∧←0 'Block'Assert(⊂1 3)⌷c1←#.DRC.Wait'S1' 5000
          r∧←(size⍴data)Assert 4⊃c1
      :EndFor
      r∧←0 Assert⊃c←#.DRC.Close'C1'
      r∧←0 'Error' 1119 Assert(⊂1 3 4)⌷c1←#.DRC.Wait'S1' 5000
      r∧←0 Assert⊃c←#.DRC.Close'S1'
      :Trap 0
          {⍵ ⎕NERASE ⍵ ⎕NTIE 0}'test.dat'
     
      :EndTrap
      Report r
    ∇




    ∇ r←Cmd cmd;c
      r←0
      waitfor←{100=1⊃cw←#.DRC.Wait ⍺ 10000:⍺ ∇ ⍵
          (2⊃⍵)≡⍵[1]⌷4↑cw:0
          cw}
      :If 0=1⊃r←#.DRC.Send cmd cmd   ⍝ 3
      :AndIf 0=⊃r←cmd waitfor(1 3 4)(0 'Receive'(⌽cmd))
          r←0
      :Else
          Log'Client ',cmd,' failed ',r
          ⍝ r is set
      :EndIf
    ∇

    ∇ r←larg Client1 name;cmds;r;c;port;m
      m port←larg
      r←0
      :If 0=1⊃r←#.DRC.Clt name'localhost'port
          name←2⊃r
          cmds←(⊂name,'.'),¨'X',¨8{(-⍺)↑(⍺⍴'0'),⍕⍵}¨⍳m
          :If ∧/0≡¨r←⎕TSYNC Cmd&¨cmds
              r←0
          :Else
              r←1 r
          :EndIf
          c←#.DRC.Close name
      :Else
          Log'Client ',name,' Failed to connect',r
          r←1(1⊃r)
      :EndIf
    ∇

    ∇ r←CControl(cmd port);c;name
      r←0
      :If 0=1⊃r←#.DRC.Clt'' 'localhost'port
      :AndIf 0=1⊃r←#.DRC.Send((name←2⊃r),'.Control')cmd
     
          :While ∨/0 100∊1⊃r←#.DRC.Wait(name,'.Control')100
              :If 0=1⊃r
                  r←0(4⊃r)
                  :Leave
              :EndIf
          :EndWhile
          c←#.DRC.Close name
      :EndIf
    ∇


    ∇ r←Load(cons cmds show port)
      {}CControl'START'port
      r←⎕TSYNC(⊂cmds port)Client1&¨cnames←'C',¨8{(-⍺)↑(⍺⍴'0'),⍕⍵}¨⍳cons
      :If 0=1⊃r
          r←0
      :EndIf
      r←CControl'STAT'port
    ∇
    ∇ r←Load1(cons cmds show port)
      {}CControl'START'port
      r←⎕TSYNC(⊂cmds port)Client1&¨cnames←cons⍴⊂''
      :If 0=1⊃r
          r←0
      :EndIf
      r←CControl'STAT'port
    ∇


    ∇ data←Control arg
     
      :Select 4⊃arg
      :Case 'END'
          data←#.DRC.Close name
      :Case 'STAT'
          data←1 2⍴'Active connections'(+/¯1=cons[;3])
          data⍪←'Closed connections'(+/0=cons[;3])
          data⍪←'Errored connections'(+/0<cons[;3])
          data⍪←'Received in order'order
          data⍪←'avg cmds/connections'((+/cons[;2])÷⊃⍴cons)
          data⍪←'Laptime'(#.DRC.Micros-StartMicros)
          data⍪←'Delta ⎕AI'(⎕AI-StartAI)
      :Case 'START'
          data←StartMicros←#.DRC.Micros
      :Case 'LAPTIME'
          data←#.DRC.Micros-StartMicros
     
     
      :EndSelect
     
     
    ∇

    ∇ Server(name ready show port);StartMicros;StartAI;cons;names;cnx;order;last;c;ix;c1;IdleTime
      StartMicros←#.DRC.Micros
      StartAI←⎕AI
      IdleTime←0
      cons←(0 3)⍴0
     
      names←{1↓¨(⍺=⍺,⍵)⊂⍺,⍵}     ⍝ 'S1.CON00000000.X00000000 => S1 CON00000000 X00000000
      cnx←{cons[;1]⍳('.'names ⍵)[2]} ⍝
      order←1
      last←0
      :If (0 name)Assert c←#.DRC.Srv name''port
          :If ready
              0=⊃c←#.DRC.SetProp name'ReadyList' 1
          :EndIf
     
          :While 1
              c←#.DRC.Waitt name 10000
              :Select 1⊃c
              :Case 0
                  :Select 3⊃c
                  :Case 'Error'
                      ix←cnx 2⊃c
                      :If 1119=4⊃c
                          cons[ix;3]←0
                      :Else
                          cons[ix;3]←4⊃c
                          Log'Server ',(2⊃c),' Error ',⍕3⊃c
                      :EndIf
                  :Case 'Receive'
                      ix←cnx 2⊃c
                      order←last≤5 2⊃c
                      last←5 2⊃c
                      Log'Server received ',(2⊃c)
                      :If 'Control'≡3⊃'.'names 2⊃c
                          c1←#.DRC.Respond(2⊃c)(Control c)
     
                      :Else
                          c1←#.DRC.Respond(2⊃c)(⌽4⊃c)
                      :EndIf
                      :If 0=⊃c1
                          cons[ix;2]+←1
                      :Else
                          Log'Server Respond failed ',c1
                      :EndIf
                  :Case 'Connect'
                      :If (ix←cnx 2⊃c)>⊃⍴cons
                          cons⍪←(2⊃('.'names 2⊃c))1 ¯1
                          Log'Server New connection ',(2⊃c)
                      :Else
                          Log'Server same connection ',(2⊃c)
                      :EndIf
                  :EndSelect
              :Case 100
                  Log'Server timeout'
                  :Continue
              :Case 1010
                  Log Control 4⍴⊂'STAT'
                  :Leave
              :Else
                  c
                  r←0
                  :Leave
              :EndSelect
          :EndWhile
      :Else
          c
          r←0
      :EndIf
    ∇




    ∇ ServerThread(name n m ready);c;cons;cmds;names;cnx;cmx;order;last;ix;c1;r
      r←1
      cons←(0 2)⍴0
      cmds←n m⍴0
     
      names←{1↓¨(⍺=⍺,⍵)⊂⍺,⍵}     ⍝ 'S1.CON00000000.X00000000 => S1 CON00000000 X00000000
      cnx←{cons[;1]⍳('.'names ⍵)[2]} ⍝
      cmx←{⍎¯8↑3⊃'.'names ⍵}
      order←1
      last←0
      :If 0 'S1'Assert c←#.DRC.Srv name'' 5000
          :If ready
              r∧←0=⊃c←#.DRC.SetProp name'ReadyList' 1
          :EndIf
     
          :While 1
              c←#.DRC.Waitt name 10000
              :Select 1⊃c
              :Case 0
                  :Select 3⊃c
                  :Case 'Error'
                      ix←cnx 2⊃c
                      :If 1119=4⊃c
                          cons[ix;2]+←1
                      :Else
                          cons[ix;2]+←100
                          Log'Server ',(2⊃c),' Error ',⍕3⊃c
                      :EndIf
                  :Case 'Receive'
                      ix←cnx 2⊃c
                      order←last≤5 2⊃c
                      last←5 2⊃c
                      Log'Server received ',(2⊃c)
                      c1←#.DRC.Respond(2⊃c)(⌽4⊃c)
                      :If 0=⊃c
                          cons[ix;2]+←1
                          cmds[ix;cmx 2⊃c]+←1
                      :Else
                          ∘∘∘
                      :EndIf
     
                  :Case 'Connect'
                      :If (ix←cnx 2⊃c)>⊃⍴cons
                          cons⍪←(2⊃('.'names 2⊃c))1
                          Log'Server New connection ',(2⊃c)
                      :Else
                          cons[ix;2]+←100
                          Log'Server same connection ',(2⊃c)
     
                      :EndIf
     
                  :EndSelect
     
              :Case 100
                  Log'Server timeout'
                  :Continue
              :Case 1010
                  :If ~res,←0=+/(cons[;2]≠2+m)
                      (cons[;2]≠2+m)/cons[;1]
                  :EndIf
                  :If ~res,←∧/∧/cmds
                      +/cmds≠1
                  :EndIf
     
                  :If ~res,←order
                      'Out of order'
                  :EndIf
     
                  :Leave
              :Else
                  c
                  r←0
                  :Leave
              :EndSelect
     
     
     
          :EndWhile
     
     
      :Else
          c
          r←0
      :EndIf
     
    ∇


    ∇ r←CmdWait cmd;c
      r←0
      waitfor←{100=1⊃cw←#.DRC.Wait ⍺ 10000:⍺ ∇ ⍵
          (2⊃⍵)≡⍵[1]⌷4↑cw:0
          cw}
      :If 0=1⊃r←#.DRC.Send cmd cmd   ⍝ 3
             ⍝ r∧←1≡c←cmd waitfor(1 3 4)(0 'Sent' 0)
      :AndIf 0=⊃r←cmd waitfor(1 3 4)(0 'Receive'(⌽cmd))
          r←0
      :Else
          Log'Client ',cmd,' failed ',r
          ⍝ r is set
      :EndIf
    ∇

    ∇ {r}←m Client name;cmds;r;c
      r←0
      :If 0=1⊃r←#.DRC.Clt name'localhost' 5000
          cmds←(⊂name,'.'),¨'X',¨8{(-⍺)↑(⍺⍴'0'),⍕⍵}¨⍳m
          :If ∧/0≡¨r←CmdWait¨cmds
              Log'Client'name
          :EndIf
          c←#.DRC.Close name
      :Else
          r←0
          Log'Client ',name,' Failed to connect'
      :EndIf
      res,←0=⊃r
    ∇

    ∇ r←TestPause;sid;port;cons;cmds;c
      r←1
      show←0
      (port cons cmds)←5000 10 2
      sid←Server&'S1' 0 0 port
     
      {}CControl'START'port
      c←⎕TSYNC(⊂cmds port)Client1&¨cons⍴⊂''
      r∧←∧/0≡¨⊃¨c
      ⍝ Pause = 1 mean keep socket open but do not accept new connection in conga
      ⍝ Pause = 2 mean close socket create new socket when resuming.
      r∧←0 Assert⊃#.DRC.SetProp'S1' 'Pause' 2
      c←⎕TSYNC(⊂cmds port)Client1&¨cons⍴⊂''
      r∧←∧/1=¨⊃¨c
      r∧←0 Assert⊃#.DRC.SetProp'S1' 'Pause' 0
      c←⎕TSYNC(⊂cmds port)Client1&¨cons⍴⊂''
      r∧←∧/0≡¨⊃¨c
     
      c←CControl'STAT'port
      {}##.DRC.Close'S1'
      ⎕TSYNC sid
      Report r
    ∇

    ∇ r←TestReadyList2 arg;n;m;ready;cons;ts;tc;tlist
      n m ready show←arg,(⍴arg)↓2 4 1 0
      {}#.DRC.Close¨#.DRC.Names'.'
      res←⍬
      r←1
      r∧←0 Assert⊃c←#.DRC.SetProp'.' 'ReadyStrategy' 2
      r∧←0 2 Assert c←#.DRC.GetProp'.' 'ReadyStrategy'
      cons←'C',¨8{(-⍺)↑(⍺⍴'0'),⍕⍵}¨⍳n
     
      ts←ServerThread&'S1'n m ready
      ⎕DL 1
      tc←m Client&¨cons
     
      :While ∨/tc∊⎕TNUMS                             ⍝ wait for all client threads to finish
          ⎕DL 0.5
      :EndWhile
      ⎕TSYNC tc
      r∧←0 Assert⊃c←#.DRC.Close'S1'
      ⎕TSYNC ts
⍝test
      :If ~r∧←∧/res
          res
      :EndIf
     
      Report r
    ∇





    ∇ r←TestReadyList arg;n;m;c;cons;cmds;res;name;data;recv;sendrecv;todo;tlist;i;ci;disconnect;connect;respond;ready;send;recvm;sendm;rs;rr;rt;respondm;last;timing;waitfor;results;show;log
      n m ready show←arg,(⍴arg)↓2 4 1 0
      r←1
      r∧←0 Assert⊃c←#.DRC.SetProp'.' 'ReadyStrategy' 2
      r∧←0 2 Assert c←#.DRC.GetProp'.' 'ReadyStrategy'
     
     
      r∧←0 'S1'Assert c←#.DRC.Srv'S1' '' 5000     ⍝('ReadyList' 1)
      show/'Server Started ',('failed' 'ok')[⎕IO+r]
     
      :If ready
          r∧←0 Assert⊃c←#.DRC.SetProp'S1' 'FIFOMode' 1
      :EndIf
     
      results←3 2⍴(1 3 4)(0 'Connect' 0)(1 3 4)(0 'Error' 1119)(1 3)(0 'Receive')
     
     
     
      cons←'C',¨8{(-⍺)↑(⍺⍴'0'),⍕⍵}¨⍳n
      cmds←'X',¨8{(-⍺)↑(⍺⍴'0'),⍕⍵}¨⍳m
     
      log←{show/(40↑⍺),('failed' 'ok')[⎕IO+⍵]}
     
     
      waitfor←{(2⊃⍵)≡⍵[1]⌷c←#.DRC.Wait ⍺ 1000:1 ⋄ c}
     
      connect←{0=1⊃c←#.DRC.Clt ⍵'localhost' 5000:1 ⋄ 1111=1⊃c:∇ ⍵ ⋄ 0≠1⊃c:c}
      disconnect←{0≠⊃c←#.DRC.Close ⍵:c ⋄ 1}
     
     
      name←{(⊃cons[1⊃⍵]),'.',⊃cmds[2⊃⍵]}
      data←{'Test ',,⍕⍵}
      send←{0≠⊃#.DRC.Send(name ⍵)(data ⍵)3:¯1
          0 'Sent' 0≢(⊂1 3 4)⌷c←#.DRC.Wait(name ⍵)10000:¯2
          1
      }
      recv←{100=⊃z←#.DRC.Wait(name ⍵)100000:∇ ⍵
          0 'Receive'(⌽data ⍵)≡(⊂1 3 4)⌷z:1
          ¯2}
      sendm←{(⍵⌷rs)←send ⍵}
      recvm←{(⍵⌷rr)←recv ⍵}
     
     
     
      sendrecv←{0≠⊃#.DRC.Send(name ⍵)(data ⍵):¯1
          (⍵⌷res)←recv ⍵}
     
      respond←{0 'Receive'≢(⊂1 3)⌷c←#.DRC.Waitt'S1' 10000:¯1
          ⍝(1<⍴,⍵)∧((data ⍵)≢4⊃c):¯2
          ⍝⎕←4⊃c
          0≠⊃cr←#.DRC.Respond(2⊃c)(⌽4⊃c):¯3
          timing,←5 2⊃c
          1
      }
     
      respondm←{(⍵⌷rt)←respond ⍵}
     
      todo←{⍵[(⍴⍵)?⍴⍵]},⍳n m
     
     
      'Client connect 'log r∧←∧/1≡¨c←connect¨cons                            ⍝ Client connect
     
      'Server connections 'log r∧←∧/1≡¨c←((⍴cons)⍴⊂'S1')waitfor¨⊂results[1;]     ⍝ Server side wait for connection
     
      rs←rr←rt←n m⍴0
      timing←⍬
      {}sendm¨todo                                      ⍝ Client send all commands
      'Send 'log r∧←∧/∧/rs=1
     
     
     
      tlist←recvm&¨todo                                 ⍝ Client wait for all answers Threaded
     
      {}respondm¨todo                                   ⍝ Server respond all commands
      'Respond 'log r∧←∧/∧/rt=1
     
     
      :While ∨/tlist∊⎕TNUMS                             ⍝ wait for all client threads to finish
          ⎕DL 0.5
      :EndWhile
      'Recv 'log r∧←∧/∧/rr=1
     
      'In Order 'log r∧←∧/{0≤(1↓⍵)-¯1↓⍵}timing
     
      'Disconnect 'log r∧←∧/1≡¨c←disconnect¨cons                         ⍝ close all client connections
     
      'Disconnected 'log r∧←∧/1≡¨c←((⍴cons)⍴⊂'S1')waitfor¨⊂results[2;]   ⍝ Server side wait for connectiona to close
     
      r∧←0 Assert⊃c←#.DRC.Close'S1'
      Report r
     
    ∇


    ∇ r←TestEndpoints;c;EndPoints;Allowed;ep
      r←1
      r∧←0 Assert⊃c←#.DRC.SetProp'.' 'ReadyStrategy' 2
      r∧←0 2 Assert c←#.DRC.GetProp'.' 'ReadyStrategy'
     
      r∧←0 Assert⊃c←#.DRC.GetProp'.' 'TCPLookup' '' 80
     
      EndPoints←⍬~⍨{'IPv6'≡1⊃⍵:(1⊃⍵)(1↓¯4↓2⊃⍵) ⋄ 'IPv4'≡1⊃⍵:(1⊃⍵)(¯3↓2⊃⍵) ⋄ ⍬}¨2⊃c
      Allowed←((⍴EndPoints)⍴1 0)/EndPoints
     
     
     
      r∧←0 'S1'Assert c←#.DRC.Srv'S1' '' 5000 'BlkText' 10000('Magic'(#.DRC.Magic'TRex'))
      r∧←0 'S2'Assert c←#.DRC.Srv'S2' '' 5001 'BlkText' 10000('Magic'(#.DRC.Magic'TRex'))('AllowEndpoints'(↓{(⊃⍺)(¯1↓⊃,/(2⊃¨Allowed[⍵]),¨('/29,' '/120,')[⎕IO+⍺≡⊂'IPv6'])}⌸1⊃¨Allowed))
     
     
      :For ep :In EndPoints
          r∧←0 Assert⊃c←#.DRC.Clt'C1'(2⊃ep)5000 'BlkText' 10000('Magic'(#.DRC.Magic'TRex'))
          r∧←0 Assert⊃c←#.DRC.Clt'C2'(2⊃ep)5001 'BlkText' 10000('Magic'(#.DRC.Magic'TRex'))
     
     
          r∧←0 'Connect' 0 Assert(⊂1 3 4)⌷c←#.DRC.Wait'S1' 100
          :If ∨/Allowed∊⊂ep
              r∧←0 'Connect' 0 Assert(⊂1 3 4)⌷c←#.DRC.Wait'S2' 100
              r∧←0 Assert⊃c←#.DRC.Close'C2'
              r∧←0 'Error' 1119 Assert(⊂1 3 4)⌷c←#.DRC.Wait('S2')100
          :Else
              r∧←100 'TIMEOUT'Assert(⊂1 2)⌷c←#.DRC.Wait'S2' 100
              r∧←0 'Error' 1119 Assert(⊂1 3 4)⌷c←#.DRC.Wait('C2')100
          :EndIf
     
          ⍝#.DRC.GetProp(2⊃c)'PeerAddr'
          r∧←0 Assert⊃c←#.DRC.Close'C1'
          r∧←0 'Error' 1119 Assert(⊂1 3 4)⌷c←#.DRC.Wait('S1')100
     
      :EndFor
      r∧←0 Assert⊃c←#.DRC.Close'S1'
      r∧←0 Assert⊃c←#.DRC.Close'S2'
      Report r
    ∇



    ∇ r←TestSentCompleteText;c1;c;c2;c3
      r←1
     
      r∧←0 Assert⊃c←#.DRC.SetProp'.' 'ReadyStrategy' 3
      r∧←0 3 Assert c←#.DRC.GetProp'.' 'ReadyStrategy'
      r∧←0 'S1'Assert c←#.DRC.Srv'S1' '' 5000 'BlkText' 10000('Magic'(#.DRC.Magic'TRex'))
     
      r∧←0 'C1'Assert c←#.DRC.Clt'C1' 'localhost' 5000 'BlkText' 10000('Magic'(#.DRC.Magic'TRex'))
      r∧←0 Assert⊃c1←#.DRC.Send'C1' 'test 1 1'
      r∧←0 Assert⊃c2←#.DRC.Send'C1' 'test 1 2' 3
      r∧←0 Assert⊃c3←#.DRC.Send'C1' 'test 1 3' 3
     
      r∧←0 'Sent' 0 Assert(⊂1 3 4)⌷c←#.DRC.Wait'C1' 100
     
      r∧←0 'Connect' 0 Assert(⊂1 3 4)⌷c←#.DRC.Wait'S1' 100
     
      r∧←0 'Block' 'test 1 1'Assert(⊂1 3 4)⌷c←#.DRC.Wait'S1' 100
      r∧←0 Assert⊃c←#.DRC.Send(2⊃c)(4⊃c)
      r∧←0 'Block' 'test 1 2'Assert(⊂1 3 4)⌷c←#.DRC.Wait'S1' 100
      r∧←0 Assert⊃c←#.DRC.Send(2⊃c)(4⊃c)
      r∧←0 'Block' 'test 1 3'Assert(⊂1 3 4)⌷c←#.DRC.Wait'S1' 100
      r∧←0 Assert⊃c←#.DRC.Send(2⊃c)(4⊃c)
     
      r∧←0 'Sent' 0 Assert(⊂1 3 4)⌷c←#.DRC.Wait'C1' 100
     
      r∧←0 'Block' 'test 1 1'Assert(⊂1 3 4)⌷c←#.DRC.Wait'C1' 100
      r∧←0 'Block' 'test 1 2'Assert(⊂1 3 4)⌷c←#.DRC.Wait'C1' 100
      r∧←0 'Block' 'test 1 3'Assert(⊂1 3 4)⌷c←#.DRC.Wait'C1' 100
     
      r∧←0 Assert⊃c←#.DRC.Close'C1'
      r∧←0 'Error' 1119 Assert(⊂1 3 4)⌷c←#.DRC.Wait('S1')100
      r∧←0 Assert⊃c←#.DRC.Close'S1'
      Report r
    ∇





    ∇ r←TestSentCompleteCMD;c1;c;c2;c3
      r←1
     
      r∧←0 Assert⊃c←#.DRC.SetProp'.' 'ReadyStrategy' 3
      r∧←0 3 Assert c←#.DRC.GetProp'.' 'ReadyStrategy'
      r∧←0 'S1'Assert c←#.DRC.Srv'S1' '' 5000
     
      r∧←0 'C1'Assert c←#.DRC.Clt'C1' 'localhost' 5000
      r∧←0 Assert⊃c1←#.DRC.Send'C1' 'test 1 1'
      r∧←0 Assert⊃c2←#.DRC.Send'C1' 'test 1 2' 3
      r∧←0 Assert⊃c3←#.DRC.Send'C1' 'test 1 3' 3
     
      r∧←0 'Sent' 0 Assert(⊂1 3 4)⌷c←#.DRC.Wait(2⊃c2)100
     
      r∧←0 'Connect' 0 Assert(⊂1 3 4)⌷c←#.DRC.Wait'S1' 100
     
      r∧←0 'Receive' 'test 1 1'Assert(⊂1 3 4)⌷c←#.DRC.Wait'S1' 100
      r∧←0 Assert⊃c←#.DRC.Respond(2⊃c)(4⊃c)
      r∧←0 'Receive' 'test 1 2'Assert(⊂1 3 4)⌷c←#.DRC.Wait'S1' 100
      r∧←0 Assert⊃c←#.DRC.Respond(2⊃c)(4⊃c)
      r∧←0 'Receive' 'test 1 3'Assert(⊂1 3 4)⌷c←#.DRC.Wait'S1' 100
      r∧←0 Assert⊃c←#.DRC.Respond(2⊃c)(4⊃c)
     
      r∧←0 'Receive' 'test 1 1'Assert(⊂1 3 4)⌷c←#.DRC.Wait(2⊃c1)100
      r∧←0 'Receive' 'test 1 2'Assert(⊂1 3 4)⌷c←#.DRC.Wait(2⊃c2)100
      r∧←0 'Receive' 'test 1 3'Assert(⊂1 3 4)⌷c←#.DRC.Wait(2⊃c3)100
     
      r∧←0 Assert⊃c←#.DRC.Close'C1'
      r∧←0 'Error' 1119 Assert(⊂1 3 4)⌷c←#.DRC.Wait('S1')100
      r∧←0 Assert⊃c←#.DRC.Close'S1'
      Report r
    ∇


    ∇ r←TestThreaded;c2;c1;c3
      r←1
     
      r∧←0 Assert⊃c←#.DRC.SetProp'.' 'ReadyStrategy' 4
      r∧←0 4 Assert c←#.DRC.GetProp'.' 'ReadyStrategy'
      r∧←0 'S1'Assert c←#.DRC.Srv'S1' '' 5000
     
      r∧←0 Assert⊃c←#.DRC.SetProp'S1' 'ConnectionOnly' 1
      r∧←(0(,1))Assert c←#.DRC.GetProp'S1' 'ConnectionOnly'
      r∧←0 'C1'Assert c←#.DRC.Clt'C1' 'localhost' 5000
      r∧←0 Assert⊃c←#.DRC.Send'C1' 'test 1 1'
      r∧←0 Assert⊃c←#.DRC.Send'C1' 'test 1 2'
     
      r∧←0 'C2'Assert c←#.DRC.Clt'C2' 'localhost' 5000
     
      r∧←0 Assert⊃c←#.DRC.Send'C2' 'test 2 1'
      r∧←0 Assert⊃c←#.DRC.Send'C2' 'test 2 2'
     
      r∧←0 'C3'Assert c←#.DRC.Clt'C3' 'localhost' 5000
      r∧←0 Assert⊃c←#.DRC.Send'C3' 'test 3 1'
      r∧←0 Assert⊃c←#.DRC.Send'C3' 'test 3 2' 1
     
     
      r∧←0 'Connect' 0 Assert(⊂1 3 4)⌷c1←#.DRC.Wait'S1' 100
     
      r∧←0 'Receive' 'test 1 1'Assert(⊂1 3 4)⌷c←#.DRC.Wait(2⊃c1)100
     
      r∧←0 'Connect' 0 Assert(⊂1 3 4)⌷c2←#.DRC.Wait'S1' 100
     
      r∧←0 'Receive' 'test 2 1'Assert(⊂1 3 4)⌷c←#.DRC.Wait(2⊃c2)100
     
      r∧←0 'Connect' 0 Assert(⊂1 3 4)⌷c3←#.DRC.Wait'S1' 100
     
      r∧←0 'Receive' 'test 3 1'Assert(⊂1 3 4)⌷c←#.DRC.Wait(2⊃c3)100
     
      r∧←100 'TIMEOUT' ''Assert c←#.DRC.Wait'S1' 100
     
      r∧←0 'Receive' 'test 1 2'Assert(⊂1 3 4)⌷c←#.DRC.Wait(2⊃c1)100
      r∧←0 'Receive' 'test 2 2'Assert(⊂1 3 4)⌷c←#.DRC.Wait(2⊃c2)100
      c←#.DRC.Wait(2⊃c3)100
      :If 0 'Error' 1119≡(⊂1 3 4)⌷c
          c←#.DRC.Wait(2⊃c3)100
      :EndIf
      r∧←0 'Receive' 'test 3 2'Assert(⊂1 3 4)⌷c
     
      r∧←100 'TIMEOUT' ''Assert c←#.DRC.Wait(2⊃c1)100
      r∧←100 'TIMEOUT' ''Assert c←#.DRC.Wait(2⊃c2)100
      r∧←0 'Error' 1119 Assert(⊂1 3 4)⌷c←#.DRC.Wait(2⊃c3)100
     
      r∧←100 'TIMEOUT' ''Assert c←#.DRC.Wait'S1' 100
      r∧←0 Assert⊃c←#.DRC.Close'C1'
      r∧←0 Assert⊃c←#.DRC.Close'C2'
     
      r∧←0 'Error' 1119 Assert(⊂1 3 4)⌷c←#.DRC.Wait(2⊃c1)100
      r∧←0 'Error' 1119 Assert(⊂1 3 4)⌷c←#.DRC.Wait(2⊃c2)100
     
      r∧←0 Assert⊃c←#.DRC.Close'S1'
      Report r
    ∇


    ∇ r←Connect(addr port srv prot);c;c1
      r←1
      r∧←0≡⊃c←#.DRC.Clt''addr port,(0<⍴prot)/(⊂'Protocol'prot)
     
      r∧←0 'Connect' 0≡(⊂1 3 4)⌷c1←4↑#.DRC.Wait srv 100
      r∧←0≡⊃#.DRC.Close 2⊃c
      r∧←0 'Error' 1119≡(⊂1 3 4)⌷c1←4↑#.DRC.Wait(srv)100
     
    ∇

    ∇ r←TestGetAddrInfo;srvs;tests;res;rr;c
      r←1
     
      srvs←('SA' '' 5000)('S4' '' 5004('Protocol' 'ipv4'))('S6' '' 5006('Protocol' 'ipv6'))
     
      r←∧/rr←{0(1⊃⍵)≡#.DRC.Srv ⍵}¨srvs
      :If ~r
          'Failed: ',⍕rr/srvs
      :EndIf
     
      tests←('localhost' '127.0.0.1' '::1' '')∘.{(⊂⍺),⍵}{⍵[3 1]}¨srvs
      res←(⍴tests)⍴1
      res[2;3]←0
      res[3;2]←0
     
      rr←Connect¨tests,¨⊂⊂''
      r∧←res Assert rr
     
      r∧←((⍴srvs)⍴0)Assert⊃¨c←#.DRC.Close¨1⊃¨srvs
      Report r
    ∇


    ∇ r←TestProtocol;srvs;tests;res;rr;c
      r←1
     
      srvs←('SA' '' 5000)('S4' '' 5004('Protocol' 'ipv4'))('S6' '' 5006('Protocol' 'ipv6'))
     
      r←∧/rr←{0(1⊃⍵)≡#.DRC.Srv ⍵}¨srvs
      :If ~r
          'Failed: ',⍕rr/srvs
      :EndIf
     
      tests←(('localhost'⍬)('localhost' 'ip')('localhost' 'ipv4')('localhost' 'ipv6'))∘.{(⍺,⍵)[1 3 4 2]}{⍵[3 1]}¨srvs
     
      res←(⍴tests)⍴1
      res[3;3]←0
      res[4;2]←0
     
      rr←Connect¨tests
      r∧←res Assert rr
     
      r∧←((⍴srvs)⍴0)Assert⊃¨c←#.DRC.Close¨1⊃¨srvs
      Report r
    ∇

    ∇ r←TestProgress;c;rs;cmd;rc
      r←1
      r∧←0 Assert⊃c←#.DRC.SetProp'.' 'EventMode' 1
      r∧←0 'S1'Assert c←#.DRC.Srv'S1' '' 5000
     
      r∧←0 'C1'Assert c←#.DRC.Clt'C1' '' 5000
      r∧←0 Assert⊃c←#.DRC.Send'C1' 'testing 1 2 3'
      cmd←2⊃c
     
      r∧←0 'Connect'Assert(⊂1 3)⌷c←#.DRC.Wait'S1' 100
      r∧←0 'Receive' 'testing 1 2 3'Assert(⊂1 3 4)⌷rs←#.DRC.Wait'S1' 100
     
      r∧←0 Assert⊃c←#.DRC.Progress(2⊃rs)('10%')
      r∧←0 Assert⊃c←#.DRC.Progress(2⊃rs)('20%')
      r∧←0 Assert⊃c←#.DRC.Progress(2⊃rs)('30%')
      r∧←0 Assert⊃c←#.DRC.Progress(2⊃rs)('40%')
      r∧←0 Assert⊃c←#.DRC.Progress(2⊃rs)('50%')
      r∧←0 Assert⊃c←#.DRC.Progress(2⊃rs)('60%')
      r∧←0 Assert⊃c←#.DRC.Progress(2⊃rs)('70%')
      r∧←0 Assert⊃c←#.DRC.Progress(2⊃rs)('80%')
      r∧←0 Assert⊃c←#.DRC.Progress(2⊃rs)('90%')
     
      r∧←0 'Progress' '10%'Assert(⊂1 3 4)⌷rc←#.DRC.Wait cmd 100
      r∧←0 'Progress' '20%'Assert(⊂1 3 4)⌷rc←#.DRC.Wait cmd 100
      r∧←0 'Progress' '30%'Assert(⊂1 3 4)⌷rc←#.DRC.Wait cmd 100
      r∧←0 'Progress' '40%'Assert(⊂1 3 4)⌷rc←#.DRC.Wait cmd 100
     
      r∧←0 Assert⊃c←#.DRC.Respond(2⊃rs)(⌽4⊃rs)
      ⎕DL 0.1
      r∧←0 'Receive'(⌽'testing 1 2 3')Assert(⊂1 3 4)⌷rc←#.DRC.Wait cmd 100
      r∧←1010 Assert⊃rc←#.DRC.Wait cmd 100
      r∧←0 Assert⊃#.DRC.Close'C1'
     
      r∧←0 'Closed' 1119 Assert(⊂1 3 4)⌷rs←#.DRC.Wait'S1' 100
      r∧←0 'Timeout' 100 Assert(⊂1 3 4)⌷rs←#.DRC.Wait'S1' 100
      r∧←0 Assert⊃#.DRC.Close'S1'
     
      Report r
     
    ∇


    ∇ r←TestUDPSimple;c;addrs;rc;con2;con1;data;a;sock
      r←1
     
      r∧←0 Assert⊃c←#.DRC.GetProp'.' 'Ipv4Addrs'
      addrs←(2⊃c)[;2]
      ⍝addrs←(¯2↓¨2⊃¨{('IPv4'∘≡∘⊃¨⍵)/⍵}2⊃c)
     
     
      r∧←0 'UdpS'Assert c←#.DRC.Srv'UdpS' '' 5000 'udp' 10000('Protocol' 'ipv4')
     
      r∧←0 Assert⊃c←#.DRC.Clt'UdpC' '127.0.0.1' 5000 'udp' 10000('Protocol' 'ipv4')
     
      con1←2⊃c
     
      r∧←0 Assert⊃c←#.DRC.Send con1'Testing Udp1'
      r∧←0 Assert⊃c←#.DRC.Send'UdpC'('127.0.0.1' 5000 'Testing Udp2')
      con2←2⊃c
     
      r∧←0 'Block'('Testing Udp1')Assert(⊂1 3 4)⌷rc←#.DRC.Wait'UdpS' 100
      r∧←0 Assert⊃c←#.DRC.Send(2⊃rc)'Testing Udp1'
     
      r∧←0 'Block'('Testing Udp2')Assert(⊂1 3 4)⌷rc←#.DRC.Wait'UdpS' 100
      r∧←0 Assert⊃c←#.DRC.Send(2⊃rc)'Testing Udp2'
     
      r∧←0 'Block'('Testing Udp1')Assert(⊂1 3 4)⌷rc←#.DRC.Wait con1 100
      r∧←0 'Block'('Testing Udp2')Assert(⊂1 3 4)⌷rc←#.DRC.Wait con2 100
     
      :For a :In addrs
          data←'Testing Udp ',a
          r∧←0 Assert⊃c←#.DRC.Send'UdpC'(a 5000 data)
          con2←2⊃c
          r∧←0 'Block'data Assert(⊂1 3 4)⌷rc←#.DRC.Wait'UdpS' 100
          r∧←0 Assert⊃c←#.DRC.Send(2⊃rc)(⌽data)
          r∧←0 'Block'(⌽data)Assert(⊂1 3 4)⌷rc←#.DRC.Wait con2 100
     
      :EndFor
     
      sock←⍬
      :For a :In addrs
          data←'Testing Udp ',a
          r∧←0 Assert⊃c←#.DRC.Clt''a 5000 'udp' 10000('Protocol' 'ipv4')
     
          con2←2⊃c
          sock,←⊂{(¯1+⍵⍳'.')↑⍵}con2
          r∧←0 Assert⊃c←#.DRC.Send con2 data
          r∧←0 'Block'data Assert(⊂1 3 4)⌷rc←#.DRC.Wait'UdpS' 100
          r∧←0 Assert⊃c←#.DRC.Send(2⊃rc)(⌽data)
          r∧←0 'Block'(⌽data)Assert(⊂1 3 4)⌷rc←#.DRC.Wait con2 100
     
      :EndFor
     
      :For n :In #.DRC.Names'.'
          'Connection: ',n
          :For l :In #.DRC.Names n
              '  ',⍕decodeAddr l
          :EndFor
      :EndFor
     
     
      r∧←∧/0=⊃¨#.DRC.Close¨sock
      r∧←0 Assert⊃c←#.DRC.Close'UdpC'
      r∧←0 Assert⊃c←#.DRC.Close'UdpS'
     
     
      Report r
    ∇

    ∇ r←TestWebSocket;c;port;wscon;len;data;c1;Features;nl;drt
      r←1
      to83←{⍵+¯256×⍵>127}
      nl←⎕UCS 13 10
      port←8088
      Features←1   ⍝ Feature 0=APL negotiate 1=AutoUpgrade
      c←#.DRC.Srv'S1' ''port'http' 450000
      r∧←0 'S1'Assert c
      :If r=1
          r∧←0 Assert⊃c←#.DRC.SetProp'S1' 'WSFeatures'Features ⍝ Set feature for server applies to all incomming connections
          c←#.DRC.Clt'C1' 'localhost'port'http' 450000
          r∧←0 'C1'Assert c
          :If r=1
              r∧←0 Assert⊃c←#.DRC.SetProp'C1' 'WSFeatures'Features
     
              c←#.DRC.Wait'S1' 1000
              r∧←0 'Connect'Assert c[1 3]
        ⍝ Client requests to upgrade the connection 4th arg is extra headers remember to add nl
              r∧←0 Assert⊃c←#.DRC.SetProp'C1' 'WSUpgrade'('/' 'localhost'('BHCHeader: Gil',nl))
     
              c←#.DRC.Wait'S1' 1000
              :If 0 'WSUpgrade'≡c[1 3]    ⍝ Auto upgrade event 4⊃c is the Incomming request but connection have been upgraded
                  r∧←1
              :ElseIf 0 'WSUpgradeReq'≡c[1 3]  ⍝ Negotiate inspect headers and accept request with the extra headers you need.
                  :If 0<≢4⊃c
                      r∧←0 Assert⊃c1←#.DRC.SetProp(2⊃c)'WSAccept'((4⊃c)('GILHeader: bhc',nl))
                  :EndIf
              :Else
                  r←0
              :EndIf
              wscon←2⊃c  ⍝ test
     
              c←#.DRC.Wait'C1' 1000
        ⍝ returns WSUpgrade and 4⊃c is the peers accept headers, WSResponse 4⊃c is the same but you have to accept the upgrade.
              :If 0 'WSResponse'≡c[1 3]
                  r∧←0 Assert⊃c1←#.DRC.SetProp(2⊃c)'WSAccept'((4⊃c)'')
              :EndIf
     
              :For drt :In 80 160 320
                  :For len :In 0 10 124 125 126 127 128 65535 65536 70000
                      data←drt utf8 len ⍝
                      r∧←0 Assert⊃c←#.DRC.Send'C1'(data 1)
     
                      c←#.DRC.Wait'S1' 1000
                      r∧←0 'WSReceive'(data 1 1)Assert c[1 3 4]
     
                      r∧←0 Assert⊃c←#.DRC.Send wscon(data 1)
     
                      c←#.DRC.Wait'C1' 1000
                      r∧←0 'WSReceive'(data 1 1)Assert c[1 3 4]
                  :EndFor
              :EndFor
              :For offset :In -⎕IO+0 128
                  :For len :In 0 10 124 125 126 127 128 65535 65536 70000
                      data←offset+len⍴⍳256
                      r∧←0 Assert⊃c←#.DRC.Send'C1'(data 1)
     
                      c←#.DRC.Wait'S1' 1000
                      r∧←0 'WSReceive'((to83 data)1 2)Assert c[1 3 4]
     
                      r∧←0 Assert⊃c←#.DRC.Send wscon(data 1)
     
                      c←#.DRC.Wait'C1' 1000
                      r∧←0 'WSReceive'((to83 data)1 2)Assert c[1 3 4]
                  :EndFor
              :EndFor
              :For drt :In 80 160 320
                  :For len :In 0 10 124 125 126 127 128 65535 65536 70000
                      data←drt utf8 len ⍝
                      Fin←len=70000
                      r∧←0 Assert⊃c←#.DRC.Send'C1'(data Fin)
     
                      c←#.DRC.Wait'S1' 1000
                      r∧←0 'WSReceive'(data Fin 1)Assert c[1 3 4]
     
                      r∧←0 Assert⊃c←#.DRC.Send wscon(data Fin)
     
                      c←#.DRC.Wait'C1' 1000
                      r∧←0 'WSReceive'(data Fin 1)Assert c[1 3 4]
                  :EndFor
              :EndFor
              :For offset :In -⎕IO+0 128
                  :For len :In 0 10 124 125 126 127 128 65535 65536 70000
                      data←offset+len⍴⍳256
                      Fin←len=70000
                      r∧←0 Assert⊃c←#.DRC.Send'C1'(data Fin)
     
                      c←#.DRC.Wait'S1' 1000
                      r∧←0 'WSReceive'((to83 data)Fin 2)Assert c[1 3 4]
     
                      r∧←0 Assert⊃c←#.DRC.Send wscon(data Fin)
     
                      c←#.DRC.Wait'C1' 1000
                      r∧←0 'WSReceive'((to83 data)Fin 2)Assert c[1 3 4]
                  :EndFor
              :EndFor
              ⍝ test wrong type
              data←80 utf8 1000 ⍝
              r∧←0 Assert⊃c←#.DRC.Send'C1'(data 0)
     
              c←#.DRC.Wait'S1' 1000
              r∧←0 'WSReceive'(data 0 1)Assert c[1 3 4]
     
              data←(-128+⎕IO)+1000⍴⍳256
              r∧←1004 Assert⊃c←#.DRC.Send'C1'(data 1)
     
              data←80 utf8 1000 ⍝
              r∧←0 Assert⊃c←#.DRC.Send'C1'(data 1)
     
              c←#.DRC.Wait'S1' 1000
              r∧←0 'WSReceive'(data 1 1)Assert c[1 3 4]
     
              ⍝ test wrong type
              data←(-128+⎕IO)+1000⍴⍳256
              r∧←0 Assert⊃c←#.DRC.Send'C1'(data 0)
     
              c←#.DRC.Wait'S1' 1000
              r∧←0 'WSReceive'(data 0 2)Assert c[1 3 4]
     
              data←80 utf8 1000 ⍝
              r∧←1004 Assert⊃c←#.DRC.Send'C1'(data 1)
     
              data←(-128+⎕IO)+1000⍴⍳256
              r∧←0 Assert⊃c←#.DRC.Send'C1'(data 1)
     
              c←#.DRC.Wait'S1' 1000
              r∧←0 'WSReceive'(data 1 2)Assert c[1 3 4]
     
     
              r∧←0 Assert⊃c←#.DRC.Close'C1'
              c←#.DRC.Wait'S1' 10000
              r∧←0 'Error' 1119 Assert c[1 3 4]
     
          :EndIf
          r∧←0 Assert⊃c←#.DRC.Close'S1'
      :EndIf
     
    ∇


    ∇ r←Run;c
      r←1
      show←0
      StopOnError←1
      Errors←⍬
      ⍝c←#.DRC.Init''
      ⍝r∧←0=⊃c
      r∧←0 Assert⊃c←#.DRC.SetProp'.' 'EventMode' 0
      ⍝ Close any extant connections
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestThreaded
     
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestSentCompleteCMD
     
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestSentCompleteText
     
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestEndpoints
     
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestSendFile
     
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestSendFileBlk
     
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestPause
     
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestGetAddrInfo
     
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestProtocol
     
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestRaw
     
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestWebSocket
     
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestReadyList2 4 8 1 0
     
      c←#.DRC.Close¨#.DRC.Names'.'
      r∧←TestProgress
     
     
      :If 0<⍴Errors
          Errors
      :EndIf
    ∇

    ∇ r←decodeAddr addr;parts
      parts←¯2↑'.:'{m←(⊃⍺),⍵ ⋄ 1↓¨(m∊⍺)⊂m}addr
      r←(base64 1⊃parts)(dec 2⊃parts)
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
      dec←{⎕IO ⎕ML←0 1                                ⍝ Decimal from hexadecimal
          ⍺←0                                         ⍝ unsigned by default.
          1<⍴⍴⍵:↑⍺ ∇¨↓⍵                               ⍝ vector-wise:
          0=≢⍵:0                                      ⍝ dec'' → 0.
          1≠≡,⍵:⍺ ∇¨⍵                                 ⍝ simple-array-wise:
          ' '=⊃⍵:⍺ ∇ 1↓⍵                              ⍝ ignoring leading and
          ' '=⊃⌽⍵:⍺ ∇ ¯1↓⍵                            ⍝ ... trailing blanks.
          ' '∊⍵:⍺ ∇¨{1↓¨(⍵=' ')⊂⍵}' ',⍵               ⍝ blank-separated:
          v←16|'0123456789abcdef0123456789ABCDEF'⍳⍵   ⍝ hex digits.
          11::'Too big'⎕SIGNAL 11                     ⍝ number too big.
          (16⊥v)-⍺×(8≤⊃v)×16*≢v                       ⍝ (signed) decimal number.
      }

:EndNamespace
