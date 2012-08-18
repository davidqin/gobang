$(document).ready ->
  list = [0..14]
  html = ""
  html += "<table>"
  for num_row in list
    html += "<tr row=#{num_row} class=\"def\">"
    for num_col in list
      html += "<td row=#{num_row} col=#{num_col}></td>"
    html += "</tr>"
  html += "</table>"

  $("#gamePool").html(html)

  socket = null
  $('#begin').live 'click', ->
    socket = io.connect()
    socket.emit 'ready', message: 'ready'
    $(this).hide()

  $("td").live "click", ->
    row = $(this).attr "row"
    col = $(this).attr "col"
    # alert "row:" + row + ",col:" + col
    socket.emit 'click_info', row: row, col: col

  socket.on 'info', (data) ->
    $("#info").html(data)



