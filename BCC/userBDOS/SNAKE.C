// Simple snake game
// Use the arrow keys on the USB keyboard
// If using a different HID, use the wasd keys
// In any case, press esc to exit

#define word char

#include "LIB/MATH.C"
#include "LIB/STDLIB.C"
#include "LIB/SYS.C"
#include "LIB/GFX.C"

#define START_DELAY 120
#define STEP_DELAY 20
#define MIN_DELAY 30

#define BOARD_WIDTH 40
#define BOARD_HEIGHT 24
#define SCORE_Y 24

// Snake directions
#define UP 0
#define DOWN 1
#define RIGHT 2
#define LEFT 3

#define CHAR_UP 30
#define CHAR_DOWN 31
#define CHAR_RIGHT 16
#define CHAR_LEFT 17

#define CHAR_WALL 219
#define CHAR_BODY 177
#define CHAR_FOOD 7

#define BTN_LEFT 256
#define BTN_RIGHT 257
#define BTN_UP 258
#define BTN_DOWN 259

word score = 0;
word delayTime = START_DELAY;

word xFood = 0;
word yFood = 0;

struct coordinate{
  word x;
  word y;
} snake[(BOARD_WIDTH-1)*(BOARD_HEIGHT-1)];

word snakeLen;

word dir = RIGHT;

word dirOnScreen = RIGHT; // keep track of the direction of the rendered snake

word gameOver = 0;

word rngLfsr = 0xACE1;
word rngBit = 0;

word rngRand()
{
  rngBit  = ((rngLfsr >> 0) ^ (rngLfsr >> 2) ^ (rngLfsr >> 3) ^ (rngLfsr >> 5) ) & 1;
  rngLfsr = (rngLfsr >> 1) | (rngBit << 15);
  return rngLfsr;
}


void setTimer3(word ms)
{
  // clear result
  timer3Value = 0;

  // set timer
  word *p = (word *) TIMER3_VAL;
  *p = ms;
  // start timer
  word *q = (word *) TIMER3_CTRL;
  *q = 1;
}


void clearScreen()
{
  GFX_clearWindowtileTable();
  //GFX_clearWindowpaletteTable(); // no colors yet
}

void drawBorder()
{
  word x, y;
  y = 0;
  char wallchar = CHAR_WALL;
  for (x = 0; x < BOARD_WIDTH; x++)
  {
    GFX_printWindowColored(&wallchar, 1, GFX_WindowPosFromXY(x, y), 0);
  }
  y = BOARD_HEIGHT-1;
  for (x = 0; x < BOARD_WIDTH; x++)
  {
    GFX_printWindowColored(&wallchar, 1, GFX_WindowPosFromXY(x, y), 0);
  }

  x = 0;
  for (y = 0; y < BOARD_HEIGHT; y++)
  {
    GFX_printWindowColored(&wallchar, 1, GFX_WindowPosFromXY(x, y), 0);
  }

  x = BOARD_WIDTH-1;
  for (y = 0; y < BOARD_HEIGHT; y++)
  {
    GFX_printWindowColored(&wallchar, 1, GFX_WindowPosFromXY(x, y), 0);
  }
}

void drawScore()
{
  GFX_printWindowColored("Score:", 6, GFX_WindowPosFromXY(0, SCORE_Y), 0);
  char scoreBuf[32];
  itoa(score, scoreBuf);
  GFX_printWindowColored(scoreBuf, strlen(scoreBuf), GFX_WindowPosFromXY(7, SCORE_Y), 0);
}

void drawPlayer()
{
  // draw head

  char bodyChar = 0;
  switch(dir)
  {
    case UP:
      bodyChar = CHAR_UP;
      break;
    case DOWN:
      bodyChar = CHAR_DOWN;
      break;
    case LEFT:
      bodyChar = CHAR_LEFT;
      break;
    case RIGHT:
      bodyChar = CHAR_RIGHT;
      break;
  }
  GFX_printWindowColored(&bodyChar, 1, GFX_WindowPosFromXY(snake[0].x, snake[0].y), 0);

  // draw body
  word i;
  for (i = 1; i < snakeLen; i++)
  {
    char bodyChar = CHAR_BODY;
    GFX_printWindowColored(&bodyChar, 1, GFX_WindowPosFromXY(snake[i].x, snake[i].y), 0);
  }
}

void drawFood()
{
  char foodChar = CHAR_FOOD;
  GFX_printWindowColored(&foodChar, 1, GFX_WindowPosFromXY(xFood, yFood), 0);
}

word genNewFoodX()
{
  // gen random number within screen width
  word randX = MATH_modU(rngRand(), BOARD_WIDTH);
  // fix on borders
  if (randX == 0)
  {
    randX = 1;
  }
  else if (randX == BOARD_WIDTH -1)
  {
    randX = BOARD_WIDTH -2;
  }
  return randX;
}

word genNewFoodY()
{
  // gen random number within screen width
  word randY = MATH_modU(rngRand(), BOARD_HEIGHT);
  // fix on borders
  if (randY == 0)
  {
    randY = 1;
  }
  else if (randY == BOARD_HEIGHT -1)
  {
    randY = BOARD_HEIGHT -2;
  }
  return randY;
}

word collidesWithSnake(word x, word y)
{
  // collision with snake
  word i;
  for (i = 0; i<snakeLen; i++)
  {
    if (x == snake[i].x && y == snake[i].y)
    {
      return 1;
    }
  }
  return 0;
}

word checkFoodCollision()
{
  if (snake[0].x == xFood && snake[0].y == yFood)
  {
    score++;
    snakeLen++;
    xFood = genNewFoodX();
    yFood = genNewFoodY();

    // repeat if collision with snake, until no collision anymore
    // TODO: check and update only one axis at the time if collision
    while(collidesWithSnake(xFood, yFood))
    {
      xFood = genNewFoodX();
      yFood = genNewFoodY();
    }
    return 1;
  }
  return 0;
}

void updatePlayer(word keepTail)
{
  // check which button is held
  if (BDOS_USBkeyHeld(BTN_LEFT))
  {
    if (dirOnScreen != RIGHT)
    {
      dir = LEFT;
    }
  }
  else if (BDOS_USBkeyHeld(BTN_RIGHT))
  {
    if (dirOnScreen != LEFT)
    {
      dir = RIGHT;
    }
  }
  else if (BDOS_USBkeyHeld(BTN_UP))
  {
    if (dirOnScreen != DOWN)
    {
      dir = UP;
    }
  }
  else if (BDOS_USBkeyHeld(BTN_DOWN))
  {
    if (dirOnScreen != UP)
    {
      dir = DOWN;
    }
  }

  dirOnScreen = dir; // update

  // remove last part of body
  if (!keepTail)
  {
    char emptyTile = 0;
    GFX_printWindowColored(&emptyTile, 1, GFX_WindowPosFromXY(snake[snakeLen-1].x, snake[snakeLen-1].y), 0);
  }

  // move all snake pieces back
  word i;
  for (i = snakeLen-2; i >= 0; i--)
  {
    snake[i+1].x = snake[i].x;
    snake[i+1].y = snake[i].y;
  }

  // create new head
  switch(dir)
  {
    case UP:
      snake[0].x = snake[1].x;
      snake[0].y = snake[1].y -1;
      break;
    case DOWN:
      snake[0].x = snake[1].x;
      snake[0].y = snake[1].y +1;
      break;
    case LEFT:
      snake[0].x = snake[1].x -1;
      snake[0].y = snake[1].y;
      break;
    case RIGHT:
      snake[0].x = snake[1].x +1;
      snake[0].y = snake[1].y;
      break;
  }
}

word checkGameOver()
{
  // collision with border
  if (snake[0].x == 0 || snake[0].x == BOARD_WIDTH-1 || snake[0].y == 0 || snake[0].y == BOARD_HEIGHT-1)
  {
    return 1;
  }

  // collision with self
  word i;
  for (i = 1; i<snakeLen; i++)
  {
    if (snake[0].x == snake[i].x && snake[0].y == snake[i].y)
    {
      return 1;
    }
  }

  return 0;
}

void doGameOver()
{
  GFX_printWindowColored("GAME OVER!", 10, GFX_WindowPosFromXY((BOARD_WIDTH>>1) - 5, (BOARD_HEIGHT>>1)), 0);
  gameOver = 1;
}

void gameUpdate()
{
  word keepTail = checkFoodCollision();
  updatePlayer(keepTail);
  drawScore();
  drawFood();
  drawPlayer();
  if (checkGameOver())
  {
    doGameOver();
  }
}

void init()
{
  // start with a snake of length 3
  snakeLen = 3;
  dir = RIGHT;
  snake[0].x = (BOARD_WIDTH>>2) -1;
  snake[0].y = BOARD_HEIGHT>>1;
  snake[1].x = snake[0].x -1;
  snake[1].y = snake[0].y;
  snake[2].x = snake[1].x -1;
  snake[2].y = snake[1].y;

  // start food at top right ish
  xFood = (BOARD_WIDTH>>1) + (BOARD_WIDTH>>2);
  yFood = (BOARD_HEIGHT>>1) - (BOARD_HEIGHT>>2);

  clearScreen();
  drawBorder();
  drawScore();
  drawFood();
  drawPlayer();
}

int main() 
{
  init();
  
  setTimer3(delayTime);

  // main loop
  while (1)
  {
    if (HID_FifoAvailable())
    {
      word c = HID_FifoRead();
      switch(c)
      {
        case 27: //escape
          // cleanup and exit
          clearScreen();
          BDOS_PrintcConsole('\n');
          return 'q';
          break;
        
        case 'a':
          if (dirOnScreen != RIGHT)
          {
            dir = LEFT;
          }
          break;
        case 'd':
          if (dirOnScreen != LEFT)
          {
            dir = RIGHT;
          }
          break;
        case 'w':
          if (dirOnScreen != DOWN)
          {
            dir = UP;
          }
          break;
        case 's':
          if (dirOnScreen != UP)
          {
            dir = DOWN;
          }
          break;
        
        case '=':
        case '+':
          // speed things up
          if (delayTime > MIN_DELAY + STEP_DELAY)
          {
            delayTime = delayTime - STEP_DELAY;
          }
          break;
      }
    }

    if (!gameOver)
    {
      if (timer3Value == 1)
      {
        gameUpdate();
        setTimer3(delayTime);
      }
    }

    rngRand(); //update rng

  }

  return 'q';
}

// timer1 interrupt handler
void int1()
{
   timer1Value = 1; // notify ending of timer1
}

void int2()
{
  int i = getIntID();
  if (i == INTID_TIMER3)
  {
    timer3Value = 1; // notify ending of timer3
  }
}

void int3()
{
}

void int4()
{
}