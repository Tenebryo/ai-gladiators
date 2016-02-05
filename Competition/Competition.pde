/*
   Copyright 2016 Sam Blazes

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

import java.util.*;
import java.lang.reflect.*;
import java.util.concurrent.*;

final Game game = new Game();
final PApplet mainPApplet = this;
Match m;

final boolean debug = true;
void debug(Object... params)
{
  if (debug)
    println(params);
}

void setup()
{
  frameRate(60);
  size(1600, 900);
  game.setup(new ArrayList(Arrays.asList(this.getClass().getDeclaredClasses())));
  //m = new Match(new BasicAIRobot().getClass(), new BasicAIRobot().getClass(), "Test Match 1", 0);
}

int stat = 0;

void draw()
{
  /*
  int t=0;
  switch(stat)
  {
  case 0:
    t = (m.stateStart()?stat++:stat);
    break;
  case 1:
    t = (m.stateStep()?stat++:stat);
    break;
  case 2:
    t = (m.stateEnd()?stat++:stat);
    break;
  }//*/
  //m.stateStep();
  game.draw();
}

void keyPressed()
{
  for(HumanControlledRobot p : instances)
  {
    p.keyPressed(key);
  }
}

void hexagon(float x, float y, float r)
{
  pushMatrix();
  translate(x, y);
  rotate(PI/6);
  beginShape();
  vertex(r, 0);
  vertex(r/2, -sqrt(3)/2*r);
  vertex(-r/2, -sqrt(3)/2*r);
  vertex(-r, 0);
  vertex(-r/2, sqrt(3)/2*r);
  vertex(r/2, sqrt(3)/2*r);
  endShape(CLOSE);
  popMatrix();
}

int getIntDirectionFromString(String direction)
{
  direction = direction.toUpperCase();
  switch(direction)
  {
  case "EAST": 
  case "E":
    return 0;
  case "NORTH NORTH EAST": 
  case "NORTH EAST": 
  case "NNE": 
  case "NE":
    return 1;
  case "NORTH NORTH WEST": 
  case "NORTH WEST": 
  case "NNW": 
  case "NW":
    return 2;
  case "WEST": 
  case "W":
    return 3;
  case "SOUTH SOUTH WEST": 
  case "SOUTH WEST": 
  case "SSW": 
  case "SW":
    return 4;
  case "SOUTH SOUTH EAST": 
  case "SOUTH EAST": 
  case "SSE": 
  case "SE":
    return 5;
  default:
    return -1;
  }
}

int turnRight(int h) 
{
  return (h+1)%6;
}

int turnLeft(int h) 
{
  return (h+5)%6;
}

Pair<Integer, Integer> getDirectionIncrement(String direction)
{
  return getIncrementedPosition(0, 0, getIntDirectionFromString(direction));
}

Pair<Integer, Integer> getIncrementedPosition(int q, int r, String direction)
{
  return getIncrementedPosition(q, r, getIntDirectionFromString(direction));
}

Pair<Integer, Integer> getDirectionIncrement(int direction)
{
  return getIncrementedPosition(0, 0, direction);
}

Pair<Integer, Integer> getIncrementedPosition(int q, int r, int direction)
{
  switch(direction)
  {
  case 0: 
    q++; 
    break;
  case 1:  
    r++; 
    break;
  case 2: 
    q--;
    r++; 
    break;
  case 3: 
    q--; 
    break;
  case 4: 
    r--; 
    break;
  case 5: 
    q++; 
    r--; 
    break;
  }

  return new Pair<Integer, Integer>(q, r);
}

ArrayList<Pair<Integer, Integer>> getAdjacentHexes(int q, int r)
{
  ArrayList<Pair<Integer, Integer>> ret = new ArrayList<Pair<Integer, Integer>>();
  
  for(int i = 0; i < 6; i++)
  {
    ret.add(getIncrementedPosition(q,r,i));
  }
  return ret;
}

void gameBackground()
{
  pushMatrix();
  {
    noStroke();
    translate(width/2, height/2);
    rotate(PI/6);
    for (int i = 1000; i >= 0; i-=100)
    {
      fill(255, 150, 0);
      hexagon(0, 0, 150+i);
      fill(255, 255, 0);
      hexagon(0, 0, 100+i);
    }
  }
  popMatrix();
}

void push()
{
  pushMatrix();
  pushStyle();
}

void pop()
{
  popStyle();
  popMatrix();
}

void reset()
{
  resetMatrix();
}

String pathJoin(String path1, String path2)
{
    File file1 = new File(path1);
    File file2 = new File(file1, path2);
    return file2.getPath();
}

String getRobotName(Class t)
{
  return match(t.getName(), "\\$(.*)")[1];
}

void drawRobotName(Class r, int x, int y, int w, int h)
{
  String name = getRobotName(r);
  
  PGraphics pg = createGraphics(w,h);
  
  pg.beginDraw();
  
  pg.textSize(h);
  pg.fill(0);
  pg.textAlign(LEFT,TOP);
  
  pg.text(name,0,0);
  
  pg.endDraw();
  
  image(pg,x,y);
}

Robot getRobotInstance(Class r)
{
    try
    {
      return new Robot().getClass().cast(r.getDeclaredConstructor(new RobotGame().getClass()).newInstance(mainPApplet));
    }
    catch(Throwable e)
    {
      return null;
    }
}

void drawRobotIntro(Class r, int x, int y, int w, int h, color c)
{
  push();
  {
    translate(x,y);
    
    noStroke();
    fill(c);
    
    rect(0,0,w,h);
    
    drawRobotName(r, 5, 5, w-10, 40);
    
    translate(0,50);
    
    image(game.getRobotAvatar(r), 5, 5, w-10, h-60);
    
  }
  pop();
}

void drawRobotIntroWithStats(Class r, int x, int y, int w, int h, color c)
{
  drawRobotIntro(r, x, y, w, h-100, c);
  
  Pair<Integer, Pair<Integer, Integer>> s = game.getRobotScore(r);
  push();
  {
    translate(0,h-100);
    noStroke();
    strokeWeight(2);
    
    fill(150);
    rect(0, 0, w, 100);
    
    fill(0);
    
    textSize(40);
    textAlign(CENTER, BOTTOM);
    text("W",w/4,45);
    text("D",w/2,45);
    text("L",w*3/4,45);
    
    textSize(30);
    textAlign(CENTER, TOP);
    text(str(s.one),w/4,55);
    text(str(s.two.one),w/2,55);
    text(str(s.two.two),w*3/4,55);
  }
  pop();
}