 r←Clt a
⍝ Create a Client
⍝    "Name",            // string
⍝    "Address",         // string
⍝    "Port",            // Integer or service name
⍝    "Mode",            // command,raw,text
⍝    "BufferSize",
⍝    "SSLValidation",   // integer
⍝    "EOM",             // Vector of stop strings
⍝    "IgnoreCase",      // boolean
⍝    "Protocol",        // ipv4,ipv6
⍝    "PublicCertData",
⍝    "PrivateKeyFile",
⍝    "PrivateKeyPass",
⍝    "PublicCertFile",
⍝    "PublicCertPass",
⍝    "PrivateKeyData'

 a←reparg a
 r←check ⍙CallR RootName'AClt'a 0
