$(document).ready ->
  socket = null

  $("#ready").hide()

  $("div[roomId]").live 'click', ->
    socket.emit 'OnJoinRoom', roomId: $(this).attr('roomId')

  $("#dlgBg").css
    width  : $(document).width()
    height : $(document).height()
  $("#login").css
    left : ($(document).width() - $("#login").width()) / 2
    top  : 100
  $("#gamePool").hide()

  $("#ready button").live 'click', ->
    socket.emit 'OnReady'

  $("#loginBtn").click ->
    socket = io.connect()
    initOnAction(socket)
    nickname = $("#nickname").val()
    if !nickname
      alert("请输入昵称")
      $("#nickname").val('').focus()
      return
    socket.emit 'OnLogin', nickname: nickname

  loginSuccess = (data) ->
    $("#dlgBg").remove()
    $("#login").remove()
    drawRoomList(data.roomList)

  readySuccess = (data) ->
    $("#ready").hide()

  joinRoomSuccess= (data) ->
    $("#roomList").hide()

    list = [1..15]
    html = ""
    html += "<table>"
    for num_row in list
      html += "<tr row=#{num_row} class=\"def\">"
      for num_col in list
        html += "<td x=#{num_row} y=#{num_col}></td>"
      html += "</tr>"
    html += "</table>"

    $("#gamePool").html(html).show()

    $("#ready").show().css
      left : ($(document).width() - $("#ready").width()) / 2
      top  : 100

  changeRoomStatus = (data) ->
    if data.p1_name
      html = "<p>Player1: #{data.p1_name}, status:#{data.p1_status}</p>"
      $('#player_1').html(html)

    if data.p2_name
      html = "<p>Player2: #{data.p2_name}, status:#{data.p2_status}</p>"
      $('#player_2').html(html)

  gameStart = (data) ->
    $("td").live "click", ->
      x = $(this).attr "x"
      y = $(this).attr "y"
      socket.emit 'OnPutPiece', x:x, y:y

  drawPiece = (data) ->
    $("td[x=#{data.x}][y=#{data.y}]").css "background-image","url(/images/#{data.position}.png)"

  gameOver = (data) ->
    $("#ready").show()

  joinRoomFailed = ->

  drawRoomList = (list) ->
    html = ""
    for room in list
      html += "<div roomId=\"#{room.id}\" class=\"button\"><p> Room index :#{room.id}, status :#{room.status}</p></div>"
    html += ''
    $('#roomList').html(html)

  reLoadRoomList = (data) ->
    drawRoomList(data.roomList)

  initOnAction = (socket) ->
    socket.on 'loginSuccess',    loginSuccess
    socket.on 'roomList',        reLoadRoomList
    socket.on 'joinRoomSuccess', joinRoomSuccess
    socket.on 'readySuccess',    readySuccess
    socket.on 'roomStatus',      changeRoomStatus
    socket.on 'gameStart',       gameStart
    socket.on 'putPiece',        drawPiece
    socket.on 'gameOver',        gameOver
    socket.on 'joinRoomFailed',  joinRoomFailed
