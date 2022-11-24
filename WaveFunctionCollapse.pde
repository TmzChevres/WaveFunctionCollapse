WorldGen world = new WorldGen(new File("data/TileSets/Default"));
PImage test;

void settings(){
  size(200,200);
  //SIZE MUST BE SET IN SETTINGS() - IDK WHY
}
void setup(){
  //size(200,200);
  rectMode(CORNERS);
  println(world.tileSet.parents().size(),world.tileSet.children().size());
  textAlign(RIGHT,BOTTOM);
  fill(#000000);
}

void draw(){
  background(#CCCCCC);
  text(frameRate,width,height);
}

void keyPressed(){
  if(key=='d') world.debug(96);
  if(key=='c') world.createWorld(10,10);
  if(key=='1') world.restrictTile(0,0,world.getTileSetByID(5)); //<>//
  if(key=='2') world.restrictTile(1,0,world.getTileSetByName("dirt, grass corner"));
  if(key=='3') world.restrictTile(2,0,world.getTileSetByEdge(3,0,0,-2));
  if(key=='4') world.restrictTile(3,0,world.getTileSetByEdgeUp(3));
  if(key=='5') world.restrictTile(4,0,world.getTileSetByEdgeDown(3));
  if(key=='6') world.restrictTile(5,0,world.getTileSetByEdgeLeft(3));
  if(key=='7') world.restrictTile(6,0,world.getTileSetByEdgeRight(3));
  if(key=='8') world.restrictTile(7,0,world.getTileSet(2,2,0,1,-2));
}
