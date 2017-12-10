#include "vector.h"
#include <stdio.h>

/*
* Amortized dynamic vector, with constant time O(n) insertion
* Authors: Gabriel Howard Jadderson (gajad16@student.sdu.dk), Patrick Jakobsen (pajak16@student.sdu.dk)
*/

/*
* Prints the array, given the array and it's length.
* returns printf of (index, pointer, dereferenced int pointer)
*/
void printVector(Vector *v) {
  for (int i = 0; i < v->size; i++)
    printf("vbuffer: [i: %u, element ptr: %p, element deref: %d], Size: %zu, Capacity: %zu\n",
    i, &v->vbuffer[i], *(int*)v->vbuffer[i], v->size, v->capacity);
    printf("actual size in bytes %zu\n", (v->capacity-v->size) * sizeof(void *));
    printf("total size in bytes %zu\n", v->capacity * sizeof(void *));
}

/*
* Initialize a vector to be empty
* Pre: 'vector' != NULL
* Initialize the vector.
* allocate and assign memory for the array and assign it's elements.
*/
void vector_init(Vector *vector) {
  if (vector->initialized == 0) {
    vector->initialized = 1; // mark the vector initialized.
    vector->size = (size_t) 0; //reset size to 0;
    vector->capacity = (size_t) 10; // set the initial capacity to 10;
    void *ptr = (int*) 42; //we'll assign all start elements a void ptr of int 0.
    void *nu;
    vector->vbuffer = malloc(sizeof(void *) * vector->capacity); //allocate memory on the heap.
    if (vector->vbuffer == 0) {printf("Failed to allocate memory.\n");exit(1);}
    for (int i = 0; i < vector->capacity -5; i++) {
      vector_push(vector, &ptr);
    }
    printf("Vector initialized\n");
  }
  else
    printf("Failed to initialize vector, vector already initialized\n");

}
// Deallocate internal structures of the vector
// Note: the user is responsible for deleting all values
// Note: the user is responsible for deleting the actual vector if it was dynamically allocated
void vector_delete(Vector *vector) {
  if (vector->initialized == 1) {
    free(vector->vbuffer);
    vector->capacity = 0;    // reset capacity
    vector->size = 0;        // reset size
    vector->initialized = 0; // reset initialisation, this way we can reinintialize the vector again.
    printf("Vector deleted\n");
  } else
  printf("Failed to delete vector, vector might not have been initialized.\n");
}


// Insert a new element at the end of the vector
// Pre: 'vector' != NULL
void vector_push(Vector *vector, void *value) {
  if (vector && value && vector->initialized == 1) {
      if (vector->size >= vector->capacity - 1) {
        //rezize
        size_t newCapacity = vector->capacity * 2; //2n1

        if (newCapacity <= vector->capacity) { printf("vector overflow.\n"); exit(1); }

        vector->vbuffer = realloc(vector->vbuffer, sizeof(void *) * newCapacity); // realloc is nice :)

        if (vector->vbuffer == NULL) { printf("failed to allocate memory for vector resize.\n"); exit(1); }

        printf("Capacity doubled from %zu to %zu\n", vector->capacity, newCapacity);
        vector->capacity = newCapacity;
      }

      //vector->vbuffer[0] = value;

      //vector->size++;
      vector->vbuffer[vector->size] = value;
      vector->size++;
  }
  else
  printf("Vector is null or not initialized.\n");
}

// Remove the last element in the vector and return the value
// Pre: the vector is non-empty, 'vector' != NULL
void *vector_pop(Vector *vector){
  if (vector && vector->initialized == 1 && vector->size >= 1) {
    void *element = vector->vbuffer[vector->size -1];
    vector->size = vector->size - 1;
    return element;
  }
  else
    printf("Vector is null or not initialized.\n");
}

// Return the number of elements in the vector
// Pre: 'vector' != NULL
size_t vector_size(const Vector *vector){
  if (vector && vector->initialized)
    return vector->size;
  else
    printf("Vector is null or not initialized.\n");
}

// Return the current capacity of the vector
// Pre: 'vector' != NULL
size_t vector_capacity(const Vector *vector) {
  if (vector && vector->initialized)
    return vector->capacity;
  else
    printf("Vector is null or not initialized.\n");
}

// Return the value at the given index
// Pre: index < vector_size(vector)
void *vector_get_element(const Vector *vector, size_t index) {
  if (vector && vector->initialized && index < vector->size)
    return vector->vbuffer[index];
  else
    printf("Vector is null, not initialized or index >= size.\n");
}

// Return a pointer to the underlying array
void **vector_get_array(const Vector *vector) {
  return vector->vbuffer;
}


int main(int argc, char const *argv[]) {

  Vector v;

  vector_init(&v);

  printVector(&v);

  void *ptr = (int*) 52;
  void *ptr5 = (int*) 765;
  void *ptr6 = (int*) 981228;
  void *ptr7 = (int*) 343323;
  void *ptr8 = (int*) 4555;
  vector_push(&v, &ptr);
  vector_push(&v, &ptr5);
  vector_push(&v, &ptr6);
  vector_push(&v, &ptr7);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);

  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);

  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);

  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);

  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);
  vector_push(&v, &ptr8);

  printVector(&v);

  printf("%i\n", *(int*)vector_get_element(&v, 5));

  void *poped = vector_pop(&v);
  printf("%p, %i\n", &poped, *(int*)poped);

  void *pope = vector_pop(&v);
  printf("%p, %i\n", &pope, *(int*)pope);


  printf("Capacity: %zu\n", vector_capacity(&v));
  printf("Size: %zu\n", vector_size(&v));

  //vector_delete(&v);
  //printf("%zu, %zu\n", v.size, v.capacity);
  //printVector(&v);

  getchar();

  return 0;
}
