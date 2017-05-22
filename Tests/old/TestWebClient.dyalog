 z←TestWebClient url
     ⍝ Get something from "the web"

 url←url,(0=⍴url)/'http://www.dyalog.com/'
 z←HTTPGet url
