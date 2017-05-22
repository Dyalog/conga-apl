 r←{send}GetSimpleServiceData(host port);done;wr;cmd;header;data;z
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
