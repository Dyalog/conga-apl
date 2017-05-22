 r←Style;NL
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
