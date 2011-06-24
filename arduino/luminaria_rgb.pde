#include <Ethernet.h>

#define LED_RGB_R 3
#define LED_RGB_G 5
#define LED_RGB_B 9
#define LED_WHITE 2

#define REQUEST_BUFFER_SIZE 20
#define STEPS 150.0
#define STEP_DELAY 10


byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 1, 111 };
char requestInfo[REQUEST_BUFFER_SIZE + 1];

Server server(80);
float red = 0, green = 0, blue = 0, previousRed, previousGreen, previousBlue;

int fromHexaCharToInt(char hexa) {
	if (hexa == 'a') {
		return 10;
	}
	else if (hexa == 'b') {
		return 11;
	}
	else if (hexa == 'c') {
		return 12;
	}
	else if (hexa == 'd') {
		return 13;
	}
	else if (hexa == 'e') {
		return 14;
	}
	else if (hexa == 'f') {
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
#ifdef DEBUG_LAMP
	Serial.begin(9600);
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
							float stepRed = (red - previousRed) / STEPS;
							float stepGreen = (green - previousGreen) / STEPS;
							float stepBlue = (blue - previousBlue) / STEPS;
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
						client.println("Change color");
					}
					break;
				}
				if (c == '\n') {
					current_line_is_blank = true;
				} else if (c != '\r') {
					current_line_is_blank = false;
				}
			}
		}
		delay(1);
		client.stop();
	}
}
