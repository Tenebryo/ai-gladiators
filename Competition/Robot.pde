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

public class Robot
{
  private String name = "";
  private int bh, th, hp = 100, q, r, pl, lq, lr;
  private Match match = null;
  private int bturn = 0, tturn = 0, move = 0;

  public Robot()
  {
    name = match(this.getClass().getName(), "\\$(.*)")[1];
  }

  public void setMatch(Match m)
  {
    if (match != null)
    {
      return;
    }
    match = m;
    Pair<Integer, Integer> p = match.getStartPosition(this);
    int player = match.getPlayerNumber(this);
    lq = q = int(p.one);
    lr = r = int(p.two);
    pl=player;
    if (q > 0) {
      bh = 3;
    }
    if (q < 0) {
      bh = 0;
    }
  }

  public Robot(String _name)
  {
    name = _name;
  }

  public final String getName()
  {
    return name;
  }

  public final void setAvatar(String name)
  {
    game.setRobotAvatar(this.getClass(), name);
  }

  public final void takeDamage(int dmg)
  {
    hp-=abs(dmg);
  }

  public final int getP()
  {
    return -q-r;
  }

  public final int getQ()
  {
    return q;
  }

  public final int getR()
  {
    return r;
  }

  public final String[] getLineOfSight()
  {
    return match.getLineOfSight((Robot)this);
  }

  public final String[] getNearbyObjects()
  {
    return match.getNearbyObjects((Robot)this);
  }

  public final int getBaseHeading()
  {
    return bh;
  }

  public final int getTurretHeading()
  {
    return (th+bh)%6;
  }

  public final void draw(float interp)
  {
    pushMatrix();
    {
      stroke(0);
      fill(255, 100, 100);
      if (pl == 1)
      {
        fill(100, 100, 255);
      }

      rotate(bh*PI/3.0);
      translate(move*(-40+40*interp), 0);

      rotate(bturn*(1-interp)*PI/3.0);

      beginShape();
      {
        vertex(-10, -10);
        vertex(8, -6);
        vertex(12, 0);
        vertex(8, 6);
        vertex(-10, 10);
      }
      endShape(CLOSE);

      fill(255, 0, 0);
      if (pl == 1)
      {
        fill(0, 0, 255);
      }

      rotate(th*PI/3.0);
      rotate(tturn*(1-interp)*PI/3.0);

      beginShape();
      {
        vertex(14, -2);
        vertex(14, 2);
        vertex(6, 2);
        vertex(-6, 8);
        vertex(-6, -8);
        vertex(6, -2);
      }
      endShape(CLOSE);
    }
    popMatrix();
  }

  public final void start()
  {
    initialize();
  }

  public synchronized final Action step()
  {
    Action a = new Action();
    move = 0;
    bturn = 0;
    tturn = 0;

    action(a);

    if (a.getTurretAction() == Left) {
      th = (th+5)%6; 
      tturn = 1;
    }
    if (a.getTurretAction() == Right) {
      th = (th+1)%6; 
      tturn = -1;
    }
    if (a.getBaseAction() == Left) {
      bh = (bh+5)%6; 
      bturn = 1;
    }
    if (a.getBaseAction() == Right) {
      bh = (bh+1)%6; 
      bturn = -1;
    }

    if (a.getMoveAction() == Forward || a.getMoveAction() == Reverse)
    {
      int t = -1;
      if (a.getMoveAction() == Forward) {
        t = 1;
      }
      int nq = q, nr = r;
      switch(bh)
      {
      case 0: 
        nq+=t; 
        break;
      case 1:  
        nr+=t; 
        break;
      case 2: 
        nq-=t;
        nr+=t; 
        break;
      case 3: 
        nq-=t; 
        break;
      case 4: 
        nr-=t; 
        break;
      case 5: 
        nq+=t; 
        nr-=t; 
        break;
      }
      if (!match.testCollision(nq, nr))
      {
        q = nq;
        r = nr;
        move = (a.getMoveAction()==Forward?1:-1);
      }
    }
    return a;
  }

  public final void end()
  {
    finish();
  }

  public final boolean isDead()
  {
    return hp <= 0;
  }

  public final int getHp()
  {
    return hp;
  }

  public void initialize()
  {
  }

  public void action(Action _)
  {
  }

  public void finish()
  {
  }
}