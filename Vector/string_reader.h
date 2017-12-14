#ifndef STRING_READER_H
#define STRing_READER_H

/*
 * String Reader.
 * This program reads newline-separated string from a file given as command line argument.
 *  The strings read are written out to stdout in lexicographically sorted order.
*/

//This function acts as a qsort compliant wrapper for strcmp.
int lexcmp(const void *s1_, const void *s2_);

#endif
