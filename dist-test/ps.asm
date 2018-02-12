
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#ifdef CS333_P2
#include "types.h"
#include "user.h"
int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 48             	sub    $0x48,%esp
  uint max = 72;
  14:	c7 45 d4 48 00 00 00 	movl   $0x48,-0x2c(%ebp)
  int filled;
  uint elps_sec, elps_milisec, cpu_sec, cpu_milisec;
  char * elps_zeros = "",* cpu_zeros = "";
  1b:	c7 45 e0 70 0a 00 00 	movl   $0xa70,-0x20(%ebp)
  22:	c7 45 dc 70 0a 00 00 	movl   $0xa70,-0x24(%ebp)
  struct uproc * table = (struct uproc *) malloc(sizeof(struct uproc) * max), *up;
  29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  2c:	6b c0 5c             	imul   $0x5c,%eax,%eax
  2f:	83 ec 0c             	sub    $0xc,%esp
  32:	50                   	push   %eax
  33:	e8 52 09 00 00       	call   98a <malloc>
  38:	83 c4 10             	add    $0x10,%esp
  3b:	89 45 d0             	mov    %eax,-0x30(%ebp)

  if((filled = getprocs(max,table)) < 0)
  3e:	83 ec 08             	sub    $0x8,%esp
  41:	ff 75 d0             	pushl  -0x30(%ebp)
  44:	ff 75 d4             	pushl  -0x2c(%ebp)
  47:	e8 8c 05 00 00       	call   5d8 <getprocs>
  4c:	83 c4 10             	add    $0x10,%esp
  4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  52:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  56:	79 17                	jns    6f <main+0x6f>
  {
      printf(1,"Error: Unable to display processors information\n");
  58:	83 ec 08             	sub    $0x8,%esp
  5b:	68 74 0a 00 00       	push   $0xa74
  60:	6a 01                	push   $0x1
  62:	e8 50 06 00 00       	call   6b7 <printf>
  67:	83 c4 10             	add    $0x10,%esp
      exit();
  6a:	e8 91 04 00 00       	call   500 <exit>
  }

  printf(1,"PID\tName\tUID\tGID\tPPID\tElapsed\t CPU\tState\tSize\n");
  6f:	83 ec 08             	sub    $0x8,%esp
  72:	68 a8 0a 00 00       	push   $0xaa8
  77:	6a 01                	push   $0x1
  79:	e8 39 06 00 00       	call   6b7 <printf>
  7e:	83 c4 10             	add    $0x10,%esp
  
  up = table;
  81:	8b 45 d0             	mov    -0x30(%ebp),%eax
  84:	89 45 d8             	mov    %eax,-0x28(%ebp)
  while(filled--)
  87:	e9 26 01 00 00       	jmp    1b2 <main+0x1b2>
  {
    elps_sec = up->elapsed_ticks / 1000;
  8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8f:	8b 40 10             	mov    0x10(%eax),%eax
  92:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  97:	f7 e2                	mul    %edx
  99:	89 d0                	mov    %edx,%eax
  9b:	c1 e8 06             	shr    $0x6,%eax
  9e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    elps_milisec = up->elapsed_ticks % 1000;
  a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  a4:	8b 48 10             	mov    0x10(%eax),%ecx
  a7:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  ac:	89 c8                	mov    %ecx,%eax
  ae:	f7 e2                	mul    %edx
  b0:	89 d0                	mov    %edx,%eax
  b2:	c1 e8 06             	shr    $0x6,%eax
  b5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  b8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  bb:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
  c1:	29 c1                	sub    %eax,%ecx
  c3:	89 c8                	mov    %ecx,%eax
  c5:	89 45 c8             	mov    %eax,-0x38(%ebp)
    cpu_sec = up->CPU_total_ticks / 1000;
  c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  cb:	8b 40 14             	mov    0x14(%eax),%eax
  ce:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  d3:	f7 e2                	mul    %edx
  d5:	89 d0                	mov    %edx,%eax
  d7:	c1 e8 06             	shr    $0x6,%eax
  da:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    cpu_milisec = up->CPU_total_ticks % 1000;
  dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  e0:	8b 48 14             	mov    0x14(%eax),%ecx
  e3:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  e8:	89 c8                	mov    %ecx,%eax
  ea:	f7 e2                	mul    %edx
  ec:	89 d0                	mov    %edx,%eax
  ee:	c1 e8 06             	shr    $0x6,%eax
  f1:	89 45 c0             	mov    %eax,-0x40(%ebp)
  f4:	8b 45 c0             	mov    -0x40(%ebp),%eax
  f7:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
  fd:	29 c1                	sub    %eax,%ecx
  ff:	89 c8                	mov    %ecx,%eax
 101:	89 45 c0             	mov    %eax,-0x40(%ebp)
    
    if(elps_milisec < 10 && elps_milisec > 1)
 104:	83 7d c8 09          	cmpl   $0x9,-0x38(%ebp)
 108:	77 0f                	ja     119 <main+0x119>
 10a:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
 10e:	76 09                	jbe    119 <main+0x119>
        elps_zeros = "00";
 110:	c7 45 e0 d7 0a 00 00 	movl   $0xad7,-0x20(%ebp)
 117:	eb 0d                	jmp    126 <main+0x126>
    else if(elps_milisec < 100)
 119:	83 7d c8 63          	cmpl   $0x63,-0x38(%ebp)
 11d:	77 07                	ja     126 <main+0x126>
        elps_zeros = "0";
 11f:	c7 45 e0 da 0a 00 00 	movl   $0xada,-0x20(%ebp)

    if(cpu_milisec < 10 && cpu_milisec > 1)
 126:	83 7d c0 09          	cmpl   $0x9,-0x40(%ebp)
 12a:	77 0f                	ja     13b <main+0x13b>
 12c:	83 7d c0 01          	cmpl   $0x1,-0x40(%ebp)
 130:	76 09                	jbe    13b <main+0x13b>
        cpu_zeros = "00";
 132:	c7 45 dc d7 0a 00 00 	movl   $0xad7,-0x24(%ebp)
 139:	eb 0d                	jmp    148 <main+0x148>
    else if(cpu_milisec < 100)
 13b:	83 7d c0 63          	cmpl   $0x63,-0x40(%ebp)
 13f:	77 07                	ja     148 <main+0x148>
        cpu_zeros = "0";
 141:	c7 45 dc da 0a 00 00 	movl   $0xada,-0x24(%ebp)

    printf(2,"%d\t%s\t%d\t%d\t%d\t%d.%s%d\t %d.%s%d\t%s\t%d\n", up->pid, up->name, up->uid, up->gid, up->ppid, elps_sec, elps_zeros, elps_milisec, cpu_sec, cpu_zeros, cpu_milisec, up->state, up->size);
 148:	8b 45 d8             	mov    -0x28(%ebp),%eax
 14b:	8b 70 38             	mov    0x38(%eax),%esi
 14e:	8b 45 d8             	mov    -0x28(%ebp),%eax
 151:	83 c0 18             	add    $0x18,%eax
 154:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 157:	8b 45 d8             	mov    -0x28(%ebp),%eax
 15a:	8b 58 0c             	mov    0xc(%eax),%ebx
 15d:	8b 45 d8             	mov    -0x28(%ebp),%eax
 160:	8b 48 08             	mov    0x8(%eax),%ecx
 163:	8b 45 d8             	mov    -0x28(%ebp),%eax
 166:	8b 50 04             	mov    0x4(%eax),%edx
 169:	8b 45 d8             	mov    -0x28(%ebp),%eax
 16c:	8d 78 3c             	lea    0x3c(%eax),%edi
 16f:	8b 45 d8             	mov    -0x28(%ebp),%eax
 172:	8b 00                	mov    (%eax),%eax
 174:	83 ec 04             	sub    $0x4,%esp
 177:	56                   	push   %esi
 178:	ff 75 b4             	pushl  -0x4c(%ebp)
 17b:	ff 75 c0             	pushl  -0x40(%ebp)
 17e:	ff 75 dc             	pushl  -0x24(%ebp)
 181:	ff 75 c4             	pushl  -0x3c(%ebp)
 184:	ff 75 c8             	pushl  -0x38(%ebp)
 187:	ff 75 e0             	pushl  -0x20(%ebp)
 18a:	ff 75 cc             	pushl  -0x34(%ebp)
 18d:	53                   	push   %ebx
 18e:	51                   	push   %ecx
 18f:	52                   	push   %edx
 190:	57                   	push   %edi
 191:	50                   	push   %eax
 192:	68 dc 0a 00 00       	push   $0xadc
 197:	6a 02                	push   $0x2
 199:	e8 19 05 00 00       	call   6b7 <printf>
 19e:	83 c4 40             	add    $0x40,%esp
    cpu_zeros = elps_zeros = "";
 1a1:	c7 45 e0 70 0a 00 00 	movl   $0xa70,-0x20(%ebp)
 1a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1ab:	89 45 dc             	mov    %eax,-0x24(%ebp)
    ++up;
 1ae:	83 45 d8 5c          	addl   $0x5c,-0x28(%ebp)
  }

  printf(1,"PID\tName\tUID\tGID\tPPID\tElapsed\t CPU\tState\tSize\n");
  
  up = table;
  while(filled--)
 1b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1b5:	8d 50 ff             	lea    -0x1(%eax),%edx
 1b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
 1bb:	85 c0                	test   %eax,%eax
 1bd:	0f 85 c9 fe ff ff    	jne    8c <main+0x8c>

    printf(2,"%d\t%s\t%d\t%d\t%d\t%d.%s%d\t %d.%s%d\t%s\t%d\n", up->pid, up->name, up->uid, up->gid, up->ppid, elps_sec, elps_zeros, elps_milisec, cpu_sec, cpu_zeros, cpu_milisec, up->state, up->size);
    cpu_zeros = elps_zeros = "";
    ++up;
  }
  free(table);
 1c3:	83 ec 0c             	sub    $0xc,%esp
 1c6:	ff 75 d0             	pushl  -0x30(%ebp)
 1c9:	e8 7a 06 00 00       	call   848 <free>
 1ce:	83 c4 10             	add    $0x10,%esp
  exit();
 1d1:	e8 2a 03 00 00       	call   500 <exit>

000001d6 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1d6:	55                   	push   %ebp
 1d7:	89 e5                	mov    %esp,%ebp
 1d9:	57                   	push   %edi
 1da:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1db:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1de:	8b 55 10             	mov    0x10(%ebp),%edx
 1e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e4:	89 cb                	mov    %ecx,%ebx
 1e6:	89 df                	mov    %ebx,%edi
 1e8:	89 d1                	mov    %edx,%ecx
 1ea:	fc                   	cld    
 1eb:	f3 aa                	rep stos %al,%es:(%edi)
 1ed:	89 ca                	mov    %ecx,%edx
 1ef:	89 fb                	mov    %edi,%ebx
 1f1:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1f4:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1f7:	90                   	nop
 1f8:	5b                   	pop    %ebx
 1f9:	5f                   	pop    %edi
 1fa:	5d                   	pop    %ebp
 1fb:	c3                   	ret    

000001fc <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1fc:	55                   	push   %ebp
 1fd:	89 e5                	mov    %esp,%ebp
 1ff:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 202:	8b 45 08             	mov    0x8(%ebp),%eax
 205:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 208:	90                   	nop
 209:	8b 45 08             	mov    0x8(%ebp),%eax
 20c:	8d 50 01             	lea    0x1(%eax),%edx
 20f:	89 55 08             	mov    %edx,0x8(%ebp)
 212:	8b 55 0c             	mov    0xc(%ebp),%edx
 215:	8d 4a 01             	lea    0x1(%edx),%ecx
 218:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 21b:	0f b6 12             	movzbl (%edx),%edx
 21e:	88 10                	mov    %dl,(%eax)
 220:	0f b6 00             	movzbl (%eax),%eax
 223:	84 c0                	test   %al,%al
 225:	75 e2                	jne    209 <strcpy+0xd>
    ;
  return os;
 227:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 22a:	c9                   	leave  
 22b:	c3                   	ret    

0000022c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 22c:	55                   	push   %ebp
 22d:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 22f:	eb 08                	jmp    239 <strcmp+0xd>
    p++, q++;
 231:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 235:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 239:	8b 45 08             	mov    0x8(%ebp),%eax
 23c:	0f b6 00             	movzbl (%eax),%eax
 23f:	84 c0                	test   %al,%al
 241:	74 10                	je     253 <strcmp+0x27>
 243:	8b 45 08             	mov    0x8(%ebp),%eax
 246:	0f b6 10             	movzbl (%eax),%edx
 249:	8b 45 0c             	mov    0xc(%ebp),%eax
 24c:	0f b6 00             	movzbl (%eax),%eax
 24f:	38 c2                	cmp    %al,%dl
 251:	74 de                	je     231 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 253:	8b 45 08             	mov    0x8(%ebp),%eax
 256:	0f b6 00             	movzbl (%eax),%eax
 259:	0f b6 d0             	movzbl %al,%edx
 25c:	8b 45 0c             	mov    0xc(%ebp),%eax
 25f:	0f b6 00             	movzbl (%eax),%eax
 262:	0f b6 c0             	movzbl %al,%eax
 265:	29 c2                	sub    %eax,%edx
 267:	89 d0                	mov    %edx,%eax
}
 269:	5d                   	pop    %ebp
 26a:	c3                   	ret    

0000026b <strlen>:

uint
strlen(char *s)
{
 26b:	55                   	push   %ebp
 26c:	89 e5                	mov    %esp,%ebp
 26e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 271:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 278:	eb 04                	jmp    27e <strlen+0x13>
 27a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 27e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 281:	8b 45 08             	mov    0x8(%ebp),%eax
 284:	01 d0                	add    %edx,%eax
 286:	0f b6 00             	movzbl (%eax),%eax
 289:	84 c0                	test   %al,%al
 28b:	75 ed                	jne    27a <strlen+0xf>
    ;
  return n;
 28d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 290:	c9                   	leave  
 291:	c3                   	ret    

00000292 <memset>:

void*
memset(void *dst, int c, uint n)
{
 292:	55                   	push   %ebp
 293:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 295:	8b 45 10             	mov    0x10(%ebp),%eax
 298:	50                   	push   %eax
 299:	ff 75 0c             	pushl  0xc(%ebp)
 29c:	ff 75 08             	pushl  0x8(%ebp)
 29f:	e8 32 ff ff ff       	call   1d6 <stosb>
 2a4:	83 c4 0c             	add    $0xc,%esp
  return dst;
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2aa:	c9                   	leave  
 2ab:	c3                   	ret    

000002ac <strchr>:

char*
strchr(const char *s, char c)
{
 2ac:	55                   	push   %ebp
 2ad:	89 e5                	mov    %esp,%ebp
 2af:	83 ec 04             	sub    $0x4,%esp
 2b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b5:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2b8:	eb 14                	jmp    2ce <strchr+0x22>
    if(*s == c)
 2ba:	8b 45 08             	mov    0x8(%ebp),%eax
 2bd:	0f b6 00             	movzbl (%eax),%eax
 2c0:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2c3:	75 05                	jne    2ca <strchr+0x1e>
      return (char*)s;
 2c5:	8b 45 08             	mov    0x8(%ebp),%eax
 2c8:	eb 13                	jmp    2dd <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2ca:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2ce:	8b 45 08             	mov    0x8(%ebp),%eax
 2d1:	0f b6 00             	movzbl (%eax),%eax
 2d4:	84 c0                	test   %al,%al
 2d6:	75 e2                	jne    2ba <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2dd:	c9                   	leave  
 2de:	c3                   	ret    

000002df <gets>:

char*
gets(char *buf, int max)
{
 2df:	55                   	push   %ebp
 2e0:	89 e5                	mov    %esp,%ebp
 2e2:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2ec:	eb 42                	jmp    330 <gets+0x51>
    cc = read(0, &c, 1);
 2ee:	83 ec 04             	sub    $0x4,%esp
 2f1:	6a 01                	push   $0x1
 2f3:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2f6:	50                   	push   %eax
 2f7:	6a 00                	push   $0x0
 2f9:	e8 1a 02 00 00       	call   518 <read>
 2fe:	83 c4 10             	add    $0x10,%esp
 301:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 304:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 308:	7e 33                	jle    33d <gets+0x5e>
      break;
    buf[i++] = c;
 30a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 30d:	8d 50 01             	lea    0x1(%eax),%edx
 310:	89 55 f4             	mov    %edx,-0xc(%ebp)
 313:	89 c2                	mov    %eax,%edx
 315:	8b 45 08             	mov    0x8(%ebp),%eax
 318:	01 c2                	add    %eax,%edx
 31a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 31e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 320:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 324:	3c 0a                	cmp    $0xa,%al
 326:	74 16                	je     33e <gets+0x5f>
 328:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 32c:	3c 0d                	cmp    $0xd,%al
 32e:	74 0e                	je     33e <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 330:	8b 45 f4             	mov    -0xc(%ebp),%eax
 333:	83 c0 01             	add    $0x1,%eax
 336:	3b 45 0c             	cmp    0xc(%ebp),%eax
 339:	7c b3                	jl     2ee <gets+0xf>
 33b:	eb 01                	jmp    33e <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 33d:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 33e:	8b 55 f4             	mov    -0xc(%ebp),%edx
 341:	8b 45 08             	mov    0x8(%ebp),%eax
 344:	01 d0                	add    %edx,%eax
 346:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 349:	8b 45 08             	mov    0x8(%ebp),%eax
}
 34c:	c9                   	leave  
 34d:	c3                   	ret    

0000034e <stat>:

int
stat(char *n, struct stat *st)
{
 34e:	55                   	push   %ebp
 34f:	89 e5                	mov    %esp,%ebp
 351:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 354:	83 ec 08             	sub    $0x8,%esp
 357:	6a 00                	push   $0x0
 359:	ff 75 08             	pushl  0x8(%ebp)
 35c:	e8 df 01 00 00       	call   540 <open>
 361:	83 c4 10             	add    $0x10,%esp
 364:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 367:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 36b:	79 07                	jns    374 <stat+0x26>
    return -1;
 36d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 372:	eb 25                	jmp    399 <stat+0x4b>
  r = fstat(fd, st);
 374:	83 ec 08             	sub    $0x8,%esp
 377:	ff 75 0c             	pushl  0xc(%ebp)
 37a:	ff 75 f4             	pushl  -0xc(%ebp)
 37d:	e8 d6 01 00 00       	call   558 <fstat>
 382:	83 c4 10             	add    $0x10,%esp
 385:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 388:	83 ec 0c             	sub    $0xc,%esp
 38b:	ff 75 f4             	pushl  -0xc(%ebp)
 38e:	e8 95 01 00 00       	call   528 <close>
 393:	83 c4 10             	add    $0x10,%esp
  return r;
 396:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 399:	c9                   	leave  
 39a:	c3                   	ret    

0000039b <atoi>:

int
atoi(const char *s)
{
 39b:	55                   	push   %ebp
 39c:	89 e5                	mov    %esp,%ebp
 39e:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 3a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 3a8:	eb 04                	jmp    3ae <atoi+0x13>
 3aa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3ae:	8b 45 08             	mov    0x8(%ebp),%eax
 3b1:	0f b6 00             	movzbl (%eax),%eax
 3b4:	3c 20                	cmp    $0x20,%al
 3b6:	74 f2                	je     3aa <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 3b8:	8b 45 08             	mov    0x8(%ebp),%eax
 3bb:	0f b6 00             	movzbl (%eax),%eax
 3be:	3c 2d                	cmp    $0x2d,%al
 3c0:	75 07                	jne    3c9 <atoi+0x2e>
 3c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3c7:	eb 05                	jmp    3ce <atoi+0x33>
 3c9:	b8 01 00 00 00       	mov    $0x1,%eax
 3ce:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 3d1:	8b 45 08             	mov    0x8(%ebp),%eax
 3d4:	0f b6 00             	movzbl (%eax),%eax
 3d7:	3c 2b                	cmp    $0x2b,%al
 3d9:	74 0a                	je     3e5 <atoi+0x4a>
 3db:	8b 45 08             	mov    0x8(%ebp),%eax
 3de:	0f b6 00             	movzbl (%eax),%eax
 3e1:	3c 2d                	cmp    $0x2d,%al
 3e3:	75 2b                	jne    410 <atoi+0x75>
    s++;
 3e5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 3e9:	eb 25                	jmp    410 <atoi+0x75>
    n = n*10 + *s++ - '0';
 3eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3ee:	89 d0                	mov    %edx,%eax
 3f0:	c1 e0 02             	shl    $0x2,%eax
 3f3:	01 d0                	add    %edx,%eax
 3f5:	01 c0                	add    %eax,%eax
 3f7:	89 c1                	mov    %eax,%ecx
 3f9:	8b 45 08             	mov    0x8(%ebp),%eax
 3fc:	8d 50 01             	lea    0x1(%eax),%edx
 3ff:	89 55 08             	mov    %edx,0x8(%ebp)
 402:	0f b6 00             	movzbl (%eax),%eax
 405:	0f be c0             	movsbl %al,%eax
 408:	01 c8                	add    %ecx,%eax
 40a:	83 e8 30             	sub    $0x30,%eax
 40d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 410:	8b 45 08             	mov    0x8(%ebp),%eax
 413:	0f b6 00             	movzbl (%eax),%eax
 416:	3c 2f                	cmp    $0x2f,%al
 418:	7e 0a                	jle    424 <atoi+0x89>
 41a:	8b 45 08             	mov    0x8(%ebp),%eax
 41d:	0f b6 00             	movzbl (%eax),%eax
 420:	3c 39                	cmp    $0x39,%al
 422:	7e c7                	jle    3eb <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 424:	8b 45 f8             	mov    -0x8(%ebp),%eax
 427:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 42b:	c9                   	leave  
 42c:	c3                   	ret    

0000042d <atoo>:

int
atoo(const char *s)
{
 42d:	55                   	push   %ebp
 42e:	89 e5                	mov    %esp,%ebp
 430:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 433:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 43a:	eb 04                	jmp    440 <atoo+0x13>
 43c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 440:	8b 45 08             	mov    0x8(%ebp),%eax
 443:	0f b6 00             	movzbl (%eax),%eax
 446:	3c 20                	cmp    $0x20,%al
 448:	74 f2                	je     43c <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 44a:	8b 45 08             	mov    0x8(%ebp),%eax
 44d:	0f b6 00             	movzbl (%eax),%eax
 450:	3c 2d                	cmp    $0x2d,%al
 452:	75 07                	jne    45b <atoo+0x2e>
 454:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 459:	eb 05                	jmp    460 <atoo+0x33>
 45b:	b8 01 00 00 00       	mov    $0x1,%eax
 460:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 463:	8b 45 08             	mov    0x8(%ebp),%eax
 466:	0f b6 00             	movzbl (%eax),%eax
 469:	3c 2b                	cmp    $0x2b,%al
 46b:	74 0a                	je     477 <atoo+0x4a>
 46d:	8b 45 08             	mov    0x8(%ebp),%eax
 470:	0f b6 00             	movzbl (%eax),%eax
 473:	3c 2d                	cmp    $0x2d,%al
 475:	75 27                	jne    49e <atoo+0x71>
    s++;
 477:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 47b:	eb 21                	jmp    49e <atoo+0x71>
    n = n*8 + *s++ - '0';
 47d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 480:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 487:	8b 45 08             	mov    0x8(%ebp),%eax
 48a:	8d 50 01             	lea    0x1(%eax),%edx
 48d:	89 55 08             	mov    %edx,0x8(%ebp)
 490:	0f b6 00             	movzbl (%eax),%eax
 493:	0f be c0             	movsbl %al,%eax
 496:	01 c8                	add    %ecx,%eax
 498:	83 e8 30             	sub    $0x30,%eax
 49b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 49e:	8b 45 08             	mov    0x8(%ebp),%eax
 4a1:	0f b6 00             	movzbl (%eax),%eax
 4a4:	3c 2f                	cmp    $0x2f,%al
 4a6:	7e 0a                	jle    4b2 <atoo+0x85>
 4a8:	8b 45 08             	mov    0x8(%ebp),%eax
 4ab:	0f b6 00             	movzbl (%eax),%eax
 4ae:	3c 37                	cmp    $0x37,%al
 4b0:	7e cb                	jle    47d <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 4b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4b5:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 4b9:	c9                   	leave  
 4ba:	c3                   	ret    

000004bb <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 4bb:	55                   	push   %ebp
 4bc:	89 e5                	mov    %esp,%ebp
 4be:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 4c1:	8b 45 08             	mov    0x8(%ebp),%eax
 4c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ca:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4cd:	eb 17                	jmp    4e6 <memmove+0x2b>
    *dst++ = *src++;
 4cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4d2:	8d 50 01             	lea    0x1(%eax),%edx
 4d5:	89 55 fc             	mov    %edx,-0x4(%ebp)
 4d8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4db:	8d 4a 01             	lea    0x1(%edx),%ecx
 4de:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 4e1:	0f b6 12             	movzbl (%edx),%edx
 4e4:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4e6:	8b 45 10             	mov    0x10(%ebp),%eax
 4e9:	8d 50 ff             	lea    -0x1(%eax),%edx
 4ec:	89 55 10             	mov    %edx,0x10(%ebp)
 4ef:	85 c0                	test   %eax,%eax
 4f1:	7f dc                	jg     4cf <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4f6:	c9                   	leave  
 4f7:	c3                   	ret    

000004f8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4f8:	b8 01 00 00 00       	mov    $0x1,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <exit>:
SYSCALL(exit)
 500:	b8 02 00 00 00       	mov    $0x2,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <wait>:
SYSCALL(wait)
 508:	b8 03 00 00 00       	mov    $0x3,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <pipe>:
SYSCALL(pipe)
 510:	b8 04 00 00 00       	mov    $0x4,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <read>:
SYSCALL(read)
 518:	b8 05 00 00 00       	mov    $0x5,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <write>:
SYSCALL(write)
 520:	b8 10 00 00 00       	mov    $0x10,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <close>:
SYSCALL(close)
 528:	b8 15 00 00 00       	mov    $0x15,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <kill>:
SYSCALL(kill)
 530:	b8 06 00 00 00       	mov    $0x6,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <exec>:
SYSCALL(exec)
 538:	b8 07 00 00 00       	mov    $0x7,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <open>:
SYSCALL(open)
 540:	b8 0f 00 00 00       	mov    $0xf,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <mknod>:
SYSCALL(mknod)
 548:	b8 11 00 00 00       	mov    $0x11,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <unlink>:
SYSCALL(unlink)
 550:	b8 12 00 00 00       	mov    $0x12,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <fstat>:
SYSCALL(fstat)
 558:	b8 08 00 00 00       	mov    $0x8,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <link>:
SYSCALL(link)
 560:	b8 13 00 00 00       	mov    $0x13,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <mkdir>:
SYSCALL(mkdir)
 568:	b8 14 00 00 00       	mov    $0x14,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <chdir>:
SYSCALL(chdir)
 570:	b8 09 00 00 00       	mov    $0x9,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <dup>:
SYSCALL(dup)
 578:	b8 0a 00 00 00       	mov    $0xa,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <getpid>:
SYSCALL(getpid)
 580:	b8 0b 00 00 00       	mov    $0xb,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <sbrk>:
SYSCALL(sbrk)
 588:	b8 0c 00 00 00       	mov    $0xc,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <sleep>:
SYSCALL(sleep)
 590:	b8 0d 00 00 00       	mov    $0xd,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <uptime>:
SYSCALL(uptime)
 598:	b8 0e 00 00 00       	mov    $0xe,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <halt>:
SYSCALL(halt)
 5a0:	b8 16 00 00 00       	mov    $0x16,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <date>:
SYSCALL(date)
 5a8:	b8 17 00 00 00       	mov    $0x17,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <getuid>:
SYSCALL(getuid)
 5b0:	b8 18 00 00 00       	mov    $0x18,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <getgid>:
SYSCALL(getgid)
 5b8:	b8 19 00 00 00       	mov    $0x19,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <getppid>:
SYSCALL(getppid)
 5c0:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <setuid>:
SYSCALL(setuid)
 5c8:	b8 1b 00 00 00       	mov    $0x1b,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <setgid>:
SYSCALL(setgid)
 5d0:	b8 1c 00 00 00       	mov    $0x1c,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <getprocs>:
SYSCALL(getprocs)
 5d8:	b8 1d 00 00 00       	mov    $0x1d,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5e0:	55                   	push   %ebp
 5e1:	89 e5                	mov    %esp,%ebp
 5e3:	83 ec 18             	sub    $0x18,%esp
 5e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5ec:	83 ec 04             	sub    $0x4,%esp
 5ef:	6a 01                	push   $0x1
 5f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5f4:	50                   	push   %eax
 5f5:	ff 75 08             	pushl  0x8(%ebp)
 5f8:	e8 23 ff ff ff       	call   520 <write>
 5fd:	83 c4 10             	add    $0x10,%esp
}
 600:	90                   	nop
 601:	c9                   	leave  
 602:	c3                   	ret    

00000603 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 603:	55                   	push   %ebp
 604:	89 e5                	mov    %esp,%ebp
 606:	53                   	push   %ebx
 607:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 60a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 611:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 615:	74 17                	je     62e <printint+0x2b>
 617:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 61b:	79 11                	jns    62e <printint+0x2b>
    neg = 1;
 61d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 624:	8b 45 0c             	mov    0xc(%ebp),%eax
 627:	f7 d8                	neg    %eax
 629:	89 45 ec             	mov    %eax,-0x14(%ebp)
 62c:	eb 06                	jmp    634 <printint+0x31>
  } else {
    x = xx;
 62e:	8b 45 0c             	mov    0xc(%ebp),%eax
 631:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 634:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 63b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 63e:	8d 41 01             	lea    0x1(%ecx),%eax
 641:	89 45 f4             	mov    %eax,-0xc(%ebp)
 644:	8b 5d 10             	mov    0x10(%ebp),%ebx
 647:	8b 45 ec             	mov    -0x14(%ebp),%eax
 64a:	ba 00 00 00 00       	mov    $0x0,%edx
 64f:	f7 f3                	div    %ebx
 651:	89 d0                	mov    %edx,%eax
 653:	0f b6 80 80 0d 00 00 	movzbl 0xd80(%eax),%eax
 65a:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 65e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 661:	8b 45 ec             	mov    -0x14(%ebp),%eax
 664:	ba 00 00 00 00       	mov    $0x0,%edx
 669:	f7 f3                	div    %ebx
 66b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 66e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 672:	75 c7                	jne    63b <printint+0x38>
  if(neg)
 674:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 678:	74 2d                	je     6a7 <printint+0xa4>
    buf[i++] = '-';
 67a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67d:	8d 50 01             	lea    0x1(%eax),%edx
 680:	89 55 f4             	mov    %edx,-0xc(%ebp)
 683:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 688:	eb 1d                	jmp    6a7 <printint+0xa4>
    putc(fd, buf[i]);
 68a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 68d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 690:	01 d0                	add    %edx,%eax
 692:	0f b6 00             	movzbl (%eax),%eax
 695:	0f be c0             	movsbl %al,%eax
 698:	83 ec 08             	sub    $0x8,%esp
 69b:	50                   	push   %eax
 69c:	ff 75 08             	pushl  0x8(%ebp)
 69f:	e8 3c ff ff ff       	call   5e0 <putc>
 6a4:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6a7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6af:	79 d9                	jns    68a <printint+0x87>
    putc(fd, buf[i]);
}
 6b1:	90                   	nop
 6b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 6b5:	c9                   	leave  
 6b6:	c3                   	ret    

000006b7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6b7:	55                   	push   %ebp
 6b8:	89 e5                	mov    %esp,%ebp
 6ba:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6bd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6c4:	8d 45 0c             	lea    0xc(%ebp),%eax
 6c7:	83 c0 04             	add    $0x4,%eax
 6ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6d4:	e9 59 01 00 00       	jmp    832 <printf+0x17b>
    c = fmt[i] & 0xff;
 6d9:	8b 55 0c             	mov    0xc(%ebp),%edx
 6dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6df:	01 d0                	add    %edx,%eax
 6e1:	0f b6 00             	movzbl (%eax),%eax
 6e4:	0f be c0             	movsbl %al,%eax
 6e7:	25 ff 00 00 00       	and    $0xff,%eax
 6ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6ef:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6f3:	75 2c                	jne    721 <printf+0x6a>
      if(c == '%'){
 6f5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6f9:	75 0c                	jne    707 <printf+0x50>
        state = '%';
 6fb:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 702:	e9 27 01 00 00       	jmp    82e <printf+0x177>
      } else {
        putc(fd, c);
 707:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 70a:	0f be c0             	movsbl %al,%eax
 70d:	83 ec 08             	sub    $0x8,%esp
 710:	50                   	push   %eax
 711:	ff 75 08             	pushl  0x8(%ebp)
 714:	e8 c7 fe ff ff       	call   5e0 <putc>
 719:	83 c4 10             	add    $0x10,%esp
 71c:	e9 0d 01 00 00       	jmp    82e <printf+0x177>
      }
    } else if(state == '%'){
 721:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 725:	0f 85 03 01 00 00    	jne    82e <printf+0x177>
      if(c == 'd'){
 72b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 72f:	75 1e                	jne    74f <printf+0x98>
        printint(fd, *ap, 10, 1);
 731:	8b 45 e8             	mov    -0x18(%ebp),%eax
 734:	8b 00                	mov    (%eax),%eax
 736:	6a 01                	push   $0x1
 738:	6a 0a                	push   $0xa
 73a:	50                   	push   %eax
 73b:	ff 75 08             	pushl  0x8(%ebp)
 73e:	e8 c0 fe ff ff       	call   603 <printint>
 743:	83 c4 10             	add    $0x10,%esp
        ap++;
 746:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74a:	e9 d8 00 00 00       	jmp    827 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 74f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 753:	74 06                	je     75b <printf+0xa4>
 755:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 759:	75 1e                	jne    779 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 75b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 75e:	8b 00                	mov    (%eax),%eax
 760:	6a 00                	push   $0x0
 762:	6a 10                	push   $0x10
 764:	50                   	push   %eax
 765:	ff 75 08             	pushl  0x8(%ebp)
 768:	e8 96 fe ff ff       	call   603 <printint>
 76d:	83 c4 10             	add    $0x10,%esp
        ap++;
 770:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 774:	e9 ae 00 00 00       	jmp    827 <printf+0x170>
      } else if(c == 's'){
 779:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 77d:	75 43                	jne    7c2 <printf+0x10b>
        s = (char*)*ap;
 77f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 782:	8b 00                	mov    (%eax),%eax
 784:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 787:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 78b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 78f:	75 25                	jne    7b6 <printf+0xff>
          s = "(null)";
 791:	c7 45 f4 03 0b 00 00 	movl   $0xb03,-0xc(%ebp)
        while(*s != 0){
 798:	eb 1c                	jmp    7b6 <printf+0xff>
          putc(fd, *s);
 79a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79d:	0f b6 00             	movzbl (%eax),%eax
 7a0:	0f be c0             	movsbl %al,%eax
 7a3:	83 ec 08             	sub    $0x8,%esp
 7a6:	50                   	push   %eax
 7a7:	ff 75 08             	pushl  0x8(%ebp)
 7aa:	e8 31 fe ff ff       	call   5e0 <putc>
 7af:	83 c4 10             	add    $0x10,%esp
          s++;
 7b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b9:	0f b6 00             	movzbl (%eax),%eax
 7bc:	84 c0                	test   %al,%al
 7be:	75 da                	jne    79a <printf+0xe3>
 7c0:	eb 65                	jmp    827 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7c2:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7c6:	75 1d                	jne    7e5 <printf+0x12e>
        putc(fd, *ap);
 7c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7cb:	8b 00                	mov    (%eax),%eax
 7cd:	0f be c0             	movsbl %al,%eax
 7d0:	83 ec 08             	sub    $0x8,%esp
 7d3:	50                   	push   %eax
 7d4:	ff 75 08             	pushl  0x8(%ebp)
 7d7:	e8 04 fe ff ff       	call   5e0 <putc>
 7dc:	83 c4 10             	add    $0x10,%esp
        ap++;
 7df:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e3:	eb 42                	jmp    827 <printf+0x170>
      } else if(c == '%'){
 7e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7e9:	75 17                	jne    802 <printf+0x14b>
        putc(fd, c);
 7eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7ee:	0f be c0             	movsbl %al,%eax
 7f1:	83 ec 08             	sub    $0x8,%esp
 7f4:	50                   	push   %eax
 7f5:	ff 75 08             	pushl  0x8(%ebp)
 7f8:	e8 e3 fd ff ff       	call   5e0 <putc>
 7fd:	83 c4 10             	add    $0x10,%esp
 800:	eb 25                	jmp    827 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 802:	83 ec 08             	sub    $0x8,%esp
 805:	6a 25                	push   $0x25
 807:	ff 75 08             	pushl  0x8(%ebp)
 80a:	e8 d1 fd ff ff       	call   5e0 <putc>
 80f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 812:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 815:	0f be c0             	movsbl %al,%eax
 818:	83 ec 08             	sub    $0x8,%esp
 81b:	50                   	push   %eax
 81c:	ff 75 08             	pushl  0x8(%ebp)
 81f:	e8 bc fd ff ff       	call   5e0 <putc>
 824:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 827:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 82e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 832:	8b 55 0c             	mov    0xc(%ebp),%edx
 835:	8b 45 f0             	mov    -0x10(%ebp),%eax
 838:	01 d0                	add    %edx,%eax
 83a:	0f b6 00             	movzbl (%eax),%eax
 83d:	84 c0                	test   %al,%al
 83f:	0f 85 94 fe ff ff    	jne    6d9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 845:	90                   	nop
 846:	c9                   	leave  
 847:	c3                   	ret    

00000848 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 848:	55                   	push   %ebp
 849:	89 e5                	mov    %esp,%ebp
 84b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 84e:	8b 45 08             	mov    0x8(%ebp),%eax
 851:	83 e8 08             	sub    $0x8,%eax
 854:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 857:	a1 9c 0d 00 00       	mov    0xd9c,%eax
 85c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 85f:	eb 24                	jmp    885 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	8b 00                	mov    (%eax),%eax
 866:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 869:	77 12                	ja     87d <free+0x35>
 86b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 871:	77 24                	ja     897 <free+0x4f>
 873:	8b 45 fc             	mov    -0x4(%ebp),%eax
 876:	8b 00                	mov    (%eax),%eax
 878:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 87b:	77 1a                	ja     897 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	8b 00                	mov    (%eax),%eax
 882:	89 45 fc             	mov    %eax,-0x4(%ebp)
 885:	8b 45 f8             	mov    -0x8(%ebp),%eax
 888:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 88b:	76 d4                	jbe    861 <free+0x19>
 88d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 890:	8b 00                	mov    (%eax),%eax
 892:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 895:	76 ca                	jbe    861 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 897:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89a:	8b 40 04             	mov    0x4(%eax),%eax
 89d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a7:	01 c2                	add    %eax,%edx
 8a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ac:	8b 00                	mov    (%eax),%eax
 8ae:	39 c2                	cmp    %eax,%edx
 8b0:	75 24                	jne    8d6 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b5:	8b 50 04             	mov    0x4(%eax),%edx
 8b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bb:	8b 00                	mov    (%eax),%eax
 8bd:	8b 40 04             	mov    0x4(%eax),%eax
 8c0:	01 c2                	add    %eax,%edx
 8c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cb:	8b 00                	mov    (%eax),%eax
 8cd:	8b 10                	mov    (%eax),%edx
 8cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d2:	89 10                	mov    %edx,(%eax)
 8d4:	eb 0a                	jmp    8e0 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d9:	8b 10                	mov    (%eax),%edx
 8db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8de:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e3:	8b 40 04             	mov    0x4(%eax),%eax
 8e6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f0:	01 d0                	add    %edx,%eax
 8f2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8f5:	75 20                	jne    917 <free+0xcf>
    p->s.size += bp->s.size;
 8f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fa:	8b 50 04             	mov    0x4(%eax),%edx
 8fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 900:	8b 40 04             	mov    0x4(%eax),%eax
 903:	01 c2                	add    %eax,%edx
 905:	8b 45 fc             	mov    -0x4(%ebp),%eax
 908:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 90b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90e:	8b 10                	mov    (%eax),%edx
 910:	8b 45 fc             	mov    -0x4(%ebp),%eax
 913:	89 10                	mov    %edx,(%eax)
 915:	eb 08                	jmp    91f <free+0xd7>
  } else
    p->s.ptr = bp;
 917:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 91d:	89 10                	mov    %edx,(%eax)
  freep = p;
 91f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 922:	a3 9c 0d 00 00       	mov    %eax,0xd9c
}
 927:	90                   	nop
 928:	c9                   	leave  
 929:	c3                   	ret    

0000092a <morecore>:

static Header*
morecore(uint nu)
{
 92a:	55                   	push   %ebp
 92b:	89 e5                	mov    %esp,%ebp
 92d:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 930:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 937:	77 07                	ja     940 <morecore+0x16>
    nu = 4096;
 939:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 940:	8b 45 08             	mov    0x8(%ebp),%eax
 943:	c1 e0 03             	shl    $0x3,%eax
 946:	83 ec 0c             	sub    $0xc,%esp
 949:	50                   	push   %eax
 94a:	e8 39 fc ff ff       	call   588 <sbrk>
 94f:	83 c4 10             	add    $0x10,%esp
 952:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 955:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 959:	75 07                	jne    962 <morecore+0x38>
    return 0;
 95b:	b8 00 00 00 00       	mov    $0x0,%eax
 960:	eb 26                	jmp    988 <morecore+0x5e>
  hp = (Header*)p;
 962:	8b 45 f4             	mov    -0xc(%ebp),%eax
 965:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 968:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96b:	8b 55 08             	mov    0x8(%ebp),%edx
 96e:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 971:	8b 45 f0             	mov    -0x10(%ebp),%eax
 974:	83 c0 08             	add    $0x8,%eax
 977:	83 ec 0c             	sub    $0xc,%esp
 97a:	50                   	push   %eax
 97b:	e8 c8 fe ff ff       	call   848 <free>
 980:	83 c4 10             	add    $0x10,%esp
  return freep;
 983:	a1 9c 0d 00 00       	mov    0xd9c,%eax
}
 988:	c9                   	leave  
 989:	c3                   	ret    

0000098a <malloc>:

void*
malloc(uint nbytes)
{
 98a:	55                   	push   %ebp
 98b:	89 e5                	mov    %esp,%ebp
 98d:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 990:	8b 45 08             	mov    0x8(%ebp),%eax
 993:	83 c0 07             	add    $0x7,%eax
 996:	c1 e8 03             	shr    $0x3,%eax
 999:	83 c0 01             	add    $0x1,%eax
 99c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 99f:	a1 9c 0d 00 00       	mov    0xd9c,%eax
 9a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9ab:	75 23                	jne    9d0 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9ad:	c7 45 f0 94 0d 00 00 	movl   $0xd94,-0x10(%ebp)
 9b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b7:	a3 9c 0d 00 00       	mov    %eax,0xd9c
 9bc:	a1 9c 0d 00 00       	mov    0xd9c,%eax
 9c1:	a3 94 0d 00 00       	mov    %eax,0xd94
    base.s.size = 0;
 9c6:	c7 05 98 0d 00 00 00 	movl   $0x0,0xd98
 9cd:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d3:	8b 00                	mov    (%eax),%eax
 9d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9db:	8b 40 04             	mov    0x4(%eax),%eax
 9de:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9e1:	72 4d                	jb     a30 <malloc+0xa6>
      if(p->s.size == nunits)
 9e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e6:	8b 40 04             	mov    0x4(%eax),%eax
 9e9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ec:	75 0c                	jne    9fa <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f1:	8b 10                	mov    (%eax),%edx
 9f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f6:	89 10                	mov    %edx,(%eax)
 9f8:	eb 26                	jmp    a20 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fd:	8b 40 04             	mov    0x4(%eax),%eax
 a00:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a03:	89 c2                	mov    %eax,%edx
 a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a08:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0e:	8b 40 04             	mov    0x4(%eax),%eax
 a11:	c1 e0 03             	shl    $0x3,%eax
 a14:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1a:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a1d:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a23:	a3 9c 0d 00 00       	mov    %eax,0xd9c
      return (void*)(p + 1);
 a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2b:	83 c0 08             	add    $0x8,%eax
 a2e:	eb 3b                	jmp    a6b <malloc+0xe1>
    }
    if(p == freep)
 a30:	a1 9c 0d 00 00       	mov    0xd9c,%eax
 a35:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a38:	75 1e                	jne    a58 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a3a:	83 ec 0c             	sub    $0xc,%esp
 a3d:	ff 75 ec             	pushl  -0x14(%ebp)
 a40:	e8 e5 fe ff ff       	call   92a <morecore>
 a45:	83 c4 10             	add    $0x10,%esp
 a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a4f:	75 07                	jne    a58 <malloc+0xce>
        return 0;
 a51:	b8 00 00 00 00       	mov    $0x0,%eax
 a56:	eb 13                	jmp    a6b <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a61:	8b 00                	mov    (%eax),%eax
 a63:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a66:	e9 6d ff ff ff       	jmp    9d8 <malloc+0x4e>
}
 a6b:	c9                   	leave  
 a6c:	c3                   	ret    
