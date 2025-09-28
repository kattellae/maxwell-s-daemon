class Point {
  Point(PVector pos, PVector vel) {
    position = pos;
    velocity = vel;
  }
  PVector position;
  PVector velocity;
  float radius = 8;
}

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

void draw() {
  background(50);

  float maxSpeed = 0;

  for (int i = 0; i < hist.length; ++i) {
    hist[i] = 0;
  }

  for (int i = 0; i < points.length; i++) {
    Point p = points[i];

    // move
    p.position.add(p.velocity);
    //p.velocity.y += 0.005;

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
    // find min/max speed
    if (p.velocity.mag() > maxSpeed) {
      maxSpeed = p.velocity.mag();
    }
  }


  for (int i = 0; i < points.length; i++) {
    Point p = points[i];
    for (int j = i + 1; j < points.length; j++) {
      Point o = points[j];
      collide(p, o);
    }
  }
  // calc total enegry
  float totalEnergy = 0;

  for (int i = 0; i < points.length; i++) {

    Point p = points[i];
    // fill historgam
    int index = (int)map(p.velocity.mag(), 0, maxSpeed, 0, hist.length);
    if (index >= hist.length) {
      index = 15;
    }
    hist[index]++;
    // calc total energy
    totalEnergy += (p.velocity.mag() * p.velocity.mag());
    // draw
    stroke(200);
    fill(200);
    circle(p.position.x, p.position.y, p.radius*2);
  }

  for (int i = 0; i < hist.length; ++i) {
    rect(0, 12*i, hist[i]*10, 10);
  }

  println("Total energy: " + totalEnergy + ", max: " + maxSpeed);
}
