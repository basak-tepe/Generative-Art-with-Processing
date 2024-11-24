int numParticles = 50;
float strength = 0.01;  // Attraction toward the center
float swirlSpeed = 0.05;  
float maxRadius = 400;  // Max init distanc

color[] sunflowerPalette = {
  color(245, 213, 91, 200),  
  color(238, 180, 47, 200),  
  color(188, 127, 34, 200),  
  color(112, 87, 54, 200),   
  color(154, 187, 119, 200), 
  color(78, 60, 32, 200)     
};

Particle[] particles;

void setup() {
  size(1200, 800);
  particles = new Particle[numParticles];
  
  // Init particles in random pos
  for (int i = 0; i < numParticles; i++) {
    float angle = random(TWO_PI);
    float radius = random(50, maxRadius);
    float x = width / 2 + cos(angle) * radius;
    float y = height / 2 + sin(angle) * radius;
    color col = sunflowerPalette[int(random(sunflowerPalette.length))];
    particles[i] = new Particle(x, y, angle, radius, col);
  }
}

void draw() {
  background(0);

  for (int i = 0; i < numParticles; i++) {
    particles[i].update();
    particles[i].display();
  }
  
  // save ss
  if (keyPressed) {
    saveFrame("screenshot-####.png");
  }
}

class Particle {
  float x, y;  // current pos
  float angle;  // direction
  float radius;  
  color col;  // color
  ArrayList<PVector> path;  // path tracking
  
  Particle(float startX, float startY, float startAngle, float startRadius, color particleColor) {
    x = startX;
    y = startY;
    angle = startAngle;
    radius = startRadius;
    col = particleColor;
    path = new ArrayList<PVector>();  
    path.add(new PVector(x, y));  
  }
  
  void update() {
   
    float dx = x - width / 2;
    float dy = y - height / 2;
    float distance = sqrt(dx * dx + dy * dy);
    
   
    float attractionForce = strength * (1 / (distance + 10));
    
    // apply force
    x -= cos(atan2(dy, dx)) * attractionForce;
    y -= sin(atan2(dy, dx)) * attractionForce;
    
    // swirl
    angle += swirlSpeed * (distance / maxRadius);  // Faster swirl for outer particles
    
    // pos update
    float fx = cos(angle) * 1;  // Circular motion in X
    float fy = sin(angle) * 1;  // Circular motion in Y
    
    // Gradual inward motion (reduce the radius over time)
    radius -= 0.1;  
    
    // Update particle pos
    x += fx;
    y += fy;
    
    path.add(new PVector(x, y));
    
    // screen limit
    x = constrain(x, 0, width);
    y = constrain(y, 0, height);
  }
  
  void display() {
  
    stroke(col); 
    noFill();
    beginShape();
    for (int i = 0; i < path.size(); i++) {
      PVector p = path.get(i);
      vertex(p.x, p.y);
    }
    endShape();
    fill(col);
    noStroke();
    ellipse(x, y, 4, 4);
  }
}
