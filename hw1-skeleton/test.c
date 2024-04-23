#include<stdio.h>
#include <string.h>
#include <stdlib.h>
#include "floating.h"
union floating2 {
  uint16_t as_int;
  float as_float;
};
int main(){
	// union floating f;
	union floating2 f2;
	// f.as_float = 4.5;
	// char buf[256];
	// printf("%s\n", floating_info(f, buf, 256));

	f2.as_float = 4.5;
	printf("%d\n\n", f2.as_int);
	char buf2[256];
	printf("%s\n", ieee_16_info(f2.as_int, buf2, 256));
	return 0;
}