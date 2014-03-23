var assert = chai.assert;

suite('PRUEBAS PARA EL LOCALSTORAGE', function() {
	test('Soporta localStorage', function() {
		if (window.localStorage) {
			localStorage.original = 'if a == 1 then call b;';
			assert.deepEqual(localStorage.original, 'if a == 1 then call b;');
		}
	});
});

suite('PRUEBAS PARA BEXEC()', function() {
	setup(function(){
		var str;
		var re;
	});
	test('NULL', function() {
		str = "dBdXXXXDBBD";
		re = /d(b+)(d)/ig;
		re.lastIndex = 3;
		assert.equal(re.bexec(str), null, 'lastIndex = 3 <> 4 = index');
    });	
	test('m', function() {
		str = "dBdXXXXDBBD";
		re = /d(b+)(d)/ig;
		re.lastIndex = 7;
		assert.isArray(re.bexec(str), '["DBBD", "BB", "D", index: 7, input: "dBdXXXXDBBD"]');
		re.lastIndex = 7;
		assert.notEqual(re.bexec(str), null, '["DBBD", "BB", "D", index: 7, input: "dBdXXXXDBBD"]');
    });	
});

suite('PRUEBAS PARA LA TOKENS()', function() {
	test('Asignación', function() {
		source = 'a = 2*4';
        tokens = source.tokens();
		assert.isArray(tokens, 'Casó con los tipos: id, =, num, *, num.');
		assert.equal(tokens[2].type, 'NUM');
	});	
	test('RESERVED_WORD: Call', function() {
		source = 'call b';
        tokens = source.tokens();
		assert.isArray(tokens, 'El resultado es un array de dos objetos.');
		assert.equal(tokens[0].type, 'CALL');
		assert.equal(tokens[1].type, 'ID');
	});	
	test('Comentario', function() {
		source = '// Comentario';
        tokens = source.tokens();
		assert.deepEqual(tokens, [], 'Devuelve el JSON vacío xq los comentarios no los incluye');
    });	
});

suite('PRUEBAS PARA DUMP_GET() Y DUMP_AJAX()', function() {
	test('GET', function() {
		window.get('/examples/example1.txt');
		assert.isString($("#original").val());
    });	
	test('AJAX', function() {
		window.ajax('/examples/example2.txt');
		assert.isString($("#original").val());
    });	
});

suite('PRUEBAS PARA MAIN() Y CODEMIRROR', function() {
	test('If', function() {
		var myCodeMirror = $('.CodeMirror')[0].CodeMirror;
   	 	myCodeMirror.setValue("begin\n if a == 1 then call b\n end.");
        window.main();
		assert.equal(OUTPUT.innerHTML,'<ol class="list">  <li class="list"> [\n  {\n    "type": "IF",\n    "left": {\n      "type": "==",\n      "left": {\n        "type": "ID",\n        "value": "a"\n      },\n      "right": {\n        "type": "NUM",\n        "value": 1\n      }\n    },\n    "right": {\n      "type": "CALL",\n      "value": "b"\n    }\n  }\n] </li>  </ol>');
    });	
	test('Call', function() {
		var myCodeMirror = $('.CodeMirror')[0].CodeMirror;
   	 	myCodeMirror.setValue("begin\n call b\n end.");
        window.main();
		assert.equal(OUTPUT.innerHTML,'<ol class="list">  <li class="list"> [\n  {\n    "type": "CALL",\n    "value": "b"\n  }\n] </li>  </ol>');
    });	
});

suite('PRUEBAS PARA PARSE()', function() {
	test('While', function() {
		var source = 'while a == b do b = 2.';
		var tokens;
		try {
			lista = '<<ol> <% _.each(tokens, function(token, index){ %> <li class="<%= index %>"> <%= matches[index] %> </li> <% }); %> </ol>';
      		output_template = _.template(lista);
		    matches = [];
		    tokens = window.parse(source);
		    for (i in tokens) {
		    	matches.push(JSON.stringify(tokens[i], null, 2));
		    }
		    result = output_template({
		    	tokens: tokens,
		    	matches: matches
		    }).substr(1);
	    } catch (_error) {
	      result = _error;
	      result = "<div class=\"error\">" + result + "</div>";
	    }
		assert.equal(result,'<ol>  <li class="0"> {\n  "type": "WHILE",\n  "left": {\n    "type": "==",\n    "left": {\n      "type": "ID",\n      "value": "a"\n    },\n    "right": {\n      "type": "ID",\n      "value": "b"\n    }\n  },\n  "right": {\n    "type": "=",\n    "left": {\n      "type": "ID",\n      "value": "b"\n    },\n    "right": {\n      "type": "NUM",\n      "value": 2\n    }\n  }\n} </li>  </ol>');
    });
	test('Begin', function() {
		var source = "begin \n call b;\n a = b end.";
		var tokens;
		try {
			lista = '<<ol> <% _.each(tokens, function(token, index){ %> <li class="<%= index %>"> <%= matches[index] %> </li> <% }); %> </ol>';
      		output_template = _.template(lista);
		    matches = [];
		    tokens = window.parse(source);
		    for (i in tokens) {
		    	matches.push(JSON.stringify(tokens[i], null, 2));
		    }
		    result = output_template({
		    	tokens: tokens,
		    	matches: matches
		    }).substr(1);
	    } catch (_error) {
	      result = _error;
	      result = "<div class=\"error\">" + result + "</div>";
	    }
		assert.equal(result,'<ol>  <li class="0"> [\n  {\n    "type": "CALL",\n    "value": "b"\n  },\n  {\n    "type": "=",\n    "left": {\n      "type": "ID",\n      "value": "a"\n    },\n    "right": {\n      "type": "ID",\n      "value": "b"\n    }\n  }\n] </li>  </ol>');    
	});
	test('Var', function() {
		var source = "var a, b;\n begin \n call b;\n a = b end.";
		var tokens;
		try {
			lista = '<<ol> <% _.each(tokens, function(token, index){ %> <li class="<%= index %>"> <%= matches[index] %> </li> <% }); %> </ol>';
      		output_template = _.template(lista);
		    matches = [];
		    tokens = window.parse(source);
		    for (i in tokens) {
		    	matches.push(JSON.stringify(tokens[i], null, 2));
		    }
		    result = output_template({
		    	tokens: tokens,
		    	matches: matches
		    }).substr(1);
	    } catch (_error) {
	      result = _error;
	      result = "<div class=\"error\">" + result + "</div>";
	    }
		assert.equal(result,'<ol>  <li class="0"> {\n  "type": "VAR ID",\n  "value": "a"\n} </li>  <li class="1"> {\n  "type": "VAR ID",\n  "value": "b"\n} </li>  <li class="2"> [\n  {\n    "type": "CALL",\n    "value": "b"\n  },\n  {\n    "type": "=",\n    "left": {\n      "type": "ID",\n      "value": "a"\n    },\n    "right": {\n      "type": "ID",\n      "value": "b"\n    }\n  }\n] </li>  </ol>');   
	});
});

suite('PRUEBAS PARA COMPROBAR ERRORES', function() {	
	test('Operador - main()', function() {
		var myCodeMirror = $('.CodeMirror')[0].CodeMirror;
   	 	myCodeMirror.setValue("a = 2 + (3");
        main();
		assert.match(OUTPUT.innerHTML, /error/);
	});

	test('Id - main()', function() {
		var myCodeMirror = $('.CodeMirror')[0].CodeMirror;
   	 	myCodeMirror.setValue('1$%&· = 5 + 3;');
        main();
		assert.match(OUTPUT.innerHTML, /error/);
	});
	test('While - parse()', function() {
		var source = "while 2 == 3";
		var tokens;
		try {
			lista = '<<ol> <% _.each(tokens, function(token, index){ %> <li class="<%= index %>"> <%= matches[index] %> </li> <% }); %> </ol>';
      		output_template = _.template(lista);
		    matches = [];
		    tokens = window.parse(source);
		    for (i in tokens) {
		    	matches.push(JSON.stringify(tokens[i], null, 2));
		    }
		    result = output_template({
		    	tokens: tokens,
		    	matches: matches
		    }).substr(1);
	    } catch (_error) {
	      result = _error;
	      result = "<div class=\"error\">" + result + "</div>";
	    }
		assert.match(OUTPUT.innerHTML, /error/);
    });	
});