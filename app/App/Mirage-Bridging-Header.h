// The game itself is joshuatree's user/mirage.c (built here with MIRAGE_EMBED): three calls, one picture.
unsigned *mirage_start(int w, int h);   // a fresh game drawn into a w by h buffer of 0x00RRGGBB pixels
void mirage_key(int code, unsigned tick); // a key press (user/jtsys.h codes) at tick
int mirage_tick(unsigned tick);           // the clock reached tick (100 a second); 1 when it drew a new frame
