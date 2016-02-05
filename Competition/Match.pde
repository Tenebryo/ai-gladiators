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

int nextMatchId = 0;

final class Match implements State
{
  public final int UNPLAYED = 1;
  public final int R1WIN = 1337;
  public final int R2WIN = -1337;
  public final int DRAW = 0;

  public final int turnLimit = 1000;


  int step, result = UNPLAYED, validator, damage_min = 50, damage_max=51, remainingTurns = turnLimit, tick = 0, tick_2 = 0, 
    r1FireCooldown = 0, 
    r2FireCooldown = 0;
  boolean matchOver = false;
  String id, title;
  final int gridSize = 10;

  Pair<Integer, Integer> lp1 = new Pair<Integer, Integer>(0, 0), lp2 = new Pair<Integer, Integer>(0, 0);

  Wrapper<Boolean> r1go = new Wrapper<Boolean>(false);
  Wrapper<Boolean> r2go = new Wrapper<Boolean>(false);
  final Wrapper<Action> a1 = new Wrapper<Action>(null), a2 = new Wrapper<Action>(null);

  Robot r1, r2;
  Class c1, c2;

  ArrayList<Action> m1 = new ArrayList();
  ArrayList<Action> m2 = new ArrayList();
  ArrayList<Projectile> projectiles = new ArrayList();
  ArrayList<Pair<Integer, Integer>> obstacles = new ArrayList();

  final SignalableThread<Boolean> _1 = new SignalableThread<Boolean>() {

    public void signal(Boolean v) {
      signalVal=v;
      a1.value = new Action();
    }

    public void run() {
      signalVal = false;

      while (true)
      {
        while (!signalVal) {
          try {
            Thread.sleep(5);
            Thread.yield();
          }
          catch (Exception e) {
            return;
          }
        }
        try {
          a1.value = r1.step();
        } 
        catch(Throwable e) {
        }
        signalVal = false;
        Thread.yield();
      }
    }
  };
  final SignalableThread<Boolean> _2 = new SignalableThread<Boolean>() {

    public void signal(Boolean v) {
      signalVal=v;
      a2.value = new Action();
    }

    public void run() {
      signalVal = false;

      while (true)
      {
        while (!signalVal) {
          try {
            Thread.sleep(5);
            Thread.yield();
          }
          catch (Exception e) {
            return;
          }
        }
        try {
          a2.value = r2.step();
        } 
        catch(Throwable e) {
        }
        signalVal = false;
        Thread.yield();
      }
    }
  };

  public Match(Class _c1, Class _c2, String _title, int _validator)
  {
    c1=_c1;
    c2=_c2;
    title=_title;
    id = str(nextMatchId++);
    validator=_validator;
    _1.start();
    _2.start();

    for (int i = 0; i < 12; i++)
    {
      while (true) {
        int q = 0, r = 0;
        while (testCollision(q, r) || (abs(q) == gridSize && r == 0)) {
          q = int(random(-gridSize-1, gridSize+1));
          r = int(random(-gridSize-1, gridSize+1));
        }

        //println(q, r);
        Pair<Integer, Integer> t1 = new Pair<Integer, Integer>(q, r), t2 = new Pair<Integer, Integer>(-q, -r);
        obstacles.add(t1);
        obstacles.add(t2);

        if (!pathExists()) {
          obstacles.remove(t1);
          obstacles.remove(t2);
        } else {
          println(q, r);
          break;
        }
      }
    }
  }

  public Match(Class _c1, Class _c2, String _title, ArrayList<Pair<Integer, Integer>> _obstacles, int _validator)
  {
    c1=_c1;
    c2=_c2;
    title=_title;
    id = str(nextMatchId++);
    validator=_validator;
    obstacles = _obstacles;
    _1.start();
    _2.start();
  }

  public final JSONObject toJSON()
  {
    String r1n = "", r2n = "";
    r1n = c1.getName();
    r2n = c2.getName();
    String tmp = obstacles.get(0).toString();
    boolean t = true;
    for (Pair<Integer, Integer> p : obstacles)
    {
      if (t) {
        t=false;
        continue;
      }
      tmp += "," + p.toString();
    }
    JSONObject obj = parseJSONObject("{robot1:\"" + r1n + "\",robot2:\"" + r2n + "\",outcome:" + str(UNPLAYED) + ",title:\""+title+"\",obstacles:[" + tmp + "]}");
    JSONArray arr1 = new JSONArray();
    int i = 0;
    for (Action a : m1)
    {
      arr1.setJSONObject(i, a.toJSON());
      i++;
    }
    i=0;
    JSONArray arr2 = new JSONArray();
    for (Action a : m1)
    {
      arr2.setJSONObject(i, a.toJSON());
      i++;
    }
    obj.setJSONArray("robot1Actions", arr1);
    obj.setJSONArray("robot2Actions", arr2);
    return obj;
  }

  public final boolean isValid(int v)
  {
    return validator==v;
  }

  public boolean hasRobot(Class c)
  {
    return c.equals(c1)||c.equals(c2);
  }

  public boolean testCollision(int q, int r)
  {
    String t = objectCollided(q, r, null);
    return !t.equals("Projectile") && !t.equals("Nothing");
  }

  private long integerPairToLong(Pair<Integer, Integer> t)
  {
    return ((long)t.one)*(1<<32) + ((long)t.two);
  }

  public boolean pathExists()
  {
    HashMap<Long, Boolean> positions = new HashMap<Long, Boolean>();
    ArrayList<Pair<Integer, Integer>> qu = new ArrayList<Pair<Integer, Integer>>();

    qu.add(new Pair(gridSize, 0));

    while (qu.size()>0)
    {
      println(qu);
      Pair<Integer, Integer> p = qu.get(0);
      int q = p.one;
      int r = p.two;
      qu.remove(0);

      for (Pair<Integer, Integer> pos : getAdjacentHexes(q, r))
      {
        if (pos.one == -gridSize && pos.two == 0)
        {
          return true;
        }
        if (!positions.containsKey(integerPairToLong(pos))) {
          if (objectCollided(pos.one, pos.two, null).equals("Nothing")) {
            qu.add(pos);
            positions.put(integerPairToLong(pos), true);
          }
        }
      }
    }

    return false;
  }

  public String objectCollided(int q, int r, Robot rb)
  {
    if (r1 != null)
    {
      if (q == r1.getQ() && r == r1.getR())
      {
        return r1==rb?"Self":"Enemy";
      }
    }
    if (r2 != null)
    {
      if (q == r2.getQ() && r == r2.getR())
      {
        return r2==rb?"Self":"Enemy";
      }
    }
    boolean test = false;
    for (Pair<Integer, Integer> o : obstacles)
    {
      if (q == o.one && r == o.two)
      {
        return "Wall";
      }
    }
    if (test || (abs(q) > gridSize || abs(r) > gridSize || abs(q+r) > gridSize))
    {
      return "Wall";
    }

    for (Projectile p : projectiles)
    {
      if (q == p.q && r == p.r)
      {
        return "Projectile";
      }
    }
    return "Nothing";
  }

  public Pair<Integer, Integer> getStartPosition(Robot r)
  {
    if (r == r1) {
      return new Pair<Integer, Integer>(-gridSize, 0);
    } else {
      return new Pair<Integer, Integer>(gridSize, 0);
    }
  }

  public String[] getLineOfSight(Robot r)
  {
    if (r!= r1 && r != r2)
    {
      return new String[]{};
    }
    ArrayList<String> lineOfSight = new ArrayList<String>();

    Pair<Integer, Integer> coords = new Pair<Integer, Integer>(r.getQ(), r.getR());
    while (true)
    {
      Pair<Integer, Integer> t = getIncrementedPosition(coords.one, coords.two, r.getTurretHeading());
      String obj = objectCollided(t.one, t.two, r);
      coords = t;
      lineOfSight.add(obj);
      if (!obj.equals("Nothing") && !obj.equals("Projectile"))
      {
        break;
      }
    }

    return lineOfSight.toArray(new String[]{});
  }

  public String[] getNearbyObjects(Robot rb)
  {
    String[] ret = new String[6];
    int q = rb.getQ(), r = rb.getR();
    for (int i = 0; i < 6; i++)
    {
      Pair<Integer, Integer> t = getIncrementedPosition(q, r, i);
      ret[i] = objectCollided(t.one, t.two, rb);
    }
    return ret;
  }

  public int getPlayerNumber(Robot r)
  {
    return r==r1?1:2;
  }

  int t_startTimer = 300;
  public boolean stateStart()
  {
    if (t_startTimer == 0)
    {
      return true;
    } else if (t_startTimer < 60)
    {
      matchIntro();
      t_startTimer--;
      fill(0, 255-map(t_startTimer, 0, 60, 0, 255));
      noStroke();
      rect(0, 0, width, height);
      return false;
    } else if (t_startTimer != 300)
    {
      matchIntro();
      t_startTimer--;
      return false;
    }
    println(title, "Starting!");
    t_startTimer--;
    //instantiate 
    boolean f1=false, f2=false;
    try
    {
      r1=new Robot().getClass().cast(c1.getDeclaredConstructor(new RobotGame().getClass()).newInstance(mainPApplet));
      r1.setMatch(this);
    }
    catch(Throwable e)
    {
      f1=true;
      println("Robot 1 failed to initialize!");
    }
    try
    {
      r2=new Robot().getClass().cast(c2.getDeclaredConstructor(new RobotGame().getClass()).newInstance(mainPApplet));
      r2.setMatch(this);
    }
    catch(Throwable e)
    {
      f2=true;
      println("Robot 2 failed to initialize!");
    }

    if (f1&&f2)
    {
      result = DRAW; 
      matchOver = true;
    } else if (f1)
    {
      result = R2WIN; 
      matchOver = true;
    } else if (f2)
    {
      result = R1WIN; 
      matchOver = true;
    }

    return false;
  }

  int t_endTimer = 300;
  public boolean stateEnd()
  {
    if (t_endTimer==300)
    {
      _1.interrupt();
      _2.interrupt();
      println(title, "Over! Result: " + ((result == R1WIN)?r1.getName() + " Wins!":((result == R2WIN)?r2.getName() + " Wins!":"DRAW")));
      game.logMatchOutcome(this);
    }
    matchOutro();
    t_endTimer--;
    return t_endTimer == 0;
  }

  public PVector getHexCoord(int q, int r)
  {
    float mult = 2;
    PVector b1 = PVector.mult(PVector.fromAngle(0), 20);
    PVector b2 = PVector.mult(PVector.fromAngle(PI/3), 20);
    return PVector.add(PVector.mult(b1, mult*q), PVector.mult(b2, mult*r));
  }

  public void draw(float interp)
  {
    pushMatrix();
    {
      gameBackground();

      noStroke();
      fill(255);
      hexagon(width/2, height/2, 500);

      //display remaining turns
      fill(0);
      stroke(0);
      textSize(40);
      textAlign(CENTER, BOTTOM);
      text(str(remainingTurns), width/2, 50);
      textSize(30);
      textAlign(CENTER, TOP);
      text("Turns Remaining!", width/2, 50);

      translate(width/2, height/2);
      //scale(2);

      noStroke();
      fill(150, 100);

      //display grid
      for (int i = -gridSize; i <= gridSize; i++)
      {
        for (int j = -gridSize; j <= gridSize; j++)
        {
          if (abs(i+j) <= gridSize)
          {
            PVector t = getHexCoord(i, j);
            hexagon(t.x, t.y, 21);
          }
        }
      }

      //display projectiles
      for (Projectile p : projectiles)
      {
        pushMatrix();
        {
          PVector pos = getHexCoord(p.q, p.r);
          translate(pos.x, pos.y);
          p.draw(interp);
        }
        popMatrix();
      }

      //display walls
      for (Pair<Integer, Integer> o : obstacles)
      {
        PVector t = getHexCoord(o.one, o.two);
        fill(0);
        stroke(0);
        strokeWeight(7);
        hexagon(t.x, t.y, 22);
        strokeWeight(1);
      }

      //draw robot 1
      pushMatrix();
      {
        PVector p = getHexCoord(r1.getQ(), r1.getR());
        translate(p.x, p.y);
        r1.draw((interp+tick%2)/2);
      }
      popMatrix();

      //draw robot 2
      pushMatrix();
      {
        PVector p = getHexCoord(r2.getQ(), r2.getR());
        translate(p.x, p.y);
        r2.draw((interp+tick%2)/2);
      }
      popMatrix();

      //display robot 1 stats
      push();
      {
        reset();
        translate(10, 150);
        drawRobotIntroWithStats(c1, 0, 0, 300, 440, color(0, 0, 255));

        translate(0, 440);

        //draw lives
        stroke(0);
        strokeWeight(2);

        fill(255, 0, 0);
        rect(0, 0, 300, 40);

        fill(0, 255, 0);
        rect(0, 0, map(r1.getHp(), 0, 100, 0, 300), 40);
      }
      pop();

      //display robot 2 stats
      push();
      {
        reset();
        translate(width-310, 150);
        drawRobotIntroWithStats(c2, 0, 0, 300, 440, color(255, 0, 0));

        translate(0, 440);

        //draw lives
        stroke(0);
        strokeWeight(2);

        fill(255, 0, 0);
        rect(0, 0, 300, 40);

        fill(0, 255, 0);
        rect(300-map(r2.getHp(), 0, 100, 0, 300), 0, map(r2.getHp(), 0, 100, 0, 300), 40);
      }
      pop();

      //display match start: "Ready... Set... Go!"
      pushMatrix();
      {
        textAlign(CENTER, CENTER);
        if (tick_2 < 60) {
          resetMatrix();
          fill(0, 255-map(tick_2, 0, 60, 0, 255));
          noStroke();
          rect(0, 0, width, height);
        } else if (tick_2 < 120)
        {
          fill(0, 255-map(tick_2-60, 0, 60, 0, 255));
          textSize(200-(tick_2-60)*2/3);
          text("READY...", 0, 0);
        } else if (tick_2 < 180)
        {
          fill(0, 255-map(tick_2-120, 0, 60, 0, 255));
          textSize(200-(tick_2-120)*2/3);
          text("SET...", 0, 0);
        } else if (tick_2 < 240)
        {
          fill(0, 255-map(tick_2-180, 0, 60, 0, 255));
          textSize(200-(tick_2-180)*2/3);
          text("GO!", 0, 0);
        }
      }
      popMatrix();
    }
    popMatrix();
  }


  int blackoutT = 0;
  public boolean stateStep()
  {
    draw(((tick_2)%6)/6.0);
    if (matchOver)
    {
      blackoutT++;
      if (blackoutT >= 60)
      {
        pushMatrix();
        {
          resetMatrix();
          fill(0, map(blackoutT, 60, 90, 0, 255));
          rect(0, 0, width, height);
        }
        popMatrix();
      }
      return blackoutT >= 90;
    }
    tick_2++;

    if (tick_2%6!=0)
    {
      return false;
    }

    tick++;

    //get actions from player robots (every 3 ticks);

    if (remainingTurns==0)
    {
      if (r1.getHp()==r2.getHp())
      {
        result = DRAW;
      } else if (r1.getHp() > r2.getHp())
      {
        result = R1WIN;
      } else
      {
        result = R2WIN;
      }
      matchOver = true;
      return false;
    }

    if (tick%2==0 && tick > 30)
    {
      remainingTurns--;

      _1.signal(true);
      _2.signal(true);
    }

    if (a1.value != null) 
    {
      if (a1.value.getFireAction() && r1FireCooldown > 6)
      {
        projectiles.add(new Projectile(r1.getQ(), r1.getR(), r1.getTurretHeading(), 1));
        r1FireCooldown = 0;
      }
      m1.add(a1.value);
    } else
    {
      m1.add(new Action());
    }
    if (a2.value != null) {
      if (a2.value.getFireAction() && r2FireCooldown > 6)
      {
        projectiles.add(new Projectile(r2.getQ(), r2.getR(), r2.getTurretHeading(), 2));
        r2FireCooldown = 0;
      }
      m2.add(a2.value);
    } else
    {
      m2.add(new Action());
    }
    r1FireCooldown++;
    r2FireCooldown++;

    //update bullets
    ArrayList<Projectile> rem = new ArrayList<Projectile>();
    for (Projectile p : projectiles)
    {
      p.step();
      if (p.q == r1.getQ() && p.r == r1.getR())
      {
        r1.takeDamage(int(random(damage_min, damage_max)));
        rem.add(p);
      }
      if (p.q == r2.getQ() && p.r == r2.getR())
      {
        r2.takeDamage(int(random(damage_min, damage_max)));
        rem.add(p);
      }
      boolean test = false;
      for (Pair<Integer, Integer> o : obstacles)
      {
        if (p.q == o.one && p.r == o.two)
        {
          test = true;
          break;
        }
      }
      if (test || (abs(p.q) > gridSize || abs(p.r) > gridSize || abs(p.q+p.r) > gridSize))
      {
        rem.add(p);
      }
    }

    for (Projectile p : rem)
    {
      projectiles.remove(p);
    }

    //check game for end conditions
    if (r1.isDead()&&r2.isDead())
    {
      result = DRAW;
      return true;
    } else if (r1.isDead())
    {
      result = R2WIN;
      return true;
    } else if (r2.isDead())
    {
      result = R1WIN;
      matchOver=true;
    }

    return false;
  }

  //displays the robots in the match as well as the result
  public void matchIntro()
  {
    pushMatrix();
    {
      gameBackground();

      pushMatrix();
      {
        translate(width/2, 0);
        fill(0, 150);
        textSize(70);
        textAlign(CENTER, TOP);
        rect(-textWidth(title)/2-5, 40, textWidth(title)+20, 80);

        fill(200);
        text(title, 0, 40);
      }
      popMatrix();

      pushMatrix();
      {
        translate(10, height/2-(width/3+140)/2);
        drawRobotIntroWithStats(c1, 0, 0, width/3, width/3+140, color(0, 0, 255));
      }
      popMatrix();

      push();
      {
        translate(width/2, 0);
        textAlign(CENTER, CENTER);
        textSize(200);
        fill(0);
        text("[VS]", 0, height/2);
      }
      pop();

      pushMatrix();
      {
        translate(width*2/3-10, height/2-(width/3+140)/2);
        drawRobotIntroWithStats(c2, 0, 0, width/3, width/3+140, color(255, 0, 0));
      }
      popMatrix();
    }
    popMatrix();
  }

  public void matchOutro()
  {
    gameBackground();
    if (result == DRAW)
    {
      pushMatrix();
      {

        pushMatrix();
        {
          translate(10, height/2-(width/3+140)/2);
          drawRobotIntroWithStats(c1, 0, 0, width/3, width/3+140, color(0, 0, 255));
        }
        popMatrix();

        push();
        {
          translate(width/2, 0);
          textAlign(CENTER, CENTER);
          textSize(150);
          fill(0);
          text("DRAW", 0, height/4);
        }
        pop();

        pushMatrix();
        {
          translate(width*2/3-10, height/2-(width/3+140)/2);
          drawRobotIntroWithStats(c2, 0, 0, width/3, width/3+140, color(255, 0, 0));
        }
        popMatrix();
      }
      popMatrix();
    } else if (result == R1WIN)
    {
      pushMatrix();
      {
        pushMatrix();
        {
          textSize(100);
          textAlign(LEFT, TOP);
          fill(0);
          text("WINNER!",5,5);
          
          translate(5, 110);
          drawRobotIntroWithStats(c1, 0, 0, height-250, height-110, color(0, 0, 255));
        }
        popMatrix();
        
        pushMatrix();
        {
          translate(width*2/3-10, height/2-(width/3+140)/2);
          drawRobotIntroWithStats(c2, 0, 0, width/3, width/3+140, color(255, 0, 0));
        }
        popMatrix();
      }
      popMatrix();
    } else if (result == R2WIN)
    {
      pushMatrix();
      {
        pushMatrix();
        {
          translate(10, height/2-(width/3+140)/2);
          drawRobotIntroWithStats(c1, 0, 0, width/3, width/3+140, color(0, 0, 255));
        }
        popMatrix();

        push();
        {
          translate(width/2, 0);
          textAlign(CENTER, CENTER);
          textSize(100);
          fill(0);
          text(r2.getName() + "\nWins!", 0, height/4);
        }
        pop();

        pushMatrix();
        {
          translate(width-height+245, 5);
          textSize(100);
          textAlign(LEFT, TOP);
          fill(0);
          text("WINNER!",0,0);
          
          translate(0,105);
          drawRobotIntroWithStats(c2, 0, 0, height-250, height-110, color(255, 0, 0));
        }
        popMatrix();

        if (t_endTimer < 30) {
          resetMatrix();
          fill(0, 255-map(t_endTimer, 0, 30, 0, 255));
          rect(0, 0, width, height);
        }
      }
      popMatrix();
    }
    pushMatrix();
    {
      if (t_endTimer < 60) {
        resetMatrix();
        fill(0, 255-map(t_endTimer, 0, 60, 0, 255));
        rect(0, 0, width, height);
      }
      if (t_endTimer > 270) {
        resetMatrix();
        fill(0, map(t_endTimer, 270, 300, 0, 255));
        rect(0, 0, width, height);
      }
    }
    popMatrix();
  }
}

class SignalableThread<T> extends Thread {

  protected T signalVal;
  public void signal(T v) {
  }
}

interface Function<R, P>
{
  public R apply(P params);
}