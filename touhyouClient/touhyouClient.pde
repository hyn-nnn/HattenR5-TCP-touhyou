import processing.net.*;

enum Status {
  INPUT,
  WAIT,
  RESULT
}

class Button {
  int id, cx, cy, size;
  color fillColor;
  boolean selected = false;

  Button(int id, int cx, int cy, int size, color fillColor) {
    this.id = id;
    this.cx = cx;
    this.cy = cy;
    this.size = size;
    this.fillColor = fillColor;
  }

  boolean clicked() {
    return dist(mouseX, mouseY, cx, cy) <= size / 2;
  }

  void draw() {
    noStroke();
    if (this.selected) {
      fill(this.fillColor);
    } else {
      fill(this.fillColor, 100);
    }
    ellipse(this.cx, this.cy, this.size, this.size);
    fill(0);
    textAlign(CENTER, CENTER);
    text(this.id, this.cx, this.cy);
  }
}

Client client;
Status currentStatus = Status.INPUT;
Button[] buttons;
int result = -1;

void setup() {
  size(400, 400);

  client = new Client(this, "127.0.0.1", 5204);

  int size = 100;
  buttons = new Button[3];
  buttons[0] = new Button(0, size / 2, height / 2, size, color(255, 0, 0));
  buttons[1] = new Button(1, width / 2, height / 2, size, color(0, 255, 0));
  buttons[2] = new Button(2, height - size / 2, height / 2, size, color(0, 0, 255));
}

void draw() {
  background(255);
  boolean win = false;
  for (Button button : buttons) {
    button.draw();
    if (button.selected && result == button.id) {
      win = true;
    }
  }
  if (currentStatus == Status.RESULT) {
    fill(0);
    textAlign(CENTER, CENTER);
    if (result == buttons.length) {
      text("draw", width / 2, 100);
    } else if (win) {
      text("win", width / 2, 100);
    } else {
      text("lose", width / 2, 100);
    }
  }
}

void mouseClicked() {
  if (currentStatus == Status.INPUT) {
    int selected = -1;
    for (Button button : buttons) {
      if (button.clicked()) {
        selected = button.id;
        button.selected = true;
      }
    }
    if (selected != -1) {
      client.write(selected);
      currentStatus = Status.WAIT;
    }
  } else if (currentStatus == Status.RESULT) {
    for (Button button : buttons) {
      button.selected = false;
    }
    result = -1;
    currentStatus = Status.INPUT;
  }
}

void clientEvent(Client client) {
  result = client.read();
  currentStatus = Status.RESULT;
}
