# http://js2coffee.org/

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