// ============================================================
//  Underwater Robot – Processing Control UI
//
//  Sends single-character commands to Arduino over Serial:
//    F/B/L/R/S  = Drive control
//    U/D/H      = Ballast control
//
//  HOW TO USE:
//    1. Upload the Arduino sketch first
//    2. Make sure Arduino Serial Monitor is CLOSED
//    3. Run this sketch — check the console for port list if needed
// ============================================================

import processing.serial.*;

Serial myPort;

// Layout constants
final int W = 520;
final int H = 620;

Button[] buttons;
String statusMsg = "Connecting...";
boolean connected = false;

// Colour palette
color BG          = color(15, 20, 35);
color PANEL       = color(25, 35, 60);
color DRIVE_COL   = color(30, 120, 220);
color DRIVE_HOV   = color(60, 160, 255);
color STOP_COL    = color(200, 50, 50);
color STOP_HOV    = color(240, 80, 80);
color BALLAST_COL = color(20, 160, 120);
color BALLAST_HOV = color(40, 200, 150);
color HALT_COL    = color(180, 130, 0);
color HALT_HOV    = color(220, 170, 20);
color TEXT_COL    = color(220, 230, 255);
color DIM_COL     = color(100, 110, 140);

// ============================================================
void setup() {
  size(520, 620);
  textFont(createFont("SansSerif", 14));

  // Build button layout
  int bw = 130, bh = 60, gap = 14;
  int driveX = 30, driveY = 110;
  int ballX  = 30, ballY  = 400;

  buttons = new Button[] {
    // ── Drive ──
    new Button("▲  FORWARD",  'F', driveX + bw + gap,       driveY,               bw, bh, DRIVE_COL,   DRIVE_HOV),
    new Button("▼  BACKWARD", 'B', driveX + bw + gap,       driveY + bh + gap,    bw, bh, DRIVE_COL,   DRIVE_HOV),
    new Button("◄  LEFT",     'L', driveX,                   driveY + bh + gap,    bw, bh, DRIVE_COL,   DRIVE_HOV),
    new Button("►  RIGHT",    'R', driveX + (bw + gap) * 2, driveY + bh + gap,    bw, bh, DRIVE_COL,   DRIVE_HOV),
    new Button("■  STOP",     'S', driveX + bw + gap,       driveY + (bh+gap)*2,  bw, bh, STOP_COL,    STOP_HOV),

    // ── Ballast ──
    new Button("▲  BALLAST UP",   'U', ballX,            ballY,              bw + 40, bh, BALLAST_COL, BALLAST_HOV),
    new Button("▼  BALLAST DOWN", 'D', ballX,            ballY + bh + gap,   bw + 40, bh, BALLAST_COL, BALLAST_HOV),
    new Button("■  HALT BALLAST", 'H', ballX + bw + 54, ballY + (bh-gap)/2, bw + 20, bh, HALT_COL,    HALT_HOV),
  };

  // Print all available ports to console — check here if connection fails
  println("Available serial ports:");
  printArray(Serial.list());

    delay(2000);
  try {
    myPort = new Serial(this, "COM4", 9600);
    myPort.clear();
    myPort.bufferUntil('\n');
    connected = true;
    statusMsg = "Connected on COM4";
  } catch (Exception e) {
    statusMsg = "Port error: " + e.getMessage();
    println("Serial error: " + e.getMessage());
  }
}
// ============================================================
void draw() {
  background(BG);

  // ── Title bar ──
  fill(PANEL);
  noStroke();
  rect(0, 0, W, 60);
  fill(TEXT_COL);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Underwater Robot Control", W/2, 30);

  // ── Status bar ──
  fill(connected ? color(20, 80, 40) : color(80, 20, 20));
  rect(0, H - 36, W, 36);
  fill(connected ? color(100, 255, 140) : color(255, 100, 100));
  textSize(13);
  textAlign(CENTER, CENTER);
  text(statusMsg, W/2, H - 18);

  // ── Section labels ──
  drawSectionLabel("DRIVE MOTORS", 30, 85);
  drawSectionLabel("BALLAST MOTOR", 30, 375);

  // ── Divider ──
  stroke(DIM_COL);
  strokeWeight(1);
  line(20, 360, W - 20, 360);
  noStroke();

  // ── Buttons ──
  for (Button b : buttons) b.draw();
}

void drawSectionLabel(String label, int x, int y) {
  fill(DIM_COL);
  textSize(12);
  textAlign(LEFT, TOP);
  text(label, x, y);
}

// ============================================================
void mousePressed() {
  if (!connected) return;
  for (Button b : buttons) {
    if (b.isHovered()) {
      b.press();
      send(b.cmd);
    }
  }
}

void mouseReleased() {
  for (Button b : buttons) b.release();
}

void send(char cmd) {
  if (connected && myPort != null) {
    myPort.write(cmd);
    statusMsg = "Sent: '" + cmd + "'  |  " + Serial.list()[0];
  }
}

// ── Read serial feedback from Arduino ──
void serialEvent(Serial p) {
  String msg = p.readStringUntil('\n');
  if (msg != null) {
    statusMsg = trim(msg) + "  |  " + Serial.list()[0];
  }
}

// ============================================================
//  Button class
// ============================================================
class Button {
  String label;
  char   cmd;
  int    x, y, w, h;
  color  baseCol, hoverCol;
  boolean pressed = false;

  Button(String label, char cmd, int x, int y, int w, int h,
         color baseCol, color hoverCol) {
    this.label    = label;
    this.cmd      = cmd;
    this.x        = x;
    this.y        = y;
    this.w        = w;
    this.h        = h;
    this.baseCol  = baseCol;
    this.hoverCol = hoverCol;
  }

  boolean isHovered() {
    return mouseX >= x && mouseX <= x + w &&
           mouseY >= y && mouseY <= y + h;
  }

  void press()   { pressed = true; }
  void release() { pressed = false; }

  void draw() {
    boolean hov = isHovered();
    color col = pressed ? hoverCol : (hov ? hoverCol : baseCol);

    // Shadow
    fill(0, 0, 0, 60);
    noStroke();
    rect(x + 3, y + 4, w, h, 10);

    // Button face
    fill(col);
    stroke(hov || pressed ? color(255, 255, 255, 80) : color(255, 255, 255, 20));
    strokeWeight(1.5);
    rect(x, y, w, h, 10);

    // Label
    fill(TEXT_COL);
    noStroke();
    textSize(14);
    textAlign(CENTER, CENTER);
    text(label, x + w/2, y + h/2);
  }
}
