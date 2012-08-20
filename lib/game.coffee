class Game
  constructor: ->
    @gameMap = []
    for i in [1..16]
      @gameMap.push new Array(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

  win: (number) ->
    for i in [1..15]
      for j in [1..15]
        return true if @checkWin i,j,number
    false

  checkWin: (i,j,number) ->
    if j + 4 <= 15
      return true if @five(i,j,0,1,number)

    if j - 4 >= 1 and i + 4 <=15
      return true if @five(i,j,1,-1,number)

    if i + 4 <= 15
      return true if @five(i,j,1,0,number)

    if i + 4 <= 15 and j + 4 <= 15
      return true if @five(i,j,1,1,number)

    false

  five: (i,j,d_i,d_j,num) ->
    if @gameMap[i][j] == num and @gameMap[i + d_i][j + d_j] == num and @gameMap[i + d_i * 2][j + d_j * 2] == num and @gameMap[i + d_i * 3][j + d_j * 3] == num and @gameMap[i + d_i * 4][j + d_j * 4] == num
      return true
    else
      return false

exports.Game = Game