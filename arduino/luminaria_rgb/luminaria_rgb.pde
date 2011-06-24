#include <Ethernet.h>

#define LED_WHITE 3
#define LED_RGB_R 5
#define LED_RGB_G 6
#define LED_RGB_B 9

#define REQUEST_BUFFER_SIZE 25
#define STEPS 150.0
#define STEP_DELAY 10
#define TUNZTUNZ_DELAY 50


byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 10, 2 };
char requestInfo[REQUEST_BUFFER_SIZE + 1];

Server server(80);
float red = 0, green = 0, blue = 0, previousRed, previousGreen, previousBlue, stepRed, stepGreen, stepBlue;
int privateMode = false, tuntztuntzMode = false, randomMode = false;
unsigned long privateTime, tuntztuntzTime;

int fromHexaCharToInt(char hexa) {
        if (hexa == 'a' || hexa == 'A') {
                return 10;
        }
        else if (hexa == 'b' || hexa == 'B') {
                return 11;
        }
        else if (hexa == 'c' || hexa == 'C') {
                return 12;
        }
        else if (hexa == 'd' || hexa == 'D') {
                return 13;
        }
        else if (hexa == 'e' || hexa == 'E') {
                return 14;
        }
        else if (hexa == 'f' || hexa == 'F') {
                return 15;
        }
        else {
                return atoi(&hexa);
        }
}

void setup() {
	Ethernet.begin(mac, ip);
	server.begin();
	pinMode(LED_RGB_R, OUTPUT);
	pinMode(LED_RGB_G, OUTPUT);
	pinMode(LED_RGB_B, OUTPUT);
	pinMode(LED_WHITE, OUTPUT);  
	digitalWrite(LED_RGB_R, LOW);
	digitalWrite(LED_RGB_G, LOW);
	digitalWrite(LED_RGB_B, LOW);
	digitalWrite(LED_WHITE, LOW);
	srand(analogRead(1));
#ifdef DEBUG_LAMP
	Serial.begin(9600);
        Serial.println("Starting web server...");
#endif
}


#ifdef DEBUG_LAMP
void debug(uint8_t r, uint8_t g, uint8_t b) {
	char r2[4], g2[4], b2[4];
	sprintf(r2, "%03d", r);
	sprintf(g2, "%03d", g);
	sprintf(b2, "%03d", b);
	Serial.print(r2);
	Serial.print(" ");
	Serial.print(g2);
	Serial.print(" ");
	Serial.println(b2);
}
#endif

void loop() {
	Client client = server.available();
	if (client) {
		int i = 0;
		boolean current_line_is_blank = true;
		requestInfo[REQUEST_BUFFER_SIZE] = '\0';
		while (client.connected()) {
			if (client.available()) {
				char c = client.read();
				if (i < REQUEST_BUFFER_SIZE) {
					requestInfo[i] = c;
					i++;
				}
				if (c == '\n' && current_line_is_blank) {
					client.println("HTTP/1.1 200 OK");
					client.println("Content-Type: text/html");
					client.println();
#ifdef DEBUG_LAMP
                                        Serial.println(requestInfo);
#endif
					if (strncmp("GET /LED-", requestInfo, 9) == 0) {
						previousRed = red;
						previousGreen = green;
						previousBlue = blue;
						red = fromHexaCharToInt(requestInfo[9]) * 16 + fromHexaCharToInt(requestInfo[10]);
						green = fromHexaCharToInt(requestInfo[11]) * 16 + fromHexaCharToInt(requestInfo[12]);
						blue = fromHexaCharToInt(requestInfo[13]) * 16 + fromHexaCharToInt(requestInfo[14]);
#ifdef DEBUG_LAMP
						debug(red, green, blue);
#endif
						red = map(red, 0, 255, 0, 50);
						green = map(green, 0, 255, 0, 50);
						blue = map(blue, 0, 255, 0, 50);
						red = map(red, 0, 50, 0, 255);
						green = map(green, 0, 50, 0, 255);
						blue = map(blue, 0, 50, 0, 255);
#ifdef DEBUG_LAMP
						debug(red, green, blue);
#endif
						if (red == 255 && green == 255 && blue == 255) {
							int stepRed = (255 - previousRed) / STEPS;
							int stepGreen = (255 - previousGreen) / STEPS;
							int stepBlue = (255 - previousBlue) / STEPS;
							digitalWrite(LED_WHITE, LOW);
							for (int i = 0; i < STEPS; i++) {
								previousRed += stepRed;
								previousGreen += stepGreen;
								previousBlue += stepBlue;
								analogWrite(LED_RGB_R, previousRed);
								analogWrite(LED_RGB_G, previousGreen);
								analogWrite(LED_RGB_B, previousBlue);
								delay(STEP_DELAY);
							}
							digitalWrite(LED_WHITE, HIGH);              
							digitalWrite(LED_RGB_R, 0);
							digitalWrite(LED_RGB_G, 0);
							digitalWrite(LED_RGB_B, 0);
						}
						else {
							stepRed = (red - previousRed) / STEPS;
							stepGreen = (green - previousGreen) / STEPS;
							stepBlue = (blue - previousBlue) / STEPS;
							digitalWrite(LED_WHITE, 0);
							for (int i = 0; i < STEPS; i++) {
								previousRed += stepRed;
								previousGreen += stepGreen;
								previousBlue += stepBlue;
								analogWrite(LED_RGB_R, previousRed);
								analogWrite(LED_RGB_G, previousGreen);
								analogWrite(LED_RGB_B, previousBlue);
								delay(STEP_DELAY);
							}
							analogWrite(LED_RGB_R, red);
							analogWrite(LED_RGB_G, green);
							analogWrite(LED_RGB_B, blue);
						}
						client.println("Changed color");
						privateMode = false;
						tuntztuntzMode = false;
						randomMode = false;
					}
 					else if (strncmp("GET /modo-intimo", requestInfo, 16) == 0) {
						privateMode = true;
						tuntztuntzMode = false;
						randomMode = false;
						privateTime = millis();
						stepRed = (255 - previousRed) / STEPS;
						stepBlue = (255 - previousBlue) / STEPS;
						digitalWrite(LED_WHITE, LOW);
						digitalWrite(LED_RGB_G, LOW);
						client.println("Private mode ON!");
 					}
					else if (strncmp("GET /dance", requestInfo, 10) == 0) {
						privateMode = false;
						tuntztuntzMode = true;
						randomMode = false;
						tuntztuntzTime = millis();
						digitalWrite(LED_WHITE, HIGH);
						digitalWrite(LED_RGB_R, HIGH);
						digitalWrite(LED_RGB_B, HIGH);
						digitalWrite(LED_RGB_G, HIGH);
						client.println("Tuntz tuntz mode ON!");
 					}
					else if (strncmp("GET /aleatorio", requestInfo, 14) == 0) {
						client.println("Random mode ON!");
						randomMode = true;
						privateMode = false;
						tuntztuntzMode = false;
					}
					break;
				}
				if (c == '\n') {
					current_line_is_blank = true;
				}
				else if (c != '\r') {
					current_line_is_blank = false;
				}
			}
		}
		delay(1);
		client.stop();
	}
	if (privateMode == true) {
		if (millis() - privateTime >= STEP_DELAY) {
			privateTime = millis();
			previousRed += stepRed;
			previousBlue += stepBlue;
			if (previousRed >= 255) {
				stepRed = - 255 / STEPS;
				previousRed += stepRed;
			}
			if (previousBlue >= 255) {
				stepBlue = - 255 / STEPS;
				previousBlue += stepBlue;
			}

			if (previousRed <= 30) {
				stepRed = 255 / STEPS;
				previousRed += stepRed;
			}
			if (previousBlue <= 30) {
				stepBlue = 255 / STEPS;
				previousBlue += stepBlue;
			}
			analogWrite(LED_RGB_R, previousRed);
			analogWrite(LED_RGB_G, 0);
			analogWrite(LED_RGB_B, previousBlue);
		}
	}

	else if (tuntztuntzMode == true) {
		if (millis() - tuntztuntzTime >= TUNZTUNZ_DELAY) {
			int newState = !digitalRead(LED_RGB_R);
			tuntztuntzTime = millis();
			if (rand() % 100 <= 10) {
  				tuntztuntzTime -= rand() % 500;
			}
			digitalWrite(LED_RGB_R, newState);
			digitalWrite(LED_RGB_G, newState);
			digitalWrite(LED_RGB_B, newState);
			digitalWrite(LED_WHITE, newState);
		}
	}
	else if (randomMode == true) {
		previousRed = red;
		previousGreen = green;
		previousBlue = blue;
		red = rand() % 256;
		green = rand() % 256;
		blue = rand() % 256;
#ifdef DEBUG_LAMP
		debug(red, green, blue);
#endif
		red = map(red, 0, 255, 0, 50);
		green = map(green, 0, 255, 0, 50);
		blue = map(blue, 0, 255, 0, 50);
		red = map(red, 0, 50, 0, 255);
		green = map(green, 0, 50, 0, 255);
		blue = map(blue, 0, 50, 0, 255);
#ifdef DEBUG_LAMP
		debug(red, green, blue);
#endif
		if (red == 255 && green == 255 && blue == 255) {
			int stepRed = (255 - previousRed) / STEPS;
			int stepGreen = (255 - previousGreen) / STEPS;
			int stepBlue = (255 - previousBlue) / STEPS;
			digitalWrite(LED_WHITE, LOW);
			for (int i = 0; i < STEPS; i++) {
				previousRed += stepRed;
				previousGreen += stepGreen;
				previousBlue += stepBlue;
				analogWrite(LED_RGB_R, previousRed);
				analogWrite(LED_RGB_G, previousGreen);
				analogWrite(LED_RGB_B, previousBlue);
				delay(STEP_DELAY);
			}
			digitalWrite(LED_WHITE, HIGH);              
			digitalWrite(LED_RGB_R, 0);
			digitalWrite(LED_RGB_G, 0);
			digitalWrite(LED_RGB_B, 0);
		}
		else {
			stepRed = (red - previousRed) / STEPS;
			stepGreen = (green - previousGreen) / STEPS;
			stepBlue = (blue - previousBlue) / STEPS;
			digitalWrite(LED_WHITE, 0);
			for (int i = 0; i < STEPS; i++) {
				previousRed += stepRed;
				previousGreen += stepGreen;
				previousBlue += stepBlue;
				analogWrite(LED_RGB_R, previousRed);
				analogWrite(LED_RGB_G, previousGreen);
				analogWrite(LED_RGB_B, previousBlue);
				delay(STEP_DELAY);
			}
			analogWrite(LED_RGB_R, red);
			analogWrite(LED_RGB_G, green);
			analogWrite(LED_RGB_B, blue);
		}
		privateMode = false;
		tuntztuntzMode = false;
		randomMode = true;
	}
}
