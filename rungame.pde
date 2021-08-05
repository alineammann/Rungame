/********* VARIABLES *********/

// We control which screen is active by settings / updating
// gameScr variable. We display the correct screen according
// to the value of this variable.
// 
// 0: Initial Screen
// 1: Game Screen
// 2: Game-over Screen 

int gameScr = 0;
Timer timer;
// gameplay settings
float gravity = .3;
float airfriction = 0.00001;
float friction = 0.1;

// scoring
int score = 0;

// ball settings
float ballX, ballY;
float ballSpeedVert = 0;
float ballSpeedHorizon = 0;
float ballSize = 30;
color ballColor = color(255, 215, 0);

// racket settings
color racketColor = color(0);
float racketWidth = 100;
float racketHeight = 10;

// wall settings
int wallSpeed = 5;
int wallInterval = 1000;
float lastAddTime = 0;
int minGapHeight = 170;
int maxGapHeight = 360;

int wallWidth = 150;
color wallColors = color(44, 62, 80);
color starColor = color(255,255,51);
color backgroundColor = color(236, 240, 241);
// This arraylist stores data of the gaps between the walls. Actuals walls are drawn accordingly.
// [gapWallX, gapWallY, gapWallWidth, gapWallHeight, scored]
ArrayList<int[]> walls = new ArrayList<int[]>();
ArrayList<int[]> coins = new ArrayList<int[]>();
ArrayList<int[]> coordinates = new ArrayList<int[]>();

/********* SETUP BLOCK *********/

void setup() {
  //frameRate(60);
  size(500, 500);
  // set the initial coordinates of the ball
  ballX=width/4;
  ballY=height/5;
  timer = new Timer(90);
  smooth();
}


/********* DRAW BLOCK *********/

void draw() {
  // Display the contents of the current screen
  if (gameScr == 0) { 
    initScreen();
  } else if (gameScr == 1) { 
    gameScr();
    timer.countDown();
  } else if (gameScr == 2) { 
    gameOverScreen();
  }
}


/********* SCREEN CONTENTS *********/

void initScreen() {
  background(backgroundColor);
  textAlign(CENTER);
  fill(52, 73, 94);
  textSize(70);
  text("Flappy Pong", width/2, height/2);
  textSize(15); 
  text("Click to start", width/2, height-30);
}
void gameScr() {
  //PImage bg = loadImage("images/background.jpg");
  //background(bg);
  background(153, 217, 234);
  text(timer.getTime(),50,35);
  if(timer.getTime() >= 0.00) {
    watchRacketBounce();
  
    applyGravity();
    applyHorizontalSpeed();
    keepInScreen();
  
    wallAdder();
    wallHandler();
    coinAdder();
    coinHandler();
    drawRacket();
    drawBall();
    printScore();
  } else {
    gameOver();
  }
}

void gameOverScreen() {
  background(44, 62, 80);
  textAlign(CENTER);
  fill(236, 240, 241);
  textSize(12);
  text("Your Score", width/2, height/2 - 120);
  textSize(130);
  text(score, width/2, height/2);
  textSize(15);
  text("Click to Restart", width/2, height-30);
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
  gameScr=2;
}

void restart() {
  score = 0;
  ballX=width/4;
  ballY=height/5;
  lastAddTime = 0;
  walls.clear();
  coins.clear();
  coordinates.clear();
  gameScr = 1;
  timer.setTime(90);
}


/********* DRAW METHODS *********/

void drawBall() {
  fill(ballColor);
  ellipse(ballX, ballY, ballSize, ballSize);
}

void drawRacket() {
  fill(racketColor);
  rectMode(CENTER);
  rect(mouseX, mouseY, racketWidth, racketHeight, 5);
}

void coinDrawer(int index) {
  int[] wall = walls.get(index);
  
  // x, y, size
  int[] position = { wall[0] + wallWidth/2, wall[3] - 40,  wallWidth/3};
  
  //ellipse(wall[0] + wallWidth/2 , wall[3] - 40, wallWidth / 3, wallWidth / 3);
  if(!(position[0] > width) || !(position[1] > height) || !(position[0] < 0)) {
    star(position[0], position[1], 8, 25, 5, starColor); 
    coordinates.add(position);
    //println(position[0] + "," + position[1] + "    " + (int)ballX + "," + (int)ballY);
  }
}
 //<>//

void wallDrawer(int index) {
  PImage img = loadImage("images/wall.png");
  int[] wall = walls.get(index);
  // get gap wall settings 
  int gapWallX = wall[0];
  int gapWallY = wall[1];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall[3];
  // draw actual walls
  if(!(gapWallX > width) || !(gapWallX < 0)) {
  //image(img, gapWallX, gapWallY+gapWallHeight, gapWallWidth, height-(gapWallY+gapWallHeight));
  rectMode(CORNER);
    noStroke();
    strokeCap(ROUND);
    fill(100, 70, 36);
    rect(gapWallX, gapWallY+gapWallHeight, gapWallWidth, 30, 0);
    coinAdder();
  }
}


/********* ADDING METHODS *********/

void coinAdder() {
    //int[] wall = walls.get(index);
    int [] coin = {width, 0, wallWidth, 0, 0};
    coins.add(coin); 
}

void wallAdder() {
  if (millis()-lastAddTime > wallInterval) {
    int randHeight = round(random(minGapHeight, maxGapHeight));
    // {gapWallX, gapWallY, gapWallWidth, gapWallHeight, scored}
    int[] randWall = {width, 0, wallWidth, randHeight, 0}; 
    walls.add(randWall);
    lastAddTime = millis();
  }
}

/********* HANDLER METHODS *********/

void coinHandler() {
  
  for (int i = 0; i < walls.size(); i++) {
    coinRemover(i);
    coinMover(i);
    coinDrawer(i);
    //watchCoinCollision(i);
    
  }
}

void wallHandler() {
  for (int i = 0; i < walls.size(); i++) {
    wallRemover(i);
    wallMover(i);
    wallDrawer(i);
    watchWallCollision(i);
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

/*void watchCoinCollision(int index) {
  int[] position = coordinates.get(index);
  float x1 = ballX + ballSize;
  float y1 = ballY + ballSize;
  float x2 = ballX;
  float y2 = ballY;
  float x3 = position[0];
  float y3 = position[1];
  float x4 = position[0] + position[2];
  float y4 = position[1] + position[2];
  
  // calculate the distance to intersection point
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

  // if uA and uB are between 0-1, lines are colliding
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
    star(position[0], position[1], 8, 25, 5, backgroundColor); 
    score();
  }
}*/

void watchWallCollision(int index) {
  int[] wall = walls.get(index);
  boolean alreadyChecked = false;
  // get gap wall settings 
  int gapWallX = wall[0];
  int gapWallY = wall[1];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall[3];
  //int wallScored = wall[4];
  int wallBottomX = gapWallX;
  int wallBottomY = gapWallY+gapWallHeight;
  int wallBottomWidth = gapWallWidth;
  int wallBottomHeight = height-gapWallHeight;
  
  if((inRange(wallBottomX, wallBottomX+wallWidth, (int)ballX)) && !alreadyChecked) {
    //println("It worked");   
    if (dist(0, ballY+ballSize, 0, wallBottomY) >= 0 || !(dist(0, ballY, 0, wallBottomY) >= wallBottomY)) {
       //println("It worked");
       makeBounceBottom(wallBottomX);
       alreadyChecked = true;
      }
    }
    
 
}

boolean inRange(int minValue, int maxValue, int value) {
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
  if ((ballX+(ballSize/2) > mouseX-(racketWidth/2)) && (ballX-(ballSize/2) < mouseX+(racketWidth/2))) {
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

void score() {
  score++;
}

void printScore() {
  textAlign(CENTER);
  fill(0);
  textSize(30); 
  text(score, height/2, 50);
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


/*************** ADDED METHODS ***************/

// star()
// coin*()
// restart()
// watchCoinCollision()
// coordinates<> / coins<>
// wallAdder()
