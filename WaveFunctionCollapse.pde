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
  
}

void draw(){
}

void keyPressed(){
  if(key=='d') world.debug(24);
  if(key=='c') world.createWorld(10,10);
}
