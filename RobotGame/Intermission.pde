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

class Intermission implements State
{
  ArrayList<ComparablePair<Float, Class>> scoreBoard;
  int timeS=60, tickS = timeS;
  int time=240, tick = time;
  int timeE=60, tickE = timeE;


  boolean stateStart()
  {
    if (tickS == timeS)
    {
      scoreBoard = game.getScores();
    }
    if (tickS == 0)
    {
      return true;
    }
    push();
    {
      drawThis();
      reset();
      fill(0, map(tickS, 0, timeS, 0, 255));
      noStroke();
      rect(0, 0, width, height);
    }
    pop();
    tickS--;
    return false;
  }
  boolean stateStep()
  {
    if (tick == 0)
    {
      return true;
    }
    drawThis();
    tick--;
    return false;
  }
  boolean stateEnd()
  {
    if (tickE == 0)
    {
      return true;
    }
    push();
    {
      drawThis();
      reset();
      fill(0, 255-map(tickE, 0, timeE, 0, 255));
      noStroke();
      rect(0, 0, width, height);
    }
    pop();
    tickE--;
    return false;
  }

  void drawThis()
  {
    push();
    {
      gameBackground();
      int yp = 100;
      int f = 25;
      int place = 1;
      int w = width - 700;
      int h = height - 100;
      push();
      {
        translate(0, map(time-tick, 0, time, 0, max(50*scoreBoard.size()-h, 0)));
        for (ComparablePair<Float, Class> rc : scoreBoard)
        {
          fill(25-f, 150);
          rect(50, yp, w, 5);

          fill(0);
          textSize(30);

          textAlign(TOP, LEFT);
          text(str(place), 75, yp);

          textAlign(TOP, RIGHT);
          text(getRobotName(rc.two), 110, yp);

          textAlign(TOP, LEFT);
          text(str(rc.one), w-10, yp);

          yp+=50;
          place++;
        }
      }
      pop();
      translate(w,0);
    }
    pop();
  }
}