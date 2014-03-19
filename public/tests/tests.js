var assert = chai.assert;

suite('PRUEBAS PARA EL LOCALSTORAGE', function() {
	test('Soporta localStorage', function() {
		if (window.localStorage) {
			localStorage.original = 'if a == 1 then call b;';
			assert.deepEqual(localStorage.original, 'if a == 1 then call b;');
		}
	});
});
