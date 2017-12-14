#include <stdio.h>
#include <string.h>

#include "string_reader.h"
#include "vector.h"

//This function acts as a qsort compliant wrapper for strcmp.
int lexcmp(const void *s1_, const void *s2_) {
  //Get the data values in the format required by strcmp.
  char *s1 = *(char**)s1_;
  char *s2 = *(char**)s2_;

  //Do the actual comparison.
  int cmp = strcmp(s1,s2);

  //Set the return value. The magnitude shouldn't be significant, but this is the format found in various documentation of qsort and comparators.
  if(cmp > 0) {return 1;}
  if(cmp < 0) {return -1;}
  return 0;
}

//Actual string reader program.
int main(int argc,char **argv) {

  //Sanity check.
  if(argc < 2) {
    fprintf(stderr, "ERROR: NO INPUT ARGUMENT GIVEN.\n");
    return 1;
  }

  //Open the file and abort if it cannot be opened.
  FILE *f = fopen(argv[1], "r");
  if(f == NULL) {
    fprintf(stderr, "ERROR: UNABLE TO READ FILE.\n");
    return 1;
  }

  //Set up the vector.
  Vector stringVector;
  vector_init(&stringVector);

  //Input string.
  char *inStr;

  //Read all lines in the file into the vector.
  while(feof(f) == 0) {
    inStr = (char*) malloc(sizeof(char) * 1024);
    fgets(inStr, sizeof(char) * 1024, f);
    vector_push(&stringVector, inStr);
  }

  //Sort with quicksort, using the comparator above.
  qsort(vector_get_array(&stringVector), vector_size(&stringVector), sizeof(char*), lexcmp);

  //Write out all the strings.
  for(size_t i = 0; i < vector_size(&stringVector); i++) {
    printf("%s", (char*) vector_get_element(&stringVector, i));
  }

  //Neatly close the file.
  fclose(f);

  //We're done. Signal successful execution.
  return 0;
}
