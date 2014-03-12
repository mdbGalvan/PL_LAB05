# http://js2coffee.org/

dump_ajax = (fileName) ->
  $.ajax
    url: fileName
    dataType: "text"
    success: (data) ->
      $("#original").val data
      
      # Si el navegador soporta localStore almacenamos en el localStorage los datos introducidos
      localStorage.original = data  if window.localStorage
      return

  return

dump = (fileName) ->
  $.get fileName, (data) ->
    $("#original").val data
    localStorage.original = data  if window.localStorage
    return

  return

calculate = (evt) ->
  f = evt.target.files[0]
  if f
    r = new FileReader()
    r.onload = (e) ->
      $("#original").val e.target.result
      localStorage.original = e.target.result  if window.localStorage
      return

    r.readAsText f
  else
    alert "Failed to load file"
  return

$(document).ready ->
  $("#files").change calculate
  return