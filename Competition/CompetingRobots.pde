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
 
/*

Some sample AI controllers have been provided to illustrate how those competing could implement theirs.

Some rules apply, such as only standard Java libraries are allowed (excluding Reflect) and must not use processing draw functions. Submissions must not use global variables or variables used to manage the game.

When running a competition, place all submissions in this file for convenience
*/

//This robot illustrates the most basic stucture of a robot.
public class SimpleRobot extends Robot
{
  public SimpleRobot() {
    super();
  }

  public void action(Action move)
  {
    move.fire();
  }
}

//this robot illustrates how robot behavior can change from turn to turn, even randomly;
public class RandomRobot extends Robot
{
  int tick = -1;
  ArrayList<Integer> moves = new ArrayList();
  public RandomRobot() {
    super();
  }

  public void action(Action move)
  {
    int r = round(random(-0.5, 4.5));
    switch(r)
    {
    case 0:
      move.move(Forward);
      break;
    case 1:
      move.move(Reverse);
      break;
    case 2:
      move.turn(Right);
      break;
    case 3:
      move.turn(Left);
      break;
    case 4:
      move.fire(true);
      break;
    }
    tick = (tick+1)%2;
  }
}

//This robot illustrates a basic - but more intelligent - strategy, and introduces the methods of sensing and responding to surroundings available to competitors.
public class BasicAIRobot extends Robot
{
  public BasicAIRobot() {
    super();

    //setImage("http://i.imgur.com/343yJj6.jpg");
  }

  boolean nextMove = true;


  public void action(Action move)
  {
    if (nextMove)
    {
      move.turnTurretLeft();
      nextMove = false;
    }
    String[] los = getLineOfSight();
    if (los.length>0)
    {
      if (los[los.length-1]=="Enemy")
      {
        move.fire();
        move.cancelMove();
        return;
      }
    }
    String[] s = getNearbyObjects();
    if (s[turnRight(getBaseHeading())]=="Nothing")
    {
      move.turnRight();
    } else if (s[getBaseHeading()]=="Nothing")
    {
      move.moveForward();
    } else 
    {
      move.turnLeft();
    }
  }
}


//this is a robot controller for testing that is controlled by the
ArrayList<HumanControlledRobot> instances = new ArrayList<HumanControlledRobot>();
public class HumanControlledRobot extends Robot {
  public HumanControlledRobot() {
    super();
    instances.add(this);
  }

  public void Finalize()
  {
    instances.remove(this);
  }

  boolean fire = false;
  int turn = 0;
  int tturn = 0;
  int move = 0;

  public void action(Action t) {
    switch (turn)
    {
    case -1:
      t.turnRight();
      break;
    case 1:
      t.turnLeft();
      break;
    }
    turn = 0;

    switch(tturn)
    {
    case -1:
      t.turnTurretRight();
      break;
    case 1:
      t.turnTurretLeft();
      break;
    }
    tturn = 0;

    switch(move)
    {
    case 1:
      t.moveForward();
      break;
    case -1:
      t.moveBackward();
      break;
    }
    move = 0;

    if (fire) {
      t.fire();
    }
    fire = false;
  }

  void keyPressed(char k) {
    switch(k)
    {
    case 'w': 
    case 'W':
      move = 1;
      break;
    case 'a': 
    case 'A':
      turn = 1;
      break;
    case 's': 
    case 'S':
      move = -1;
      break;
    case 'd': 
    case 'D':
      turn = -1;
      break;
    case 'q': 
    case 'Q':
      tturn = 1;
      break;
    case 'e': 
    case 'E':
      tturn = -1;
      break;
    case ' ':
      fire = true;
      break;
    }
  }
}