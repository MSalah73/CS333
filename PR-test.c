#ifdef CS333_P3P4
#include "types.h"
#include "user.h"
int main(void)
{
    int pid = fork();
      if(!pid)
        for(;;);// Inifnite look to check roundrobin scheduling 
    exit();
}
#endif
