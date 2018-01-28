#ifdef CS333_P2
#include "types.h"
#include "user.h"
int
main(void)
{
  uint max = 72;
  int filled;
  uint elps_sec, elps_milisec, cpu_sec, cpu_milisec;
  char * elps_zeros = "",* cpu_zeros = "";
  struct uproc * table = (struct uproc *) malloc(sizeof(struct uproc) * max), *up;

  if((filled = getprocs(max,table)) < 0)
  {
      printf(1,"Error: Unable to display processors information\n");
      exit();
  }

  printf(1,"PID\tName\tUID\tGID\tPPID\tElapsed\t CPU\tState\tSize\n");
  
  up = table;
  while(filled--)
  {
    elps_sec = up->elapsed_ticks / 1000;
    elps_milisec = up->elapsed_ticks % 1000;
    cpu_sec = up->CPU_total_ticks / 1000;
    cpu_milisec = up->CPU_total_ticks % 1000;
    
    if(elps_milisec < 10 && elps_milisec > 1)
        elps_zeros = "00";
    else if(elps_milisec < 100)
        elps_zeros = "0";

    if(cpu_milisec < 10 && cpu_milisec > 1)
        cpu_zeros = "00";
    else if(cpu_milisec < 100)
        cpu_zeros = "0";

    printf(2,"%d\t%s\t%d\t%d\t%d\t%d.%s%d\t %d.%s%d\t%s\t%d\n", up->pid, up->name, up->uid, up->gid, up->ppid, elps_sec, elps_zeros, elps_milisec, cpu_sec, cpu_zeros, cpu_milisec, up->state, up->size);
    cpu_zeros = elps_zeros = "";
    ++up;
  }
  free(table);
  exit();
}
#endif
