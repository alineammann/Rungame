/********* VARIABLES *********/

// We control which screen is active by settings / updating
// gameScr variable. We display the correct screen according
// to the value of this variable.

// gameplay settings
int gameScr = 0;
float gravity = .3;
float airfriction = 0.00002;
float friction = 0.1;
Timer timer;

// scoring
int score = 0;
color starColor = color(255,255,51);

// ball settings
float ballX, ballY;
float ballSpeedVert = 0;
float ballSpeedHorizon = 0;
float ballSize = 30;
color ballColor = color(255,99,71);

// racket settings
float racketWidth = 100;
float racketHeight = 10;
color racketColor = color(255,255,240);

//Height for coins & walls
int randHeight;

// wall settings
int wallWidth = 150;
int minGapHeight = 170;
int maxGapHeight = 360;
int wallSpeed = 5;
int wallInterval = 1000;
float lastAddTime = 0;
color wallColors = color(44, 62, 80);

// ArrayLists 
ArrayList<int[]> walls = new ArrayList<int[]>();
ArrayList<int[]> coins = new ArrayList<int[]>();
ArrayList<Integer> scores = new ArrayList<Integer>();

/********* SETUP BLOCK *********/

void setup() {
  //frameRate(60);
  size(800 , 600);
  // set the initial coordinates of the ball
  ballX=width/4;
  ballY=height/5;
  timer = new Timer(60);
  smooth();
}


/********* DRAW BLOCK *********/

void draw() {
  // Display the contents of the current screen
  if (gameScr == 0) { 
    initScreen();
  } else if (gameScr == 1) { 
    showGameScreen();
    timer.countDown();
  } else if (gameScr == 2) { 
    gameOverScreen();
  }
}


/********* INPUTS *********/

public void mousePressed() {
  // if we are on the initial screen when clicked, start the game 
  if (gameScr==0) { 
    startGame();
  }
  if (gameScr==2) {
    restart();
  }
}



/********* GAME STATE *********/

// This method sets the necessery variables to start the game  
void startGame() {
  gameScr=1;
}
void gameOver() {
  scores.add(score);
  gameScr=2;
}

void restart() {
  score = 0;
  ballX=width/4;
  ballY=height/5;
  lastAddTime = 0;
  walls.clear();
  coins.clear();
  gameScr = 1;
  timer.setTime(60);
}


/********* SCREEN CONTENTS *********/

void gameOverScreen() {
  background(44, 62, 80);
  textAlign(CENTER);
  fill(236, 240, 241);
  textSize(12);
  text("Your Score", width/2, height/2 - 120);
  textSize(130);
  text(score, width/2, height/2);
  textSize(15);
  text("Current Highscore:" + getHighScore(), width/2, height/2 + 60);
  textSize(15);
  text("Click to Restart", width/2, height-30);
}

void initScreen() {
  background(236, 240, 241);
  textAlign(CENTER);
  fill(52, 73, 94);
  textSize(70);
  text("Rungame", width/2, height/2);
  textSize(15); 
  text("Click to start", width/2, height-30);
}

void showGameScreen() {
  //PImage bg = loadImage("images/background.jpg");
  //background(bg);
  background(44, 62, 80);
  textSize(30);
  text(timer.getTime(),50,35);
  
  if(timer.getTime() >= 0.00) {
    applyGravity();
    watchRacketBounce();
    applyHorizontalSpeed();
    keepInScreen();
  
    adder();
    handler();
    drawRacket();
    drawBall();
    
    printScore();
  } else {
    gameOver();
  }
}


/********* DRAW METHODS *********/

void drawBall() {
  fill(ballColor);
  ellipse(ballX, ballY, ballSize, ballSize);
}

void drawRacket() {
  fill(255,255,240);
  rectMode(CENTER);
  rect(mouseX, mouseY, racketWidth, racketHeight, 5);
}


void drawer(int index) {
  //Load image from Folder
  //PImage wall = loadImage("images/wall.png");
  //PImage ball = loadImage("images/ball.png");
  
  // get gap wall and coin settings
  int[] wall = walls.get(index);
  int[] coin = coins.get(index);
  int gapWallX = wall[0];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall[3];
  int ballX = coin[0];
  int ballY = coin[3];
  // draw elements
  
  rectMode(CORNER);
  noStroke();
  strokeCap(ROUND);
  fill(255,255,240);
  rect(gapWallX, gapWallHeight, gapWallWidth, 30, 15);
  star(ballX+(wallWidth/2), ballY, 8, 25, 5, starColor);
  
  
  //Image replacement for wall and star
  //image(wall, gapWallX, gapWallHeight, gapWallWidth, height-gapWallHeight);
  //image(ball, ballX+(wallWidth/2), ballY, wallWidth/3);
}


/********* ADDING METHODS *********/


void adder() {
  if (millis()-lastAddTime > wallInterval) {
     randHeight = round(random(minGapHeight, maxGapHeight));
    // {gapWallX, gapWallY, gapWallWidth, gapWallHeight, scored}
    int[] randWall = {width, 0, wallWidth, randHeight, 0};
    
    walls.add(randWall);
    lastAddTime = millis();
    fillCoinArray(randWall[0], randWall[1], randWall[2], randWall[3], randWall[4]);
  }
}

void fillCoinArray(int first, int second, int third, int fourth, int fifth) {
    fourth -= 40;
    int[] coin = {first, second, third, fourth, fifth};
    coins.add(coin);
}


/********* HANDLER METHODS *********/


void handler() {
  for (int i = 0; i < walls.size(); i++) {
    wallRemover(i);
    coinRemover(i);
    
    wallMover(i);
    coinMover(i);
    
    drawer(i);
    
    watchWallCollision(i);
    watchCoinCollision(i);
  }
}


/********* MOVING METHODS *********/

void coinMover(int index) {
  int[] coin = coins.get(index);
  coin[0] -= wallSpeed;
}

void coinRemover(int index) {
  int[] coin = coins.get(index);
  if (coin[0]+coin[2] <= 0) {
    coins.remove(index);
  }
}

void wallMover(int index) {
  int[] wall = walls.get(index);
  wall[0] -= wallSpeed;
}

void wallRemover(int index) {
  int[] wall = walls.get(index);
  if (wall[0]+wall[2] <= 0) {
    walls.remove(index);
  }
}


/********* COLLISION METHODS *********/

void watchCoinCollision(int index) {
  int[] coin = coins.get(index);
  int starScored = coin[4];
  float halfBall = ballSize/2;
  if(starScored == 0 && inRange(coin[0] - halfBall+(wallWidth/2), coin[0]+wallWidth/3 + halfBall+(wallWidth/2), ballX)) {
    if (inRange(coin[3]-halfBall, coin[3]+(wallWidth/3)+halfBall, ballY+halfBall)) {
      increaseScore();
      starScored = 1;
      coin[4] = 1;
    }
  }
  
  if(starScored != 0) {
    removeStar(coin[0]+(wallWidth/2), coin[3], 8, 25, 5, color(44, 62, 80));
  }
  
}

void watchWallCollision(int index) {
  int[] wall = walls.get(index);
  // get gap wall settings 
  int gapWallX = wall[0];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall[3];
  int wallBottomWidth = gapWallWidth;
  int wallBottomHeight = height-gapWallHeight;
  
  
  if ((ballX+(ballSize/2) > gapWallX && (ballX-(ballSize/2) < gapWallX+(wallBottomWidth)))) {
    if (dist(ballX, ballY, ballX, height-wallBottomHeight)<=(ballSize/2)) {
        makeBounceBottom(height-wallBottomHeight);
    }
  }
  
}

boolean inRange(float minValue, float maxValue, float value) {
  if(value >= minValue && value <= maxValue) {
    return true;
  } else {
    return false;
  }
}

/********* GRAVITY RESPONDING METHODS *********/

void applyGravity() {
  ballSpeedVert += gravity;
  ballY += ballSpeedVert;
  ballSpeedVert -= (ballSpeedVert * airfriction);
}

void applyHorizontalSpeed() {
  ballX += ballSpeedHorizon;
  ballSpeedHorizon -= (ballSpeedHorizon * airfriction);
}

// ball falls and hits the floor (or other surface) 
void makeBounceBottom(float surface) {
  ballY = surface-(ballSize/2);
  ballSpeedVert*=-1;
  ballSpeedVert -= (ballSpeedVert * friction);
}

// ball rises and hits the ceiling (or other surface)
void makeBounceTop(float surface) {
  ballY = surface+(ballSize/2);
  ballSpeedVert*=-1;
  ballSpeedVert -= (ballSpeedVert * friction);
}

// ball hits object from left side
void makeBounceLeft(float surface) {
  ballX = surface+(ballSize/2);
  ballSpeedHorizon*=-1;
  ballSpeedHorizon -= (ballSpeedHorizon * friction);
}
// ball hits object from right side
void makeBounceRight(float surface) {
  ballX = surface-(ballSize/2);
  ballSpeedHorizon*=-1;
  ballSpeedHorizon -= (ballSpeedHorizon * friction);
}

// keep ball in the screen
void keepInScreen() {
  // ball hits floor
  if (ballY+(ballSize/2) > height) { 
    makeBounceBottom(height);
  }
  // ball hits ceiling
  if (ballY-(ballSize/2) < 0) {
    makeBounceTop(0);
  }
  // ball hits left of the screen
  if (ballX-(ballSize/2) < 0) {
    makeBounceLeft(0);
  }
  // ball hits right of the screen
  if (ballX+(ballSize/2) > width) {
    makeBounceRight(width);
  }
}

void watchRacketBounce() {
  float overhead = mouseY - pmouseY;
  
  if ((ballX+(ballSize/2) > mouseX-(racketWidth/2)) && (ballX+(ballSize/2) < mouseX+(racketWidth/2))) {
    if (dist(ballX, ballY, ballX, mouseY)<=(ballSize/2)+abs(overhead)) {
      makeBounceBottom(mouseY);
      ballSpeedHorizon = (ballX - mouseX)/10;
      // racket moving up
      if (overhead<0) {
        ballY+=(overhead/2);
        ballSpeedVert+=(overhead/2);
      }
    }
  }
}


/********* OTHER METHODS *********/

void increaseScore() {
  score++;
}

void printScore() {
  textAlign(CENTER);
  fill(color(255,255,240));
  textSize(30);
  text(score, width/2, 35);
}

void star(float x, float y, float radius1, float radius2, int npoints, color fillColor) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  beginShape();
  fill(fillColor);
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

void removeStar(float x, float y, float r, float r2, int p, color c) {
  star(x, y, r, r2, p, c);
}

int getHighScore() {
  int max = scores.get(0);
  for(int i = 0; i < scores.size(); i++) {
    int current = scores.get(i);
    if(current > max) {
      max = current;
    }
  }
  return max;
}
