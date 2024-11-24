int numParticles = 500;
ArrayList<WindParticle> particles = new ArrayList<WindParticle>();
int numCircles = 50;
ArrayList<Circle> circles = new ArrayList<Circle>();

void setup() {
  size(1200, 800);
  noStroke();
  background(10, 10, 50);
  
  // init particles
  for (int i = 0; i < numParticles; i++) {
    particles.add(new WindParticle(random(width), height));
  }
  
  // init circles
  for (int i = 0; i < numCircles; i++) {
    circles.add(new Circle(random(width), random(height), random(10, 100)));
  }
}

void draw() {
  fill(10, 10, 50, 200); 
  rect(0, 0, width, height);

  // update particles
  for (WindParticle particle : particles) {
    particle.followFlowField();  // progress in flow
    particle.update();        
    particle.display();         
  }

  for (int i = 0; i < circles.size(); i++) {
    circles.get(i).display();
  }

  for (int i = 0; i < circles.size(); i++) {
    for (int j = i + 1; j < circles.size(); j++) {
      Circle c1 = circles.get(i);
      Circle c2 = circles.get(j);

      // Intersection Handling
      if (c1.intersects(c2)) {
        Intersection intersection = c1.getIntersection(c2);
        fill(random(200, 255), random(200, 255), random(50, 100), 60);
        noStroke();
        ellipse(intersection.x, intersection.y, intersection.diameter, intersection.diameter);
      }
    }
  }

  // save ss
  if (keyPressed) {
    saveFrame("screenshot-####.png"); 
  }
}


class WindParticle {
  PVector position;
  PVector velocity;
  ArrayList<PVector> trail; // trace
  int trailLength = 200;     //max trace for fading

  WindParticle(float x, float y) {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    trail = new ArrayList<PVector>(); 
  }

   // flow motion
  void followFlowField() {
    //  Perlin to determine the dynamic flow direction
    float angle = noise(position.x * 0.005, position.y * 0.005) * TWO_PI;
    PVector flow = new PVector(cos(angle), sin(angle)); 
    velocity.add(flow.mult(2)); // effect increase
  }

  void update() {
    position.add(velocity);     
    velocity.mult(0.9);       

    //canvas overflow
    if (position.x > width) position.x = 0;
    if (position.x < 0) position.x = width;
    if (position.y > height) position.y = 0;
    if (position.y < 0) position.y = height;


    trail.add(position.copy());
    if (trail.size() > trailLength) trail.remove(0); 
  }

  void display() {
    noStroke();
    fill(50, 50, random(150, 255), 40);

    for (int i = 1; i < trail.size(); i++) {
      PVector prev = trail.get(i - 1);
      PVector curr = trail.get(i);

      if (PVector.dist(prev, curr) < 50) {
        stroke(random(50, 100), random(100, 200), 255, 80);
        strokeWeight(0.5);
        line(prev.x, prev.y, curr.x, curr.y);
      }
    }
  }
}

class Circle {
  float x, y, size;

  Circle(float x, float y, float size) {
    this.x = x;
    this.y = y;
    this.size = size;
  }

  void display() {
    noStroke();
    fill(random(70, 80), random(70, 100), random(150, 255), 50); 
    ellipse(x, y, size, size);
  }

  //circle intersection
  boolean intersects(Circle other) {
    float d = dist(x, y, other.x, other.y);  
    return d < (size / 2 + other.size / 2);  
  }
  Intersection getIntersection(Circle other) {
    // finding approximate intersection center by avg he centers of the two circles
    float xOverlap = (x + other.x) / 2;
    float yOverlap = (y + other.y) / 2;

    // Estimate a size
    float overlapRadius = (size / 2 + other.size / 2) - dist(x, y, other.x, other.y);
    overlapRadius = max(overlapRadius, 0);  // > 0  check

    return new Intersection(xOverlap, yOverlap, overlapRadius * 2); //new instersection
  }
}

class Intersection {
  float x, y, diameter;

  Intersection(float x, float y, float diameter) {
    this.x = x;
    this.y = y;
    this.diameter = diameter;
  }
}
