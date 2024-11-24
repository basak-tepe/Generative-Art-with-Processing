class FlowField {
  PVector[][] vectors; 
  int cols, rows;
  float grid_inc = 0.1;
  float noise_time_off = 0;
  float noise_time_inc = 0.002;
  int scl;

  FlowField(int res, float ntime_inc) {
    scl = res;
    noise_time_inc = ntime_inc;
    cols = floor(width / res) + 1;
    rows = floor(height / res) + 1;
    vectors = new PVector[cols][rows];
  }


  void updateFF() {
    for (int y = 0; y < rows; y++) { 
      for (int x = 0; x < cols; x++) {
        float px = x * scl;
        float py = y * scl;
      
        float angle = random(TWO_PI);  // random angle for chaotic galaxy-like motion
        PVector v = PVector.fromAngle(angle);
        v.setMag(0.5); 
        
        //we are working in 2D but this vertical lifts gives us control
        float verticalLift = map(dist(px, py, width / 2, height / 2), 0, width / 2, 1, 0.1); // Decreases with distance from center
        v.z = -verticalLift * 0.5; 
        
 
        float noiseVal = noise(px * 0.05, py * 0.05, noise_time_off);
        float magnitude = map(noiseVal, 0, 1, 0.5, 1.5); 
        v.setMag(v.mag() * magnitude); 
        
        vectors[x][y] = v;
      }
    }
    noise_time_off += noise_time_inc;  // inc the noise offset
  }

  void display() {
    for (int y = 0; y < rows; y++) { 
      for (int x = 0; x < cols; x++) {
        PVector v = vectors[x][y];
        stroke(0, 0, 255, 100);  
        strokeWeight(1);
        pushMatrix();
        translate(x * scl, y * scl);
        rotate(v.heading());
        line(0, 0, scl, 0);
        popMatrix();
      }
    }
  }

  public PVector[][] getVectors() {
    return vectors;
  }
}

public class Particle {
  PVector pos;
  PVector vel;
  PVector acc;
  PVector previousPos;
  float maxSpeed;
  float noiseOffset;
  float noiseTime = 0.01;
  int r, g, b;
  boolean isDrawingTrace = true;

  Particle(PVector start, float maxspeed) {
    maxSpeed = maxspeed;
    pos = start;
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    previousPos = pos.copy();
    noiseOffset = random(1000);
  }

  void run() {
    updatePosition();
    edges();
    show();
  }

  void updatePosition() {
    pos.add(vel);
    vel.add(acc);
    vel.limit(maxSpeed);
    acc.mult(0);
  }

  void applyForce(PVector force) {
    acc.add(force);
  }

  void applyFieldForce(FlowField flowfield) {
    int x = floor(pos.x / flowfield.scl);
    int y = floor(pos.y / flowfield.scl);

    PVector force = flowfield.vectors[x][y];
    applyForce(force);
  }

void show() {
  // color transition tracing
  float totalFrames = 600.0; // one full cycle
  float progress = (frameCount % totalFrames) / totalFrames; // Normalized progress [0, 1]

  if (progress < 0.5) {
    // Phase 1 dark blue to pink
    float t = map(progress, 0, 0.5, 0, 1); // Map progress to [0, 1] within phase 1
    r = int(lerp(0, 255, t)); 
    g = int(lerp(0, 20, t));  
    b = int(lerp(139, 147, t)); 
  } else {
    // Phase 2 pink to yellow
    float t = map(progress, 0.5, 1, 0, 1); 
    r = 255;
    g = int(lerp(20, 255, t)); 
    b = int(lerp(147, 0, t));  
  }

  stroke(r, g, b, 50);
  strokeWeight(2);
  line(pos.x, pos.y, previousPos.x, previousPos.y);

  updatePreviousPos();
}


  void updatePreviousPos() {
    previousPos.set(pos);
  }

  void edges() {
    if (pos.x > width) {
      pos.x = 0;
      updatePreviousPos();
    }
    if (pos.x < 0) {
      pos.x = width;
      updatePreviousPos();
    }
    if (pos.y > height) {
      pos.y = 0;
      updatePreviousPos();
    }
    if (pos.y < 0) {
      pos.y = height;
      updatePreviousPos();
    }
  }
}

FlowField flowfield;
ArrayList<Particle> particles;
ArrayList<Particle> stars;
ArrayList<Particle> spiralParticles;

boolean isShowingFF = false;
boolean isDrawingTrace = true;

float flowFieldTimeStep = 0.007;
int flowFieldScl = 15;
int numParticles = 300;
int numStars = 50;  
int numSpiralPoints = 20; 

void setup() {
  size(1200, 800);

  flowfield = new FlowField(flowFieldScl, flowFieldTimeStep);
  flowfield.updateFF();
  initParticles(numParticles);
  initStars(numStars);
  background(0);  
}

void draw() {
  if (!isDrawingTrace) background(0);
  flowfield.updateFF();
  if (isShowingFF) flowfield.display();
  for (Particle p : particles) {
    p.applyFieldForce(flowfield);
    p.run();
  }
  for (Particle star : stars) {
    star.run();
  }

  if (keyPressed) {
    saveFrame("screenshot-####.png"); 
}
}

//moving particles
void initParticles(int n) {
  particles = new ArrayList<Particle>();
  for (int i = 0; i < n; i++) {
    float maxSpeed = random(1, 2);
    PVector start_point = new PVector(random(width), random(height));
    while (dist(start_point.x, start_point.y, width / 2, height / 2) > width / 2) {
      start_point = new PVector(random(width), random(height));
    }
    
    particles.add(new Particle(start_point, maxSpeed));
  }
}


//Just static dots i.e stars
void initStars(int n) {
  stars = new ArrayList<Particle>();
  for (int i = 0; i < n; i++) {
    PVector start_point = new PVector(random(width), random(height));
    Particle star = new Particle(start_point, 0);
    star.r = 255;
    star.g = 255;
    star.b = 255;

    stars.add(star);
  }
}
