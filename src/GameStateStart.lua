GameStateStart = Class{__includes = BaseState}

function GameStateStart:init()
  self.background = math.random(#FRAMES['backgrounds'])
  self.text = {
    { string = GAME_TITLE, font = FONTS['title'], shadow = true },
    { string = 'Press Enter', font = FONTS['medium'], shadow = true }
  }
end

function GameStateStart:update(dt)
  if love.keyboard.keysPressed['enter'] or love.keyboard.keysPressed['return'] then
    gameStateMachine:change('play')
  end
end

function GameStateStart:render()
  love.graphics.draw(TEXTURES['backgrounds'], FRAMES['backgrounds'][self.background], 0, 0)
  love.graphics.draw(TEXTURES['backgrounds'], FRAMES['backgrounds'][self.background], 
    0, BACKGROUND_HEIGHT * 2, 0, 1, -1)
  
  RenderCenteredText(self.text)
end