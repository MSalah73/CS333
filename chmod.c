#include "types.h"
#include "user.h"
#ifdef CS333_P5

int
main(int argc, char * argv[])
{
  if(argc != 3)
  {
    printf(1, "Invalid use of chmod - usage: chmod # Path\n");
    exit();
  }
  //atoo convert octal to decimal -  only catch number characters - no need to check
  if(chmod(argv[2], atoo(argv[1])))
    printf(1 ,"chmod exec error - # is out of bounds or pathname does not exist\n");
  exit();
}
#else
int
main(void)
{
  printf(1, "Not imlpemented yet.\n");
  exit();
}

#endif
