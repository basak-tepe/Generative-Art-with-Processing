int numNeurons = 1000;
Neuron[] neurons;
float noiseScale = 0.1;  
color[] palette;  

void setup() {
  size(1200, 800);
  neurons = new Neuron[numNeurons];

  palette = loadPalette();
  
  // init randomly
  for (int i = 0; i < numNeurons; i++) {
    float x = random(width);
    float y = random(height);
    neurons[i] = new Neuron(x, y);
  }
  
  for (int i = 0; i < numNeurons; i++) {
    for (int j = i + 1; j < numNeurons; j++) {
      if (dist(neurons[i].x, neurons[i].y, neurons[j].x, neurons[j].y) < 200) {  // neighbor neurons
        neurons[i].connect(neurons[j]);
      }
    }
  }
}

void draw() {
  background(20);  
  for (Neuron n : neurons) {
    n.update(); 
    n.display();  
  }
  
  // save ss
  if (keyPressed) {
    saveFrame("screenshot-####.png"); 
  }
}

class Neuron {
  float x, y;  // pos
  ArrayList<Neuron> connections;  //  neighbor neurons
  float pulse;  
  boolean increasing;  // Pulse type
  float noiseOffsetX, noiseOffsetY;
  color neuronColor;  
  
  Neuron(float x, float y) {
    this.x = x;
    this.y = y;
    this.connections = new ArrayList<Neuron>();
    this.pulse = random(5, 10); 
    this.increasing = true;  
    this.noiseOffsetX = random(1000);  
    this.noiseOffsetY = random(1000);
    this.neuronColor = palette[int(random(palette.length))]; 
  }
  
  void connect(Neuron other) {
    connections.add(other);  
  }
  
  void update() {
    // Update pos with perlin
    x += map(noise(noiseOffsetX), 0, 1, -1, 1);
    y += map(noise(noiseOffsetY), 0, 1, -1, 1);
    noiseOffsetX += noiseScale;
    noiseOffsetY += noiseScale;

    // Pulse logic: grow and shrink the neuron circle
    if (increasing) {
      pulse += 0.1;
      if (pulse > 10) increasing = false;
    } else {
      pulse -= 0.1;
      if (pulse < 5) increasing = true;
    }
  }
  
  void display() {
    fill(neuronColor, 100); 
    noStroke();
    ellipse(x, y, pulse, pulse);
    
    // Bezier Curves 
    stroke(neuronColor, 50);  
    strokeWeight(0.4);
    noFill();
    for (Neuron n : connections) {
      float midX = (x + n.x) / 2 + map(noise(noiseOffsetX), 0, 1, -50, 50);   //perlin
      float midY = (y + n.y) / 2 + map(noise(noiseOffsetY), 0, 1, -50, 50); //perlin
      bezier(x, y, midX, midY, midX, midY, n.x, n.y);
    }
  }
}

// to adjust palette to ones liking
color[] loadPalette() {
  return new color[] {
    color(25, 42, 86), 
    color(34, 98, 168), 
    color(254, 216, 93), 
    color(231, 111, 81), 
    color(42, 157, 143)
  };
}
