 TestFTPClient;z;pub;CR;readme;host;user;pass;folder;file;sub;⎕ML;path
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
