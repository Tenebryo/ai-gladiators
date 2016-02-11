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

final class Game
{
  Game() {
  };

  private int matchValidator = 0; //no one can add invalid matches
  private String currentTournament;

  private PImage defaultAvatar;

  private ArrayList<Class> robots;
  private ArrayList<Match> matches;
  private ArrayList<State> stateQueue;

  private HashMap<Class, Pair<Integer, Pair<Integer, Integer>>> scores;
  private HashMap<Class, PImage> avatars = new HashMap<Class, PImage>();

  private JSONObject gameLog;

  private State currentState;

  void setup(ArrayList<Class> r)
  {
    while (true) 
    {
      try 
      {
        gameLog = loadJSONObject("./data/games/game.json");
        break;
      }
      catch(NullPointerException e)
      {
        //game.json was not in the games folder
        //replace it with new one
        try
        {
          saveStrings("./data/games/game.json", loadStrings("./data/game.json"));
        }
        catch(Exception e1)
        {
          //real problems now
          println("ERROR: Unable to find game log template file, or unable to write file new one, exiting.");
          exit();
        }
      }
    }

    matchValidator = new Random().nextInt();

    scores = new HashMap<Class, Pair<Integer, Pair<Integer, Integer>>>();

    matches = new ArrayList<Match>();
    stateQueue = new ArrayList<State>();
    robots = r;

    defaultAvatar = loadImage(pathJoin(".\\data", "defaultAvatar.png"));

    println(robots);

    Collections.shuffle(robots);

    for (int i = robots.size()-1; i >= 0; i--)
    {
      if (robots.get(i).getSuperclass()==null)
      {
        robots.remove(i);
      } else if (!robots.get(i).getSuperclass().equals(new Robot().getClass()))
      {
        robots.remove(i);
      }
    }

    //run initialization code for all robots
    for (Class rb : robots)
    {
      Robot tmp = getRobotInstance(rb);
      if (tmp != null)
      {
        tmp.initialize();
      }
    }

    if (gameLog.getJSONArray("robotNames").size() != 0)
    {
      //load old competition
      for (int i = 0; i < gameLog.getJSONArray("queuedMatches").size(); i++)
      {
        matches.add(matchFromJSON(gameLog.getJSONObject("matches").getJSONObject(gameLog.getJSONArray("queuedMatches").getString(i))));
      }
      for (int i = 0; i < gameLog.getJSONArray("robotNames").size(); i++)
      {
        String rname = gameLog.getJSONArray("robotNames").getString(i);
        JSONObject rb = gameLog.getJSONObject("robots").getJSONObject(rname);
        try
        {
          Class tmp = Class.forName(rname);
          scores.put(tmp, new Pair<Integer, Pair<Integer, Integer>>(rb.getInt("wins"), new Pair<Integer, Integer>(rb.getInt("draws"), rb.getInt("losses"))));
        }
        catch(ClassNotFoundException e)
        {
          println("Could not find Class: " + rname);
        }
      }
    } else
    {
      //create new competition

      for (Class t : robots)
      {
        println(t.getName());
        scores.put(t, new Pair<Integer, Pair<Integer, Integer>>(0, new Pair<Integer, Integer>(0, 0)));
        gameLog.getJSONArray("robotNames").append(t.getName());
        gameLog.getJSONObject("robots").setJSONObject(t.getName(), parseJSONObject("{wins:0,draws:0,losses:0}"));
      }

      //create a bracket
      int sc = 1;
      ArrayList<Integer> setIndex = new ArrayList<Integer>();
      for (int i = 0; i < robots.size(); i++)
      {
        for (int j = i+1; j < robots.size(); j++)
        {
          matches.add(new Match(robots.get(i), robots.get(j), "Set " + str(sc) + ": Match 1", matchValidator));
          addMatch(matches.get(matches.size()-1));
          matches.add(new Match(robots.get(i), robots.get(j), "Set " + str(sc) + ": Match 2", matchValidator));
          addMatch(matches.get(matches.size()-1));
          matches.add(new Match(robots.get(i), robots.get(j), "Set " + str(sc) + ": Match 3", matchValidator));
          addMatch(matches.get(matches.size()-1));
          setIndex.add(sc-1);
          sc++;
        }
      }
      saveJSONObject(gameLog, "./data/game.json");
      Collections.shuffle(setIndex);


      ArrayList<Match> ms = new ArrayList<Match>();
      for (int i = 0; i < setIndex.size(); i++)
      {
        ms.add(matches.get(3*setIndex.get(i)));
        ms.add(matches.get(3*setIndex.get(i)+1));
        ms.add(matches.get(3*setIndex.get(i)+2));
      }
      matches = ms;
    }


    stateQueue.add(new Intermission());
    for (int i = 0; i < matches.size(); i++)
    {
      stateQueue.add(matches.get(i));
      stateQueue.add(new Intermission());
    }

    println("Ready");
  }

  Match matchFromJSON(JSONObject obj)
  {
    Class r1 = null, r2 = null;
    String title;
    ArrayList<Pair<Integer, Integer>> obs = new ArrayList<Pair<Integer, Integer>>();

    try
    {
      r1=Class.forName(obj.getString("robot1"));
    }
    catch(ClassNotFoundException e)
    {
      println("Could not find Class: " +obj.getString("robot1"));
    }

    try
    {
      r2=Class.forName(obj.getString("robot2"));
    }
    catch(ClassNotFoundException e)
    {
      println("Could not find Class: " +obj.getString("robot2"));
    }

    title=obj.getString("title");

    for (int i = 0; i < obj.getJSONArray("obstacles").size(); i++)
    {
      JSONArray tmp = obj.getJSONArray("obstacles").getJSONArray(i);
      obs.add(new Pair<Integer, Integer>(tmp.getInt(0), tmp.getInt(1)));
    }

    return new Match(r1, r2, title, obs, matchValidator);
  }

  void addMatch(Match m)
  {
    gameLog.getJSONObject("matches").setJSONObject(m.id, m.toJSON());
    gameLog.getJSONArray("queuedMatches").append(m.id);
  }

  float getCompetitionScoreFromPair(Pair<Integer, Pair<Integer, Integer>> pair) {
    return pair.one + pair.two.one/2.0 - pair.two.two/4.0;
  }

  void logMatchOutcome(Match m)
  {
    if (m.isValid(matchValidator))
    {
      //{matches:{id:{robot1:"",robot2:"",outcome:"",title:"",obstacles:[[1,3], ...],actions:[["",""], ...]}},completedMatches:[...],queuedMatches:[...],robots:{test:{wins:1337,draws:0,losses:-1}, ...},robotNames:[test, ...]}
      JSONObject log = gameLog;

      if (m.result == m.DRAW)
      {
        log.getJSONObject("matches").getJSONObject(m.id).setInt("outcome", m.DRAW);
        JSONObject r1 = log.getJSONObject("robots").getJSONObject(m.c1.getName());
        r1.setInt("draws", r1.getInt("draws")+1);
        scores.get(m.c1).two.one++;
        JSONObject r2 = log.getJSONObject("robots").getJSONObject(m.c2.getName());
        r2.setInt("draws", r2.getInt("draws")+1);
        scores.get(m.c2).two.one++;
      } else if (m.result == m.R1WIN)
      {
        log.getJSONObject("matches").getJSONObject(m.id).setInt("outcome", m.R1WIN);

        JSONObject winner = log.getJSONObject("robots").getJSONObject(m.c1.getName());
        winner.setInt("wins", winner.getInt("wins")+1);
        scores.get(m.c1).one++;
        JSONObject loser = log.getJSONObject("robots").getJSONObject(m.c2.getName());
        loser.setInt("losses", loser.getInt("losses")+1);
        scores.get(m.c2).two.two++;
      } else if (m.result == m.R2WIN)
      {
        log.getJSONObject("matches").getJSONObject(m.id).setInt("outcome", m.R2WIN);

        JSONObject winner = log.getJSONObject("robots").getJSONObject(m.c2.getName());
        winner.setInt("wins", winner.getInt("wins")+1);
        scores.get(m.c2).one++;
        JSONObject loser = log.getJSONObject("robots").getJSONObject(m.c1.getName());
        loser.setInt("losses", loser.getInt("losses")+1);
        scores.get(m.c1).two.two++;
      } else if (m.result == m.UNPLAYED)
      {
        return;
      }
      log.getJSONArray("completedMatches").append(m.id);

      JSONArray queued = log.getJSONArray("queuedMatches");
      for (int i = 0; i < queued.size(); i++) {
        if (queued.getString(i).equals(m.id))
        {
          queued.remove(i);
          break;
        }
      }


      saveJSONObject(log, "./data/game.json");
    }
  }

  ArrayList<ComparablePair<Float, Class>> getScores()
  {
    ArrayList<ComparablePair<Float, Class>> robotList = new ArrayList<ComparablePair<Float, Class>>();
    for (Class rc : scores.keySet())
    {
      robotList.add(new ComparablePair<Float, Class>(getCompetitionScoreFromPair(scores.get(rc)), rc));
    }
    Collections.sort(robotList);
    Collections.reverse(robotList);
    return robotList;
  }

  public Pair<Integer, Pair<Integer, Integer>> getRobotScore(Class r)
  {
    if (scores.containsKey(r))
    {
      return scores.get(r);
    } else
    {
      return new Pair<Integer, Pair<Integer, Integer>>(0, new Pair<Integer, Integer>(0, 0));
    }
  }

  public void setRobotAvatar(Class robot, String p)
  {
    if (!avatars.containsKey(robot))
    {
      PImage pi = loadImage(pathJoin(pathJoin("./data/", getRobotName(robot)), p));
      avatars.put(robot, pi);
    }
  }

  public PImage getRobotAvatar(Class robot)
  {
    if (avatars.containsKey(robot))
    {
      return avatars.get(robot);
    } else 
    {
      return defaultAvatar;
    }
  }

  int stateState = 0;
  void draw()
  {
    if (currentState==null)
    {
      if (stateQueue.size()>0)
      {
        currentState = stateQueue.remove(0);
      }
      return;
    }
    switch(stateState)
    {
    case 0:
      if (currentState.stateStart()) {
        stateState++;
      }
      break;
    case 1:
      if (currentState.stateStep()) {
        stateState++;
      }
      break;
    case 2:
      if (currentState.stateEnd()) {
        stateState = 0;
        if (stateQueue.size()>0)
        {
          currentState = stateQueue.remove(0);
        }
      }
      break;
    }
  }
}