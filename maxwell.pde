class Point {
  Point(PVector pos, PVector vel) {
    position = pos;
    velocity = vel;
  }
  PVector position;
  PVector velocity;
  final static float radius = 8;
}

int fpsDivider = 1;

boolean collide(Point a, Point b) {
  float dist = a.position.dist(b.position);
  if (dist < a.radius + b.radius) {
    float prox = dist/(a.radius + b.radius);
    float force = 1/prox - 1;

    PVector impact = PVector.sub(a.position, b.position);
    impact.setMag(force);
    a.velocity.add(impact);
    b.velocity.sub(impact);
    return true;
  }
  return false;
}

Point[] points = new Point[400];
int[] hist = new int[16];

void setup() {
  size(1600, 1600);
  frameRate(100);
  //points[0] = new Point(new PVector(200, 510), new PVector(0, 0));
  //points[1] = new Point(new PVector(800, 500), new PVector(-1, 0));
  int rowCount = (int)sqrt(points.length);
  float space = width / rowCount;
  for (int i = 0; i < points.length; i++) {
    int row = i / rowCount;
    int col = i %  rowCount;
    points[i] = new Point(new PVector(col * space + space / 2, row * space + space / 2), new PVector(1, 0));
    points[i].velocity.setHeading(random(2*PI));
  }
}

boolean daemonActive = false;
float maxPointEnergy = 0;
float maxSpeed = 0;

void draw() {
  background(50);
  fill(200);

  //daemon
  if (daemonActive) {
    rect(width / 2 - 8, 0, 8, height);
  }

  for (int i = 0; i < hist.length; ++i) {
    hist[i] = 0;
  }

  for (int i = 0; i < points.length; i++) {
    Point p = points[i];

    // move
    p.position.add(p.velocity.div(fpsDivider));

    // wall baunce
    if (p.position.x < 0 || p.position.x >= width) {
      if (p.position.x < 0) p.position.x = 0;
      if (p.position.x >= width) p.position.x = width - 1;
      p.velocity.x *= -1;
    }

    if (p.position.y < 0 || p.position.y >= height) {
      if (p.position.y < 0) p.position.y = 0;
      if (p.position.y >= height) p.position.y = height - 1;
      p.velocity.y *= -1;
    }

    // calc daemon work
    if ((p.position.x > width / 2 - 8) && (p.position.x < width / 2 + 8) && daemonActive) {
      if ((p.velocity.x > 0 && p.velocity.mag() < maxSpeed / 2)
        || (p.velocity.x < 0 && p.velocity.mag() > maxSpeed / 2)) { // движемся вправо
        // отскок
        p.velocity.x *= -1;
      }
    }
  }
  maxSpeed = 0;

  for (int i = 0; i < points.length; i++) {
    Point p = points[i];
    for (int j = i + 1; j < points.length; j++) {
      Point o = points[j];
      collide(p, o);
    }
        // find min/max speed
    if (p.velocity.mag() > maxSpeed) {
      maxSpeed = p.velocity.mag();
    }
  }
  
  if (maxSpeed > 8) {
    fpsDivider *= 2;
  }

  // calc total enegry
  float totalEnergy = 0;
  float coldEnergy = 0;
  float hotEnergy = 0;
  int coldP = 0;
  int hotP = 0;

  for (int i = 0; i < points.length; i++) {

    Point p = points[i];
    // fill historgam
    int index = (int)map(p.velocity.mag(), 0, maxSpeed, 0, hist.length);
    if (index >= hist.length) {
      index = 15;
    }
    hist[index]++;
    // calc total energy
    float e = p.velocity.mag() * p.velocity.mag();
    if (maxPointEnergy < e) {
      maxPointEnergy = e;
    }
    totalEnergy += e;
    if (p.position.x > width/2) {
      hotEnergy += e;
      hotP++;
    } else {
      coldEnergy += e;
      coldP++;
    }
    // draw
    stroke(200);

    fill(map(e, 0, maxPointEnergy, 50, 250));
    circle(p.position.x, p.position.y, p.radius*2);
    fill(250);
    textSize(64);
  }
  text(coldEnergy/coldP, 40, height - 100);
  text(hotEnergy/hotP, width/2 + 40, height - 100);


  for (int i = 0; i < hist.length; ++i) {
    rect(0, 12*i, hist[i]*10, 10);
  }

  println("Total energy: " + totalEnergy + ", max: " + maxSpeed + ", world slow x" + fpsDivider);
}


void keyPressed() {
  if (key == ' ') {
    daemonActive = true;
  }
}
