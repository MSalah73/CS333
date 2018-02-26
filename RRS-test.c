#ifdef CS333_P3P4
#include "types.h"
#include "user.h"
int main(void)
{
    int pid, i;
    for(i = 0; i < 10; ++i)
    {
      pid = fork();// making babies
      if(!pid)
        for(;;);// Inifnite look to check roundrobin scheduling 
    }
    if(pid)
      for(i = 0; i < 10; ++i)
        wait();
    exit();
}
#endif
