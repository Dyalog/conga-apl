 r←Certs a
      ⍝ Return certificates. Arguments can be:
      ⍝ 'ListMSStores': return list of Microsoft Certificate Stores
      ⍝ 'MSStore' storename Issuer subject details api password: Certs in a named store
 r←check ⍙CallR RootName'ACerts'a 0
