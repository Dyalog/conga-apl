:Class SimpleReverser : #.Conga.Connection

    ∇ MakeN arg
      :Access Public
      :Implements Constructor :Base arg
    ∇

    ∇ onReceive(obj data)
      :Access public override
      _←Respond obj(data(⌽data))
    ∇

:EndClass
