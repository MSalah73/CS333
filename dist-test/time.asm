
_time:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#ifdef CS333_P2
#include "types.h"
#include "user.h"
int
main(int argc, char * argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 20             	sub    $0x20,%esp
  12:	89 cb                	mov    %ecx,%ebx
  ++argv;//ingore the first arg and move throght list of args pass on on main
  14:	83 43 04 04          	addl   $0x4,0x4(%ebx)
  int start, end, sec, milisec, pid = fork();//the purpose of calling fork is to invert the list so it looks like the P2 sample
  18:	e8 63 04 00 00       	call   480 <fork>
  1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char * zeros = "";
  20:	c7 45 f4 f5 09 00 00 	movl   $0x9f5,-0xc(%ebp)

  if(pid < 0)
  27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  2b:	79 17                	jns    44 <main+0x44>
  {
    printf(1, "Error: Fork Failed\n");
  2d:	83 ec 08             	sub    $0x8,%esp
  30:	68 f6 09 00 00       	push   $0x9f6
  35:	6a 01                	push   $0x1
  37:	e8 03 06 00 00       	call   63f <printf>
  3c:	83 c4 10             	add    $0x10,%esp
    exit();
  3f:	e8 44 04 00 00       	call   488 <exit>
  }
  //wait();//to remove possibility of zombies 
  if(!pid)// to invert the list of calls, we need to call exec function, and ignore other postive 1  n pid  
  44:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  48:	75 38                	jne    82 <main+0x82>
    if(exec(argv[0], argv))//run function such as time and echo from the list of arg list pass on
  4a:	8b 43 04             	mov    0x4(%ebx),%eax
  4d:	8b 00                	mov    (%eax),%eax
  4f:	83 ec 08             	sub    $0x8,%esp
  52:	ff 73 04             	pushl  0x4(%ebx)
  55:	50                   	push   %eax
  56:	e8 65 04 00 00       	call   4c0 <exec>
  5b:	83 c4 10             	add    $0x10,%esp
  5e:	85 c0                	test   %eax,%eax
  60:	74 20                	je     82 <main+0x82>
    {
      if(argv[0])
  62:	8b 43 04             	mov    0x4(%ebx),%eax
  65:	8b 00                	mov    (%eax),%eax
  67:	85 c0                	test   %eax,%eax
  69:	74 12                	je     7d <main+0x7d>
          printf(1, "Exec fault\n");
  6b:	83 ec 08             	sub    $0x8,%esp
  6e:	68 0a 0a 00 00       	push   $0xa0a
  73:	6a 01                	push   $0x1
  75:	e8 c5 05 00 00       	call   63f <printf>
  7a:	83 c4 10             	add    $0x10,%esp
      exit();
  7d:	e8 06 04 00 00       	call   488 <exit>
    }

  start = uptime(); //do time ps to check correctness
  82:	e8 99 04 00 00       	call   520 <uptime>
  87:	89 45 ec             	mov    %eax,-0x14(%ebp)
  wait();//to remove possibility of zombies 
  8a:	e8 01 04 00 00       	call   490 <wait>
  end = uptime();
  8f:	e8 8c 04 00 00       	call   520 <uptime>
  94:	89 45 e8             	mov    %eax,-0x18(%ebp)
  sec = (end - start)/1000;
  97:	8b 45 e8             	mov    -0x18(%ebp),%eax
  9a:	2b 45 ec             	sub    -0x14(%ebp),%eax
  9d:	89 c1                	mov    %eax,%ecx
  9f:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  a4:	89 c8                	mov    %ecx,%eax
  a6:	f7 ea                	imul   %edx
  a8:	c1 fa 06             	sar    $0x6,%edx
  ab:	89 c8                	mov    %ecx,%eax
  ad:	c1 f8 1f             	sar    $0x1f,%eax
  b0:	29 c2                	sub    %eax,%edx
  b2:	89 d0                	mov    %edx,%eax
  b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  milisec = (end - start) % 1000;
  b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  ba:	2b 45 ec             	sub    -0x14(%ebp),%eax
  bd:	89 c1                	mov    %eax,%ecx
  bf:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  c4:	89 c8                	mov    %ecx,%eax
  c6:	f7 ea                	imul   %edx
  c8:	c1 fa 06             	sar    $0x6,%edx
  cb:	89 c8                	mov    %ecx,%eax
  cd:	c1 f8 1f             	sar    $0x1f,%eax
  d0:	29 c2                	sub    %eax,%edx
  d2:	89 d0                	mov    %edx,%eax
  d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  da:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
  e0:	29 c1                	sub    %eax,%ecx
  e2:	89 c8                	mov    %ecx,%eax
  e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((milisec < 10 && milisec > 1))
  e7:	83 7d e0 09          	cmpl   $0x9,-0x20(%ebp)
  eb:	7f 0f                	jg     fc <main+0xfc>
  ed:	83 7d e0 01          	cmpl   $0x1,-0x20(%ebp)
  f1:	7e 09                	jle    fc <main+0xfc>
    zeros = "00";
  f3:	c7 45 f4 16 0a 00 00 	movl   $0xa16,-0xc(%ebp)
  fa:	eb 16                	jmp    112 <main+0x112>
  else if(milisec < 100)
  fc:	83 7d e0 63          	cmpl   $0x63,-0x20(%ebp)
 100:	7f 09                	jg     10b <main+0x10b>
    zeros = "0";
 102:	c7 45 f4 19 0a 00 00 	movl   $0xa19,-0xc(%ebp)
 109:	eb 07                	jmp    112 <main+0x112>
  else
    zeros = "";
 10b:	c7 45 f4 f5 09 00 00 	movl   $0x9f5,-0xc(%ebp)

  if(!argv[0])
 112:	8b 43 04             	mov    0x4(%ebx),%eax
 115:	8b 00                	mov    (%eax),%eax
 117:	85 c0                	test   %eax,%eax
 119:	75 1d                	jne    138 <main+0x138>
      printf(2, "Ran in %d.%s%d\n", sec, zeros, milisec);
 11b:	83 ec 0c             	sub    $0xc,%esp
 11e:	ff 75 e0             	pushl  -0x20(%ebp)
 121:	ff 75 f4             	pushl  -0xc(%ebp)
 124:	ff 75 e4             	pushl  -0x1c(%ebp)
 127:	68 1b 0a 00 00       	push   $0xa1b
 12c:	6a 02                	push   $0x2
 12e:	e8 0c 05 00 00       	call   63f <printf>
 133:	83 c4 20             	add    $0x20,%esp
 136:	eb 21                	jmp    159 <main+0x159>
  else
      printf(2, "%s ran in %d.%s%d\n", argv[0], sec, zeros, milisec);
 138:	8b 43 04             	mov    0x4(%ebx),%eax
 13b:	8b 00                	mov    (%eax),%eax
 13d:	83 ec 08             	sub    $0x8,%esp
 140:	ff 75 e0             	pushl  -0x20(%ebp)
 143:	ff 75 f4             	pushl  -0xc(%ebp)
 146:	ff 75 e4             	pushl  -0x1c(%ebp)
 149:	50                   	push   %eax
 14a:	68 2b 0a 00 00       	push   $0xa2b
 14f:	6a 02                	push   $0x2
 151:	e8 e9 04 00 00       	call   63f <printf>
 156:	83 c4 20             	add    $0x20,%esp
  exit();
 159:	e8 2a 03 00 00       	call   488 <exit>

0000015e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 15e:	55                   	push   %ebp
 15f:	89 e5                	mov    %esp,%ebp
 161:	57                   	push   %edi
 162:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 163:	8b 4d 08             	mov    0x8(%ebp),%ecx
 166:	8b 55 10             	mov    0x10(%ebp),%edx
 169:	8b 45 0c             	mov    0xc(%ebp),%eax
 16c:	89 cb                	mov    %ecx,%ebx
 16e:	89 df                	mov    %ebx,%edi
 170:	89 d1                	mov    %edx,%ecx
 172:	fc                   	cld    
 173:	f3 aa                	rep stos %al,%es:(%edi)
 175:	89 ca                	mov    %ecx,%edx
 177:	89 fb                	mov    %edi,%ebx
 179:	89 5d 08             	mov    %ebx,0x8(%ebp)
 17c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 17f:	90                   	nop
 180:	5b                   	pop    %ebx
 181:	5f                   	pop    %edi
 182:	5d                   	pop    %ebp
 183:	c3                   	ret    

00000184 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 184:	55                   	push   %ebp
 185:	89 e5                	mov    %esp,%ebp
 187:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
 18d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 190:	90                   	nop
 191:	8b 45 08             	mov    0x8(%ebp),%eax
 194:	8d 50 01             	lea    0x1(%eax),%edx
 197:	89 55 08             	mov    %edx,0x8(%ebp)
 19a:	8b 55 0c             	mov    0xc(%ebp),%edx
 19d:	8d 4a 01             	lea    0x1(%edx),%ecx
 1a0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1a3:	0f b6 12             	movzbl (%edx),%edx
 1a6:	88 10                	mov    %dl,(%eax)
 1a8:	0f b6 00             	movzbl (%eax),%eax
 1ab:	84 c0                	test   %al,%al
 1ad:	75 e2                	jne    191 <strcpy+0xd>
    ;
  return os;
 1af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1b2:	c9                   	leave  
 1b3:	c3                   	ret    

000001b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1b7:	eb 08                	jmp    1c1 <strcmp+0xd>
    p++, q++;
 1b9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1bd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1c1:	8b 45 08             	mov    0x8(%ebp),%eax
 1c4:	0f b6 00             	movzbl (%eax),%eax
 1c7:	84 c0                	test   %al,%al
 1c9:	74 10                	je     1db <strcmp+0x27>
 1cb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ce:	0f b6 10             	movzbl (%eax),%edx
 1d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d4:	0f b6 00             	movzbl (%eax),%eax
 1d7:	38 c2                	cmp    %al,%dl
 1d9:	74 de                	je     1b9 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1db:	8b 45 08             	mov    0x8(%ebp),%eax
 1de:	0f b6 00             	movzbl (%eax),%eax
 1e1:	0f b6 d0             	movzbl %al,%edx
 1e4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e7:	0f b6 00             	movzbl (%eax),%eax
 1ea:	0f b6 c0             	movzbl %al,%eax
 1ed:	29 c2                	sub    %eax,%edx
 1ef:	89 d0                	mov    %edx,%eax
}
 1f1:	5d                   	pop    %ebp
 1f2:	c3                   	ret    

000001f3 <strlen>:

uint
strlen(char *s)
{
 1f3:	55                   	push   %ebp
 1f4:	89 e5                	mov    %esp,%ebp
 1f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 200:	eb 04                	jmp    206 <strlen+0x13>
 202:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 206:	8b 55 fc             	mov    -0x4(%ebp),%edx
 209:	8b 45 08             	mov    0x8(%ebp),%eax
 20c:	01 d0                	add    %edx,%eax
 20e:	0f b6 00             	movzbl (%eax),%eax
 211:	84 c0                	test   %al,%al
 213:	75 ed                	jne    202 <strlen+0xf>
    ;
  return n;
 215:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 218:	c9                   	leave  
 219:	c3                   	ret    

0000021a <memset>:

void*
memset(void *dst, int c, uint n)
{
 21a:	55                   	push   %ebp
 21b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 21d:	8b 45 10             	mov    0x10(%ebp),%eax
 220:	50                   	push   %eax
 221:	ff 75 0c             	pushl  0xc(%ebp)
 224:	ff 75 08             	pushl  0x8(%ebp)
 227:	e8 32 ff ff ff       	call   15e <stosb>
 22c:	83 c4 0c             	add    $0xc,%esp
  return dst;
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 232:	c9                   	leave  
 233:	c3                   	ret    

00000234 <strchr>:

char*
strchr(const char *s, char c)
{
 234:	55                   	push   %ebp
 235:	89 e5                	mov    %esp,%ebp
 237:	83 ec 04             	sub    $0x4,%esp
 23a:	8b 45 0c             	mov    0xc(%ebp),%eax
 23d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 240:	eb 14                	jmp    256 <strchr+0x22>
    if(*s == c)
 242:	8b 45 08             	mov    0x8(%ebp),%eax
 245:	0f b6 00             	movzbl (%eax),%eax
 248:	3a 45 fc             	cmp    -0x4(%ebp),%al
 24b:	75 05                	jne    252 <strchr+0x1e>
      return (char*)s;
 24d:	8b 45 08             	mov    0x8(%ebp),%eax
 250:	eb 13                	jmp    265 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 252:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 256:	8b 45 08             	mov    0x8(%ebp),%eax
 259:	0f b6 00             	movzbl (%eax),%eax
 25c:	84 c0                	test   %al,%al
 25e:	75 e2                	jne    242 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 260:	b8 00 00 00 00       	mov    $0x0,%eax
}
 265:	c9                   	leave  
 266:	c3                   	ret    

00000267 <gets>:

char*
gets(char *buf, int max)
{
 267:	55                   	push   %ebp
 268:	89 e5                	mov    %esp,%ebp
 26a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 274:	eb 42                	jmp    2b8 <gets+0x51>
    cc = read(0, &c, 1);
 276:	83 ec 04             	sub    $0x4,%esp
 279:	6a 01                	push   $0x1
 27b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 27e:	50                   	push   %eax
 27f:	6a 00                	push   $0x0
 281:	e8 1a 02 00 00       	call   4a0 <read>
 286:	83 c4 10             	add    $0x10,%esp
 289:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 28c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 290:	7e 33                	jle    2c5 <gets+0x5e>
      break;
    buf[i++] = c;
 292:	8b 45 f4             	mov    -0xc(%ebp),%eax
 295:	8d 50 01             	lea    0x1(%eax),%edx
 298:	89 55 f4             	mov    %edx,-0xc(%ebp)
 29b:	89 c2                	mov    %eax,%edx
 29d:	8b 45 08             	mov    0x8(%ebp),%eax
 2a0:	01 c2                	add    %eax,%edx
 2a2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2a8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2ac:	3c 0a                	cmp    $0xa,%al
 2ae:	74 16                	je     2c6 <gets+0x5f>
 2b0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2b4:	3c 0d                	cmp    $0xd,%al
 2b6:	74 0e                	je     2c6 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2bb:	83 c0 01             	add    $0x1,%eax
 2be:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2c1:	7c b3                	jl     276 <gets+0xf>
 2c3:	eb 01                	jmp    2c6 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 2c5:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2c9:	8b 45 08             	mov    0x8(%ebp),%eax
 2cc:	01 d0                	add    %edx,%eax
 2ce:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2d1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d4:	c9                   	leave  
 2d5:	c3                   	ret    

000002d6 <stat>:

int
stat(char *n, struct stat *st)
{
 2d6:	55                   	push   %ebp
 2d7:	89 e5                	mov    %esp,%ebp
 2d9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2dc:	83 ec 08             	sub    $0x8,%esp
 2df:	6a 00                	push   $0x0
 2e1:	ff 75 08             	pushl  0x8(%ebp)
 2e4:	e8 df 01 00 00       	call   4c8 <open>
 2e9:	83 c4 10             	add    $0x10,%esp
 2ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2f3:	79 07                	jns    2fc <stat+0x26>
    return -1;
 2f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2fa:	eb 25                	jmp    321 <stat+0x4b>
  r = fstat(fd, st);
 2fc:	83 ec 08             	sub    $0x8,%esp
 2ff:	ff 75 0c             	pushl  0xc(%ebp)
 302:	ff 75 f4             	pushl  -0xc(%ebp)
 305:	e8 d6 01 00 00       	call   4e0 <fstat>
 30a:	83 c4 10             	add    $0x10,%esp
 30d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 310:	83 ec 0c             	sub    $0xc,%esp
 313:	ff 75 f4             	pushl  -0xc(%ebp)
 316:	e8 95 01 00 00       	call   4b0 <close>
 31b:	83 c4 10             	add    $0x10,%esp
  return r;
 31e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 321:	c9                   	leave  
 322:	c3                   	ret    

00000323 <atoi>:

int
atoi(const char *s)
{
 323:	55                   	push   %ebp
 324:	89 e5                	mov    %esp,%ebp
 326:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 329:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 330:	eb 04                	jmp    336 <atoi+0x13>
 332:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 336:	8b 45 08             	mov    0x8(%ebp),%eax
 339:	0f b6 00             	movzbl (%eax),%eax
 33c:	3c 20                	cmp    $0x20,%al
 33e:	74 f2                	je     332 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 340:	8b 45 08             	mov    0x8(%ebp),%eax
 343:	0f b6 00             	movzbl (%eax),%eax
 346:	3c 2d                	cmp    $0x2d,%al
 348:	75 07                	jne    351 <atoi+0x2e>
 34a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 34f:	eb 05                	jmp    356 <atoi+0x33>
 351:	b8 01 00 00 00       	mov    $0x1,%eax
 356:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 359:	8b 45 08             	mov    0x8(%ebp),%eax
 35c:	0f b6 00             	movzbl (%eax),%eax
 35f:	3c 2b                	cmp    $0x2b,%al
 361:	74 0a                	je     36d <atoi+0x4a>
 363:	8b 45 08             	mov    0x8(%ebp),%eax
 366:	0f b6 00             	movzbl (%eax),%eax
 369:	3c 2d                	cmp    $0x2d,%al
 36b:	75 2b                	jne    398 <atoi+0x75>
    s++;
 36d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 371:	eb 25                	jmp    398 <atoi+0x75>
    n = n*10 + *s++ - '0';
 373:	8b 55 fc             	mov    -0x4(%ebp),%edx
 376:	89 d0                	mov    %edx,%eax
 378:	c1 e0 02             	shl    $0x2,%eax
 37b:	01 d0                	add    %edx,%eax
 37d:	01 c0                	add    %eax,%eax
 37f:	89 c1                	mov    %eax,%ecx
 381:	8b 45 08             	mov    0x8(%ebp),%eax
 384:	8d 50 01             	lea    0x1(%eax),%edx
 387:	89 55 08             	mov    %edx,0x8(%ebp)
 38a:	0f b6 00             	movzbl (%eax),%eax
 38d:	0f be c0             	movsbl %al,%eax
 390:	01 c8                	add    %ecx,%eax
 392:	83 e8 30             	sub    $0x30,%eax
 395:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 398:	8b 45 08             	mov    0x8(%ebp),%eax
 39b:	0f b6 00             	movzbl (%eax),%eax
 39e:	3c 2f                	cmp    $0x2f,%al
 3a0:	7e 0a                	jle    3ac <atoi+0x89>
 3a2:	8b 45 08             	mov    0x8(%ebp),%eax
 3a5:	0f b6 00             	movzbl (%eax),%eax
 3a8:	3c 39                	cmp    $0x39,%al
 3aa:	7e c7                	jle    373 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 3ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3af:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 3b3:	c9                   	leave  
 3b4:	c3                   	ret    

000003b5 <atoo>:

int
atoo(const char *s)
{
 3b5:	55                   	push   %ebp
 3b6:	89 e5                	mov    %esp,%ebp
 3b8:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 3bb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 3c2:	eb 04                	jmp    3c8 <atoo+0x13>
 3c4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3c8:	8b 45 08             	mov    0x8(%ebp),%eax
 3cb:	0f b6 00             	movzbl (%eax),%eax
 3ce:	3c 20                	cmp    $0x20,%al
 3d0:	74 f2                	je     3c4 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 3d2:	8b 45 08             	mov    0x8(%ebp),%eax
 3d5:	0f b6 00             	movzbl (%eax),%eax
 3d8:	3c 2d                	cmp    $0x2d,%al
 3da:	75 07                	jne    3e3 <atoo+0x2e>
 3dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3e1:	eb 05                	jmp    3e8 <atoo+0x33>
 3e3:	b8 01 00 00 00       	mov    $0x1,%eax
 3e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	0f b6 00             	movzbl (%eax),%eax
 3f1:	3c 2b                	cmp    $0x2b,%al
 3f3:	74 0a                	je     3ff <atoo+0x4a>
 3f5:	8b 45 08             	mov    0x8(%ebp),%eax
 3f8:	0f b6 00             	movzbl (%eax),%eax
 3fb:	3c 2d                	cmp    $0x2d,%al
 3fd:	75 27                	jne    426 <atoo+0x71>
    s++;
 3ff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 403:	eb 21                	jmp    426 <atoo+0x71>
    n = n*8 + *s++ - '0';
 405:	8b 45 fc             	mov    -0x4(%ebp),%eax
 408:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 40f:	8b 45 08             	mov    0x8(%ebp),%eax
 412:	8d 50 01             	lea    0x1(%eax),%edx
 415:	89 55 08             	mov    %edx,0x8(%ebp)
 418:	0f b6 00             	movzbl (%eax),%eax
 41b:	0f be c0             	movsbl %al,%eax
 41e:	01 c8                	add    %ecx,%eax
 420:	83 e8 30             	sub    $0x30,%eax
 423:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 426:	8b 45 08             	mov    0x8(%ebp),%eax
 429:	0f b6 00             	movzbl (%eax),%eax
 42c:	3c 2f                	cmp    $0x2f,%al
 42e:	7e 0a                	jle    43a <atoo+0x85>
 430:	8b 45 08             	mov    0x8(%ebp),%eax
 433:	0f b6 00             	movzbl (%eax),%eax
 436:	3c 37                	cmp    $0x37,%al
 438:	7e cb                	jle    405 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 43a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 43d:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 441:	c9                   	leave  
 442:	c3                   	ret    

00000443 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 443:	55                   	push   %ebp
 444:	89 e5                	mov    %esp,%ebp
 446:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 449:	8b 45 08             	mov    0x8(%ebp),%eax
 44c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 44f:	8b 45 0c             	mov    0xc(%ebp),%eax
 452:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 455:	eb 17                	jmp    46e <memmove+0x2b>
    *dst++ = *src++;
 457:	8b 45 fc             	mov    -0x4(%ebp),%eax
 45a:	8d 50 01             	lea    0x1(%eax),%edx
 45d:	89 55 fc             	mov    %edx,-0x4(%ebp)
 460:	8b 55 f8             	mov    -0x8(%ebp),%edx
 463:	8d 4a 01             	lea    0x1(%edx),%ecx
 466:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 469:	0f b6 12             	movzbl (%edx),%edx
 46c:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 46e:	8b 45 10             	mov    0x10(%ebp),%eax
 471:	8d 50 ff             	lea    -0x1(%eax),%edx
 474:	89 55 10             	mov    %edx,0x10(%ebp)
 477:	85 c0                	test   %eax,%eax
 479:	7f dc                	jg     457 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 47b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 47e:	c9                   	leave  
 47f:	c3                   	ret    

00000480 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 480:	b8 01 00 00 00       	mov    $0x1,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <exit>:
SYSCALL(exit)
 488:	b8 02 00 00 00       	mov    $0x2,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <wait>:
SYSCALL(wait)
 490:	b8 03 00 00 00       	mov    $0x3,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <pipe>:
SYSCALL(pipe)
 498:	b8 04 00 00 00       	mov    $0x4,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <read>:
SYSCALL(read)
 4a0:	b8 05 00 00 00       	mov    $0x5,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <write>:
SYSCALL(write)
 4a8:	b8 10 00 00 00       	mov    $0x10,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <close>:
SYSCALL(close)
 4b0:	b8 15 00 00 00       	mov    $0x15,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <kill>:
SYSCALL(kill)
 4b8:	b8 06 00 00 00       	mov    $0x6,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <exec>:
SYSCALL(exec)
 4c0:	b8 07 00 00 00       	mov    $0x7,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <open>:
SYSCALL(open)
 4c8:	b8 0f 00 00 00       	mov    $0xf,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <mknod>:
SYSCALL(mknod)
 4d0:	b8 11 00 00 00       	mov    $0x11,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <unlink>:
SYSCALL(unlink)
 4d8:	b8 12 00 00 00       	mov    $0x12,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <fstat>:
SYSCALL(fstat)
 4e0:	b8 08 00 00 00       	mov    $0x8,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <link>:
SYSCALL(link)
 4e8:	b8 13 00 00 00       	mov    $0x13,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <mkdir>:
SYSCALL(mkdir)
 4f0:	b8 14 00 00 00       	mov    $0x14,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <chdir>:
SYSCALL(chdir)
 4f8:	b8 09 00 00 00       	mov    $0x9,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <dup>:
SYSCALL(dup)
 500:	b8 0a 00 00 00       	mov    $0xa,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <getpid>:
SYSCALL(getpid)
 508:	b8 0b 00 00 00       	mov    $0xb,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <sbrk>:
SYSCALL(sbrk)
 510:	b8 0c 00 00 00       	mov    $0xc,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <sleep>:
SYSCALL(sleep)
 518:	b8 0d 00 00 00       	mov    $0xd,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <uptime>:
SYSCALL(uptime)
 520:	b8 0e 00 00 00       	mov    $0xe,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <halt>:
SYSCALL(halt)
 528:	b8 16 00 00 00       	mov    $0x16,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <date>:
SYSCALL(date)
 530:	b8 17 00 00 00       	mov    $0x17,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <getuid>:
SYSCALL(getuid)
 538:	b8 18 00 00 00       	mov    $0x18,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <getgid>:
SYSCALL(getgid)
 540:	b8 19 00 00 00       	mov    $0x19,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <getppid>:
SYSCALL(getppid)
 548:	b8 1a 00 00 00       	mov    $0x1a,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <setuid>:
SYSCALL(setuid)
 550:	b8 1b 00 00 00       	mov    $0x1b,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <setgid>:
SYSCALL(setgid)
 558:	b8 1c 00 00 00       	mov    $0x1c,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <getprocs>:
SYSCALL(getprocs)
 560:	b8 1d 00 00 00       	mov    $0x1d,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 568:	55                   	push   %ebp
 569:	89 e5                	mov    %esp,%ebp
 56b:	83 ec 18             	sub    $0x18,%esp
 56e:	8b 45 0c             	mov    0xc(%ebp),%eax
 571:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 574:	83 ec 04             	sub    $0x4,%esp
 577:	6a 01                	push   $0x1
 579:	8d 45 f4             	lea    -0xc(%ebp),%eax
 57c:	50                   	push   %eax
 57d:	ff 75 08             	pushl  0x8(%ebp)
 580:	e8 23 ff ff ff       	call   4a8 <write>
 585:	83 c4 10             	add    $0x10,%esp
}
 588:	90                   	nop
 589:	c9                   	leave  
 58a:	c3                   	ret    

0000058b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 58b:	55                   	push   %ebp
 58c:	89 e5                	mov    %esp,%ebp
 58e:	53                   	push   %ebx
 58f:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 592:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 599:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 59d:	74 17                	je     5b6 <printint+0x2b>
 59f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5a3:	79 11                	jns    5b6 <printint+0x2b>
    neg = 1;
 5a5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 5af:	f7 d8                	neg    %eax
 5b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5b4:	eb 06                	jmp    5bc <printint+0x31>
  } else {
    x = xx;
 5b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5c3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5c6:	8d 41 01             	lea    0x1(%ecx),%eax
 5c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5d2:	ba 00 00 00 00       	mov    $0x0,%edx
 5d7:	f7 f3                	div    %ebx
 5d9:	89 d0                	mov    %edx,%eax
 5db:	0f b6 80 b4 0c 00 00 	movzbl 0xcb4(%eax),%eax
 5e2:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ec:	ba 00 00 00 00       	mov    $0x0,%edx
 5f1:	f7 f3                	div    %ebx
 5f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5fa:	75 c7                	jne    5c3 <printint+0x38>
  if(neg)
 5fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 600:	74 2d                	je     62f <printint+0xa4>
    buf[i++] = '-';
 602:	8b 45 f4             	mov    -0xc(%ebp),%eax
 605:	8d 50 01             	lea    0x1(%eax),%edx
 608:	89 55 f4             	mov    %edx,-0xc(%ebp)
 60b:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 610:	eb 1d                	jmp    62f <printint+0xa4>
    putc(fd, buf[i]);
 612:	8d 55 dc             	lea    -0x24(%ebp),%edx
 615:	8b 45 f4             	mov    -0xc(%ebp),%eax
 618:	01 d0                	add    %edx,%eax
 61a:	0f b6 00             	movzbl (%eax),%eax
 61d:	0f be c0             	movsbl %al,%eax
 620:	83 ec 08             	sub    $0x8,%esp
 623:	50                   	push   %eax
 624:	ff 75 08             	pushl  0x8(%ebp)
 627:	e8 3c ff ff ff       	call   568 <putc>
 62c:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 62f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 633:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 637:	79 d9                	jns    612 <printint+0x87>
    putc(fd, buf[i]);
}
 639:	90                   	nop
 63a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 63d:	c9                   	leave  
 63e:	c3                   	ret    

0000063f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 63f:	55                   	push   %ebp
 640:	89 e5                	mov    %esp,%ebp
 642:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 645:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 64c:	8d 45 0c             	lea    0xc(%ebp),%eax
 64f:	83 c0 04             	add    $0x4,%eax
 652:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 655:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 65c:	e9 59 01 00 00       	jmp    7ba <printf+0x17b>
    c = fmt[i] & 0xff;
 661:	8b 55 0c             	mov    0xc(%ebp),%edx
 664:	8b 45 f0             	mov    -0x10(%ebp),%eax
 667:	01 d0                	add    %edx,%eax
 669:	0f b6 00             	movzbl (%eax),%eax
 66c:	0f be c0             	movsbl %al,%eax
 66f:	25 ff 00 00 00       	and    $0xff,%eax
 674:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 677:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 67b:	75 2c                	jne    6a9 <printf+0x6a>
      if(c == '%'){
 67d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 681:	75 0c                	jne    68f <printf+0x50>
        state = '%';
 683:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 68a:	e9 27 01 00 00       	jmp    7b6 <printf+0x177>
      } else {
        putc(fd, c);
 68f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 692:	0f be c0             	movsbl %al,%eax
 695:	83 ec 08             	sub    $0x8,%esp
 698:	50                   	push   %eax
 699:	ff 75 08             	pushl  0x8(%ebp)
 69c:	e8 c7 fe ff ff       	call   568 <putc>
 6a1:	83 c4 10             	add    $0x10,%esp
 6a4:	e9 0d 01 00 00       	jmp    7b6 <printf+0x177>
      }
    } else if(state == '%'){
 6a9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6ad:	0f 85 03 01 00 00    	jne    7b6 <printf+0x177>
      if(c == 'd'){
 6b3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6b7:	75 1e                	jne    6d7 <printf+0x98>
        printint(fd, *ap, 10, 1);
 6b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6bc:	8b 00                	mov    (%eax),%eax
 6be:	6a 01                	push   $0x1
 6c0:	6a 0a                	push   $0xa
 6c2:	50                   	push   %eax
 6c3:	ff 75 08             	pushl  0x8(%ebp)
 6c6:	e8 c0 fe ff ff       	call   58b <printint>
 6cb:	83 c4 10             	add    $0x10,%esp
        ap++;
 6ce:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d2:	e9 d8 00 00 00       	jmp    7af <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6d7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6db:	74 06                	je     6e3 <printf+0xa4>
 6dd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6e1:	75 1e                	jne    701 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e6:	8b 00                	mov    (%eax),%eax
 6e8:	6a 00                	push   $0x0
 6ea:	6a 10                	push   $0x10
 6ec:	50                   	push   %eax
 6ed:	ff 75 08             	pushl  0x8(%ebp)
 6f0:	e8 96 fe ff ff       	call   58b <printint>
 6f5:	83 c4 10             	add    $0x10,%esp
        ap++;
 6f8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6fc:	e9 ae 00 00 00       	jmp    7af <printf+0x170>
      } else if(c == 's'){
 701:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 705:	75 43                	jne    74a <printf+0x10b>
        s = (char*)*ap;
 707:	8b 45 e8             	mov    -0x18(%ebp),%eax
 70a:	8b 00                	mov    (%eax),%eax
 70c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 70f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 713:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 717:	75 25                	jne    73e <printf+0xff>
          s = "(null)";
 719:	c7 45 f4 3e 0a 00 00 	movl   $0xa3e,-0xc(%ebp)
        while(*s != 0){
 720:	eb 1c                	jmp    73e <printf+0xff>
          putc(fd, *s);
 722:	8b 45 f4             	mov    -0xc(%ebp),%eax
 725:	0f b6 00             	movzbl (%eax),%eax
 728:	0f be c0             	movsbl %al,%eax
 72b:	83 ec 08             	sub    $0x8,%esp
 72e:	50                   	push   %eax
 72f:	ff 75 08             	pushl  0x8(%ebp)
 732:	e8 31 fe ff ff       	call   568 <putc>
 737:	83 c4 10             	add    $0x10,%esp
          s++;
 73a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 73e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 741:	0f b6 00             	movzbl (%eax),%eax
 744:	84 c0                	test   %al,%al
 746:	75 da                	jne    722 <printf+0xe3>
 748:	eb 65                	jmp    7af <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 74a:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 74e:	75 1d                	jne    76d <printf+0x12e>
        putc(fd, *ap);
 750:	8b 45 e8             	mov    -0x18(%ebp),%eax
 753:	8b 00                	mov    (%eax),%eax
 755:	0f be c0             	movsbl %al,%eax
 758:	83 ec 08             	sub    $0x8,%esp
 75b:	50                   	push   %eax
 75c:	ff 75 08             	pushl  0x8(%ebp)
 75f:	e8 04 fe ff ff       	call   568 <putc>
 764:	83 c4 10             	add    $0x10,%esp
        ap++;
 767:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 76b:	eb 42                	jmp    7af <printf+0x170>
      } else if(c == '%'){
 76d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 771:	75 17                	jne    78a <printf+0x14b>
        putc(fd, c);
 773:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 776:	0f be c0             	movsbl %al,%eax
 779:	83 ec 08             	sub    $0x8,%esp
 77c:	50                   	push   %eax
 77d:	ff 75 08             	pushl  0x8(%ebp)
 780:	e8 e3 fd ff ff       	call   568 <putc>
 785:	83 c4 10             	add    $0x10,%esp
 788:	eb 25                	jmp    7af <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 78a:	83 ec 08             	sub    $0x8,%esp
 78d:	6a 25                	push   $0x25
 78f:	ff 75 08             	pushl  0x8(%ebp)
 792:	e8 d1 fd ff ff       	call   568 <putc>
 797:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 79a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 79d:	0f be c0             	movsbl %al,%eax
 7a0:	83 ec 08             	sub    $0x8,%esp
 7a3:	50                   	push   %eax
 7a4:	ff 75 08             	pushl  0x8(%ebp)
 7a7:	e8 bc fd ff ff       	call   568 <putc>
 7ac:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7b6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7ba:	8b 55 0c             	mov    0xc(%ebp),%edx
 7bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c0:	01 d0                	add    %edx,%eax
 7c2:	0f b6 00             	movzbl (%eax),%eax
 7c5:	84 c0                	test   %al,%al
 7c7:	0f 85 94 fe ff ff    	jne    661 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7cd:	90                   	nop
 7ce:	c9                   	leave  
 7cf:	c3                   	ret    

000007d0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d0:	55                   	push   %ebp
 7d1:	89 e5                	mov    %esp,%ebp
 7d3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d6:	8b 45 08             	mov    0x8(%ebp),%eax
 7d9:	83 e8 08             	sub    $0x8,%eax
 7dc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7df:	a1 d0 0c 00 00       	mov    0xcd0,%eax
 7e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7e7:	eb 24                	jmp    80d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ec:	8b 00                	mov    (%eax),%eax
 7ee:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f1:	77 12                	ja     805 <free+0x35>
 7f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f9:	77 24                	ja     81f <free+0x4f>
 7fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fe:	8b 00                	mov    (%eax),%eax
 800:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 803:	77 1a                	ja     81f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 805:	8b 45 fc             	mov    -0x4(%ebp),%eax
 808:	8b 00                	mov    (%eax),%eax
 80a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 80d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 810:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 813:	76 d4                	jbe    7e9 <free+0x19>
 815:	8b 45 fc             	mov    -0x4(%ebp),%eax
 818:	8b 00                	mov    (%eax),%eax
 81a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 81d:	76 ca                	jbe    7e9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 81f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 822:	8b 40 04             	mov    0x4(%eax),%eax
 825:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 82c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82f:	01 c2                	add    %eax,%edx
 831:	8b 45 fc             	mov    -0x4(%ebp),%eax
 834:	8b 00                	mov    (%eax),%eax
 836:	39 c2                	cmp    %eax,%edx
 838:	75 24                	jne    85e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 83a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83d:	8b 50 04             	mov    0x4(%eax),%edx
 840:	8b 45 fc             	mov    -0x4(%ebp),%eax
 843:	8b 00                	mov    (%eax),%eax
 845:	8b 40 04             	mov    0x4(%eax),%eax
 848:	01 c2                	add    %eax,%edx
 84a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	8b 00                	mov    (%eax),%eax
 855:	8b 10                	mov    (%eax),%edx
 857:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85a:	89 10                	mov    %edx,(%eax)
 85c:	eb 0a                	jmp    868 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 85e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 861:	8b 10                	mov    (%eax),%edx
 863:	8b 45 f8             	mov    -0x8(%ebp),%eax
 866:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 868:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86b:	8b 40 04             	mov    0x4(%eax),%eax
 86e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 875:	8b 45 fc             	mov    -0x4(%ebp),%eax
 878:	01 d0                	add    %edx,%eax
 87a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 87d:	75 20                	jne    89f <free+0xcf>
    p->s.size += bp->s.size;
 87f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 882:	8b 50 04             	mov    0x4(%eax),%edx
 885:	8b 45 f8             	mov    -0x8(%ebp),%eax
 888:	8b 40 04             	mov    0x4(%eax),%eax
 88b:	01 c2                	add    %eax,%edx
 88d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 890:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 893:	8b 45 f8             	mov    -0x8(%ebp),%eax
 896:	8b 10                	mov    (%eax),%edx
 898:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89b:	89 10                	mov    %edx,(%eax)
 89d:	eb 08                	jmp    8a7 <free+0xd7>
  } else
    p->s.ptr = bp;
 89f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8a5:	89 10                	mov    %edx,(%eax)
  freep = p;
 8a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8aa:	a3 d0 0c 00 00       	mov    %eax,0xcd0
}
 8af:	90                   	nop
 8b0:	c9                   	leave  
 8b1:	c3                   	ret    

000008b2 <morecore>:

static Header*
morecore(uint nu)
{
 8b2:	55                   	push   %ebp
 8b3:	89 e5                	mov    %esp,%ebp
 8b5:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8b8:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8bf:	77 07                	ja     8c8 <morecore+0x16>
    nu = 4096;
 8c1:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8c8:	8b 45 08             	mov    0x8(%ebp),%eax
 8cb:	c1 e0 03             	shl    $0x3,%eax
 8ce:	83 ec 0c             	sub    $0xc,%esp
 8d1:	50                   	push   %eax
 8d2:	e8 39 fc ff ff       	call   510 <sbrk>
 8d7:	83 c4 10             	add    $0x10,%esp
 8da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8dd:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8e1:	75 07                	jne    8ea <morecore+0x38>
    return 0;
 8e3:	b8 00 00 00 00       	mov    $0x0,%eax
 8e8:	eb 26                	jmp    910 <morecore+0x5e>
  hp = (Header*)p;
 8ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f3:	8b 55 08             	mov    0x8(%ebp),%edx
 8f6:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8fc:	83 c0 08             	add    $0x8,%eax
 8ff:	83 ec 0c             	sub    $0xc,%esp
 902:	50                   	push   %eax
 903:	e8 c8 fe ff ff       	call   7d0 <free>
 908:	83 c4 10             	add    $0x10,%esp
  return freep;
 90b:	a1 d0 0c 00 00       	mov    0xcd0,%eax
}
 910:	c9                   	leave  
 911:	c3                   	ret    

00000912 <malloc>:

void*
malloc(uint nbytes)
{
 912:	55                   	push   %ebp
 913:	89 e5                	mov    %esp,%ebp
 915:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 918:	8b 45 08             	mov    0x8(%ebp),%eax
 91b:	83 c0 07             	add    $0x7,%eax
 91e:	c1 e8 03             	shr    $0x3,%eax
 921:	83 c0 01             	add    $0x1,%eax
 924:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 927:	a1 d0 0c 00 00       	mov    0xcd0,%eax
 92c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 92f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 933:	75 23                	jne    958 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 935:	c7 45 f0 c8 0c 00 00 	movl   $0xcc8,-0x10(%ebp)
 93c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93f:	a3 d0 0c 00 00       	mov    %eax,0xcd0
 944:	a1 d0 0c 00 00       	mov    0xcd0,%eax
 949:	a3 c8 0c 00 00       	mov    %eax,0xcc8
    base.s.size = 0;
 94e:	c7 05 cc 0c 00 00 00 	movl   $0x0,0xccc
 955:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 958:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95b:	8b 00                	mov    (%eax),%eax
 95d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 960:	8b 45 f4             	mov    -0xc(%ebp),%eax
 963:	8b 40 04             	mov    0x4(%eax),%eax
 966:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 969:	72 4d                	jb     9b8 <malloc+0xa6>
      if(p->s.size == nunits)
 96b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96e:	8b 40 04             	mov    0x4(%eax),%eax
 971:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 974:	75 0c                	jne    982 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 976:	8b 45 f4             	mov    -0xc(%ebp),%eax
 979:	8b 10                	mov    (%eax),%edx
 97b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97e:	89 10                	mov    %edx,(%eax)
 980:	eb 26                	jmp    9a8 <malloc+0x96>
      else {
        p->s.size -= nunits;
 982:	8b 45 f4             	mov    -0xc(%ebp),%eax
 985:	8b 40 04             	mov    0x4(%eax),%eax
 988:	2b 45 ec             	sub    -0x14(%ebp),%eax
 98b:	89 c2                	mov    %eax,%edx
 98d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 990:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 993:	8b 45 f4             	mov    -0xc(%ebp),%eax
 996:	8b 40 04             	mov    0x4(%eax),%eax
 999:	c1 e0 03             	shl    $0x3,%eax
 99c:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 99f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a2:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9a5:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ab:	a3 d0 0c 00 00       	mov    %eax,0xcd0
      return (void*)(p + 1);
 9b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b3:	83 c0 08             	add    $0x8,%eax
 9b6:	eb 3b                	jmp    9f3 <malloc+0xe1>
    }
    if(p == freep)
 9b8:	a1 d0 0c 00 00       	mov    0xcd0,%eax
 9bd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9c0:	75 1e                	jne    9e0 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9c2:	83 ec 0c             	sub    $0xc,%esp
 9c5:	ff 75 ec             	pushl  -0x14(%ebp)
 9c8:	e8 e5 fe ff ff       	call   8b2 <morecore>
 9cd:	83 c4 10             	add    $0x10,%esp
 9d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9d7:	75 07                	jne    9e0 <malloc+0xce>
        return 0;
 9d9:	b8 00 00 00 00       	mov    $0x0,%eax
 9de:	eb 13                	jmp    9f3 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e9:	8b 00                	mov    (%eax),%eax
 9eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9ee:	e9 6d ff ff ff       	jmp    960 <malloc+0x4e>
}
 9f3:	c9                   	leave  
 9f4:	c3                   	ret    
