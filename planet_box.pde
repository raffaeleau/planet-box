//--------------------------------------------
// PlanetBox 0.3.0-alpha (code name: youranus)
// 5/11/2019, RI
//--------------------------------------------

// TODO: Add more interactivity.

// Constants
final String progName = "PlanetBox";
final String progVer = "0.3.0-alpha";
final String codeName = "youranus";
final String howToUse = 
  "How to interact:\n" +
  "* Hold 'UP' key to ZOOM IN\n" +
  "* Hold 'DOWN' key to ZOOM OUT\n" +
  "* Use 'LEFT' and 'RIGHT' keys to adjust rotational speed and direction\n" +
  "* Press 'spacebar' to display more planets\n" +
  "* Press 'H' for help\n";

// Declare objects
Planet venus;
CubeSat cubeSat1, cubeSat2, cubeSat3;
Star sun;
Moon moon;

Planet planetB;
CubeSat cubeSat4, cubeSat5;

// Variables
boolean showExp = false;
boolean showHelp = false;

// Called once, on startup.
void setup() {
  println("Welcome to " + progName + " version " + progVer + "!");
  println("Code name '" + codeName + "'");
  println("");
  print(howToUse);
  
  // Pre-load text font to avoid run-time speed penatly on first call to text()
  textFont(createFont("Arial", 14));
  
  size(800, 400);
  background (color(36, 38, 70));
  
  // *** SETUP SCENE: A fictional "Solar Eclipse" with Cube Sats orbiting Venus, from Earth's perspective ***
    
  float planet_freq = 2;      // default rotation step size
  float planet_radius = 104;
  
  // Venus.
  venus = new Planet(color(240,220,96), width/2, height/2, planet_radius, planet_freq);
  
  // A Cube Sat orbit can be geosynchronous and/or tidally locked to a planet's rotation.
  cubeSat1 = new CubeSat(venus, color(180, 220, 220), 5, CubeSat.DIR_CCW, CubeSat.GEO_SYNC, CubeSat.TIDAL_LOCK);
  cubeSat2 = new CubeSat(venus, color(100, 200, 200), 10, CubeSat.DIR_CW, CubeSat.GEO_SYNC, CubeSat.NO_LOCK);
  cubeSat3 = new CubeSat(venus, color(200, 200, 50), 5, CubeSat.DIR_CCW, CubeSat.NO_SYNC, CubeSat.TIDAL_LOCK);
  
  // The Sun.
  sun = new Star(color(255,100,0), venus.xpos, venus.ypos, venus.radius + 1.5);
  
  // The Moon.
  moon = new Moon(color(18,17,15), venus.xpos, venus.ypos, venus.radius - 0.5);
  
  // *** END SCENE ***
  
  // Planet B, aka Mars - Experimental
  planetB = new Planet(color(255/2,130/2,100/2), width/10, height/5, 25, planet_freq);
  
  cubeSat4 = new CubeSat(planetB, color(100, 200, 200), 5, CubeSat.DIR_CCW, CubeSat.NO_SYNC, CubeSat.TIDAL_LOCK);
  cubeSat5 = new CubeSat(planetB, color(200, 200, 50), 5, CubeSat.DIR_CW, CubeSat.NO_SYNC, CubeSat.TIDAL_LOCK);
}

// Main "loop"
void draw() {
  background (color(4, 6, 16));

  sun.display();
  venus.display();

  // Cubes orbiting venus: {altitude, period}.
  cubeSat1.orbit(5, 1);
  cubeSat2.orbit(15, 1);
  //cubeSat3.orbit(30, 1.5);
  cubeSat3.orbit(5, 20, 1.5, CubeSat.ORBIT_ELLIPTICAL); // {altitude, gain, period, orbitType}
  
  moon.display();
  moon.drawGradient(1);

  if (showExp) {
    displayPlanetB();
  }
  if (showHelp) {
    displayHelp(howToUse);
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT) {
      venus.setFrequency(venus.getFrequency() + 0.5);
    } else if (keyCode == LEFT) {
      venus.setFrequency(venus.getFrequency() - 0.5);
    } else if (keyCode == DOWN) {
      zoomOut(0.85);
    } else if (keyCode == UP) {
      zoomIn(0.85);    
    }
  } else {
    if (key == ' ') {
      // Toggle experimental display with 'spacebar'
      showExp ^= true; 
    } else if (key == 'h' || key == 'H') {
      showHelp ^= true;
    }
  }
}

void zoomOut(float factor) {
  int zoom_limit = 5;
  if (venus.radius > zoom_limit)
  {
    venus.scaleDown(factor);
    sun.scaleDown(factor);
    moon.scaleDown(factor);
    cubeSat1.scaleDown();
    cubeSat2.scaleDown();
    cubeSat3.scaleDown();
  }
}

void zoomIn(float factor) {
  venus.scaleUp(factor);
  sun.scaleUp(factor);
  moon.scaleUp(factor);
  cubeSat1.scaleUp();
  cubeSat2.scaleUp();
  cubeSat3.scaleUp();
}

void displayPlanetB() {
  // Box and label
  stroke(255);
  noFill();
  rect(planetB.xpos, planetB.ypos, planetB.diameter*2.5, planetB.diameter*2.5);
  fill(255);
  text("Planet B", planetB.xpos - planetB.diameter*1.1, planetB.ypos + planetB.diameter*1.1);
  
  // EXPERIMENTAL
  planetB.display();
  planetB.drawGradient(5);
  cubeSat4.orbit(10, 0.5);
  cubeSat5.orbit(5, 10, 1.5, CubeSat.ORBIT_ELLIPTICAL);
}

void displayHelp(String s) {
  fill(255);
  text(s, width/50, height - height/3.5);
}

// Object definitions

class Planet {
  color c;
  float xpos;
  float ypos;
  float radius;
  float diameter;
  float rotation;
  private float frequency;
  
  public Planet(color c, float xpos, float ypos, float radius, float freq)
  {
    this.c = c;
    this.xpos = xpos;
    this.ypos = ypos;
    this.radius = radius;
    this.diameter = this.radius * 2;
    rotation = 0;
    frequency = freq;
  }
  
  // Note: No collision detection. A planet can be drawn anywhere on screen.
  void display() {
    noStroke();
    fill(c);
    ellipse(xpos, ypos, radius * 2, radius * 2);
    // Tick rate
    rotation -= frequency;
  }
  
  float getFrequency() {
    return frequency;
  }
  
  void setFrequency(float freq) {
    frequency = freq;
  }
  
  void scaleUp(float factor) {
    this.radius += factor;  
  }
  
  void scaleDown(float factor) {
    this.radius -= factor;
  }
  
  void drawGradient(int step) {
    // Brighten before fading
    float cr = red(c)*2;
    float cg = green(c)*2;
    float cb = blue(c)*2;
    
    for(int r = int(radius); r > 0; --r) {
      fill(max(0, cr), max(0, cg), max(0, cb));
      ellipse(xpos, ypos, r * 2, r * 2);
      cr -=step;
      cg -=step;
      cb -=step;
    }
  }
}

class Moon extends Planet {
  public Moon(color c, float xpos, float ypos, float radius) {
    super(c, xpos, ypos, radius, 1);
  }
}

class Star extends Planet {
  public Star(color c, float xpos, float ypos, float radius) {
    super(c, xpos, ypos, radius, 1);
  }
} 

class CubeSat {
  static final int DIR_CCW = 1;
  static final int DIR_CW = -1;
  static final boolean GEO_SYNC = true;
  static final boolean NO_SYNC = false;
  static final boolean TIDAL_LOCK = true;
  static final boolean NO_LOCK = false;
  static final int ORBIT_CIRCULAR = 0;
  static final int ORBIT_ELLIPTICAL = 1;
  
  Planet planet;
  color c;
  float size;
  int direction;
  boolean geoSync;
  boolean tidalLock;
  
  public CubeSat(Planet p, color c, float size, int dir, boolean sync, boolean lock) {
    this.planet = p;
    this.c = c;
    this.size = size;
    
    switch(dir)
    {
      case DIR_CW:
      case DIR_CCW:
        direction = dir;
        break;
      default:
        direction = DIR_CCW;
    }
    
    this.geoSync = sync;
    this.tidalLock = lock;
  }
  
  private float elliptical(float rmin, float gain) {
    return rmin + ((1 + cos(radians(planet.rotation % 360))) * gain);
  }
  
  private void rotateAxis(float px, float py, float period) {
    // Rotate cube axis; face towards planet if tidally locked.
    pushMatrix();
    translate(px, py);
    rectMode(CENTER);
    rotate(radians(planet.rotation * (tidalLock ? 1 : -1) * direction * period));
    fill(c);
    rect (0, 0, size, size);
    popMatrix();
  }
  
  void orbit(float alt, float period) {
    // Override orbit period if orbit is geosynchronous.
    period = geoSync ? 1 : period;
  
    // Scaled altitude
    float distance = (alt / 100) * planet.radius * 2;
    
    // Rotates cube around a planet. Polar to Cartesian.
    float pos = planet.rotation;
    float px = planet.xpos + (cos(radians(direction * pos * period)) * (planet.radius + distance));
    float py = planet.ypos + (sin(radians(direction * pos * period)) * (planet.radius + distance));
  
    rotateAxis(px, py, period);
  }
  
  void orbit(float altMin, float altGain,  float period, int orbitType) {
    // Override orbit period if orbit is geosynchronous.
    period = geoSync ? 1 : period;
    
    float altitude = altMin;
    if (orbitType == ORBIT_ELLIPTICAL) {
      // Revolving "elliptical" orbit - varying altitude
      altitude = elliptical(altMin, altGain);
    }
    
    // Scaled altitude
    float distance = (altitude / 100) * planet.radius * 2;
    
    // Rotates cube around a planet. Polar to Cartesian.
    float pos = planet.rotation;
    float px = planet.xpos + (cos(radians(direction * pos * period)) * (planet.radius + distance));
    float py = planet.ypos + (sin(radians(direction * pos * period)) * (planet.radius + distance));
  
    rotateAxis(px, py, period);
  }
  
  // overloaded planet method
  void scaleUp() {
    float s_ratio = size / planet.radius;
    size += 1 * s_ratio * 0.5;
  }
  
  // overloaded planet method
  void scaleDown() {
    float s_ratio = size / planet.radius;
    size -= 1 * s_ratio * 0.5;
  }
}
