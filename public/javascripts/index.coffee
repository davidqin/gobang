$(document).ready ->
  socket = io.connect()
  socket.emit 'OnLogin', nickname: "david"





  LogData = (data) ->
    console.log data

  socket.on 'loginSuccess', LogData

  socket.on 'roomList', LogData