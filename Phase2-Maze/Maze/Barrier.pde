class Barrier{
  /**
  * Creates an Actuator using motor port position 1
  */  
  int wallNumber = 10;
  FBox[] wall = new FBox[wallNumber];
  
  public Barrier(){
    
  }
  
  public void add(FWorld world){
    println ("#inside barrier");
    //outer walls
    wall[0]                  = new FBox(21.5, 0.6);
    wall[0] .setPosition(worldWidth-11.5, worldHeight/2-3.75); 
    wall[1]                   = new FBox(0.6, 8.5);
    wall[1] .setPosition(worldWidth/2-10, worldHeight/2+0.2); 
    wall[2]                   = new FBox(11, 0.6);
    wall[2] .setPosition(worldWidth/2-4.8, worldHeight/2+4.6); 
    wall[3]                   = new FBox(7, 0.6);
    wall[3] .setPosition(worldWidth-4.27, worldHeight/2+4.6); 
    
    //inner walls
    wall[4]                   = new FBox(0.6, 2);
    wall[4] .setPosition(worldWidth-7.05, worldHeight/2.0+3.8); 
    wall[5]                   = new FBox(13.5, 0.6);
    wall[5] .setPosition(worldWidth/2-1, worldHeight/2+2.6);
    wall[6]                   = new FBox(0.6, 4);
    wall[6] .setPosition(worldWidth/2-4.5, worldHeight/2+0.5);
    wall[7]                   = new FBox(0.6, 4.5);
    wall[7] .setPosition(worldWidth/2-7.5, worldHeight/2-1.5);
    wall[8]                   = new FBox(13.5, 0.1);
    wall[8] .setPosition(worldWidth/2-4.96, worldHeight/2-5.3);
    wall[9]                   = new FBox(0.6, 4);
    wall[9] .setPosition(worldWidth-7.05, worldHeight/2.0-2);
    
    
    for (FBox element : wall) { 
      element.setFill(153,190,27);
      element.setNoStroke();
      element.setStaticBody(true);
      world.add(element);
    }
  }
  
  public void hideWalls(){
    for (FBox element : wall) { 
      element.setFill(255,255,255);
    }
  }
  
  public void showWalls(){
    for (FBox element : wall) { 
      element.setFill(153,190,27);
    }
  }
}
