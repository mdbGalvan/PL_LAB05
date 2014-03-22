# http://js2coffee.org/

calculate = (evt) ->
  f = evt.target.files[0]
  if f
    r = new FileReader()
    r.onload = (e) ->
      $("#original").val e.target.result
      myCodeMirror.setValue(e.target.result)
      return

    r.readAsText f
  else
    alert "Failed to load file"
  return

dump_get = (fileName) ->
  $.get fileName, (data) ->
    
    #$("#original").val(data);
    myCodeMirror.setValue data
    return

  return

window.get = dump_get

dump_ajax = (fileName) ->
  $.ajax
    url: fileName
    dataType: "text"
    success: (data) ->
      
      #$("#original").val(data);
      myCodeMirror.setValue data

      return

  return

window.ajax = dump_ajax

$(document).ready ->
  $("#files").change calculate
  return