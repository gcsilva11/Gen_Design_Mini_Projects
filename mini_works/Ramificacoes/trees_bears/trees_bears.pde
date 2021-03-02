PImage animal;

void setup() {
  size(840,1100);
  background(93, 150, 240,255);
  animal = loadImage("bear.png");
  imageMode(CENTER);
  image(animal, width/2, height/2, width/2, height/5);
  colorMode(RGB);
  fill(255,255,255,255);
  noStroke();
  smooth();
  noLoop();
}

void draw_tree(float x,float y,float ang,float size) {
  float dx = x+cos(ang)*size*random(1,1.4);
  float dy = y+sin(ang)*size*random(1,1.4);
  fill(255,255,255, size*20);
  if(get(int(dx),int(dy)) != color(94,151,242)){
     circle(dx, dy, size);
  }
  if(size>2){ 
    if (random(0,100) <= 10){
       draw_tree(dx, dy, ang + PI/4, size*0.98);
       draw_tree(dx, dy, ang - PI/4, size*0.98);
       draw_tree(dx, dy, ang + 3 * PI/4, size*0.98);
       draw_tree(dx, dy, ang - 3 *PI/4, size*0.98);
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
   float size = 3;
   float posx =  width;
   float posy =  height;
   
   for (int i = 0; i < 700; i = i+1) {
      draw_tree(random(0,posx),random(0,posy),random(0,8)*(PI/4), size);
      //draw_tree(random(0,posx),random(posy/2,posy),random(0,8)*(PI/4), size);
      if(random(0,100)<20){
        draw_tree(random(0,posx),random(posy/2-posy/12,posy/2+posy/10),random(0,8)*(PI/4), size);
      }
      
      draw_tree(random(0,posx),random(posy/2+posy/14,posy),random(0,8)*(PI/4), size);
      draw_tree(random(0,posx),random(posy/2+posy/14,posy),random(0,8)*(PI/4), size);
  }
   //imageMode(CENTER);
   //image(animal, width/2, height/2, width/5, height/3);
   save("owlposter.png");
}
