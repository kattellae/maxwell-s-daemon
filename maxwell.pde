class Point {
  Point(PVector pos, PVector vel) {
    position = pos;
    velocity = vel;
  }
  PVector position;
  PVector velocity;
  float radius = 15;
}

Point[] points = new Point[2];

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

void setup() {
  size(1000, 1000);
  frameRate(200);
  points[0] = new Point(new PVector(200, 510), new PVector(0, 0));
  points[1] = new Point(new PVector(800, 500), new PVector(-1, 0));
}

void draw() {
  background(50);

  for (int i = 0; i < points.length; i++) {
    Point p = points[i];

    // move
    p.position.add(p.velocity);

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
    totalEnergy += (p.velocity.mag() * p.velocity.mag());
    // draw
    stroke(200);
    fill(200);
    circle(p.position.x, p.position.y, p.radius*2);
  }
  println("Total energy: " + totalEnergy);
 
}
