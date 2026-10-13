#include <stdio.h>
extern int adsp_default_listener_start(int argc, char *argv[]);
int main(int argc, char *argv[]){
  printf("snsrpcd: starting listener for args:");
  for(int i=1;i<argc;i++) printf(" %s", argv[i]);
  printf("\n"); fflush(stdout);
  int r = adsp_default_listener_start(argc, argv);
  printf("snsrpcd: listener_start returned %d\n", r);
  return r;
}
