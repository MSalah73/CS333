
_RRS-test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#ifdef CS333_P3P4
#include "types.h"
#include "user.h"

int main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
    int pid, i;
    for(i = 0; i < 20; ++i)
  11:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  18:	eb 14                	jmp    2e <main+0x2e>
    {
      pid = fork();// making babies
  1a:	e8 5a 03 00 00       	call   379 <fork>
  1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(!pid)
  22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  26:	75 02                	jne    2a <main+0x2a>
        for(;;);// Inifnite look to check roundrobin scheduling 
  28:	eb fe                	jmp    28 <main+0x28>
#include "user.h"

int main(void)
{
    int pid, i;
    for(i = 0; i < 20; ++i)
  2a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  2e:	83 7d f0 13          	cmpl   $0x13,-0x10(%ebp)
  32:	7e e6                	jle    1a <main+0x1a>
    {
      pid = fork();// making babies
      if(!pid)
        for(;;);// Inifnite look to check roundrobin scheduling 
    }
    if(pid)
  34:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  38:	74 18                	je     52 <main+0x52>
      for(i = 0; i < 20; ++i)
  3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  41:	eb 09                	jmp    4c <main+0x4c>
        wait();
  43:	e8 41 03 00 00       	call   389 <wait>
      pid = fork();// making babies
      if(!pid)
        for(;;);// Inifnite look to check roundrobin scheduling 
    }
    if(pid)
      for(i = 0; i < 20; ++i)
  48:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  4c:	83 7d f0 13          	cmpl   $0x13,-0x10(%ebp)
  50:	7e f1                	jle    43 <main+0x43>
        wait();
    exit();
  52:	e8 2a 03 00 00       	call   381 <exit>

00000057 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  57:	55                   	push   %ebp
  58:	89 e5                	mov    %esp,%ebp
  5a:	57                   	push   %edi
  5b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  5f:	8b 55 10             	mov    0x10(%ebp),%edx
  62:	8b 45 0c             	mov    0xc(%ebp),%eax
  65:	89 cb                	mov    %ecx,%ebx
  67:	89 df                	mov    %ebx,%edi
  69:	89 d1                	mov    %edx,%ecx
  6b:	fc                   	cld    
  6c:	f3 aa                	rep stos %al,%es:(%edi)
  6e:	89 ca                	mov    %ecx,%edx
  70:	89 fb                	mov    %edi,%ebx
  72:	89 5d 08             	mov    %ebx,0x8(%ebp)
  75:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  78:	90                   	nop
  79:	5b                   	pop    %ebx
  7a:	5f                   	pop    %edi
  7b:	5d                   	pop    %ebp
  7c:	c3                   	ret    

0000007d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  7d:	55                   	push   %ebp
  7e:	89 e5                	mov    %esp,%ebp
  80:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  83:	8b 45 08             	mov    0x8(%ebp),%eax
  86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  89:	90                   	nop
  8a:	8b 45 08             	mov    0x8(%ebp),%eax
  8d:	8d 50 01             	lea    0x1(%eax),%edx
  90:	89 55 08             	mov    %edx,0x8(%ebp)
  93:	8b 55 0c             	mov    0xc(%ebp),%edx
  96:	8d 4a 01             	lea    0x1(%edx),%ecx
  99:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  9c:	0f b6 12             	movzbl (%edx),%edx
  9f:	88 10                	mov    %dl,(%eax)
  a1:	0f b6 00             	movzbl (%eax),%eax
  a4:	84 c0                	test   %al,%al
  a6:	75 e2                	jne    8a <strcpy+0xd>
    ;
  return os;
  a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  ab:	c9                   	leave  
  ac:	c3                   	ret    

000000ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ad:	55                   	push   %ebp
  ae:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  b0:	eb 08                	jmp    ba <strcmp+0xd>
    p++, q++;
  b2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  b6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ba:	8b 45 08             	mov    0x8(%ebp),%eax
  bd:	0f b6 00             	movzbl (%eax),%eax
  c0:	84 c0                	test   %al,%al
  c2:	74 10                	je     d4 <strcmp+0x27>
  c4:	8b 45 08             	mov    0x8(%ebp),%eax
  c7:	0f b6 10             	movzbl (%eax),%edx
  ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  cd:	0f b6 00             	movzbl (%eax),%eax
  d0:	38 c2                	cmp    %al,%dl
  d2:	74 de                	je     b2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	0f b6 00             	movzbl (%eax),%eax
  da:	0f b6 d0             	movzbl %al,%edx
  dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  e0:	0f b6 00             	movzbl (%eax),%eax
  e3:	0f b6 c0             	movzbl %al,%eax
  e6:	29 c2                	sub    %eax,%edx
  e8:	89 d0                	mov    %edx,%eax
}
  ea:	5d                   	pop    %ebp
  eb:	c3                   	ret    

000000ec <strlen>:

uint
strlen(char *s)
{
  ec:	55                   	push   %ebp
  ed:	89 e5                	mov    %esp,%ebp
  ef:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  f9:	eb 04                	jmp    ff <strlen+0x13>
  fb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  ff:	8b 55 fc             	mov    -0x4(%ebp),%edx
 102:	8b 45 08             	mov    0x8(%ebp),%eax
 105:	01 d0                	add    %edx,%eax
 107:	0f b6 00             	movzbl (%eax),%eax
 10a:	84 c0                	test   %al,%al
 10c:	75 ed                	jne    fb <strlen+0xf>
    ;
  return n;
 10e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 111:	c9                   	leave  
 112:	c3                   	ret    

00000113 <memset>:

void*
memset(void *dst, int c, uint n)
{
 113:	55                   	push   %ebp
 114:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 116:	8b 45 10             	mov    0x10(%ebp),%eax
 119:	50                   	push   %eax
 11a:	ff 75 0c             	pushl  0xc(%ebp)
 11d:	ff 75 08             	pushl  0x8(%ebp)
 120:	e8 32 ff ff ff       	call   57 <stosb>
 125:	83 c4 0c             	add    $0xc,%esp
  return dst;
 128:	8b 45 08             	mov    0x8(%ebp),%eax
}
 12b:	c9                   	leave  
 12c:	c3                   	ret    

0000012d <strchr>:

char*
strchr(const char *s, char c)
{
 12d:	55                   	push   %ebp
 12e:	89 e5                	mov    %esp,%ebp
 130:	83 ec 04             	sub    $0x4,%esp
 133:	8b 45 0c             	mov    0xc(%ebp),%eax
 136:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 139:	eb 14                	jmp    14f <strchr+0x22>
    if(*s == c)
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
 13e:	0f b6 00             	movzbl (%eax),%eax
 141:	3a 45 fc             	cmp    -0x4(%ebp),%al
 144:	75 05                	jne    14b <strchr+0x1e>
      return (char*)s;
 146:	8b 45 08             	mov    0x8(%ebp),%eax
 149:	eb 13                	jmp    15e <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 14b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 14f:	8b 45 08             	mov    0x8(%ebp),%eax
 152:	0f b6 00             	movzbl (%eax),%eax
 155:	84 c0                	test   %al,%al
 157:	75 e2                	jne    13b <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 159:	b8 00 00 00 00       	mov    $0x0,%eax
}
 15e:	c9                   	leave  
 15f:	c3                   	ret    

00000160 <gets>:

char*
gets(char *buf, int max)
{
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 166:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 16d:	eb 42                	jmp    1b1 <gets+0x51>
    cc = read(0, &c, 1);
 16f:	83 ec 04             	sub    $0x4,%esp
 172:	6a 01                	push   $0x1
 174:	8d 45 ef             	lea    -0x11(%ebp),%eax
 177:	50                   	push   %eax
 178:	6a 00                	push   $0x0
 17a:	e8 1a 02 00 00       	call   399 <read>
 17f:	83 c4 10             	add    $0x10,%esp
 182:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 185:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 189:	7e 33                	jle    1be <gets+0x5e>
      break;
    buf[i++] = c;
 18b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18e:	8d 50 01             	lea    0x1(%eax),%edx
 191:	89 55 f4             	mov    %edx,-0xc(%ebp)
 194:	89 c2                	mov    %eax,%edx
 196:	8b 45 08             	mov    0x8(%ebp),%eax
 199:	01 c2                	add    %eax,%edx
 19b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 19f:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1a1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1a5:	3c 0a                	cmp    $0xa,%al
 1a7:	74 16                	je     1bf <gets+0x5f>
 1a9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ad:	3c 0d                	cmp    $0xd,%al
 1af:	74 0e                	je     1bf <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b4:	83 c0 01             	add    $0x1,%eax
 1b7:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1ba:	7c b3                	jl     16f <gets+0xf>
 1bc:	eb 01                	jmp    1bf <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1be:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1c2:	8b 45 08             	mov    0x8(%ebp),%eax
 1c5:	01 d0                	add    %edx,%eax
 1c7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1cd:	c9                   	leave  
 1ce:	c3                   	ret    

000001cf <stat>:

int
stat(char *n, struct stat *st)
{
 1cf:	55                   	push   %ebp
 1d0:	89 e5                	mov    %esp,%ebp
 1d2:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d5:	83 ec 08             	sub    $0x8,%esp
 1d8:	6a 00                	push   $0x0
 1da:	ff 75 08             	pushl  0x8(%ebp)
 1dd:	e8 df 01 00 00       	call   3c1 <open>
 1e2:	83 c4 10             	add    $0x10,%esp
 1e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1ec:	79 07                	jns    1f5 <stat+0x26>
    return -1;
 1ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1f3:	eb 25                	jmp    21a <stat+0x4b>
  r = fstat(fd, st);
 1f5:	83 ec 08             	sub    $0x8,%esp
 1f8:	ff 75 0c             	pushl  0xc(%ebp)
 1fb:	ff 75 f4             	pushl  -0xc(%ebp)
 1fe:	e8 d6 01 00 00       	call   3d9 <fstat>
 203:	83 c4 10             	add    $0x10,%esp
 206:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 209:	83 ec 0c             	sub    $0xc,%esp
 20c:	ff 75 f4             	pushl  -0xc(%ebp)
 20f:	e8 95 01 00 00       	call   3a9 <close>
 214:	83 c4 10             	add    $0x10,%esp
  return r;
 217:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 21a:	c9                   	leave  
 21b:	c3                   	ret    

0000021c <atoi>:

int
atoi(const char *s)
{
 21c:	55                   	push   %ebp
 21d:	89 e5                	mov    %esp,%ebp
 21f:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 222:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 229:	eb 04                	jmp    22f <atoi+0x13>
 22b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
 232:	0f b6 00             	movzbl (%eax),%eax
 235:	3c 20                	cmp    $0x20,%al
 237:	74 f2                	je     22b <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 239:	8b 45 08             	mov    0x8(%ebp),%eax
 23c:	0f b6 00             	movzbl (%eax),%eax
 23f:	3c 2d                	cmp    $0x2d,%al
 241:	75 07                	jne    24a <atoi+0x2e>
 243:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 248:	eb 05                	jmp    24f <atoi+0x33>
 24a:	b8 01 00 00 00       	mov    $0x1,%eax
 24f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 252:	8b 45 08             	mov    0x8(%ebp),%eax
 255:	0f b6 00             	movzbl (%eax),%eax
 258:	3c 2b                	cmp    $0x2b,%al
 25a:	74 0a                	je     266 <atoi+0x4a>
 25c:	8b 45 08             	mov    0x8(%ebp),%eax
 25f:	0f b6 00             	movzbl (%eax),%eax
 262:	3c 2d                	cmp    $0x2d,%al
 264:	75 2b                	jne    291 <atoi+0x75>
    s++;
 266:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 26a:	eb 25                	jmp    291 <atoi+0x75>
    n = n*10 + *s++ - '0';
 26c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 26f:	89 d0                	mov    %edx,%eax
 271:	c1 e0 02             	shl    $0x2,%eax
 274:	01 d0                	add    %edx,%eax
 276:	01 c0                	add    %eax,%eax
 278:	89 c1                	mov    %eax,%ecx
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
 27d:	8d 50 01             	lea    0x1(%eax),%edx
 280:	89 55 08             	mov    %edx,0x8(%ebp)
 283:	0f b6 00             	movzbl (%eax),%eax
 286:	0f be c0             	movsbl %al,%eax
 289:	01 c8                	add    %ecx,%eax
 28b:	83 e8 30             	sub    $0x30,%eax
 28e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	0f b6 00             	movzbl (%eax),%eax
 297:	3c 2f                	cmp    $0x2f,%al
 299:	7e 0a                	jle    2a5 <atoi+0x89>
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	0f b6 00             	movzbl (%eax),%eax
 2a1:	3c 39                	cmp    $0x39,%al
 2a3:	7e c7                	jle    26c <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 2a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2a8:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 2ac:	c9                   	leave  
 2ad:	c3                   	ret    

000002ae <atoo>:

int
atoo(const char *s)
{
 2ae:	55                   	push   %ebp
 2af:	89 e5                	mov    %esp,%ebp
 2b1:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 2b4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 2bb:	eb 04                	jmp    2c1 <atoo+0x13>
 2bd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2c1:	8b 45 08             	mov    0x8(%ebp),%eax
 2c4:	0f b6 00             	movzbl (%eax),%eax
 2c7:	3c 20                	cmp    $0x20,%al
 2c9:	74 f2                	je     2bd <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 2cb:	8b 45 08             	mov    0x8(%ebp),%eax
 2ce:	0f b6 00             	movzbl (%eax),%eax
 2d1:	3c 2d                	cmp    $0x2d,%al
 2d3:	75 07                	jne    2dc <atoo+0x2e>
 2d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2da:	eb 05                	jmp    2e1 <atoo+0x33>
 2dc:	b8 01 00 00 00       	mov    $0x1,%eax
 2e1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	0f b6 00             	movzbl (%eax),%eax
 2ea:	3c 2b                	cmp    $0x2b,%al
 2ec:	74 0a                	je     2f8 <atoo+0x4a>
 2ee:	8b 45 08             	mov    0x8(%ebp),%eax
 2f1:	0f b6 00             	movzbl (%eax),%eax
 2f4:	3c 2d                	cmp    $0x2d,%al
 2f6:	75 27                	jne    31f <atoo+0x71>
    s++;
 2f8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 2fc:	eb 21                	jmp    31f <atoo+0x71>
    n = n*8 + *s++ - '0';
 2fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 301:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 308:	8b 45 08             	mov    0x8(%ebp),%eax
 30b:	8d 50 01             	lea    0x1(%eax),%edx
 30e:	89 55 08             	mov    %edx,0x8(%ebp)
 311:	0f b6 00             	movzbl (%eax),%eax
 314:	0f be c0             	movsbl %al,%eax
 317:	01 c8                	add    %ecx,%eax
 319:	83 e8 30             	sub    $0x30,%eax
 31c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	0f b6 00             	movzbl (%eax),%eax
 325:	3c 2f                	cmp    $0x2f,%al
 327:	7e 0a                	jle    333 <atoo+0x85>
 329:	8b 45 08             	mov    0x8(%ebp),%eax
 32c:	0f b6 00             	movzbl (%eax),%eax
 32f:	3c 37                	cmp    $0x37,%al
 331:	7e cb                	jle    2fe <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 333:	8b 45 f8             	mov    -0x8(%ebp),%eax
 336:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 33a:	c9                   	leave  
 33b:	c3                   	ret    

0000033c <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 33c:	55                   	push   %ebp
 33d:	89 e5                	mov    %esp,%ebp
 33f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 342:	8b 45 08             	mov    0x8(%ebp),%eax
 345:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 348:	8b 45 0c             	mov    0xc(%ebp),%eax
 34b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 34e:	eb 17                	jmp    367 <memmove+0x2b>
    *dst++ = *src++;
 350:	8b 45 fc             	mov    -0x4(%ebp),%eax
 353:	8d 50 01             	lea    0x1(%eax),%edx
 356:	89 55 fc             	mov    %edx,-0x4(%ebp)
 359:	8b 55 f8             	mov    -0x8(%ebp),%edx
 35c:	8d 4a 01             	lea    0x1(%edx),%ecx
 35f:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 362:	0f b6 12             	movzbl (%edx),%edx
 365:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 367:	8b 45 10             	mov    0x10(%ebp),%eax
 36a:	8d 50 ff             	lea    -0x1(%eax),%edx
 36d:	89 55 10             	mov    %edx,0x10(%ebp)
 370:	85 c0                	test   %eax,%eax
 372:	7f dc                	jg     350 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 374:	8b 45 08             	mov    0x8(%ebp),%eax
}
 377:	c9                   	leave  
 378:	c3                   	ret    

00000379 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 379:	b8 01 00 00 00       	mov    $0x1,%eax
 37e:	cd 40                	int    $0x40
 380:	c3                   	ret    

00000381 <exit>:
SYSCALL(exit)
 381:	b8 02 00 00 00       	mov    $0x2,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret    

00000389 <wait>:
SYSCALL(wait)
 389:	b8 03 00 00 00       	mov    $0x3,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret    

00000391 <pipe>:
SYSCALL(pipe)
 391:	b8 04 00 00 00       	mov    $0x4,%eax
 396:	cd 40                	int    $0x40
 398:	c3                   	ret    

00000399 <read>:
SYSCALL(read)
 399:	b8 05 00 00 00       	mov    $0x5,%eax
 39e:	cd 40                	int    $0x40
 3a0:	c3                   	ret    

000003a1 <write>:
SYSCALL(write)
 3a1:	b8 10 00 00 00       	mov    $0x10,%eax
 3a6:	cd 40                	int    $0x40
 3a8:	c3                   	ret    

000003a9 <close>:
SYSCALL(close)
 3a9:	b8 15 00 00 00       	mov    $0x15,%eax
 3ae:	cd 40                	int    $0x40
 3b0:	c3                   	ret    

000003b1 <kill>:
SYSCALL(kill)
 3b1:	b8 06 00 00 00       	mov    $0x6,%eax
 3b6:	cd 40                	int    $0x40
 3b8:	c3                   	ret    

000003b9 <exec>:
SYSCALL(exec)
 3b9:	b8 07 00 00 00       	mov    $0x7,%eax
 3be:	cd 40                	int    $0x40
 3c0:	c3                   	ret    

000003c1 <open>:
SYSCALL(open)
 3c1:	b8 0f 00 00 00       	mov    $0xf,%eax
 3c6:	cd 40                	int    $0x40
 3c8:	c3                   	ret    

000003c9 <mknod>:
SYSCALL(mknod)
 3c9:	b8 11 00 00 00       	mov    $0x11,%eax
 3ce:	cd 40                	int    $0x40
 3d0:	c3                   	ret    

000003d1 <unlink>:
SYSCALL(unlink)
 3d1:	b8 12 00 00 00       	mov    $0x12,%eax
 3d6:	cd 40                	int    $0x40
 3d8:	c3                   	ret    

000003d9 <fstat>:
SYSCALL(fstat)
 3d9:	b8 08 00 00 00       	mov    $0x8,%eax
 3de:	cd 40                	int    $0x40
 3e0:	c3                   	ret    

000003e1 <link>:
SYSCALL(link)
 3e1:	b8 13 00 00 00       	mov    $0x13,%eax
 3e6:	cd 40                	int    $0x40
 3e8:	c3                   	ret    

000003e9 <mkdir>:
SYSCALL(mkdir)
 3e9:	b8 14 00 00 00       	mov    $0x14,%eax
 3ee:	cd 40                	int    $0x40
 3f0:	c3                   	ret    

000003f1 <chdir>:
SYSCALL(chdir)
 3f1:	b8 09 00 00 00       	mov    $0x9,%eax
 3f6:	cd 40                	int    $0x40
 3f8:	c3                   	ret    

000003f9 <dup>:
SYSCALL(dup)
 3f9:	b8 0a 00 00 00       	mov    $0xa,%eax
 3fe:	cd 40                	int    $0x40
 400:	c3                   	ret    

00000401 <getpid>:
SYSCALL(getpid)
 401:	b8 0b 00 00 00       	mov    $0xb,%eax
 406:	cd 40                	int    $0x40
 408:	c3                   	ret    

00000409 <sbrk>:
SYSCALL(sbrk)
 409:	b8 0c 00 00 00       	mov    $0xc,%eax
 40e:	cd 40                	int    $0x40
 410:	c3                   	ret    

00000411 <sleep>:
SYSCALL(sleep)
 411:	b8 0d 00 00 00       	mov    $0xd,%eax
 416:	cd 40                	int    $0x40
 418:	c3                   	ret    

00000419 <uptime>:
SYSCALL(uptime)
 419:	b8 0e 00 00 00       	mov    $0xe,%eax
 41e:	cd 40                	int    $0x40
 420:	c3                   	ret    

00000421 <halt>:
SYSCALL(halt)
 421:	b8 16 00 00 00       	mov    $0x16,%eax
 426:	cd 40                	int    $0x40
 428:	c3                   	ret    

00000429 <date>:
SYSCALL(date)
 429:	b8 17 00 00 00       	mov    $0x17,%eax
 42e:	cd 40                	int    $0x40
 430:	c3                   	ret    

00000431 <getuid>:
SYSCALL(getuid)
 431:	b8 18 00 00 00       	mov    $0x18,%eax
 436:	cd 40                	int    $0x40
 438:	c3                   	ret    

00000439 <getgid>:
SYSCALL(getgid)
 439:	b8 19 00 00 00       	mov    $0x19,%eax
 43e:	cd 40                	int    $0x40
 440:	c3                   	ret    

00000441 <getppid>:
SYSCALL(getppid)
 441:	b8 1a 00 00 00       	mov    $0x1a,%eax
 446:	cd 40                	int    $0x40
 448:	c3                   	ret    

00000449 <setuid>:
SYSCALL(setuid)
 449:	b8 1b 00 00 00       	mov    $0x1b,%eax
 44e:	cd 40                	int    $0x40
 450:	c3                   	ret    

00000451 <setgid>:
SYSCALL(setgid)
 451:	b8 1c 00 00 00       	mov    $0x1c,%eax
 456:	cd 40                	int    $0x40
 458:	c3                   	ret    

00000459 <getprocs>:
SYSCALL(getprocs)
 459:	b8 1d 00 00 00       	mov    $0x1d,%eax
 45e:	cd 40                	int    $0x40
 460:	c3                   	ret    

00000461 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 461:	55                   	push   %ebp
 462:	89 e5                	mov    %esp,%ebp
 464:	83 ec 18             	sub    $0x18,%esp
 467:	8b 45 0c             	mov    0xc(%ebp),%eax
 46a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 46d:	83 ec 04             	sub    $0x4,%esp
 470:	6a 01                	push   $0x1
 472:	8d 45 f4             	lea    -0xc(%ebp),%eax
 475:	50                   	push   %eax
 476:	ff 75 08             	pushl  0x8(%ebp)
 479:	e8 23 ff ff ff       	call   3a1 <write>
 47e:	83 c4 10             	add    $0x10,%esp
}
 481:	90                   	nop
 482:	c9                   	leave  
 483:	c3                   	ret    

00000484 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 484:	55                   	push   %ebp
 485:	89 e5                	mov    %esp,%ebp
 487:	53                   	push   %ebx
 488:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 48b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 492:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 496:	74 17                	je     4af <printint+0x2b>
 498:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 49c:	79 11                	jns    4af <printint+0x2b>
    neg = 1;
 49e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a8:	f7 d8                	neg    %eax
 4aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ad:	eb 06                	jmp    4b5 <printint+0x31>
  } else {
    x = xx;
 4af:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4bc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4bf:	8d 41 01             	lea    0x1(%ecx),%eax
 4c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4cb:	ba 00 00 00 00       	mov    $0x0,%edx
 4d0:	f7 f3                	div    %ebx
 4d2:	89 d0                	mov    %edx,%eax
 4d4:	0f b6 80 60 0b 00 00 	movzbl 0xb60(%eax),%eax
 4db:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4df:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4e5:	ba 00 00 00 00       	mov    $0x0,%edx
 4ea:	f7 f3                	div    %ebx
 4ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ef:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4f3:	75 c7                	jne    4bc <printint+0x38>
  if(neg)
 4f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f9:	74 2d                	je     528 <printint+0xa4>
    buf[i++] = '-';
 4fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fe:	8d 50 01             	lea    0x1(%eax),%edx
 501:	89 55 f4             	mov    %edx,-0xc(%ebp)
 504:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 509:	eb 1d                	jmp    528 <printint+0xa4>
    putc(fd, buf[i]);
 50b:	8d 55 dc             	lea    -0x24(%ebp),%edx
 50e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 511:	01 d0                	add    %edx,%eax
 513:	0f b6 00             	movzbl (%eax),%eax
 516:	0f be c0             	movsbl %al,%eax
 519:	83 ec 08             	sub    $0x8,%esp
 51c:	50                   	push   %eax
 51d:	ff 75 08             	pushl  0x8(%ebp)
 520:	e8 3c ff ff ff       	call   461 <putc>
 525:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 528:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 52c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 530:	79 d9                	jns    50b <printint+0x87>
    putc(fd, buf[i]);
}
 532:	90                   	nop
 533:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 536:	c9                   	leave  
 537:	c3                   	ret    

00000538 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 538:	55                   	push   %ebp
 539:	89 e5                	mov    %esp,%ebp
 53b:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 53e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 545:	8d 45 0c             	lea    0xc(%ebp),%eax
 548:	83 c0 04             	add    $0x4,%eax
 54b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 54e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 555:	e9 59 01 00 00       	jmp    6b3 <printf+0x17b>
    c = fmt[i] & 0xff;
 55a:	8b 55 0c             	mov    0xc(%ebp),%edx
 55d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 560:	01 d0                	add    %edx,%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	0f be c0             	movsbl %al,%eax
 568:	25 ff 00 00 00       	and    $0xff,%eax
 56d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 570:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 574:	75 2c                	jne    5a2 <printf+0x6a>
      if(c == '%'){
 576:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 57a:	75 0c                	jne    588 <printf+0x50>
        state = '%';
 57c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 583:	e9 27 01 00 00       	jmp    6af <printf+0x177>
      } else {
        putc(fd, c);
 588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 58b:	0f be c0             	movsbl %al,%eax
 58e:	83 ec 08             	sub    $0x8,%esp
 591:	50                   	push   %eax
 592:	ff 75 08             	pushl  0x8(%ebp)
 595:	e8 c7 fe ff ff       	call   461 <putc>
 59a:	83 c4 10             	add    $0x10,%esp
 59d:	e9 0d 01 00 00       	jmp    6af <printf+0x177>
      }
    } else if(state == '%'){
 5a2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5a6:	0f 85 03 01 00 00    	jne    6af <printf+0x177>
      if(c == 'd'){
 5ac:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5b0:	75 1e                	jne    5d0 <printf+0x98>
        printint(fd, *ap, 10, 1);
 5b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b5:	8b 00                	mov    (%eax),%eax
 5b7:	6a 01                	push   $0x1
 5b9:	6a 0a                	push   $0xa
 5bb:	50                   	push   %eax
 5bc:	ff 75 08             	pushl  0x8(%ebp)
 5bf:	e8 c0 fe ff ff       	call   484 <printint>
 5c4:	83 c4 10             	add    $0x10,%esp
        ap++;
 5c7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5cb:	e9 d8 00 00 00       	jmp    6a8 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 5d0:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5d4:	74 06                	je     5dc <printf+0xa4>
 5d6:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5da:	75 1e                	jne    5fa <printf+0xc2>
        printint(fd, *ap, 16, 0);
 5dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5df:	8b 00                	mov    (%eax),%eax
 5e1:	6a 00                	push   $0x0
 5e3:	6a 10                	push   $0x10
 5e5:	50                   	push   %eax
 5e6:	ff 75 08             	pushl  0x8(%ebp)
 5e9:	e8 96 fe ff ff       	call   484 <printint>
 5ee:	83 c4 10             	add    $0x10,%esp
        ap++;
 5f1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f5:	e9 ae 00 00 00       	jmp    6a8 <printf+0x170>
      } else if(c == 's'){
 5fa:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5fe:	75 43                	jne    643 <printf+0x10b>
        s = (char*)*ap;
 600:	8b 45 e8             	mov    -0x18(%ebp),%eax
 603:	8b 00                	mov    (%eax),%eax
 605:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 608:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 60c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 610:	75 25                	jne    637 <printf+0xff>
          s = "(null)";
 612:	c7 45 f4 ee 08 00 00 	movl   $0x8ee,-0xc(%ebp)
        while(*s != 0){
 619:	eb 1c                	jmp    637 <printf+0xff>
          putc(fd, *s);
 61b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 61e:	0f b6 00             	movzbl (%eax),%eax
 621:	0f be c0             	movsbl %al,%eax
 624:	83 ec 08             	sub    $0x8,%esp
 627:	50                   	push   %eax
 628:	ff 75 08             	pushl  0x8(%ebp)
 62b:	e8 31 fe ff ff       	call   461 <putc>
 630:	83 c4 10             	add    $0x10,%esp
          s++;
 633:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 637:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63a:	0f b6 00             	movzbl (%eax),%eax
 63d:	84 c0                	test   %al,%al
 63f:	75 da                	jne    61b <printf+0xe3>
 641:	eb 65                	jmp    6a8 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 643:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 647:	75 1d                	jne    666 <printf+0x12e>
        putc(fd, *ap);
 649:	8b 45 e8             	mov    -0x18(%ebp),%eax
 64c:	8b 00                	mov    (%eax),%eax
 64e:	0f be c0             	movsbl %al,%eax
 651:	83 ec 08             	sub    $0x8,%esp
 654:	50                   	push   %eax
 655:	ff 75 08             	pushl  0x8(%ebp)
 658:	e8 04 fe ff ff       	call   461 <putc>
 65d:	83 c4 10             	add    $0x10,%esp
        ap++;
 660:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 664:	eb 42                	jmp    6a8 <printf+0x170>
      } else if(c == '%'){
 666:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 66a:	75 17                	jne    683 <printf+0x14b>
        putc(fd, c);
 66c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66f:	0f be c0             	movsbl %al,%eax
 672:	83 ec 08             	sub    $0x8,%esp
 675:	50                   	push   %eax
 676:	ff 75 08             	pushl  0x8(%ebp)
 679:	e8 e3 fd ff ff       	call   461 <putc>
 67e:	83 c4 10             	add    $0x10,%esp
 681:	eb 25                	jmp    6a8 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 683:	83 ec 08             	sub    $0x8,%esp
 686:	6a 25                	push   $0x25
 688:	ff 75 08             	pushl  0x8(%ebp)
 68b:	e8 d1 fd ff ff       	call   461 <putc>
 690:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 693:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 696:	0f be c0             	movsbl %al,%eax
 699:	83 ec 08             	sub    $0x8,%esp
 69c:	50                   	push   %eax
 69d:	ff 75 08             	pushl  0x8(%ebp)
 6a0:	e8 bc fd ff ff       	call   461 <putc>
 6a5:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 6a8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6af:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6b3:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b9:	01 d0                	add    %edx,%eax
 6bb:	0f b6 00             	movzbl (%eax),%eax
 6be:	84 c0                	test   %al,%al
 6c0:	0f 85 94 fe ff ff    	jne    55a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6c6:	90                   	nop
 6c7:	c9                   	leave  
 6c8:	c3                   	ret    

000006c9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6c9:	55                   	push   %ebp
 6ca:	89 e5                	mov    %esp,%ebp
 6cc:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6cf:	8b 45 08             	mov    0x8(%ebp),%eax
 6d2:	83 e8 08             	sub    $0x8,%eax
 6d5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d8:	a1 7c 0b 00 00       	mov    0xb7c,%eax
 6dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6e0:	eb 24                	jmp    706 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e5:	8b 00                	mov    (%eax),%eax
 6e7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ea:	77 12                	ja     6fe <free+0x35>
 6ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ef:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6f2:	77 24                	ja     718 <free+0x4f>
 6f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f7:	8b 00                	mov    (%eax),%eax
 6f9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6fc:	77 1a                	ja     718 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 701:	8b 00                	mov    (%eax),%eax
 703:	89 45 fc             	mov    %eax,-0x4(%ebp)
 706:	8b 45 f8             	mov    -0x8(%ebp),%eax
 709:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 70c:	76 d4                	jbe    6e2 <free+0x19>
 70e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 711:	8b 00                	mov    (%eax),%eax
 713:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 716:	76 ca                	jbe    6e2 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 718:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71b:	8b 40 04             	mov    0x4(%eax),%eax
 71e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 725:	8b 45 f8             	mov    -0x8(%ebp),%eax
 728:	01 c2                	add    %eax,%edx
 72a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72d:	8b 00                	mov    (%eax),%eax
 72f:	39 c2                	cmp    %eax,%edx
 731:	75 24                	jne    757 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 733:	8b 45 f8             	mov    -0x8(%ebp),%eax
 736:	8b 50 04             	mov    0x4(%eax),%edx
 739:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73c:	8b 00                	mov    (%eax),%eax
 73e:	8b 40 04             	mov    0x4(%eax),%eax
 741:	01 c2                	add    %eax,%edx
 743:	8b 45 f8             	mov    -0x8(%ebp),%eax
 746:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 749:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74c:	8b 00                	mov    (%eax),%eax
 74e:	8b 10                	mov    (%eax),%edx
 750:	8b 45 f8             	mov    -0x8(%ebp),%eax
 753:	89 10                	mov    %edx,(%eax)
 755:	eb 0a                	jmp    761 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 757:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75a:	8b 10                	mov    (%eax),%edx
 75c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 761:	8b 45 fc             	mov    -0x4(%ebp),%eax
 764:	8b 40 04             	mov    0x4(%eax),%eax
 767:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 76e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 771:	01 d0                	add    %edx,%eax
 773:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 776:	75 20                	jne    798 <free+0xcf>
    p->s.size += bp->s.size;
 778:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77b:	8b 50 04             	mov    0x4(%eax),%edx
 77e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 781:	8b 40 04             	mov    0x4(%eax),%eax
 784:	01 c2                	add    %eax,%edx
 786:	8b 45 fc             	mov    -0x4(%ebp),%eax
 789:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 78c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78f:	8b 10                	mov    (%eax),%edx
 791:	8b 45 fc             	mov    -0x4(%ebp),%eax
 794:	89 10                	mov    %edx,(%eax)
 796:	eb 08                	jmp    7a0 <free+0xd7>
  } else
    p->s.ptr = bp;
 798:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 79e:	89 10                	mov    %edx,(%eax)
  freep = p;
 7a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a3:	a3 7c 0b 00 00       	mov    %eax,0xb7c
}
 7a8:	90                   	nop
 7a9:	c9                   	leave  
 7aa:	c3                   	ret    

000007ab <morecore>:

static Header*
morecore(uint nu)
{
 7ab:	55                   	push   %ebp
 7ac:	89 e5                	mov    %esp,%ebp
 7ae:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7b1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7b8:	77 07                	ja     7c1 <morecore+0x16>
    nu = 4096;
 7ba:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7c1:	8b 45 08             	mov    0x8(%ebp),%eax
 7c4:	c1 e0 03             	shl    $0x3,%eax
 7c7:	83 ec 0c             	sub    $0xc,%esp
 7ca:	50                   	push   %eax
 7cb:	e8 39 fc ff ff       	call   409 <sbrk>
 7d0:	83 c4 10             	add    $0x10,%esp
 7d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7d6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7da:	75 07                	jne    7e3 <morecore+0x38>
    return 0;
 7dc:	b8 00 00 00 00       	mov    $0x0,%eax
 7e1:	eb 26                	jmp    809 <morecore+0x5e>
  hp = (Header*)p;
 7e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ec:	8b 55 08             	mov    0x8(%ebp),%edx
 7ef:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f5:	83 c0 08             	add    $0x8,%eax
 7f8:	83 ec 0c             	sub    $0xc,%esp
 7fb:	50                   	push   %eax
 7fc:	e8 c8 fe ff ff       	call   6c9 <free>
 801:	83 c4 10             	add    $0x10,%esp
  return freep;
 804:	a1 7c 0b 00 00       	mov    0xb7c,%eax
}
 809:	c9                   	leave  
 80a:	c3                   	ret    

0000080b <malloc>:

void*
malloc(uint nbytes)
{
 80b:	55                   	push   %ebp
 80c:	89 e5                	mov    %esp,%ebp
 80e:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 811:	8b 45 08             	mov    0x8(%ebp),%eax
 814:	83 c0 07             	add    $0x7,%eax
 817:	c1 e8 03             	shr    $0x3,%eax
 81a:	83 c0 01             	add    $0x1,%eax
 81d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 820:	a1 7c 0b 00 00       	mov    0xb7c,%eax
 825:	89 45 f0             	mov    %eax,-0x10(%ebp)
 828:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 82c:	75 23                	jne    851 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 82e:	c7 45 f0 74 0b 00 00 	movl   $0xb74,-0x10(%ebp)
 835:	8b 45 f0             	mov    -0x10(%ebp),%eax
 838:	a3 7c 0b 00 00       	mov    %eax,0xb7c
 83d:	a1 7c 0b 00 00       	mov    0xb7c,%eax
 842:	a3 74 0b 00 00       	mov    %eax,0xb74
    base.s.size = 0;
 847:	c7 05 78 0b 00 00 00 	movl   $0x0,0xb78
 84e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 851:	8b 45 f0             	mov    -0x10(%ebp),%eax
 854:	8b 00                	mov    (%eax),%eax
 856:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 859:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85c:	8b 40 04             	mov    0x4(%eax),%eax
 85f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 862:	72 4d                	jb     8b1 <malloc+0xa6>
      if(p->s.size == nunits)
 864:	8b 45 f4             	mov    -0xc(%ebp),%eax
 867:	8b 40 04             	mov    0x4(%eax),%eax
 86a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 86d:	75 0c                	jne    87b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 86f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 872:	8b 10                	mov    (%eax),%edx
 874:	8b 45 f0             	mov    -0x10(%ebp),%eax
 877:	89 10                	mov    %edx,(%eax)
 879:	eb 26                	jmp    8a1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 87b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87e:	8b 40 04             	mov    0x4(%eax),%eax
 881:	2b 45 ec             	sub    -0x14(%ebp),%eax
 884:	89 c2                	mov    %eax,%edx
 886:	8b 45 f4             	mov    -0xc(%ebp),%eax
 889:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 88c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88f:	8b 40 04             	mov    0x4(%eax),%eax
 892:	c1 e0 03             	shl    $0x3,%eax
 895:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 898:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 89e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a4:	a3 7c 0b 00 00       	mov    %eax,0xb7c
      return (void*)(p + 1);
 8a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ac:	83 c0 08             	add    $0x8,%eax
 8af:	eb 3b                	jmp    8ec <malloc+0xe1>
    }
    if(p == freep)
 8b1:	a1 7c 0b 00 00       	mov    0xb7c,%eax
 8b6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8b9:	75 1e                	jne    8d9 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8bb:	83 ec 0c             	sub    $0xc,%esp
 8be:	ff 75 ec             	pushl  -0x14(%ebp)
 8c1:	e8 e5 fe ff ff       	call   7ab <morecore>
 8c6:	83 c4 10             	add    $0x10,%esp
 8c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8d0:	75 07                	jne    8d9 <malloc+0xce>
        return 0;
 8d2:	b8 00 00 00 00       	mov    $0x0,%eax
 8d7:	eb 13                	jmp    8ec <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e2:	8b 00                	mov    (%eax),%eax
 8e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8e7:	e9 6d ff ff ff       	jmp    859 <malloc+0x4e>
}
 8ec:	c9                   	leave  
 8ed:	c3                   	ret    
