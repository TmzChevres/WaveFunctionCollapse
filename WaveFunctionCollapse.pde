WorldGen world = new WorldGen(new File("data/TileSets/Circuit"));
PImage test;
float[] frmRt;
float[] dbgRt;

void settings(){
  size(200,200);
  //SIZE MUST BE SET IN SETTINGS() - IDK WHY
}
void setup(){
  //size(200,200);
  rectMode(CORNERS);
  println("Parents: "+world.tileSet.parents().size()+"\nChildren: "+world.tileSet.children().size());
  textAlign(RIGHT,BOTTOM);
  fill(#000000);
  frmRt=new float[width];
  dbgRt=new float[width];
}

void draw(){
  //draw frame rate
  background(#CCCCCC);
  stroke(#AAAAAA);
  for(int i=height; i>=height-90; i-=30){
    line(0,i,width,i);
  }
  //frame rate
  stroke(#000000);
  for(int i=0; i<frmRt.length-1; i++){
    frmRt[i]=frmRt[i+1];
    point(i,height-frmRt[i]);
  }
  frmRt[width-1]=frameRate;
  point(width-1,height-frameRate);
  //debug frame rate
  if(load){
    stroke(#FF0000);
    for(int i=0; i<dbgRt.length-1; i++){
      dbgRt[i]=dbgRt[i+1];
      point(i,height-dbgRt[i]);
    }
    dbgRt[width-1]=world.debug.frameRate;
    point(width-1,height-world.debug.frameRate);
  }
  
  text(frameRate,width,height);
}

boolean load=false;
void keyPressed(){
  if(key==' '){
    if(!load){
      world.createWorld(50,50);
      world.debug(96);
      load=true;
    }
    else world.generateWorld();
  }
  if(key=='1') world.restrictTile(1,1,world.getTileSetByID(5));
  if(key=='2') world.restrictTile(2,2,world.getTileSetByName("dirt, grass corner"));
  if(key=='3') world.restrictTile(3,3,world.getTileSetByEdge(1,0,0,2));
  if(key=='4') world.restrictTile(4,4,world.getTileSetByEdgeUp(3));
  if(key=='5') world.restrictTile(5,5,world.getTileSetByEdgeDown(3));
  if(key=='6') world.restrictTile(6,6,world.getTileSetByEdgeLeft(3));
  if(key=='7') world.restrictTile(7,7,world.getTileSetByEdgeRight(3));
  if(key=='8') world.restrictTile(8,8,world.getTileSet(2,-2,0,-2,1));
  if(key=='9') world.generateTile(9,9);
  
  if(keyCode==DELETE || keyCode==BACKSPACE){
    world.createWorld(world.map.size(),world.map.get(0).size());
  }
}
