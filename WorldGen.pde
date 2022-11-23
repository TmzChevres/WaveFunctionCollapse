import java.io.*;
import java.util.*;

//Class to generate a tiled world using wave-function collapse
//Reads tile sets from a folder data/TileSets/
class WorldGen extends Thread{
  //Vars for loading tile set
  TileSet tileSet;
  ArrayList<ArrayList<Set<BaseTile>>> map = new ArrayList<ArrayList<Set<BaseTile>>>();
  
  //Standard constructor using String for file directory
  public WorldGen(String tileSetDir){
    this(new File(tileSetDir));
  }
  //More specific constructor passing the directory File directly
  public WorldGen(File tileSetDir){
    tileSet = new TileSet(tileSetDir);
  }
  
  //creates an empty array for the world
  //returns false if tileSet is not loaded (and will not generate map), true otherwise
  public boolean createWorld(int worldWidth, int worldHeight){
    if(!tileSet.loaded) return false;
    for(int x=0; x<worldWidth; x++){
      map.add(new ArrayList<Set<BaseTile>>());
      for(int y=0; y<worldHeight; y++){
        map.get(x).add(tileSet.getTileSet());
      }
    }
    return true;
  }
  //returns the tileSet in map at [x][y]
  public Set<BaseTile> getSet(int x, int y){
    return map.get(x).get(y);
  }
  //restricts the Tile at [x][y] to a single state
  public boolean restrictTile(int x, int y, BaseTile t){
    if(getSet(x,y).contains(t)){
      map.get(x).set(y, new HashSet<BaseTile>());
      getSet(x,y).add(t);
      return true;
    }
    else return false;
  }
  //adds a row of tileSets to map
  public void addRow(){
    for(ArrayList<Set<BaseTile>> arr : map){
      arr.add(tileSet.getTileSet());
    }
  }
  public void addRow(int i){
    for(ArrayList<Set<BaseTile>> arr : map){
      arr.add(i,tileSet.getTileSet());
    }
  }
  //adds a column of tileSets to map
  public void addCol(){
    int len = map.get(0).size();
    ArrayList<Set<BaseTile>> newArr = new ArrayList<Set<BaseTile>>();
    for(int i=0; i<len; i++){
      newArr.add(tileSet.getTileSet());
    }
    map.add(newArr);
  }
  public void addCol(int i){
    int len = map.get(0).size();
    ArrayList<Set<BaseTile>> newArr = new ArrayList<Set<BaseTile>>();
    for(int j=0; j<len; j++){
      newArr.add(tileSet.getTileSet());
    }
    map.add(i,newArr);
  }
  
  //TILESET CLASS-----------------------------------------------------------------------------------------------------------------------------------------------------
  private class TileSet extends Thread{
    File tileSetDir; //Directory of the tile set
    String name="";//name of the tileset
    String description="";//description of the tileset  
    ArrayList<BaseTile> tiles = new ArrayList<BaseTile>();
    boolean loaded = false;
    
    public TileSet(File tileSetDir){
      this.tileSetDir = tileSetDir;
      start();
    }
    
    //called by start() in a new thread
    public void run(){
      try{
        println("Loading "+tileSetDir.getPath()+"...");
        LoadTileSet();
        loaded = true;
      }
      catch(NullPointerException e){
        println(e);
        tileSetDir = new File("data/TileSets/Default");
        println("Loading default tile set...");
        LoadTileSet();
      }
    }
    
    public void LoadTileSet(){
      JSONObject setConfig; //json file of tileSet config
      JSONArray tileArr = null; //json array with all tile info
      
      //get JSONObject tileset/config.json
      try {
        //nightmare trying to get the right path, should identify config.json inside of tileSet folder
        setConfig = loadJSONObject(sketchPath() + "\\" + new File(tileSetDir.getPath()+"\\config.json"));
      } catch (NullPointerException e){
        throw(new NullPointerException(tileSetDir.getPath()+"\\config.json is missing or inaccessible."));
      }
      
      //read JSONObject to get info & tiles
      if(!setConfig.isNull("name")) name = setConfig.getString("name");
      if(!setConfig.isNull("description")) description = setConfig.getString("description");
      if(!setConfig.isNull("tiles")) tileArr=setConfig.getJSONArray("tiles");
      else{
        throw(new NullPointerException(tileSetDir.getPath() + "\\config.json does not contain any tiles."));
      }
      println("Reading tile set:\n  "+name+" - "+description);
      
      //add tiles to ArrayList
      for(int i=0; i<tileArr.size(); i++){
        BaseTile tile = new BaseTile(tileArr.getJSONObject(i), tileSetDir);
        println("  "+tile);
        tiles.add(tile);
      }
      //create duplicates for mirrorable tiles
      for(int i=tiles.size()-1; i>=0; i--){
        //mirror horizontally
        if(tiles.get(i).mirrorX){
          BaseTile t = tiles.get(i).mirrorX();
          println("  "+t);
          tiles.add(t);
        }
      }
      for(int i=tiles.size()-1; i>=0; i--){
        //mirror horizontally
        if(tiles.get(i).mirrorY){
          BaseTile t = tiles.get(i).mirrorY();
          println("  "+t);
          tiles.add(t);
        }
      }
      for(int i=tiles.size()-1; i>=0; i--){
        //rotates - 4 times, or only once for mirrorX & mirrorY=true
        if(tiles.get(i).rotate){
          BaseTile t = tiles.get(i);
          if(t.mirrorX && t.mirrorY == true){
            t = t.rotate(1);
            println("  "+t);
            tiles.add(t);
          }
          else{
            for(int r=1; r<4; r++){
              BaseTile rT = t.rotate(r);
              println("  "+rT);
              tiles.add(rT);
            }
          }
        }
      }
      //correct symmetrical sockets
      Set<Integer> evenSockets = new HashSet<Integer>();
      if(!setConfig.isNull("sockets")){
        JSONArray sockets = setConfig.getJSONArray("sockets");
        for(int i=0; i<sockets.size(); i++){
          if((!sockets.getJSONObject(i).isNull("id")) && (!sockets.getJSONObject(i).isNull("symmetry"))){
            if(sockets.getJSONObject(i).getBoolean("symmetry")){
              evenSockets.add(sockets.getJSONObject(i).getInt("id"));
            }
          }
        }
      }
      for(BaseTile t:tiles){
        if(t.edgeUp<0 && evenSockets.contains(abs(t.edgeUp))) t.edgeUp = abs(t.edgeUp);
        if(t.edgeDown<0 && evenSockets.contains(abs(t.edgeDown))) t.edgeDown = abs(t.edgeDown);
        if(t.edgeLeft<0 && evenSockets.contains(abs(t.edgeLeft))) t.edgeLeft = abs(t.edgeLeft);
        if(t.edgeRight<0 && evenSockets.contains(abs(t.edgeRight))) t.edgeRight = abs(t.edgeRight);
      }
      //sort tiles by id
      Collections.sort(tiles);
      
      //Generate neighbors
      for(BaseTile t:tiles) t.generateNeighbors(tiles);
      //println(this);
    }
    
    public BaseTile get(int index) throws IndexOutOfBoundsException{
      return tiles.get(index);
    }
    
    public List<BaseTile> parents(){
      //returns an arraylist of all tiles w/o parents
      ArrayList<BaseTile> parents = new ArrayList<BaseTile>();
      for(BaseTile t:tiles){
        if(!t.hasParent()) parents.add(t);
      }
      return parents;
    }
    public List<BaseTile> children(){
      //returns an arraylist of all tiles with parents
      ArrayList<BaseTile> parents = new ArrayList<BaseTile>();
      for(BaseTile t:tiles){
        if(t.hasParent()) parents.add(t);
      }
      return parents;
    }
    
    public String toString(){
      String out = name + "\n" + description;
      for(BaseTile t:tiles){
        out += "\n  " + t;
      }
      return out;
    }
    
    public Set getTileSet(){
      if(!loaded) return null;
      Set<BaseTile> newTileSet = new HashSet<BaseTile>();
      for(BaseTile t:tiles){
        newTileSet.add(t);
      }
      return newTileSet;
    }
    
  }
    
  //TILE CLASS-----------------------------------------------------------------------------------------------------------------------------------------------------  
    
  public class BaseTile implements Comparable<BaseTile>{
    //individual tile data, including image texture and what tiles it can connect to
    protected int id = 0; //value to identify the Tile type
    protected String name = "";
    protected int weight = 1; //probability weight to choose this tile if eligble
    protected PImage[] textures; //images to display for the tile [null.png default]
    protected int[] textureWeight; //probability to display each texture for the tile to display [lenght = textures.length]
    protected int edgeUp = 0; //{type of link that can be made on the top side, bool - if the tile face can be mirrored and still connect}
    protected int edgeDown = 0;//link on bottom side, symmetry bool
    protected int edgeLeft = 0;//link on left side, symmetry bool
    protected int edgeRight = 0;//link on right side, symmetry bool
    protected boolean mirrorX = false;//can create a child Tile by mirroring horizontally
    protected boolean mirrorY = false;//can create a child Tile by mirroring vertically
    protected boolean rotate = false;//can create a child Tile by rotating
    
    protected BaseTile parent = null; //if the tile is a mirrored version of another, parent is the original
    protected Set<BaseTile>[] neighbors = new HashSet[4]; //set of all tiles that can be adjacent to this tile
    public final static int UP=0, DOWN=1, LEFT=2, RIGHT=3;
    
    public BaseTile(JSONObject tileObject, File tileSetDir){
      //reading values
      if(!tileObject.isNull("id")) id = tileObject.getInt("id");
      if(!tileObject.isNull("name")) name = tileObject.getString("name");
      if(!tileObject.isNull("weight")) weight = tileObject.getInt("weight");
      //read texture image values
      try{
        JSONObject texture = tileObject.getJSONObject("texture");
        setTexture(tileSetDir +"\\"+ texture.getString("source"), texture.getInt("tiles"),texture.getJSONArray("weight").getIntArray());
      }
      catch(Exception e){
        println(e);
        setTexture("data/TileSets/Default/null.png",1,new int[]{1});
      }
      //read socket values
      if(!tileObject.isNull("edges")){
        JSONObject edges = tileObject.getJSONObject("edges");
        if(!edges.isNull("up"))edgeUp = edges.getInt("up");
        if(!edges.isNull("down")) edgeDown = edges.getInt("down");
        if(!edges.isNull("left")) edgeLeft = edges.getInt("left");
        if(!edges.isNull("right")) edgeRight = edges.getInt("right");
      }
      //read mirroring rules
      if(!tileObject.isNull("mirrorX")) mirrorX = tileObject.getBoolean("mirrorX");
      if(!tileObject.isNull("mirrorY")) mirrorY = tileObject.getBoolean("mirrorY");
      if(!tileObject.isNull("rotate")) rotate = tileObject.getBoolean("rotate");
      //rotate=false;
    }
    
    public void setTexture(String imgPath, int tiles, int[] weight){
      PImage texture = loadImage(imgPath);
      textures = new PImage[tiles];
      textureWeight = new int[tiles];
      for(int i=0; i<tiles; i++){
        textures[i] = texture.get(i*texture.width/tiles,0,texture.width/tiles,texture.height);
        //textures[i].save("text"+i+".png");  //use for testing
        if(i<weight.length) textureWeight[i]=weight[i];
        else textureWeight[i]=1;
      }
    }
    
    public PImage getTexture(int index) throws ArrayIndexOutOfBoundsException{
      //returns A COPY of the specified texture image, BLURS IF THE IMAGE IS SMALLER THAN DISPLAYED
      return textures[index].copy();
    }
    public PImage getTexture(int index, int size){
      //returns A COPY of the specified texture image, resized
      PImage copy = textures[index].copy();
      copy = flatResize(copy,size);
      return copy;
    }
    
    public boolean hasParent(){
      //returns if Tile has a parent
      return parent!=null;
    }
    
    //-----------------------------
    //Tile Duplication - creates another baseTile with the same variable VALUES
    public BaseTile(BaseTile t){
      id=t.id;
      name=t.name;
      weight=t.weight;
      textures=new PImage[t.textures.length];
      for(int i=0; i<t.textures.length; i++){
        textures[i] = t.textures[i].copy();
      }
      textureWeight=t.textureWeight.clone();
      edgeUp=t.edgeUp;
      edgeDown=t.edgeDown;
      edgeLeft=t.edgeLeft;
      edgeRight=t.edgeRight;
      mirrorX=t.mirrorX;
      mirrorY=t.mirrorY;
      rotate=t.rotate;
      if(t.parent==null) parent=t;
      else parent = t.parent;
    }
    public BaseTile mirrorX(){
      //create a duplicate tile mirrored horizontally
      BaseTile t = new BaseTile(this);
      t.mirrorHorizontal();
      return t;
    }
    public BaseTile mirrorY(){
      //create a duplicate tile mirrored vertically
      BaseTile t = new BaseTile(this);
      t.mirrorVertical();
      return t;
    }
    public BaseTile rotate(int rotations){
      BaseTile t = new BaseTile(this);
      for(int i=0; i<rotations; i++)
        t.rotate();
      return t;
    }
    private void mirrorHorizontal(){
      edgeUp = -edgeUp;
      edgeDown = -edgeDown;
      int tempEdge = edgeLeft;
      edgeLeft = edgeRight;
      edgeRight = tempEdge;
      //mirror image
      for(int i=0; i<textures.length; i++){
        PImage mirror = createImage(textures[i].width,textures[i].height,ARGB);
        for(int x=0; x<mirror.width; x++){
          for(int y=0; y<mirror.height; y++){
            mirror.set(x,y,textures[i].get(textures[i].width-1-x,y));
          }
        }
        textures[i] = mirror;
      }
    }
    private void mirrorVertical(){
      int tempEdge = edgeUp;
      edgeUp = edgeDown;
      edgeDown = tempEdge;
      edgeLeft = -edgeLeft;
      edgeRight = -edgeRight;
      //mirror image
      for(int i=0; i<textures.length; i++){
        PImage mirror = createImage(textures[i].width,textures[i].height,ARGB);
        for(int x=0; x<mirror.width; x++){
          for(int y=0; y<mirror.height; y++){
            mirror.set(x,y,textures[i].get(x,textures[i].height-1-y));
          }
        }
        textures[i] = mirror;
      }
    }
    private void rotate(){
      //rotates Tile 90 degrees clockwise
      int tempEdge = edgeLeft;
      edgeLeft = edgeDown;
      edgeDown = -edgeRight;
      edgeRight = edgeUp;
      edgeUp = -tempEdge;
      //rotate image
      for(int i=0; i<textures.length; i++){
        PImage mirror = createImage(textures[i].height,textures[i].width,ARGB);
          for(int x=0; x<textures[i].width; x++){
            for(int y=0; y<textures[i].height; y++){
              mirror.set(mirror.width-1-y,x,textures[i].get(x,y));
            }
          }
        textures[i] = mirror;
      }
    }
    
    private void generateNeighbors(ArrayList<BaseTile> tiles){
      neighbors[UP] = new HashSet<BaseTile>();
      neighbors[DOWN] = new HashSet<BaseTile>();
      neighbors[LEFT] = new HashSet<BaseTile>();
      neighbors[RIGHT] = new HashSet<BaseTile>();
      
      for(BaseTile t:tiles){
        if(edgeUp == t.edgeDown) neighbors[UP].add(t);
        if(edgeDown == t.edgeUp) neighbors[DOWN].add(t);
        if(edgeLeft == t.edgeRight) neighbors[LEFT].add(t);
        if(edgeRight == t.edgeLeft) neighbors[RIGHT].add(t);
      }
    }
    
    //------------
    public int compareTo(BaseTile t){
      if(id!=t.id) return id - t.id;
      if(!name.equals(t.name)) return name.compareTo(t.name);
      return (this == t) ? 0 : -1;
    }
    public String toString(){
      return "up: "+edgeUp + "\tdown: "+edgeDown + "\tleft: "+edgeLeft + "\tright: "+edgeRight + "\tid: "+id+"\t"+name +(parent!=null?"*":"");
    }
  }
  
  //TILE CLASS----DIFFERENT FROM BASETILE------------------------------------------------------------------------------------------------------------------------------
  //public class Tile implements Comparable<Tile>{
  //  private BaseTile parent;
    
  //  public  Tile(BaseTile tileParent){
  //    parent = tileParent;
  //  }
    
  //  public int compareTo(Tile t){
  //    return parent.compareTo(t.parent);
  //  }
  //}
  
  
  
  //USEFUL METHODS-----------------------------------------------------------------------------------------------------------------------------------------------------
  public PImage flatResize(PImage img, int size){
    //resizes a PImage so that pixels are not blurred when expanding
    PImage copy = img.copy();
    if(copy.width>=size) copy.resize(size,size);
    else{
      PImage strech = createImage(size,copy.height,ARGB);
      for(int x=0; x<strech.width; x++){
        strech.set(x,0,copy.get(copy.width*x/strech.width,0,1,strech.height));
      }
      copy=strech;
    }
    if(copy.height>=size) copy.resize(size,size);
    else{
      PImage strech = createImage(copy.width,size,ARGB);
      for(int y=0; y<strech.height; y++){
        strech.set(0,y,copy.get(0,copy.height*y/strech.height,strech.width,1));
      }
      copy=strech;
    }
    return copy;
  }
  //DEBUG METHODS-----------------------------------------------------------------------------------------------------------------------------------------------------
  //class for debugging
  /*
    Instructions:
    call debug() to activate, or debug(int) for a specific tile display size
    Pressing keys 1-9 will display different info
    Display Screens:
    1.All possible tiles (including textures)
      mainly there to make sure the translations work
    2.Tile adjacencies (spelling?)
      will display a center tile and possible neighboring tiles on each face
      Press 'q' to cycle the center tile
      Press 'w','a','s', or 'd' to cycle adjacent tiles
      Press shift + q/w/a/s/d to cycle textures
      Press ' ' to randomize tiles (null tile excluded)
      Press 'e' to randomize textures
    
  */
  Debug debug = new Debug();
  public void debug(){debug(12);}
  public void debug(int tileSize){
    debug.tileSize=tileSize;
    PApplet.runSketch(new String[]{""},debug);
  }
  public class Debug extends PApplet{
    public int tileSize = 12;
    public int display=0;
    //PApplet stuff
    PImage debugTiles;
    
    @Override
    void settings(){
      debugTiles = debugTiles(tileSize);
      int debugH = tileSize * int((displayHeight-100)/tileSize);
      if(debugTiles.height < debugH) debugH=debugTiles.height;
      size(debugTiles.width * (1 + (int)debugTiles.height/(displayHeight-100)),debugTiles.height);
      println(height);
    }
    
    void setup(){
      //surface.setResizable(true);
    }
    
    void draw(){
      background(#CCCCCC);
      switch(display){
        case 0:
          image(debugTiles,0,0);
          if(debugTiles.height>height){
            int tempY = debugTiles.height-height;
            int shifts = 1;
            while(tempY > 0){
              image(debugTiles.get(0,debugTiles.height-tempY,debugTiles.width,debugTiles.height),debugTiles.width*shifts,0);
              shifts++;
              tempY = debugTiles.height - shifts*height;
            }
          }
        break;
        case 1:
          drawAdjacent();
        break;
      }
    }
    
    void keyTyped(){
      switch(key){
        case '1':
          display=0;
          int debugH = tileSize * int((displayHeight-100)/tileSize);
          if(debugTiles.height < debugH) debugH=debugTiles.height;
          surface.setSize(debugTiles.width * (1 + (int)debugTiles.height/(displayHeight-100)),debugTiles.height);
        break;
        case '2':
          display=1;
          surface.setSize(tileSize*3,tileSize*3);
        break;
      }
      switch(display){
        case 1:
          if(key=='q') tileIndex[0][0]++;
          if(key=='w') tileIndex[1][0]++;
          if(key=='s') tileIndex[2][0]++;
          if(key=='a') tileIndex[3][0]++;
          if(key=='d') tileIndex[4][0]++;
          
          if(key=='Q') tileIndex[0][1]++;
          if(key=='W') tileIndex[1][1]++;
          if(key=='S') tileIndex[2][1]++;
          if(key=='A') tileIndex[3][1]++;
          if(key=='D') tileIndex[4][1]++;
          if(key== ' '){
          for(int i=0; i<tileIndex.length; i++) //<>//
            for(int j=0; j<tileIndex[i].length; j++)
              tileIndex[i][j]=(int)random(0,100);
            if(tileIndex[0][0]%tileSet.tiles.size()==0) tileIndex[0][0]++;
          }
          if(key=='e'){
            for(int i=0; i<tileIndex.length; i++){
              tileIndex[i][1]=(int)random(0,100);
            }
          }
        break;
      }
    }
    
    public PImage debugTiles(int tileSize /*pixel height of each tile texture*/){
      //Create an image with all tiles and variations
      List<BaseTile> parents = tileSet.parents();
      ArrayList<BaseTile> tileGroups[] = new ArrayList[parents.size()];
      for(int i=0; i<parents.size(); i++){
        tileGroups[i] = new ArrayList<BaseTile>();
        tileGroups[i].add(parents.get(i));
      }
      for(BaseTile t:tileSet.children()){
        for(ArrayList<BaseTile> group:tileGroups){
          if(t.parent == group.get(0)){
            group.add(t);
          }
        }
      }
      int tileTextures = 0;
      for(ArrayList<BaseTile> tileGroup:tileGroups){
        tileTextures += tileGroup.get(0).textures.length;
      }
      PImage[][] textures = new PImage[tileTextures][];
      int textureIndex=0;
      for(int i=0; i<tileGroups.length; i++){
        for(int j=0; j<tileGroups[i].get(0).textures.length; j++){
          textures[textureIndex] = new PImage[tileGroups[i].size()];
          for(int k=0; k<tileGroups[i].size(); k++){
            textures[textureIndex][k] = tileGroups[i].get(k).textures[j].copy();
            textures[textureIndex][k] = flatResize(textures[textureIndex][k],tileSize);
          }
          textureIndex++;
        }
      }
      
      //draw tiles in img
      PImage img = createImage(8*tileSize,tileTextures*tileSize,ARGB);
      for(int r=0; r<textures.length; r++){
        for(int c=0; c<textures[r].length; c++){
          img.set(c*tileSize, r*tileSize, textures[r][c]);
        }
      }
       //<>//
      return img;
    }
    
    
    int[][] tileIndex = {{0,0},{0,0},{0,0},{0,0},{0,0}};
    void drawAdjacent(){
      ArrayList<WorldGen.BaseTile> tiles = tileSet.tiles;
      image(tiles.get(tileIndex[0][0]%tiles.size()).getTexture(tileIndex[0][1]%tiles.get(tileIndex[0][0]%tiles.size()).textures.length,width/3),width/3,height/3,width/3+1, height/3+1);
      
      Set<WorldGen.BaseTile> set = tiles.get(tileIndex[0][0]%tiles.size()).neighbors[0];
      WorldGen.BaseTile t = set.toArray(new WorldGen.BaseTile[0])[tileIndex[1][0]%set.size()];
      image(t.getTexture(tileIndex[1][1]%t.textures.length,width/3),width/3,0,width/3,height/3);
      
      set = tiles.get(tileIndex[0][0]%tiles.size()).neighbors[1];
      t = set.toArray(new WorldGen.BaseTile[0])[tileIndex[2][0]%set.size()];
      image(t.getTexture(tileIndex[2][1]%t.textures.length,width/3),width/3,2*height/3,width/3,height/3+1);
      
      set = tiles.get(tileIndex[0][0]%tiles.size()).neighbors[2];
      t = set.toArray(new WorldGen.BaseTile[0])[tileIndex[3][0]%set.size()];
      image(t.getTexture(tileIndex[3][1]%t.textures.length,width/3),0,height/3,width/3,height/3);
      
      set = tiles.get(tileIndex[0][0]%tiles.size()).neighbors[3];
      t = set.toArray(new WorldGen.BaseTile[0])[tileIndex[4][0]%set.size()];
      image(t.getTexture(tileIndex[4][1]%t.textures.length,width/3),2*width/3,height/3,width/3+1,height/3); 
    }
  }
}
