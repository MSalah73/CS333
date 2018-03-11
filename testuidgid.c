#include "types.h"
#include "user.h"
#define TESTBOUNDS 30000
#define TESTBOUNDS2 20000
int
testuidgid(void)
{
    uint uid, gid, ppid, pid, to_check;
    int testsample, TESTCASES[] = {300, 40000, -3};
    for(int i = 0; i < 3; ++i) // Loop 3 times to check three cases 
    {
      if(!i)
        printf(2, "Commencing In Bound check!\n");// case 1
      else if(i == 1)
        printf(2, "Commencing Positive Out Of Bound check!\n"); //case 2
      else
        printf(2, "Commencing Negative Out Of Bound check!\n"); //case 3

      //UID TEST
      uid = getuid();
      printf(2, "Current_UID_is:_%d\n", uid);
      testsample = TESTCASES[i];
      printf(2, "Setting_UID_is:_%d\n", testsample);
      to_check = setuid(testsample);
      if(!to_check) // for values in bounds
        uid = getuid();
      else if(to_check)
        printf(2, "Unable To Set: %d To UID - Out of bounds\n", testsample);// zero for values out of bounds
      else
        printf(2, "Unable To Set: %d To UID - Feching Error\n", testsample); //to_check value is -1 - argint failed
      printf(2, "Current_UID_is:_%d\n\n", uid);

      //GID TEST
      gid = getgid();
      printf(2, "Current_GID_is:_%d\n", gid);
      testsample = TESTCASES[i];
      printf(2, "Setting_GID_is:_%d\n", testsample);
      to_check = setgid(testsample);
      if(!to_check)
        gid = getgid();
      else if(to_check)
        printf(2, "Unable To Set: %d To GID - Out of bounds\n", testsample);
      else
        printf(2, "Unable To Set: %d To UID - Feching Error\n", testsample);
      printf(2, "Current_GID_is:_%d\n\n", gid);
    }    

    pid = getpid();
    printf(2, "Current_PID_is:_%d\n", pid); 

    ppid = getppid();
    if(!pid)
      printf(2, "Error: Invalid PID - PID Can Not Be Zero\n");
    else
      printf(2, "My_prarent_process_is:_%d\n", ppid);

    printf(2, "Done!\n");
    return 0;
}
int
main(void)
{
    testuidgid();
    exit();
}
