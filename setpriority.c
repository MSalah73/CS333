#ifdef CS333_P3P4
#include "types.h"
#include "user.h"
int
main(int argc, char * argv[])
{
  int pid, priority;
  if(argc != 3 || (argv[1] == '\0'  || argv[argc - 1] == '\0'))//add check for string - a..z
  {
    printf(1,"Invaild use of setpriority command - e.g. setpriority # #\n");
    exit();
  }
  pid = atoi(argv[1]);
  priority = atoi(argv[argc - 1]);
  if(setpriority(pid, priority) == -1)
    printf(1, "Invaild PID or Priority\n");
  exit();
}
#endif
