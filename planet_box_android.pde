//--------------------------------------------
// PlanetBox 0.5.0-alpha (code name: youranus)
// 6/11/2019, RI
//--------------------------------------------

import android.view.MotionEvent;
import ketai.ui.*;

KetaiGesture gesture;

// TODO: Add more interactivity.

// Constants
final String progName = "PlanetBox";
final String progVer = "0.5.0-alpha";
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

Boundry bDoubleTap, bLongPress;

// Variables
boolean showExp = false;
boolean showHelp = false;
boolean showStats = false;
boolean keyboard = false;

int cooldownStart_ms = 0;

// Called once, on startup.
void setup() {
  println("Welcome to " + progName + " version " + progVer + "!");
  println("Code name '" + codeName + "'");
  println("");
  print(howToUse);
  
  orientation(LANDSCAPE);
  fullScreen(P3D);
  background (color(36, 38, 70));
  
  gesture = new KetaiGesture(this);
  
  // Pre-load text font to avoid run-time speed penatly on first call to text()
  textFont(createFont("Arial", 14 * displayDensity));
  
  // *** SETUP SCENE: A fictional "Solar Eclipse" with Cube Sats orbiting Venus, from Earth's perspective ***
    
  float planet_freq = 2;      // default rotation step size
  float planet_radius = (height / 3.5);
  
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
  planetB = new Planet(color(255/2,130/2,100/2), width/10, height/5, 25 * displayDensity, planet_freq);
  
  cubeSat4 = new CubeSat(planetB, color(100, 200, 200), 5, CubeSat.DIR_CCW, CubeSat.NO_SYNC, CubeSat.TIDAL_LOCK);
  cubeSat5 = new CubeSat(planetB, color(200, 200, 50), 5, CubeSat.DIR_CW, CubeSat.NO_SYNC, CubeSat.TIDAL_LOCK);
  
  bLongPress = new Boundry(width - width/5, height/22, width, height/4);
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
  if (showStats) {
    displayPlanetStats(venus);
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

//void mousePressed() {
//  if (!keyboard) {
//    openKeyboard();
//    keyboard = true;
//  } else {
//    closeKeyboard();
//    keyboard = false;
//  }
//}

void onPinch(float x, float y, float r)
{
  // (re)start 'flick' cooldown
  cooldownStart_ms = millis();
  
  float speed = abs(constrain(r, -8, 8));
  if (r > 3) {
    zoomIn(speed * 0.85);
  } else if (r < -3) {
    zoomOut(speed * 0.85);
  }
}

void onDoubleTap(float x, float y)
{
  // TODO: implement boundary checking.
  showExp ^= true; 
}

//the coordinates of the start of the gesture, 
//     end of gesture and velocity in pixels/sec
void onFlick( float x, float y, float px, float py, float v)
{
  // ignore until cooldown expires
  if ( millis() - cooldownStart_ms < 500) return;
  
  // Get flick's vector heading (angle)
  PVector p = new PVector(x-px, y-py);
  float angle = 180 - degrees(p.heading());
  
  println("Degrees: " + angle);
  println("Magnitude: " + p.mag());

  if (p.mag() > 100 ) {
    // Adjust rotational speed based on flick's angle
    if (angle < 270 && angle > 90 ) {
      venus.setFrequency(venus.getFrequency() + 0.5);
    } else {
      venus.setFrequency(venus.getFrequency() - 0.5);
    }
  }
}

void onLongPress(float x, float y) {
  println("LONG PRESS: x = " + x + ", y = " + y);
  if (bLongPress.isIn(x, y)) {
    showStats ^= true;
  }
}

void zoomOut(float factor) {
  int zoom_lower = height/45;
  int zoom_upper = height/2;
  
  float m = abs(norm(venus.radius, zoom_lower, zoom_upper));
  factor *= 1 + m;
  
  println("Zoom Out multiplier: " + m);
  println("Zoom Out factor: " + factor);
  
  if (venus.radius > zoom_lower)
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
  int zoom_lower = height/45;
  int zoom_upper = height/2;
  
  float m = abs(norm(venus.radius, zoom_lower, zoom_upper));
  factor *= 1 + m;
  
  println("Zoom In multiplier: " + m);
  println("Zoom In factor: " + factor);
  
  if (venus.radius < zoom_upper)
  {
    venus.scaleUp(factor);
    sun.scaleUp(factor);
    moon.scaleUp(factor);
    
    cubeSat1.scaleUp();
    cubeSat2.scaleUp();
    cubeSat3.scaleUp();
  }
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

void displayPlanetStats(Planet p) {
  fill(255);
  text("Venus:" + 
       "\n* Radius = " + p.radius + 
       "\n* Frequency = " + p.getFrequency() + 
       "\n* Revolutions = " + int(p.rotation / 360),
       bLongPress.x, bLongPress.y);
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
    
    for(int r = int(radius); r > 0; r -=3) {
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
  float scale;
  int direction;
  boolean geoSync;
  boolean tidalLock;
  
  public CubeSat(Planet p, color c, float size, int dir, boolean sync, boolean lock) {
    this.planet = p;
    this.c = c;
    this.size = size;
    this.scale = (this.size / this.planet.radius);
    
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
    rect (0, 0, size * displayDensity, size * displayDensity);
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
  
  // overloaded planet methods
  void scaleUp() {
    this.size = planet.radius * this.scale;
  }
  
  void scaleDown() {
    this.size = planet.radius * this.scale;
  }
}

class Boundry {
  float x, y, xx, yy;
  Boundry(float x, float y, float xx, float yy) {
    this.x = x;
    this.y = y;
    this.xx = xx;
    this.yy = yy;
  }
  
  boolean isIn(float ix, float iy) {
    return(ix >= this.x && iy >= this.y && ix <= this.xx && iy <= this.yy);
  }
}
