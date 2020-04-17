 r←CertPath
⍝ Return the path to the certificates and set global TestCertificates
 ⍝ TestCertificates←2 ⎕nq 'GetEnvironment' 'TESTCERTIFICATESDIR'
 :If 0=#.⎕NC'TestCertificates'
     TestCertificates←2 ⎕NQ'.' 'GetEnvironment' 'TESTCERTIFICATESDIR'
 :Else
     TestCertificates←#.TestCertificates
 :EndIf
 :If {0::0 ⋄ ⎕NEXISTS ⍵}r←TestCertificates
 :ElseIf ⎕NEXISTS r←##.TESTSOURCE,'TestCertificates/'
 :ElseIf ⎕NEXISTS r←##.WSFOLDER,'/TestCertificates/'
 :ElseIf ⎕NEXISTS r←##.DYALOG,'/TestCertificates/'
     TestCertificates←r  
 :Else
     ('Unable to locate TestCertificates folder')⎕SIGNAL 22
 :EndIf
 r←(2↑r),{(~'//'⍷⍵)/⍵}2↓r  ⍝ avoid // anywhere, except at the beginning
