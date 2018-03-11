#include "types.h"
#include "user.h"
#ifdef CS333_P5
int
main(int argc, char * argv[])
{
  if(argc != 3)
  {
    printf(1, "Invalid use of chmod - usage: chown # Path\n");
    exit();
  }
  if(chown(argv[2], atoi(argv[1])))
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
