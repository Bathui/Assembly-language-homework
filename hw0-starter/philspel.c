/*
 * Include the provided hashtable library.
 */
#include "hashtable.h"

/*
 * Include the header file.
 */
#include "philspel.h"

/*
 * Standard I/O and file routines.
 */
#include <stdio.h>

/*
 * General utility routines (including malloc()).
 */
#include <stdlib.h>

/*
 * Character utility routines.
 */
#include <ctype.h>

/*
 * String utility routines.
 */
#include <string.h>

/*
 * this hashtable stores the dictionary.  For this purpose you really
 * want to just use a set: "is a word in the dictionary or not", so
 * for storing data the keys should strings that represent valid words
 * and the associated data should also be the same string.
 */
HashTable *dictionary;

/*
 * the MAIN routine.  You can safely print debugging information
 * to standard error (stderr) and it will be ignored in the grading
 * process, in the same way which this does.
 */
int main(int argc, char **argv) {
  dictionary = createHashTable(200, &stringHash,&stringEquals);
  readDictionary(argv[1]);
  processInput();
  freeTable(dictionary);

  return 0;
}
// a simple power function for my hash function
int power(int a, int b){
  int temp = a;
  if(b==0)return 1;
  else if (b==1) return a;
  else{ 
    for(int i = 2; i < b+1; i++ ){
      a = a*temp;
    }
    return a;
  }
}
/*
 * You need to define this function. void *s can be safely casted
 * to a char * (NULL terminated string) which is done for you here for
 * convenience.
 */
// create a hash function below. I used one similar to polynomial rolling hash function
// The method refers to the website: https://www.geeksforgeeks.org/string-hashing-using-polynomial-rolling-hash-function/
unsigned int stringHash(void *s) {
  char *string = (char *)s;
  int p = 31;
  int hash_value = 0;
  if(strlen(string)==0) return 0;
  for (int i = 0; i < strlen(string); i++) {
    hash_value += (string[i] * power(p, i));
  }
  return hash_value;
}

/*
 * You need to define this function.  It should return a nonzero
 * value if the two strings are identical (case sensitive comparison)
 * and 0 otherwise.
 */
int stringEquals(void *s1, void *s2) {
  char *string1 = (char *)s1;
  char *string2 = (char *)s2;
  if (strcmp(string1, string2)==0) {
    return 1;
  }
  else return 0;
}

/*
 * this function should read in every word in the dictionary and
 * store it in the dictionary.  You should first open the file specified,
 * then read the words one at a time and insert them into the dictionary.
 * Once the file is read in completely, exit.  You will need to allocate
 * (using malloc()) space for each word.  As described in the specs, you
 * can initially assume that no word is longer than 60 characters.  However,
 * for the final 20% of your grade, you cannot assumed that words have a bounded
 * length.  You can NOT assume that the specified file exists.  If the file does
 * NOT exist, you should print some message to standard error and call exit(0)
 * to cleanly exit the program.
 *
 * Since the format is one word at a time, with returns in between,
 * you can safely use fscanf() to read in the strings until you want to handle
 * arbitrarily long dictionary chacaters.
 */
void readDictionary(char *filename) {
  FILE *f1 = fopen(filename, "r");
  if (f1 == NULL) {
    fprintf(stderr, "The file does not exist\n");
    exit(0);
  }
  char* buffer = NULL;
  while(1){
    int num = fscanf(f1, "%ms", &buffer);
    if (num == EOF) break;
    insertData(dictionary, buffer, buffer);
  }
  fclose(f1);
}
/*
 * This should process standard input and copy it to standard output
 * as specified in the specs.  EG, if a standard dictionary was used
 * and the string "this is a taest of  this-proGram" was given to
 * standard input, the output to standard output (stdout) should be
 * "this is a teast [sic] of  this-proGram".  All words should be checked
 * against the dictionary as they are input, again with all but the first
 * letter converted to lowercase, and finally with all letters converted
 * to lowercase.  Only if all 3 cases are not in the dictionary should it
 * be reported as not being found, by appending " [sic]" after the
 * error.
 *
 * Since we care about preserving whitespace, and pass on all non alphabet
 * characters untouched, and with all non alphabet characters acting as
 * word breaks, scanf() is probably insufficent (since it only considers
 * whitespace as breaking strings), so you will probably have
 * to get characters from standard input one at a time.
 *
 * As stated in the specs, you can initially assume that no word is longer than
 * 60 characters, but you may have strings of non-alphabetic characters (eg,
 * numbers, punctuation) which are longer than 60 characters. For the final 20%
 * of your grade,  you can no longer assume words have a bounded length.
 */
void processInput() {
  char* decision; // help us identify if the variations are found
  int i = 0;
  char appending[7] = " [sic]";
  char* temp = (char*)calloc(10, sizeof(char));
  int temp2;
  while (1) {
    if(i>59){
      temp = (char*)realloc(temp, (i+1)*sizeof(char));
    }
    temp2 = getchar();
    if (isalpha(temp2)){
      temp[i] = temp2;
      i++;
    } 
    else{
      int times = 0;
      temp[i] = '\0';
      if (temp[0]!='\0'){
        printf("%s", temp);
        decision = findData(dictionary, temp);
        if (decision == NULL) times++;
        for(int j = 1; j< strlen(temp);j++){
          temp[j] = tolower(temp[j]);
        }
        decision = findData(dictionary, temp);
        if (decision == NULL) times++;
        if (isupper(temp[0]))temp[0] = tolower(temp[0]);
        decision = findData(dictionary, temp);
        if (decision == NULL) times++;
        if (times==3){ // 3 means none of the variations are found
          printf("%s", appending);
        }
      }
        i = 0;
        free(temp);
        if (temp2==EOF) break;
        temp = (char*)calloc(61, sizeof(char));
        if (temp2!=EOF) printf("%c", temp2);
    }
  }  
}
