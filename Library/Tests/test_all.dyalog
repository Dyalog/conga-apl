:Namespace test_httpcommand

    (⎕IO ⎕ML)←1 1

    _httpbin←'httpbin.org'
    _typicode←'https://jsonplaceholder.typicode.com/'

    HttpCommand←#.HttpCommand

    _AplVersion←2⊃⎕VFI{⍵/⍨∧\⍵≠'.'}2⊃#.⎕WG'APLVersion'
    fromJSON←{16≤_AplVersion:⎕JSON ⍵ ⋄ (7159⌶)⍵}

    _true←⊂'true'

    ∇ {r}←TestAll;tests;test                
     ∘∘∘
      tests←(⊂'TestAll')~⍨tests/⍨{'Test'≡4↑⍵}¨tests←⎕NL ¯3
      r←⍬
      :For test :In tests
          r,←{(0≠≢⍵)/⊂⍵}⍎test
      :EndFor
    ∇

    ∇ {r}←TestGet
      r←''
      :If 0 200 ##.check (HttpCommand.Get _httpbin,'/get ').(rc HttpStatus)
          r←'HTTP Get Basic failed'
      :EndIf
    ∇

    ∇ {r}←TestDeflate;result
      r←''
      result←HttpCommand.Get _httpbin,'/deflate'
      :Trap 0
          :If (0 200,_true,(⊂'deflate'))##.check result.(rc HttpStatus),((fromJSON result.Data).deflated),⊂result.Headers HttpCommand.Lookup'content-encoding'
              r←'Deflate failed'
          :EndIf
      :Else
          ∘∘∘
      :EndTrap     
    ∇

    ∇ {r}←TestGzip;result
      r←''
      result←HttpCommand.Get _httpbin,'/gzip'
      :Trap 0
          :If (0 200,_true,(⊂'gzip')) ##.check result.(rc HttpStatus),((fromJSON result.Data).gzipped),⊂result.Headers HttpCommand.Lookup'content-encoding'
              r←'Gzip failed'
          :EndIf
      :EndTrap
    ∇

    ∇ {r}←TestChunked;result
      r←''
      result←HttpCommand.Get'https://www.httpwatch.com/httpgallery/chunked/chunkedimage.aspx'
      :If 0 200 'chunked' ##.check result.(rc HttpStatus),⊂result.Headers HttpCommand.Lookup'transfer-encoding'
        r←'HTTP GET chunked FILED' 
      :EndIf      
    ∇

    ∇ {r}←TestRestfulGet;host
      r←''
      :If 0 200 ##.check (HttpCommand.Get _typicode,'posts').(rc HttpStatus)
          r←'RESTful GET all posts failed'
      :EndIf      
    ∇

    ∇ {r}←TestRestfulPost;host;params
      r←''
      (params←⎕NS'').(title body userId)←'foo' 'bar' 1 
      :If 0 201 ##.check (HttpCommand.Do'post'(_typicode,'posts')params).(rc HttpStatus)
          r←'RESTful POST failed'
      :EndIf
      
    ∇

    ∇ {r}←TestRestfulPut;host;params
      (params←⎕NS'').(title body userId id)←'foo' 'bar' 1 200
      r←'RESTful PUT'report 0 200∧.=(HttpCommand.Do'put'(_typicode,'posts/1')params).(rc HttpStatus)
    ∇

:EndNamespace
