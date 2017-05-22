 r←SecureCallback(cmd session);⎕TRAP;cert;rc;cmd;head;call;r;html;user
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
