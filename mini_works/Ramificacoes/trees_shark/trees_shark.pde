PImage animal;

void setup() {
  size(840,1100);
  background(19, 50, 66,255);
  animal = loadImage("shark.png");
  imageMode(CENTER);
  image(animal, width/2, height/2, width/2, height/2);
  colorMode(RGB);
  fill(255,255,255,255);
  noStroke();
  smooth();
  noLoop();
}

void draw_tree(float x,float y,float ang,float size) {
  float angle_bias = 0.2;
  float true_bias = angle_bias * random(-1,1);
  ang = ang + true_bias;
  float dx = x+cos(ang)*size*random(3,3.2);
  float dy = y+sin(ang)*size*random(3,3.2);
  stroke(173, 220, 255, size*15);
  noFill();
  if(get(int(dx),int(dy)) != color(19,50,69)){
     circle(dx, dy, size);
     fill(255,255,255);
     circle(dx+1, dy-1, size/10);
  }
  if(size>2){ 
    if (random(0,100) <= 11){
       draw_tree(dx, dy, ang + PI/10, size*0.98);
       draw_tree(dx, dy, ang - PI/10, size*0.98);
      
    }
    else{
      draw_tree(dx, dy, ang, size*0.98);
    }
      
  }
  else{
      return;
    }
}

void draw(){
   float size = 15;
   float posx =  width;
   float posy =  height;
   
   draw_tree(posx/2 + posx/4,posy,6 * (PI/4), size);
   draw_tree(posx/2 + posx/6,posy,6 * (PI/4), size);
   draw_tree(posx/2,posy,6 * (PI/4), size);
   draw_tree(posx/4,posy,6 * (PI/4), size);
   draw_tree(posx/6,posy,6 * (PI/4), size);
   //imageMode(CENTER);
   //image(animal, width/2, height/2, width/5, height/3);
   save("owlposter.png");
}
