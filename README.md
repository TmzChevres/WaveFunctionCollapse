# WaveFunctionCollapse
Wave function collapse program for generating open worlds in Processing
Tomaz Chevres
Nov 23, 2022


## Stuff to know
### Constructors:
**public WorldGen(String tileSetDir)**
- Creates a worldGen using the directory at the specified location tileSetDir
- ex. WorldGen world = new WorldGen("data/TileSets/Default") will use the JSON file at /data/TileSets/Default/config.json

**public WorldGen(File tileSetDir)**
- Creates a worldGen using the directory tileSetDir (recomended)
- ex. WolrdGen world = new WorldGen(new File("data/TileSets/Default")) will use the JSON file at /data/TileSets/Default/config.json


### Variables:
**private TileSet tileSet**
- Set of all possible BaseTiles to generate the world from
- Loaded from a config.json file

**private ArrayList\<ArrayList\<Set\<BaseTile\>\>\> map**
- Matrix of Sets of tiles
- Each Set contains all possible Tiles that can generate in that spot on the map
- set.size()==1 represents a completely collapsed Tile, when the world is fully generated all sets in map will have a size of 1


### Methods:
#### World Generation
To generate a world methods must be called in the following order order:
1. createWorld(int worldWidth, int worldHeight)
2. OPTIONAL - restrictTile(int x, int y, BaseTile t), addRow(), addRow(int i), addCol(), addCol(int i)
3. OPTIONAL - generateTile(int x, int y)
4. generateWorld()

<br>**public boolean createWorld(int worldWidth, int worldHeight)**
- Creates a matrix (ArrayList\<ArrayList\<Set\<BaseTile\>\>\> map) to generate the world in.
- Each spot in map will contains the set of all BaseTiles (tileSet.getTileSet())
- Returns false if the tileSet is not fully loaded yet or if it hits an error while generating, true otherwise

**public void addRow(), addRow(int i)**
- Adds a row to map at the end or at index i
- Each spot in the new row will contain the set of all BaseTiles (tileSet.getTileSet())

**public void addCol(), addCol(int i)**
- Adds a column to map at the end or at index i
- Each spot in the new column will contain the set of all BaseTiles (tileSet.getTileSet())

**public Set\<BaseTile\> get(int x, int y)**
- Returns the Set at map[x][y]
- get(x,y) is the same thing as map.get(x).get(y)

**public Set\<BaseTile\> set(int x, int y, Set\<BaseTile\> tSet)**
- Sets the Set at map[x][y] to tSet, returns the original value
- set(x,y,tSet) is the same thing as map.get(x).set(y,tSet)

**public boolean restrictTile(int x, int y, BaseTile t)**
- Sets map[x][y] to a set of size==1 that contains only t
- Returns false and does not run if map[x][y] does not already contain t or if map[x][y] is unchanged, true otherwise

**public boolean restrictTile(int x, int y, Set\<BaseTile\> t)**
- Sets map[x][y] to the intersection of map[x][y] and t
- Returns false and does not run if map[x][y] and t have no intersections of if map[x][y] is unchanged, true otherwise

#### Getting Tiles
**public Set\<BaseTile\> getTileSet()**
- Returns the set of all tiles

**public Set\<BaseTile\> getTileSetByID(int id)**
- Returns the set of all tiles with a matching id

**public Set\<BaseTile\> getTileSetByName(String name)**
- Returns the set of all tiles with a matching name

**public Set\<BaseTile\> getTileSetByEdge(int up, int down, int left, int right)**
- Returns the set of all tiles with the corresponding socket values
- Edge value of 0 is ignored

**public Set\<BaseTile\> getTileSetByEdgeUp(int val)**
- Returns the set of all tiles a matching up socket value
- Edge value of 0 is ignored

**public Set\<BaseTile\> getTileSetByEdgeDown(int val)**
- Returns the set of all tiles a matching down socket value
- Edge value of 0 is ignored

**public Set\<BaseTile\> getTileSetByEdgeLeft(int val)**
- Returns the set of all tiles a matching left socket value
- Edge value of 0 is ignored

**public Set\<BaseTile\> getTileSetByEdgeRight(int val)**
- Returns the set of all tiles a matching right socket value

**public Set\<BaseTile\> getTileSet(int id, int upEdge, int downEdge, int leftEdge, int rightEdge)**
- Returns the set of all tiles that meet all of the parameters
- Edge value of 0 is ignored

## DEBUG MODE
**IMPORTANT - size() must be called within settings() not setup() on the main tab of the sketch (or just delete the debugger)**

<br>Call debug() or debug(int tileSize) to activate in a new PApplet
Pressing keys 1-2 will display different modes
Display Screens:
1. Displays all possible tiles (including texture variations), mainly used to check that JSON file was read correctly
2. Tile adjacencies (spelling?) - displays a center tile and 4 possible bordering tiles
   - Press 'q' to cycle the center tile
   - Press 'w'/'a'/'s'/'d' to cycle the adjacent tiles
   - Press shift + 'q'/'w'/'a'/'s'/'d' to cycle textures
   - Press ' ' to randomize all tiles (null excluded)
   - Press 'e' to randomize textures
3. Displays map & all possible tile placements