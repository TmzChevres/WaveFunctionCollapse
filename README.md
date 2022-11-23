# WaveFunctionCollapse
Wave function collapse program for generating open worlds in Processing
Tomaz Chevres
Nov 23, 2022


## Stuff to know
### Constructors:
public WorldGen(String tileSetDir)
- Creates a worldGen using the directory at the specified location tileSetDir
- ex. WorldGen world = new WorldGen("data/TileSets/Default") will use the JSON file at /data/TileSets/Default/config.json

public WorldGen(File tileSetDir)
- Creates a worldGen using the directory tileSetDir (recomended)
- ex. WolrdGen world = new WorldGen(new File("data/TileSets/Default")) will use the JSON file at /data/TileSets/Default/config.json


### Methods:
To generate a world methods must be called in the following order order:
1. createWorld(int worldWidth, int worldHeight)
2. OPTIONAL - restrictTile(int x, int y, BaseTile t), addRow(), addRow(int i), addCol(), addCol(int i)
3. OPTIONAL - generateTile(int x, int y)
4. generateWorld()

public boolean createWorld(int worldWidth, int worldHeight)
- Creates a matrix (ArrayList\<ArrayList\<Set\<BaseTile\>\>\> map) to generate the world in.
- Each spot in map will contains the set of all BaseTiles (tileSet.getTileSet())
- Returns false if the tileSet is not fully loaded yet or if it hits an error while generating, true otherwise

public void addRow(), addRow(int i)
- Adds a row to map at the end or at index i
- Each spot in the new row will contain the set of all BaseTiles (tileSet.getTileSet())

public void addCol(), addCol(int i)
- Adds a column to map at the end or at index i
- Each spot in the new column will contain the set of all BaseTiles (tileSet.getTileSet())




## DEBUG MODE
IMPORTANT - size() must be called within settings(){} not setup(){} on the main tab of the sketch (or just delete the debugger)

Call debug() or debug(int tileSize) to activate in a new PApplet
Pressing keys 1-2 will display different modes
Display Screens:
1. Displays all possible tiles (including texture variations), mainly used to check that JSON file was read correctly
2. Tile adjacencies (spelling?) - displays a center tile and 4 possible bordering tiles
   - Press 'q' to cycle the center tile
   - Press 'w'/'a'/'s'/'d' to cycle the adjacent tiles
   - Press shift + 'q'/'w'/'a'/'s'/'d' to cycle textures
   - Press ' ' to randomize all tiles (null excluded)
   - Press 'e' to randomize textures
