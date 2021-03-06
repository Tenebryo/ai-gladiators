#Artificial Intelligence Gladiator Tournament
A simple game pitting two AI-controlled tanks against each other in a round-robin match-based tournament.

##Rules

###Game
The game is played on a grid of hexagons and the edges of the arena are 10 hexagons from the center. Directions will be defined as follows: the tile to the East with be in the `0` direction, then the directions go from `1` to `5` counter clockwise. Positions are defined by 2 coordinates,`Q`, and `R`; positive `Q` is in the East direction (or `0` as defined before), and `R` is in the North-Northeast direction (`1` as defined before). 12 random obstacles are placed in the arena, and you may assume there will always be one in the very center of the arena and there will always be a path to the other robot. The robots will both be simultaneously given the opportunity to take one "Action" each "Turn". An action can be moving forward or backward, turning left or right, either the base, turret, or both, and/or firing a missile (you have a cooldown of 3 turns before you can fire again. The only restriction on Actions is that you may not move (forwards or backwards) and turn on the same Action. Each robot has 100 health, and first robot to have less than or equal to 0 health loses (a missile does 50 damage), or if 1000 turns pass, the winner is decided by the health remaining. A draw can occur in either situations. The winner of the tournament is decided by the number of wins, draws, and losses each competitor has; a win is worth 1 point, a draw is worth 0.5 points, and a loss is worth -0.25 points.

###Robot Design
Competitors will submit an implementation of the `Robot` class. The name of the class will be the display name of your robot. You may have global variables but they must be prefixed with the name of your robot. You may only use standard Java libraries (excluding Java Reflection) and Processing functions (excluding drawing functions). All robots submitted will be manually reviewed to ensure that no underhanded code (such as code to change your score, exit the game, or otherwise interfere with the competition). The robots are given around 100 milliseconds (1/10 of a second) to plan their next action, and if they fail to finish by then, they will "pass" that turn, and will continue to be skipped until they finish planning that action. Any planned action will not be executed until after your function returns, and there is no addition effect from calling a function on an action more than once.

##Running a Competition
Use the Processing files from the `Competition` folder and make sure the `singleMatch` boolean variable is set to `false` to run a competition.

 * Place all the competitor classes in the `CompetingRobots` tab, then run the program.
    * Submissions have to be manually checked to make sure no one cheats. No one should use Java Reflect, or try to access the game data in the game controller. Use of Processing draw functions should be banned as it can lead to graphical messiness during matches.
 * The game record will be available after the competition finishes in the `data/games/game<date of finish>.json`

##Competing in a Competition
Use the Processing files from the `Competition` folder  and make sure the `singleMatch` boolean variable is set to `true` to design and test your robot. Examples and debug robots are available as references and to test your robot.

* Implement a subclass of the `Robot` class. The name of your class will be the name displayed in the competition.
 * A new instance of your robot will be created for each match, so design your robot accordingly.
* Put any initialization code you want to run once at the beginning of the competion in the `void initialize()` function.
 * Something you may want to do is set your avatar here.
* Put the code you want to run each time you have the opportunity to take an action in the `void action(Action a)` function.
 * Your code will be given roughly 100ms to run each turn, and if you have not completed your turn by then your turn will be skipped. Your `action(...)` function will not be called again until the previous call has returned.


##Robot Class and Utility Function Documentation
This is the documentation of the functions provided to the competitor as utilities related to the game.
 
* Robot Class
 * Actions (these functions are all called on the Action instance passed to you each turn)
  * Moving
   * `void move(Direction dir)`
    * Moves the robot in the direction specified along the direction the base of your robot is facing, or cancels previously planned moves. This function will cancel any base turns.
   * `void moveForward()`
    * Equivalent to move(Forward)
   * `void moveBackward()`
    * Equivalent to move(Reverse)
  * Turning
   * `void turn(Direction dir)`
    * Turns the entire robot in the direction specified (`Left`, `Right`, or `None`) by 60 degrees or 1/6 rotations. Calling this function with `None` as a parameter will cancel previously ordered turns.
   * `void turnRight()`
    * Turns the robot right by 60 degrees, or 1/6 rotations.
   * `void turnLeft()`
    * Turns the robot right by 60 degrees, or 1/6 rotations.
 * Sensors
  * Line of Sight
   * `String[] getLineOfSight()`
    * Returns a list of objects on the ray extended from your robot in the direction your turret is facing until an object blocks your view. An enemy robot or a wall will block your sight, but not a projectile or empyt space.
  * Adjacent Area
   * `String[] getNearbyObjects()`
    * Returns a list of the objects in the 6 adjacent hexagons to your robot. The list index is the absolute direction of the hexagon from your robot (i.e. `getNearbyObjects()[0]` will always be the position to the East of your robot.
  * Location
   * `int getQ()`
    * Returns the `Q` coordinate of the robot
   * `int getR()`
    * Returns the `R` coordinate of the robot
  * Robot Health
   * `int getHp()`
    * Gets the robot health points (between 0-100)
* Utility Functions
 * `int getIntDirectionFromString(String dir)`
  * Returns the corresponding integer value of a direction
 * `int getDirectionLeftOf(int d)`
  * Returns the direction to the left of the given direction
 * `int getDirectionRightOf(int d)`
  * returns the direction to the right of the given direction
 * `Pair<Integer, Integer> getDirectionIncrement(String direction)` or `Pair<Integer, Integer> getDirectionIncrement(int direction)`
  * returns the corresponding changes in the `q` and `r` position from a movement in the direction specified, returned as a `Pair<Integer, Integer>` pair (`pair.one` being the change in `Q` and `pair.two` being the change in `R`)
 * `Pair<Integer, Integer> getIncrementedPosition(int q, int r, String direction)` or `Pair<Integer, Integer> getIncrementedPosition(int q, int r, String direction)`
  * Returns the new changes in the `q` and `r` position from a movement in the direction specified starting at the `Q` and `R` positions specified, returned as a `Pair<Integer, Integer>` pair (`pair.one` being the new `Q` and `pair.two` being the new `R`)
 * `ArrayList<Pair<Integer, Integer>> getAdjacentTiles(int q, int r)`
  * returns an ArrayList of the positions of the tiles around the position `Q` and `R`. The index is the direction from that position.

##Examples
These examples are also provided in the processing files.

* SimpleRobot 
 * The most basic robot possible. Simple fires whenever it has recharged.
```
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
```
* RandomRobot
 * Chooses a random move
```
public class RandomRobot extends Robot
{
  public RandomRobot() {
    super();
  }

  public void action(Action move)
  {
    int r = round(random(-0.5, 4.5));
    switch(r)
    {
    case 0:
      move.moveForward();
      break;
    case 1:
      move.moveBackward();
      break;
    case 2:
      move.turnRight();
      break;
    case 3:
      move.turnLeft();
      break;
    case 4:
      move.fire();
      break;
    }
  }
}
```
* BasicAIRobot
 * This robot always keeps the wall on the left and stops to shoot at the enemy when it sees it.
```
public class BasicAIRobot extends Robot
{
  public BasicAIRobot() {
    super();
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
    if (s[getDirectionRightOf(getBaseHeading())]=="Nothing")
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
```
