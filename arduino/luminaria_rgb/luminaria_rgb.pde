#include <SPI.h>
#include <Ethernet.h>

#define LED_WHITE 3
#define LED_RGB_R 5
#define LED_RGB_G 6
#define LED_RGB_B 9

#define REQUEST_BUFFER_SIZE 25
#define STEPS 150.0
#define STEP_DELAY 10
#define PRIVATE_DELAY 50
#define TUNZTUNZ_DELAY 50
#define RANDOM_DELAY 50


byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 10, 111 };
char requestInfo[REQUEST_BUFFER_SIZE + 1];

Server server(80);
float previousRed = 0, previousGreen = 0, previousBlue = 0, previousWhite = 0, previousTuntzTuntzValue = 0;
int privateMode = false, tuntztuntzMode = false, randomMode = false, privateMultiplierRed, privateMultiplierBlue, privateModeFade;
unsigned long privateTime, tuntztuntzTime, randomTime;

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

int adjustColor(int color) {
	int newColor = map(color, 0, 255, 0, 50);
	newColor = map(newColor, 0, 50, 0, 255);
	return newColor;
}

void changeAllStates(int newState) {
	digitalWrite(LED_RGB_R, newState);
	digitalWrite(LED_RGB_G, newState);
	digitalWrite(LED_RGB_B, newState);
	digitalWrite(LED_WHITE, newState);
}

void fadeAll(int red, int green, int blue, int white, int steps, int stepDelay) {
	float stepRed = (red - previousRed) / steps;
	float stepGreen = (green - previousGreen) / steps;
	float stepBlue = (blue - previousBlue) / steps;
	float stepWhite = (white - previousWhite) / steps;
	for (int i = 0; i < steps; i++) {
		previousRed += stepRed;
		previousGreen += stepGreen;
		previousBlue += stepBlue;
		previousWhite += stepWhite;
		analogWrite(LED_RGB_R, previousRed);
		analogWrite(LED_RGB_G, previousGreen);
		analogWrite(LED_RGB_B, previousBlue);
		analogWrite(LED_WHITE, previousWhite);
		delay(stepDelay);
	}
	analogWrite(LED_RGB_R, red);
	analogWrite(LED_RGB_G, green);
	analogWrite(LED_RGB_B, blue);
	analogWrite(LED_WHITE, white);
#ifdef DEBUG_LAMP
	Serial.println("fadeAll done.");
#endif
}

void setup() {
	Ethernet.begin(mac, ip);
	server.begin();
	pinMode(LED_RGB_R, OUTPUT);
	pinMode(LED_RGB_G, OUTPUT);
	pinMode(LED_RGB_B, OUTPUT);
	pinMode(LED_WHITE, OUTPUT);  
	changeAllStates(LOW);
	srand(analogRead(1));
#ifdef DEBUG_LAMP
	Serial.begin(9600);
	Serial.println("Starting web server...");
#endif
}


#ifdef DEBUG_LAMP
void debug(uint8_t r, uint8_t g, uint8_t b, uint8_t w) {
	char r2[4], g2[4], b2[4], w2[4];
	sprintf(r2, "%03d", r);
	sprintf(g2, "%03d", g);
	sprintf(b2, "%03d", b);
	sprintf(w2, "%03d", w);
	Serial.print(r2);
	Serial.print(" ");
	Serial.print(g2);
	Serial.print(" ");
	Serial.print(b2);
	Serial.print(" ");
	Serial.println(w2);
}
#endif

void loop() {
#ifdef DEBUG_LAMP
	Serial.println("Running loop");
#endif
	Client client = server.available();
	if (client) {
#ifdef DEBUG_LAMP
		Serial.println("Client connected");
#endif
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
#ifdef DEBUG_LAMP
					Serial.println(requestInfo);
#endif
					client.println("HTTP/1.1 200 OK");
					client.println("Content-Type: text/html");
					client.println();
					if (strncmp("GET /LED-", requestInfo, 9) == 0) {
						int red = adjustColor(fromHexaCharToInt(requestInfo[9]) * 16 + fromHexaCharToInt(requestInfo[10]));
						int green = adjustColor(fromHexaCharToInt(requestInfo[11]) * 16 + fromHexaCharToInt(requestInfo[12]));
						int blue = adjustColor(fromHexaCharToInt(requestInfo[13]) * 16 + fromHexaCharToInt(requestInfo[14]));
						int white;
						if (red == 255 && green == 255 && blue == 255) {
							red = 0;
							green = 0;
							blue = 0;
							white = 255;
							fadeAll(0, 0, 0, 0, STEPS, STEP_DELAY);
						}
						else {
							white = 0;
						}
#ifdef DEBUG_LAMP
						debug(red, green, blue, white);
#endif
						fadeAll(red, green, blue, white, STEPS, STEP_DELAY);
						previousRed = red;
						previousGreen = green;
						previousBlue = blue;
						previousWhite = white;
						privateMode = false;
						tuntztuntzMode = false;
						randomMode = false;
						client.println("Cor Solida");
					}
					else if (strncmp("GET /modo-intimo", requestInfo, 16) == 0) {
						privateTime = millis() - PRIVATE_DELAY;
						privateModeFade = 170;
						privateMode = true;
						tuntztuntzMode = false;
						randomMode = false;
						client.println("Private mode ON!");
					}
					else if (strncmp("GET /dance", requestInfo, 10) == 0) {
						tuntztuntzTime = millis();
						changeAllStates(LOW);							
						privateMode = false;
						tuntztuntzMode = true;
						randomMode = false;
						client.println("Tuntz tuntz mode ON!");
					}
					else if (strncmp("GET /aleatorio", requestInfo, 14) == 0) {
						randomTime = millis();
						randomMode = true;
						privateMode = false;
						tuntztuntzMode = false;
						client.println("Random mode ON!");
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
		if (millis() - privateTime >= PRIVATE_DELAY) {
			if (privateModeFade == 255) {
				fadeAll(170, 0, 170, 0, STEPS, PRIVATE_DELAY);
				privateModeFade = 170;
			}
			else if (privateModeFade == 170) {
				fadeAll(30, 0, 30, 0, STEPS, PRIVATE_DELAY);
				privateModeFade = 30;
			}
			else if (privateModeFade == 30) {
				fadeAll(150, 0, 150, 0, STEPS, PRIVATE_DELAY);
				privateModeFade = 150;
			}
			else if (privateModeFade == 150) {
				fadeAll(255, 0, 255, 0, STEPS, PRIVATE_DELAY);
				privateModeFade = 255;
			}
			privateTime = millis();
#ifdef DEBUG_LAMP
			debug(previousRed, 0, previousBlue, 0);
#endif
		}
	}

	else if (tuntztuntzMode == true) {
		if (millis() - tuntztuntzTime >= TUNZTUNZ_DELAY) {
			tuntztuntzTime = millis();
			if (rand() % 100 <= 10) {
				tuntztuntzTime -= rand() % 500;
			}
			if (previousTuntzTuntzValue == 0) {
				previousTuntzTuntzValue = 127;
			}
			else {
				previousTuntzTuntzValue = 0;
			}
			analogWrite(LED_RGB_R, previousTuntzTuntzValue);
			analogWrite(LED_RGB_G, previousTuntzTuntzValue);
			analogWrite(LED_RGB_B, previousTuntzTuntzValue);
			analogWrite(LED_WHITE, previousTuntzTuntzValue);
		}
	}
	else if (randomMode == true) {
		if (millis() - randomTime >= RANDOM_DELAY) {
			int red = adjustColor(rand() % 256);
			int green = adjustColor(rand() % 256);
			int blue = adjustColor(rand() % 256);
			int white;
			if (red == 255 && green == 255 && blue == 255) {
				red = 0;
				green = 0;
				blue = 0;
				white = 255;
				fadeAll(0, 0, 0, 0, STEPS, RANDOM_DELAY);
			}
			else {
				white = 0;
			}
			fadeAll(red, green, blue, white, STEPS, RANDOM_DELAY);
			randomTime = millis();
			previousRed = red;
			previousGreen = green;
			previousBlue = blue;
			previousWhite = white;
#ifdef DEBUG_LAMP
			debug(red, green, blue, white);
#endif
		}	
	}
}
