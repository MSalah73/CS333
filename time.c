#ifdef CS333_P2
#include "types.h"
#include "user.h"
int
main(int argc, char * argv[])
{
  ++argv;//ingore the first arg and move throght list of args pass on on main
  int start, end, sec, milisec, pid = fork();//the purpose of calling fork is to invert the list so it looks like the P2 sample
  char * zeros = "";

  if(pid < 0)
  {
    printf(1, "Error: Fork Failed\n");
    exit();
  }
  //wait();//to remove possibility of zombies 
  if(!pid)// to invert the list of calls, we need to call exec function, and ignore other postive 1  n pid  
    if(exec(argv[0], argv))//run function such as time and echo from the list of arg list pass on
    {
      if(argv[0])
          printf(1, "Exec fault\n");
      exit();
    }

  start = uptime(); //do time ps to check correctness
  wait();//to remove possibility of zombies 
  end = uptime();
  sec = (end - start)/1000;
  milisec = (end - start) % 1000;
  if((milisec < 10 && milisec > 1))
    zeros = "00";
  else if(milisec < 100)
    zeros = "0";
  else
    zeros = "";

  if(!argv[0])
      printf(2, "Ran in %d.%s%d\n", sec, zeros, milisec);
  else
      printf(2, "%s ran in %d.%s%d\n", argv[0], sec, zeros, milisec);
  exit();
}

#endif
