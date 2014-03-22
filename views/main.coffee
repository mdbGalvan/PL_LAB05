main = ()-> 
  myCodeMirror = $(".CodeMirror")[0].CodeMirror
  source = myCodeMirror.getValue()

  out.className = "unhidden"
  $("#INIPUT").html myCodeMirror.getValue()

  try 
    lista = '<<ol> <% _.each(tokens, function(token, index){ %> <li class="list"> <%= matches[index] %> </li> <% }); %> </ol>'
    output_template = _.template(lista)
    matches = []
    tokens = parse(source)
    for i of tokens
      matches.push JSON.stringify(tokens[i], null, 2)
    result = output_template(
                        tokens: tokens
                        matches: matches
                      ).substr 1
  catch result
    result = """<div class="error">#{result}</div>"""

  OUTPUT.innerHTML = result
  if window.localStorage
    myCodeMirror = $(".CodeMirror")[0].CodeMirror
    localStorage.original = myCodeMirror.getValue()
    localStorage.output = result;

window.main = main

window.onload = ()-> 
  PARSE.onclick = main
  if window.localStorage and localStorage.original and localStorage.output
    out.className = "unhidden"
    myCodeMirror = $(".CodeMirror")[0].CodeMirror
    myCodeMirror.setValue(localStorage.original)
    OUTPUT.innerHTML = localStorage.output
    $("#INIPUT").html myCodeMirror.getValue()
  else
    $("#original").val "VAR a, b;\n BEGIN \n CALL b;\n a = b END."
    out.className = "unhidden"
    $("#INIPUT").html $("#original").val()
    
Object.constructor::error = (message, t) ->
  t = t or this
  t.name = "SyntaxError"
  t.message = message
  throw treturn

RegExp::bexec = (str) ->
  i = @lastIndex
  m = @exec(str)
  return m  if m and m.index is i
  null

String::tokens = ->
  from = undefined                                # The index of the start of the token.
  i = 0                                           # The index of the current character.
  n = undefined                                   # The number value.
  m = undefined                                   # Matching
  result = []                                     # An array to hold the results.
  tokens =
    WHITES: /\s+/g                                # Casa con Carácter individual en espacio en blanco
    ID: /[a-zA-Z_]\w*/g                           # Casa con una palabra que contiene letras o dígitos y empieza con letras o _
    NUM: /\b\d+(\.\d*)?([eE][+-]?\d+)?\b/g        # Casa con dígitos con coma flotante
    STRING: /('(\\.|[^'])*'|"(\\.|[^"])*")/g      # Casa con palabras entre "" ó '', y escapa \", \'
    ONELINECOMMENT: /\/\/.*/g                     # Casa con // comentario
    MULTIPLELINECOMMENT: /\/[*](.|\n)*?[*]\//g    # /* comentario con multilínea */
    COMPARISONOPERATOR: /[<>=!]=|[<>]/g           # Casa con <=, >=, ==, !=, <>
    ONECHAROPERATORS: /([=()&|;:,\.<>{}[\]])/g
    ADDOP: /[+-]/g                                # Casa con + o -, útil para expression()
    MULTOP: /[*\/]/g                              # Casa con * o /, útil para term()

  RESERVED_WORD =
    p:          "P"
    P:          "P"
    "if":       "IF"
    "IF":       "IF"
    then:       "THEN"
    THEN:       "THEN"
    "while":    "WHILE"
    "WHILE":    "WHILE"
    "do":       "DO"
    "DO":       "DO"
    "begin":    "BEGIN"
    "BEGIN":    "BEGIN"
    "end":      "END"
    "END":      "END"
    "call":     "CALL"
    "CALL":     "CALL"
    "const":    "CONST"
    "CONST":    "CONST"
    "var":      "VAR"
    "VAR":      "VAR"
    "procedure":"PROCEDURE"
    "PROCEDURE":"PROCEDURE"
    "odd":      "ODD"
    "ODD":      "ODD"
  
  # Make a token object.
  make = (type, value) ->
    type: type
    value: value
    from: from
    to: i

  getTok = ->
    str = m[0]
    i += str.length # Warning! side effect on i
    str

  
  # Begin tokenization. If the source string is empty, return nothing.
  return  unless this
  
  # Loop through this text
  while i < @length
    for key, value of tokens
      value.lastIndex = i

    from = i
    
    # Ignore whitespace and comments
    if m = tokens.WHITES.bexec(this) or 
           (m = tokens.ONELINECOMMENT.bexec(this)) or 
           (m = tokens.MULTIPLELINECOMMENT.bexec(this))
      getTok()
    
    # name.
    else if m = tokens.ID.bexec(this)
      rw = RESERVED_WORD[m[0]]
      if rw
        result.push make(rw, getTok())
      else
        result.push make("ID", getTok())
    
    # number.
    else if m = tokens.NUM.bexec(this)
      n = +getTok()
      if isFinite(n)
        result.push make("NUM", n)
      else
        make("NUM", m[0]).error "Bad number"
    
    # string
    else if m = tokens.STRING.bexec(this)
      result.push make("STRING", 
                        getTok().replace(/^["']|["']$/g, ""))
    
    # comparison operator
    else if m = tokens.COMPARISONOPERATOR.bexec(this)
      result.push make("COMPARISON", getTok())
    
    # addop
    else if m = tokens.ADDOP.bexec(this)
      result.push make("ADDOP", getTok())
    
    # multop
    else if m = tokens.MULTOP.bexec(this)
      result.push make("MULTOP", getTok())
    
    # single-character operator
    else if m = tokens.ONECHAROPERATORS.bexec(this)
      result.push make(m[0], getTok())
    else
      throw "Syntax error near '#{@substr(i)}'"
  result

parse = (input) ->
  tokens = input.tokens()             # Devuelve los elementos casados: name, number, string, RESERVED_WORD, ...
  lookahead = tokens.shift()          # Toma el primer elemento casado anteriormente, ahora tokens tiene un menos
  # *****************************************************************************************************************
  # MATCH:  Método que el tipo t que se le pasa coincide con el tipo del lookahead, sino devuelve excepción. 
  #         Útil para saber si no se cierra un ), o falta then, ... Si coincide pasa al sig. objeto casado, y com-
  #         prueba que éste exista.
  # *****************************************************************************************************************  
  match = (t) ->
    if lookahead.type is t
      lookahead = tokens.shift()
      lookahead = null  if typeof lookahead is "undefined"
    else # Error. Throw exception
      throw "Syntax Error. Expected #{t} found '" + 
            lookahead.value + "' near '" + 
            input.substr(lookahead.from) + "'"
    return

  # *****************************************************************************************************************
  # PROGRAM:   
  # *****************************************************************************************************************
  program = ->
    result = block()
    if lookahead and lookahead.type is "."
      match "."
    else
      throw "Syntax Error. Expected '.' Remember to end
                 your program with a ."
    result

  # *****************************************************************************************************************
  # BLOCK:   
  # *****************************************************************************************************************
  block = ->
    results = []
    if lookahead and lookahead.type is "CONST"
       match "CONST"
       constant = ->
         result = null
         if lookahead and lookahead.type is "ID"
           left =
             type: "CONST ID"
             value: lookahead.value
           match "ID"
           match "="
           if lookahead and lookahead.type is "NUM"
             right =
               type: "NUM"
               value: lookahead.value
             match "NUM"
           else # Error!
             throw "Syntax Error. Expected NUM but found " + 
                   (if lookahead then lookahead.value else "end of input") + 
                   " near '#{input.substr(lookahead.from)}'"
         else # Error!
           throw "Syntax Error. Expected ID but found " + 
                 (if lookahead then lookahead.value else "end of input") + 
                 " near '#{input.substr(lookahead.from)}'"
         result =
           type: "="
           left: left
           right: right
         result
       results.push constant()
       while lookahead and lookahead.type is ","
         match ","
         results.push constant()
       match ";"
    
    if lookahead and lookahead.type is "VAR"
       match "VAR"
       variable = ->
         result = null
         if lookahead and lookahead.type is "ID"
           result =
             type: "VAR ID"
             value: lookahead.value
           match "ID"
         else # Error!
           throw "Syntax Error. Expected ID but found " + 
                 (if lookahead then lookahead.value else "end of input") + 
                 " near '#{input.substr(lookahead.from)}'"
         result
       results.push variable()
       while lookahead and lookahead.type is ","
         match ","
         results.push variable()
       match ";"
  
  # *****************************************************************************************************************
  # PROCEDURE:   
  # *****************************************************************************************************************
    procedure = ->
      result = null
      match "PROCEDURE"
      if lookahead and lookahead.type is "ID"
        value = lookahead.value
        match "ID"
        match ";"
        result =
          type: "PROCEDURE"
          value: value
          left: block()
        match ";"
      else # Error!
        throw "Syntax Error. Expected ID but found " + 
              (if lookahead then lookahead.value else "end of input") + 
              " near '#{input.substr(lookahead.from)}'"
      result
    while lookahead and lookahead.type is "PROCEDURE"
      results.push procedure()
    results.push statement()
    results

  # *****************************************************************************************************************
  # STATEMENTS:   A partir de aquí se analiza todo lo casado por tokens, tras hacer la llamada: [statement()],
  #               esta sentencia es n-aria y tiene un array de hijos. Va empujando los árboles en el array.
  #               Luego, se almacenará en tree.
  # *****************************************************************************************************************
  statements = ->
    result = [statement()]                                    # Array de hijos, n-aria
    while lookahead and lookahead.type is ";"
      match ";"
      result.push statement()
    (if result.length is 1 then result[0] else result)

  # *****************************************************************************************************************
  # STATEMENTS:   
  # *****************************************************************************************************************
  statement = ->
    result = null
    if lookahead and lookahead.type is "ID"
      left =
        type: "ID"
        value: lookahead.value
      match "ID"
      match "="
      right = expression()
      result =
        type: "="
        left: left
        right: right
    else if lookahead and lookahead.type is "P"
      match "P"
      right = expression()
      result =
        type: "P"
        value: right
    else if lookahead and lookahead.type is "CALL"
      match "CALL"
      result =
        type: "CALL"
        value: lookahead.value
      match "ID"
    else if lookahead and lookahead.type is "BEGIN"
      match "BEGIN"
      result = [statement()]
      while lookahead and lookahead.type is ";"
        match ";"
        result.push statement()
      match "END"
    else if lookahead and lookahead.type is "IF"  # Si casa con el Tipo if debe seguir unas pautas y se verifica
      match "IF"                                  # Primero debe casar con IF, y toma la sig.
      left = condition()                          # Se guarda en left toda la condición, que verifica: exp comp exp
      match "THEN"                                # Luego, casa con THEN, y toma la sig.
      right = statement()                         # Se guarda en right todo statement, que cumple: ID, P, ...
      result =                                    # Se guarda el resultado en result
        type: "IF"
        left: left
        right: right
    else if lookahead and lookahead.type is "WHILE"  # Si casa con while debe seguir unas pautas y se verifica
      match "WHILE"                               # Primero debe casar con WHILE, y toma la sig.
      left = condition()                          # Se guarda en left toda la condición, que verifica: exp comp exp
      match "DO"                                  # Luego, casa con DO, y toma la sig.
      right = statement()                         # Se guarda en right todo statement, que cumple: ID, P, ...
      result =                                    # Se guarda el resultado en result
        type: "WHILE"
        left: left
        right: right
    else # Error!
      throw "Syntax Error. Expected identifier but found " + 
            (if lookahead then lookahead.value else "end of input") + 
            " near '#{input.substr(lookahead.from)}'"
    result

  # *****************************************************************************************************************
  # CONDITION:  Método que se ejecuta cuando queremos verificar que se cumple una condición del tipo: expr cond expr.
  #             Útil para el if, while, ...
  # *****************************************************************************************************************
  condition = ->
    if lookahead and lookahead.type is "ODD"
      match "ODD"
      right = expression()
      result =
        type: "ODD"
        value: right
    else
        left = expression()                       # Guardamos en left la expresión a la izquierda de la condición
        type = lookahead.value                    # Se almacena en type el tipo de comparación: ==, <=, >=, ...
        match "COMPARISON"                        # Se verifica que ahora va la comparación y seguimos al sig.
        right = expression()                      # Se almacena la expresión a la derecha de la condición
        result =
          type: type
          left: left
          right: right
    result

  # *****************************************************************************************************************
  # EXPRESSION: Método que ejecutará primero term() en busca de una expresión del tipo: ID|NUM|() y un operador *|/.
  #             Luego, mira si casa con +|- y vuelve hacer la misma búsqueda de nuevo. Haciendo posible que exista 
  #             Una expresión enorme, una dentro de otras, con: +-*/ ID, NUM y ()   
  # *****************************************************************************************************************
  expression = ->
    result = term()
    while lookahead and lookahead.type is "ADDOP"
      type = lookahead.value
      match "ADDOP"
      right = term()
      result =
        type: type
        left: result
        right: right
    result

  # *****************************************************************************************************************
  # TERM: Método que se ejecuta al entrar en expression() o si en este método se identifica que existe el sig. y 
  #       el tipo: * y /.
  # *****************************************************************************************************************
  term = ->
    result = factor()
    while lookahead and lookahead.type is "MULTOP"
      type = lookahead.value
      match "MULTOP"
      right = factor()
      result =
        type: type
        left: result
        right: right
    result

  # *****************************************************************************************************************
  # FACTOR: Método que se ejecuta al entrar en term(). Identifica el tipo: NUM, ID ó (, sino devuelve una excepción.
  #         Añade el tipo y valor en result. Llama al método match con el tipo identificado para que avance al sig.
  # *****************************************************************************************************************
  factor = ->                           
    result = null
    if lookahead.type is "NUM"
      result =
        type: "NUM"
        value: lookahead.value

      match "NUM"
    else if lookahead.type is "ID"
      result =
        type: "ID"
        value: lookahead.value

      match "ID"
    else if lookahead.type is "("         # El lookahead es del tipo "(" entonces tiene que cumplir "expr )"
      match "("                           # Casa con ( y sigue con el sig.
      result = expression()               # Se idendifica la expresión y se almacena el resultado
      match ")"                           # Tiene que cerrar el paréntesis tras la expresión. Y seguimos con el sig.
    else # Throw exception
      throw "Syntax Error. Expected number or identifier or '(' but found " + 
            (if lookahead then lookahead.value else "end of input") + 
            " near '" + input.substr(lookahead.from) + "'"
    result

  tree = program(input)
  if lookahead?
    throw "Syntax Error parsing statements. " + 
          "Expected 'end of input' and found '" + 
          input.substr(lookahead.from) + "'"  
  tree

window.parse = parse