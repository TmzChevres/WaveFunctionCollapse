# WaveFunctionCollapse
Wave function collapse program for generating open worlds in Processing
Tomaz Chevres
Nov 23, 2022


=====Stuff to know=====

Constructors:
public WorldGen(String tileSetDir)
- Creates a worldGen using the directory at the specified location tileSetDir
- ex. WorldGen world = new WorldGen("data/TileSets/Default") will use the JSON file at /data/TileSets/Default/config.json

public WorldGen(File tileSetDir)
- Creates a worldGen using the directory tileSetDir (recomended)
- ex. WolrdGen world = new WorldGen(new File("data/TileSets/Default")) will use the JSON file at /data/TileSets/Default/config.json


Methods:
- To generate a world methods must be called in the following order order:
- createWorld(int worldWidth, int worldHeight)
- OPTIONAL - restrictTile(int x, int y, BaseTile t), addRow(), addRow(int i), addCol(), addCol(int i)
- OPTIONAL - generateTile(int x, int y)
- generateWorld()



=====DEBUG MODE=====
- IMPORTANT - size() must be called within settings(){} not setup(){} on the main tab of the sketch (or just delete the debugger)
-
- call debug() or debug(int tileSize) to activate in a new PApplet
- Pressing keys 1-2 will display different modes
- Display Screens:
-   1. Displays all possible tiles (including texture variations), mainly used to check that JSON file was read correctly
-   2. Tile adjacencies (spelling?) - displays a center tile and 4 possible bordering tiles
-       Press 'q' to cycle the center tile
-       Press 'w'/'a'/'s'/'d' to cycle the adjacent tiles
-       Press shift + 'q'/'w'/'a'/'s'/'d' to cycle textures
-       Press ' ' to randomize all tiles (null excluded)
-       Press 'e' to randomize textures