# ai-gladiators
A simple game pitting two AI-controlled tanks against each other in a round-robin match-based tournament.

## Running a Competition
Use the Processing files from the `Competition` folder to run a competition.

 * Place all the competitor classes in the `CompetingRobots` tab, then run the program.
    * Submissions have to be manually checked to make sure no one cheats. No one should use Java Reflect, or try to access the game data in the game controller. Use of Processing draw functions should be banned as it can lead to graphical messiness during matches.
 * The game record will be available after the competition finishes in the `data/games/game<date of finish>.json`

## Competing in a Competition
Use the Processing files from the `Practice` folder to design and test your robot. Examples and debug robots are available as references and to test your robot.

 * Implement a subclass of the `Robot` class. The name of your class will be the name displayed in the competition.
    * A new instance of your robot will be created for each match, so design your robot accordingly.
 * Put any initialization code you want to run once at the beginning of the competion in the `void initialize()` function.
    * Something you may want to do is set your avatar here.
 * Put the code you want to run each time you have the opportunity to take an action in the `void action(Action a)` function.
    * Your code will be given roughly 100ms to run each turn, and if you have not completed your turn by then your turn will be skipped. Your `action(...)` function will not be called again until it has returned.


## Robot Class and Utility Function Documentation
This is the documentation of the functions provided to the competitor as utilities related to the game.
 
* Robot Class
 * Actions (these functions are all called on the Action instance passed to you each turn)
  * Moving
  * Turning
   * `void turn(Direction dir)`
    * Turns the entire robot in the direction specified (`Left` or `Right`) by 60 degrees or 1/6 rotations. Calling this function with `None` as a parameter will cancel previously ordered turns.
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
    * Returns a list of the objects in the 6 adjacent hexagons to your robot. The list index is the absolute direction of the hexagon from your robot.
  * Telemtry
   * Location
   * Robot Health
* Utility Functions
