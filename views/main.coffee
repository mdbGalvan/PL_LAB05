main = ()-> 
  out.className = "unhidden"
  $("#INIPUT").html $("#original").val()
  source = original.value
  try 
    lista = '<<ol> <% _.each(tokens, function(token, index){ %> <li class="<%= index %>"> <%= matches[index] %> </li> <% }); %> </ol>'
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

window.onload = ()-> 
  PARSE.onclick = main
  if window.localStorage and localStorage.original
    $("#original").val localStorage.original
  else
    $("#original").val "b = 5 + y"

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
    ONECHAROPERATORS: /([-+*\/=()&|;:,{}[\]])/g

  RESERVED_WORD = 
    p:    "P"
    "if": "IF"
    then: "THEN"
  
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
    if lookahead.type is t            # Si el tipo del objeto (tomado de tokens) es igual que el que entró
      lookahead = tokens.shift()      # Toma el siguiente elemento casado, si ya no tenía más
      lookahead = null  if typeof lookahead is "undefined"    # entra en esta condición
    else # Error. Throw exception     # Si el tipo no coincide lanza una excepción
      throw "Syntax Error. Expected #{t} found '" + 
            lookahead.value + "' near '" + 
            input.substr(lookahead.from) + "'"
    return

  # *****************************************************************************************************************
  # STATEMENTS:   A partir de aquí se analiza todo lo casado por tokens, tras hacer la llamada: [statement()]. 
  #               Luego, se almacenará en tree.
  # *****************************************************************************************************************
  statements = ->
    result = [statement()]
    while lookahead and lookahead.type is ";"
      match ";"
      result.push statement()
    #(if result.length is 1 then result[0] else result)
    result

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
    else if lookahead and lookahead.type is "IF"  # Si casa con el Tipo if debe seguir unas pautas y se verifica
      match "IF"                                  # Primero debe casar con IF, y toma la sig.
      left = condition()                          # Se guarda en left toda la condición, que verifica: exp comp exp
      match "THEN"                                # Luego, casa con THEN, y toma la sig.
      right = statement()                         # Se guarda en right todo statement, que cumple: ID, P, ...
      result =                                    # Se guarda el resultado en result
        type: "IF"
        left: left
        right: right
    else # Error!
      throw "Syntax Error. Expected identifier but found " + 
        (if lookahead then lookahead.value else "end of input") + 
        " near '#{input.substr(lookahead.from)}'"
    result

  # *****************************************************************************************************************
  # CONDITION:  Método que se ejecuta cuando queremos verificar que se cumple una condición del tipo: expr cond expr 
  # *****************************************************************************************************************
  condition = ->
    left = expression()                           # Guardamos en left la expresión a la izquierda de la condición
    type = lookahead.value                        # Se almacena en type el tipo de comparación: ==, <=, >=, ...
    match "COMPARISON"                            # Se verifica que ahora va la comparación y seguimos al sig.
    right = expression()                          # Se almacena la expresión a la derecha de la condición
    result =
      type: type
      left: left
      right: right
    result

  expression = ->
    result = term()
    if lookahead and lookahead.type is "+"
      match "+"
      right = expression()
      result =
        type: "+"
        left: result
        right: right
    result

  # *****************************************************************************************************************
  # TERM: Método que se ejecuta al entrar en expression() o si en este método se identifica que existe el sig. y 
  #       el tipo: *.
  # *****************************************************************************************************************
  term = ->
    result = factor()
    if lookahead and lookahead.type is "*"
      match "*"
      right = term()
      result =
        type: "*"
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
    else if lookahead.type is "("               # El lookahead es del tipo "(" entonces tiene que cumplir "expr )"
      match "("                                 # Casa con ( y sigue con el sig.
      result = expression()                     # Se idendifica la expresión y se almacena el resultado
      match ")"                                 # Tiene que cerrar el paréntesis tras la expresión. Y seguimos con el sig.
    else # Throw exception
      throw "Syntax Error. Expected number or identifier or '(' but found " + 
        (if lookahead then lookahead.value else "end of input") + 
        " near '" + input.substr(lookahead.from) + "'"
    result

  tree = statements(input)
  if lookahead?
    throw "Syntax Error parsing statements. " + 
      "Expected 'end of input' and found '" + 
      input.substr(lookahead.from) + "'"  
  tree