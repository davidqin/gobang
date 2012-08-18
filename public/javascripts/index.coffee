$(document).ready ->
  socket = io.connect()
  socket.emit 'roomList'

  socket.on "roomList", (data) ->
    html = ""
    for room in data.roomList
      html += "<hr><p> Room index :#{room.id}, status :#{room.status}</p>"
      html += "<button roomId=\"#{room.id}\" fun=\"in\">I am comming!</button>"
    html += '<hr>'
    $('#roomList').html(html)

  $("button[fun='in']").live 'click', ->
    socket.emit 'checkIn', roomId: $(this).attr('roomId'), playerName: "ss"

  socket.on "checkIn", (data) ->
    html = "<p>you are know in room #{data.roomId}</p>"
    html += "<button roomId=\"#{data.roomId}\" fun=\"out\" playerid=\"#{data.playerid}\" playerToken=\"#{data.playerToken}\">Exit</button>"
    $('#notice').html(html)
    $('div').hide()
    $('#notice').show()

  $("button[fun='out']").live 'click', ->
    socket.emit 'checkOut', roomId: $(this).attr('roomId'), playerId: $(this).attr('playerid'), playerToken: $(this).attr('playerToken')

  socket.on "checkOut", (data) ->
    $('div').hide()
    $('#roomList').show()

  socket.on "gameStart", (data) ->
    $('div').hide()

    list = [1..15]
    html = ""
    html += "<table>"
    for num_row in list
      html += "<tr row=#{num_row} class=\"def\">"
      for num_col in list
        html += "<td row=#{num_row} col=#{num_col}></td>"
      html += "</tr>"
    html += "</table>"

    $("#gamePool").html(html).show()
    $('#notice').show()

    $("td").live "click", ->
      row = $(this).attr "row"
      col = $(this).attr "col"
      # alert "row:" + row + ",col:" + col
      socket.emit 'click_info', playerId: data.playerId ,row: row, col: col, roomId: data.roomId

  socket.on "click_success", (data) ->
    row = data.row
    col = data.col
    $("td[row=#{row}][col=#{col}]").css("background-color","#{data.color}")

  socket.on "win", (data) ->
    alert "you win!"

  socket.on "lose", (data) ->
    alert "you lose!"