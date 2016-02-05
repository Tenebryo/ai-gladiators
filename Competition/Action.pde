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

public final class Direction
{
}

final Direction Left = new Direction();
final Direction Right = new Direction();
final Direction Forward = new Direction();
final Direction Reverse = new Direction();
final Direction None = new Direction();

final class Action
{
  private Direction 
    a_turnTurret = None, 
    a_turnBase = None, 
    a_move = None;
  private boolean a_fire = false;

  private String directionToString(Direction d)
  {
    if (d == Right)
    {
      return "RIGHT";
    } else if (d == Left)
    {
      return "LEFT";
    } else if (d == Forward)
    {
      return "FORWARD";
    } else if (d == Reverse)
    {
      return "REVERSE";
    } else
    {
      return "NONE";
    }
  }

  public String toString()
  {
    return "{'turnTurret':'" +directionToString(a_turnTurret) +"','turnBase':'"+directionToString(a_turnBase)+"','move':'"+directionToString(a_move)+"','fire':'"+str(a_fire)+"'}";
  }
  
  public JSONObject toJSON()
  {
    return parseJSONObject(this.toString());
  }

  public Direction getTurretAction() 
  {
    return a_turnTurret;
  }
  public Direction getBaseAction() 
  {
    return a_turnBase;
  }
  public Direction getMoveAction() 
  {
    return a_move;
  }
  public boolean getFireAction() 
  {
    return a_fire;
  }

  public void turn(Direction dir)
  {
    if (dir == Left || dir == Right)
    {
      a_turnBase = dir;
      a_move = None;
    }
  }

  public void turnRight()
  {
    turn(Right);
  }

  public void turnLeft()
  {
    turn(Left);
  }

  public void turnTurret(Direction dir)
  {
    if (dir == Left || dir == Right)
    {
      a_turnTurret = dir;
    }
  }

  public void turnTurretRight()
  {
    turnTurret(Right);
  }
  public void turnTurretLeft()
  {
    turnTurret(Left);
  }
  public void cancelTurretTurn()
  {
    turnTurret(None);
  }

  public void turnBase(Direction dir)
  {
    if (dir == Left)
    {
      a_turnBase = dir;
      a_turnTurret = Right;
      a_move = None;
    } else if (dir == Right)
    {
      a_turnBase = dir;
      a_turnTurret = Left;
      a_move = None;
    }
  }

  public void turnBaseRight()
  {
    turnBase(Right);
  }
  public void turnBaseLeft()
  {
    turnBase(Left);
  }
  public void cancelBaseTurn()
  {
    turnBase(None);
  }

  public void cancelFire()
  {
    fire(false);
  }

  public void fire()
  {
    fire(true);
  }

  public void fire(boolean _fire)
  {
    a_fire = _fire;
  }

  public void move(Direction dir)
  {
    if (dir == Forward || dir == Reverse)
    {
      a_move = dir;
      a_turnBase = None;
    }
  }

  public void moveForward()
  {
    move(Forward);
  }
  public void moveBackward()
  {
    move(Reverse);
  }
  public void cancelMove()
  {
    move(None);
  }

  public void reset()
  {
    a_turnTurret = None;
    a_turnBase = None;
    a_move = None;
    a_fire = false;
  }
}