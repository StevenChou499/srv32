#include <stdio.h>

int strStr(char *haystack, char *needle) {
    char *base = haystack;
    char *tmp = needle;
    int index = 0;
    while(*base) {
        while (*tmp && *tmp == *base) {
            tmp++;
            base++;
        }
        if(!*tmp)
            return index;
        index++;
        base = ++haystack;
        tmp = needle;
    }
    return -1;
}

int main(void)
{
    char *haystack = "I live my life a quarter mile at a time.";
    char *needle = "mile";
    int index = strStr(haystack, needle);
    printf("The index is %d.\n", index);
    
    return 0;
}