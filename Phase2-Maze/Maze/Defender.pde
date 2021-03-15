class Defender{
  // Variables.
   float theta =0.0;
  
  public Defender(){
   
  }
  
  // Function.  
  void moveHorizontal(float horizontalDistance, float verticalDistance, float speed) {  
    // The output of the sin() function oscillates smoothly between 1 and 1. 
    // By adding 1 we get values between 0 and 2. 
    // By multiplying by 100, we get values between 0 and 200 which can be used as the ellipse's x location.
    float x = horizontalDistance+(sin(theta) + 1) * speed; 
  
    // With each cycle, increment theta
    theta += 0.05;
  
    // Draw the ellipse at the value produced by sine
    fill(171,92,88);
    stroke(0);
    //FCircle c = new FCircle(32);
    //c.setDensity(12);
    //c.setPosition(x, height/2);
    
    ellipse(x, verticalDistance, 32, 32);
    
  }
  
  
  void moveVertical(float horizontalDistance, float verticalDistance, float speed) { 
    
    float x = verticalDistance+(sin(theta) + 1) * speed; 
  
    // With each cycle, increment theta
    theta += 0.05;
  
    // Draw the ellipse at the value produced by sine
    fill(171,92,88);
    stroke(0);
    //FCircle c = new FCircle(32);
    //c.setDensity(12);
    //c.setPosition(x, height/2);
    
    ellipse(horizontalDistance, x , 32, 32);
      
  }
}
