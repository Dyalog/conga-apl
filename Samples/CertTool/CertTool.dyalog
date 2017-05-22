:Namespace CertTool
⍝ Examples showing how GnuTLS "CertTool" can be used
⍝ to generate a variety of certificates.
⍝    
⍝ This code requires version 15.0 or later of Dyalog APL
⍝
⍝ Run CertTool.Examples
⍝
⍝ See https://www.gnutls.org for more information.
⍝
⍝ The Select statement in the Init function will need to be altered for your machine:
⍝ you must point to the location of the certtool executable unless it is on your PATH
⍝ and must select where you want the generated certificates to be put

    APLplatform←''
    :Section Examples

    ∇ r←Init;ver
     
      COMPANYINFO←'C=UK,O=MyOrg,OU=Test,ST=Hampshire' ⍝ Becomes part of the cert "subject"
     
      ver←'.'⎕WG'APLVersion'
      :If ~V15←15≤⊃2⊃⎕VFI{(¯1+⍵⍳'.')↑⍵}2⊃ver                         ⍝ Version 15.0 or later?
          'Dyalog Version 15.0 or later is required'⎕SIGNAL 11
      :EndIf
     
      APLplatform←3↑⊃ver
      :If 'Lin'≡APLplatform
          :If 'armv'≡4↑⊃⎕SH'uname -m'
              APLplatform←'Ras'                                      ⍝ [Ras]pberry Pi
          :EndIf
      :EndIf
     
      :Select APLplatform
      :Case 'Win'
          EXEC←'c:/apps/gnutls-3.4.9/bin/certtool.exe'               ⍝ Path to certtool (download from gnutls.org)
          TARGET←⊃,/(⊂'TestCertificates\'),⍨⊃⎕NPARTS 2 ⎕NQ'.' 'GetEnvironment' 'Log_file'
                ⍝TARGET←'c:/temp/TestCertificates/'                         ⍝ Where to store generated files
      :Case 'Mac'
          EXEC←'/usr/local/Cellar/gnutls/3.4.10/bin/gnutls-certtool' ⍝ Path to certtool (download from gnutls.org)
          TARGET←'./TestCertificates/'                               ⍝ Where to store generated files
      :CaseList 'Lin' 'Ras'
          EXEC←'certtool'                                            ⍝ if certtool installed it'll be on the PATH
          TARGET←'./TestCertificates/'                               ⍝ Where to store generated files
      :Else
          ('Unsupported platform: ',APLplatform)⎕SIGNAL 11
      :EndSelect
     
      :If 0=≢toolversion                                             ⍝ No version number suggest that the executable
          ('Attempt to call ',EXEC,' failed')⎕SIGNAL 11              ⍝ is not where it is expected to be
      :EndIf
     
      :If 30400>0 100 100⊥⊃(//)'.'⎕VFI toolversion
          'No pkcs#7 or pkcs#12 encoded certificates before version 3.4.0 of certtool'⎕SIGNAL 11
      :EndIf
     
      SERIAL←100                                      ⍝ Serial number of first certificate
     
      EOL←⎕UCS 10                                     ⍝ CertTool uses LF on all platforms
    ∇

    ∇ Examples;⎕PW
    ⍝ Creates a set of certificates for a small company
     
      ⎕PW←1000
      Init              ⍝ Set up global variables
      mkdir'CA'         ⍝ Location for Certificate Authority certificates
      mkdir'client'     ⍝ Location for client certs
      mkdir'server'     ⍝ Location for server certs
      mkdir'tmp'        ⍝ Work in a temporary directory and remove it after we're done
     
      'CA/ca-key.pem'KeyGen'rsa' 4096
      'CA/caconf.cfg'CreateConfig(COMPANYINFO,',CN=TestCA')'' '' 'CA'
     
      CreateCA'CA/caconf.cfg' 'CA/ca-key.pem' 'CA/ca-cert.pem'
     
      ServerCert'localhost'
      ServerCert'myserver'
      ClientCert'John Doe' 'johndoe@samples.net'
      ClientCert'Jane Doe' 'janedoe@samples.net'
     
      rmdir'tmp'
    ∇

    ∇ ServerCert name
      ('tmp/conf.cfg')CreateConfig(COMPANYINFO,',CN=',name)name'' ''
      ('tmp/key.pem')KeyGen'rsa' 2048
      CreateRequest'tmp/conf.cfg' 'tmp/key.pem' 'tmp/req.pem'
      SignRequest'tmp/conf.cfg' 'tmp/req.pem' 'tmp/cert.pem'
      'dyalog'ToP7 name'tmp/cert.pem' 'tmp/key.pem'('server/',name,'.cer')
      'dyalog'ToP12 name'tmp/cert.pem' 'tmp/key.pem'('server/',name,'.p12')
     
      'tmp/cert.pem'copy('server/',name,'-cert.pem')
      'tmp/key.pem'copy('server/',name,'-key.pem')
    ∇

    ∇ ClientCert(name email)
      'tmp/conf.cfg'CreateConfig(COMPANYINFO,',CN=',name)''email''
      'tmp/key.pem'KeyGen'rsa' 2048
      CreateRequest'tmp/conf.cfg' 'tmp/key.pem' 'tmp/req.pem'
      SignRequest'tmp/conf.cfg' 'tmp/req.pem' 'tmp/cert.pem'
      'dyalog'ToP7 name'tmp/cert.pem' 'tmp/key.pem'('client/',name,'.cer')
      'dyalog'ToP12 name'tmp/cert.pem' 'tmp/key.pem'('client/',name,'.p12')
     
      'tmp/cert.pem'copy('client/',name,'-cert.pem')
      'tmp/key.pem'copy('client/',name,'-key.pem')
    ∇

    ⍝ List of legal items for Distinguished names
    ⍝ Note: this function is not used in any of the examples

    ∇ DN←ListDN data;list
      list←'country' 'C' 'street'
      list,←'O' 'organization' 'OU' 'unit' 'title' 'CN' 'common name'
      list,←'L' 'locality' 'ST' 'state' 'placeOfBirth' 'gender' 'countryOfCitizenship'
      list,←'countryOfResidence' 'serialNumber' 'telephoneNumber' 'surName' 'initials'
      list,←'generationQualifier' 'givenName' 'pseudonym' 'dnQualifier' 'postalCode' 'name'
      list,←'businessCategory' 'DC' 'UID' 'jurisdictionOfIncorporationLocalityName'
      list,←'jurisdictionOfIncorporationStateOrProvinceName' 'jurisdictionOfIncorporationCountryName' 'XmppAddr'
            ⍝ and numeric OIDs.
      DN←list
    ∇

    :EndSection


    :Section Generators

    ⍝ Generates a new random RSA or DSA Key (for use as private key)
    ∇ file KeyGen arg;str;outfile
      str←' --hash=sha256'
      :If 1=≡arg
          arg←⊂arg
      :EndIf
     
      :Select 1⊃arg
      :CaseList 'rsa' 'dsa'
          str,←' --',(1⊃arg)
          :If 1<⍴arg
              str,←' --bits=',⍕2⊃arg
          :EndIf
     
      :Else
          str,←' --rsa --bits=2048'
     
      :EndSelect
     
      outfile←FQFN file
      outfile exec'-V --generate-privkey --outfile ',outfile,str
    ∇

    ⍝ Generate Self-Signed CA
    ∇ CreateCA(conf cakey cacert);outfile
      outfile←FQFN cacert
      outfile exec' -V --generate-self-signed --template=',(FQFN conf),'  --load-privkey ',(FQFN cakey),' --outfile ',outfile
    ∇

    ⍝ Generate a Certificate Request
    ∇ CreateRequest(conf key cert);outfile
      outfile←FQFN cert
      outfile exec' -V --generate-request --template=',(FQFN conf),'  --load-privkey ',(FQFN key),' --outfile ',outfile
    ∇

    ⍝ Generate a Certificate by Signing a Request
    ∇ SignRequest(conf request cert);outfile
      outfile←FQFN cert
      outfile exec' -V --generate-certificate --load-request ',(FQFN request),' --template ',(FQFN conf),' --outfile ',outfile,' --load-ca-certificate ',(FQFN'CA/ca-cert.pem'),' --load-ca-privkey ',(FQFN'CA/ca-key.pem')
    ∇

    ⍝ save as PKCS#12 file
    ∇ {password}ToP12(name cert key p12);then;outfile;thenoutfile
      :If 0=⎕NC'password'
          password←''
      :Else
          password←' --password=',password
     
      :EndIf
      outfile←FQFN p12
      outfile exec' -V --load-ca-certificate ',(FQFN'CA/ca-cert.pem'),' --load-certificate ',(FQFN cert),' --load-privkey ',(FQFN key),' --to-p12 --p12-name="',name,'" --outder --outfile ',outfile,password
    ∇

    ⍝ Save as PKCS#7 file
    ∇ {password}ToP7(name cert key p7);outfile
      :If 0=⎕NC'password'
          password←''
      :Else
          password←' --password=',password
     
      :EndIf
      outfile←FQFN p7
      outfile exec' -V --load-ca-certificate ',(FQFN'CA/ca-cert.pem'),' --load-certificate ',(FQFN cert),' --load-privkey ',(FQFN key),' --p7-generate   --outfile ',outfile,password
    ∇

    :EndSection

    :Section CreateConfig

    ⍝ Create Configuration file so no questions are asked during generation
    ∇ r←conffile CreateConfig(DN name email CA);tie;writeline
      :Trap 22
          tie←(TARGET,conffile)⎕NCREATE 0
      :Else
          tie←(TARGET,conffile)⎕NTIE 0
          (TARGET,conffile)⎕NERASE tie
          tie←(TARGET,conffile)⎕NCREATE 0
      :EndTrap
      writeline←tie∘append
     
      writeline¨CommonAttr DN
     
      :If 0<⍴name
          writeline¨ServerAttr name
      :EndIf
     
      :If 0<⍴email
          writeline¨ClientAttr email
      :EndIf
     
      :If 0<⍴CA
          writeline¨CAAttr CA
      :EndIf
     
      ⎕NUNTIE tie
    ∇

    ⍝ All certificates
    ∇ r←CommonAttr DN;app
      r←⍬
      r,←⊂'dn= "',DN,'"'
      r,←⊂'serial = ',⍕SERIAL←SERIAL+7
      r,←⊂'signing_key'
      r,←⊂'encryption_key'
      r,←⊂'path_len = 3'
      r,←⊂'policy1 = 1.3.6.1.4.1.311.17.1'
      r,←⊂'policy1 =  "Microsoft Enhanced RSA and AES Cryptographic Provider"'
    ∇

    ⍝ Server Certificates
    ∇ r←ServerAttr name;app
      r←⍬
      r,←⊂'tls_www_server'
      r,←⊂'dns_name = "',name,'"'
    ⍝ r,←⊂'uri = "http://',name,'"'
      r,←⊂'expiration_days = 3650'
    ∇

    ⍝ Client Certificates
    ∇ r←ClientAttr email;app
      r←⍬
      r,←⊂'tls_www_client'
      r,←⊂'email_protection_key'
      r,←⊂'email = "',email,'"'
      r,←⊂'expiration_days = 3650'
    ∇

    ⍝ CA Certificate
    ∇ r←CAAttr CA;app
      r←⍬
      r,←⊂'cert_signing_key'
      r,←⊂'crl_signing_key'
      r,←⊂'ocsp_signing_key'
      r,←⊂'time_stamping_key'
      r,←⊂'expiration_days = 3651' ⍝ CA cert needs to last one day more
      r,←⊂'ca'
    ∇

    :EndSection

    :Section Utils

    ∇ r←FQFN filename
      r←'"',TARGET,filename,'"' ⍝ Quoted File Name
    ∇

    ∇ r←CMD arg                        ⍝ Execute an OS command
      :Select APLplatform
      :Case 'Win'
          r←⎕CMD ⎕←arg
      :Else
          r←⎕SH(⎕←arg),' ; exit 0'   ⍝ a non-zero exit code leads to a DOMAIN ERROR
      :EndSelect
    ∇

    ∇ r←{outfile}exec arg;check;then;ok;lastmod
      :If check←2=⎕NC'outfile'
          outfile←outfile~'"'
          then←{22::7⍴0 ⋄ ⊃3 ⎕NINFO ⍵}outfile
      :EndIf
      r←CMD EXEC,' ',arg                        ⍝ Call the GNUTLS executable with an argument
     
      :If check
          ok←{22::0 ⋄ 0≠2 ⎕NINFO ⍵}outfile      ⍝ OK if the file exists and isn't empty
          :Trap 22
              lastmod←⊃3 ⎕NINFO outfile
              ok←ok∧(DateToIDTS lastmod)≥DateToIDTS then
          :Else
              ok←0
          :EndTrap
     
          :If ok
              ⎕←'     Last modified: ',outfile
          :Else
              ('Creation of ',outfile,' failed')⎕SIGNAL 11
          :EndIf
      :EndIf
    ∇

    ∇ {r}←mkdir arg             ⍝ Create a directory
      r←3 ⎕MKDIR TARGET,arg
    ∇

    ∇ from copy to
          ⍝ Assumes from is a text file
      {}(⎕NGET TARGET,from)⎕NPUT(TARGET,to)1
    ∇

    ∇ rmdir folder;fldr;files         ⍝ remove directory
      fldr←TARGET,folder
      :If 0≠≢files←⊃(⎕NINFO⍠1)fldr,'/*'
          1 ⎕NDELETE¨files
      :EndIf
      1 ⎕NDELETE fldr
    ∇

    append←{⍺ ⎕arbout 'UTF-8'  ⎕ucs ⍵, EOL} ⍝ append to a UTF-8 file

    ∇ r←DateToIDTS ts;base
      :If ts∨.≠r←0
          r←(2 ⎕NQ'.' 'DateToIDN'ts)+(base⊥3↓ts)÷×/base←24 60 60 1000
      :EndIf
    ∇

    ∇ r←toolversion
      :Trap 0
          r←CMD EXEC,' -v',(APLplatform≢'Win')/' 2>/dev/null'
          r←{(⍵⍳' ')↓⍵}⊃r              ⍝ The version appears in the first line of output
      :EndTrap
    ∇
    :EndSection

:EndNamespace
