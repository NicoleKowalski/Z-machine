#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern void asm_main();
extern void send_to_UART();

int test(int i);
int getSizeNum(int binaryFromRegister);
char getNextChar();
int getSizeofHex(int binaryFromRegister);
int mod(int a, int b);
int divide(int a, int b);
int multiply(int a, int b);
int random_number(int a);

char charToPrint[10];
int count = -1;

int main(){
	/*for(int i = 90; i < 122; i++){
		test(i);
		send_to_UART();
	}*/
	asm_main();
	return 0;

}

int test(int i){
	return i;
}

int getSizeNum(int binaryFromRegister){
	strcpy(charToPrint, "");
	count = -1;
	int n =  sprintf(charToPrint, "%d", binaryFromRegister);
	return n;
}

char getNextChar(){
	return charToPrint[++count];
}

int getSizeofHex(int binaryFromRegister){
	strcpy(charToPrint, "");
	count = -1;
	int n = 0;
	n = sprintf(charToPrint, "%02x", binaryFromRegister);
	return n;
}

int mod(int a, int b){
	return a%b;
}

int divide(int a, int b){
	return a/b;
}

int multiply(int a, int b){
	return a*b;
}

int random_number(int a){
	return rand() % (a+1-0) + 0;
}
