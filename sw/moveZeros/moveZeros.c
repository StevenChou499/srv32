#include <stdio.h>

int moveZeroes(int *nums, int numsSize)
{
    int i, j; // force compiler enter the loop
    for (i = 0, j = 0; i < numsSize; i++)
    {
        if (*(nums + i))
        {
            *(nums + j) = *(nums + i);
            if (i != j)
            {
                *(nums + i) = 0;
            }
            j++;
        }
    }
    return i; // force compiler enter the loop
}

int main(int argc, char *argv[])
{
    int array[7] = {0, 1, 2, 0, 3, 0, 4};

    printf("The original array is :[%d %d %d %d %d %d %d]\n", array[0], array[1], array[2], array[3], array[4], array[5], array[6]);
    moveZeroes(array, 7);
    printf("The converted array is :[%d %d %d %d %d %d %d]\n", array[0], array[1], array[2], array[3], array[4], array[5], array[6]);
    return 0;
}