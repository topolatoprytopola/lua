function love.load()
    lume = require "lume"
    menus = { 'Play', 'Load', 'Quit' }
    game_state = 'menu'
    move = love.audio.newSource('move.wav', "static")
    hit = love.audio.newSource('hit.wav', "static")
    clear = love.audio.newSource('clear.wav', "static")
    selected_menu_item = 1
    local font = love.graphics.setNewFont(30)
    font_height = font:getHeight()
    window_width, window_height = love.graphics.getDimensions()
    points = 0
    time = 0
    timerLimit = 0.5
    initPieces()
    boardXMax = 10
    boardYMax = 18
    reset()
    initBoard()
    newTetris(3,0)
end
function love.update(dt)
    if game_state == 'game' then
    time = time + dt
    if time >= timerLimit then
        time = 0
        if canPieceMove(locX,locY + 1,tetrisRotation) then
        locY = locY + 1       
    else
        for y = 1, 4 do
            for x = 1, 4 do
                local block = tetrisPieces[tetrisIndex][tetrisRotation][y][x]
                if block ~= ' ' then
                board[locY + y][locX + x] = block
                end
            end
        end
        checkIfFinished()
        newTetris(3,0)
        if not canPieceMove(locX, locY, tetrisRotation) then
            reset()
        end
    end
    end
end
end
function love.draw()
    if(game_state == 'game') then     
        drawBoard()
        drawPoints()
    elseif(game_state == 'menu') then
        drawMainMenu()
    else
        drawSaveMenu()
    end
end
function love.keypressed(key)
    if game_state == 'menu' then
        menu_keypressed(key)
    
      elseif game_state == 'game' then
        game_keypressed(key)
    
      else
        pause_keypressed(key)
      end
end
function pause_keypressed(key)
    if key == 's' then
        saveGame()
        game_state = 'game'
    elseif key == 'escape' then
        game_state = 'game'
    end
end
function game_keypressed(key)
    if key == 'x' then
        local tetrisRotationTest = tetrisRotation + 1
        if tetrisRotationTest > #tetrisPieces[tetrisIndex] then
            tetrisRotationTest = 1
        end
        if canPieceMove(locX,locY, tetrisRotationTest) then
            move:play()
            tetrisRotation = tetrisRotationTest
        end

    elseif key == 'z' then
        local tetrisRotationTest = tetrisRotation - 1
        if tetrisRotationTest < 1 then
            tetrisRotationTest = #tetrisPieces[tetrisIndex]
        end
        if canPieceMove(locX,locY, tetrisRotationTest) then
            move:play()
            tetrisRotation = tetrisRotationTest
        end
    elseif key == 'left' then
        if canPieceMove(locX - 1,locY, tetrisRotation) then
        move:play()
        locX = locX - 1
        end

    elseif key == 'right' then
        if canPieceMove(locX + 1,locY, tetrisRotation) then
        move:play()
        locX = locX + 1
        end
    elseif key == 'c' then
        while canPieceMove(locX, locY + 1, tetrisRotation) do
            locY = locY + 1
            time = timerLimit
            hit:play()
        end
    elseif key == 'escape' then
        game_state = 'pause'
    end
end
function menu_keypressed(key)
    if key == 'escape' then
      love.event.quit()
    elseif key == 'up' then
  
      selected_menu_item = selected_menu_item - 1
  
      if selected_menu_item < 1 then
        selected_menu_item = #menus
      end
    elseif key == 'down' then
  
      selected_menu_item = selected_menu_item + 1
  
      if selected_menu_item > #menus then
        selected_menu_item = 1
      end
    elseif key == 'return' or key == 'kpenter' then
  
      if menus[selected_menu_item] == 'Play' then
        game_state = 'game'
  
      elseif menus[selected_menu_item] == 'Load' then
        game_state = 'load'
        loadGame()
  
      elseif menus[selected_menu_item] == 'Quit' then
        love.event.quit()
      end
  
    end
  
  end
function drawBoard()
    for y = 1, boardYMax do
        for x = 1, boardXMax do
        drawSquare(board[y][x],x,y)
        end
    end
    for y = 1, 4 do
        for x = 1, 4 do
            local block = tetrisPieces[tetrisIndex][tetrisRotation][y][x]
            if block ~= ' ' then
                drawSquare(block, x + locX, y + locY)
            end
        end
    end
end
function drawSquare(square,x,y)
    color = colors[square]
    love.graphics.setColor(color)
    blockSize = 60
    blockDrawSize = blockSize - 1
    love.graphics.rectangle(
        'fill',
        (x - 1) * blockSize,
        (y - 1) * blockSize,
        blockDrawSize,
        blockDrawSize
    )
end
function drawMainMenu()
    local vertical_center = window_height / 2
    local start_y = vertical_center - (font_height * (#menus / 2))
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Tetris", 0, 150, window_width, 'center')
    for i = 1, #menus do
      if i == selected_menu_item then
        love.graphics.setColor(1, 1, 0, 1)
      else
        love.graphics.setColor(1, 1, 1, 1)
      end
      love.graphics.printf(menus[i], 0, start_y + font_height * (i-1), window_width, 'center')
  
    end
  
end
function drawSaveMenu()
    local vertical_center = window_height / 2
    local start_y = vertical_center - (font_height * (#menus / 2))
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Press 'S' to save. Press 'Esc' to return", 0, start_y + font_height, window_width, 'center')
end
function drawPoints()
    love.graphics.setColor(0, 0, 0, 1)
    local start_y = 0
    love.graphics.printf("Points:" .. points, 0, start_y + font_height, window_width, 'right')
end
function saveGame()
    data = {}
    data = {
        points = points,
        board = board,
        locX = locX,
        locY = locY,
        time = time,
        tetrisIndex = tetrisIndex,
        tetrisRotation = tetrisRotation
    }
    serialized = lume.serialize(data)
    love.filesystem.write("savedata.txt", serialized)
end
function loadGame()
    if love.filesystem.getInfo("savedata.txt") then
        file = love.filesystem.read("savedata.txt")
        data = lume.deserialize(file)
        points = data.points
        board = data.board
        locX = data.locX
        locY = data.locY
        time = data.time
        tetrisIndex = data.tetrisIndex
        tetrisRotation = data.tetrisRotation
        game_state = 'game'
    else
        game_state = 'menu'
    end
end
function initBoard()
    colors = {
        [' '] = {.87, .87, .87},
        i = {.47, .76, .94},
        j = {.93, .91, .42},
        l = {.49, .85, .76},
        o = {.92, .69, .47},
        s = {.83, .54, .93},
        t = {.97, .58, .77},
        z = {.66, .83, .46},
    }
    for y = 1, boardYMax do
        board[y] = {}
        for x = 1, boardXMax do
            board[y][x] = ' '
        end
    end
end
function initPieces()
    tetrisPieces  = {
        {
            {
                {' ', ' ', ' ', ' '},
                {'i', 'i', 'i', 'i'},
                {' ', ' ', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 'i', ' ', ' '},
                {' ', 'i', ' ', ' '},
                {' ', 'i', ' ', ' '},
                {' ', 'i', ' ', ' '},
            },
        },
        {
            {
                {' ', ' ', ' ', ' '},
                {' ', 'o', 'o', ' '},
                {' ', 'o', 'o', ' '},
                {' ', ' ', ' ', ' '},
            },
        },
        {
            {
                {' ', ' ', ' ', ' '},
                {'j', 'j', 'j', ' '},
                {' ', ' ', 'j', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 'j', ' ', ' '},
                {' ', 'j', ' ', ' '},
                {'j', 'j', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {'j', ' ', ' ', ' '},
                {'j', 'j', 'j', ' '},
                {' ', ' ', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 'j', 'j', ' '},
                {' ', 'j', ' ', ' '},
                {' ', 'j', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
        },
        {
            {
                {' ', ' ', ' ', ' '},
                {'l', 'l', 'l', ' '},
                {'l', ' ', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 'l', ' ', ' '},
                {' ', 'l', ' ', ' '},
                {' ', 'l', 'l', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', ' ', 'l', ' '},
                {'l', 'l', 'l', ' '},
                {' ', ' ', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {'l', 'l', ' ', ' '},
                {' ', 'l', ' ', ' '},
                {' ', 'l', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
        },
        {
            {
                {' ', ' ', ' ', ' '},
                {'t', 't', 't', ' '},
                {' ', 't', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 't', ' ', ' '},
                {' ', 't', 't', ' '},
                {' ', 't', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 't', ' ', ' '},
                {'t', 't', 't', ' '},
                {' ', ' ', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 't', ' ', ' '},
                {'t', 't', ' ', ' '},
                {' ', 't', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
        },
        {
            {
                {' ', ' ', ' ', ' '},
                {' ', 's', 's', ' '},
                {'s', 's', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {'s', ' ', ' ', ' '},
                {'s', 's', ' ', ' '},
                {' ', 's', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
        },
        {
            {
                {' ', ' ', ' ', ' '},
                {'z', 'z', ' ', ' '},
                {' ', 'z', 'z', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 'z', ' ', ' '},
                {'z', 'z', ' ', ' '},
                {'z', ' ', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
        },
    }
end
function canPieceMove(checkX, checkY, checkRotation)
    for y = 1, 4 do
        for x = 1, 4 do
            if tetrisPieces[tetrisIndex][checkRotation][y][x] ~= ' '
            and ((checkX + x) < 1 or (checkX + x) > boardXMax or (checkY + y) > boardYMax or board[checkY + y][checkX + x] ~= ' ') then
                return false
            end
        end
    end
    return true
end
function newTetris(x,y)
    locX = x
    locY = y
    tetrisIndex = love.math.random(#tetrisPieces)
    tetrisRotation = love.math.random(#tetrisPieces[tetrisIndex])
end
function checkIfFinished()
    for y = 1, boardYMax do
        local complete = true
        for x = 1, boardXMax do
            if board[y][x] == ' ' then
                complete = false
                break
            end
        end
        if complete then
            points = points + 1
            clear:play()
            for removeY = y, 2, -1 do
                for removeX = 1, boardXMax do
                    board[removeY][removeX] =
                    board[removeY - 1][removeX]
                end
            end
        end

        for removeX = 1, boardXMax do
            board[1][removeX] = ' '
        end
    end
end
function reset()
    board = {}
    for y = 1, boardYMax do
        board[y] = {}
        for x = 1, boardXMax do
            board[y][x] = ' '
        end
    end
    newTetris(3,0)
    time = 0
    points = 0
end