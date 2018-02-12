
_testuidgid:     file format elf32-i386


Disassembly of section .text:

00000000 <testuidgid>:
#include "user.h"
#define TESTBOUNDS 30000
#define TESTBOUNDS2 20000
int
testuidgid(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 38             	sub    $0x38,%esp
    uint uid, gid, ppid, pid, to_check;
    int testsample, TESTCASES[] = {300, 40000, -3};
   6:	c7 45 d0 2c 01 00 00 	movl   $0x12c,-0x30(%ebp)
   d:	c7 45 d4 40 9c 00 00 	movl   $0x9c40,-0x2c(%ebp)
  14:	c7 45 d8 fd ff ff ff 	movl   $0xfffffffd,-0x28(%ebp)
    for(int i = 0; i < 3; ++i) // Loop 3 times to check three cases 
  1b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  22:	e9 98 01 00 00       	jmp    1bf <testuidgid+0x1bf>
    {
      if(!i)
  27:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  2b:	75 14                	jne    41 <testuidgid+0x41>
        printf(2, "Commencing In Bound check!\n");// case 1
  2d:	83 ec 08             	sub    $0x8,%esp
  30:	68 e8 0a 00 00       	push   $0xae8
  35:	6a 02                	push   $0x2
  37:	e8 f6 06 00 00       	call   732 <printf>
  3c:	83 c4 10             	add    $0x10,%esp
  3f:	eb 2c                	jmp    6d <testuidgid+0x6d>
      else if(i == 1)
  41:	83 7d ec 01          	cmpl   $0x1,-0x14(%ebp)
  45:	75 14                	jne    5b <testuidgid+0x5b>
        printf(2, "Commencing Positive Out Of Bound check!\n"); //case 2
  47:	83 ec 08             	sub    $0x8,%esp
  4a:	68 04 0b 00 00       	push   $0xb04
  4f:	6a 02                	push   $0x2
  51:	e8 dc 06 00 00       	call   732 <printf>
  56:	83 c4 10             	add    $0x10,%esp
  59:	eb 12                	jmp    6d <testuidgid+0x6d>
      else
        printf(2, "Commencing Negative Out Of Bound check!\n"); //case 3
  5b:	83 ec 08             	sub    $0x8,%esp
  5e:	68 30 0b 00 00       	push   $0xb30
  63:	6a 02                	push   $0x2
  65:	e8 c8 06 00 00       	call   732 <printf>
  6a:	83 c4 10             	add    $0x10,%esp

      //UID TEST
      uid = getuid();
  6d:	e8 b9 05 00 00       	call   62b <getuid>
  72:	89 45 f4             	mov    %eax,-0xc(%ebp)
      printf(2, "Current_UID_is:_%d\n", uid);
  75:	83 ec 04             	sub    $0x4,%esp
  78:	ff 75 f4             	pushl  -0xc(%ebp)
  7b:	68 59 0b 00 00       	push   $0xb59
  80:	6a 02                	push   $0x2
  82:	e8 ab 06 00 00       	call   732 <printf>
  87:	83 c4 10             	add    $0x10,%esp
      testsample = TESTCASES[i];
  8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8d:	8b 44 85 d0          	mov    -0x30(%ebp,%eax,4),%eax
  91:	89 45 e8             	mov    %eax,-0x18(%ebp)
      printf(2, "Setting_UID_is:_%d\n", testsample);
  94:	83 ec 04             	sub    $0x4,%esp
  97:	ff 75 e8             	pushl  -0x18(%ebp)
  9a:	68 6d 0b 00 00       	push   $0xb6d
  9f:	6a 02                	push   $0x2
  a1:	e8 8c 06 00 00       	call   732 <printf>
  a6:	83 c4 10             	add    $0x10,%esp
      to_check = setuid(testsample);
  a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  ac:	83 ec 0c             	sub    $0xc,%esp
  af:	50                   	push   %eax
  b0:	e8 8e 05 00 00       	call   643 <setuid>
  b5:	83 c4 10             	add    $0x10,%esp
  b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(to_check == testsample) // for values in bounds
  bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  be:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  c1:	75 0a                	jne    cd <testuidgid+0xcd>
        uid = getuid();
  c3:	e8 63 05 00 00       	call   62b <getuid>
  c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cb:	eb 32                	jmp    ff <testuidgid+0xff>
      else if(!to_check)
  cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  d1:	75 17                	jne    ea <testuidgid+0xea>
        printf(2, "Unable To Set: %d To UID - Out of bounds\n", testsample);// zero for values out of bounds
  d3:	83 ec 04             	sub    $0x4,%esp
  d6:	ff 75 e8             	pushl  -0x18(%ebp)
  d9:	68 84 0b 00 00       	push   $0xb84
  de:	6a 02                	push   $0x2
  e0:	e8 4d 06 00 00       	call   732 <printf>
  e5:	83 c4 10             	add    $0x10,%esp
  e8:	eb 15                	jmp    ff <testuidgid+0xff>
      else
        printf(2, "Unable To Set: %d To UID - Feching Error\n", testsample); //to_check value is -1 - argint failed
  ea:	83 ec 04             	sub    $0x4,%esp
  ed:	ff 75 e8             	pushl  -0x18(%ebp)
  f0:	68 b0 0b 00 00       	push   $0xbb0
  f5:	6a 02                	push   $0x2
  f7:	e8 36 06 00 00       	call   732 <printf>
  fc:	83 c4 10             	add    $0x10,%esp
      printf(2, "Current_UID_is:_%d\n\n", uid);
  ff:	83 ec 04             	sub    $0x4,%esp
 102:	ff 75 f4             	pushl  -0xc(%ebp)
 105:	68 da 0b 00 00       	push   $0xbda
 10a:	6a 02                	push   $0x2
 10c:	e8 21 06 00 00       	call   732 <printf>
 111:	83 c4 10             	add    $0x10,%esp

      //GID TEST
      gid = getgid();
 114:	e8 1a 05 00 00       	call   633 <getgid>
 119:	89 45 f0             	mov    %eax,-0x10(%ebp)
      printf(2, "Current_GID_is:_%d\n", gid);
 11c:	83 ec 04             	sub    $0x4,%esp
 11f:	ff 75 f0             	pushl  -0x10(%ebp)
 122:	68 ef 0b 00 00       	push   $0xbef
 127:	6a 02                	push   $0x2
 129:	e8 04 06 00 00       	call   732 <printf>
 12e:	83 c4 10             	add    $0x10,%esp
      testsample = TESTCASES[i];
 131:	8b 45 ec             	mov    -0x14(%ebp),%eax
 134:	8b 44 85 d0          	mov    -0x30(%ebp,%eax,4),%eax
 138:	89 45 e8             	mov    %eax,-0x18(%ebp)
      printf(2, "Setting_GID_is:_%d\n", testsample);
 13b:	83 ec 04             	sub    $0x4,%esp
 13e:	ff 75 e8             	pushl  -0x18(%ebp)
 141:	68 03 0c 00 00       	push   $0xc03
 146:	6a 02                	push   $0x2
 148:	e8 e5 05 00 00       	call   732 <printf>
 14d:	83 c4 10             	add    $0x10,%esp
      to_check = setgid(testsample);
 150:	8b 45 e8             	mov    -0x18(%ebp),%eax
 153:	83 ec 0c             	sub    $0xc,%esp
 156:	50                   	push   %eax
 157:	e8 ef 04 00 00       	call   64b <setgid>
 15c:	83 c4 10             	add    $0x10,%esp
 15f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(to_check == testsample)
 162:	8b 45 e8             	mov    -0x18(%ebp),%eax
 165:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
 168:	75 0a                	jne    174 <testuidgid+0x174>
        gid = getgid();
 16a:	e8 c4 04 00 00       	call   633 <getgid>
 16f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 172:	eb 32                	jmp    1a6 <testuidgid+0x1a6>
      else if(!to_check)
 174:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 178:	75 17                	jne    191 <testuidgid+0x191>
        printf(2, "Unable To Set: %d To GID - Out of bounds\n", testsample);
 17a:	83 ec 04             	sub    $0x4,%esp
 17d:	ff 75 e8             	pushl  -0x18(%ebp)
 180:	68 18 0c 00 00       	push   $0xc18
 185:	6a 02                	push   $0x2
 187:	e8 a6 05 00 00       	call   732 <printf>
 18c:	83 c4 10             	add    $0x10,%esp
 18f:	eb 15                	jmp    1a6 <testuidgid+0x1a6>
      else
        printf(2, "Unable To Set: %d To UID - Feching Error\n", testsample);
 191:	83 ec 04             	sub    $0x4,%esp
 194:	ff 75 e8             	pushl  -0x18(%ebp)
 197:	68 b0 0b 00 00       	push   $0xbb0
 19c:	6a 02                	push   $0x2
 19e:	e8 8f 05 00 00       	call   732 <printf>
 1a3:	83 c4 10             	add    $0x10,%esp
      printf(2, "Current_GID_is:_%d\n\n", gid);
 1a6:	83 ec 04             	sub    $0x4,%esp
 1a9:	ff 75 f0             	pushl  -0x10(%ebp)
 1ac:	68 42 0c 00 00       	push   $0xc42
 1b1:	6a 02                	push   $0x2
 1b3:	e8 7a 05 00 00       	call   732 <printf>
 1b8:	83 c4 10             	add    $0x10,%esp
int
testuidgid(void)
{
    uint uid, gid, ppid, pid, to_check;
    int testsample, TESTCASES[] = {300, 40000, -3};
    for(int i = 0; i < 3; ++i) // Loop 3 times to check three cases 
 1bb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 1bf:	83 7d ec 02          	cmpl   $0x2,-0x14(%ebp)
 1c3:	0f 8e 5e fe ff ff    	jle    27 <testuidgid+0x27>
      else
        printf(2, "Unable To Set: %d To UID - Feching Error\n", testsample);
      printf(2, "Current_GID_is:_%d\n\n", gid);
    }    

    pid = getpid();
 1c9:	e8 2d 04 00 00       	call   5fb <getpid>
 1ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
    printf(2, "Current_PID_is:_%d\n", pid); 
 1d1:	83 ec 04             	sub    $0x4,%esp
 1d4:	ff 75 e0             	pushl  -0x20(%ebp)
 1d7:	68 57 0c 00 00       	push   $0xc57
 1dc:	6a 02                	push   $0x2
 1de:	e8 4f 05 00 00       	call   732 <printf>
 1e3:	83 c4 10             	add    $0x10,%esp

    ppid = getppid();
 1e6:	e8 50 04 00 00       	call   63b <getppid>
 1eb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(!pid)
 1ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 1f2:	75 14                	jne    208 <testuidgid+0x208>
      printf(2, "Error: Invalid PID - PID Can Not Be Zero\n");
 1f4:	83 ec 08             	sub    $0x8,%esp
 1f7:	68 6c 0c 00 00       	push   $0xc6c
 1fc:	6a 02                	push   $0x2
 1fe:	e8 2f 05 00 00       	call   732 <printf>
 203:	83 c4 10             	add    $0x10,%esp
 206:	eb 15                	jmp    21d <testuidgid+0x21d>
    else
      printf(2, "My_prarent_process_is:_%d\n", ppid);
 208:	83 ec 04             	sub    $0x4,%esp
 20b:	ff 75 dc             	pushl  -0x24(%ebp)
 20e:	68 96 0c 00 00       	push   $0xc96
 213:	6a 02                	push   $0x2
 215:	e8 18 05 00 00       	call   732 <printf>
 21a:	83 c4 10             	add    $0x10,%esp

    printf(2, "Done!\n");
 21d:	83 ec 08             	sub    $0x8,%esp
 220:	68 b1 0c 00 00       	push   $0xcb1
 225:	6a 02                	push   $0x2
 227:	e8 06 05 00 00       	call   732 <printf>
 22c:	83 c4 10             	add    $0x10,%esp
    return 0;
 22f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 234:	c9                   	leave  
 235:	c3                   	ret    

00000236 <main>:
int
main(void)
{
 236:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 23a:	83 e4 f0             	and    $0xfffffff0,%esp
 23d:	ff 71 fc             	pushl  -0x4(%ecx)
 240:	55                   	push   %ebp
 241:	89 e5                	mov    %esp,%ebp
 243:	51                   	push   %ecx
 244:	83 ec 04             	sub    $0x4,%esp
    testuidgid();
 247:	e8 b4 fd ff ff       	call   0 <testuidgid>
    exit();
 24c:	e8 2a 03 00 00       	call   57b <exit>

00000251 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 251:	55                   	push   %ebp
 252:	89 e5                	mov    %esp,%ebp
 254:	57                   	push   %edi
 255:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 256:	8b 4d 08             	mov    0x8(%ebp),%ecx
 259:	8b 55 10             	mov    0x10(%ebp),%edx
 25c:	8b 45 0c             	mov    0xc(%ebp),%eax
 25f:	89 cb                	mov    %ecx,%ebx
 261:	89 df                	mov    %ebx,%edi
 263:	89 d1                	mov    %edx,%ecx
 265:	fc                   	cld    
 266:	f3 aa                	rep stos %al,%es:(%edi)
 268:	89 ca                	mov    %ecx,%edx
 26a:	89 fb                	mov    %edi,%ebx
 26c:	89 5d 08             	mov    %ebx,0x8(%ebp)
 26f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 272:	90                   	nop
 273:	5b                   	pop    %ebx
 274:	5f                   	pop    %edi
 275:	5d                   	pop    %ebp
 276:	c3                   	ret    

00000277 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 277:	55                   	push   %ebp
 278:	89 e5                	mov    %esp,%ebp
 27a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 27d:	8b 45 08             	mov    0x8(%ebp),%eax
 280:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 283:	90                   	nop
 284:	8b 45 08             	mov    0x8(%ebp),%eax
 287:	8d 50 01             	lea    0x1(%eax),%edx
 28a:	89 55 08             	mov    %edx,0x8(%ebp)
 28d:	8b 55 0c             	mov    0xc(%ebp),%edx
 290:	8d 4a 01             	lea    0x1(%edx),%ecx
 293:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 296:	0f b6 12             	movzbl (%edx),%edx
 299:	88 10                	mov    %dl,(%eax)
 29b:	0f b6 00             	movzbl (%eax),%eax
 29e:	84 c0                	test   %al,%al
 2a0:	75 e2                	jne    284 <strcpy+0xd>
    ;
  return os;
 2a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a5:	c9                   	leave  
 2a6:	c3                   	ret    

000002a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2a7:	55                   	push   %ebp
 2a8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2aa:	eb 08                	jmp    2b4 <strcmp+0xd>
    p++, q++;
 2ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2b0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2b4:	8b 45 08             	mov    0x8(%ebp),%eax
 2b7:	0f b6 00             	movzbl (%eax),%eax
 2ba:	84 c0                	test   %al,%al
 2bc:	74 10                	je     2ce <strcmp+0x27>
 2be:	8b 45 08             	mov    0x8(%ebp),%eax
 2c1:	0f b6 10             	movzbl (%eax),%edx
 2c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c7:	0f b6 00             	movzbl (%eax),%eax
 2ca:	38 c2                	cmp    %al,%dl
 2cc:	74 de                	je     2ac <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2ce:	8b 45 08             	mov    0x8(%ebp),%eax
 2d1:	0f b6 00             	movzbl (%eax),%eax
 2d4:	0f b6 d0             	movzbl %al,%edx
 2d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 2da:	0f b6 00             	movzbl (%eax),%eax
 2dd:	0f b6 c0             	movzbl %al,%eax
 2e0:	29 c2                	sub    %eax,%edx
 2e2:	89 d0                	mov    %edx,%eax
}
 2e4:	5d                   	pop    %ebp
 2e5:	c3                   	ret    

000002e6 <strlen>:

uint
strlen(char *s)
{
 2e6:	55                   	push   %ebp
 2e7:	89 e5                	mov    %esp,%ebp
 2e9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2f3:	eb 04                	jmp    2f9 <strlen+0x13>
 2f5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2f9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2fc:	8b 45 08             	mov    0x8(%ebp),%eax
 2ff:	01 d0                	add    %edx,%eax
 301:	0f b6 00             	movzbl (%eax),%eax
 304:	84 c0                	test   %al,%al
 306:	75 ed                	jne    2f5 <strlen+0xf>
    ;
  return n;
 308:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 30b:	c9                   	leave  
 30c:	c3                   	ret    

0000030d <memset>:

void*
memset(void *dst, int c, uint n)
{
 30d:	55                   	push   %ebp
 30e:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 310:	8b 45 10             	mov    0x10(%ebp),%eax
 313:	50                   	push   %eax
 314:	ff 75 0c             	pushl  0xc(%ebp)
 317:	ff 75 08             	pushl  0x8(%ebp)
 31a:	e8 32 ff ff ff       	call   251 <stosb>
 31f:	83 c4 0c             	add    $0xc,%esp
  return dst;
 322:	8b 45 08             	mov    0x8(%ebp),%eax
}
 325:	c9                   	leave  
 326:	c3                   	ret    

00000327 <strchr>:

char*
strchr(const char *s, char c)
{
 327:	55                   	push   %ebp
 328:	89 e5                	mov    %esp,%ebp
 32a:	83 ec 04             	sub    $0x4,%esp
 32d:	8b 45 0c             	mov    0xc(%ebp),%eax
 330:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 333:	eb 14                	jmp    349 <strchr+0x22>
    if(*s == c)
 335:	8b 45 08             	mov    0x8(%ebp),%eax
 338:	0f b6 00             	movzbl (%eax),%eax
 33b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 33e:	75 05                	jne    345 <strchr+0x1e>
      return (char*)s;
 340:	8b 45 08             	mov    0x8(%ebp),%eax
 343:	eb 13                	jmp    358 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 345:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 349:	8b 45 08             	mov    0x8(%ebp),%eax
 34c:	0f b6 00             	movzbl (%eax),%eax
 34f:	84 c0                	test   %al,%al
 351:	75 e2                	jne    335 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 353:	b8 00 00 00 00       	mov    $0x0,%eax
}
 358:	c9                   	leave  
 359:	c3                   	ret    

0000035a <gets>:

char*
gets(char *buf, int max)
{
 35a:	55                   	push   %ebp
 35b:	89 e5                	mov    %esp,%ebp
 35d:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 360:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 367:	eb 42                	jmp    3ab <gets+0x51>
    cc = read(0, &c, 1);
 369:	83 ec 04             	sub    $0x4,%esp
 36c:	6a 01                	push   $0x1
 36e:	8d 45 ef             	lea    -0x11(%ebp),%eax
 371:	50                   	push   %eax
 372:	6a 00                	push   $0x0
 374:	e8 1a 02 00 00       	call   593 <read>
 379:	83 c4 10             	add    $0x10,%esp
 37c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 37f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 383:	7e 33                	jle    3b8 <gets+0x5e>
      break;
    buf[i++] = c;
 385:	8b 45 f4             	mov    -0xc(%ebp),%eax
 388:	8d 50 01             	lea    0x1(%eax),%edx
 38b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 38e:	89 c2                	mov    %eax,%edx
 390:	8b 45 08             	mov    0x8(%ebp),%eax
 393:	01 c2                	add    %eax,%edx
 395:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 399:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 39b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 39f:	3c 0a                	cmp    $0xa,%al
 3a1:	74 16                	je     3b9 <gets+0x5f>
 3a3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3a7:	3c 0d                	cmp    $0xd,%al
 3a9:	74 0e                	je     3b9 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ae:	83 c0 01             	add    $0x1,%eax
 3b1:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3b4:	7c b3                	jl     369 <gets+0xf>
 3b6:	eb 01                	jmp    3b9 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 3b8:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3bc:	8b 45 08             	mov    0x8(%ebp),%eax
 3bf:	01 d0                	add    %edx,%eax
 3c1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3c7:	c9                   	leave  
 3c8:	c3                   	ret    

000003c9 <stat>:

int
stat(char *n, struct stat *st)
{
 3c9:	55                   	push   %ebp
 3ca:	89 e5                	mov    %esp,%ebp
 3cc:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3cf:	83 ec 08             	sub    $0x8,%esp
 3d2:	6a 00                	push   $0x0
 3d4:	ff 75 08             	pushl  0x8(%ebp)
 3d7:	e8 df 01 00 00       	call   5bb <open>
 3dc:	83 c4 10             	add    $0x10,%esp
 3df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3e6:	79 07                	jns    3ef <stat+0x26>
    return -1;
 3e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3ed:	eb 25                	jmp    414 <stat+0x4b>
  r = fstat(fd, st);
 3ef:	83 ec 08             	sub    $0x8,%esp
 3f2:	ff 75 0c             	pushl  0xc(%ebp)
 3f5:	ff 75 f4             	pushl  -0xc(%ebp)
 3f8:	e8 d6 01 00 00       	call   5d3 <fstat>
 3fd:	83 c4 10             	add    $0x10,%esp
 400:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 403:	83 ec 0c             	sub    $0xc,%esp
 406:	ff 75 f4             	pushl  -0xc(%ebp)
 409:	e8 95 01 00 00       	call   5a3 <close>
 40e:	83 c4 10             	add    $0x10,%esp
  return r;
 411:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 414:	c9                   	leave  
 415:	c3                   	ret    

00000416 <atoi>:

int
atoi(const char *s)
{
 416:	55                   	push   %ebp
 417:	89 e5                	mov    %esp,%ebp
 419:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 41c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 423:	eb 04                	jmp    429 <atoi+0x13>
 425:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 429:	8b 45 08             	mov    0x8(%ebp),%eax
 42c:	0f b6 00             	movzbl (%eax),%eax
 42f:	3c 20                	cmp    $0x20,%al
 431:	74 f2                	je     425 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 433:	8b 45 08             	mov    0x8(%ebp),%eax
 436:	0f b6 00             	movzbl (%eax),%eax
 439:	3c 2d                	cmp    $0x2d,%al
 43b:	75 07                	jne    444 <atoi+0x2e>
 43d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 442:	eb 05                	jmp    449 <atoi+0x33>
 444:	b8 01 00 00 00       	mov    $0x1,%eax
 449:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 44c:	8b 45 08             	mov    0x8(%ebp),%eax
 44f:	0f b6 00             	movzbl (%eax),%eax
 452:	3c 2b                	cmp    $0x2b,%al
 454:	74 0a                	je     460 <atoi+0x4a>
 456:	8b 45 08             	mov    0x8(%ebp),%eax
 459:	0f b6 00             	movzbl (%eax),%eax
 45c:	3c 2d                	cmp    $0x2d,%al
 45e:	75 2b                	jne    48b <atoi+0x75>
    s++;
 460:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 464:	eb 25                	jmp    48b <atoi+0x75>
    n = n*10 + *s++ - '0';
 466:	8b 55 fc             	mov    -0x4(%ebp),%edx
 469:	89 d0                	mov    %edx,%eax
 46b:	c1 e0 02             	shl    $0x2,%eax
 46e:	01 d0                	add    %edx,%eax
 470:	01 c0                	add    %eax,%eax
 472:	89 c1                	mov    %eax,%ecx
 474:	8b 45 08             	mov    0x8(%ebp),%eax
 477:	8d 50 01             	lea    0x1(%eax),%edx
 47a:	89 55 08             	mov    %edx,0x8(%ebp)
 47d:	0f b6 00             	movzbl (%eax),%eax
 480:	0f be c0             	movsbl %al,%eax
 483:	01 c8                	add    %ecx,%eax
 485:	83 e8 30             	sub    $0x30,%eax
 488:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 48b:	8b 45 08             	mov    0x8(%ebp),%eax
 48e:	0f b6 00             	movzbl (%eax),%eax
 491:	3c 2f                	cmp    $0x2f,%al
 493:	7e 0a                	jle    49f <atoi+0x89>
 495:	8b 45 08             	mov    0x8(%ebp),%eax
 498:	0f b6 00             	movzbl (%eax),%eax
 49b:	3c 39                	cmp    $0x39,%al
 49d:	7e c7                	jle    466 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 49f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4a2:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 4a6:	c9                   	leave  
 4a7:	c3                   	ret    

000004a8 <atoo>:

int
atoo(const char *s)
{
 4a8:	55                   	push   %ebp
 4a9:	89 e5                	mov    %esp,%ebp
 4ab:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 4ae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 4b5:	eb 04                	jmp    4bb <atoo+0x13>
 4b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4bb:	8b 45 08             	mov    0x8(%ebp),%eax
 4be:	0f b6 00             	movzbl (%eax),%eax
 4c1:	3c 20                	cmp    $0x20,%al
 4c3:	74 f2                	je     4b7 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 4c5:	8b 45 08             	mov    0x8(%ebp),%eax
 4c8:	0f b6 00             	movzbl (%eax),%eax
 4cb:	3c 2d                	cmp    $0x2d,%al
 4cd:	75 07                	jne    4d6 <atoo+0x2e>
 4cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4d4:	eb 05                	jmp    4db <atoo+0x33>
 4d6:	b8 01 00 00 00       	mov    $0x1,%eax
 4db:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 4de:	8b 45 08             	mov    0x8(%ebp),%eax
 4e1:	0f b6 00             	movzbl (%eax),%eax
 4e4:	3c 2b                	cmp    $0x2b,%al
 4e6:	74 0a                	je     4f2 <atoo+0x4a>
 4e8:	8b 45 08             	mov    0x8(%ebp),%eax
 4eb:	0f b6 00             	movzbl (%eax),%eax
 4ee:	3c 2d                	cmp    $0x2d,%al
 4f0:	75 27                	jne    519 <atoo+0x71>
    s++;
 4f2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 4f6:	eb 21                	jmp    519 <atoo+0x71>
    n = n*8 + *s++ - '0';
 4f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4fb:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 502:	8b 45 08             	mov    0x8(%ebp),%eax
 505:	8d 50 01             	lea    0x1(%eax),%edx
 508:	89 55 08             	mov    %edx,0x8(%ebp)
 50b:	0f b6 00             	movzbl (%eax),%eax
 50e:	0f be c0             	movsbl %al,%eax
 511:	01 c8                	add    %ecx,%eax
 513:	83 e8 30             	sub    $0x30,%eax
 516:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 519:	8b 45 08             	mov    0x8(%ebp),%eax
 51c:	0f b6 00             	movzbl (%eax),%eax
 51f:	3c 2f                	cmp    $0x2f,%al
 521:	7e 0a                	jle    52d <atoo+0x85>
 523:	8b 45 08             	mov    0x8(%ebp),%eax
 526:	0f b6 00             	movzbl (%eax),%eax
 529:	3c 37                	cmp    $0x37,%al
 52b:	7e cb                	jle    4f8 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 52d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 530:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 534:	c9                   	leave  
 535:	c3                   	ret    

00000536 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 536:	55                   	push   %ebp
 537:	89 e5                	mov    %esp,%ebp
 539:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 53c:	8b 45 08             	mov    0x8(%ebp),%eax
 53f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 542:	8b 45 0c             	mov    0xc(%ebp),%eax
 545:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 548:	eb 17                	jmp    561 <memmove+0x2b>
    *dst++ = *src++;
 54a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 54d:	8d 50 01             	lea    0x1(%eax),%edx
 550:	89 55 fc             	mov    %edx,-0x4(%ebp)
 553:	8b 55 f8             	mov    -0x8(%ebp),%edx
 556:	8d 4a 01             	lea    0x1(%edx),%ecx
 559:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 55c:	0f b6 12             	movzbl (%edx),%edx
 55f:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 561:	8b 45 10             	mov    0x10(%ebp),%eax
 564:	8d 50 ff             	lea    -0x1(%eax),%edx
 567:	89 55 10             	mov    %edx,0x10(%ebp)
 56a:	85 c0                	test   %eax,%eax
 56c:	7f dc                	jg     54a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 56e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 571:	c9                   	leave  
 572:	c3                   	ret    

00000573 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 573:	b8 01 00 00 00       	mov    $0x1,%eax
 578:	cd 40                	int    $0x40
 57a:	c3                   	ret    

0000057b <exit>:
SYSCALL(exit)
 57b:	b8 02 00 00 00       	mov    $0x2,%eax
 580:	cd 40                	int    $0x40
 582:	c3                   	ret    

00000583 <wait>:
SYSCALL(wait)
 583:	b8 03 00 00 00       	mov    $0x3,%eax
 588:	cd 40                	int    $0x40
 58a:	c3                   	ret    

0000058b <pipe>:
SYSCALL(pipe)
 58b:	b8 04 00 00 00       	mov    $0x4,%eax
 590:	cd 40                	int    $0x40
 592:	c3                   	ret    

00000593 <read>:
SYSCALL(read)
 593:	b8 05 00 00 00       	mov    $0x5,%eax
 598:	cd 40                	int    $0x40
 59a:	c3                   	ret    

0000059b <write>:
SYSCALL(write)
 59b:	b8 10 00 00 00       	mov    $0x10,%eax
 5a0:	cd 40                	int    $0x40
 5a2:	c3                   	ret    

000005a3 <close>:
SYSCALL(close)
 5a3:	b8 15 00 00 00       	mov    $0x15,%eax
 5a8:	cd 40                	int    $0x40
 5aa:	c3                   	ret    

000005ab <kill>:
SYSCALL(kill)
 5ab:	b8 06 00 00 00       	mov    $0x6,%eax
 5b0:	cd 40                	int    $0x40
 5b2:	c3                   	ret    

000005b3 <exec>:
SYSCALL(exec)
 5b3:	b8 07 00 00 00       	mov    $0x7,%eax
 5b8:	cd 40                	int    $0x40
 5ba:	c3                   	ret    

000005bb <open>:
SYSCALL(open)
 5bb:	b8 0f 00 00 00       	mov    $0xf,%eax
 5c0:	cd 40                	int    $0x40
 5c2:	c3                   	ret    

000005c3 <mknod>:
SYSCALL(mknod)
 5c3:	b8 11 00 00 00       	mov    $0x11,%eax
 5c8:	cd 40                	int    $0x40
 5ca:	c3                   	ret    

000005cb <unlink>:
SYSCALL(unlink)
 5cb:	b8 12 00 00 00       	mov    $0x12,%eax
 5d0:	cd 40                	int    $0x40
 5d2:	c3                   	ret    

000005d3 <fstat>:
SYSCALL(fstat)
 5d3:	b8 08 00 00 00       	mov    $0x8,%eax
 5d8:	cd 40                	int    $0x40
 5da:	c3                   	ret    

000005db <link>:
SYSCALL(link)
 5db:	b8 13 00 00 00       	mov    $0x13,%eax
 5e0:	cd 40                	int    $0x40
 5e2:	c3                   	ret    

000005e3 <mkdir>:
SYSCALL(mkdir)
 5e3:	b8 14 00 00 00       	mov    $0x14,%eax
 5e8:	cd 40                	int    $0x40
 5ea:	c3                   	ret    

000005eb <chdir>:
SYSCALL(chdir)
 5eb:	b8 09 00 00 00       	mov    $0x9,%eax
 5f0:	cd 40                	int    $0x40
 5f2:	c3                   	ret    

000005f3 <dup>:
SYSCALL(dup)
 5f3:	b8 0a 00 00 00       	mov    $0xa,%eax
 5f8:	cd 40                	int    $0x40
 5fa:	c3                   	ret    

000005fb <getpid>:
SYSCALL(getpid)
 5fb:	b8 0b 00 00 00       	mov    $0xb,%eax
 600:	cd 40                	int    $0x40
 602:	c3                   	ret    

00000603 <sbrk>:
SYSCALL(sbrk)
 603:	b8 0c 00 00 00       	mov    $0xc,%eax
 608:	cd 40                	int    $0x40
 60a:	c3                   	ret    

0000060b <sleep>:
SYSCALL(sleep)
 60b:	b8 0d 00 00 00       	mov    $0xd,%eax
 610:	cd 40                	int    $0x40
 612:	c3                   	ret    

00000613 <uptime>:
SYSCALL(uptime)
 613:	b8 0e 00 00 00       	mov    $0xe,%eax
 618:	cd 40                	int    $0x40
 61a:	c3                   	ret    

0000061b <halt>:
SYSCALL(halt)
 61b:	b8 16 00 00 00       	mov    $0x16,%eax
 620:	cd 40                	int    $0x40
 622:	c3                   	ret    

00000623 <date>:
SYSCALL(date)
 623:	b8 17 00 00 00       	mov    $0x17,%eax
 628:	cd 40                	int    $0x40
 62a:	c3                   	ret    

0000062b <getuid>:
SYSCALL(getuid)
 62b:	b8 18 00 00 00       	mov    $0x18,%eax
 630:	cd 40                	int    $0x40
 632:	c3                   	ret    

00000633 <getgid>:
SYSCALL(getgid)
 633:	b8 19 00 00 00       	mov    $0x19,%eax
 638:	cd 40                	int    $0x40
 63a:	c3                   	ret    

0000063b <getppid>:
SYSCALL(getppid)
 63b:	b8 1a 00 00 00       	mov    $0x1a,%eax
 640:	cd 40                	int    $0x40
 642:	c3                   	ret    

00000643 <setuid>:
SYSCALL(setuid)
 643:	b8 1b 00 00 00       	mov    $0x1b,%eax
 648:	cd 40                	int    $0x40
 64a:	c3                   	ret    

0000064b <setgid>:
SYSCALL(setgid)
 64b:	b8 1c 00 00 00       	mov    $0x1c,%eax
 650:	cd 40                	int    $0x40
 652:	c3                   	ret    

00000653 <getprocs>:
SYSCALL(getprocs)
 653:	b8 1d 00 00 00       	mov    $0x1d,%eax
 658:	cd 40                	int    $0x40
 65a:	c3                   	ret    

0000065b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 65b:	55                   	push   %ebp
 65c:	89 e5                	mov    %esp,%ebp
 65e:	83 ec 18             	sub    $0x18,%esp
 661:	8b 45 0c             	mov    0xc(%ebp),%eax
 664:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 667:	83 ec 04             	sub    $0x4,%esp
 66a:	6a 01                	push   $0x1
 66c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 66f:	50                   	push   %eax
 670:	ff 75 08             	pushl  0x8(%ebp)
 673:	e8 23 ff ff ff       	call   59b <write>
 678:	83 c4 10             	add    $0x10,%esp
}
 67b:	90                   	nop
 67c:	c9                   	leave  
 67d:	c3                   	ret    

0000067e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 67e:	55                   	push   %ebp
 67f:	89 e5                	mov    %esp,%ebp
 681:	53                   	push   %ebx
 682:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 685:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 68c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 690:	74 17                	je     6a9 <printint+0x2b>
 692:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 696:	79 11                	jns    6a9 <printint+0x2b>
    neg = 1;
 698:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 69f:	8b 45 0c             	mov    0xc(%ebp),%eax
 6a2:	f7 d8                	neg    %eax
 6a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6a7:	eb 06                	jmp    6af <printint+0x31>
  } else {
    x = xx;
 6a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6b6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6b9:	8d 41 01             	lea    0x1(%ecx),%eax
 6bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6c5:	ba 00 00 00 00       	mov    $0x0,%edx
 6ca:	f7 f3                	div    %ebx
 6cc:	89 d0                	mov    %edx,%eax
 6ce:	0f b6 80 48 0f 00 00 	movzbl 0xf48(%eax),%eax
 6d5:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6df:	ba 00 00 00 00       	mov    $0x0,%edx
 6e4:	f7 f3                	div    %ebx
 6e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6ed:	75 c7                	jne    6b6 <printint+0x38>
  if(neg)
 6ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6f3:	74 2d                	je     722 <printint+0xa4>
    buf[i++] = '-';
 6f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f8:	8d 50 01             	lea    0x1(%eax),%edx
 6fb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6fe:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 703:	eb 1d                	jmp    722 <printint+0xa4>
    putc(fd, buf[i]);
 705:	8d 55 dc             	lea    -0x24(%ebp),%edx
 708:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70b:	01 d0                	add    %edx,%eax
 70d:	0f b6 00             	movzbl (%eax),%eax
 710:	0f be c0             	movsbl %al,%eax
 713:	83 ec 08             	sub    $0x8,%esp
 716:	50                   	push   %eax
 717:	ff 75 08             	pushl  0x8(%ebp)
 71a:	e8 3c ff ff ff       	call   65b <putc>
 71f:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 722:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 726:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 72a:	79 d9                	jns    705 <printint+0x87>
    putc(fd, buf[i]);
}
 72c:	90                   	nop
 72d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 730:	c9                   	leave  
 731:	c3                   	ret    

00000732 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 732:	55                   	push   %ebp
 733:	89 e5                	mov    %esp,%ebp
 735:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 738:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 73f:	8d 45 0c             	lea    0xc(%ebp),%eax
 742:	83 c0 04             	add    $0x4,%eax
 745:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 748:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 74f:	e9 59 01 00 00       	jmp    8ad <printf+0x17b>
    c = fmt[i] & 0xff;
 754:	8b 55 0c             	mov    0xc(%ebp),%edx
 757:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75a:	01 d0                	add    %edx,%eax
 75c:	0f b6 00             	movzbl (%eax),%eax
 75f:	0f be c0             	movsbl %al,%eax
 762:	25 ff 00 00 00       	and    $0xff,%eax
 767:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 76a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 76e:	75 2c                	jne    79c <printf+0x6a>
      if(c == '%'){
 770:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 774:	75 0c                	jne    782 <printf+0x50>
        state = '%';
 776:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 77d:	e9 27 01 00 00       	jmp    8a9 <printf+0x177>
      } else {
        putc(fd, c);
 782:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 785:	0f be c0             	movsbl %al,%eax
 788:	83 ec 08             	sub    $0x8,%esp
 78b:	50                   	push   %eax
 78c:	ff 75 08             	pushl  0x8(%ebp)
 78f:	e8 c7 fe ff ff       	call   65b <putc>
 794:	83 c4 10             	add    $0x10,%esp
 797:	e9 0d 01 00 00       	jmp    8a9 <printf+0x177>
      }
    } else if(state == '%'){
 79c:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7a0:	0f 85 03 01 00 00    	jne    8a9 <printf+0x177>
      if(c == 'd'){
 7a6:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7aa:	75 1e                	jne    7ca <printf+0x98>
        printint(fd, *ap, 10, 1);
 7ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7af:	8b 00                	mov    (%eax),%eax
 7b1:	6a 01                	push   $0x1
 7b3:	6a 0a                	push   $0xa
 7b5:	50                   	push   %eax
 7b6:	ff 75 08             	pushl  0x8(%ebp)
 7b9:	e8 c0 fe ff ff       	call   67e <printint>
 7be:	83 c4 10             	add    $0x10,%esp
        ap++;
 7c1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c5:	e9 d8 00 00 00       	jmp    8a2 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7ca:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7ce:	74 06                	je     7d6 <printf+0xa4>
 7d0:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7d4:	75 1e                	jne    7f4 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d9:	8b 00                	mov    (%eax),%eax
 7db:	6a 00                	push   $0x0
 7dd:	6a 10                	push   $0x10
 7df:	50                   	push   %eax
 7e0:	ff 75 08             	pushl  0x8(%ebp)
 7e3:	e8 96 fe ff ff       	call   67e <printint>
 7e8:	83 c4 10             	add    $0x10,%esp
        ap++;
 7eb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ef:	e9 ae 00 00 00       	jmp    8a2 <printf+0x170>
      } else if(c == 's'){
 7f4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7f8:	75 43                	jne    83d <printf+0x10b>
        s = (char*)*ap;
 7fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7fd:	8b 00                	mov    (%eax),%eax
 7ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 802:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 806:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 80a:	75 25                	jne    831 <printf+0xff>
          s = "(null)";
 80c:	c7 45 f4 b8 0c 00 00 	movl   $0xcb8,-0xc(%ebp)
        while(*s != 0){
 813:	eb 1c                	jmp    831 <printf+0xff>
          putc(fd, *s);
 815:	8b 45 f4             	mov    -0xc(%ebp),%eax
 818:	0f b6 00             	movzbl (%eax),%eax
 81b:	0f be c0             	movsbl %al,%eax
 81e:	83 ec 08             	sub    $0x8,%esp
 821:	50                   	push   %eax
 822:	ff 75 08             	pushl  0x8(%ebp)
 825:	e8 31 fe ff ff       	call   65b <putc>
 82a:	83 c4 10             	add    $0x10,%esp
          s++;
 82d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 831:	8b 45 f4             	mov    -0xc(%ebp),%eax
 834:	0f b6 00             	movzbl (%eax),%eax
 837:	84 c0                	test   %al,%al
 839:	75 da                	jne    815 <printf+0xe3>
 83b:	eb 65                	jmp    8a2 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 83d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 841:	75 1d                	jne    860 <printf+0x12e>
        putc(fd, *ap);
 843:	8b 45 e8             	mov    -0x18(%ebp),%eax
 846:	8b 00                	mov    (%eax),%eax
 848:	0f be c0             	movsbl %al,%eax
 84b:	83 ec 08             	sub    $0x8,%esp
 84e:	50                   	push   %eax
 84f:	ff 75 08             	pushl  0x8(%ebp)
 852:	e8 04 fe ff ff       	call   65b <putc>
 857:	83 c4 10             	add    $0x10,%esp
        ap++;
 85a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 85e:	eb 42                	jmp    8a2 <printf+0x170>
      } else if(c == '%'){
 860:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 864:	75 17                	jne    87d <printf+0x14b>
        putc(fd, c);
 866:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 869:	0f be c0             	movsbl %al,%eax
 86c:	83 ec 08             	sub    $0x8,%esp
 86f:	50                   	push   %eax
 870:	ff 75 08             	pushl  0x8(%ebp)
 873:	e8 e3 fd ff ff       	call   65b <putc>
 878:	83 c4 10             	add    $0x10,%esp
 87b:	eb 25                	jmp    8a2 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 87d:	83 ec 08             	sub    $0x8,%esp
 880:	6a 25                	push   $0x25
 882:	ff 75 08             	pushl  0x8(%ebp)
 885:	e8 d1 fd ff ff       	call   65b <putc>
 88a:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 88d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 890:	0f be c0             	movsbl %al,%eax
 893:	83 ec 08             	sub    $0x8,%esp
 896:	50                   	push   %eax
 897:	ff 75 08             	pushl  0x8(%ebp)
 89a:	e8 bc fd ff ff       	call   65b <putc>
 89f:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8a2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8a9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8ad:	8b 55 0c             	mov    0xc(%ebp),%edx
 8b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b3:	01 d0                	add    %edx,%eax
 8b5:	0f b6 00             	movzbl (%eax),%eax
 8b8:	84 c0                	test   %al,%al
 8ba:	0f 85 94 fe ff ff    	jne    754 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8c0:	90                   	nop
 8c1:	c9                   	leave  
 8c2:	c3                   	ret    

000008c3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8c3:	55                   	push   %ebp
 8c4:	89 e5                	mov    %esp,%ebp
 8c6:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8c9:	8b 45 08             	mov    0x8(%ebp),%eax
 8cc:	83 e8 08             	sub    $0x8,%eax
 8cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d2:	a1 64 0f 00 00       	mov    0xf64,%eax
 8d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8da:	eb 24                	jmp    900 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8df:	8b 00                	mov    (%eax),%eax
 8e1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8e4:	77 12                	ja     8f8 <free+0x35>
 8e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8ec:	77 24                	ja     912 <free+0x4f>
 8ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f1:	8b 00                	mov    (%eax),%eax
 8f3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8f6:	77 1a                	ja     912 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fb:	8b 00                	mov    (%eax),%eax
 8fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
 900:	8b 45 f8             	mov    -0x8(%ebp),%eax
 903:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 906:	76 d4                	jbe    8dc <free+0x19>
 908:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90b:	8b 00                	mov    (%eax),%eax
 90d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 910:	76 ca                	jbe    8dc <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 912:	8b 45 f8             	mov    -0x8(%ebp),%eax
 915:	8b 40 04             	mov    0x4(%eax),%eax
 918:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 91f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 922:	01 c2                	add    %eax,%edx
 924:	8b 45 fc             	mov    -0x4(%ebp),%eax
 927:	8b 00                	mov    (%eax),%eax
 929:	39 c2                	cmp    %eax,%edx
 92b:	75 24                	jne    951 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 92d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 930:	8b 50 04             	mov    0x4(%eax),%edx
 933:	8b 45 fc             	mov    -0x4(%ebp),%eax
 936:	8b 00                	mov    (%eax),%eax
 938:	8b 40 04             	mov    0x4(%eax),%eax
 93b:	01 c2                	add    %eax,%edx
 93d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 940:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 943:	8b 45 fc             	mov    -0x4(%ebp),%eax
 946:	8b 00                	mov    (%eax),%eax
 948:	8b 10                	mov    (%eax),%edx
 94a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94d:	89 10                	mov    %edx,(%eax)
 94f:	eb 0a                	jmp    95b <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 951:	8b 45 fc             	mov    -0x4(%ebp),%eax
 954:	8b 10                	mov    (%eax),%edx
 956:	8b 45 f8             	mov    -0x8(%ebp),%eax
 959:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 95b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95e:	8b 40 04             	mov    0x4(%eax),%eax
 961:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 968:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96b:	01 d0                	add    %edx,%eax
 96d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 970:	75 20                	jne    992 <free+0xcf>
    p->s.size += bp->s.size;
 972:	8b 45 fc             	mov    -0x4(%ebp),%eax
 975:	8b 50 04             	mov    0x4(%eax),%edx
 978:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97b:	8b 40 04             	mov    0x4(%eax),%eax
 97e:	01 c2                	add    %eax,%edx
 980:	8b 45 fc             	mov    -0x4(%ebp),%eax
 983:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 986:	8b 45 f8             	mov    -0x8(%ebp),%eax
 989:	8b 10                	mov    (%eax),%edx
 98b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98e:	89 10                	mov    %edx,(%eax)
 990:	eb 08                	jmp    99a <free+0xd7>
  } else
    p->s.ptr = bp;
 992:	8b 45 fc             	mov    -0x4(%ebp),%eax
 995:	8b 55 f8             	mov    -0x8(%ebp),%edx
 998:	89 10                	mov    %edx,(%eax)
  freep = p;
 99a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99d:	a3 64 0f 00 00       	mov    %eax,0xf64
}
 9a2:	90                   	nop
 9a3:	c9                   	leave  
 9a4:	c3                   	ret    

000009a5 <morecore>:

static Header*
morecore(uint nu)
{
 9a5:	55                   	push   %ebp
 9a6:	89 e5                	mov    %esp,%ebp
 9a8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9ab:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9b2:	77 07                	ja     9bb <morecore+0x16>
    nu = 4096;
 9b4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9bb:	8b 45 08             	mov    0x8(%ebp),%eax
 9be:	c1 e0 03             	shl    $0x3,%eax
 9c1:	83 ec 0c             	sub    $0xc,%esp
 9c4:	50                   	push   %eax
 9c5:	e8 39 fc ff ff       	call   603 <sbrk>
 9ca:	83 c4 10             	add    $0x10,%esp
 9cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9d0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9d4:	75 07                	jne    9dd <morecore+0x38>
    return 0;
 9d6:	b8 00 00 00 00       	mov    $0x0,%eax
 9db:	eb 26                	jmp    a03 <morecore+0x5e>
  hp = (Header*)p;
 9dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e6:	8b 55 08             	mov    0x8(%ebp),%edx
 9e9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ef:	83 c0 08             	add    $0x8,%eax
 9f2:	83 ec 0c             	sub    $0xc,%esp
 9f5:	50                   	push   %eax
 9f6:	e8 c8 fe ff ff       	call   8c3 <free>
 9fb:	83 c4 10             	add    $0x10,%esp
  return freep;
 9fe:	a1 64 0f 00 00       	mov    0xf64,%eax
}
 a03:	c9                   	leave  
 a04:	c3                   	ret    

00000a05 <malloc>:

void*
malloc(uint nbytes)
{
 a05:	55                   	push   %ebp
 a06:	89 e5                	mov    %esp,%ebp
 a08:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a0b:	8b 45 08             	mov    0x8(%ebp),%eax
 a0e:	83 c0 07             	add    $0x7,%eax
 a11:	c1 e8 03             	shr    $0x3,%eax
 a14:	83 c0 01             	add    $0x1,%eax
 a17:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a1a:	a1 64 0f 00 00       	mov    0xf64,%eax
 a1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a26:	75 23                	jne    a4b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a28:	c7 45 f0 5c 0f 00 00 	movl   $0xf5c,-0x10(%ebp)
 a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a32:	a3 64 0f 00 00       	mov    %eax,0xf64
 a37:	a1 64 0f 00 00       	mov    0xf64,%eax
 a3c:	a3 5c 0f 00 00       	mov    %eax,0xf5c
    base.s.size = 0;
 a41:	c7 05 60 0f 00 00 00 	movl   $0x0,0xf60
 a48:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4e:	8b 00                	mov    (%eax),%eax
 a50:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a56:	8b 40 04             	mov    0x4(%eax),%eax
 a59:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a5c:	72 4d                	jb     aab <malloc+0xa6>
      if(p->s.size == nunits)
 a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a61:	8b 40 04             	mov    0x4(%eax),%eax
 a64:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a67:	75 0c                	jne    a75 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6c:	8b 10                	mov    (%eax),%edx
 a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a71:	89 10                	mov    %edx,(%eax)
 a73:	eb 26                	jmp    a9b <malloc+0x96>
      else {
        p->s.size -= nunits;
 a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a78:	8b 40 04             	mov    0x4(%eax),%eax
 a7b:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a7e:	89 c2                	mov    %eax,%edx
 a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a83:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a89:	8b 40 04             	mov    0x4(%eax),%eax
 a8c:	c1 e0 03             	shl    $0x3,%eax
 a8f:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a95:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a98:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a9e:	a3 64 0f 00 00       	mov    %eax,0xf64
      return (void*)(p + 1);
 aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa6:	83 c0 08             	add    $0x8,%eax
 aa9:	eb 3b                	jmp    ae6 <malloc+0xe1>
    }
    if(p == freep)
 aab:	a1 64 0f 00 00       	mov    0xf64,%eax
 ab0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ab3:	75 1e                	jne    ad3 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ab5:	83 ec 0c             	sub    $0xc,%esp
 ab8:	ff 75 ec             	pushl  -0x14(%ebp)
 abb:	e8 e5 fe ff ff       	call   9a5 <morecore>
 ac0:	83 c4 10             	add    $0x10,%esp
 ac3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ac6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aca:	75 07                	jne    ad3 <malloc+0xce>
        return 0;
 acc:	b8 00 00 00 00       	mov    $0x0,%eax
 ad1:	eb 13                	jmp    ae6 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 adc:	8b 00                	mov    (%eax),%eax
 ade:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ae1:	e9 6d ff ff ff       	jmp    a53 <malloc+0x4e>
}
 ae6:	c9                   	leave  
 ae7:	c3                   	ret    
