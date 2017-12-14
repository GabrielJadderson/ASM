#include "vector.h"
#include <stdio.h>

/*
* Dynamic vector, with amortized constant time O(n) insertion
* Authors: Gabriel Howard Jadderson (gajad16@student.sdu.dk), Patrick Jakobsen (pajak16@student.sdu.dk)
*/

/*
* Prints the array, given the array and it's length.
* returns printf of (index, pointer, dereferenced int pointer)
* This function proved handy for debugging our vector
*/
void printVector(Vector *v) {
  if(v != NULL) { //check if null before printing as printf with %i and others will result in undefined behaviour
    for (int i = 0; i < v->size; i++) {
      printf("vbuffer: [i: %u, element ptr: %p, element deref: %d], Size: %zu, Capacity: %zu\n",
      i, &v->vbuffer[i], *(int*)v->vbuffer[i], v->size, v->capacity);
      printf("actual size in bytes %zu\n", (v->size) * sizeof(void *)); //This is the actual size in bytes, the other is the spare room in bytes.
      printf("total size in bytes %zu\n", v->capacity * sizeof(void *)); //just for extra debugging.
    }
  } else {
    printf("Attempt to print NULL vector.\n");
    exit(1);
  }
}

/*
* Initialize a vector to be empty
* Pre: 'vector' != NULL
* Initialize the vector.
* allocate and assign memory for the array and assign it's elements.
*/
void vector_init(Vector *vector) {
  if (vector != NULL/* && vector->initialized == 0*/) {
    vector->size = (size_t) 0; //reset size to 0;
    vector->capacity = (size_t) 10; // set the initial capacity to 10;
    vector->vbuffer = malloc(sizeof(void *) * vector->capacity); //allocate memory on the heap.
    if (vector->vbuffer == 0) {printf("Failed to allocate memory.\n");exit(1);} //failsafe for malloc, in case memory is full etc.
    //printf("Vector initialized\n");
  }
  else {
    printf("Failed to initialize vector, vector is null or vector already initialized\n"); //if null then exit
    exit(1);
  }
}
// Deallocate internal structures of the vector
// Note: the user is responsible for deleting all values
// Note: the user is responsible for deleting the actual vector if it was dynamically allocated
void vector_delete(Vector *vector) {
  if(vector != NULL) {
    free(vector->vbuffer);   // free the allocated memory
    vector->capacity = 0;    // reset capacity
    vector->size = 0;        // reset size
  } else {
    printf("Failed to delete vector, vector might not have been initialized.\n");
    exit(1);
  }
}

// Insert a new element at the end of the vector
// Pre: 'vector' != NULL
void vector_push(Vector *vector, void *value) {
  if (vector != NULL && value != NULL) { // make sure the passed in parameters are valid
      if (vector->size >= vector->capacity) {
        size_t newCapacity = vector->capacity * 2; //resize 2n

        if (newCapacity <= vector->capacity) { printf("vector overflow.\n"); exit(1); } // handle overflowing, if vector is deleted and someone pushes into it, this will trigger.

        vector->vbuffer = realloc(vector->vbuffer, sizeof(void *) * newCapacity); // realloc is nice :)

        if (vector->vbuffer == NULL) { printf("failed to allocate memory for vector resize.\n"); exit(1); } // handle realloc failure.

        vector->capacity = newCapacity; //update to the new capacity
      }
      vector->vbuffer[vector->size] = value; // update the last element in the vector to the value given.
      vector->size++; // increment the size for future pushes.
  }
  else {
    printf("Vector is null, not initialized or value may be null\n");
    exit(1);
  }
}

// Remove the last element in the vector and return the value
// Pre: the vector is non-empty, 'vector' != NULL
void *vector_pop(Vector *vector){
  if (vector != NULL && vector->size >= 1) { // first we check if the vector is not null and that the size of the vector is valid.
    void *element = vector->vbuffer[vector->size -1]; // put void * element on the stack and retrieve the last element from our buffer and assign it to element.
    vector->size = vector->size - 1; //decrement the size since we've popped it.
    return element; // return to user.
  }
  else {
    printf("Vector is null or not initialized.\n");
    exit(1);
  }
}

// Return the number of elements in the vector
// Pre: 'vector' != NULL
size_t vector_size(const Vector *vector){
  if (vector != NULL) //check for null
    return vector->size; // return to user.
  else {
    printf("Vector is null or not initialized.\n");
    exit(1);
  }
}

// Return the current capacity of the vector
// Pre: 'vector' != NULL
size_t vector_capacity(const Vector *vector) {
  if (vector != NULL) //check for null
    return vector->capacity; //return to user
  else {
    printf("Vector is null or not initialized.\n");
    exit(1);
  }
}

// Return the value at the given index
// Pre: index < vector_size(vector)
void *vector_get_element(const Vector *vector, size_t index) {
  if (vector != NULL && index < vector->size) // check if the vector is null, and the given index is less than the vector size.
    return vector->vbuffer[index]; //return the given index in the buffer.
  else {
    printf("Vector is null, not initialized or index >= size.\n");
    exit(1);
  }
}

// Return a pointer to the underlying array
void **vector_get_array(const Vector *vector) {
  if(vector != NULL) { // Not explicitly stated as a prerequisite. Should still check this though.
    return vector->vbuffer; // return the actual.
  } else {
    printf("Attempt to access array of NULL vector.\n");
    exit(1);
  }
}
