$(document).ready ->
  socket = io.connect()

  welcomeHtml     = "<div class=\"player-info\"><h3>Welcome</h3></div>"
  readyButtonHtml = "<button id=\"ready-button\" class=\"button green brackets\" style=\"display: inline-block; \">✔READY</button>"
  exitButtonhTML  = "<button id=\"exit-room-button\" class=\"button pink brackets\">EXIT</button>"

  $("button[roomId]").live 'click', ->
    socket.emit 'JoinRoomRequest', roomId: $(this).attr('roomId')

  $("#dlgBg").css
    width  : $(document).width()
    height : $(document).height()
  $("#login").css
    left : ($(document).width() - $("#login").width()) / 2
    top  : 100
  $("#gamePool").hide()

  $("#ready-button").live 'click', ->
    socket.emit 'ReadyRequest'

  $("#exit-room-button").live 'click', ->
    socket.emit 'ExitRoomRequest'

  $("#loginBtn").click ->
    initOnAction(socket)
    nickname = $("#nickname").val()
    if !nickname
      alert("请输入昵称")
      $("#nickname").val('').focus()
      return
    socket.emit 'LoginRequest', nickname: nickname

  loginSuccess = (data) ->
    $("#dlgBg").remove()
    $("#login").remove()
    #$("#left").html(welcomeHtml)
    drawRoomList(data.roomList)

  readySuccess = (data) ->
    $("#functions").html('').append(exitButtonhTML)
    resetGamePool()

  resetGamePool = ->
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

  joinRoomSuccess= (data) ->
    $("#roomList").hide()
    resetGamePool()
    $("#functions").append(readyButtonHtml).append(exitButtonhTML)

  playerInfoHtml= (position, name, status) ->
    html =
    "<div id=\"player_#{position}\" class=\"player-info\">
       <h3>Player#{position}</h3>
       <h4>#{name}</h4>"
    if status == 0
      html += "<span class=\"label\">not Ready</span>"
    else if status == 1
      html += "<span class=\"label label-success\" >Ready</span>"

    html += "</div>"

  changeRoomStatus = (data) ->
    $('#players').html('')
    if data.p1_name
      $('#players').prepend(playerInfoHtml(1, data.p1_name, data.p1_status))

    if data.p2_name
      $('#players').append(playerInfoHtml(2, data.p2_name, data.p2_status))

  gameStart = (data) ->
    $("td").live "click", ->
      x = $(this).attr "x"
      y = $(this).attr "y"
      socket.emit 'PutPieceRequest', x:x, y:y

  drawPiece = (data) ->
    $("td[x=#{data.x}][y=#{data.y}]").css "background-image","url(/images/#{data.position}.png)"

  gameOver = (data) ->
    console.log data
    $("#ready-button").show()

  joinRoomFailed = ->

  drawRoomList = (list) ->
    html = ""
    for room in list
      html += "<button data-icon=\"✰\" roomId=\"#{room.id}\" style=\"width: 100%;\" class=\"button serif\"> Room index :#{room.id}  Room Status :#{room.status}  watcher: 0</button>"
    html += ''
    $('#roomList').html(html)

  reLoadRoomList = (data) ->
    drawRoomList(data.roomList)

  noticeTurn = (data) ->
    $("#player_1").removeClass("notice-turn")
    $("#player_2").removeClass("notice-turn")
    $("#player_#{data.turn}").addClass("notice-turn")

  exitRoomSuccess = (data) ->
    $("#players").html('')
    $("#watchers").html('')
    $("#functions").html('')
    $("#roomList").show()
    $("#gamePool").hide()

  resetFunctions = (data) ->
    $("#functions").html('')
    $("#functions").append(readyButtonHtml).append(exitButtonhTML)


  initOnAction = (socket) ->
    socket.on 'gameOver',        gameOver
    socket.on 'gameStart',       gameStart
    socket.on 'joinRoomFailed',  joinRoomFailed
    socket.on 'joinRoomSuccess', joinRoomSuccess
    socket.on 'exitRoomSuccess', exitRoomSuccess
    socket.on 'loginSuccess',    loginSuccess
    socket.on 'noticeTurn',      noticeTurn
    socket.on 'putPiece',        drawPiece
    socket.on 'readySuccess',    readySuccess
    socket.on 'roomList',        reLoadRoomList
    socket.on 'roomStatus',      changeRoomStatus
    socket.on 'resetFunctions',  resetFunctions