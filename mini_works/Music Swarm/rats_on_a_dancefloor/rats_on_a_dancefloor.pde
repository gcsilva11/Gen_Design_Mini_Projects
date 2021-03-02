Flock flock;
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;  
AudioPlayer jingle;
FFT fftLin;
FFT fftLog;

float height3;
float height23;
float height5;
float width6;
float spectrumScale = 4;
int xoffset = 20;
int yoffset = 15;
int sensability = 30;
int lightcounter = 0;
int timecounter = 0;
boolean lockout = false;
int react = 0;

/*
253, 255, 107 = YELLOW
100, 227, 102 = GREEN
87, 215, 217  = BLUE
235, 103, 156 = PINK
*/

float [][][] colors = {{{207, 46, 31},{171, 79, 201},{235, 103, 156},{79, 110, 209},{100, 227, 102},{253, 255, 107}},
                    {{100, 227, 102},{207, 46, 31},{171, 79, 201},{235, 103, 156},{79, 110, 209},{100, 227, 102}},
                    {{100, 227, 102},{253, 255, 107},{207, 46, 31},{171, 79, 201},{235, 103, 156},{79, 110, 209}},
                    {{100, 227, 102},{100, 227, 102},{253, 255, 107},{207, 46, 31},{171, 79, 201},{235, 103, 156}},
                    {{235, 103, 156},{79, 110, 209},{100, 227, 102},{253, 255, 107},{207, 46, 31},{171, 79, 201}},
                    {{171, 79, 201},{235, 103, 156},{79, 110, 209},{100, 227, 102},{253, 255, 107},{207, 46, 31}}};

void setup() {
  fullScreen(P2D);
  background(0);
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 300; i++) {
    flock.addBoid(new Boid(width/2,height/2));
  }
  
  height3 = height/3;
  height23 = 2*height/3;
  height5 = height/5;
  width6 = width/6;

  minim = new Minim(this);
  jingle = minim.loadFile("bois.mp3", 1024);
  jingle.loop();
  
  fftLin = new FFT( jingle.bufferSize(), jingle.sampleRate() );
  
  fftLin.linAverages( 30 );
  fftLog = new FFT( jingle.bufferSize(), jingle.sampleRate() );
  rectMode(CORNERS);
  
  
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      sensability = sensability + 5;
    } else if (keyCode == DOWN) {
      sensability = sensability - 5;
    } else if (keyCode == LEFT) {
      if(react > 0){
        react = react - 1;
      }
    } else if (keyCode == RIGHT) {
      if(react <= 25){
        react = react + 1;
      }
    } 
  }
}

void draw() {
  
  background(0);
  fftLin.forward(jingle.mix);
  fftLog.forward(jingle.mix);
  noStroke();
  
    for(int i = 0; i < 6; i++){  
      for(int j=0; j<6; j++){
        float squareOffset = fftLin.getAvg(i+j) * sensability;
        if(squareOffset > 100){
          //fill(colors[i][j][0],colors[i][j][1],colors[i][j][2], 255);
        }
        else{
          fill(colors[i][j][0]+20,colors[i][j][1]+20,colors[i][j][2]+20, 50);
          rect((width6*i)+10, (height5*j)-height5+10, (width6*i)+width6-10, (height5*j)-10);
        }
          fill(colors[i][j][0],colors[i][j][1],colors[i][j][2], 50);
          rect((width6*i)+10, (height5*j)-height5+10, (width6*i)+width6-10, (height5*j)-10);
          fill(colors[i][j][0]+20,colors[i][j][1]+20,colors[i][j][2]+20, squareOffset);
          rect((width6*i)+20, (height5*j)-height5+20, (width6*i)+width6-20, (height5*j)-20);
        }
      
    }
    print(react);
  flock.run();
}

/*
// Add a new boid into the System
void mousePressed() {
  flock.addBoid(new Boid(mouseX,mouseY));
}



if(!lockout){
  lightcounter = lightcounter + 1;
    if (lightcounter > 6){
      lightcounter = 0;
      lockout = true;
    }
}

print(lockout);

timecounter = timecounter + 1;
if(timecounter == 3000){
  timecounter = 0;
  lockout = false;
}

*/


// The Flock (a list of Boid objects)

class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

}

// The Boid class

class Boid {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

    Boid(float x, float y) {
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    position = new PVector(x, y);
    r = 5.0;
    maxspeed = 2;
    maxforce = 0.03;
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    
    sep.mult(fftLin.getAvg(0)*20);
    ali.mult(fftLin.getAvg(react)*5);
    coh.mult(fftLin.getAvg(0)*0.005);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
    
    fill(random(0,255),random(0,255),random(0,255));
    stroke(255);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } 
    else {
      return new PVector(0, 0);
    }
  }
}
