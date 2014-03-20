# Resumen

Tras la [práctica 4](http://pl-lab04.herokuapp.com/), la siguiente fase en la construcción del *analizador* es la fase de *análisis sintáctico*. Esta toma como entrada el flujo de terminales y construye como salida el *árbol de análisis sintáctico abstracto* concretamente para la EBNF-like grammar (for **Niklaus Wirth's** PL/0 programming language).

El *árbol de análisis sintáctico abstracto* es una representación compactada del árbol de análisis sintáctico concreto que contiene la misma información que éste.

Existen diferentes *métodos* de *análisis sintáctico*. La mayoría caen en una de dos categorías: *ascendentes* y *descendentes*. Los *ascendentes* construyen el árbol desde las hojas hacia la raíz. Los *descendentes* lo hacen en modo inverso. El que describiremos aquí es uno de los mas sencillos: se denomina **Método de Análisis Predictivo Descendente Recursivo**.

![alt text](http://pl-lab05.herokuapp.com/images/PL0.png "PL/0")

# Motivación

La aplicación fue propuesta para ser desarrolla en la asignatura **Procesadores de Lenguajes**, del tercer año del **Grado en Ingeniería Informática**. Se corresponde con la 5ª práctica de la asignatura.

# Funcionamiento

Puede probar en [Heroku](http://pl-lab05.herokuapp.com/), el funcionamiento del *Analizador Descendente Predictivo Recursivo*.

...

# Desarrollo

Los lenguajes y herramientas (frameworks, librerías, etc.) utilizados para el desarrollo del presente proyecto fueron:

* Ruby gems
* [Sinatra](http://www.sinatrarb.com/configuration.html)
* [Heroku](https://dashboard.heroku.com/apps)
* HTML/CSS/Javascript
* [JQuery](http://jquery.com/)
* [CoffeeScript](http://coffeescript.org/) 
* [Slim](http://slim-lang.com/)
* [Sass](http://sass-lang.com/) 

# Tests

Entorno de pruebas basado en [Mocha](http://visionmedia.github.io/mocha/) y [Chai](http://chaijs.com/guide/installation/). 

Pueden ejecutarse las pruebas [aquí](http://pl-lab05.herokuapp.com/tests) **EN PROCESO**.


# Colaboradores

| Autores | E-mail |
| ---------- | ---------- |
| María D. Batista Galván   | magomenlopark@gmail.com  |


# Licencia

Léase el archivo LICENSE.txt.

