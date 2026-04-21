// ============================================================
//  Underwater Robot – Combined Drive + Ballast Control
//  Communication: Processing UI → Serial → Arduino
//
//  Commands:
//    F = Drive Forward     B = Drive Backward
//    L = Turn Left         R = Turn Right
//    S = Stop Drive
//    U = Ballast Up        D = Ballast Down
//    H = Halt Ballast
// ============================================================

// --- TB6612FNG Motor Driver (Drive Motors A & B) ---
const int ain1 = 4;
const int ain2 = 2;
const int pwma = 3;   // PWM – Motor A

const int bin1 = 6;
const int bin2 = 9;
const int pwmb = 5;   // PWM – Motor B

const int stby = 10;  // Standby pin

// --- L298N-style Driver (Ballast Motor C) ---
const int ENA  = 11;  // PWM – Motor C
const int IN1  = 7;
const int IN2  = 8;

// --- Speed Settings ---
const int DRIVE_SPEED   = 200;  // 0–255
const int BALLAST_SPEED = 255;  // 0–255

// ============================================================
void setup() {
  // Drive motor pins
  pinMode(ain1, OUTPUT);
  pinMode(ain2, OUTPUT);
  pinMode(pwma, OUTPUT);
  pinMode(pwmb, OUTPUT);
  pinMode(bin1, OUTPUT);
  pinMode(bin2, OUTPUT);
  pinMode(stby, OUTPUT);
  digitalWrite(stby, HIGH);   // take drive motors out of standby

  // Ballast motor pins
  pinMode(ENA, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);

  // Start everything stopped
  stopDrive();
  haltBallast();

  Serial.begin(9600);
  Serial.println("Robot Ready");
}

// ============================================================
void loop() {
  if (Serial.available() > 0) {
    char cmd = Serial.read();

    switch (cmd) {
      // --- Drive commands ---
      case 'F': driveForward();   Serial.println("Drive: Forward");  break;
      case 'B': driveBackward();  Serial.println("Drive: Backward"); break;
      case 'L': turnLeft();       Serial.println("Drive: Left");     break;
      case 'R': turnRight();      Serial.println("Drive: Right");    break;
      case 'S': stopDrive();      Serial.println("Drive: Stop");     break;

      // --- Ballast commands ---
      case 'U': ballastUp();      Serial.println("Ballast: Up");     break;
      case 'D': ballastDown();    Serial.println("Ballast: Down");   break;
      case 'H': haltBallast();    Serial.println("Ballast: Halt");   break;

      default: break;  // ignore unknown characters
    }
  }
}

// ============================================================
//  Drive Motor Helpers
// ============================================================

void driveForward() {
  setMotor(pwma, ain1, ain2,  DRIVE_SPEED);
  setMotor(pwmb, bin1, bin2,  DRIVE_SPEED);
}

void driveBackward() {
  setMotor(pwma, ain1, ain2, -DRIVE_SPEED);
  setMotor(pwmb, bin1, bin2, -DRIVE_SPEED);
}

void turnLeft() {
  // Left motor backward, right motor forward
  setMotor(pwma, ain1, ain2, -DRIVE_SPEED);
  setMotor(pwmb, bin1, bin2,  DRIVE_SPEED);
}

void turnRight() {
  // Left motor forward, right motor backward
  setMotor(pwma, ain1, ain2,  DRIVE_SPEED);
  setMotor(pwmb, bin1, bin2, -DRIVE_SPEED);
}

void stopDrive() {
  setMotor(pwma, ain1, ain2, 0);
  setMotor(pwmb, bin1, bin2, 0);
}

// speed: positive = forward, negative = backward, 0 = stop
void setMotor(int pwmPin, int in1, int in2, int speed) {
  if (speed > 0) {
    digitalWrite(in1, HIGH);
    digitalWrite(in2, LOW);
    analogWrite(pwmPin, speed);
  } else if (speed < 0) {
    digitalWrite(in1, LOW);
    digitalWrite(in2, HIGH);
    analogWrite(pwmPin, -speed);
  } else {
    digitalWrite(in1, LOW);
    digitalWrite(in2, LOW);
    analogWrite(pwmPin, 0);
  }
}

// ============================================================
//  Ballast Motor Helpers
// ============================================================

void ballastUp() {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  analogWrite(ENA, BALLAST_SPEED);
}

void ballastDown() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  analogWrite(ENA, BALLAST_SPEED);
}

void haltBallast() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  analogWrite(ENA, 0);
}
