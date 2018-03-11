#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#ifdef CS333_P3P4
struct StateLists {
    //struct proc * ready; //Project 3
    struct proc * ready[MAX+1]; //project 4
    struct proc * free;
    struct proc * sleep;
    struct proc * zombie;
    struct proc * running;
    struct proc * embryo;
};
#endif
struct {
  struct spinlock lock;
  struct proc proc[NPROC];
#ifdef CS333_P3P4
  struct StateLists pLists;
  uint PromoteAtTime;
#endif
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

#ifdef CS333_P3P4
static void checker(int to_check);//, int t, enum procstate c, enum procstate s);
static int removeFromStateList(struct proc ** sList, struct proc * p);
static void assertState(struct proc * p, enum procstate state);
static int addToStateListEnd(struct proc ** sList, struct proc * p);
static int addToStateListHead(struct proc ** sList, struct proc * p);
static void removeAndHeadInsert(struct proc * p, struct proc ** to_remove, struct proc ** to_add, enum procstate to_check, enum procstate assign_state);
static void removeAndEndInsert(struct proc * p, struct proc ** to_remove, struct proc ** to_add, enum procstate to_check, enum procstate assign_state);
void exit_helper(struct proc ** sList);
int wait_helper(struct proc ** sList, int * havekids);
int kill_helper(int pid, struct proc ** sList);
int remove_helper(struct proc ** sList, struct proc * p);
int setpriority_helper(struct proc ** sList, int pid, int priority, int * index); //Project 4
int promotion(struct proc ** sList, int isReady);
void demotion();
#endif

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
#ifdef CS333_P3P4
  if((p = ptable.pLists.free))
    goto found;
  release(&ptable.lock);
  return 0;
#else 
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;
#endif

#ifdef CS333_P2
  p->cpu_ticks_total = p->cpu_ticks_in = 0;
#endif

found:
#ifdef CS333_P3P4
  removeAndHeadInsert(p, &ptable.pLists.free, &ptable.pLists.embryo, UNUSED, EMBRYO);// p - remove - add - check - assign state
#else
  p->state = EMBRYO;
#endif
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
#ifdef CS333_P3P4
  acquire(&ptable.lock);
  removeAndHeadInsert(p, &ptable.pLists.embryo, &ptable.pLists.free, EMBRYO, UNUSED);// p - remove - add - check - assign state
  release(&ptable.lock);
  return 0;
#else
  p->state = UNUSED;
  return 0;
#endif 
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

#ifdef CS333_P1
  p->start_ticks = ticks;
#endif
#ifdef CS333_P4
  p->budget = BUDGET;
#endif
  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
#ifdef CS333_P3P4
  int i;
#endif
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
#ifdef CS333_P3P4
  ptable.PromoteAtTime = ticks;//inital 
  for(i = 0; i < MAX+1; ++i)
    ptable.pLists.ready[i] = 0;
  ptable.pLists.sleep = 0;
  ptable.pLists.zombie = 0;
  ptable.pLists.running = 0;
  ptable.pLists.embryo = 0;
  ptable.pLists.free = 0;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    assertState(p, UNUSED);
    checker(addToStateListHead(&ptable.pLists.free, p));//,5, 0, 0);
  }
#endif
  p = allocproc();// p should be embryo
  initproc = p;
#ifdef CS333_P2
  initproc->parent = initproc;
  initproc->uid = initproc->gid = UIDGID;
#endif

  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

#ifdef CS333_P3P4
  acquire(&ptable.lock);
  p->priority = 0;
  removeAndEndInsert(p, &ptable.pLists.embryo, &ptable.pLists.ready[p->priority], EMBRYO, RUNNABLE);// p - remove - add - check - assign state
  release(&ptable.lock);
#else 
  p->state = RUNNABLE;
#endif
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  // Allocate process.
  if((np = allocproc()) == 0)// np should be an embryo
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
#ifdef CS333_P3P4
    acquire(&ptable.lock);
    removeAndHeadInsert(np, &ptable.pLists.embryo, &ptable.pLists.free, EMBRYO, UNUSED);//np - remove - add - check - assign state
    release(&ptable.lock);
#else 
    np->state = UNUSED;
#endif
    return -1;
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
#ifdef CS333_P2
  np->uid = proc->uid;
  np->gid = proc->gid;
#endif
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));
 
  pid = np->pid;

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
#ifdef CS333_P3P4
  np->priority = 0;
  removeAndEndInsert(np, &ptable.pLists.embryo, &ptable.pLists.ready[np->priority], EMBRYO, RUNNABLE);//np - remove - add - check - assign state
#else
  np->state = RUNNABLE;
#endif
  release(&ptable.lock);
  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
#ifndef CS333_P3P4
void
exit(void)
{
  struct proc *p;
  int fd;
  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}
#else
void
exit(void)
{
  int fd, i;
  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init. //
  //Free donst not have parents
  for(i = 0; i < MAX+1; ++i)
    exit_helper(&ptable.pLists.ready[i]);
  exit_helper(&ptable.pLists.running);
  exit_helper(&ptable.pLists.zombie);
  exit_helper(&ptable.pLists.embryo);//yes, embry have parents
  exit_helper(&ptable.pLists.sleep);

  // Jump into the scheduler, never to return.
  // running -exit-> zombie --- proc should be running 
  //cprintf("exit\n");
  removeAndHeadInsert(proc, &ptable.pLists.running, &ptable.pLists.zombie, RUNNING, ZOMBIE);//proc - remove - add - check - assign state
  //cprintf("exit done\n");
  sched();
  panic("zombie exit");
}
void
exit_helper(struct proc ** sList)
{
  struct proc * p = *sList;
  if(!p)
    return;
  if(p->parent == proc){
    p->parent = initproc;
    if(p->state == ZOMBIE)
      wakeup1(initproc);
  }
  exit_helper(&p->next);
}
#endif
// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
#ifndef CS333_P3P4
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
#else
int
wait(void)
{
  int havekids, pid, i;
  acquire(&ptable.lock);
  for(;;){
    havekids = 0;
    // Scan through table looking for zombie children.
    pid = wait_helper(&ptable.pLists.zombie, &havekids);
    if(pid) return pid;//only with zombie list
    for(i = 0; i < MAX+1; ++i)
      wait_helper(&ptable.pLists.ready[i], &havekids);
    wait_helper(&ptable.pLists.running, &havekids);
    wait_helper(&ptable.pLists.sleep, &havekids);
    wait_helper(&ptable.pLists.embryo, &havekids);
    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
int
wait_helper(struct proc ** sList, int * havekids)
{
  struct proc * p = *sList;
  int pid;

  if(!p)
    return 0;
  if(p->parent == proc)
  {
    *havekids = 1;
    if(p->state == ZOMBIE){
      // Found one.
      pid = p->pid;
      kfree(p->kstack);
      p->kstack = 0;
      freevm(p->pgdir);
      removeAndHeadInsert(p, &ptable.pLists.zombie, &ptable.pLists.free, ZOMBIE, UNUSED);//proc - remove - add - check - assign state
      p->pid = 0;
      p->parent = 0;
      p->name[0] = 0;
      p->killed = 0;
      release(&ptable.lock);
      return pid;
    }
  }
  return wait_helper(&p->next, havekids);
}
#endif


//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
#ifndef CS333_P3P4
// original xv6 scheduler. Use if CS333_P3P4 NOT defined.
void
scheduler(void)
{
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);

#ifdef CS333_P2
      p->cpu_ticks_in = ticks; // Start ticks when the procceser enters 
#endif

      switchkvm();
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
    // if idle, wait for next interrupt
    if (idle) {
      sti();
      hlt();
    }
  }
}

#else
void
scheduler(void)
{
  struct proc *p;
  int idle;  // for checking if processor is idle
  int i;

  for(;;){
    // Enable interrupts on this processor.
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);

    if(ticks >= ptable.PromoteAtTime)
    {
      for(i = 1; i < MAX+1; ++i)
        promotion(&ptable.pLists.ready[i], 1); // 1 for ready 
      promotion(&ptable.pLists.running, 0); // 0 for sleep and running
      promotion(&ptable.pLists.sleep, 0); 
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
    }
    for(i = 0; i < MAX+1; ++i)
      if((p = ptable.pLists.ready[i]))//rnnable loop and o running -- START
      {
        // Switch to chosen process.  It is the process's job
        // to release ptable.lock and then reacquire it
        // before jumping back to us.
        idle = 0;  // not idle this timeslice
        proc = p;
        switchuvm(p);

        //cprintf("schedular\n");
        removeAndHeadInsert(p, &ptable.pLists.ready[i], &ptable.pLists.running, RUNNABLE, RUNNING);//proc - remove - add - check - assign state
        //cprintf("schedualr done\n");
        swtch(&cpu->scheduler, proc->context);

#ifdef CS333_P2
        p->cpu_ticks_in = ticks; // Start ticks when the procceser enters 
#endif

        switchkvm();
        // Process is done running for now.
        // It should have changed its p->state before coming back.
        proc = 0;
        i = MAX+1;
      }
    release(&ptable.lock);
    // if idle, wait for next interrupt
    if (idle) 
      hlt();
    }
}
#endif

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
#ifndef CS333_P3P4
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;

#ifdef CS333_P2
  proc->cpu_ticks_total += (ticks - proc->cpu_ticks_in); // Update the total cpu ticks before it switches to the other one
#endif

  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
}
#else
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;

#ifdef CS333_P2
  proc->cpu_ticks_total += (ticks - proc->cpu_ticks_in); // Update the total cpu ticks before it switches to the other one
#endif

  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
}
#endif

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
#ifdef CS333_P3P4
  //cprintf("yield\n");
  demotion();// Project 4 - update budget and priority 
  removeAndEndInsert(proc, &ptable.pLists.running, &ptable.pLists.ready[proc->priority], RUNNING, RUNNABLE);//proc - remove - add - check - assign state
  //cprintf("yield done\n");
#else
  proc->state = RUNNABLE;
#endif
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }
  
  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
    acquire(&ptable.lock);
    if (lk) release(lk);
  }

  if(proc->state != SLEEPING)
      //cprintf("not sleep\n");

  // Go to sleep.
  proc->chan = chan;
#ifdef CS333_P3P4
  //cprintf("sleep\n");
  removeAndHeadInsert(proc, &ptable.pLists.running, &ptable.pLists.sleep, RUNNING, SLEEPING);//proc - remove - add - check - assign state
  demotion();// Project 4 - budget update
  //cprintf("sleep done\n");
#else
  proc->state = SLEEPING;
#endif
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){ 
    release(&ptable.lock);
    if (lk) acquire(lk);
  }
}

//PAGEBREAK!
#ifndef CS333_P3P4
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
  //cprintf("wakeup1\n");
  struct proc * p = ptable.pLists.sleep;
  while(p)
  {
    if(p->chan == chan && p->state == SLEEPING)
    {
      struct proc * hold = p->next;//11. (-1) point fixed 
      removeAndEndInsert(p, &ptable.pLists.sleep, &ptable.pLists.ready[p->priority], SLEEPING, RUNNABLE);//proc - remove - add - check - assign state
      p = hold;
    }
    else
      p = p->next;
  }
}
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
#ifndef CS333_P3P4
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
#else
int
kill(int pid)
{
  int i, isFound = 0;
  acquire(&ptable.lock);
  for(i = 0; i < MAX+1 && !isFound; ++i)
    if(kill_helper(pid, &ptable.pLists.ready[i]))
      ++isFound;
  if(isFound)
      return 0;
  else if(kill_helper(pid, &ptable.pLists.running))
      return 0;
  else if(kill_helper(pid, &ptable.pLists.zombie))
      return 0;
  else if(kill_helper(pid, &ptable.pLists.embryo))
      return 0;
  else if(kill_helper(pid, &ptable.pLists.sleep))//last so we dont add to runable list
      return 0;
  release(&ptable.lock);
  return -1;
}
int
kill_helper(int pid, struct proc ** sList)
{
  struct proc * p = *sList;
  if(!p)
    return 0;
  if(p->pid == pid){
    p->killed = 1;
    if(p->state == SLEEPING)
    {
      p->priority = 0;
      removeAndEndInsert(p, &ptable.pLists.sleep, &ptable.pLists.ready[p->priority], SLEEPING, RUNNABLE);//proc - remove - add - check - assign state
    }
    release(&ptable.lock);
    return 1;
  }
  return kill_helper(pid, &p->next);
}
#endif

static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
};

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
#ifdef CS333_P2
  int i, sec, milisec, cpu_sec, cpu_milisec;
  char * zeros = "", *cpu_zeros = "";
#elif CS333_P1
  int i, sec, milisec;
  char * zeros = "";
#else
  int i;
#endif
  struct proc *p;
  char *state;
  uint pc[10];
#ifdef CS333_P3P4
  cprintf("PID\tName\tUID\tGID\tPPID\tPrio\tElapsed\t CPU\tState\tSize\t PCs\n");
#elif CS333_P2
  cprintf("PID\tName\tUID\tGID\tPPID\tElapsed\t CPU\tState\tSize\t PCs\n");
#elif CS333_P1
  cprintf("PID\tState\tName\tElapsed\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
#ifdef CS333_P2
    sec = (ticks - p->start_ticks)/1000;
    milisec = (ticks - p->start_ticks) % 1000;
    cpu_sec = p->cpu_ticks_total/1000;
    cpu_milisec = p->cpu_ticks_total % 1000;

    if((milisec < 10 && milisec > 1))
        zeros = "00";
    else if(milisec < 100)
        zeros = "0";
    else
        zeros = "";
    if((cpu_milisec < 10 && cpu_milisec > 1))
        cpu_zeros = "00";
    else if(cpu_milisec < 100)
        cpu_zeros = "0";
    else
        cpu_zeros = "";
#ifdef CS333_P3P4
    cprintf("%d\t%s\t%d\t%d\t%d\t%d\t%d.%s%d\t %d.%s%d\t%s\t%d\t", p->pid, p->name, p->uid, p->gid, p->parent->pid, p->priority, sec, zeros, milisec, cpu_sec, cpu_zeros, cpu_milisec, state, p->sz);
#else
    cprintf("%d\t%s\t%d\t%d\t%d\t%d.%s%d\t %d.%s%d\t%s\t%d\t", p->pid, p->name, p->uid, p->gid, p->parent->pid, sec, zeros, milisec, cpu_sec, cpu_zeros, cpu_milisec, state, p->sz);
#endif

#elif CS333_P1
    sec = (ticks - p->start_ticks)/1000;
    milisec = (ticks - p->start_ticks) % 1000;

    if((milisec < 10 && milisec > 1))
        zeros = "00";
    else if(milisec < 100)
        zeros = "0";
    else
        zeros = "";

    cprintf("%d\t%s\t%s\t%d.%s%d\t", p->pid, state, p->name, sec, zeros,  milisec);
#else
    cprintf("%d %s %s", p->pid, state, p->name);
#endif
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
#ifdef CS333_P2
int getprocs(uint max, struct uproc * table){
  struct proc * p;
  int i;

  for(i = 0, p = ptable.proc; p < &ptable.proc[NPROC] && i < max; p++){
    if(p->state == UNUSED || p->state == EMBRYO)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    {
        table[i].pid = p->pid;
        table[i].uid = p->uid;
        table[i].gid = p->gid;
        table[i].ppid = p->parent->pid;
#ifdef CS333_P3P4
        table[i].priority = p->priority;
#endif
        table[i].elapsed_ticks = ticks - p->start_ticks;
        table[i].CPU_total_ticks = p->cpu_ticks_total;
        table[i].size = p->sz;

        safestrcpy(table[i].state, states[p->state], STRMAX);
        safestrcpy(table[i++].name, p->name, STRMAX);
    }
    else
      return -1;
  }
  return i;
}
#endif

#ifdef CS333_P3P4
static void
checker(int to_check)//, int t, enum procstate c, enum procstate s)
{
  if(to_check)   //cprintf("- type %d  c - %s   s -  %s", t, states[c],states[s]);
    panic("Error: Add/remove Failed");
}
static int
removeFromStateList(struct proc ** sList, struct proc * p)
{
    struct proc * head = *sList;
    if(!p || !head)
        return -1;
    if(p == head)
    {
      *sList = head->next;
      p->next = 0;
      return 0;
    }
    else
      return remove_helper(sList, p);
}
int
remove_helper(struct proc ** sList, struct proc * p)
{
    struct proc * head = *sList;
    if(!head)
      return -1;
    if(head->next)
      if(p == head->next)
        {
          head->next = head->next->next;
          p->next = 0;
          return 0;
        }
    return remove_helper(&head->next, p);
}
static void
assertState(struct proc * p, enum procstate state)
{
  if(p->state != state)
  {
    cprintf("Error: States does not match! process state is %s - It should be %s", states[p->state], states[state]);
    panic("\n");
  }
}
static int
addToStateListEnd(struct proc ** sList, struct proc * p)
{
  struct proc * temp = *sList;
  if(!*sList)
    return addToStateListHead(sList, p);
  if(!p)
    return -1;
  while(temp->next)
    temp = temp->next;
  p->next = 0;
  temp->next = p;
  return 0;
}
static int
addToStateListHead(struct proc ** sList, struct proc * p)
{
  if(!p)
    return -1;
  p->next = *sList;
  *sList = p;
  return 0;
}
static void
removeAndHeadInsert(struct proc * p, struct proc ** to_remove, struct proc ** to_add, enum procstate to_check, enum procstate assign_state)//for readability 
{
  //cprintf("in head - p = %s || to_check = %s\n", states[p->state], states[to_check]);
  assertState(p, to_check);
  checker(removeFromStateList(to_remove, p));//, 1, to_check , assign_state);
  p->state = assign_state;
  checker(addToStateListHead(to_add, p));//, 2, p->state, to_check);
}
static void
removeAndEndInsert(struct proc * p, struct proc ** to_remove, struct proc ** to_add, enum procstate to_check, enum procstate assign_state)//for readability 
{
  assertState(p, to_check);
  checker(removeFromStateList(to_remove, p));//, 3, to_check, assign_state);
  p->state = assign_state;
  checker(addToStateListEnd(to_add, p));//, 4, p->state, to_check);

}
void 
control_r(void)
{
  int i;
  cprintf("Ready List Processes:\n");
  for(i = 0; i < MAX+1; ++i)
  {
    struct proc * p = ptable.pLists.ready[i];
    cprintf("%d: ", i);
    if(!p)
      cprintf("Empty\n");

    while(p)
    {
      if(p->next)
        cprintf("(%d, %d) -> ", p->pid, p->budget);
      else
        cprintf("(%d, %d)\n", p->pid, p->budget);
      p = p->next;
    }
  }
}
void 
control_f(void)
{
  int i = 0;
  struct proc * p = ptable.pLists.free;
  for(i = 0; p; ++i)
    p = p->next;
  cprintf("Free List Size: %d processes\n", i);
}
void 
control_s(void)
{
  struct proc * p = ptable.pLists.sleep;
  cprintf("Sleep List Processes:\n");
  if(!p)
    cprintf("Empty\n");

  while(p)
  {
    if(p->next)
      cprintf("%d -> ", p->pid);
    else
      cprintf("%d\n", p->pid);
    p = p->next;
  }
}
void 
control_z(void)
{
  struct proc * p = ptable.pLists.zombie;
  cprintf("Zombie List Processes:\n");
  if(!p)
    cprintf("Empty\n");

  while(p)
  {
    if(p->next)
      cprintf("(%d, %d) -> ", p->pid, p->parent->pid);
    else
      cprintf("(%d, %d)\n", p->pid, p->parent->pid);;
    p = p->next;
  }
}
//***************Project 4****************//
int 
setpriority(int pid, int priority)
{
  int i, isSet = 1;
  acquire(&ptable.lock);
  for(i = 0; i < MAX+1 && isSet; ++i)
    isSet = setpriority_helper(&ptable.pLists.ready[i], pid, priority, &i);
  if(isSet && (isSet = setpriority_helper(&ptable.pLists.sleep, pid, priority, 0)))
    isSet = setpriority_helper(&ptable.pLists.running, pid, priority, 0);
  release(&ptable.lock);
  return isSet;
}
int 
setpriority_helper(struct proc ** sList, int pid, int priority, int * index)
{
  struct proc * phead = *sList;
  if(!phead)
    return 1;
  if(phead->pid == pid)
  {
    if(index)//this is only for the ready state, otherwise its null.
    {
      checker(removeFromStateList(&ptable.pLists.ready[*index], phead));
      phead->budget = BUDGET;
      phead->priority = priority;
      checker(addToStateListEnd(&ptable.pLists.ready[priority], phead));
    }
    else
    {
      phead->budget = BUDGET;
      phead->priority = priority;
    }
    return 0;
  }
  return setpriority_helper(&phead->next, pid, priority, index);
}
int
promotion(struct proc ** sList, int isReady)
{
  struct proc * phead = *sList;
  if(!phead || !phead->priority)
    return 1;
  --phead->priority;
  if(isReady)
  {
    removeAndEndInsert(phead, sList, &ptable.pLists.ready[phead->priority], RUNNABLE, RUNNABLE);//proc - remove - add - check - assign state
  }
  return promotion(&phead->next, isReady);
}
void
demotion()
{
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
  if(proc->budget <= 0)
  {
    if(proc->priority < MAX)
      ++proc->priority;
    proc->budget = BUDGET;
  }
}
#endif
