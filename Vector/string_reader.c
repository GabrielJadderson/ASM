#include <string.h>

#include "string_reader.h"
#include "vector.h"

extern void printVector(Vector *v);

int lexcmp(const void *s1_, const void *s2_) {
  
  char *s1 = *(char**)s1_;
  char *s2 = *(char**)s2_;
  
  int cmp = strcmp(s1,s2);
  
  //printf("LEXCMP: %s %s %d\n", s1, s2, cmp);
  
  if(cmp > 0) {return 1;}
  if(cmp < 0) {return -1;}
  return 0;
}

int main(int argc,char **argv) {
  
  if(argc < 2) {
    fprintf(stderr, "ERROR: NO INPUT ARGUMENT GIVEN.\n");
    return 1;
  }
  
  FILE *f = fopen(argv[1], "r");
  if(f == NULL) {
    fprintf(stderr, "ERROR: UNABLE TO READ FILE.\n");
    return 1;
  }
  
  Vector stringVector;
  vector_init(&stringVector);
  
  char *inStr; // = malloc(sizeof(char) * 1024);
  //char inStr[1024]; //Buffer
  
  //int code = fscanf(f, "%[^\n]", inStr);
  //printf("#args successfully filled: %d\n", code);
  
  //printf("> READING INPUT FILE:\n");
  /*while(fscanf(f, "%[^\n]\n", inStr) > 0) {
    //printf("String read: %s\n", inStr);
    vector_push(&stringVector, inStr);
    inStr = malloc(sizeof(char) * 1024);
  }*/
  
  while(feof(f) == 0) {
    inStr = malloc(sizeof(char) * 1024);
    fgets(inStr, sizeof(char) * 1024, f);
    vector_push(&stringVector, inStr);
  }
  
  
  
  //int code = fscanf(f, "%[^\n]\n", inStr);
  //printf("#args successfully filled: %d\n", code);
  //printf("%s\n", inStr);
  
  //printVector(&stringVector);
  /*
  for(int i = 0; i < vector_size(&stringVector); i++) {
    printf("%s\n", (char*) vector_get_element(&stringVector, i));
  }*/
  
  //vector_get_array(&stringVector);
  
  //printf("     %p");
  
  qsort(vector_get_array(&stringVector), vector_size(&stringVector), sizeof(char*), lexcmp);
  
  //printf("-----\n");
  
  for(int i = 0; i < vector_size(&stringVector); i++) {
    printf("%s", (char*) vector_get_element(&stringVector, i));
  }
  /*
  char* s1 = "ava";
  char* s2 = "vsd";
  
  printf("%d %d\n", strcmp(s1, s2), lexcmp((void*)s1, (void*)s2));
  
  */
  
  fclose(f);
  
  
  
  return 0;
}











