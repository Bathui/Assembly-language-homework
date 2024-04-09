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
  /* main in C should always return 0 as a way of telling
     whatever program invoked this that everything went OK.

     You should free the dictionary when done.
     */
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
unsigned int stringHash(void *s) {
  char *string = (char *)s;
  // create a hash function below. use polynomial rolling hash function
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
  int count = 0, max = 0, count_str = 0;
  char buffer2;
  fscanf(f1,"%c", &buffer2);
  while (!feof(f1)){
    if(buffer2 == '\n'){
      count=0;
      count_str++;
    }
    else{count++;}
    if(count>max)max = count;
    fscanf(f1,"%c", &buffer2);
  }
  max+=1;
  fseek(f1, 0, SEEK_SET);
  char** buffer = (char**)calloc((count_str+1),sizeof(char*));
  // printf("%s\n\n", buffer[7]);// test point
  for (int i = 0; i < (count_str+1); i++) {
    buffer[i] = (char*)calloc(max,sizeof(char));
    // printf("%d\n", max);
  }
  dictionary = createHashTable(count_str, &stringHash,&stringEquals);
  int* key_buff = (int*)calloc(count_str+1,sizeof(unsigned int));
  int i = 0;
  fscanf(f1, "%s", buffer[i]);
  key_buff[i] = stringHash(buffer[i]);
  // printf("%s\n", buffer[i]);
  // printf("%d\n", key_buff[i]);
  while(!feof(f1)){
    insertData(dictionary, buffer[i], &(key_buff[i]));
    i++;
    fscanf(f1, "%s", buffer[i]); 
    if (i<=count_str) key_buff[i] = stringHash(buffer[i]);
    
  }
  free(buffer);
  fclose(f1);
  // char asdff[] = "this";
  // printf("%d",*((int*)findData(dictionary, asdff)));
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
  char* temp = (char*)calloc(61, sizeof(char));
  int i = 0, count = 1;
  char temp2 = 0, temp3 = 0;
  while(1){
    if (i%59 == 0&&i!=0){
      count++;
      temp = (char*)realloc(temp, (60*count+1)*sizeof(char));
    }
    temp[i] = (char)getchar();
      // if(temp[i] == EOF){
      //   temp3 = temp[i];
      //   temp2 = 0;
      //   temp[i] = '\0';
      //   //test
      //   // temp = (char*)realloc(temp, (i+1)*sizeof(char));
      //   // printf("%s", temp);
      // }
      if(!((temp[i]>64&&temp[i]<91)||(temp[i]>96&&temp[i]<123))||temp[i] == EOF){
        temp2 = temp[i];
        if (temp[i] == EOF) {
          temp2 = 0;
          temp3 = EOF;
        }

        temp[i] = '\0';  
        // temp = (char*)realloc(temp, (i+1)*sizeof(char));
        i = -1;
        //test
        // printf("%s", temp);
        // if(temp2!=0) printf("%c", temp2);
      
      if(findData(dictionary, temp)){
        if(temp2!=0) {
          printf("%s", temp);
          printf("%c", temp2);
        }
        else{
          if (temp[0]!='\0'){
            printf("%s", temp);
          } 
        }
      }else{
          int length = strlen(temp);
          char * v2 = (char*)calloc(length+1,sizeof(char));
          strcpy(v2, temp);
          for (int k =1; k < strlen(v2);k++) {
              if(isupper(v2[k]))v2[k]+=32;
          }
          if(findData(dictionary, v2)!=NULL){
            if(temp2!=0) {
              printf("%s", temp);
              printf("%c", temp2);
            }
            else{
              if (temp[0]!='\0'){
              printf("%s", temp);
             } 
            }
          }else{
            if(isupper(v2[0]))v2[0]+=32;
            if(findData(dictionary, v2)!=NULL){
              printf("%s", temp);
              if(temp2!=0) printf("%c", temp2);
            }else{
              if (temp[0]=='\0'&&temp3!=EOF)printf("%c", temp2);
              else{
                if(temp2!=0) {
                  printf("%s [sic]", temp);
                  printf("%c", temp2);
                }
                else{
                  if (temp[0]!='\0'){
                    printf("%s [sic]", temp);
                  } 
                }
              }
            }
          }
          free(v2);
      }
      }
    i++;
    if (temp3==EOF) break;
  }
  free(temp);
}