
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 31 39 10 80       	mov    $0x80103931,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 ac 92 10 80       	push   $0x801092ac
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 9f 5b 00 00       	call   80105beb <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100056:	15 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
80100060:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 15 11 80       	mov    0x80111594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 15 11 80       	mov    %eax,0x80111594
  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 15 11 80       	mov    $0x80111584,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 80 d6 10 80       	push   $0x8010d680
801000c1:	e8 47 5b 00 00       	call   80105c0d <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 94 15 11 80       	mov    0x80111594,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 80 d6 10 80       	push   $0x8010d680
8010010c:	e8 63 5b 00 00       	call   80105c74 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 a8 4f 00 00       	call   801050d4 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 90 15 11 80       	mov    0x80111590,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 80 d6 10 80       	push   $0x8010d680
80100188:	e8 e7 5a 00 00       	call   80105c74 <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 b3 92 10 80       	push   $0x801092b3
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 c8 27 00 00       	call   801029af <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 c4 92 10 80       	push   $0x801092c4
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 87 27 00 00       	call   801029af <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 cb 92 10 80       	push   $0x801092cb
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 b3 59 00 00       	call   80105c0d <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 94 15 11 80       	mov    0x80111594,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 15 11 80       	mov    %eax,0x80111594

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 33 4f 00 00       	call   801051f1 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 a6 59 00 00       	call   80105c74 <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 c5 10 80       	push   $0x8010c5e0
801003e2:	e8 26 58 00 00       	call   80105c0d <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 d2 92 10 80       	push   $0x801092d2
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec db 92 10 80 	movl   $0x801092db,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 e0 c5 10 80       	push   $0x8010c5e0
8010055b:	e8 14 57 00 00       	call   80105c74 <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 e2 92 10 80       	push   $0x801092e2
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 f1 92 10 80       	push   $0x801092f1
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 ff 56 00 00       	call   80105cc6 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 f3 92 10 80       	push   $0x801092f3
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 f7 92 10 80       	push   $0x801092f7
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 33 58 00 00       	call   80105f2f <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 4a 57 00 00       	call   80105e70 <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 77 71 00 00       	call   80107932 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 6a 71 00 00       	call   80107932 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 5d 71 00 00       	call   80107932 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 4d 71 00 00       	call   80107932 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 28             	sub    $0x28,%esp
#ifdef CS333_P3P4
  int c, doprocdump, dor, dof, dos, doz;
  doprocdump = dor =  dof = dos = doz = 0;
801007ff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100806:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100809:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010080c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010080f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100812:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100815:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100818:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010081b:	89 45 f4             	mov    %eax,-0xc(%ebp)
#else
  int c, doprocdump = 0;
#endif
  acquire(&cons.lock);
8010081e:	83 ec 0c             	sub    $0xc,%esp
80100821:	68 e0 c5 10 80       	push   $0x8010c5e0
80100826:	e8 e2 53 00 00       	call   80105c0d <acquire>
8010082b:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
8010082e:	e9 9a 01 00 00       	jmp    801009cd <consoleintr+0x1d4>
    switch(c){
80100833:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100836:	83 f8 12             	cmp    $0x12,%eax
80100839:	74 50                	je     8010088b <consoleintr+0x92>
8010083b:	83 f8 12             	cmp    $0x12,%eax
8010083e:	7f 18                	jg     80100858 <consoleintr+0x5f>
80100840:	83 f8 08             	cmp    $0x8,%eax
80100843:	0f 84 bd 00 00 00    	je     80100906 <consoleintr+0x10d>
80100849:	83 f8 10             	cmp    $0x10,%eax
8010084c:	74 31                	je     8010087f <consoleintr+0x86>
8010084e:	83 f8 06             	cmp    $0x6,%eax
80100851:	74 44                	je     80100897 <consoleintr+0x9e>
80100853:	e9 e3 00 00 00       	jmp    8010093b <consoleintr+0x142>
80100858:	83 f8 15             	cmp    $0x15,%eax
8010085b:	74 7b                	je     801008d8 <consoleintr+0xdf>
8010085d:	83 f8 15             	cmp    $0x15,%eax
80100860:	7f 0a                	jg     8010086c <consoleintr+0x73>
80100862:	83 f8 13             	cmp    $0x13,%eax
80100865:	74 3c                	je     801008a3 <consoleintr+0xaa>
80100867:	e9 cf 00 00 00       	jmp    8010093b <consoleintr+0x142>
8010086c:	83 f8 1a             	cmp    $0x1a,%eax
8010086f:	74 3e                	je     801008af <consoleintr+0xb6>
80100871:	83 f8 7f             	cmp    $0x7f,%eax
80100874:	0f 84 8c 00 00 00    	je     80100906 <consoleintr+0x10d>
8010087a:	e9 bc 00 00 00       	jmp    8010093b <consoleintr+0x142>
    case C('P'): // Process listing.
      doprocdump = 1;  // procdump() locks cons.lock indirectly; invoke later
8010087f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100886:	e9 42 01 00 00       	jmp    801009cd <consoleintr+0x1d4>
#ifdef CS333_P3P4
    case C('R'):
      dor = 1;
8010088b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      break;
80100892:	e9 36 01 00 00       	jmp    801009cd <consoleintr+0x1d4>
    case C('F'):
      dof = 1;
80100897:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
      break;
8010089e:	e9 2a 01 00 00       	jmp    801009cd <consoleintr+0x1d4>
    case C('S'):
      dos = 1;
801008a3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
      break;
801008aa:	e9 1e 01 00 00       	jmp    801009cd <consoleintr+0x1d4>
    case C('Z'):
      doz = 1;
801008af:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
      break;
801008b6:	e9 12 01 00 00       	jmp    801009cd <consoleintr+0x1d4>
#endif
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008bb:	a1 28 18 11 80       	mov    0x80111828,%eax
801008c0:	83 e8 01             	sub    $0x1,%eax
801008c3:	a3 28 18 11 80       	mov    %eax,0x80111828
        consputc(BACKSPACE);
801008c8:	83 ec 0c             	sub    $0xc,%esp
801008cb:	68 00 01 00 00       	push   $0x100
801008d0:	e8 bd fe ff ff       	call   80100792 <consputc>
801008d5:	83 c4 10             	add    $0x10,%esp
    case C('Z'):
      doz = 1;
      break;
#endif
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008d8:	8b 15 28 18 11 80    	mov    0x80111828,%edx
801008de:	a1 24 18 11 80       	mov    0x80111824,%eax
801008e3:	39 c2                	cmp    %eax,%edx
801008e5:	0f 84 e2 00 00 00    	je     801009cd <consoleintr+0x1d4>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008eb:	a1 28 18 11 80       	mov    0x80111828,%eax
801008f0:	83 e8 01             	sub    $0x1,%eax
801008f3:	83 e0 7f             	and    $0x7f,%eax
801008f6:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
    case C('Z'):
      doz = 1;
      break;
#endif
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008fd:	3c 0a                	cmp    $0xa,%al
801008ff:	75 ba                	jne    801008bb <consoleintr+0xc2>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100901:	e9 c7 00 00 00       	jmp    801009cd <consoleintr+0x1d4>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100906:	8b 15 28 18 11 80    	mov    0x80111828,%edx
8010090c:	a1 24 18 11 80       	mov    0x80111824,%eax
80100911:	39 c2                	cmp    %eax,%edx
80100913:	0f 84 b4 00 00 00    	je     801009cd <consoleintr+0x1d4>
        input.e--;
80100919:	a1 28 18 11 80       	mov    0x80111828,%eax
8010091e:	83 e8 01             	sub    $0x1,%eax
80100921:	a3 28 18 11 80       	mov    %eax,0x80111828
        consputc(BACKSPACE);
80100926:	83 ec 0c             	sub    $0xc,%esp
80100929:	68 00 01 00 00       	push   $0x100
8010092e:	e8 5f fe ff ff       	call   80100792 <consputc>
80100933:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100936:	e9 92 00 00 00       	jmp    801009cd <consoleintr+0x1d4>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010093b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010093f:	0f 84 87 00 00 00    	je     801009cc <consoleintr+0x1d3>
80100945:	8b 15 28 18 11 80    	mov    0x80111828,%edx
8010094b:	a1 20 18 11 80       	mov    0x80111820,%eax
80100950:	29 c2                	sub    %eax,%edx
80100952:	89 d0                	mov    %edx,%eax
80100954:	83 f8 7f             	cmp    $0x7f,%eax
80100957:	77 73                	ja     801009cc <consoleintr+0x1d3>
        c = (c == '\r') ? '\n' : c;
80100959:	83 7d e0 0d          	cmpl   $0xd,-0x20(%ebp)
8010095d:	74 05                	je     80100964 <consoleintr+0x16b>
8010095f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100962:	eb 05                	jmp    80100969 <consoleintr+0x170>
80100964:	b8 0a 00 00 00       	mov    $0xa,%eax
80100969:	89 45 e0             	mov    %eax,-0x20(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010096c:	a1 28 18 11 80       	mov    0x80111828,%eax
80100971:	8d 50 01             	lea    0x1(%eax),%edx
80100974:	89 15 28 18 11 80    	mov    %edx,0x80111828
8010097a:	83 e0 7f             	and    $0x7f,%eax
8010097d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100980:	88 90 a0 17 11 80    	mov    %dl,-0x7feee860(%eax)
        consputc(c);
80100986:	83 ec 0c             	sub    $0xc,%esp
80100989:	ff 75 e0             	pushl  -0x20(%ebp)
8010098c:	e8 01 fe ff ff       	call   80100792 <consputc>
80100991:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100994:	83 7d e0 0a          	cmpl   $0xa,-0x20(%ebp)
80100998:	74 18                	je     801009b2 <consoleintr+0x1b9>
8010099a:	83 7d e0 04          	cmpl   $0x4,-0x20(%ebp)
8010099e:	74 12                	je     801009b2 <consoleintr+0x1b9>
801009a0:	a1 28 18 11 80       	mov    0x80111828,%eax
801009a5:	8b 15 20 18 11 80    	mov    0x80111820,%edx
801009ab:	83 ea 80             	sub    $0xffffff80,%edx
801009ae:	39 d0                	cmp    %edx,%eax
801009b0:	75 1a                	jne    801009cc <consoleintr+0x1d3>
          input.w = input.e;
801009b2:	a1 28 18 11 80       	mov    0x80111828,%eax
801009b7:	a3 24 18 11 80       	mov    %eax,0x80111824
          wakeup(&input.r);
801009bc:	83 ec 0c             	sub    $0xc,%esp
801009bf:	68 20 18 11 80       	push   $0x80111820
801009c4:	e8 28 48 00 00       	call   801051f1 <wakeup>
801009c9:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009cc:	90                   	nop
  doprocdump = dor =  dof = dos = doz = 0;
#else
  int c, doprocdump = 0;
#endif
  acquire(&cons.lock);
  while((c = getc()) >= 0){
801009cd:	8b 45 08             	mov    0x8(%ebp),%eax
801009d0:	ff d0                	call   *%eax
801009d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
801009d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801009d9:	0f 89 54 fe ff ff    	jns    80100833 <consoleintr+0x3a>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801009df:	83 ec 0c             	sub    $0xc,%esp
801009e2:	68 e0 c5 10 80       	push   $0x8010c5e0
801009e7:	e8 88 52 00 00       	call   80105c74 <release>
801009ec:	83 c4 10             	add    $0x10,%esp
#ifdef CS333_P3P4
  if(doprocdump) {
801009ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009f3:	74 07                	je     801009fc <consoleintr+0x203>
    procdump();  // now call procdump() wo. cons.lock held
801009f5:	e8 7d 49 00 00       	call   80105377 <procdump>
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }
#endif

}
801009fa:	eb 32                	jmp    80100a2e <consoleintr+0x235>
  }
  release(&cons.lock);
#ifdef CS333_P3P4
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }else if(dor) {
801009fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a00:	74 07                	je     80100a09 <consoleintr+0x210>
    control_r();
80100a02:	e8 b6 4f 00 00       	call   801059bd <control_r>
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }
#endif

}
80100a07:	eb 25                	jmp    80100a2e <consoleintr+0x235>
#ifdef CS333_P3P4
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }else if(dor) {
    control_r();
  }else if(dof) {
80100a09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a0d:	74 07                	je     80100a16 <consoleintr+0x21d>
    control_f();
80100a0f:	e8 31 50 00 00       	call   80105a45 <control_f>
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }
#endif

}
80100a14:	eb 18                	jmp    80100a2e <consoleintr+0x235>
    procdump();  // now call procdump() wo. cons.lock held
  }else if(dor) {
    control_r();
  }else if(dof) {
    control_f();
  }else if(dos) {
80100a16:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100a1a:	74 07                	je     80100a23 <consoleintr+0x22a>
    control_s();
80100a1c:	e8 6e 50 00 00       	call   80105a8f <control_s>
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }
#endif

}
80100a21:	eb 0b                	jmp    80100a2e <consoleintr+0x235>
    control_r();
  }else if(dof) {
    control_f();
  }else if(dos) {
    control_s();
  }else if(doz) {
80100a23:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a27:	74 05                	je     80100a2e <consoleintr+0x235>
    control_z();
80100a29:	e8 e9 50 00 00       	call   80105b17 <control_z>
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }
#endif

}
80100a2e:	90                   	nop
80100a2f:	c9                   	leave  
80100a30:	c3                   	ret    

80100a31 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a31:	55                   	push   %ebp
80100a32:	89 e5                	mov    %esp,%ebp
80100a34:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a37:	83 ec 0c             	sub    $0xc,%esp
80100a3a:	ff 75 08             	pushl  0x8(%ebp)
80100a3d:	e8 28 11 00 00       	call   80101b6a <iunlock>
80100a42:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a45:	8b 45 10             	mov    0x10(%ebp),%eax
80100a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a4b:	83 ec 0c             	sub    $0xc,%esp
80100a4e:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a53:	e8 b5 51 00 00       	call   80105c0d <acquire>
80100a58:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a5b:	e9 ac 00 00 00       	jmp    80100b0c <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
80100a60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100a66:	8b 40 24             	mov    0x24(%eax),%eax
80100a69:	85 c0                	test   %eax,%eax
80100a6b:	74 28                	je     80100a95 <consoleread+0x64>
        release(&cons.lock);
80100a6d:	83 ec 0c             	sub    $0xc,%esp
80100a70:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a75:	e8 fa 51 00 00       	call   80105c74 <release>
80100a7a:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a7d:	83 ec 0c             	sub    $0xc,%esp
80100a80:	ff 75 08             	pushl  0x8(%ebp)
80100a83:	e8 84 0f 00 00       	call   80101a0c <ilock>
80100a88:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a90:	e9 ab 00 00 00       	jmp    80100b40 <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
80100a95:	83 ec 08             	sub    $0x8,%esp
80100a98:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a9d:	68 20 18 11 80       	push   $0x80111820
80100aa2:	e8 2d 46 00 00       	call   801050d4 <sleep>
80100aa7:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100aaa:	8b 15 20 18 11 80    	mov    0x80111820,%edx
80100ab0:	a1 24 18 11 80       	mov    0x80111824,%eax
80100ab5:	39 c2                	cmp    %eax,%edx
80100ab7:	74 a7                	je     80100a60 <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100ab9:	a1 20 18 11 80       	mov    0x80111820,%eax
80100abe:	8d 50 01             	lea    0x1(%eax),%edx
80100ac1:	89 15 20 18 11 80    	mov    %edx,0x80111820
80100ac7:	83 e0 7f             	and    $0x7f,%eax
80100aca:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
80100ad1:	0f be c0             	movsbl %al,%eax
80100ad4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100ad7:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100adb:	75 17                	jne    80100af4 <consoleread+0xc3>
      if(n < target){
80100add:	8b 45 10             	mov    0x10(%ebp),%eax
80100ae0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100ae3:	73 2f                	jae    80100b14 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100ae5:	a1 20 18 11 80       	mov    0x80111820,%eax
80100aea:	83 e8 01             	sub    $0x1,%eax
80100aed:	a3 20 18 11 80       	mov    %eax,0x80111820
      }
      break;
80100af2:	eb 20                	jmp    80100b14 <consoleread+0xe3>
    }
    *dst++ = c;
80100af4:	8b 45 0c             	mov    0xc(%ebp),%eax
80100af7:	8d 50 01             	lea    0x1(%eax),%edx
80100afa:	89 55 0c             	mov    %edx,0xc(%ebp)
80100afd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b00:	88 10                	mov    %dl,(%eax)
    --n;
80100b02:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b06:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b0a:	74 0b                	je     80100b17 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100b0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b10:	7f 98                	jg     80100aaa <consoleread+0x79>
80100b12:	eb 04                	jmp    80100b18 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100b14:	90                   	nop
80100b15:	eb 01                	jmp    80100b18 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100b17:	90                   	nop
  }
  release(&cons.lock);
80100b18:	83 ec 0c             	sub    $0xc,%esp
80100b1b:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b20:	e8 4f 51 00 00       	call   80105c74 <release>
80100b25:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b28:	83 ec 0c             	sub    $0xc,%esp
80100b2b:	ff 75 08             	pushl  0x8(%ebp)
80100b2e:	e8 d9 0e 00 00       	call   80101a0c <ilock>
80100b33:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b36:	8b 45 10             	mov    0x10(%ebp),%eax
80100b39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b3c:	29 c2                	sub    %eax,%edx
80100b3e:	89 d0                	mov    %edx,%eax
}
80100b40:	c9                   	leave  
80100b41:	c3                   	ret    

80100b42 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b42:	55                   	push   %ebp
80100b43:	89 e5                	mov    %esp,%ebp
80100b45:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b48:	83 ec 0c             	sub    $0xc,%esp
80100b4b:	ff 75 08             	pushl  0x8(%ebp)
80100b4e:	e8 17 10 00 00       	call   80101b6a <iunlock>
80100b53:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b56:	83 ec 0c             	sub    $0xc,%esp
80100b59:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b5e:	e8 aa 50 00 00       	call   80105c0d <acquire>
80100b63:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b6d:	eb 21                	jmp    80100b90 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b75:	01 d0                	add    %edx,%eax
80100b77:	0f b6 00             	movzbl (%eax),%eax
80100b7a:	0f be c0             	movsbl %al,%eax
80100b7d:	0f b6 c0             	movzbl %al,%eax
80100b80:	83 ec 0c             	sub    $0xc,%esp
80100b83:	50                   	push   %eax
80100b84:	e8 09 fc ff ff       	call   80100792 <consputc>
80100b89:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100b8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b93:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b96:	7c d7                	jl     80100b6f <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100b98:	83 ec 0c             	sub    $0xc,%esp
80100b9b:	68 e0 c5 10 80       	push   $0x8010c5e0
80100ba0:	e8 cf 50 00 00       	call   80105c74 <release>
80100ba5:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ba8:	83 ec 0c             	sub    $0xc,%esp
80100bab:	ff 75 08             	pushl  0x8(%ebp)
80100bae:	e8 59 0e 00 00       	call   80101a0c <ilock>
80100bb3:	83 c4 10             	add    $0x10,%esp

  return n;
80100bb6:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bb9:	c9                   	leave  
80100bba:	c3                   	ret    

80100bbb <consoleinit>:

void
consoleinit(void)
{
80100bbb:	55                   	push   %ebp
80100bbc:	89 e5                	mov    %esp,%ebp
80100bbe:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100bc1:	83 ec 08             	sub    $0x8,%esp
80100bc4:	68 0a 93 10 80       	push   $0x8010930a
80100bc9:	68 e0 c5 10 80       	push   $0x8010c5e0
80100bce:	e8 18 50 00 00       	call   80105beb <initlock>
80100bd3:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100bd6:	c7 05 ec 21 11 80 42 	movl   $0x80100b42,0x801121ec
80100bdd:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100be0:	c7 05 e8 21 11 80 31 	movl   $0x80100a31,0x801121e8
80100be7:	0a 10 80 
  cons.locking = 1;
80100bea:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100bf1:	00 00 00 

  picenable(IRQ_KBD);
80100bf4:	83 ec 0c             	sub    $0xc,%esp
80100bf7:	6a 01                	push   $0x1
80100bf9:	e8 cf 33 00 00       	call   80103fcd <picenable>
80100bfe:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100c01:	83 ec 08             	sub    $0x8,%esp
80100c04:	6a 00                	push   $0x0
80100c06:	6a 01                	push   $0x1
80100c08:	e8 6f 1f 00 00       	call   80102b7c <ioapicenable>
80100c0d:	83 c4 10             	add    $0x10,%esp
}
80100c10:	90                   	nop
80100c11:	c9                   	leave  
80100c12:	c3                   	ret    

80100c13 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c13:	55                   	push   %ebp
80100c14:	89 e5                	mov    %esp,%ebp
80100c16:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100c1c:	e8 ce 29 00 00       	call   801035ef <begin_op>
  if((ip = namei(path)) == 0){
80100c21:	83 ec 0c             	sub    $0xc,%esp
80100c24:	ff 75 08             	pushl  0x8(%ebp)
80100c27:	e8 9e 19 00 00       	call   801025ca <namei>
80100c2c:	83 c4 10             	add    $0x10,%esp
80100c2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c32:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c36:	75 0f                	jne    80100c47 <exec+0x34>
    end_op();
80100c38:	e8 3e 2a 00 00       	call   8010367b <end_op>
    return -1;
80100c3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c42:	e9 ce 03 00 00       	jmp    80101015 <exec+0x402>
  }
  ilock(ip);
80100c47:	83 ec 0c             	sub    $0xc,%esp
80100c4a:	ff 75 d8             	pushl  -0x28(%ebp)
80100c4d:	e8 ba 0d 00 00       	call   80101a0c <ilock>
80100c52:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c55:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100c5c:	6a 34                	push   $0x34
80100c5e:	6a 00                	push   $0x0
80100c60:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100c66:	50                   	push   %eax
80100c67:	ff 75 d8             	pushl  -0x28(%ebp)
80100c6a:	e8 0b 13 00 00       	call   80101f7a <readi>
80100c6f:	83 c4 10             	add    $0x10,%esp
80100c72:	83 f8 33             	cmp    $0x33,%eax
80100c75:	0f 86 49 03 00 00    	jbe    80100fc4 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c7b:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c81:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c86:	0f 85 3b 03 00 00    	jne    80100fc7 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c8c:	e8 f6 7d 00 00       	call   80108a87 <setupkvm>
80100c91:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c94:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c98:	0f 84 2c 03 00 00    	je     80100fca <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c9e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ca5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100cac:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100cb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cb5:	e9 ab 00 00 00       	jmp    80100d65 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cbd:	6a 20                	push   $0x20
80100cbf:	50                   	push   %eax
80100cc0:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100cc6:	50                   	push   %eax
80100cc7:	ff 75 d8             	pushl  -0x28(%ebp)
80100cca:	e8 ab 12 00 00       	call   80101f7a <readi>
80100ccf:	83 c4 10             	add    $0x10,%esp
80100cd2:	83 f8 20             	cmp    $0x20,%eax
80100cd5:	0f 85 f2 02 00 00    	jne    80100fcd <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100cdb:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ce1:	83 f8 01             	cmp    $0x1,%eax
80100ce4:	75 71                	jne    80100d57 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100ce6:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100cec:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cf2:	39 c2                	cmp    %eax,%edx
80100cf4:	0f 82 d6 02 00 00    	jb     80100fd0 <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cfa:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100d00:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100d06:	01 d0                	add    %edx,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d0f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d12:	e8 17 81 00 00       	call   80108e2e <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 ac 02 00 00    	je     80100fd3 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d27:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d2d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d33:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100d39:	83 ec 0c             	sub    $0xc,%esp
80100d3c:	52                   	push   %edx
80100d3d:	50                   	push   %eax
80100d3e:	ff 75 d8             	pushl  -0x28(%ebp)
80100d41:	51                   	push   %ecx
80100d42:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d45:	e8 0d 80 00 00       	call   80108d57 <loaduvm>
80100d4a:	83 c4 20             	add    $0x20,%esp
80100d4d:	85 c0                	test   %eax,%eax
80100d4f:	0f 88 81 02 00 00    	js     80100fd6 <exec+0x3c3>
80100d55:	eb 01                	jmp    80100d58 <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100d57:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d58:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d5f:	83 c0 20             	add    $0x20,%eax
80100d62:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d65:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100d6c:	0f b7 c0             	movzwl %ax,%eax
80100d6f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100d72:	0f 8f 42 ff ff ff    	jg     80100cba <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d78:	83 ec 0c             	sub    $0xc,%esp
80100d7b:	ff 75 d8             	pushl  -0x28(%ebp)
80100d7e:	e8 49 0f 00 00       	call   80101ccc <iunlockput>
80100d83:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d86:	e8 f0 28 00 00       	call   8010367b <end_op>
  ip = 0;
80100d8b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d92:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d95:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da5:	05 00 20 00 00       	add    $0x2000,%eax
80100daa:	83 ec 04             	sub    $0x4,%esp
80100dad:	50                   	push   %eax
80100dae:	ff 75 e0             	pushl  -0x20(%ebp)
80100db1:	ff 75 d4             	pushl  -0x2c(%ebp)
80100db4:	e8 75 80 00 00       	call   80108e2e <allocuvm>
80100db9:	83 c4 10             	add    $0x10,%esp
80100dbc:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dbf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dc3:	0f 84 10 02 00 00    	je     80100fd9 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dcc:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dd1:	83 ec 08             	sub    $0x8,%esp
80100dd4:	50                   	push   %eax
80100dd5:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dd8:	e8 77 82 00 00       	call   80109054 <clearpteu>
80100ddd:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100de0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100de3:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100ded:	e9 96 00 00 00       	jmp    80100e88 <exec+0x275>
    if(argc >= MAXARG)
80100df2:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100df6:	0f 87 e0 01 00 00    	ja     80100fdc <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e09:	01 d0                	add    %edx,%eax
80100e0b:	8b 00                	mov    (%eax),%eax
80100e0d:	83 ec 0c             	sub    $0xc,%esp
80100e10:	50                   	push   %eax
80100e11:	e8 a7 52 00 00       	call   801060bd <strlen>
80100e16:	83 c4 10             	add    $0x10,%esp
80100e19:	89 c2                	mov    %eax,%edx
80100e1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e1e:	29 d0                	sub    %edx,%eax
80100e20:	83 e8 01             	sub    $0x1,%eax
80100e23:	83 e0 fc             	and    $0xfffffffc,%eax
80100e26:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e33:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e36:	01 d0                	add    %edx,%eax
80100e38:	8b 00                	mov    (%eax),%eax
80100e3a:	83 ec 0c             	sub    $0xc,%esp
80100e3d:	50                   	push   %eax
80100e3e:	e8 7a 52 00 00       	call   801060bd <strlen>
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	83 c0 01             	add    $0x1,%eax
80100e49:	89 c1                	mov    %eax,%ecx
80100e4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e55:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e58:	01 d0                	add    %edx,%eax
80100e5a:	8b 00                	mov    (%eax),%eax
80100e5c:	51                   	push   %ecx
80100e5d:	50                   	push   %eax
80100e5e:	ff 75 dc             	pushl  -0x24(%ebp)
80100e61:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e64:	e8 a2 83 00 00       	call   8010920b <copyout>
80100e69:	83 c4 10             	add    $0x10,%esp
80100e6c:	85 c0                	test   %eax,%eax
80100e6e:	0f 88 6b 01 00 00    	js     80100fdf <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	8d 50 03             	lea    0x3(%eax),%edx
80100e7a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e7d:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e84:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e92:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e95:	01 d0                	add    %edx,%eax
80100e97:	8b 00                	mov    (%eax),%eax
80100e99:	85 c0                	test   %eax,%eax
80100e9b:	0f 85 51 ff ff ff    	jne    80100df2 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea4:	83 c0 03             	add    $0x3,%eax
80100ea7:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100eae:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100eb2:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100eb9:	ff ff ff 
  ustack[1] = argc;
80100ebc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ebf:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ec5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec8:	83 c0 01             	add    $0x1,%eax
80100ecb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ed2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ed5:	29 d0                	sub    %edx,%eax
80100ed7:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100edd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee0:	83 c0 04             	add    $0x4,%eax
80100ee3:	c1 e0 02             	shl    $0x2,%eax
80100ee6:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ee9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eec:	83 c0 04             	add    $0x4,%eax
80100eef:	c1 e0 02             	shl    $0x2,%eax
80100ef2:	50                   	push   %eax
80100ef3:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100ef9:	50                   	push   %eax
80100efa:	ff 75 dc             	pushl  -0x24(%ebp)
80100efd:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f00:	e8 06 83 00 00       	call   8010920b <copyout>
80100f05:	83 c4 10             	add    $0x10,%esp
80100f08:	85 c0                	test   %eax,%eax
80100f0a:	0f 88 d2 00 00 00    	js     80100fe2 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f10:	8b 45 08             	mov    0x8(%ebp),%eax
80100f13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f19:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f1c:	eb 17                	jmp    80100f35 <exec+0x322>
    if(*s == '/')
80100f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f21:	0f b6 00             	movzbl (%eax),%eax
80100f24:	3c 2f                	cmp    $0x2f,%al
80100f26:	75 09                	jne    80100f31 <exec+0x31e>
      last = s+1;
80100f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f2b:	83 c0 01             	add    $0x1,%eax
80100f2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f31:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f38:	0f b6 00             	movzbl (%eax),%eax
80100f3b:	84 c0                	test   %al,%al
80100f3d:	75 df                	jne    80100f1e <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100f3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f45:	83 c0 6c             	add    $0x6c,%eax
80100f48:	83 ec 04             	sub    $0x4,%esp
80100f4b:	6a 10                	push   $0x10
80100f4d:	ff 75 f0             	pushl  -0x10(%ebp)
80100f50:	50                   	push   %eax
80100f51:	e8 1d 51 00 00       	call   80106073 <safestrcpy>
80100f56:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100f59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f5f:	8b 40 04             	mov    0x4(%eax),%eax
80100f62:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100f65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f6b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f6e:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f77:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f7a:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f82:	8b 40 18             	mov    0x18(%eax),%eax
80100f85:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f8b:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f8e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f94:	8b 40 18             	mov    0x18(%eax),%eax
80100f97:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f9a:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100fa3:	83 ec 0c             	sub    $0xc,%esp
80100fa6:	50                   	push   %eax
80100fa7:	e8 c2 7b 00 00       	call   80108b6e <switchuvm>
80100fac:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100faf:	83 ec 0c             	sub    $0xc,%esp
80100fb2:	ff 75 d0             	pushl  -0x30(%ebp)
80100fb5:	e8 fa 7f 00 00       	call   80108fb4 <freevm>
80100fba:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fbd:	b8 00 00 00 00       	mov    $0x0,%eax
80100fc2:	eb 51                	jmp    80101015 <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100fc4:	90                   	nop
80100fc5:	eb 1c                	jmp    80100fe3 <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100fc7:	90                   	nop
80100fc8:	eb 19                	jmp    80100fe3 <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100fca:	90                   	nop
80100fcb:	eb 16                	jmp    80100fe3 <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100fcd:	90                   	nop
80100fce:	eb 13                	jmp    80100fe3 <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100fd0:	90                   	nop
80100fd1:	eb 10                	jmp    80100fe3 <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100fd3:	90                   	nop
80100fd4:	eb 0d                	jmp    80100fe3 <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100fd6:	90                   	nop
80100fd7:	eb 0a                	jmp    80100fe3 <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100fd9:	90                   	nop
80100fda:	eb 07                	jmp    80100fe3 <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100fdc:	90                   	nop
80100fdd:	eb 04                	jmp    80100fe3 <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100fdf:	90                   	nop
80100fe0:	eb 01                	jmp    80100fe3 <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100fe2:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100fe3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fe7:	74 0e                	je     80100ff7 <exec+0x3e4>
    freevm(pgdir);
80100fe9:	83 ec 0c             	sub    $0xc,%esp
80100fec:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fef:	e8 c0 7f 00 00       	call   80108fb4 <freevm>
80100ff4:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100ff7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ffb:	74 13                	je     80101010 <exec+0x3fd>
    iunlockput(ip);
80100ffd:	83 ec 0c             	sub    $0xc,%esp
80101000:	ff 75 d8             	pushl  -0x28(%ebp)
80101003:	e8 c4 0c 00 00       	call   80101ccc <iunlockput>
80101008:	83 c4 10             	add    $0x10,%esp
    end_op();
8010100b:	e8 6b 26 00 00       	call   8010367b <end_op>
  }
  return -1;
80101010:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101015:	c9                   	leave  
80101016:	c3                   	ret    

80101017 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101017:	55                   	push   %ebp
80101018:	89 e5                	mov    %esp,%ebp
8010101a:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010101d:	83 ec 08             	sub    $0x8,%esp
80101020:	68 12 93 10 80       	push   $0x80109312
80101025:	68 40 18 11 80       	push   $0x80111840
8010102a:	e8 bc 4b 00 00       	call   80105beb <initlock>
8010102f:	83 c4 10             	add    $0x10,%esp
}
80101032:	90                   	nop
80101033:	c9                   	leave  
80101034:	c3                   	ret    

80101035 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101035:	55                   	push   %ebp
80101036:	89 e5                	mov    %esp,%ebp
80101038:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010103b:	83 ec 0c             	sub    $0xc,%esp
8010103e:	68 40 18 11 80       	push   $0x80111840
80101043:	e8 c5 4b 00 00       	call   80105c0d <acquire>
80101048:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010104b:	c7 45 f4 74 18 11 80 	movl   $0x80111874,-0xc(%ebp)
80101052:	eb 2d                	jmp    80101081 <filealloc+0x4c>
    if(f->ref == 0){
80101054:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101057:	8b 40 04             	mov    0x4(%eax),%eax
8010105a:	85 c0                	test   %eax,%eax
8010105c:	75 1f                	jne    8010107d <filealloc+0x48>
      f->ref = 1;
8010105e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101061:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101068:	83 ec 0c             	sub    $0xc,%esp
8010106b:	68 40 18 11 80       	push   $0x80111840
80101070:	e8 ff 4b 00 00       	call   80105c74 <release>
80101075:	83 c4 10             	add    $0x10,%esp
      return f;
80101078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010107b:	eb 23                	jmp    801010a0 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010107d:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101081:	b8 d4 21 11 80       	mov    $0x801121d4,%eax
80101086:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101089:	72 c9                	jb     80101054 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010108b:	83 ec 0c             	sub    $0xc,%esp
8010108e:	68 40 18 11 80       	push   $0x80111840
80101093:	e8 dc 4b 00 00       	call   80105c74 <release>
80101098:	83 c4 10             	add    $0x10,%esp
  return 0;
8010109b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010a0:	c9                   	leave  
801010a1:	c3                   	ret    

801010a2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010a2:	55                   	push   %ebp
801010a3:	89 e5                	mov    %esp,%ebp
801010a5:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010a8:	83 ec 0c             	sub    $0xc,%esp
801010ab:	68 40 18 11 80       	push   $0x80111840
801010b0:	e8 58 4b 00 00       	call   80105c0d <acquire>
801010b5:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b8:	8b 45 08             	mov    0x8(%ebp),%eax
801010bb:	8b 40 04             	mov    0x4(%eax),%eax
801010be:	85 c0                	test   %eax,%eax
801010c0:	7f 0d                	jg     801010cf <filedup+0x2d>
    panic("filedup");
801010c2:	83 ec 0c             	sub    $0xc,%esp
801010c5:	68 19 93 10 80       	push   $0x80109319
801010ca:	e8 97 f4 ff ff       	call   80100566 <panic>
  f->ref++;
801010cf:	8b 45 08             	mov    0x8(%ebp),%eax
801010d2:	8b 40 04             	mov    0x4(%eax),%eax
801010d5:	8d 50 01             	lea    0x1(%eax),%edx
801010d8:	8b 45 08             	mov    0x8(%ebp),%eax
801010db:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010de:	83 ec 0c             	sub    $0xc,%esp
801010e1:	68 40 18 11 80       	push   $0x80111840
801010e6:	e8 89 4b 00 00       	call   80105c74 <release>
801010eb:	83 c4 10             	add    $0x10,%esp
  return f;
801010ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010f1:	c9                   	leave  
801010f2:	c3                   	ret    

801010f3 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010f3:	55                   	push   %ebp
801010f4:	89 e5                	mov    %esp,%ebp
801010f6:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010f9:	83 ec 0c             	sub    $0xc,%esp
801010fc:	68 40 18 11 80       	push   $0x80111840
80101101:	e8 07 4b 00 00       	call   80105c0d <acquire>
80101106:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101109:	8b 45 08             	mov    0x8(%ebp),%eax
8010110c:	8b 40 04             	mov    0x4(%eax),%eax
8010110f:	85 c0                	test   %eax,%eax
80101111:	7f 0d                	jg     80101120 <fileclose+0x2d>
    panic("fileclose");
80101113:	83 ec 0c             	sub    $0xc,%esp
80101116:	68 21 93 10 80       	push   $0x80109321
8010111b:	e8 46 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
80101120:	8b 45 08             	mov    0x8(%ebp),%eax
80101123:	8b 40 04             	mov    0x4(%eax),%eax
80101126:	8d 50 ff             	lea    -0x1(%eax),%edx
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	89 50 04             	mov    %edx,0x4(%eax)
8010112f:	8b 45 08             	mov    0x8(%ebp),%eax
80101132:	8b 40 04             	mov    0x4(%eax),%eax
80101135:	85 c0                	test   %eax,%eax
80101137:	7e 15                	jle    8010114e <fileclose+0x5b>
    release(&ftable.lock);
80101139:	83 ec 0c             	sub    $0xc,%esp
8010113c:	68 40 18 11 80       	push   $0x80111840
80101141:	e8 2e 4b 00 00       	call   80105c74 <release>
80101146:	83 c4 10             	add    $0x10,%esp
80101149:	e9 8b 00 00 00       	jmp    801011d9 <fileclose+0xe6>
    return;
  }
  ff = *f;
8010114e:	8b 45 08             	mov    0x8(%ebp),%eax
80101151:	8b 10                	mov    (%eax),%edx
80101153:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101156:	8b 50 04             	mov    0x4(%eax),%edx
80101159:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010115c:	8b 50 08             	mov    0x8(%eax),%edx
8010115f:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101162:	8b 50 0c             	mov    0xc(%eax),%edx
80101165:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101168:	8b 50 10             	mov    0x10(%eax),%edx
8010116b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010116e:	8b 40 14             	mov    0x14(%eax),%eax
80101171:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010117e:	8b 45 08             	mov    0x8(%ebp),%eax
80101181:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101187:	83 ec 0c             	sub    $0xc,%esp
8010118a:	68 40 18 11 80       	push   $0x80111840
8010118f:	e8 e0 4a 00 00       	call   80105c74 <release>
80101194:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101197:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010119a:	83 f8 01             	cmp    $0x1,%eax
8010119d:	75 19                	jne    801011b8 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010119f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011a3:	0f be d0             	movsbl %al,%edx
801011a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011a9:	83 ec 08             	sub    $0x8,%esp
801011ac:	52                   	push   %edx
801011ad:	50                   	push   %eax
801011ae:	e8 83 30 00 00       	call   80104236 <pipeclose>
801011b3:	83 c4 10             	add    $0x10,%esp
801011b6:	eb 21                	jmp    801011d9 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011bb:	83 f8 02             	cmp    $0x2,%eax
801011be:	75 19                	jne    801011d9 <fileclose+0xe6>
    begin_op();
801011c0:	e8 2a 24 00 00       	call   801035ef <begin_op>
    iput(ff.ip);
801011c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011c8:	83 ec 0c             	sub    $0xc,%esp
801011cb:	50                   	push   %eax
801011cc:	e8 0b 0a 00 00       	call   80101bdc <iput>
801011d1:	83 c4 10             	add    $0x10,%esp
    end_op();
801011d4:	e8 a2 24 00 00       	call   8010367b <end_op>
  }
}
801011d9:	c9                   	leave  
801011da:	c3                   	ret    

801011db <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011db:	55                   	push   %ebp
801011dc:	89 e5                	mov    %esp,%ebp
801011de:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011e1:	8b 45 08             	mov    0x8(%ebp),%eax
801011e4:	8b 00                	mov    (%eax),%eax
801011e6:	83 f8 02             	cmp    $0x2,%eax
801011e9:	75 40                	jne    8010122b <filestat+0x50>
    ilock(f->ip);
801011eb:	8b 45 08             	mov    0x8(%ebp),%eax
801011ee:	8b 40 10             	mov    0x10(%eax),%eax
801011f1:	83 ec 0c             	sub    $0xc,%esp
801011f4:	50                   	push   %eax
801011f5:	e8 12 08 00 00       	call   80101a0c <ilock>
801011fa:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101200:	8b 40 10             	mov    0x10(%eax),%eax
80101203:	83 ec 08             	sub    $0x8,%esp
80101206:	ff 75 0c             	pushl  0xc(%ebp)
80101209:	50                   	push   %eax
8010120a:	e8 25 0d 00 00       	call   80101f34 <stati>
8010120f:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101212:	8b 45 08             	mov    0x8(%ebp),%eax
80101215:	8b 40 10             	mov    0x10(%eax),%eax
80101218:	83 ec 0c             	sub    $0xc,%esp
8010121b:	50                   	push   %eax
8010121c:	e8 49 09 00 00       	call   80101b6a <iunlock>
80101221:	83 c4 10             	add    $0x10,%esp
    return 0;
80101224:	b8 00 00 00 00       	mov    $0x0,%eax
80101229:	eb 05                	jmp    80101230 <filestat+0x55>
  }
  return -1;
8010122b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101230:	c9                   	leave  
80101231:	c3                   	ret    

80101232 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101232:	55                   	push   %ebp
80101233:	89 e5                	mov    %esp,%ebp
80101235:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010123f:	84 c0                	test   %al,%al
80101241:	75 0a                	jne    8010124d <fileread+0x1b>
    return -1;
80101243:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101248:	e9 9b 00 00 00       	jmp    801012e8 <fileread+0xb6>
  if(f->type == FD_PIPE)
8010124d:	8b 45 08             	mov    0x8(%ebp),%eax
80101250:	8b 00                	mov    (%eax),%eax
80101252:	83 f8 01             	cmp    $0x1,%eax
80101255:	75 1a                	jne    80101271 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101257:	8b 45 08             	mov    0x8(%ebp),%eax
8010125a:	8b 40 0c             	mov    0xc(%eax),%eax
8010125d:	83 ec 04             	sub    $0x4,%esp
80101260:	ff 75 10             	pushl  0x10(%ebp)
80101263:	ff 75 0c             	pushl  0xc(%ebp)
80101266:	50                   	push   %eax
80101267:	e8 72 31 00 00       	call   801043de <piperead>
8010126c:	83 c4 10             	add    $0x10,%esp
8010126f:	eb 77                	jmp    801012e8 <fileread+0xb6>
  if(f->type == FD_INODE){
80101271:	8b 45 08             	mov    0x8(%ebp),%eax
80101274:	8b 00                	mov    (%eax),%eax
80101276:	83 f8 02             	cmp    $0x2,%eax
80101279:	75 60                	jne    801012db <fileread+0xa9>
    ilock(f->ip);
8010127b:	8b 45 08             	mov    0x8(%ebp),%eax
8010127e:	8b 40 10             	mov    0x10(%eax),%eax
80101281:	83 ec 0c             	sub    $0xc,%esp
80101284:	50                   	push   %eax
80101285:	e8 82 07 00 00       	call   80101a0c <ilock>
8010128a:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010128d:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101290:	8b 45 08             	mov    0x8(%ebp),%eax
80101293:	8b 50 14             	mov    0x14(%eax),%edx
80101296:	8b 45 08             	mov    0x8(%ebp),%eax
80101299:	8b 40 10             	mov    0x10(%eax),%eax
8010129c:	51                   	push   %ecx
8010129d:	52                   	push   %edx
8010129e:	ff 75 0c             	pushl  0xc(%ebp)
801012a1:	50                   	push   %eax
801012a2:	e8 d3 0c 00 00       	call   80101f7a <readi>
801012a7:	83 c4 10             	add    $0x10,%esp
801012aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012b1:	7e 11                	jle    801012c4 <fileread+0x92>
      f->off += r;
801012b3:	8b 45 08             	mov    0x8(%ebp),%eax
801012b6:	8b 50 14             	mov    0x14(%eax),%edx
801012b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012bc:	01 c2                	add    %eax,%edx
801012be:	8b 45 08             	mov    0x8(%ebp),%eax
801012c1:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012c4:	8b 45 08             	mov    0x8(%ebp),%eax
801012c7:	8b 40 10             	mov    0x10(%eax),%eax
801012ca:	83 ec 0c             	sub    $0xc,%esp
801012cd:	50                   	push   %eax
801012ce:	e8 97 08 00 00       	call   80101b6a <iunlock>
801012d3:	83 c4 10             	add    $0x10,%esp
    return r;
801012d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d9:	eb 0d                	jmp    801012e8 <fileread+0xb6>
  }
  panic("fileread");
801012db:	83 ec 0c             	sub    $0xc,%esp
801012de:	68 2b 93 10 80       	push   $0x8010932b
801012e3:	e8 7e f2 ff ff       	call   80100566 <panic>
}
801012e8:	c9                   	leave  
801012e9:	c3                   	ret    

801012ea <filewrite>:

// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012ea:	55                   	push   %ebp
801012eb:	89 e5                	mov    %esp,%ebp
801012ed:	53                   	push   %ebx
801012ee:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012f1:	8b 45 08             	mov    0x8(%ebp),%eax
801012f4:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012f8:	84 c0                	test   %al,%al
801012fa:	75 0a                	jne    80101306 <filewrite+0x1c>
    return -1;
801012fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101301:	e9 1b 01 00 00       	jmp    80101421 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101306:	8b 45 08             	mov    0x8(%ebp),%eax
80101309:	8b 00                	mov    (%eax),%eax
8010130b:	83 f8 01             	cmp    $0x1,%eax
8010130e:	75 1d                	jne    8010132d <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101310:	8b 45 08             	mov    0x8(%ebp),%eax
80101313:	8b 40 0c             	mov    0xc(%eax),%eax
80101316:	83 ec 04             	sub    $0x4,%esp
80101319:	ff 75 10             	pushl  0x10(%ebp)
8010131c:	ff 75 0c             	pushl  0xc(%ebp)
8010131f:	50                   	push   %eax
80101320:	e8 bb 2f 00 00       	call   801042e0 <pipewrite>
80101325:	83 c4 10             	add    $0x10,%esp
80101328:	e9 f4 00 00 00       	jmp    80101421 <filewrite+0x137>
  if(f->type == FD_INODE){
8010132d:	8b 45 08             	mov    0x8(%ebp),%eax
80101330:	8b 00                	mov    (%eax),%eax
80101332:	83 f8 02             	cmp    $0x2,%eax
80101335:	0f 85 d9 00 00 00    	jne    80101414 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010133b:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101342:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101349:	e9 a3 00 00 00       	jmp    801013f1 <filewrite+0x107>
      int n1 = n - i;
8010134e:	8b 45 10             	mov    0x10(%ebp),%eax
80101351:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101354:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101357:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010135a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010135d:	7e 06                	jle    80101365 <filewrite+0x7b>
        n1 = max;
8010135f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101362:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101365:	e8 85 22 00 00       	call   801035ef <begin_op>
      ilock(f->ip);
8010136a:	8b 45 08             	mov    0x8(%ebp),%eax
8010136d:	8b 40 10             	mov    0x10(%eax),%eax
80101370:	83 ec 0c             	sub    $0xc,%esp
80101373:	50                   	push   %eax
80101374:	e8 93 06 00 00       	call   80101a0c <ilock>
80101379:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010137c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010137f:	8b 45 08             	mov    0x8(%ebp),%eax
80101382:	8b 50 14             	mov    0x14(%eax),%edx
80101385:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101388:	8b 45 0c             	mov    0xc(%ebp),%eax
8010138b:	01 c3                	add    %eax,%ebx
8010138d:	8b 45 08             	mov    0x8(%ebp),%eax
80101390:	8b 40 10             	mov    0x10(%eax),%eax
80101393:	51                   	push   %ecx
80101394:	52                   	push   %edx
80101395:	53                   	push   %ebx
80101396:	50                   	push   %eax
80101397:	e8 35 0d 00 00       	call   801020d1 <writei>
8010139c:	83 c4 10             	add    $0x10,%esp
8010139f:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013a2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013a6:	7e 11                	jle    801013b9 <filewrite+0xcf>
        f->off += r;
801013a8:	8b 45 08             	mov    0x8(%ebp),%eax
801013ab:	8b 50 14             	mov    0x14(%eax),%edx
801013ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013b1:	01 c2                	add    %eax,%edx
801013b3:	8b 45 08             	mov    0x8(%ebp),%eax
801013b6:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013b9:	8b 45 08             	mov    0x8(%ebp),%eax
801013bc:	8b 40 10             	mov    0x10(%eax),%eax
801013bf:	83 ec 0c             	sub    $0xc,%esp
801013c2:	50                   	push   %eax
801013c3:	e8 a2 07 00 00       	call   80101b6a <iunlock>
801013c8:	83 c4 10             	add    $0x10,%esp
      end_op();
801013cb:	e8 ab 22 00 00       	call   8010367b <end_op>

      if(r < 0)
801013d0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013d4:	78 29                	js     801013ff <filewrite+0x115>
        break;
      if(r != n1)
801013d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013d9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013dc:	74 0d                	je     801013eb <filewrite+0x101>
        panic("short filewrite");
801013de:	83 ec 0c             	sub    $0xc,%esp
801013e1:	68 34 93 10 80       	push   $0x80109334
801013e6:	e8 7b f1 ff ff       	call   80100566 <panic>
      i += r;
801013eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013ee:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801013f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f4:	3b 45 10             	cmp    0x10(%ebp),%eax
801013f7:	0f 8c 51 ff ff ff    	jl     8010134e <filewrite+0x64>
801013fd:	eb 01                	jmp    80101400 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
801013ff:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101403:	3b 45 10             	cmp    0x10(%ebp),%eax
80101406:	75 05                	jne    8010140d <filewrite+0x123>
80101408:	8b 45 10             	mov    0x10(%ebp),%eax
8010140b:	eb 14                	jmp    80101421 <filewrite+0x137>
8010140d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101412:	eb 0d                	jmp    80101421 <filewrite+0x137>
  }
  panic("filewrite");
80101414:	83 ec 0c             	sub    $0xc,%esp
80101417:	68 44 93 10 80       	push   $0x80109344
8010141c:	e8 45 f1 ff ff       	call   80100566 <panic>
}
80101421:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101424:	c9                   	leave  
80101425:	c3                   	ret    

80101426 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101426:	55                   	push   %ebp
80101427:	89 e5                	mov    %esp,%ebp
80101429:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010142c:	8b 45 08             	mov    0x8(%ebp),%eax
8010142f:	83 ec 08             	sub    $0x8,%esp
80101432:	6a 01                	push   $0x1
80101434:	50                   	push   %eax
80101435:	e8 7c ed ff ff       	call   801001b6 <bread>
8010143a:	83 c4 10             	add    $0x10,%esp
8010143d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101443:	83 c0 18             	add    $0x18,%eax
80101446:	83 ec 04             	sub    $0x4,%esp
80101449:	6a 1c                	push   $0x1c
8010144b:	50                   	push   %eax
8010144c:	ff 75 0c             	pushl  0xc(%ebp)
8010144f:	e8 db 4a 00 00       	call   80105f2f <memmove>
80101454:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101457:	83 ec 0c             	sub    $0xc,%esp
8010145a:	ff 75 f4             	pushl  -0xc(%ebp)
8010145d:	e8 cc ed ff ff       	call   8010022e <brelse>
80101462:	83 c4 10             	add    $0x10,%esp
}
80101465:	90                   	nop
80101466:	c9                   	leave  
80101467:	c3                   	ret    

80101468 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101468:	55                   	push   %ebp
80101469:	89 e5                	mov    %esp,%ebp
8010146b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010146e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101471:	8b 45 08             	mov    0x8(%ebp),%eax
80101474:	83 ec 08             	sub    $0x8,%esp
80101477:	52                   	push   %edx
80101478:	50                   	push   %eax
80101479:	e8 38 ed ff ff       	call   801001b6 <bread>
8010147e:	83 c4 10             	add    $0x10,%esp
80101481:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101487:	83 c0 18             	add    $0x18,%eax
8010148a:	83 ec 04             	sub    $0x4,%esp
8010148d:	68 00 02 00 00       	push   $0x200
80101492:	6a 00                	push   $0x0
80101494:	50                   	push   %eax
80101495:	e8 d6 49 00 00       	call   80105e70 <memset>
8010149a:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010149d:	83 ec 0c             	sub    $0xc,%esp
801014a0:	ff 75 f4             	pushl  -0xc(%ebp)
801014a3:	e8 7f 23 00 00       	call   80103827 <log_write>
801014a8:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014ab:	83 ec 0c             	sub    $0xc,%esp
801014ae:	ff 75 f4             	pushl  -0xc(%ebp)
801014b1:	e8 78 ed ff ff       	call   8010022e <brelse>
801014b6:	83 c4 10             	add    $0x10,%esp
}
801014b9:	90                   	nop
801014ba:	c9                   	leave  
801014bb:	c3                   	ret    

801014bc <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014bc:	55                   	push   %ebp
801014bd:	89 e5                	mov    %esp,%ebp
801014bf:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014c2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014d0:	e9 13 01 00 00       	jmp    801015e8 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
801014d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d8:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014de:	85 c0                	test   %eax,%eax
801014e0:	0f 48 c2             	cmovs  %edx,%eax
801014e3:	c1 f8 0c             	sar    $0xc,%eax
801014e6:	89 c2                	mov    %eax,%edx
801014e8:	a1 58 22 11 80       	mov    0x80112258,%eax
801014ed:	01 d0                	add    %edx,%eax
801014ef:	83 ec 08             	sub    $0x8,%esp
801014f2:	50                   	push   %eax
801014f3:	ff 75 08             	pushl  0x8(%ebp)
801014f6:	e8 bb ec ff ff       	call   801001b6 <bread>
801014fb:	83 c4 10             	add    $0x10,%esp
801014fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101501:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101508:	e9 a6 00 00 00       	jmp    801015b3 <balloc+0xf7>
      m = 1 << (bi % 8);
8010150d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101510:	99                   	cltd   
80101511:	c1 ea 1d             	shr    $0x1d,%edx
80101514:	01 d0                	add    %edx,%eax
80101516:	83 e0 07             	and    $0x7,%eax
80101519:	29 d0                	sub    %edx,%eax
8010151b:	ba 01 00 00 00       	mov    $0x1,%edx
80101520:	89 c1                	mov    %eax,%ecx
80101522:	d3 e2                	shl    %cl,%edx
80101524:	89 d0                	mov    %edx,%eax
80101526:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101529:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152c:	8d 50 07             	lea    0x7(%eax),%edx
8010152f:	85 c0                	test   %eax,%eax
80101531:	0f 48 c2             	cmovs  %edx,%eax
80101534:	c1 f8 03             	sar    $0x3,%eax
80101537:	89 c2                	mov    %eax,%edx
80101539:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010153c:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101541:	0f b6 c0             	movzbl %al,%eax
80101544:	23 45 e8             	and    -0x18(%ebp),%eax
80101547:	85 c0                	test   %eax,%eax
80101549:	75 64                	jne    801015af <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
8010154b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154e:	8d 50 07             	lea    0x7(%eax),%edx
80101551:	85 c0                	test   %eax,%eax
80101553:	0f 48 c2             	cmovs  %edx,%eax
80101556:	c1 f8 03             	sar    $0x3,%eax
80101559:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010155c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101561:	89 d1                	mov    %edx,%ecx
80101563:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101566:	09 ca                	or     %ecx,%edx
80101568:	89 d1                	mov    %edx,%ecx
8010156a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010156d:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101571:	83 ec 0c             	sub    $0xc,%esp
80101574:	ff 75 ec             	pushl  -0x14(%ebp)
80101577:	e8 ab 22 00 00       	call   80103827 <log_write>
8010157c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010157f:	83 ec 0c             	sub    $0xc,%esp
80101582:	ff 75 ec             	pushl  -0x14(%ebp)
80101585:	e8 a4 ec ff ff       	call   8010022e <brelse>
8010158a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010158d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101590:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101593:	01 c2                	add    %eax,%edx
80101595:	8b 45 08             	mov    0x8(%ebp),%eax
80101598:	83 ec 08             	sub    $0x8,%esp
8010159b:	52                   	push   %edx
8010159c:	50                   	push   %eax
8010159d:	e8 c6 fe ff ff       	call   80101468 <bzero>
801015a2:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ab:	01 d0                	add    %edx,%eax
801015ad:	eb 57                	jmp    80101606 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015af:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015b3:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015ba:	7f 17                	jg     801015d3 <balloc+0x117>
801015bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c2:	01 d0                	add    %edx,%eax
801015c4:	89 c2                	mov    %eax,%edx
801015c6:	a1 40 22 11 80       	mov    0x80112240,%eax
801015cb:	39 c2                	cmp    %eax,%edx
801015cd:	0f 82 3a ff ff ff    	jb     8010150d <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801015d3:	83 ec 0c             	sub    $0xc,%esp
801015d6:	ff 75 ec             	pushl  -0x14(%ebp)
801015d9:	e8 50 ec ff ff       	call   8010022e <brelse>
801015de:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801015e1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015e8:	8b 15 40 22 11 80    	mov    0x80112240,%edx
801015ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015f1:	39 c2                	cmp    %eax,%edx
801015f3:	0f 87 dc fe ff ff    	ja     801014d5 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801015f9:	83 ec 0c             	sub    $0xc,%esp
801015fc:	68 50 93 10 80       	push   $0x80109350
80101601:	e8 60 ef ff ff       	call   80100566 <panic>
}
80101606:	c9                   	leave  
80101607:	c3                   	ret    

80101608 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101608:	55                   	push   %ebp
80101609:	89 e5                	mov    %esp,%ebp
8010160b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010160e:	83 ec 08             	sub    $0x8,%esp
80101611:	68 40 22 11 80       	push   $0x80112240
80101616:	ff 75 08             	pushl  0x8(%ebp)
80101619:	e8 08 fe ff ff       	call   80101426 <readsb>
8010161e:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101621:	8b 45 0c             	mov    0xc(%ebp),%eax
80101624:	c1 e8 0c             	shr    $0xc,%eax
80101627:	89 c2                	mov    %eax,%edx
80101629:	a1 58 22 11 80       	mov    0x80112258,%eax
8010162e:	01 c2                	add    %eax,%edx
80101630:	8b 45 08             	mov    0x8(%ebp),%eax
80101633:	83 ec 08             	sub    $0x8,%esp
80101636:	52                   	push   %edx
80101637:	50                   	push   %eax
80101638:	e8 79 eb ff ff       	call   801001b6 <bread>
8010163d:	83 c4 10             	add    $0x10,%esp
80101640:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101643:	8b 45 0c             	mov    0xc(%ebp),%eax
80101646:	25 ff 0f 00 00       	and    $0xfff,%eax
8010164b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010164e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101651:	99                   	cltd   
80101652:	c1 ea 1d             	shr    $0x1d,%edx
80101655:	01 d0                	add    %edx,%eax
80101657:	83 e0 07             	and    $0x7,%eax
8010165a:	29 d0                	sub    %edx,%eax
8010165c:	ba 01 00 00 00       	mov    $0x1,%edx
80101661:	89 c1                	mov    %eax,%ecx
80101663:	d3 e2                	shl    %cl,%edx
80101665:	89 d0                	mov    %edx,%eax
80101667:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010166a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010166d:	8d 50 07             	lea    0x7(%eax),%edx
80101670:	85 c0                	test   %eax,%eax
80101672:	0f 48 c2             	cmovs  %edx,%eax
80101675:	c1 f8 03             	sar    $0x3,%eax
80101678:	89 c2                	mov    %eax,%edx
8010167a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167d:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101682:	0f b6 c0             	movzbl %al,%eax
80101685:	23 45 ec             	and    -0x14(%ebp),%eax
80101688:	85 c0                	test   %eax,%eax
8010168a:	75 0d                	jne    80101699 <bfree+0x91>
    panic("freeing free block");
8010168c:	83 ec 0c             	sub    $0xc,%esp
8010168f:	68 66 93 10 80       	push   $0x80109366
80101694:	e8 cd ee ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
80101699:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010169c:	8d 50 07             	lea    0x7(%eax),%edx
8010169f:	85 c0                	test   %eax,%eax
801016a1:	0f 48 c2             	cmovs  %edx,%eax
801016a4:	c1 f8 03             	sar    $0x3,%eax
801016a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016aa:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801016af:	89 d1                	mov    %edx,%ecx
801016b1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016b4:	f7 d2                	not    %edx
801016b6:	21 ca                	and    %ecx,%edx
801016b8:	89 d1                	mov    %edx,%ecx
801016ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016bd:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801016c1:	83 ec 0c             	sub    $0xc,%esp
801016c4:	ff 75 f4             	pushl  -0xc(%ebp)
801016c7:	e8 5b 21 00 00       	call   80103827 <log_write>
801016cc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016cf:	83 ec 0c             	sub    $0xc,%esp
801016d2:	ff 75 f4             	pushl  -0xc(%ebp)
801016d5:	e8 54 eb ff ff       	call   8010022e <brelse>
801016da:	83 c4 10             	add    $0x10,%esp
}
801016dd:	90                   	nop
801016de:	c9                   	leave  
801016df:	c3                   	ret    

801016e0 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016e0:	55                   	push   %ebp
801016e1:	89 e5                	mov    %esp,%ebp
801016e3:	57                   	push   %edi
801016e4:	56                   	push   %esi
801016e5:	53                   	push   %ebx
801016e6:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
801016e9:	83 ec 08             	sub    $0x8,%esp
801016ec:	68 79 93 10 80       	push   $0x80109379
801016f1:	68 60 22 11 80       	push   $0x80112260
801016f6:	e8 f0 44 00 00       	call   80105beb <initlock>
801016fb:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801016fe:	83 ec 08             	sub    $0x8,%esp
80101701:	68 40 22 11 80       	push   $0x80112240
80101706:	ff 75 08             	pushl  0x8(%ebp)
80101709:	e8 18 fd ff ff       	call   80101426 <readsb>
8010170e:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101711:	a1 58 22 11 80       	mov    0x80112258,%eax
80101716:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101719:	8b 3d 54 22 11 80    	mov    0x80112254,%edi
8010171f:	8b 35 50 22 11 80    	mov    0x80112250,%esi
80101725:	8b 1d 4c 22 11 80    	mov    0x8011224c,%ebx
8010172b:	8b 0d 48 22 11 80    	mov    0x80112248,%ecx
80101731:	8b 15 44 22 11 80    	mov    0x80112244,%edx
80101737:	a1 40 22 11 80       	mov    0x80112240,%eax
8010173c:	ff 75 e4             	pushl  -0x1c(%ebp)
8010173f:	57                   	push   %edi
80101740:	56                   	push   %esi
80101741:	53                   	push   %ebx
80101742:	51                   	push   %ecx
80101743:	52                   	push   %edx
80101744:	50                   	push   %eax
80101745:	68 80 93 10 80       	push   $0x80109380
8010174a:	e8 77 ec ff ff       	call   801003c6 <cprintf>
8010174f:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101752:	90                   	nop
80101753:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101756:	5b                   	pop    %ebx
80101757:	5e                   	pop    %esi
80101758:	5f                   	pop    %edi
80101759:	5d                   	pop    %ebp
8010175a:	c3                   	ret    

8010175b <ialloc>:

// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
8010175b:	55                   	push   %ebp
8010175c:	89 e5                	mov    %esp,%ebp
8010175e:	83 ec 28             	sub    $0x28,%esp
80101761:	8b 45 0c             	mov    0xc(%ebp),%eax
80101764:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101768:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010176f:	e9 9e 00 00 00       	jmp    80101812 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101777:	c1 e8 03             	shr    $0x3,%eax
8010177a:	89 c2                	mov    %eax,%edx
8010177c:	a1 54 22 11 80       	mov    0x80112254,%eax
80101781:	01 d0                	add    %edx,%eax
80101783:	83 ec 08             	sub    $0x8,%esp
80101786:	50                   	push   %eax
80101787:	ff 75 08             	pushl  0x8(%ebp)
8010178a:	e8 27 ea ff ff       	call   801001b6 <bread>
8010178f:	83 c4 10             	add    $0x10,%esp
80101792:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101795:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101798:	8d 50 18             	lea    0x18(%eax),%edx
8010179b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179e:	83 e0 07             	and    $0x7,%eax
801017a1:	c1 e0 06             	shl    $0x6,%eax
801017a4:	01 d0                	add    %edx,%eax
801017a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017ac:	0f b7 00             	movzwl (%eax),%eax
801017af:	66 85 c0             	test   %ax,%ax
801017b2:	75 4c                	jne    80101800 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017b4:	83 ec 04             	sub    $0x4,%esp
801017b7:	6a 40                	push   $0x40
801017b9:	6a 00                	push   $0x0
801017bb:	ff 75 ec             	pushl  -0x14(%ebp)
801017be:	e8 ad 46 00 00       	call   80105e70 <memset>
801017c3:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017c9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017cd:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017d0:	83 ec 0c             	sub    $0xc,%esp
801017d3:	ff 75 f0             	pushl  -0x10(%ebp)
801017d6:	e8 4c 20 00 00       	call   80103827 <log_write>
801017db:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017de:	83 ec 0c             	sub    $0xc,%esp
801017e1:	ff 75 f0             	pushl  -0x10(%ebp)
801017e4:	e8 45 ea ff ff       	call   8010022e <brelse>
801017e9:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ef:	83 ec 08             	sub    $0x8,%esp
801017f2:	50                   	push   %eax
801017f3:	ff 75 08             	pushl  0x8(%ebp)
801017f6:	e8 f8 00 00 00       	call   801018f3 <iget>
801017fb:	83 c4 10             	add    $0x10,%esp
801017fe:	eb 30                	jmp    80101830 <ialloc+0xd5>
    }
    brelse(bp);
80101800:	83 ec 0c             	sub    $0xc,%esp
80101803:	ff 75 f0             	pushl  -0x10(%ebp)
80101806:	e8 23 ea ff ff       	call   8010022e <brelse>
8010180b:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010180e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101812:	8b 15 48 22 11 80    	mov    0x80112248,%edx
80101818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181b:	39 c2                	cmp    %eax,%edx
8010181d:	0f 87 51 ff ff ff    	ja     80101774 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101823:	83 ec 0c             	sub    $0xc,%esp
80101826:	68 d3 93 10 80       	push   $0x801093d3
8010182b:	e8 36 ed ff ff       	call   80100566 <panic>
}
80101830:	c9                   	leave  
80101831:	c3                   	ret    

80101832 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101832:	55                   	push   %ebp
80101833:	89 e5                	mov    %esp,%ebp
80101835:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101838:	8b 45 08             	mov    0x8(%ebp),%eax
8010183b:	8b 40 04             	mov    0x4(%eax),%eax
8010183e:	c1 e8 03             	shr    $0x3,%eax
80101841:	89 c2                	mov    %eax,%edx
80101843:	a1 54 22 11 80       	mov    0x80112254,%eax
80101848:	01 c2                	add    %eax,%edx
8010184a:	8b 45 08             	mov    0x8(%ebp),%eax
8010184d:	8b 00                	mov    (%eax),%eax
8010184f:	83 ec 08             	sub    $0x8,%esp
80101852:	52                   	push   %edx
80101853:	50                   	push   %eax
80101854:	e8 5d e9 ff ff       	call   801001b6 <bread>
80101859:	83 c4 10             	add    $0x10,%esp
8010185c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010185f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101862:	8d 50 18             	lea    0x18(%eax),%edx
80101865:	8b 45 08             	mov    0x8(%ebp),%eax
80101868:	8b 40 04             	mov    0x4(%eax),%eax
8010186b:	83 e0 07             	and    $0x7,%eax
8010186e:	c1 e0 06             	shl    $0x6,%eax
80101871:	01 d0                	add    %edx,%eax
80101873:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101876:	8b 45 08             	mov    0x8(%ebp),%eax
80101879:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010187d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101880:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101883:	8b 45 08             	mov    0x8(%ebp),%eax
80101886:	0f b7 50 12          	movzwl 0x12(%eax),%edx
8010188a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188d:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101891:	8b 45 08             	mov    0x8(%ebp),%eax
80101894:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101898:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189b:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010189f:	8b 45 08             	mov    0x8(%ebp),%eax
801018a2:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801018a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a9:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018ad:	8b 45 08             	mov    0x8(%ebp),%eax
801018b0:	8b 50 18             	mov    0x18(%eax),%edx
801018b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b6:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018b9:	8b 45 08             	mov    0x8(%ebp),%eax
801018bc:	8d 50 1c             	lea    0x1c(%eax),%edx
801018bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c2:	83 c0 0c             	add    $0xc,%eax
801018c5:	83 ec 04             	sub    $0x4,%esp
801018c8:	6a 34                	push   $0x34
801018ca:	52                   	push   %edx
801018cb:	50                   	push   %eax
801018cc:	e8 5e 46 00 00       	call   80105f2f <memmove>
801018d1:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018d4:	83 ec 0c             	sub    $0xc,%esp
801018d7:	ff 75 f4             	pushl  -0xc(%ebp)
801018da:	e8 48 1f 00 00       	call   80103827 <log_write>
801018df:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018e2:	83 ec 0c             	sub    $0xc,%esp
801018e5:	ff 75 f4             	pushl  -0xc(%ebp)
801018e8:	e8 41 e9 ff ff       	call   8010022e <brelse>
801018ed:	83 c4 10             	add    $0x10,%esp
}
801018f0:	90                   	nop
801018f1:	c9                   	leave  
801018f2:	c3                   	ret    

801018f3 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018f3:	55                   	push   %ebp
801018f4:	89 e5                	mov    %esp,%ebp
801018f6:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018f9:	83 ec 0c             	sub    $0xc,%esp
801018fc:	68 60 22 11 80       	push   $0x80112260
80101901:	e8 07 43 00 00       	call   80105c0d <acquire>
80101906:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101909:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101910:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
80101917:	eb 5d                	jmp    80101976 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191c:	8b 40 08             	mov    0x8(%eax),%eax
8010191f:	85 c0                	test   %eax,%eax
80101921:	7e 39                	jle    8010195c <iget+0x69>
80101923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101926:	8b 00                	mov    (%eax),%eax
80101928:	3b 45 08             	cmp    0x8(%ebp),%eax
8010192b:	75 2f                	jne    8010195c <iget+0x69>
8010192d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101930:	8b 40 04             	mov    0x4(%eax),%eax
80101933:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101936:	75 24                	jne    8010195c <iget+0x69>
      ip->ref++;
80101938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193b:	8b 40 08             	mov    0x8(%eax),%eax
8010193e:	8d 50 01             	lea    0x1(%eax),%edx
80101941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101944:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101947:	83 ec 0c             	sub    $0xc,%esp
8010194a:	68 60 22 11 80       	push   $0x80112260
8010194f:	e8 20 43 00 00       	call   80105c74 <release>
80101954:	83 c4 10             	add    $0x10,%esp
      return ip;
80101957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010195a:	eb 74                	jmp    801019d0 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010195c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101960:	75 10                	jne    80101972 <iget+0x7f>
80101962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101965:	8b 40 08             	mov    0x8(%eax),%eax
80101968:	85 c0                	test   %eax,%eax
8010196a:	75 06                	jne    80101972 <iget+0x7f>
      empty = ip;
8010196c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101972:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101976:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
8010197d:	72 9a                	jb     80101919 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010197f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101983:	75 0d                	jne    80101992 <iget+0x9f>
    panic("iget: no inodes");
80101985:	83 ec 0c             	sub    $0xc,%esp
80101988:	68 e5 93 10 80       	push   $0x801093e5
8010198d:	e8 d4 eb ff ff       	call   80100566 <panic>

  ip = empty;
80101992:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101995:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199b:	8b 55 08             	mov    0x8(%ebp),%edx
8010199e:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a3:	8b 55 0c             	mov    0xc(%ebp),%edx
801019a6:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801019bd:	83 ec 0c             	sub    $0xc,%esp
801019c0:	68 60 22 11 80       	push   $0x80112260
801019c5:	e8 aa 42 00 00       	call   80105c74 <release>
801019ca:	83 c4 10             	add    $0x10,%esp

  return ip;
801019cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019d0:	c9                   	leave  
801019d1:	c3                   	ret    

801019d2 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019d2:	55                   	push   %ebp
801019d3:	89 e5                	mov    %esp,%ebp
801019d5:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019d8:	83 ec 0c             	sub    $0xc,%esp
801019db:	68 60 22 11 80       	push   $0x80112260
801019e0:	e8 28 42 00 00       	call   80105c0d <acquire>
801019e5:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019e8:	8b 45 08             	mov    0x8(%ebp),%eax
801019eb:	8b 40 08             	mov    0x8(%eax),%eax
801019ee:	8d 50 01             	lea    0x1(%eax),%edx
801019f1:	8b 45 08             	mov    0x8(%ebp),%eax
801019f4:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019f7:	83 ec 0c             	sub    $0xc,%esp
801019fa:	68 60 22 11 80       	push   $0x80112260
801019ff:	e8 70 42 00 00       	call   80105c74 <release>
80101a04:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a07:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a0a:	c9                   	leave  
80101a0b:	c3                   	ret    

80101a0c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a0c:	55                   	push   %ebp
80101a0d:	89 e5                	mov    %esp,%ebp
80101a0f:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a16:	74 0a                	je     80101a22 <ilock+0x16>
80101a18:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1b:	8b 40 08             	mov    0x8(%eax),%eax
80101a1e:	85 c0                	test   %eax,%eax
80101a20:	7f 0d                	jg     80101a2f <ilock+0x23>
    panic("ilock");
80101a22:	83 ec 0c             	sub    $0xc,%esp
80101a25:	68 f5 93 10 80       	push   $0x801093f5
80101a2a:	e8 37 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a2f:	83 ec 0c             	sub    $0xc,%esp
80101a32:	68 60 22 11 80       	push   $0x80112260
80101a37:	e8 d1 41 00 00       	call   80105c0d <acquire>
80101a3c:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a3f:	eb 13                	jmp    80101a54 <ilock+0x48>
    sleep(ip, &icache.lock);
80101a41:	83 ec 08             	sub    $0x8,%esp
80101a44:	68 60 22 11 80       	push   $0x80112260
80101a49:	ff 75 08             	pushl  0x8(%ebp)
80101a4c:	e8 83 36 00 00       	call   801050d4 <sleep>
80101a51:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101a54:	8b 45 08             	mov    0x8(%ebp),%eax
80101a57:	8b 40 0c             	mov    0xc(%eax),%eax
80101a5a:	83 e0 01             	and    $0x1,%eax
80101a5d:	85 c0                	test   %eax,%eax
80101a5f:	75 e0                	jne    80101a41 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101a61:	8b 45 08             	mov    0x8(%ebp),%eax
80101a64:	8b 40 0c             	mov    0xc(%eax),%eax
80101a67:	83 c8 01             	or     $0x1,%eax
80101a6a:	89 c2                	mov    %eax,%edx
80101a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6f:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101a72:	83 ec 0c             	sub    $0xc,%esp
80101a75:	68 60 22 11 80       	push   $0x80112260
80101a7a:	e8 f5 41 00 00       	call   80105c74 <release>
80101a7f:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101a82:	8b 45 08             	mov    0x8(%ebp),%eax
80101a85:	8b 40 0c             	mov    0xc(%eax),%eax
80101a88:	83 e0 02             	and    $0x2,%eax
80101a8b:	85 c0                	test   %eax,%eax
80101a8d:	0f 85 d4 00 00 00    	jne    80101b67 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a93:	8b 45 08             	mov    0x8(%ebp),%eax
80101a96:	8b 40 04             	mov    0x4(%eax),%eax
80101a99:	c1 e8 03             	shr    $0x3,%eax
80101a9c:	89 c2                	mov    %eax,%edx
80101a9e:	a1 54 22 11 80       	mov    0x80112254,%eax
80101aa3:	01 c2                	add    %eax,%edx
80101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa8:	8b 00                	mov    (%eax),%eax
80101aaa:	83 ec 08             	sub    $0x8,%esp
80101aad:	52                   	push   %edx
80101aae:	50                   	push   %eax
80101aaf:	e8 02 e7 ff ff       	call   801001b6 <bread>
80101ab4:	83 c4 10             	add    $0x10,%esp
80101ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101abd:	8d 50 18             	lea    0x18(%eax),%edx
80101ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac3:	8b 40 04             	mov    0x4(%eax),%eax
80101ac6:	83 e0 07             	and    $0x7,%eax
80101ac9:	c1 e0 06             	shl    $0x6,%eax
80101acc:	01 d0                	add    %edx,%eax
80101ace:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad4:	0f b7 10             	movzwl (%eax),%edx
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae1:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101aec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aef:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101af3:	8b 45 08             	mov    0x8(%ebp),%eax
80101af6:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101afd:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b01:	8b 45 08             	mov    0x8(%ebp),%eax
80101b04:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b0b:	8b 50 08             	mov    0x8(%eax),%edx
80101b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b11:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b17:	8d 50 0c             	lea    0xc(%eax),%edx
80101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1d:	83 c0 1c             	add    $0x1c,%eax
80101b20:	83 ec 04             	sub    $0x4,%esp
80101b23:	6a 34                	push   $0x34
80101b25:	52                   	push   %edx
80101b26:	50                   	push   %eax
80101b27:	e8 03 44 00 00       	call   80105f2f <memmove>
80101b2c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b2f:	83 ec 0c             	sub    $0xc,%esp
80101b32:	ff 75 f4             	pushl  -0xc(%ebp)
80101b35:	e8 f4 e6 ff ff       	call   8010022e <brelse>
80101b3a:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b40:	8b 40 0c             	mov    0xc(%eax),%eax
80101b43:	83 c8 02             	or     $0x2,%eax
80101b46:	89 c2                	mov    %eax,%edx
80101b48:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4b:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b51:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101b55:	66 85 c0             	test   %ax,%ax
80101b58:	75 0d                	jne    80101b67 <ilock+0x15b>
      panic("ilock: no type");
80101b5a:	83 ec 0c             	sub    $0xc,%esp
80101b5d:	68 fb 93 10 80       	push   $0x801093fb
80101b62:	e8 ff e9 ff ff       	call   80100566 <panic>
  }
}
80101b67:	90                   	nop
80101b68:	c9                   	leave  
80101b69:	c3                   	ret    

80101b6a <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b6a:	55                   	push   %ebp
80101b6b:	89 e5                	mov    %esp,%ebp
80101b6d:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101b70:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b74:	74 17                	je     80101b8d <iunlock+0x23>
80101b76:	8b 45 08             	mov    0x8(%ebp),%eax
80101b79:	8b 40 0c             	mov    0xc(%eax),%eax
80101b7c:	83 e0 01             	and    $0x1,%eax
80101b7f:	85 c0                	test   %eax,%eax
80101b81:	74 0a                	je     80101b8d <iunlock+0x23>
80101b83:	8b 45 08             	mov    0x8(%ebp),%eax
80101b86:	8b 40 08             	mov    0x8(%eax),%eax
80101b89:	85 c0                	test   %eax,%eax
80101b8b:	7f 0d                	jg     80101b9a <iunlock+0x30>
    panic("iunlock");
80101b8d:	83 ec 0c             	sub    $0xc,%esp
80101b90:	68 0a 94 10 80       	push   $0x8010940a
80101b95:	e8 cc e9 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 22 11 80       	push   $0x80112260
80101ba2:	e8 66 40 00 00       	call   80105c0d <acquire>
80101ba7:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101baa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bad:	8b 40 0c             	mov    0xc(%eax),%eax
80101bb0:	83 e0 fe             	and    $0xfffffffe,%eax
80101bb3:	89 c2                	mov    %eax,%edx
80101bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb8:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101bbb:	83 ec 0c             	sub    $0xc,%esp
80101bbe:	ff 75 08             	pushl  0x8(%ebp)
80101bc1:	e8 2b 36 00 00       	call   801051f1 <wakeup>
80101bc6:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101bc9:	83 ec 0c             	sub    $0xc,%esp
80101bcc:	68 60 22 11 80       	push   $0x80112260
80101bd1:	e8 9e 40 00 00       	call   80105c74 <release>
80101bd6:	83 c4 10             	add    $0x10,%esp
}
80101bd9:	90                   	nop
80101bda:	c9                   	leave  
80101bdb:	c3                   	ret    

80101bdc <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bdc:	55                   	push   %ebp
80101bdd:	89 e5                	mov    %esp,%ebp
80101bdf:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101be2:	83 ec 0c             	sub    $0xc,%esp
80101be5:	68 60 22 11 80       	push   $0x80112260
80101bea:	e8 1e 40 00 00       	call   80105c0d <acquire>
80101bef:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf5:	8b 40 08             	mov    0x8(%eax),%eax
80101bf8:	83 f8 01             	cmp    $0x1,%eax
80101bfb:	0f 85 a9 00 00 00    	jne    80101caa <iput+0xce>
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 0c             	mov    0xc(%eax),%eax
80101c07:	83 e0 02             	and    $0x2,%eax
80101c0a:	85 c0                	test   %eax,%eax
80101c0c:	0f 84 98 00 00 00    	je     80101caa <iput+0xce>
80101c12:	8b 45 08             	mov    0x8(%ebp),%eax
80101c15:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101c19:	66 85 c0             	test   %ax,%ax
80101c1c:	0f 85 88 00 00 00    	jne    80101caa <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101c22:	8b 45 08             	mov    0x8(%ebp),%eax
80101c25:	8b 40 0c             	mov    0xc(%eax),%eax
80101c28:	83 e0 01             	and    $0x1,%eax
80101c2b:	85 c0                	test   %eax,%eax
80101c2d:	74 0d                	je     80101c3c <iput+0x60>
      panic("iput busy");
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	68 12 94 10 80       	push   $0x80109412
80101c37:	e8 2a e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3f:	8b 40 0c             	mov    0xc(%eax),%eax
80101c42:	83 c8 01             	or     $0x1,%eax
80101c45:	89 c2                	mov    %eax,%edx
80101c47:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4a:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101c4d:	83 ec 0c             	sub    $0xc,%esp
80101c50:	68 60 22 11 80       	push   $0x80112260
80101c55:	e8 1a 40 00 00       	call   80105c74 <release>
80101c5a:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	ff 75 08             	pushl  0x8(%ebp)
80101c63:	e8 a8 01 00 00       	call   80101e10 <itrunc>
80101c68:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6e:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101c74:	83 ec 0c             	sub    $0xc,%esp
80101c77:	ff 75 08             	pushl  0x8(%ebp)
80101c7a:	e8 b3 fb ff ff       	call   80101832 <iupdate>
80101c7f:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101c82:	83 ec 0c             	sub    $0xc,%esp
80101c85:	68 60 22 11 80       	push   $0x80112260
80101c8a:	e8 7e 3f 00 00       	call   80105c0d <acquire>
80101c8f:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c92:	8b 45 08             	mov    0x8(%ebp),%eax
80101c95:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c9c:	83 ec 0c             	sub    $0xc,%esp
80101c9f:	ff 75 08             	pushl  0x8(%ebp)
80101ca2:	e8 4a 35 00 00       	call   801051f1 <wakeup>
80101ca7:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101caa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cad:	8b 40 08             	mov    0x8(%eax),%eax
80101cb0:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb6:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb9:	83 ec 0c             	sub    $0xc,%esp
80101cbc:	68 60 22 11 80       	push   $0x80112260
80101cc1:	e8 ae 3f 00 00       	call   80105c74 <release>
80101cc6:	83 c4 10             	add    $0x10,%esp
}
80101cc9:	90                   	nop
80101cca:	c9                   	leave  
80101ccb:	c3                   	ret    

80101ccc <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101ccc:	55                   	push   %ebp
80101ccd:	89 e5                	mov    %esp,%ebp
80101ccf:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cd2:	83 ec 0c             	sub    $0xc,%esp
80101cd5:	ff 75 08             	pushl  0x8(%ebp)
80101cd8:	e8 8d fe ff ff       	call   80101b6a <iunlock>
80101cdd:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101ce0:	83 ec 0c             	sub    $0xc,%esp
80101ce3:	ff 75 08             	pushl  0x8(%ebp)
80101ce6:	e8 f1 fe ff ff       	call   80101bdc <iput>
80101ceb:	83 c4 10             	add    $0x10,%esp
}
80101cee:	90                   	nop
80101cef:	c9                   	leave  
80101cf0:	c3                   	ret    

80101cf1 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cf1:	55                   	push   %ebp
80101cf2:	89 e5                	mov    %esp,%ebp
80101cf4:	53                   	push   %ebx
80101cf5:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cf8:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cfc:	77 42                	ja     80101d40 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101d01:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d04:	83 c2 04             	add    $0x4,%edx
80101d07:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d12:	75 24                	jne    80101d38 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d14:	8b 45 08             	mov    0x8(%ebp),%eax
80101d17:	8b 00                	mov    (%eax),%eax
80101d19:	83 ec 0c             	sub    $0xc,%esp
80101d1c:	50                   	push   %eax
80101d1d:	e8 9a f7 ff ff       	call   801014bc <balloc>
80101d22:	83 c4 10             	add    $0x10,%esp
80101d25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d28:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d2e:	8d 4a 04             	lea    0x4(%edx),%ecx
80101d31:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d34:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d3b:	e9 cb 00 00 00       	jmp    80101e0b <bmap+0x11a>
  }
  bn -= NDIRECT;
80101d40:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d44:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d48:	0f 87 b0 00 00 00    	ja     80101dfe <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d51:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d5b:	75 1d                	jne    80101d7a <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d60:	8b 00                	mov    (%eax),%eax
80101d62:	83 ec 0c             	sub    $0xc,%esp
80101d65:	50                   	push   %eax
80101d66:	e8 51 f7 ff ff       	call   801014bc <balloc>
80101d6b:	83 c4 10             	add    $0x10,%esp
80101d6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d71:	8b 45 08             	mov    0x8(%ebp),%eax
80101d74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d77:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7d:	8b 00                	mov    (%eax),%eax
80101d7f:	83 ec 08             	sub    $0x8,%esp
80101d82:	ff 75 f4             	pushl  -0xc(%ebp)
80101d85:	50                   	push   %eax
80101d86:	e8 2b e4 ff ff       	call   801001b6 <bread>
80101d8b:	83 c4 10             	add    $0x10,%esp
80101d8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d94:	83 c0 18             	add    $0x18,%eax
80101d97:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d9d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101da4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101da7:	01 d0                	add    %edx,%eax
80101da9:	8b 00                	mov    (%eax),%eax
80101dab:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101db2:	75 37                	jne    80101deb <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101db4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dc1:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101dc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc7:	8b 00                	mov    (%eax),%eax
80101dc9:	83 ec 0c             	sub    $0xc,%esp
80101dcc:	50                   	push   %eax
80101dcd:	e8 ea f6 ff ff       	call   801014bc <balloc>
80101dd2:	83 c4 10             	add    $0x10,%esp
80101dd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ddb:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101ddd:	83 ec 0c             	sub    $0xc,%esp
80101de0:	ff 75 f0             	pushl  -0x10(%ebp)
80101de3:	e8 3f 1a 00 00       	call   80103827 <log_write>
80101de8:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101deb:	83 ec 0c             	sub    $0xc,%esp
80101dee:	ff 75 f0             	pushl  -0x10(%ebp)
80101df1:	e8 38 e4 ff ff       	call   8010022e <brelse>
80101df6:	83 c4 10             	add    $0x10,%esp
    return addr;
80101df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dfc:	eb 0d                	jmp    80101e0b <bmap+0x11a>
  }

  panic("bmap: out of range");
80101dfe:	83 ec 0c             	sub    $0xc,%esp
80101e01:	68 1c 94 10 80       	push   $0x8010941c
80101e06:	e8 5b e7 ff ff       	call   80100566 <panic>
}
80101e0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e0e:	c9                   	leave  
80101e0f:	c3                   	ret    

80101e10 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e10:	55                   	push   %ebp
80101e11:	89 e5                	mov    %esp,%ebp
80101e13:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e1d:	eb 45                	jmp    80101e64 <itrunc+0x54>
    if(ip->addrs[i]){
80101e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e22:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e25:	83 c2 04             	add    $0x4,%edx
80101e28:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e2c:	85 c0                	test   %eax,%eax
80101e2e:	74 30                	je     80101e60 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101e30:	8b 45 08             	mov    0x8(%ebp),%eax
80101e33:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e36:	83 c2 04             	add    $0x4,%edx
80101e39:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e3d:	8b 55 08             	mov    0x8(%ebp),%edx
80101e40:	8b 12                	mov    (%edx),%edx
80101e42:	83 ec 08             	sub    $0x8,%esp
80101e45:	50                   	push   %eax
80101e46:	52                   	push   %edx
80101e47:	e8 bc f7 ff ff       	call   80101608 <bfree>
80101e4c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e55:	83 c2 04             	add    $0x4,%edx
80101e58:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e5f:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e60:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e64:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e68:	7e b5                	jle    80101e1f <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6d:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e70:	85 c0                	test   %eax,%eax
80101e72:	0f 84 a1 00 00 00    	je     80101f19 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e78:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7b:	8b 50 4c             	mov    0x4c(%eax),%edx
80101e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e81:	8b 00                	mov    (%eax),%eax
80101e83:	83 ec 08             	sub    $0x8,%esp
80101e86:	52                   	push   %edx
80101e87:	50                   	push   %eax
80101e88:	e8 29 e3 ff ff       	call   801001b6 <bread>
80101e8d:	83 c4 10             	add    $0x10,%esp
80101e90:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e96:	83 c0 18             	add    $0x18,%eax
80101e99:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e9c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ea3:	eb 3c                	jmp    80101ee1 <itrunc+0xd1>
      if(a[j])
80101ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eb2:	01 d0                	add    %edx,%eax
80101eb4:	8b 00                	mov    (%eax),%eax
80101eb6:	85 c0                	test   %eax,%eax
80101eb8:	74 23                	je     80101edd <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ec4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ec7:	01 d0                	add    %edx,%eax
80101ec9:	8b 00                	mov    (%eax),%eax
80101ecb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ece:	8b 12                	mov    (%edx),%edx
80101ed0:	83 ec 08             	sub    $0x8,%esp
80101ed3:	50                   	push   %eax
80101ed4:	52                   	push   %edx
80101ed5:	e8 2e f7 ff ff       	call   80101608 <bfree>
80101eda:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101edd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee4:	83 f8 7f             	cmp    $0x7f,%eax
80101ee7:	76 bc                	jbe    80101ea5 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ee9:	83 ec 0c             	sub    $0xc,%esp
80101eec:	ff 75 ec             	pushl  -0x14(%ebp)
80101eef:	e8 3a e3 ff ff       	call   8010022e <brelse>
80101ef4:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 40 4c             	mov    0x4c(%eax),%eax
80101efd:	8b 55 08             	mov    0x8(%ebp),%edx
80101f00:	8b 12                	mov    (%edx),%edx
80101f02:	83 ec 08             	sub    $0x8,%esp
80101f05:	50                   	push   %eax
80101f06:	52                   	push   %edx
80101f07:	e8 fc f6 ff ff       	call   80101608 <bfree>
80101f0c:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f12:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101f19:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1c:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101f23:	83 ec 0c             	sub    $0xc,%esp
80101f26:	ff 75 08             	pushl  0x8(%ebp)
80101f29:	e8 04 f9 ff ff       	call   80101832 <iupdate>
80101f2e:	83 c4 10             	add    $0x10,%esp
}
80101f31:	90                   	nop
80101f32:	c9                   	leave  
80101f33:	c3                   	ret    

80101f34 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101f34:	55                   	push   %ebp
80101f35:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f37:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3a:	8b 00                	mov    (%eax),%eax
80101f3c:	89 c2                	mov    %eax,%edx
80101f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f41:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f44:	8b 45 08             	mov    0x8(%ebp),%eax
80101f47:	8b 50 04             	mov    0x4(%eax),%edx
80101f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f4d:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f50:	8b 45 08             	mov    0x8(%ebp),%eax
80101f53:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101f57:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f5a:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f60:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101f64:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f67:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6e:	8b 50 18             	mov    0x18(%eax),%edx
80101f71:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f74:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f77:	90                   	nop
80101f78:	5d                   	pop    %ebp
80101f79:	c3                   	ret    

80101f7a <readi>:

// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f7a:	55                   	push   %ebp
80101f7b:	89 e5                	mov    %esp,%ebp
80101f7d:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f80:	8b 45 08             	mov    0x8(%ebp),%eax
80101f83:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f87:	66 83 f8 03          	cmp    $0x3,%ax
80101f8b:	75 5c                	jne    80101fe9 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f90:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f94:	66 85 c0             	test   %ax,%ax
80101f97:	78 20                	js     80101fb9 <readi+0x3f>
80101f99:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fa0:	66 83 f8 09          	cmp    $0x9,%ax
80101fa4:	7f 13                	jg     80101fb9 <readi+0x3f>
80101fa6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fad:	98                   	cwtl   
80101fae:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101fb5:	85 c0                	test   %eax,%eax
80101fb7:	75 0a                	jne    80101fc3 <readi+0x49>
      return -1;
80101fb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fbe:	e9 0c 01 00 00       	jmp    801020cf <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fca:	98                   	cwtl   
80101fcb:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101fd2:	8b 55 14             	mov    0x14(%ebp),%edx
80101fd5:	83 ec 04             	sub    $0x4,%esp
80101fd8:	52                   	push   %edx
80101fd9:	ff 75 0c             	pushl  0xc(%ebp)
80101fdc:	ff 75 08             	pushl  0x8(%ebp)
80101fdf:	ff d0                	call   *%eax
80101fe1:	83 c4 10             	add    $0x10,%esp
80101fe4:	e9 e6 00 00 00       	jmp    801020cf <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fec:	8b 40 18             	mov    0x18(%eax),%eax
80101fef:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ff2:	72 0d                	jb     80102001 <readi+0x87>
80101ff4:	8b 55 10             	mov    0x10(%ebp),%edx
80101ff7:	8b 45 14             	mov    0x14(%ebp),%eax
80101ffa:	01 d0                	add    %edx,%eax
80101ffc:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fff:	73 0a                	jae    8010200b <readi+0x91>
    return -1;
80102001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102006:	e9 c4 00 00 00       	jmp    801020cf <readi+0x155>
  if(off + n > ip->size)
8010200b:	8b 55 10             	mov    0x10(%ebp),%edx
8010200e:	8b 45 14             	mov    0x14(%ebp),%eax
80102011:	01 c2                	add    %eax,%edx
80102013:	8b 45 08             	mov    0x8(%ebp),%eax
80102016:	8b 40 18             	mov    0x18(%eax),%eax
80102019:	39 c2                	cmp    %eax,%edx
8010201b:	76 0c                	jbe    80102029 <readi+0xaf>
    n = ip->size - off;
8010201d:	8b 45 08             	mov    0x8(%ebp),%eax
80102020:	8b 40 18             	mov    0x18(%eax),%eax
80102023:	2b 45 10             	sub    0x10(%ebp),%eax
80102026:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102029:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102030:	e9 8b 00 00 00       	jmp    801020c0 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102035:	8b 45 10             	mov    0x10(%ebp),%eax
80102038:	c1 e8 09             	shr    $0x9,%eax
8010203b:	83 ec 08             	sub    $0x8,%esp
8010203e:	50                   	push   %eax
8010203f:	ff 75 08             	pushl  0x8(%ebp)
80102042:	e8 aa fc ff ff       	call   80101cf1 <bmap>
80102047:	83 c4 10             	add    $0x10,%esp
8010204a:	89 c2                	mov    %eax,%edx
8010204c:	8b 45 08             	mov    0x8(%ebp),%eax
8010204f:	8b 00                	mov    (%eax),%eax
80102051:	83 ec 08             	sub    $0x8,%esp
80102054:	52                   	push   %edx
80102055:	50                   	push   %eax
80102056:	e8 5b e1 ff ff       	call   801001b6 <bread>
8010205b:	83 c4 10             	add    $0x10,%esp
8010205e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102061:	8b 45 10             	mov    0x10(%ebp),%eax
80102064:	25 ff 01 00 00       	and    $0x1ff,%eax
80102069:	ba 00 02 00 00       	mov    $0x200,%edx
8010206e:	29 c2                	sub    %eax,%edx
80102070:	8b 45 14             	mov    0x14(%ebp),%eax
80102073:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102076:	39 c2                	cmp    %eax,%edx
80102078:	0f 46 c2             	cmovbe %edx,%eax
8010207b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010207e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102081:	8d 50 18             	lea    0x18(%eax),%edx
80102084:	8b 45 10             	mov    0x10(%ebp),%eax
80102087:	25 ff 01 00 00       	and    $0x1ff,%eax
8010208c:	01 d0                	add    %edx,%eax
8010208e:	83 ec 04             	sub    $0x4,%esp
80102091:	ff 75 ec             	pushl  -0x14(%ebp)
80102094:	50                   	push   %eax
80102095:	ff 75 0c             	pushl  0xc(%ebp)
80102098:	e8 92 3e 00 00       	call   80105f2f <memmove>
8010209d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020a0:	83 ec 0c             	sub    $0xc,%esp
801020a3:	ff 75 f0             	pushl  -0x10(%ebp)
801020a6:	e8 83 e1 ff ff       	call   8010022e <brelse>
801020ab:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020b1:	01 45 f4             	add    %eax,-0xc(%ebp)
801020b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020b7:	01 45 10             	add    %eax,0x10(%ebp)
801020ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020bd:	01 45 0c             	add    %eax,0xc(%ebp)
801020c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020c3:	3b 45 14             	cmp    0x14(%ebp),%eax
801020c6:	0f 82 69 ff ff ff    	jb     80102035 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801020cc:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020cf:	c9                   	leave  
801020d0:	c3                   	ret    

801020d1 <writei>:

// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020d1:	55                   	push   %ebp
801020d2:	89 e5                	mov    %esp,%ebp
801020d4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020d7:	8b 45 08             	mov    0x8(%ebp),%eax
801020da:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020de:	66 83 f8 03          	cmp    $0x3,%ax
801020e2:	75 5c                	jne    80102140 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020e4:	8b 45 08             	mov    0x8(%ebp),%eax
801020e7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020eb:	66 85 c0             	test   %ax,%ax
801020ee:	78 20                	js     80102110 <writei+0x3f>
801020f0:	8b 45 08             	mov    0x8(%ebp),%eax
801020f3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020f7:	66 83 f8 09          	cmp    $0x9,%ax
801020fb:	7f 13                	jg     80102110 <writei+0x3f>
801020fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102100:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102104:	98                   	cwtl   
80102105:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
8010210c:	85 c0                	test   %eax,%eax
8010210e:	75 0a                	jne    8010211a <writei+0x49>
      return -1;
80102110:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102115:	e9 3d 01 00 00       	jmp    80102257 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
8010211a:	8b 45 08             	mov    0x8(%ebp),%eax
8010211d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102121:	98                   	cwtl   
80102122:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
80102129:	8b 55 14             	mov    0x14(%ebp),%edx
8010212c:	83 ec 04             	sub    $0x4,%esp
8010212f:	52                   	push   %edx
80102130:	ff 75 0c             	pushl  0xc(%ebp)
80102133:	ff 75 08             	pushl  0x8(%ebp)
80102136:	ff d0                	call   *%eax
80102138:	83 c4 10             	add    $0x10,%esp
8010213b:	e9 17 01 00 00       	jmp    80102257 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102140:	8b 45 08             	mov    0x8(%ebp),%eax
80102143:	8b 40 18             	mov    0x18(%eax),%eax
80102146:	3b 45 10             	cmp    0x10(%ebp),%eax
80102149:	72 0d                	jb     80102158 <writei+0x87>
8010214b:	8b 55 10             	mov    0x10(%ebp),%edx
8010214e:	8b 45 14             	mov    0x14(%ebp),%eax
80102151:	01 d0                	add    %edx,%eax
80102153:	3b 45 10             	cmp    0x10(%ebp),%eax
80102156:	73 0a                	jae    80102162 <writei+0x91>
    return -1;
80102158:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010215d:	e9 f5 00 00 00       	jmp    80102257 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102162:	8b 55 10             	mov    0x10(%ebp),%edx
80102165:	8b 45 14             	mov    0x14(%ebp),%eax
80102168:	01 d0                	add    %edx,%eax
8010216a:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010216f:	76 0a                	jbe    8010217b <writei+0xaa>
    return -1;
80102171:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102176:	e9 dc 00 00 00       	jmp    80102257 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010217b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102182:	e9 99 00 00 00       	jmp    80102220 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102187:	8b 45 10             	mov    0x10(%ebp),%eax
8010218a:	c1 e8 09             	shr    $0x9,%eax
8010218d:	83 ec 08             	sub    $0x8,%esp
80102190:	50                   	push   %eax
80102191:	ff 75 08             	pushl  0x8(%ebp)
80102194:	e8 58 fb ff ff       	call   80101cf1 <bmap>
80102199:	83 c4 10             	add    $0x10,%esp
8010219c:	89 c2                	mov    %eax,%edx
8010219e:	8b 45 08             	mov    0x8(%ebp),%eax
801021a1:	8b 00                	mov    (%eax),%eax
801021a3:	83 ec 08             	sub    $0x8,%esp
801021a6:	52                   	push   %edx
801021a7:	50                   	push   %eax
801021a8:	e8 09 e0 ff ff       	call   801001b6 <bread>
801021ad:	83 c4 10             	add    $0x10,%esp
801021b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021b3:	8b 45 10             	mov    0x10(%ebp),%eax
801021b6:	25 ff 01 00 00       	and    $0x1ff,%eax
801021bb:	ba 00 02 00 00       	mov    $0x200,%edx
801021c0:	29 c2                	sub    %eax,%edx
801021c2:	8b 45 14             	mov    0x14(%ebp),%eax
801021c5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021c8:	39 c2                	cmp    %eax,%edx
801021ca:	0f 46 c2             	cmovbe %edx,%eax
801021cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021d3:	8d 50 18             	lea    0x18(%eax),%edx
801021d6:	8b 45 10             	mov    0x10(%ebp),%eax
801021d9:	25 ff 01 00 00       	and    $0x1ff,%eax
801021de:	01 d0                	add    %edx,%eax
801021e0:	83 ec 04             	sub    $0x4,%esp
801021e3:	ff 75 ec             	pushl  -0x14(%ebp)
801021e6:	ff 75 0c             	pushl  0xc(%ebp)
801021e9:	50                   	push   %eax
801021ea:	e8 40 3d 00 00       	call   80105f2f <memmove>
801021ef:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801021f2:	83 ec 0c             	sub    $0xc,%esp
801021f5:	ff 75 f0             	pushl  -0x10(%ebp)
801021f8:	e8 2a 16 00 00       	call   80103827 <log_write>
801021fd:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102200:	83 ec 0c             	sub    $0xc,%esp
80102203:	ff 75 f0             	pushl  -0x10(%ebp)
80102206:	e8 23 e0 ff ff       	call   8010022e <brelse>
8010220b:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010220e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102211:	01 45 f4             	add    %eax,-0xc(%ebp)
80102214:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102217:	01 45 10             	add    %eax,0x10(%ebp)
8010221a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010221d:	01 45 0c             	add    %eax,0xc(%ebp)
80102220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102223:	3b 45 14             	cmp    0x14(%ebp),%eax
80102226:	0f 82 5b ff ff ff    	jb     80102187 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010222c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102230:	74 22                	je     80102254 <writei+0x183>
80102232:	8b 45 08             	mov    0x8(%ebp),%eax
80102235:	8b 40 18             	mov    0x18(%eax),%eax
80102238:	3b 45 10             	cmp    0x10(%ebp),%eax
8010223b:	73 17                	jae    80102254 <writei+0x183>
    ip->size = off;
8010223d:	8b 45 08             	mov    0x8(%ebp),%eax
80102240:	8b 55 10             	mov    0x10(%ebp),%edx
80102243:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102246:	83 ec 0c             	sub    $0xc,%esp
80102249:	ff 75 08             	pushl  0x8(%ebp)
8010224c:	e8 e1 f5 ff ff       	call   80101832 <iupdate>
80102251:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102254:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102257:	c9                   	leave  
80102258:	c3                   	ret    

80102259 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
80102259:	55                   	push   %ebp
8010225a:	89 e5                	mov    %esp,%ebp
8010225c:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010225f:	83 ec 04             	sub    $0x4,%esp
80102262:	6a 0e                	push   $0xe
80102264:	ff 75 0c             	pushl  0xc(%ebp)
80102267:	ff 75 08             	pushl  0x8(%ebp)
8010226a:	e8 56 3d 00 00       	call   80105fc5 <strncmp>
8010226f:	83 c4 10             	add    $0x10,%esp
}
80102272:	c9                   	leave  
80102273:	c3                   	ret    

80102274 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102274:	55                   	push   %ebp
80102275:	89 e5                	mov    %esp,%ebp
80102277:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010227a:	8b 45 08             	mov    0x8(%ebp),%eax
8010227d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102281:	66 83 f8 01          	cmp    $0x1,%ax
80102285:	74 0d                	je     80102294 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102287:	83 ec 0c             	sub    $0xc,%esp
8010228a:	68 2f 94 10 80       	push   $0x8010942f
8010228f:	e8 d2 e2 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102294:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010229b:	eb 7b                	jmp    80102318 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010229d:	6a 10                	push   $0x10
8010229f:	ff 75 f4             	pushl  -0xc(%ebp)
801022a2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022a5:	50                   	push   %eax
801022a6:	ff 75 08             	pushl  0x8(%ebp)
801022a9:	e8 cc fc ff ff       	call   80101f7a <readi>
801022ae:	83 c4 10             	add    $0x10,%esp
801022b1:	83 f8 10             	cmp    $0x10,%eax
801022b4:	74 0d                	je     801022c3 <dirlookup+0x4f>
      panic("dirlink read");
801022b6:	83 ec 0c             	sub    $0xc,%esp
801022b9:	68 41 94 10 80       	push   $0x80109441
801022be:	e8 a3 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022c3:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022c7:	66 85 c0             	test   %ax,%ax
801022ca:	74 47                	je     80102313 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801022cc:	83 ec 08             	sub    $0x8,%esp
801022cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d2:	83 c0 02             	add    $0x2,%eax
801022d5:	50                   	push   %eax
801022d6:	ff 75 0c             	pushl  0xc(%ebp)
801022d9:	e8 7b ff ff ff       	call   80102259 <namecmp>
801022de:	83 c4 10             	add    $0x10,%esp
801022e1:	85 c0                	test   %eax,%eax
801022e3:	75 2f                	jne    80102314 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801022e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022e9:	74 08                	je     801022f3 <dirlookup+0x7f>
        *poff = off;
801022eb:	8b 45 10             	mov    0x10(%ebp),%eax
801022ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022f1:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022f3:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f7:	0f b7 c0             	movzwl %ax,%eax
801022fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801022fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102300:	8b 00                	mov    (%eax),%eax
80102302:	83 ec 08             	sub    $0x8,%esp
80102305:	ff 75 f0             	pushl  -0x10(%ebp)
80102308:	50                   	push   %eax
80102309:	e8 e5 f5 ff ff       	call   801018f3 <iget>
8010230e:	83 c4 10             	add    $0x10,%esp
80102311:	eb 19                	jmp    8010232c <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102313:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102314:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102318:	8b 45 08             	mov    0x8(%ebp),%eax
8010231b:	8b 40 18             	mov    0x18(%eax),%eax
8010231e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102321:	0f 87 76 ff ff ff    	ja     8010229d <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102327:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010232c:	c9                   	leave  
8010232d:	c3                   	ret    

8010232e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010232e:	55                   	push   %ebp
8010232f:	89 e5                	mov    %esp,%ebp
80102331:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102334:	83 ec 04             	sub    $0x4,%esp
80102337:	6a 00                	push   $0x0
80102339:	ff 75 0c             	pushl  0xc(%ebp)
8010233c:	ff 75 08             	pushl  0x8(%ebp)
8010233f:	e8 30 ff ff ff       	call   80102274 <dirlookup>
80102344:	83 c4 10             	add    $0x10,%esp
80102347:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010234a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010234e:	74 18                	je     80102368 <dirlink+0x3a>
    iput(ip);
80102350:	83 ec 0c             	sub    $0xc,%esp
80102353:	ff 75 f0             	pushl  -0x10(%ebp)
80102356:	e8 81 f8 ff ff       	call   80101bdc <iput>
8010235b:	83 c4 10             	add    $0x10,%esp
    return -1;
8010235e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102363:	e9 9c 00 00 00       	jmp    80102404 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102368:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010236f:	eb 39                	jmp    801023aa <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102374:	6a 10                	push   $0x10
80102376:	50                   	push   %eax
80102377:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010237a:	50                   	push   %eax
8010237b:	ff 75 08             	pushl  0x8(%ebp)
8010237e:	e8 f7 fb ff ff       	call   80101f7a <readi>
80102383:	83 c4 10             	add    $0x10,%esp
80102386:	83 f8 10             	cmp    $0x10,%eax
80102389:	74 0d                	je     80102398 <dirlink+0x6a>
      panic("dirlink read");
8010238b:	83 ec 0c             	sub    $0xc,%esp
8010238e:	68 41 94 10 80       	push   $0x80109441
80102393:	e8 ce e1 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102398:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010239c:	66 85 c0             	test   %ax,%ax
8010239f:	74 18                	je     801023b9 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a4:	83 c0 10             	add    $0x10,%eax
801023a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023aa:	8b 45 08             	mov    0x8(%ebp),%eax
801023ad:	8b 50 18             	mov    0x18(%eax),%edx
801023b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b3:	39 c2                	cmp    %eax,%edx
801023b5:	77 ba                	ja     80102371 <dirlink+0x43>
801023b7:	eb 01                	jmp    801023ba <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801023b9:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023ba:	83 ec 04             	sub    $0x4,%esp
801023bd:	6a 0e                	push   $0xe
801023bf:	ff 75 0c             	pushl  0xc(%ebp)
801023c2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023c5:	83 c0 02             	add    $0x2,%eax
801023c8:	50                   	push   %eax
801023c9:	e8 4d 3c 00 00       	call   8010601b <strncpy>
801023ce:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023d1:	8b 45 10             	mov    0x10(%ebp),%eax
801023d4:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023db:	6a 10                	push   $0x10
801023dd:	50                   	push   %eax
801023de:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023e1:	50                   	push   %eax
801023e2:	ff 75 08             	pushl  0x8(%ebp)
801023e5:	e8 e7 fc ff ff       	call   801020d1 <writei>
801023ea:	83 c4 10             	add    $0x10,%esp
801023ed:	83 f8 10             	cmp    $0x10,%eax
801023f0:	74 0d                	je     801023ff <dirlink+0xd1>
    panic("dirlink");
801023f2:	83 ec 0c             	sub    $0xc,%esp
801023f5:	68 4e 94 10 80       	push   $0x8010944e
801023fa:	e8 67 e1 ff ff       	call   80100566 <panic>
  
  return 0;
801023ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102404:	c9                   	leave  
80102405:	c3                   	ret    

80102406 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010240c:	eb 04                	jmp    80102412 <skipelem+0xc>
    path++;
8010240e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102412:	8b 45 08             	mov    0x8(%ebp),%eax
80102415:	0f b6 00             	movzbl (%eax),%eax
80102418:	3c 2f                	cmp    $0x2f,%al
8010241a:	74 f2                	je     8010240e <skipelem+0x8>
    path++;
  if(*path == 0)
8010241c:	8b 45 08             	mov    0x8(%ebp),%eax
8010241f:	0f b6 00             	movzbl (%eax),%eax
80102422:	84 c0                	test   %al,%al
80102424:	75 07                	jne    8010242d <skipelem+0x27>
    return 0;
80102426:	b8 00 00 00 00       	mov    $0x0,%eax
8010242b:	eb 7b                	jmp    801024a8 <skipelem+0xa2>
  s = path;
8010242d:	8b 45 08             	mov    0x8(%ebp),%eax
80102430:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102433:	eb 04                	jmp    80102439 <skipelem+0x33>
    path++;
80102435:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102439:	8b 45 08             	mov    0x8(%ebp),%eax
8010243c:	0f b6 00             	movzbl (%eax),%eax
8010243f:	3c 2f                	cmp    $0x2f,%al
80102441:	74 0a                	je     8010244d <skipelem+0x47>
80102443:	8b 45 08             	mov    0x8(%ebp),%eax
80102446:	0f b6 00             	movzbl (%eax),%eax
80102449:	84 c0                	test   %al,%al
8010244b:	75 e8                	jne    80102435 <skipelem+0x2f>
    path++;
  len = path - s;
8010244d:	8b 55 08             	mov    0x8(%ebp),%edx
80102450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102453:	29 c2                	sub    %eax,%edx
80102455:	89 d0                	mov    %edx,%eax
80102457:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010245a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010245e:	7e 15                	jle    80102475 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102460:	83 ec 04             	sub    $0x4,%esp
80102463:	6a 0e                	push   $0xe
80102465:	ff 75 f4             	pushl  -0xc(%ebp)
80102468:	ff 75 0c             	pushl  0xc(%ebp)
8010246b:	e8 bf 3a 00 00       	call   80105f2f <memmove>
80102470:	83 c4 10             	add    $0x10,%esp
80102473:	eb 26                	jmp    8010249b <skipelem+0x95>
  else {
    memmove(name, s, len);
80102475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102478:	83 ec 04             	sub    $0x4,%esp
8010247b:	50                   	push   %eax
8010247c:	ff 75 f4             	pushl  -0xc(%ebp)
8010247f:	ff 75 0c             	pushl  0xc(%ebp)
80102482:	e8 a8 3a 00 00       	call   80105f2f <memmove>
80102487:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010248a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010248d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102490:	01 d0                	add    %edx,%eax
80102492:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102495:	eb 04                	jmp    8010249b <skipelem+0x95>
    path++;
80102497:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010249b:	8b 45 08             	mov    0x8(%ebp),%eax
8010249e:	0f b6 00             	movzbl (%eax),%eax
801024a1:	3c 2f                	cmp    $0x2f,%al
801024a3:	74 f2                	je     80102497 <skipelem+0x91>
    path++;
  return path;
801024a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024a8:	c9                   	leave  
801024a9:	c3                   	ret    

801024aa <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024aa:	55                   	push   %ebp
801024ab:	89 e5                	mov    %esp,%ebp
801024ad:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024b0:	8b 45 08             	mov    0x8(%ebp),%eax
801024b3:	0f b6 00             	movzbl (%eax),%eax
801024b6:	3c 2f                	cmp    $0x2f,%al
801024b8:	75 17                	jne    801024d1 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801024ba:	83 ec 08             	sub    $0x8,%esp
801024bd:	6a 01                	push   $0x1
801024bf:	6a 01                	push   $0x1
801024c1:	e8 2d f4 ff ff       	call   801018f3 <iget>
801024c6:	83 c4 10             	add    $0x10,%esp
801024c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024cc:	e9 bb 00 00 00       	jmp    8010258c <namex+0xe2>
  else
    ip = idup(proc->cwd);
801024d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801024d7:	8b 40 68             	mov    0x68(%eax),%eax
801024da:	83 ec 0c             	sub    $0xc,%esp
801024dd:	50                   	push   %eax
801024de:	e8 ef f4 ff ff       	call   801019d2 <idup>
801024e3:	83 c4 10             	add    $0x10,%esp
801024e6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024e9:	e9 9e 00 00 00       	jmp    8010258c <namex+0xe2>
    ilock(ip);
801024ee:	83 ec 0c             	sub    $0xc,%esp
801024f1:	ff 75 f4             	pushl  -0xc(%ebp)
801024f4:	e8 13 f5 ff ff       	call   80101a0c <ilock>
801024f9:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801024fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024ff:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102503:	66 83 f8 01          	cmp    $0x1,%ax
80102507:	74 18                	je     80102521 <namex+0x77>
      iunlockput(ip);
80102509:	83 ec 0c             	sub    $0xc,%esp
8010250c:	ff 75 f4             	pushl  -0xc(%ebp)
8010250f:	e8 b8 f7 ff ff       	call   80101ccc <iunlockput>
80102514:	83 c4 10             	add    $0x10,%esp
      return 0;
80102517:	b8 00 00 00 00       	mov    $0x0,%eax
8010251c:	e9 a7 00 00 00       	jmp    801025c8 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102521:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102525:	74 20                	je     80102547 <namex+0x9d>
80102527:	8b 45 08             	mov    0x8(%ebp),%eax
8010252a:	0f b6 00             	movzbl (%eax),%eax
8010252d:	84 c0                	test   %al,%al
8010252f:	75 16                	jne    80102547 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102531:	83 ec 0c             	sub    $0xc,%esp
80102534:	ff 75 f4             	pushl  -0xc(%ebp)
80102537:	e8 2e f6 ff ff       	call   80101b6a <iunlock>
8010253c:	83 c4 10             	add    $0x10,%esp
      return ip;
8010253f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102542:	e9 81 00 00 00       	jmp    801025c8 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102547:	83 ec 04             	sub    $0x4,%esp
8010254a:	6a 00                	push   $0x0
8010254c:	ff 75 10             	pushl  0x10(%ebp)
8010254f:	ff 75 f4             	pushl  -0xc(%ebp)
80102552:	e8 1d fd ff ff       	call   80102274 <dirlookup>
80102557:	83 c4 10             	add    $0x10,%esp
8010255a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010255d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102561:	75 15                	jne    80102578 <namex+0xce>
      iunlockput(ip);
80102563:	83 ec 0c             	sub    $0xc,%esp
80102566:	ff 75 f4             	pushl  -0xc(%ebp)
80102569:	e8 5e f7 ff ff       	call   80101ccc <iunlockput>
8010256e:	83 c4 10             	add    $0x10,%esp
      return 0;
80102571:	b8 00 00 00 00       	mov    $0x0,%eax
80102576:	eb 50                	jmp    801025c8 <namex+0x11e>
    }
    iunlockput(ip);
80102578:	83 ec 0c             	sub    $0xc,%esp
8010257b:	ff 75 f4             	pushl  -0xc(%ebp)
8010257e:	e8 49 f7 ff ff       	call   80101ccc <iunlockput>
80102583:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102586:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102589:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010258c:	83 ec 08             	sub    $0x8,%esp
8010258f:	ff 75 10             	pushl  0x10(%ebp)
80102592:	ff 75 08             	pushl  0x8(%ebp)
80102595:	e8 6c fe ff ff       	call   80102406 <skipelem>
8010259a:	83 c4 10             	add    $0x10,%esp
8010259d:	89 45 08             	mov    %eax,0x8(%ebp)
801025a0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025a4:	0f 85 44 ff ff ff    	jne    801024ee <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801025aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025ae:	74 15                	je     801025c5 <namex+0x11b>
    iput(ip);
801025b0:	83 ec 0c             	sub    $0xc,%esp
801025b3:	ff 75 f4             	pushl  -0xc(%ebp)
801025b6:	e8 21 f6 ff ff       	call   80101bdc <iput>
801025bb:	83 c4 10             	add    $0x10,%esp
    return 0;
801025be:	b8 00 00 00 00       	mov    $0x0,%eax
801025c3:	eb 03                	jmp    801025c8 <namex+0x11e>
  }
  return ip;
801025c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025c8:	c9                   	leave  
801025c9:	c3                   	ret    

801025ca <namei>:

struct inode*
namei(char *path)
{
801025ca:	55                   	push   %ebp
801025cb:	89 e5                	mov    %esp,%ebp
801025cd:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025d0:	83 ec 04             	sub    $0x4,%esp
801025d3:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025d6:	50                   	push   %eax
801025d7:	6a 00                	push   $0x0
801025d9:	ff 75 08             	pushl  0x8(%ebp)
801025dc:	e8 c9 fe ff ff       	call   801024aa <namex>
801025e1:	83 c4 10             	add    $0x10,%esp
}
801025e4:	c9                   	leave  
801025e5:	c3                   	ret    

801025e6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025e6:	55                   	push   %ebp
801025e7:	89 e5                	mov    %esp,%ebp
801025e9:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025ec:	83 ec 04             	sub    $0x4,%esp
801025ef:	ff 75 0c             	pushl  0xc(%ebp)
801025f2:	6a 01                	push   $0x1
801025f4:	ff 75 08             	pushl  0x8(%ebp)
801025f7:	e8 ae fe ff ff       	call   801024aa <namex>
801025fc:	83 c4 10             	add    $0x10,%esp
}
801025ff:	c9                   	leave  
80102600:	c3                   	ret    

80102601 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102601:	55                   	push   %ebp
80102602:	89 e5                	mov    %esp,%ebp
80102604:	83 ec 14             	sub    $0x14,%esp
80102607:	8b 45 08             	mov    0x8(%ebp),%eax
8010260a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010260e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102612:	89 c2                	mov    %eax,%edx
80102614:	ec                   	in     (%dx),%al
80102615:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102618:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010261c:	c9                   	leave  
8010261d:	c3                   	ret    

8010261e <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010261e:	55                   	push   %ebp
8010261f:	89 e5                	mov    %esp,%ebp
80102621:	57                   	push   %edi
80102622:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102623:	8b 55 08             	mov    0x8(%ebp),%edx
80102626:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102629:	8b 45 10             	mov    0x10(%ebp),%eax
8010262c:	89 cb                	mov    %ecx,%ebx
8010262e:	89 df                	mov    %ebx,%edi
80102630:	89 c1                	mov    %eax,%ecx
80102632:	fc                   	cld    
80102633:	f3 6d                	rep insl (%dx),%es:(%edi)
80102635:	89 c8                	mov    %ecx,%eax
80102637:	89 fb                	mov    %edi,%ebx
80102639:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010263c:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010263f:	90                   	nop
80102640:	5b                   	pop    %ebx
80102641:	5f                   	pop    %edi
80102642:	5d                   	pop    %ebp
80102643:	c3                   	ret    

80102644 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102644:	55                   	push   %ebp
80102645:	89 e5                	mov    %esp,%ebp
80102647:	83 ec 08             	sub    $0x8,%esp
8010264a:	8b 55 08             	mov    0x8(%ebp),%edx
8010264d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102650:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102654:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102657:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010265b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010265f:	ee                   	out    %al,(%dx)
}
80102660:	90                   	nop
80102661:	c9                   	leave  
80102662:	c3                   	ret    

80102663 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102663:	55                   	push   %ebp
80102664:	89 e5                	mov    %esp,%ebp
80102666:	56                   	push   %esi
80102667:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102668:	8b 55 08             	mov    0x8(%ebp),%edx
8010266b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010266e:	8b 45 10             	mov    0x10(%ebp),%eax
80102671:	89 cb                	mov    %ecx,%ebx
80102673:	89 de                	mov    %ebx,%esi
80102675:	89 c1                	mov    %eax,%ecx
80102677:	fc                   	cld    
80102678:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010267a:	89 c8                	mov    %ecx,%eax
8010267c:	89 f3                	mov    %esi,%ebx
8010267e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102681:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102684:	90                   	nop
80102685:	5b                   	pop    %ebx
80102686:	5e                   	pop    %esi
80102687:	5d                   	pop    %ebp
80102688:	c3                   	ret    

80102689 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102689:	55                   	push   %ebp
8010268a:	89 e5                	mov    %esp,%ebp
8010268c:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
8010268f:	90                   	nop
80102690:	68 f7 01 00 00       	push   $0x1f7
80102695:	e8 67 ff ff ff       	call   80102601 <inb>
8010269a:	83 c4 04             	add    $0x4,%esp
8010269d:	0f b6 c0             	movzbl %al,%eax
801026a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026a6:	25 c0 00 00 00       	and    $0xc0,%eax
801026ab:	83 f8 40             	cmp    $0x40,%eax
801026ae:	75 e0                	jne    80102690 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026b0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026b4:	74 11                	je     801026c7 <idewait+0x3e>
801026b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026b9:	83 e0 21             	and    $0x21,%eax
801026bc:	85 c0                	test   %eax,%eax
801026be:	74 07                	je     801026c7 <idewait+0x3e>
    return -1;
801026c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026c5:	eb 05                	jmp    801026cc <idewait+0x43>
  return 0;
801026c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026cc:	c9                   	leave  
801026cd:	c3                   	ret    

801026ce <ideinit>:

void
ideinit(void)
{
801026ce:	55                   	push   %ebp
801026cf:	89 e5                	mov    %esp,%ebp
801026d1:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
801026d4:	83 ec 08             	sub    $0x8,%esp
801026d7:	68 56 94 10 80       	push   $0x80109456
801026dc:	68 20 c6 10 80       	push   $0x8010c620
801026e1:	e8 05 35 00 00       	call   80105beb <initlock>
801026e6:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801026e9:	83 ec 0c             	sub    $0xc,%esp
801026ec:	6a 0e                	push   $0xe
801026ee:	e8 da 18 00 00       	call   80103fcd <picenable>
801026f3:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801026f6:	a1 60 39 11 80       	mov    0x80113960,%eax
801026fb:	83 e8 01             	sub    $0x1,%eax
801026fe:	83 ec 08             	sub    $0x8,%esp
80102701:	50                   	push   %eax
80102702:	6a 0e                	push   $0xe
80102704:	e8 73 04 00 00       	call   80102b7c <ioapicenable>
80102709:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010270c:	83 ec 0c             	sub    $0xc,%esp
8010270f:	6a 00                	push   $0x0
80102711:	e8 73 ff ff ff       	call   80102689 <idewait>
80102716:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102719:	83 ec 08             	sub    $0x8,%esp
8010271c:	68 f0 00 00 00       	push   $0xf0
80102721:	68 f6 01 00 00       	push   $0x1f6
80102726:	e8 19 ff ff ff       	call   80102644 <outb>
8010272b:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010272e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102735:	eb 24                	jmp    8010275b <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102737:	83 ec 0c             	sub    $0xc,%esp
8010273a:	68 f7 01 00 00       	push   $0x1f7
8010273f:	e8 bd fe ff ff       	call   80102601 <inb>
80102744:	83 c4 10             	add    $0x10,%esp
80102747:	84 c0                	test   %al,%al
80102749:	74 0c                	je     80102757 <ideinit+0x89>
      havedisk1 = 1;
8010274b:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
80102752:	00 00 00 
      break;
80102755:	eb 0d                	jmp    80102764 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102757:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010275b:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102762:	7e d3                	jle    80102737 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102764:	83 ec 08             	sub    $0x8,%esp
80102767:	68 e0 00 00 00       	push   $0xe0
8010276c:	68 f6 01 00 00       	push   $0x1f6
80102771:	e8 ce fe ff ff       	call   80102644 <outb>
80102776:	83 c4 10             	add    $0x10,%esp
}
80102779:	90                   	nop
8010277a:	c9                   	leave  
8010277b:	c3                   	ret    

8010277c <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010277c:	55                   	push   %ebp
8010277d:	89 e5                	mov    %esp,%ebp
8010277f:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102782:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102786:	75 0d                	jne    80102795 <idestart+0x19>
    panic("idestart");
80102788:	83 ec 0c             	sub    $0xc,%esp
8010278b:	68 5a 94 10 80       	push   $0x8010945a
80102790:	e8 d1 dd ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102795:	8b 45 08             	mov    0x8(%ebp),%eax
80102798:	8b 40 08             	mov    0x8(%eax),%eax
8010279b:	3d cf 07 00 00       	cmp    $0x7cf,%eax
801027a0:	76 0d                	jbe    801027af <idestart+0x33>
    panic("incorrect blockno");
801027a2:	83 ec 0c             	sub    $0xc,%esp
801027a5:	68 63 94 10 80       	push   $0x80109463
801027aa:	e8 b7 dd ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027af:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027b6:	8b 45 08             	mov    0x8(%ebp),%eax
801027b9:	8b 50 08             	mov    0x8(%eax),%edx
801027bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027bf:	0f af c2             	imul   %edx,%eax
801027c2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
801027c5:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801027c9:	7e 0d                	jle    801027d8 <idestart+0x5c>
801027cb:	83 ec 0c             	sub    $0xc,%esp
801027ce:	68 5a 94 10 80       	push   $0x8010945a
801027d3:	e8 8e dd ff ff       	call   80100566 <panic>
  
  idewait(0);
801027d8:	83 ec 0c             	sub    $0xc,%esp
801027db:	6a 00                	push   $0x0
801027dd:	e8 a7 fe ff ff       	call   80102689 <idewait>
801027e2:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801027e5:	83 ec 08             	sub    $0x8,%esp
801027e8:	6a 00                	push   $0x0
801027ea:	68 f6 03 00 00       	push   $0x3f6
801027ef:	e8 50 fe ff ff       	call   80102644 <outb>
801027f4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801027f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027fa:	0f b6 c0             	movzbl %al,%eax
801027fd:	83 ec 08             	sub    $0x8,%esp
80102800:	50                   	push   %eax
80102801:	68 f2 01 00 00       	push   $0x1f2
80102806:	e8 39 fe ff ff       	call   80102644 <outb>
8010280b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010280e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102811:	0f b6 c0             	movzbl %al,%eax
80102814:	83 ec 08             	sub    $0x8,%esp
80102817:	50                   	push   %eax
80102818:	68 f3 01 00 00       	push   $0x1f3
8010281d:	e8 22 fe ff ff       	call   80102644 <outb>
80102822:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102825:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102828:	c1 f8 08             	sar    $0x8,%eax
8010282b:	0f b6 c0             	movzbl %al,%eax
8010282e:	83 ec 08             	sub    $0x8,%esp
80102831:	50                   	push   %eax
80102832:	68 f4 01 00 00       	push   $0x1f4
80102837:	e8 08 fe ff ff       	call   80102644 <outb>
8010283c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010283f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102842:	c1 f8 10             	sar    $0x10,%eax
80102845:	0f b6 c0             	movzbl %al,%eax
80102848:	83 ec 08             	sub    $0x8,%esp
8010284b:	50                   	push   %eax
8010284c:	68 f5 01 00 00       	push   $0x1f5
80102851:	e8 ee fd ff ff       	call   80102644 <outb>
80102856:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102859:	8b 45 08             	mov    0x8(%ebp),%eax
8010285c:	8b 40 04             	mov    0x4(%eax),%eax
8010285f:	83 e0 01             	and    $0x1,%eax
80102862:	c1 e0 04             	shl    $0x4,%eax
80102865:	89 c2                	mov    %eax,%edx
80102867:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010286a:	c1 f8 18             	sar    $0x18,%eax
8010286d:	83 e0 0f             	and    $0xf,%eax
80102870:	09 d0                	or     %edx,%eax
80102872:	83 c8 e0             	or     $0xffffffe0,%eax
80102875:	0f b6 c0             	movzbl %al,%eax
80102878:	83 ec 08             	sub    $0x8,%esp
8010287b:	50                   	push   %eax
8010287c:	68 f6 01 00 00       	push   $0x1f6
80102881:	e8 be fd ff ff       	call   80102644 <outb>
80102886:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102889:	8b 45 08             	mov    0x8(%ebp),%eax
8010288c:	8b 00                	mov    (%eax),%eax
8010288e:	83 e0 04             	and    $0x4,%eax
80102891:	85 c0                	test   %eax,%eax
80102893:	74 30                	je     801028c5 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102895:	83 ec 08             	sub    $0x8,%esp
80102898:	6a 30                	push   $0x30
8010289a:	68 f7 01 00 00       	push   $0x1f7
8010289f:	e8 a0 fd ff ff       	call   80102644 <outb>
801028a4:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801028a7:	8b 45 08             	mov    0x8(%ebp),%eax
801028aa:	83 c0 18             	add    $0x18,%eax
801028ad:	83 ec 04             	sub    $0x4,%esp
801028b0:	68 80 00 00 00       	push   $0x80
801028b5:	50                   	push   %eax
801028b6:	68 f0 01 00 00       	push   $0x1f0
801028bb:	e8 a3 fd ff ff       	call   80102663 <outsl>
801028c0:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
801028c3:	eb 12                	jmp    801028d7 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
801028c5:	83 ec 08             	sub    $0x8,%esp
801028c8:	6a 20                	push   $0x20
801028ca:	68 f7 01 00 00       	push   $0x1f7
801028cf:	e8 70 fd ff ff       	call   80102644 <outb>
801028d4:	83 c4 10             	add    $0x10,%esp
  }
}
801028d7:	90                   	nop
801028d8:	c9                   	leave  
801028d9:	c3                   	ret    

801028da <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801028da:	55                   	push   %ebp
801028db:	89 e5                	mov    %esp,%ebp
801028dd:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801028e0:	83 ec 0c             	sub    $0xc,%esp
801028e3:	68 20 c6 10 80       	push   $0x8010c620
801028e8:	e8 20 33 00 00       	call   80105c0d <acquire>
801028ed:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801028f0:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801028f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028fc:	75 15                	jne    80102913 <ideintr+0x39>
    release(&idelock);
801028fe:	83 ec 0c             	sub    $0xc,%esp
80102901:	68 20 c6 10 80       	push   $0x8010c620
80102906:	e8 69 33 00 00       	call   80105c74 <release>
8010290b:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010290e:	e9 9a 00 00 00       	jmp    801029ad <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102916:	8b 40 14             	mov    0x14(%eax),%eax
80102919:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010291e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102921:	8b 00                	mov    (%eax),%eax
80102923:	83 e0 04             	and    $0x4,%eax
80102926:	85 c0                	test   %eax,%eax
80102928:	75 2d                	jne    80102957 <ideintr+0x7d>
8010292a:	83 ec 0c             	sub    $0xc,%esp
8010292d:	6a 01                	push   $0x1
8010292f:	e8 55 fd ff ff       	call   80102689 <idewait>
80102934:	83 c4 10             	add    $0x10,%esp
80102937:	85 c0                	test   %eax,%eax
80102939:	78 1c                	js     80102957 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
8010293b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010293e:	83 c0 18             	add    $0x18,%eax
80102941:	83 ec 04             	sub    $0x4,%esp
80102944:	68 80 00 00 00       	push   $0x80
80102949:	50                   	push   %eax
8010294a:	68 f0 01 00 00       	push   $0x1f0
8010294f:	e8 ca fc ff ff       	call   8010261e <insl>
80102954:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010295a:	8b 00                	mov    (%eax),%eax
8010295c:	83 c8 02             	or     $0x2,%eax
8010295f:	89 c2                	mov    %eax,%edx
80102961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102964:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102969:	8b 00                	mov    (%eax),%eax
8010296b:	83 e0 fb             	and    $0xfffffffb,%eax
8010296e:	89 c2                	mov    %eax,%edx
80102970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102973:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102975:	83 ec 0c             	sub    $0xc,%esp
80102978:	ff 75 f4             	pushl  -0xc(%ebp)
8010297b:	e8 71 28 00 00       	call   801051f1 <wakeup>
80102980:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102983:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102988:	85 c0                	test   %eax,%eax
8010298a:	74 11                	je     8010299d <ideintr+0xc3>
    idestart(idequeue);
8010298c:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102991:	83 ec 0c             	sub    $0xc,%esp
80102994:	50                   	push   %eax
80102995:	e8 e2 fd ff ff       	call   8010277c <idestart>
8010299a:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010299d:	83 ec 0c             	sub    $0xc,%esp
801029a0:	68 20 c6 10 80       	push   $0x8010c620
801029a5:	e8 ca 32 00 00       	call   80105c74 <release>
801029aa:	83 c4 10             	add    $0x10,%esp
}
801029ad:	c9                   	leave  
801029ae:	c3                   	ret    

801029af <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029af:	55                   	push   %ebp
801029b0:	89 e5                	mov    %esp,%ebp
801029b2:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801029b5:	8b 45 08             	mov    0x8(%ebp),%eax
801029b8:	8b 00                	mov    (%eax),%eax
801029ba:	83 e0 01             	and    $0x1,%eax
801029bd:	85 c0                	test   %eax,%eax
801029bf:	75 0d                	jne    801029ce <iderw+0x1f>
    panic("iderw: buf not busy");
801029c1:	83 ec 0c             	sub    $0xc,%esp
801029c4:	68 75 94 10 80       	push   $0x80109475
801029c9:	e8 98 db ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029ce:	8b 45 08             	mov    0x8(%ebp),%eax
801029d1:	8b 00                	mov    (%eax),%eax
801029d3:	83 e0 06             	and    $0x6,%eax
801029d6:	83 f8 02             	cmp    $0x2,%eax
801029d9:	75 0d                	jne    801029e8 <iderw+0x39>
    panic("iderw: nothing to do");
801029db:	83 ec 0c             	sub    $0xc,%esp
801029de:	68 89 94 10 80       	push   $0x80109489
801029e3:	e8 7e db ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801029e8:	8b 45 08             	mov    0x8(%ebp),%eax
801029eb:	8b 40 04             	mov    0x4(%eax),%eax
801029ee:	85 c0                	test   %eax,%eax
801029f0:	74 16                	je     80102a08 <iderw+0x59>
801029f2:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801029f7:	85 c0                	test   %eax,%eax
801029f9:	75 0d                	jne    80102a08 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801029fb:	83 ec 0c             	sub    $0xc,%esp
801029fe:	68 9e 94 10 80       	push   $0x8010949e
80102a03:	e8 5e db ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a08:	83 ec 0c             	sub    $0xc,%esp
80102a0b:	68 20 c6 10 80       	push   $0x8010c620
80102a10:	e8 f8 31 00 00       	call   80105c0d <acquire>
80102a15:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a18:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a22:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80102a29:	eb 0b                	jmp    80102a36 <iderw+0x87>
80102a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2e:	8b 00                	mov    (%eax),%eax
80102a30:	83 c0 14             	add    $0x14,%eax
80102a33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a39:	8b 00                	mov    (%eax),%eax
80102a3b:	85 c0                	test   %eax,%eax
80102a3d:	75 ec                	jne    80102a2b <iderw+0x7c>
    ;
  *pp = b;
80102a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a42:	8b 55 08             	mov    0x8(%ebp),%edx
80102a45:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102a47:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102a4c:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a4f:	75 23                	jne    80102a74 <iderw+0xc5>
    idestart(b);
80102a51:	83 ec 0c             	sub    $0xc,%esp
80102a54:	ff 75 08             	pushl  0x8(%ebp)
80102a57:	e8 20 fd ff ff       	call   8010277c <idestart>
80102a5c:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a5f:	eb 13                	jmp    80102a74 <iderw+0xc5>
    sleep(b, &idelock);
80102a61:	83 ec 08             	sub    $0x8,%esp
80102a64:	68 20 c6 10 80       	push   $0x8010c620
80102a69:	ff 75 08             	pushl  0x8(%ebp)
80102a6c:	e8 63 26 00 00       	call   801050d4 <sleep>
80102a71:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a74:	8b 45 08             	mov    0x8(%ebp),%eax
80102a77:	8b 00                	mov    (%eax),%eax
80102a79:	83 e0 06             	and    $0x6,%eax
80102a7c:	83 f8 02             	cmp    $0x2,%eax
80102a7f:	75 e0                	jne    80102a61 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102a81:	83 ec 0c             	sub    $0xc,%esp
80102a84:	68 20 c6 10 80       	push   $0x8010c620
80102a89:	e8 e6 31 00 00       	call   80105c74 <release>
80102a8e:	83 c4 10             	add    $0x10,%esp
}
80102a91:	90                   	nop
80102a92:	c9                   	leave  
80102a93:	c3                   	ret    

80102a94 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a94:	55                   	push   %ebp
80102a95:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a97:	a1 34 32 11 80       	mov    0x80113234,%eax
80102a9c:	8b 55 08             	mov    0x8(%ebp),%edx
80102a9f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102aa1:	a1 34 32 11 80       	mov    0x80113234,%eax
80102aa6:	8b 40 10             	mov    0x10(%eax),%eax
}
80102aa9:	5d                   	pop    %ebp
80102aaa:	c3                   	ret    

80102aab <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102aab:	55                   	push   %ebp
80102aac:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102aae:	a1 34 32 11 80       	mov    0x80113234,%eax
80102ab3:	8b 55 08             	mov    0x8(%ebp),%edx
80102ab6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102ab8:	a1 34 32 11 80       	mov    0x80113234,%eax
80102abd:	8b 55 0c             	mov    0xc(%ebp),%edx
80102ac0:	89 50 10             	mov    %edx,0x10(%eax)
}
80102ac3:	90                   	nop
80102ac4:	5d                   	pop    %ebp
80102ac5:	c3                   	ret    

80102ac6 <ioapicinit>:

void
ioapicinit(void)
{
80102ac6:	55                   	push   %ebp
80102ac7:	89 e5                	mov    %esp,%ebp
80102ac9:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102acc:	a1 64 33 11 80       	mov    0x80113364,%eax
80102ad1:	85 c0                	test   %eax,%eax
80102ad3:	0f 84 a0 00 00 00    	je     80102b79 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ad9:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
80102ae0:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102ae3:	6a 01                	push   $0x1
80102ae5:	e8 aa ff ff ff       	call   80102a94 <ioapicread>
80102aea:	83 c4 04             	add    $0x4,%esp
80102aed:	c1 e8 10             	shr    $0x10,%eax
80102af0:	25 ff 00 00 00       	and    $0xff,%eax
80102af5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102af8:	6a 00                	push   $0x0
80102afa:	e8 95 ff ff ff       	call   80102a94 <ioapicread>
80102aff:	83 c4 04             	add    $0x4,%esp
80102b02:	c1 e8 18             	shr    $0x18,%eax
80102b05:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b08:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
80102b0f:	0f b6 c0             	movzbl %al,%eax
80102b12:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b15:	74 10                	je     80102b27 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b17:	83 ec 0c             	sub    $0xc,%esp
80102b1a:	68 bc 94 10 80       	push   $0x801094bc
80102b1f:	e8 a2 d8 ff ff       	call   801003c6 <cprintf>
80102b24:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b2e:	eb 3f                	jmp    80102b6f <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b33:	83 c0 20             	add    $0x20,%eax
80102b36:	0d 00 00 01 00       	or     $0x10000,%eax
80102b3b:	89 c2                	mov    %eax,%edx
80102b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b40:	83 c0 08             	add    $0x8,%eax
80102b43:	01 c0                	add    %eax,%eax
80102b45:	83 ec 08             	sub    $0x8,%esp
80102b48:	52                   	push   %edx
80102b49:	50                   	push   %eax
80102b4a:	e8 5c ff ff ff       	call   80102aab <ioapicwrite>
80102b4f:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b55:	83 c0 08             	add    $0x8,%eax
80102b58:	01 c0                	add    %eax,%eax
80102b5a:	83 c0 01             	add    $0x1,%eax
80102b5d:	83 ec 08             	sub    $0x8,%esp
80102b60:	6a 00                	push   $0x0
80102b62:	50                   	push   %eax
80102b63:	e8 43 ff ff ff       	call   80102aab <ioapicwrite>
80102b68:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b72:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b75:	7e b9                	jle    80102b30 <ioapicinit+0x6a>
80102b77:	eb 01                	jmp    80102b7a <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102b79:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b7a:	c9                   	leave  
80102b7b:	c3                   	ret    

80102b7c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b7c:	55                   	push   %ebp
80102b7d:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102b7f:	a1 64 33 11 80       	mov    0x80113364,%eax
80102b84:	85 c0                	test   %eax,%eax
80102b86:	74 39                	je     80102bc1 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b88:	8b 45 08             	mov    0x8(%ebp),%eax
80102b8b:	83 c0 20             	add    $0x20,%eax
80102b8e:	89 c2                	mov    %eax,%edx
80102b90:	8b 45 08             	mov    0x8(%ebp),%eax
80102b93:	83 c0 08             	add    $0x8,%eax
80102b96:	01 c0                	add    %eax,%eax
80102b98:	52                   	push   %edx
80102b99:	50                   	push   %eax
80102b9a:	e8 0c ff ff ff       	call   80102aab <ioapicwrite>
80102b9f:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ba5:	c1 e0 18             	shl    $0x18,%eax
80102ba8:	89 c2                	mov    %eax,%edx
80102baa:	8b 45 08             	mov    0x8(%ebp),%eax
80102bad:	83 c0 08             	add    $0x8,%eax
80102bb0:	01 c0                	add    %eax,%eax
80102bb2:	83 c0 01             	add    $0x1,%eax
80102bb5:	52                   	push   %edx
80102bb6:	50                   	push   %eax
80102bb7:	e8 ef fe ff ff       	call   80102aab <ioapicwrite>
80102bbc:	83 c4 08             	add    $0x8,%esp
80102bbf:	eb 01                	jmp    80102bc2 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102bc1:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102bc2:	c9                   	leave  
80102bc3:	c3                   	ret    

80102bc4 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102bc4:	55                   	push   %ebp
80102bc5:	89 e5                	mov    %esp,%ebp
80102bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80102bca:	05 00 00 00 80       	add    $0x80000000,%eax
80102bcf:	5d                   	pop    %ebp
80102bd0:	c3                   	ret    

80102bd1 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102bd1:	55                   	push   %ebp
80102bd2:	89 e5                	mov    %esp,%ebp
80102bd4:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102bd7:	83 ec 08             	sub    $0x8,%esp
80102bda:	68 ee 94 10 80       	push   $0x801094ee
80102bdf:	68 40 32 11 80       	push   $0x80113240
80102be4:	e8 02 30 00 00       	call   80105beb <initlock>
80102be9:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102bec:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
80102bf3:	00 00 00 
  freerange(vstart, vend);
80102bf6:	83 ec 08             	sub    $0x8,%esp
80102bf9:	ff 75 0c             	pushl  0xc(%ebp)
80102bfc:	ff 75 08             	pushl  0x8(%ebp)
80102bff:	e8 2a 00 00 00       	call   80102c2e <freerange>
80102c04:	83 c4 10             	add    $0x10,%esp
}
80102c07:	90                   	nop
80102c08:	c9                   	leave  
80102c09:	c3                   	ret    

80102c0a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c0a:	55                   	push   %ebp
80102c0b:	89 e5                	mov    %esp,%ebp
80102c0d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c10:	83 ec 08             	sub    $0x8,%esp
80102c13:	ff 75 0c             	pushl  0xc(%ebp)
80102c16:	ff 75 08             	pushl  0x8(%ebp)
80102c19:	e8 10 00 00 00       	call   80102c2e <freerange>
80102c1e:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c21:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102c28:	00 00 00 
}
80102c2b:	90                   	nop
80102c2c:	c9                   	leave  
80102c2d:	c3                   	ret    

80102c2e <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c2e:	55                   	push   %ebp
80102c2f:	89 e5                	mov    %esp,%ebp
80102c31:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c34:	8b 45 08             	mov    0x8(%ebp),%eax
80102c37:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c3c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c44:	eb 15                	jmp    80102c5b <freerange+0x2d>
    kfree(p);
80102c46:	83 ec 0c             	sub    $0xc,%esp
80102c49:	ff 75 f4             	pushl  -0xc(%ebp)
80102c4c:	e8 1a 00 00 00       	call   80102c6b <kfree>
80102c51:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c54:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5e:	05 00 10 00 00       	add    $0x1000,%eax
80102c63:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c66:	76 de                	jbe    80102c46 <freerange+0x18>
    kfree(p);
}
80102c68:	90                   	nop
80102c69:	c9                   	leave  
80102c6a:	c3                   	ret    

80102c6b <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c6b:	55                   	push   %ebp
80102c6c:	89 e5                	mov    %esp,%ebp
80102c6e:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102c71:	8b 45 08             	mov    0x8(%ebp),%eax
80102c74:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c79:	85 c0                	test   %eax,%eax
80102c7b:	75 1b                	jne    80102c98 <kfree+0x2d>
80102c7d:	81 7d 08 3c 67 11 80 	cmpl   $0x8011673c,0x8(%ebp)
80102c84:	72 12                	jb     80102c98 <kfree+0x2d>
80102c86:	ff 75 08             	pushl  0x8(%ebp)
80102c89:	e8 36 ff ff ff       	call   80102bc4 <v2p>
80102c8e:	83 c4 04             	add    $0x4,%esp
80102c91:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c96:	76 0d                	jbe    80102ca5 <kfree+0x3a>
    panic("kfree");
80102c98:	83 ec 0c             	sub    $0xc,%esp
80102c9b:	68 f3 94 10 80       	push   $0x801094f3
80102ca0:	e8 c1 d8 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ca5:	83 ec 04             	sub    $0x4,%esp
80102ca8:	68 00 10 00 00       	push   $0x1000
80102cad:	6a 01                	push   $0x1
80102caf:	ff 75 08             	pushl  0x8(%ebp)
80102cb2:	e8 b9 31 00 00       	call   80105e70 <memset>
80102cb7:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cba:	a1 74 32 11 80       	mov    0x80113274,%eax
80102cbf:	85 c0                	test   %eax,%eax
80102cc1:	74 10                	je     80102cd3 <kfree+0x68>
    acquire(&kmem.lock);
80102cc3:	83 ec 0c             	sub    $0xc,%esp
80102cc6:	68 40 32 11 80       	push   $0x80113240
80102ccb:	e8 3d 2f 00 00       	call   80105c0d <acquire>
80102cd0:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102cd9:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce2:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce7:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102cec:	a1 74 32 11 80       	mov    0x80113274,%eax
80102cf1:	85 c0                	test   %eax,%eax
80102cf3:	74 10                	je     80102d05 <kfree+0x9a>
    release(&kmem.lock);
80102cf5:	83 ec 0c             	sub    $0xc,%esp
80102cf8:	68 40 32 11 80       	push   $0x80113240
80102cfd:	e8 72 2f 00 00       	call   80105c74 <release>
80102d02:	83 c4 10             	add    $0x10,%esp
}
80102d05:	90                   	nop
80102d06:	c9                   	leave  
80102d07:	c3                   	ret    

80102d08 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d08:	55                   	push   %ebp
80102d09:	89 e5                	mov    %esp,%ebp
80102d0b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d0e:	a1 74 32 11 80       	mov    0x80113274,%eax
80102d13:	85 c0                	test   %eax,%eax
80102d15:	74 10                	je     80102d27 <kalloc+0x1f>
    acquire(&kmem.lock);
80102d17:	83 ec 0c             	sub    $0xc,%esp
80102d1a:	68 40 32 11 80       	push   $0x80113240
80102d1f:	e8 e9 2e 00 00       	call   80105c0d <acquire>
80102d24:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d27:	a1 78 32 11 80       	mov    0x80113278,%eax
80102d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d33:	74 0a                	je     80102d3f <kalloc+0x37>
    kmem.freelist = r->next;
80102d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d38:	8b 00                	mov    (%eax),%eax
80102d3a:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102d3f:	a1 74 32 11 80       	mov    0x80113274,%eax
80102d44:	85 c0                	test   %eax,%eax
80102d46:	74 10                	je     80102d58 <kalloc+0x50>
    release(&kmem.lock);
80102d48:	83 ec 0c             	sub    $0xc,%esp
80102d4b:	68 40 32 11 80       	push   $0x80113240
80102d50:	e8 1f 2f 00 00       	call   80105c74 <release>
80102d55:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d5b:	c9                   	leave  
80102d5c:	c3                   	ret    

80102d5d <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102d5d:	55                   	push   %ebp
80102d5e:	89 e5                	mov    %esp,%ebp
80102d60:	83 ec 14             	sub    $0x14,%esp
80102d63:	8b 45 08             	mov    0x8(%ebp),%eax
80102d66:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d6a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d6e:	89 c2                	mov    %eax,%edx
80102d70:	ec                   	in     (%dx),%al
80102d71:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d74:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d78:	c9                   	leave  
80102d79:	c3                   	ret    

80102d7a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d7a:	55                   	push   %ebp
80102d7b:	89 e5                	mov    %esp,%ebp
80102d7d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d80:	6a 64                	push   $0x64
80102d82:	e8 d6 ff ff ff       	call   80102d5d <inb>
80102d87:	83 c4 04             	add    $0x4,%esp
80102d8a:	0f b6 c0             	movzbl %al,%eax
80102d8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d93:	83 e0 01             	and    $0x1,%eax
80102d96:	85 c0                	test   %eax,%eax
80102d98:	75 0a                	jne    80102da4 <kbdgetc+0x2a>
    return -1;
80102d9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d9f:	e9 23 01 00 00       	jmp    80102ec7 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102da4:	6a 60                	push   $0x60
80102da6:	e8 b2 ff ff ff       	call   80102d5d <inb>
80102dab:	83 c4 04             	add    $0x4,%esp
80102dae:	0f b6 c0             	movzbl %al,%eax
80102db1:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102db4:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102dbb:	75 17                	jne    80102dd4 <kbdgetc+0x5a>
    shift |= E0ESC;
80102dbd:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102dc2:	83 c8 40             	or     $0x40,%eax
80102dc5:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102dca:	b8 00 00 00 00       	mov    $0x0,%eax
80102dcf:	e9 f3 00 00 00       	jmp    80102ec7 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102dd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd7:	25 80 00 00 00       	and    $0x80,%eax
80102ddc:	85 c0                	test   %eax,%eax
80102dde:	74 45                	je     80102e25 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102de0:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102de5:	83 e0 40             	and    $0x40,%eax
80102de8:	85 c0                	test   %eax,%eax
80102dea:	75 08                	jne    80102df4 <kbdgetc+0x7a>
80102dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102def:	83 e0 7f             	and    $0x7f,%eax
80102df2:	eb 03                	jmp    80102df7 <kbdgetc+0x7d>
80102df4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102df7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102dfa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dfd:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e02:	0f b6 00             	movzbl (%eax),%eax
80102e05:	83 c8 40             	or     $0x40,%eax
80102e08:	0f b6 c0             	movzbl %al,%eax
80102e0b:	f7 d0                	not    %eax
80102e0d:	89 c2                	mov    %eax,%edx
80102e0f:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e14:	21 d0                	and    %edx,%eax
80102e16:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102e1b:	b8 00 00 00 00       	mov    $0x0,%eax
80102e20:	e9 a2 00 00 00       	jmp    80102ec7 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e25:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e2a:	83 e0 40             	and    $0x40,%eax
80102e2d:	85 c0                	test   %eax,%eax
80102e2f:	74 14                	je     80102e45 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e31:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e38:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e3d:	83 e0 bf             	and    $0xffffffbf,%eax
80102e40:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102e45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e48:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e4d:	0f b6 00             	movzbl (%eax),%eax
80102e50:	0f b6 d0             	movzbl %al,%edx
80102e53:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e58:	09 d0                	or     %edx,%eax
80102e5a:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102e5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e62:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102e67:	0f b6 00             	movzbl (%eax),%eax
80102e6a:	0f b6 d0             	movzbl %al,%edx
80102e6d:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e72:	31 d0                	xor    %edx,%eax
80102e74:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e79:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e7e:	83 e0 03             	and    $0x3,%eax
80102e81:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102e88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e8b:	01 d0                	add    %edx,%eax
80102e8d:	0f b6 00             	movzbl (%eax),%eax
80102e90:	0f b6 c0             	movzbl %al,%eax
80102e93:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e96:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e9b:	83 e0 08             	and    $0x8,%eax
80102e9e:	85 c0                	test   %eax,%eax
80102ea0:	74 22                	je     80102ec4 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102ea2:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102ea6:	76 0c                	jbe    80102eb4 <kbdgetc+0x13a>
80102ea8:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102eac:	77 06                	ja     80102eb4 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102eae:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102eb2:	eb 10                	jmp    80102ec4 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102eb4:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102eb8:	76 0a                	jbe    80102ec4 <kbdgetc+0x14a>
80102eba:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ebe:	77 04                	ja     80102ec4 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102ec0:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ec4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ec7:	c9                   	leave  
80102ec8:	c3                   	ret    

80102ec9 <kbdintr>:

void
kbdintr(void)
{
80102ec9:	55                   	push   %ebp
80102eca:	89 e5                	mov    %esp,%ebp
80102ecc:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102ecf:	83 ec 0c             	sub    $0xc,%esp
80102ed2:	68 7a 2d 10 80       	push   $0x80102d7a
80102ed7:	e8 1d d9 ff ff       	call   801007f9 <consoleintr>
80102edc:	83 c4 10             	add    $0x10,%esp
}
80102edf:	90                   	nop
80102ee0:	c9                   	leave  
80102ee1:	c3                   	ret    

80102ee2 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102ee2:	55                   	push   %ebp
80102ee3:	89 e5                	mov    %esp,%ebp
80102ee5:	83 ec 14             	sub    $0x14,%esp
80102ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80102eeb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102eef:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ef3:	89 c2                	mov    %eax,%edx
80102ef5:	ec                   	in     (%dx),%al
80102ef6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ef9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102efd:	c9                   	leave  
80102efe:	c3                   	ret    

80102eff <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102eff:	55                   	push   %ebp
80102f00:	89 e5                	mov    %esp,%ebp
80102f02:	83 ec 08             	sub    $0x8,%esp
80102f05:	8b 55 08             	mov    0x8(%ebp),%edx
80102f08:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f0b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102f0f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f12:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f16:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f1a:	ee                   	out    %al,(%dx)
}
80102f1b:	90                   	nop
80102f1c:	c9                   	leave  
80102f1d:	c3                   	ret    

80102f1e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102f1e:	55                   	push   %ebp
80102f1f:	89 e5                	mov    %esp,%ebp
80102f21:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102f24:	9c                   	pushf  
80102f25:	58                   	pop    %eax
80102f26:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102f29:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102f2c:	c9                   	leave  
80102f2d:	c3                   	ret    

80102f2e <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102f2e:	55                   	push   %ebp
80102f2f:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f31:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f36:	8b 55 08             	mov    0x8(%ebp),%edx
80102f39:	c1 e2 02             	shl    $0x2,%edx
80102f3c:	01 c2                	add    %eax,%edx
80102f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f41:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f43:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f48:	83 c0 20             	add    $0x20,%eax
80102f4b:	8b 00                	mov    (%eax),%eax
}
80102f4d:	90                   	nop
80102f4e:	5d                   	pop    %ebp
80102f4f:	c3                   	ret    

80102f50 <lapicinit>:

void
lapicinit(void)
{
80102f50:	55                   	push   %ebp
80102f51:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102f53:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f58:	85 c0                	test   %eax,%eax
80102f5a:	0f 84 0b 01 00 00    	je     8010306b <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f60:	68 3f 01 00 00       	push   $0x13f
80102f65:	6a 3c                	push   $0x3c
80102f67:	e8 c2 ff ff ff       	call   80102f2e <lapicw>
80102f6c:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f6f:	6a 0b                	push   $0xb
80102f71:	68 f8 00 00 00       	push   $0xf8
80102f76:	e8 b3 ff ff ff       	call   80102f2e <lapicw>
80102f7b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f7e:	68 20 00 02 00       	push   $0x20020
80102f83:	68 c8 00 00 00       	push   $0xc8
80102f88:	e8 a1 ff ff ff       	call   80102f2e <lapicw>
80102f8d:	83 c4 08             	add    $0x8,%esp
  // lapicw(TICR, 10000000); 
  lapicw(TICR, 1000000000/TPS); // PSU CS333. Makes ticks per second programmable
80102f90:	68 40 42 0f 00       	push   $0xf4240
80102f95:	68 e0 00 00 00       	push   $0xe0
80102f9a:	e8 8f ff ff ff       	call   80102f2e <lapicw>
80102f9f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102fa2:	68 00 00 01 00       	push   $0x10000
80102fa7:	68 d4 00 00 00       	push   $0xd4
80102fac:	e8 7d ff ff ff       	call   80102f2e <lapicw>
80102fb1:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102fb4:	68 00 00 01 00       	push   $0x10000
80102fb9:	68 d8 00 00 00       	push   $0xd8
80102fbe:	e8 6b ff ff ff       	call   80102f2e <lapicw>
80102fc3:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102fc6:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102fcb:	83 c0 30             	add    $0x30,%eax
80102fce:	8b 00                	mov    (%eax),%eax
80102fd0:	c1 e8 10             	shr    $0x10,%eax
80102fd3:	0f b6 c0             	movzbl %al,%eax
80102fd6:	83 f8 03             	cmp    $0x3,%eax
80102fd9:	76 12                	jbe    80102fed <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102fdb:	68 00 00 01 00       	push   $0x10000
80102fe0:	68 d0 00 00 00       	push   $0xd0
80102fe5:	e8 44 ff ff ff       	call   80102f2e <lapicw>
80102fea:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102fed:	6a 33                	push   $0x33
80102fef:	68 dc 00 00 00       	push   $0xdc
80102ff4:	e8 35 ff ff ff       	call   80102f2e <lapicw>
80102ff9:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102ffc:	6a 00                	push   $0x0
80102ffe:	68 a0 00 00 00       	push   $0xa0
80103003:	e8 26 ff ff ff       	call   80102f2e <lapicw>
80103008:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010300b:	6a 00                	push   $0x0
8010300d:	68 a0 00 00 00       	push   $0xa0
80103012:	e8 17 ff ff ff       	call   80102f2e <lapicw>
80103017:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010301a:	6a 00                	push   $0x0
8010301c:	6a 2c                	push   $0x2c
8010301e:	e8 0b ff ff ff       	call   80102f2e <lapicw>
80103023:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103026:	6a 00                	push   $0x0
80103028:	68 c4 00 00 00       	push   $0xc4
8010302d:	e8 fc fe ff ff       	call   80102f2e <lapicw>
80103032:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103035:	68 00 85 08 00       	push   $0x88500
8010303a:	68 c0 00 00 00       	push   $0xc0
8010303f:	e8 ea fe ff ff       	call   80102f2e <lapicw>
80103044:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103047:	90                   	nop
80103048:	a1 7c 32 11 80       	mov    0x8011327c,%eax
8010304d:	05 00 03 00 00       	add    $0x300,%eax
80103052:	8b 00                	mov    (%eax),%eax
80103054:	25 00 10 00 00       	and    $0x1000,%eax
80103059:	85 c0                	test   %eax,%eax
8010305b:	75 eb                	jne    80103048 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010305d:	6a 00                	push   $0x0
8010305f:	6a 20                	push   $0x20
80103061:	e8 c8 fe ff ff       	call   80102f2e <lapicw>
80103066:	83 c4 08             	add    $0x8,%esp
80103069:	eb 01                	jmp    8010306c <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
8010306b:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010306c:	c9                   	leave  
8010306d:	c3                   	ret    

8010306e <cpunum>:

int
cpunum(void)
{
8010306e:	55                   	push   %ebp
8010306f:	89 e5                	mov    %esp,%ebp
80103071:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103074:	e8 a5 fe ff ff       	call   80102f1e <readeflags>
80103079:	25 00 02 00 00       	and    $0x200,%eax
8010307e:	85 c0                	test   %eax,%eax
80103080:	74 26                	je     801030a8 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80103082:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80103087:	8d 50 01             	lea    0x1(%eax),%edx
8010308a:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80103090:	85 c0                	test   %eax,%eax
80103092:	75 14                	jne    801030a8 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103094:	8b 45 04             	mov    0x4(%ebp),%eax
80103097:	83 ec 08             	sub    $0x8,%esp
8010309a:	50                   	push   %eax
8010309b:	68 fc 94 10 80       	push   $0x801094fc
801030a0:	e8 21 d3 ff ff       	call   801003c6 <cprintf>
801030a5:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
801030a8:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030ad:	85 c0                	test   %eax,%eax
801030af:	74 0f                	je     801030c0 <cpunum+0x52>
    return lapic[ID]>>24;
801030b1:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030b6:	83 c0 20             	add    $0x20,%eax
801030b9:	8b 00                	mov    (%eax),%eax
801030bb:	c1 e8 18             	shr    $0x18,%eax
801030be:	eb 05                	jmp    801030c5 <cpunum+0x57>
  return 0;
801030c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801030c5:	c9                   	leave  
801030c6:	c3                   	ret    

801030c7 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801030c7:	55                   	push   %ebp
801030c8:	89 e5                	mov    %esp,%ebp
  if(lapic)
801030ca:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030cf:	85 c0                	test   %eax,%eax
801030d1:	74 0c                	je     801030df <lapiceoi+0x18>
    lapicw(EOI, 0);
801030d3:	6a 00                	push   $0x0
801030d5:	6a 2c                	push   $0x2c
801030d7:	e8 52 fe ff ff       	call   80102f2e <lapicw>
801030dc:	83 c4 08             	add    $0x8,%esp
}
801030df:	90                   	nop
801030e0:	c9                   	leave  
801030e1:	c3                   	ret    

801030e2 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801030e2:	55                   	push   %ebp
801030e3:	89 e5                	mov    %esp,%ebp
}
801030e5:	90                   	nop
801030e6:	5d                   	pop    %ebp
801030e7:	c3                   	ret    

801030e8 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801030e8:	55                   	push   %ebp
801030e9:	89 e5                	mov    %esp,%ebp
801030eb:	83 ec 14             	sub    $0x14,%esp
801030ee:	8b 45 08             	mov    0x8(%ebp),%eax
801030f1:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801030f4:	6a 0f                	push   $0xf
801030f6:	6a 70                	push   $0x70
801030f8:	e8 02 fe ff ff       	call   80102eff <outb>
801030fd:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103100:	6a 0a                	push   $0xa
80103102:	6a 71                	push   $0x71
80103104:	e8 f6 fd ff ff       	call   80102eff <outb>
80103109:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010310c:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103113:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103116:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010311b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010311e:	83 c0 02             	add    $0x2,%eax
80103121:	8b 55 0c             	mov    0xc(%ebp),%edx
80103124:	c1 ea 04             	shr    $0x4,%edx
80103127:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010312a:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010312e:	c1 e0 18             	shl    $0x18,%eax
80103131:	50                   	push   %eax
80103132:	68 c4 00 00 00       	push   $0xc4
80103137:	e8 f2 fd ff ff       	call   80102f2e <lapicw>
8010313c:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010313f:	68 00 c5 00 00       	push   $0xc500
80103144:	68 c0 00 00 00       	push   $0xc0
80103149:	e8 e0 fd ff ff       	call   80102f2e <lapicw>
8010314e:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103151:	68 c8 00 00 00       	push   $0xc8
80103156:	e8 87 ff ff ff       	call   801030e2 <microdelay>
8010315b:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010315e:	68 00 85 00 00       	push   $0x8500
80103163:	68 c0 00 00 00       	push   $0xc0
80103168:	e8 c1 fd ff ff       	call   80102f2e <lapicw>
8010316d:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103170:	6a 64                	push   $0x64
80103172:	e8 6b ff ff ff       	call   801030e2 <microdelay>
80103177:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010317a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103181:	eb 3d                	jmp    801031c0 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103183:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103187:	c1 e0 18             	shl    $0x18,%eax
8010318a:	50                   	push   %eax
8010318b:	68 c4 00 00 00       	push   $0xc4
80103190:	e8 99 fd ff ff       	call   80102f2e <lapicw>
80103195:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103198:	8b 45 0c             	mov    0xc(%ebp),%eax
8010319b:	c1 e8 0c             	shr    $0xc,%eax
8010319e:	80 cc 06             	or     $0x6,%ah
801031a1:	50                   	push   %eax
801031a2:	68 c0 00 00 00       	push   $0xc0
801031a7:	e8 82 fd ff ff       	call   80102f2e <lapicw>
801031ac:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801031af:	68 c8 00 00 00       	push   $0xc8
801031b4:	e8 29 ff ff ff       	call   801030e2 <microdelay>
801031b9:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031bc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801031c0:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801031c4:	7e bd                	jle    80103183 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801031c6:	90                   	nop
801031c7:	c9                   	leave  
801031c8:	c3                   	ret    

801031c9 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801031c9:	55                   	push   %ebp
801031ca:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801031cc:	8b 45 08             	mov    0x8(%ebp),%eax
801031cf:	0f b6 c0             	movzbl %al,%eax
801031d2:	50                   	push   %eax
801031d3:	6a 70                	push   $0x70
801031d5:	e8 25 fd ff ff       	call   80102eff <outb>
801031da:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031dd:	68 c8 00 00 00       	push   $0xc8
801031e2:	e8 fb fe ff ff       	call   801030e2 <microdelay>
801031e7:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801031ea:	6a 71                	push   $0x71
801031ec:	e8 f1 fc ff ff       	call   80102ee2 <inb>
801031f1:	83 c4 04             	add    $0x4,%esp
801031f4:	0f b6 c0             	movzbl %al,%eax
}
801031f7:	c9                   	leave  
801031f8:	c3                   	ret    

801031f9 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801031f9:	55                   	push   %ebp
801031fa:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801031fc:	6a 00                	push   $0x0
801031fe:	e8 c6 ff ff ff       	call   801031c9 <cmos_read>
80103203:	83 c4 04             	add    $0x4,%esp
80103206:	89 c2                	mov    %eax,%edx
80103208:	8b 45 08             	mov    0x8(%ebp),%eax
8010320b:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
8010320d:	6a 02                	push   $0x2
8010320f:	e8 b5 ff ff ff       	call   801031c9 <cmos_read>
80103214:	83 c4 04             	add    $0x4,%esp
80103217:	89 c2                	mov    %eax,%edx
80103219:	8b 45 08             	mov    0x8(%ebp),%eax
8010321c:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010321f:	6a 04                	push   $0x4
80103221:	e8 a3 ff ff ff       	call   801031c9 <cmos_read>
80103226:	83 c4 04             	add    $0x4,%esp
80103229:	89 c2                	mov    %eax,%edx
8010322b:	8b 45 08             	mov    0x8(%ebp),%eax
8010322e:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103231:	6a 07                	push   $0x7
80103233:	e8 91 ff ff ff       	call   801031c9 <cmos_read>
80103238:	83 c4 04             	add    $0x4,%esp
8010323b:	89 c2                	mov    %eax,%edx
8010323d:	8b 45 08             	mov    0x8(%ebp),%eax
80103240:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103243:	6a 08                	push   $0x8
80103245:	e8 7f ff ff ff       	call   801031c9 <cmos_read>
8010324a:	83 c4 04             	add    $0x4,%esp
8010324d:	89 c2                	mov    %eax,%edx
8010324f:	8b 45 08             	mov    0x8(%ebp),%eax
80103252:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103255:	6a 09                	push   $0x9
80103257:	e8 6d ff ff ff       	call   801031c9 <cmos_read>
8010325c:	83 c4 04             	add    $0x4,%esp
8010325f:	89 c2                	mov    %eax,%edx
80103261:	8b 45 08             	mov    0x8(%ebp),%eax
80103264:	89 50 14             	mov    %edx,0x14(%eax)
}
80103267:	90                   	nop
80103268:	c9                   	leave  
80103269:	c3                   	ret    

8010326a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010326a:	55                   	push   %ebp
8010326b:	89 e5                	mov    %esp,%ebp
8010326d:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103270:	6a 0b                	push   $0xb
80103272:	e8 52 ff ff ff       	call   801031c9 <cmos_read>
80103277:	83 c4 04             	add    $0x4,%esp
8010327a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010327d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103280:	83 e0 04             	and    $0x4,%eax
80103283:	85 c0                	test   %eax,%eax
80103285:	0f 94 c0             	sete   %al
80103288:	0f b6 c0             	movzbl %al,%eax
8010328b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010328e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103291:	50                   	push   %eax
80103292:	e8 62 ff ff ff       	call   801031f9 <fill_rtcdate>
80103297:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010329a:	6a 0a                	push   $0xa
8010329c:	e8 28 ff ff ff       	call   801031c9 <cmos_read>
801032a1:	83 c4 04             	add    $0x4,%esp
801032a4:	25 80 00 00 00       	and    $0x80,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	75 27                	jne    801032d4 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801032ad:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032b0:	50                   	push   %eax
801032b1:	e8 43 ff ff ff       	call   801031f9 <fill_rtcdate>
801032b6:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801032b9:	83 ec 04             	sub    $0x4,%esp
801032bc:	6a 18                	push   $0x18
801032be:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032c1:	50                   	push   %eax
801032c2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032c5:	50                   	push   %eax
801032c6:	e8 0c 2c 00 00       	call   80105ed7 <memcmp>
801032cb:	83 c4 10             	add    $0x10,%esp
801032ce:	85 c0                	test   %eax,%eax
801032d0:	74 05                	je     801032d7 <cmostime+0x6d>
801032d2:	eb ba                	jmp    8010328e <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801032d4:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801032d5:	eb b7                	jmp    8010328e <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801032d7:	90                   	nop
  }

  // convert
  if (bcd) {
801032d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801032dc:	0f 84 b4 00 00 00    	je     80103396 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801032e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032e5:	c1 e8 04             	shr    $0x4,%eax
801032e8:	89 c2                	mov    %eax,%edx
801032ea:	89 d0                	mov    %edx,%eax
801032ec:	c1 e0 02             	shl    $0x2,%eax
801032ef:	01 d0                	add    %edx,%eax
801032f1:	01 c0                	add    %eax,%eax
801032f3:	89 c2                	mov    %eax,%edx
801032f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032f8:	83 e0 0f             	and    $0xf,%eax
801032fb:	01 d0                	add    %edx,%eax
801032fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103300:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103303:	c1 e8 04             	shr    $0x4,%eax
80103306:	89 c2                	mov    %eax,%edx
80103308:	89 d0                	mov    %edx,%eax
8010330a:	c1 e0 02             	shl    $0x2,%eax
8010330d:	01 d0                	add    %edx,%eax
8010330f:	01 c0                	add    %eax,%eax
80103311:	89 c2                	mov    %eax,%edx
80103313:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103316:	83 e0 0f             	and    $0xf,%eax
80103319:	01 d0                	add    %edx,%eax
8010331b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010331e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103321:	c1 e8 04             	shr    $0x4,%eax
80103324:	89 c2                	mov    %eax,%edx
80103326:	89 d0                	mov    %edx,%eax
80103328:	c1 e0 02             	shl    $0x2,%eax
8010332b:	01 d0                	add    %edx,%eax
8010332d:	01 c0                	add    %eax,%eax
8010332f:	89 c2                	mov    %eax,%edx
80103331:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103334:	83 e0 0f             	and    $0xf,%eax
80103337:	01 d0                	add    %edx,%eax
80103339:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010333c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010333f:	c1 e8 04             	shr    $0x4,%eax
80103342:	89 c2                	mov    %eax,%edx
80103344:	89 d0                	mov    %edx,%eax
80103346:	c1 e0 02             	shl    $0x2,%eax
80103349:	01 d0                	add    %edx,%eax
8010334b:	01 c0                	add    %eax,%eax
8010334d:	89 c2                	mov    %eax,%edx
8010334f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103352:	83 e0 0f             	and    $0xf,%eax
80103355:	01 d0                	add    %edx,%eax
80103357:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010335a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010335d:	c1 e8 04             	shr    $0x4,%eax
80103360:	89 c2                	mov    %eax,%edx
80103362:	89 d0                	mov    %edx,%eax
80103364:	c1 e0 02             	shl    $0x2,%eax
80103367:	01 d0                	add    %edx,%eax
80103369:	01 c0                	add    %eax,%eax
8010336b:	89 c2                	mov    %eax,%edx
8010336d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103370:	83 e0 0f             	and    $0xf,%eax
80103373:	01 d0                	add    %edx,%eax
80103375:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103378:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010337b:	c1 e8 04             	shr    $0x4,%eax
8010337e:	89 c2                	mov    %eax,%edx
80103380:	89 d0                	mov    %edx,%eax
80103382:	c1 e0 02             	shl    $0x2,%eax
80103385:	01 d0                	add    %edx,%eax
80103387:	01 c0                	add    %eax,%eax
80103389:	89 c2                	mov    %eax,%edx
8010338b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010338e:	83 e0 0f             	and    $0xf,%eax
80103391:	01 d0                	add    %edx,%eax
80103393:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103396:	8b 45 08             	mov    0x8(%ebp),%eax
80103399:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010339c:	89 10                	mov    %edx,(%eax)
8010339e:	8b 55 dc             	mov    -0x24(%ebp),%edx
801033a1:	89 50 04             	mov    %edx,0x4(%eax)
801033a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801033a7:	89 50 08             	mov    %edx,0x8(%eax)
801033aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801033ad:	89 50 0c             	mov    %edx,0xc(%eax)
801033b0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801033b3:	89 50 10             	mov    %edx,0x10(%eax)
801033b6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801033b9:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801033bc:	8b 45 08             	mov    0x8(%ebp),%eax
801033bf:	8b 40 14             	mov    0x14(%eax),%eax
801033c2:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801033c8:	8b 45 08             	mov    0x8(%ebp),%eax
801033cb:	89 50 14             	mov    %edx,0x14(%eax)
}
801033ce:	90                   	nop
801033cf:	c9                   	leave  
801033d0:	c3                   	ret    

801033d1 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801033d1:	55                   	push   %ebp
801033d2:	89 e5                	mov    %esp,%ebp
801033d4:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801033d7:	83 ec 08             	sub    $0x8,%esp
801033da:	68 28 95 10 80       	push   $0x80109528
801033df:	68 80 32 11 80       	push   $0x80113280
801033e4:	e8 02 28 00 00       	call   80105beb <initlock>
801033e9:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801033ec:	83 ec 08             	sub    $0x8,%esp
801033ef:	8d 45 dc             	lea    -0x24(%ebp),%eax
801033f2:	50                   	push   %eax
801033f3:	ff 75 08             	pushl  0x8(%ebp)
801033f6:	e8 2b e0 ff ff       	call   80101426 <readsb>
801033fb:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801033fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103401:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
80103406:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103409:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = dev;
8010340e:	8b 45 08             	mov    0x8(%ebp),%eax
80103411:	a3 c4 32 11 80       	mov    %eax,0x801132c4
  recover_from_log();
80103416:	e8 b2 01 00 00       	call   801035cd <recover_from_log>
}
8010341b:	90                   	nop
8010341c:	c9                   	leave  
8010341d:	c3                   	ret    

8010341e <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010341e:	55                   	push   %ebp
8010341f:	89 e5                	mov    %esp,%ebp
80103421:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103424:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010342b:	e9 95 00 00 00       	jmp    801034c5 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103430:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103439:	01 d0                	add    %edx,%eax
8010343b:	83 c0 01             	add    $0x1,%eax
8010343e:	89 c2                	mov    %eax,%edx
80103440:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103445:	83 ec 08             	sub    $0x8,%esp
80103448:	52                   	push   %edx
80103449:	50                   	push   %eax
8010344a:	e8 67 cd ff ff       	call   801001b6 <bread>
8010344f:	83 c4 10             	add    $0x10,%esp
80103452:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103458:	83 c0 10             	add    $0x10,%eax
8010345b:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103462:	89 c2                	mov    %eax,%edx
80103464:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103469:	83 ec 08             	sub    $0x8,%esp
8010346c:	52                   	push   %edx
8010346d:	50                   	push   %eax
8010346e:	e8 43 cd ff ff       	call   801001b6 <bread>
80103473:	83 c4 10             	add    $0x10,%esp
80103476:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010347c:	8d 50 18             	lea    0x18(%eax),%edx
8010347f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103482:	83 c0 18             	add    $0x18,%eax
80103485:	83 ec 04             	sub    $0x4,%esp
80103488:	68 00 02 00 00       	push   $0x200
8010348d:	52                   	push   %edx
8010348e:	50                   	push   %eax
8010348f:	e8 9b 2a 00 00       	call   80105f2f <memmove>
80103494:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103497:	83 ec 0c             	sub    $0xc,%esp
8010349a:	ff 75 ec             	pushl  -0x14(%ebp)
8010349d:	e8 4d cd ff ff       	call   801001ef <bwrite>
801034a2:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
801034a5:	83 ec 0c             	sub    $0xc,%esp
801034a8:	ff 75 f0             	pushl  -0x10(%ebp)
801034ab:	e8 7e cd ff ff       	call   8010022e <brelse>
801034b0:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801034b3:	83 ec 0c             	sub    $0xc,%esp
801034b6:	ff 75 ec             	pushl  -0x14(%ebp)
801034b9:	e8 70 cd ff ff       	call   8010022e <brelse>
801034be:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034c5:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801034ca:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034cd:	0f 8f 5d ff ff ff    	jg     80103430 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801034d3:	90                   	nop
801034d4:	c9                   	leave  
801034d5:	c3                   	ret    

801034d6 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801034d6:	55                   	push   %ebp
801034d7:	89 e5                	mov    %esp,%ebp
801034d9:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034dc:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801034e1:	89 c2                	mov    %eax,%edx
801034e3:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801034e8:	83 ec 08             	sub    $0x8,%esp
801034eb:	52                   	push   %edx
801034ec:	50                   	push   %eax
801034ed:	e8 c4 cc ff ff       	call   801001b6 <bread>
801034f2:	83 c4 10             	add    $0x10,%esp
801034f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801034f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034fb:	83 c0 18             	add    $0x18,%eax
801034fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103501:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103504:	8b 00                	mov    (%eax),%eax
80103506:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
8010350b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103512:	eb 1b                	jmp    8010352f <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103514:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103517:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010351a:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010351e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103521:	83 c2 10             	add    $0x10,%edx
80103524:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010352b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010352f:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103534:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103537:	7f db                	jg     80103514 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103539:	83 ec 0c             	sub    $0xc,%esp
8010353c:	ff 75 f0             	pushl  -0x10(%ebp)
8010353f:	e8 ea cc ff ff       	call   8010022e <brelse>
80103544:	83 c4 10             	add    $0x10,%esp
}
80103547:	90                   	nop
80103548:	c9                   	leave  
80103549:	c3                   	ret    

8010354a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010354a:	55                   	push   %ebp
8010354b:	89 e5                	mov    %esp,%ebp
8010354d:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103550:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80103555:	89 c2                	mov    %eax,%edx
80103557:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010355c:	83 ec 08             	sub    $0x8,%esp
8010355f:	52                   	push   %edx
80103560:	50                   	push   %eax
80103561:	e8 50 cc ff ff       	call   801001b6 <bread>
80103566:	83 c4 10             	add    $0x10,%esp
80103569:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010356c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010356f:	83 c0 18             	add    $0x18,%eax
80103572:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103575:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
8010357b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010357e:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103580:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103587:	eb 1b                	jmp    801035a4 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010358c:	83 c0 10             	add    $0x10,%eax
8010358f:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
80103596:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103599:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010359c:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801035a0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035a4:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801035a9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035ac:	7f db                	jg     80103589 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801035ae:	83 ec 0c             	sub    $0xc,%esp
801035b1:	ff 75 f0             	pushl  -0x10(%ebp)
801035b4:	e8 36 cc ff ff       	call   801001ef <bwrite>
801035b9:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801035bc:	83 ec 0c             	sub    $0xc,%esp
801035bf:	ff 75 f0             	pushl  -0x10(%ebp)
801035c2:	e8 67 cc ff ff       	call   8010022e <brelse>
801035c7:	83 c4 10             	add    $0x10,%esp
}
801035ca:	90                   	nop
801035cb:	c9                   	leave  
801035cc:	c3                   	ret    

801035cd <recover_from_log>:

static void
recover_from_log(void)
{
801035cd:	55                   	push   %ebp
801035ce:	89 e5                	mov    %esp,%ebp
801035d0:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801035d3:	e8 fe fe ff ff       	call   801034d6 <read_head>
  install_trans(); // if committed, copy from log to disk
801035d8:	e8 41 fe ff ff       	call   8010341e <install_trans>
  log.lh.n = 0;
801035dd:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801035e4:	00 00 00 
  write_head(); // clear the log
801035e7:	e8 5e ff ff ff       	call   8010354a <write_head>
}
801035ec:	90                   	nop
801035ed:	c9                   	leave  
801035ee:	c3                   	ret    

801035ef <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801035ef:	55                   	push   %ebp
801035f0:	89 e5                	mov    %esp,%ebp
801035f2:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801035f5:	83 ec 0c             	sub    $0xc,%esp
801035f8:	68 80 32 11 80       	push   $0x80113280
801035fd:	e8 0b 26 00 00       	call   80105c0d <acquire>
80103602:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103605:	a1 c0 32 11 80       	mov    0x801132c0,%eax
8010360a:	85 c0                	test   %eax,%eax
8010360c:	74 17                	je     80103625 <begin_op+0x36>
      sleep(&log, &log.lock);
8010360e:	83 ec 08             	sub    $0x8,%esp
80103611:	68 80 32 11 80       	push   $0x80113280
80103616:	68 80 32 11 80       	push   $0x80113280
8010361b:	e8 b4 1a 00 00       	call   801050d4 <sleep>
80103620:	83 c4 10             	add    $0x10,%esp
80103623:	eb e0                	jmp    80103605 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103625:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
8010362b:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103630:	8d 50 01             	lea    0x1(%eax),%edx
80103633:	89 d0                	mov    %edx,%eax
80103635:	c1 e0 02             	shl    $0x2,%eax
80103638:	01 d0                	add    %edx,%eax
8010363a:	01 c0                	add    %eax,%eax
8010363c:	01 c8                	add    %ecx,%eax
8010363e:	83 f8 1e             	cmp    $0x1e,%eax
80103641:	7e 17                	jle    8010365a <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103643:	83 ec 08             	sub    $0x8,%esp
80103646:	68 80 32 11 80       	push   $0x80113280
8010364b:	68 80 32 11 80       	push   $0x80113280
80103650:	e8 7f 1a 00 00       	call   801050d4 <sleep>
80103655:	83 c4 10             	add    $0x10,%esp
80103658:	eb ab                	jmp    80103605 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010365a:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010365f:	83 c0 01             	add    $0x1,%eax
80103662:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
80103667:	83 ec 0c             	sub    $0xc,%esp
8010366a:	68 80 32 11 80       	push   $0x80113280
8010366f:	e8 00 26 00 00       	call   80105c74 <release>
80103674:	83 c4 10             	add    $0x10,%esp
      break;
80103677:	90                   	nop
    }
  }
}
80103678:	90                   	nop
80103679:	c9                   	leave  
8010367a:	c3                   	ret    

8010367b <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010367b:	55                   	push   %ebp
8010367c:	89 e5                	mov    %esp,%ebp
8010367e:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103681:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103688:	83 ec 0c             	sub    $0xc,%esp
8010368b:	68 80 32 11 80       	push   $0x80113280
80103690:	e8 78 25 00 00       	call   80105c0d <acquire>
80103695:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103698:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010369d:	83 e8 01             	sub    $0x1,%eax
801036a0:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
801036a5:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801036aa:	85 c0                	test   %eax,%eax
801036ac:	74 0d                	je     801036bb <end_op+0x40>
    panic("log.committing");
801036ae:	83 ec 0c             	sub    $0xc,%esp
801036b1:	68 2c 95 10 80       	push   $0x8010952c
801036b6:	e8 ab ce ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801036bb:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801036c0:	85 c0                	test   %eax,%eax
801036c2:	75 13                	jne    801036d7 <end_op+0x5c>
    do_commit = 1;
801036c4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036cb:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
801036d2:	00 00 00 
801036d5:	eb 10                	jmp    801036e7 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801036d7:	83 ec 0c             	sub    $0xc,%esp
801036da:	68 80 32 11 80       	push   $0x80113280
801036df:	e8 0d 1b 00 00       	call   801051f1 <wakeup>
801036e4:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036e7:	83 ec 0c             	sub    $0xc,%esp
801036ea:	68 80 32 11 80       	push   $0x80113280
801036ef:	e8 80 25 00 00       	call   80105c74 <release>
801036f4:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801036f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801036fb:	74 3f                	je     8010373c <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801036fd:	e8 f5 00 00 00       	call   801037f7 <commit>
    acquire(&log.lock);
80103702:	83 ec 0c             	sub    $0xc,%esp
80103705:	68 80 32 11 80       	push   $0x80113280
8010370a:	e8 fe 24 00 00       	call   80105c0d <acquire>
8010370f:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103712:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
80103719:	00 00 00 
    wakeup(&log);
8010371c:	83 ec 0c             	sub    $0xc,%esp
8010371f:	68 80 32 11 80       	push   $0x80113280
80103724:	e8 c8 1a 00 00       	call   801051f1 <wakeup>
80103729:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010372c:	83 ec 0c             	sub    $0xc,%esp
8010372f:	68 80 32 11 80       	push   $0x80113280
80103734:	e8 3b 25 00 00       	call   80105c74 <release>
80103739:	83 c4 10             	add    $0x10,%esp
  }
}
8010373c:	90                   	nop
8010373d:	c9                   	leave  
8010373e:	c3                   	ret    

8010373f <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010373f:	55                   	push   %ebp
80103740:	89 e5                	mov    %esp,%ebp
80103742:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103745:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010374c:	e9 95 00 00 00       	jmp    801037e6 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103751:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010375a:	01 d0                	add    %edx,%eax
8010375c:	83 c0 01             	add    $0x1,%eax
8010375f:	89 c2                	mov    %eax,%edx
80103761:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103766:	83 ec 08             	sub    $0x8,%esp
80103769:	52                   	push   %edx
8010376a:	50                   	push   %eax
8010376b:	e8 46 ca ff ff       	call   801001b6 <bread>
80103770:	83 c4 10             	add    $0x10,%esp
80103773:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103779:	83 c0 10             	add    $0x10,%eax
8010377c:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103783:	89 c2                	mov    %eax,%edx
80103785:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010378a:	83 ec 08             	sub    $0x8,%esp
8010378d:	52                   	push   %edx
8010378e:	50                   	push   %eax
8010378f:	e8 22 ca ff ff       	call   801001b6 <bread>
80103794:	83 c4 10             	add    $0x10,%esp
80103797:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010379a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010379d:	8d 50 18             	lea    0x18(%eax),%edx
801037a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037a3:	83 c0 18             	add    $0x18,%eax
801037a6:	83 ec 04             	sub    $0x4,%esp
801037a9:	68 00 02 00 00       	push   $0x200
801037ae:	52                   	push   %edx
801037af:	50                   	push   %eax
801037b0:	e8 7a 27 00 00       	call   80105f2f <memmove>
801037b5:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801037b8:	83 ec 0c             	sub    $0xc,%esp
801037bb:	ff 75 f0             	pushl  -0x10(%ebp)
801037be:	e8 2c ca ff ff       	call   801001ef <bwrite>
801037c3:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	ff 75 ec             	pushl  -0x14(%ebp)
801037cc:	e8 5d ca ff ff       	call   8010022e <brelse>
801037d1:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801037d4:	83 ec 0c             	sub    $0xc,%esp
801037d7:	ff 75 f0             	pushl  -0x10(%ebp)
801037da:	e8 4f ca ff ff       	call   8010022e <brelse>
801037df:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037e6:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037eb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037ee:	0f 8f 5d ff ff ff    	jg     80103751 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801037f4:	90                   	nop
801037f5:	c9                   	leave  
801037f6:	c3                   	ret    

801037f7 <commit>:

static void
commit()
{
801037f7:	55                   	push   %ebp
801037f8:	89 e5                	mov    %esp,%ebp
801037fa:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801037fd:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103802:	85 c0                	test   %eax,%eax
80103804:	7e 1e                	jle    80103824 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103806:	e8 34 ff ff ff       	call   8010373f <write_log>
    write_head();    // Write header to disk -- the real commit
8010380b:	e8 3a fd ff ff       	call   8010354a <write_head>
    install_trans(); // Now install writes to home locations
80103810:	e8 09 fc ff ff       	call   8010341e <install_trans>
    log.lh.n = 0; 
80103815:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
8010381c:	00 00 00 
    write_head();    // Erase the transaction from the log
8010381f:	e8 26 fd ff ff       	call   8010354a <write_head>
  }
}
80103824:	90                   	nop
80103825:	c9                   	leave  
80103826:	c3                   	ret    

80103827 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103827:	55                   	push   %ebp
80103828:	89 e5                	mov    %esp,%ebp
8010382a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010382d:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103832:	83 f8 1d             	cmp    $0x1d,%eax
80103835:	7f 12                	jg     80103849 <log_write+0x22>
80103837:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010383c:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
80103842:	83 ea 01             	sub    $0x1,%edx
80103845:	39 d0                	cmp    %edx,%eax
80103847:	7c 0d                	jl     80103856 <log_write+0x2f>
    panic("too big a transaction");
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	68 3b 95 10 80       	push   $0x8010953b
80103851:	e8 10 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103856:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010385b:	85 c0                	test   %eax,%eax
8010385d:	7f 0d                	jg     8010386c <log_write+0x45>
    panic("log_write outside of trans");
8010385f:	83 ec 0c             	sub    $0xc,%esp
80103862:	68 51 95 10 80       	push   $0x80109551
80103867:	e8 fa cc ff ff       	call   80100566 <panic>

  acquire(&log.lock);
8010386c:	83 ec 0c             	sub    $0xc,%esp
8010386f:	68 80 32 11 80       	push   $0x80113280
80103874:	e8 94 23 00 00       	call   80105c0d <acquire>
80103879:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
8010387c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103883:	eb 1d                	jmp    801038a2 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103888:	83 c0 10             	add    $0x10,%eax
8010388b:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103892:	89 c2                	mov    %eax,%edx
80103894:	8b 45 08             	mov    0x8(%ebp),%eax
80103897:	8b 40 08             	mov    0x8(%eax),%eax
8010389a:	39 c2                	cmp    %eax,%edx
8010389c:	74 10                	je     801038ae <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010389e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038a2:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038a7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038aa:	7f d9                	jg     80103885 <log_write+0x5e>
801038ac:	eb 01                	jmp    801038af <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
801038ae:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801038af:	8b 45 08             	mov    0x8(%ebp),%eax
801038b2:	8b 40 08             	mov    0x8(%eax),%eax
801038b5:	89 c2                	mov    %eax,%edx
801038b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038ba:	83 c0 10             	add    $0x10,%eax
801038bd:	89 14 85 8c 32 11 80 	mov    %edx,-0x7feecd74(,%eax,4)
  if (i == log.lh.n)
801038c4:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038c9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038cc:	75 0d                	jne    801038db <log_write+0xb4>
    log.lh.n++;
801038ce:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038d3:	83 c0 01             	add    $0x1,%eax
801038d6:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
801038db:	8b 45 08             	mov    0x8(%ebp),%eax
801038de:	8b 00                	mov    (%eax),%eax
801038e0:	83 c8 04             	or     $0x4,%eax
801038e3:	89 c2                	mov    %eax,%edx
801038e5:	8b 45 08             	mov    0x8(%ebp),%eax
801038e8:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038ea:	83 ec 0c             	sub    $0xc,%esp
801038ed:	68 80 32 11 80       	push   $0x80113280
801038f2:	e8 7d 23 00 00       	call   80105c74 <release>
801038f7:	83 c4 10             	add    $0x10,%esp
}
801038fa:	90                   	nop
801038fb:	c9                   	leave  
801038fc:	c3                   	ret    

801038fd <v2p>:
801038fd:	55                   	push   %ebp
801038fe:	89 e5                	mov    %esp,%ebp
80103900:	8b 45 08             	mov    0x8(%ebp),%eax
80103903:	05 00 00 00 80       	add    $0x80000000,%eax
80103908:	5d                   	pop    %ebp
80103909:	c3                   	ret    

8010390a <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010390a:	55                   	push   %ebp
8010390b:	89 e5                	mov    %esp,%ebp
8010390d:	8b 45 08             	mov    0x8(%ebp),%eax
80103910:	05 00 00 00 80       	add    $0x80000000,%eax
80103915:	5d                   	pop    %ebp
80103916:	c3                   	ret    

80103917 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103917:	55                   	push   %ebp
80103918:	89 e5                	mov    %esp,%ebp
8010391a:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010391d:	8b 55 08             	mov    0x8(%ebp),%edx
80103920:	8b 45 0c             	mov    0xc(%ebp),%eax
80103923:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103926:	f0 87 02             	lock xchg %eax,(%edx)
80103929:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010392c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010392f:	c9                   	leave  
80103930:	c3                   	ret    

80103931 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103931:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103935:	83 e4 f0             	and    $0xfffffff0,%esp
80103938:	ff 71 fc             	pushl  -0x4(%ecx)
8010393b:	55                   	push   %ebp
8010393c:	89 e5                	mov    %esp,%ebp
8010393e:	51                   	push   %ecx
8010393f:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103942:	83 ec 08             	sub    $0x8,%esp
80103945:	68 00 00 40 80       	push   $0x80400000
8010394a:	68 3c 67 11 80       	push   $0x8011673c
8010394f:	e8 7d f2 ff ff       	call   80102bd1 <kinit1>
80103954:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103957:	e8 dd 51 00 00       	call   80108b39 <kvmalloc>
  mpinit();        // collect info about this machine
8010395c:	e8 43 04 00 00       	call   80103da4 <mpinit>
  lapicinit();
80103961:	e8 ea f5 ff ff       	call   80102f50 <lapicinit>
  seginit();       // set up segments
80103966:	e8 77 4b 00 00       	call   801084e2 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
8010396b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103971:	0f b6 00             	movzbl (%eax),%eax
80103974:	0f b6 c0             	movzbl %al,%eax
80103977:	83 ec 08             	sub    $0x8,%esp
8010397a:	50                   	push   %eax
8010397b:	68 6c 95 10 80       	push   $0x8010956c
80103980:	e8 41 ca ff ff       	call   801003c6 <cprintf>
80103985:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103988:	e8 6d 06 00 00       	call   80103ffa <picinit>
  ioapicinit();    // another interrupt controller
8010398d:	e8 34 f1 ff ff       	call   80102ac6 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103992:	e8 24 d2 ff ff       	call   80100bbb <consoleinit>
  uartinit();      // serial port
80103997:	e8 a2 3e 00 00       	call   8010783e <uartinit>
  pinit();         // process table
8010399c:	e8 5d 0b 00 00       	call   801044fe <pinit>
  tvinit();        // trap vectors
801039a1:	e8 71 3a 00 00       	call   80107417 <tvinit>
  binit();         // buffer cache
801039a6:	e8 89 c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801039ab:	e8 67 d6 ff ff       	call   80101017 <fileinit>
  ideinit();       // disk
801039b0:	e8 19 ed ff ff       	call   801026ce <ideinit>
  if(!ismp)
801039b5:	a1 64 33 11 80       	mov    0x80113364,%eax
801039ba:	85 c0                	test   %eax,%eax
801039bc:	75 05                	jne    801039c3 <main+0x92>
    timerinit();   // uniprocessor timer
801039be:	e8 a5 39 00 00       	call   80107368 <timerinit>
  startothers();   // start other processors
801039c3:	e8 7f 00 00 00       	call   80103a47 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801039c8:	83 ec 08             	sub    $0x8,%esp
801039cb:	68 00 00 00 8e       	push   $0x8e000000
801039d0:	68 00 00 40 80       	push   $0x80400000
801039d5:	e8 30 f2 ff ff       	call   80102c0a <kinit2>
801039da:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801039dd:	e8 80 0c 00 00       	call   80104662 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801039e2:	e8 1a 00 00 00       	call   80103a01 <mpmain>

801039e7 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801039e7:	55                   	push   %ebp
801039e8:	89 e5                	mov    %esp,%ebp
801039ea:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801039ed:	e8 5f 51 00 00       	call   80108b51 <switchkvm>
  seginit();
801039f2:	e8 eb 4a 00 00       	call   801084e2 <seginit>
  lapicinit();
801039f7:	e8 54 f5 ff ff       	call   80102f50 <lapicinit>
  mpmain();
801039fc:	e8 00 00 00 00       	call   80103a01 <mpmain>

80103a01 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103a01:	55                   	push   %ebp
80103a02:	89 e5                	mov    %esp,%ebp
80103a04:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103a07:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a0d:	0f b6 00             	movzbl (%eax),%eax
80103a10:	0f b6 c0             	movzbl %al,%eax
80103a13:	83 ec 08             	sub    $0x8,%esp
80103a16:	50                   	push   %eax
80103a17:	68 83 95 10 80       	push   $0x80109583
80103a1c:	e8 a5 c9 ff ff       	call   801003c6 <cprintf>
80103a21:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a24:	e8 4f 3b 00 00       	call   80107578 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103a29:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a2f:	05 a8 00 00 00       	add    $0xa8,%eax
80103a34:	83 ec 08             	sub    $0x8,%esp
80103a37:	6a 01                	push   $0x1
80103a39:	50                   	push   %eax
80103a3a:	e8 d8 fe ff ff       	call   80103917 <xchg>
80103a3f:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103a42:	e8 3a 14 00 00       	call   80104e81 <scheduler>

80103a47 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a47:	55                   	push   %ebp
80103a48:	89 e5                	mov    %esp,%ebp
80103a4a:	53                   	push   %ebx
80103a4b:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103a4e:	68 00 70 00 00       	push   $0x7000
80103a53:	e8 b2 fe ff ff       	call   8010390a <p2v>
80103a58:	83 c4 04             	add    $0x4,%esp
80103a5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a5e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a63:	83 ec 04             	sub    $0x4,%esp
80103a66:	50                   	push   %eax
80103a67:	68 2c c5 10 80       	push   $0x8010c52c
80103a6c:	ff 75 f0             	pushl  -0x10(%ebp)
80103a6f:	e8 bb 24 00 00       	call   80105f2f <memmove>
80103a74:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103a77:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
80103a7e:	e9 90 00 00 00       	jmp    80103b13 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103a83:	e8 e6 f5 ff ff       	call   8010306e <cpunum>
80103a88:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a8e:	05 80 33 11 80       	add    $0x80113380,%eax
80103a93:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a96:	74 73                	je     80103b0b <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a98:	e8 6b f2 ff ff       	call   80102d08 <kalloc>
80103a9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103aa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aa3:	83 e8 04             	sub    $0x4,%eax
80103aa6:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103aa9:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103aaf:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ab4:	83 e8 08             	sub    $0x8,%eax
80103ab7:	c7 00 e7 39 10 80    	movl   $0x801039e7,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac0:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103ac3:	83 ec 0c             	sub    $0xc,%esp
80103ac6:	68 00 b0 10 80       	push   $0x8010b000
80103acb:	e8 2d fe ff ff       	call   801038fd <v2p>
80103ad0:	83 c4 10             	add    $0x10,%esp
80103ad3:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103ad5:	83 ec 0c             	sub    $0xc,%esp
80103ad8:	ff 75 f0             	pushl  -0x10(%ebp)
80103adb:	e8 1d fe ff ff       	call   801038fd <v2p>
80103ae0:	83 c4 10             	add    $0x10,%esp
80103ae3:	89 c2                	mov    %eax,%edx
80103ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae8:	0f b6 00             	movzbl (%eax),%eax
80103aeb:	0f b6 c0             	movzbl %al,%eax
80103aee:	83 ec 08             	sub    $0x8,%esp
80103af1:	52                   	push   %edx
80103af2:	50                   	push   %eax
80103af3:	e8 f0 f5 ff ff       	call   801030e8 <lapicstartap>
80103af8:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103afb:	90                   	nop
80103afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aff:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103b05:	85 c0                	test   %eax,%eax
80103b07:	74 f3                	je     80103afc <startothers+0xb5>
80103b09:	eb 01                	jmp    80103b0c <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103b0b:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103b0c:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103b13:	a1 60 39 11 80       	mov    0x80113960,%eax
80103b18:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103b1e:	05 80 33 11 80       	add    $0x80113380,%eax
80103b23:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b26:	0f 87 57 ff ff ff    	ja     80103a83 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103b2c:	90                   	nop
80103b2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b30:	c9                   	leave  
80103b31:	c3                   	ret    

80103b32 <p2v>:
80103b32:	55                   	push   %ebp
80103b33:	89 e5                	mov    %esp,%ebp
80103b35:	8b 45 08             	mov    0x8(%ebp),%eax
80103b38:	05 00 00 00 80       	add    $0x80000000,%eax
80103b3d:	5d                   	pop    %ebp
80103b3e:	c3                   	ret    

80103b3f <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80103b3f:	55                   	push   %ebp
80103b40:	89 e5                	mov    %esp,%ebp
80103b42:	83 ec 14             	sub    $0x14,%esp
80103b45:	8b 45 08             	mov    0x8(%ebp),%eax
80103b48:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103b4c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103b50:	89 c2                	mov    %eax,%edx
80103b52:	ec                   	in     (%dx),%al
80103b53:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103b56:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103b5a:	c9                   	leave  
80103b5b:	c3                   	ret    

80103b5c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103b5c:	55                   	push   %ebp
80103b5d:	89 e5                	mov    %esp,%ebp
80103b5f:	83 ec 08             	sub    $0x8,%esp
80103b62:	8b 55 08             	mov    0x8(%ebp),%edx
80103b65:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b68:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103b6c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b6f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b73:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b77:	ee                   	out    %al,(%dx)
}
80103b78:	90                   	nop
80103b79:	c9                   	leave  
80103b7a:	c3                   	ret    

80103b7b <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103b7b:	55                   	push   %ebp
80103b7c:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103b7e:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103b83:	89 c2                	mov    %eax,%edx
80103b85:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103b8a:	29 c2                	sub    %eax,%edx
80103b8c:	89 d0                	mov    %edx,%eax
80103b8e:	c1 f8 02             	sar    $0x2,%eax
80103b91:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b97:	5d                   	pop    %ebp
80103b98:	c3                   	ret    

80103b99 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103b99:	55                   	push   %ebp
80103b9a:	89 e5                	mov    %esp,%ebp
80103b9c:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b9f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103ba6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103bad:	eb 15                	jmp    80103bc4 <sum+0x2b>
    sum += addr[i];
80103baf:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80103bb5:	01 d0                	add    %edx,%eax
80103bb7:	0f b6 00             	movzbl (%eax),%eax
80103bba:	0f b6 c0             	movzbl %al,%eax
80103bbd:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103bc0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103bc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103bc7:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103bca:	7c e3                	jl     80103baf <sum+0x16>
    sum += addr[i];
  return sum;
80103bcc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103bcf:	c9                   	leave  
80103bd0:	c3                   	ret    

80103bd1 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103bd1:	55                   	push   %ebp
80103bd2:	89 e5                	mov    %esp,%ebp
80103bd4:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103bd7:	ff 75 08             	pushl  0x8(%ebp)
80103bda:	e8 53 ff ff ff       	call   80103b32 <p2v>
80103bdf:	83 c4 04             	add    $0x4,%esp
80103be2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103be5:	8b 55 0c             	mov    0xc(%ebp),%edx
80103be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103beb:	01 d0                	add    %edx,%eax
80103bed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bf6:	eb 36                	jmp    80103c2e <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103bf8:	83 ec 04             	sub    $0x4,%esp
80103bfb:	6a 04                	push   $0x4
80103bfd:	68 94 95 10 80       	push   $0x80109594
80103c02:	ff 75 f4             	pushl  -0xc(%ebp)
80103c05:	e8 cd 22 00 00       	call   80105ed7 <memcmp>
80103c0a:	83 c4 10             	add    $0x10,%esp
80103c0d:	85 c0                	test   %eax,%eax
80103c0f:	75 19                	jne    80103c2a <mpsearch1+0x59>
80103c11:	83 ec 08             	sub    $0x8,%esp
80103c14:	6a 10                	push   $0x10
80103c16:	ff 75 f4             	pushl  -0xc(%ebp)
80103c19:	e8 7b ff ff ff       	call   80103b99 <sum>
80103c1e:	83 c4 10             	add    $0x10,%esp
80103c21:	84 c0                	test   %al,%al
80103c23:	75 05                	jne    80103c2a <mpsearch1+0x59>
      return (struct mp*)p;
80103c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c28:	eb 11                	jmp    80103c3b <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103c2a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c31:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103c34:	72 c2                	jb     80103bf8 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103c36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103c3b:	c9                   	leave  
80103c3c:	c3                   	ret    

80103c3d <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103c3d:	55                   	push   %ebp
80103c3e:	89 e5                	mov    %esp,%ebp
80103c40:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103c43:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4d:	83 c0 0f             	add    $0xf,%eax
80103c50:	0f b6 00             	movzbl (%eax),%eax
80103c53:	0f b6 c0             	movzbl %al,%eax
80103c56:	c1 e0 08             	shl    $0x8,%eax
80103c59:	89 c2                	mov    %eax,%edx
80103c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5e:	83 c0 0e             	add    $0xe,%eax
80103c61:	0f b6 00             	movzbl (%eax),%eax
80103c64:	0f b6 c0             	movzbl %al,%eax
80103c67:	09 d0                	or     %edx,%eax
80103c69:	c1 e0 04             	shl    $0x4,%eax
80103c6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c73:	74 21                	je     80103c96 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103c75:	83 ec 08             	sub    $0x8,%esp
80103c78:	68 00 04 00 00       	push   $0x400
80103c7d:	ff 75 f0             	pushl  -0x10(%ebp)
80103c80:	e8 4c ff ff ff       	call   80103bd1 <mpsearch1>
80103c85:	83 c4 10             	add    $0x10,%esp
80103c88:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c8b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c8f:	74 51                	je     80103ce2 <mpsearch+0xa5>
      return mp;
80103c91:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c94:	eb 61                	jmp    80103cf7 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c99:	83 c0 14             	add    $0x14,%eax
80103c9c:	0f b6 00             	movzbl (%eax),%eax
80103c9f:	0f b6 c0             	movzbl %al,%eax
80103ca2:	c1 e0 08             	shl    $0x8,%eax
80103ca5:	89 c2                	mov    %eax,%edx
80103ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103caa:	83 c0 13             	add    $0x13,%eax
80103cad:	0f b6 00             	movzbl (%eax),%eax
80103cb0:	0f b6 c0             	movzbl %al,%eax
80103cb3:	09 d0                	or     %edx,%eax
80103cb5:	c1 e0 0a             	shl    $0xa,%eax
80103cb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbe:	2d 00 04 00 00       	sub    $0x400,%eax
80103cc3:	83 ec 08             	sub    $0x8,%esp
80103cc6:	68 00 04 00 00       	push   $0x400
80103ccb:	50                   	push   %eax
80103ccc:	e8 00 ff ff ff       	call   80103bd1 <mpsearch1>
80103cd1:	83 c4 10             	add    $0x10,%esp
80103cd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cd7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cdb:	74 05                	je     80103ce2 <mpsearch+0xa5>
      return mp;
80103cdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ce0:	eb 15                	jmp    80103cf7 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ce2:	83 ec 08             	sub    $0x8,%esp
80103ce5:	68 00 00 01 00       	push   $0x10000
80103cea:	68 00 00 0f 00       	push   $0xf0000
80103cef:	e8 dd fe ff ff       	call   80103bd1 <mpsearch1>
80103cf4:	83 c4 10             	add    $0x10,%esp
}
80103cf7:	c9                   	leave  
80103cf8:	c3                   	ret    

80103cf9 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103cf9:	55                   	push   %ebp
80103cfa:	89 e5                	mov    %esp,%ebp
80103cfc:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103cff:	e8 39 ff ff ff       	call   80103c3d <mpsearch>
80103d04:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d07:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d0b:	74 0a                	je     80103d17 <mpconfig+0x1e>
80103d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d10:	8b 40 04             	mov    0x4(%eax),%eax
80103d13:	85 c0                	test   %eax,%eax
80103d15:	75 0a                	jne    80103d21 <mpconfig+0x28>
    return 0;
80103d17:	b8 00 00 00 00       	mov    $0x0,%eax
80103d1c:	e9 81 00 00 00       	jmp    80103da2 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d24:	8b 40 04             	mov    0x4(%eax),%eax
80103d27:	83 ec 0c             	sub    $0xc,%esp
80103d2a:	50                   	push   %eax
80103d2b:	e8 02 fe ff ff       	call   80103b32 <p2v>
80103d30:	83 c4 10             	add    $0x10,%esp
80103d33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103d36:	83 ec 04             	sub    $0x4,%esp
80103d39:	6a 04                	push   $0x4
80103d3b:	68 99 95 10 80       	push   $0x80109599
80103d40:	ff 75 f0             	pushl  -0x10(%ebp)
80103d43:	e8 8f 21 00 00       	call   80105ed7 <memcmp>
80103d48:	83 c4 10             	add    $0x10,%esp
80103d4b:	85 c0                	test   %eax,%eax
80103d4d:	74 07                	je     80103d56 <mpconfig+0x5d>
    return 0;
80103d4f:	b8 00 00 00 00       	mov    $0x0,%eax
80103d54:	eb 4c                	jmp    80103da2 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d59:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d5d:	3c 01                	cmp    $0x1,%al
80103d5f:	74 12                	je     80103d73 <mpconfig+0x7a>
80103d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d64:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d68:	3c 04                	cmp    $0x4,%al
80103d6a:	74 07                	je     80103d73 <mpconfig+0x7a>
    return 0;
80103d6c:	b8 00 00 00 00       	mov    $0x0,%eax
80103d71:	eb 2f                	jmp    80103da2 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d76:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d7a:	0f b7 c0             	movzwl %ax,%eax
80103d7d:	83 ec 08             	sub    $0x8,%esp
80103d80:	50                   	push   %eax
80103d81:	ff 75 f0             	pushl  -0x10(%ebp)
80103d84:	e8 10 fe ff ff       	call   80103b99 <sum>
80103d89:	83 c4 10             	add    $0x10,%esp
80103d8c:	84 c0                	test   %al,%al
80103d8e:	74 07                	je     80103d97 <mpconfig+0x9e>
    return 0;
80103d90:	b8 00 00 00 00       	mov    $0x0,%eax
80103d95:	eb 0b                	jmp    80103da2 <mpconfig+0xa9>
  *pmp = mp;
80103d97:	8b 45 08             	mov    0x8(%ebp),%eax
80103d9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d9d:	89 10                	mov    %edx,(%eax)
  return conf;
80103d9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103da2:	c9                   	leave  
80103da3:	c3                   	ret    

80103da4 <mpinit>:

void
mpinit(void)
{
80103da4:	55                   	push   %ebp
80103da5:	89 e5                	mov    %esp,%ebp
80103da7:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103daa:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103db1:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103db4:	83 ec 0c             	sub    $0xc,%esp
80103db7:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103dba:	50                   	push   %eax
80103dbb:	e8 39 ff ff ff       	call   80103cf9 <mpconfig>
80103dc0:	83 c4 10             	add    $0x10,%esp
80103dc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103dc6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103dca:	0f 84 96 01 00 00    	je     80103f66 <mpinit+0x1c2>
    return;
  ismp = 1;
80103dd0:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103dd7:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ddd:	8b 40 24             	mov    0x24(%eax),%eax
80103de0:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103de8:	83 c0 2c             	add    $0x2c,%eax
80103deb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103df5:	0f b7 d0             	movzwl %ax,%edx
80103df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dfb:	01 d0                	add    %edx,%eax
80103dfd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e00:	e9 f2 00 00 00       	jmp    80103ef7 <mpinit+0x153>
    switch(*p){
80103e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e08:	0f b6 00             	movzbl (%eax),%eax
80103e0b:	0f b6 c0             	movzbl %al,%eax
80103e0e:	83 f8 04             	cmp    $0x4,%eax
80103e11:	0f 87 bc 00 00 00    	ja     80103ed3 <mpinit+0x12f>
80103e17:	8b 04 85 dc 95 10 80 	mov    -0x7fef6a24(,%eax,4),%eax
80103e1e:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e23:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103e26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e29:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e2d:	0f b6 d0             	movzbl %al,%edx
80103e30:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e35:	39 c2                	cmp    %eax,%edx
80103e37:	74 2b                	je     80103e64 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103e39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e3c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e40:	0f b6 d0             	movzbl %al,%edx
80103e43:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e48:	83 ec 04             	sub    $0x4,%esp
80103e4b:	52                   	push   %edx
80103e4c:	50                   	push   %eax
80103e4d:	68 9e 95 10 80       	push   $0x8010959e
80103e52:	e8 6f c5 ff ff       	call   801003c6 <cprintf>
80103e57:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103e5a:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103e61:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103e64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e67:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103e6b:	0f b6 c0             	movzbl %al,%eax
80103e6e:	83 e0 02             	and    $0x2,%eax
80103e71:	85 c0                	test   %eax,%eax
80103e73:	74 15                	je     80103e8a <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103e75:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e7a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e80:	05 80 33 11 80       	add    $0x80113380,%eax
80103e85:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103e8a:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e8f:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103e95:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e9b:	05 80 33 11 80       	add    $0x80113380,%eax
80103ea0:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103ea2:	a1 60 39 11 80       	mov    0x80113960,%eax
80103ea7:	83 c0 01             	add    $0x1,%eax
80103eaa:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103eaf:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103eb3:	eb 42                	jmp    80103ef7 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103ebb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ebe:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ec2:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103ec7:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ecb:	eb 2a                	jmp    80103ef7 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103ecd:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ed1:	eb 24                	jmp    80103ef7 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed6:	0f b6 00             	movzbl (%eax),%eax
80103ed9:	0f b6 c0             	movzbl %al,%eax
80103edc:	83 ec 08             	sub    $0x8,%esp
80103edf:	50                   	push   %eax
80103ee0:	68 bc 95 10 80       	push   $0x801095bc
80103ee5:	e8 dc c4 ff ff       	call   801003c6 <cprintf>
80103eea:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103eed:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103ef4:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103efa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103efd:	0f 82 02 ff ff ff    	jb     80103e05 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103f03:	a1 64 33 11 80       	mov    0x80113364,%eax
80103f08:	85 c0                	test   %eax,%eax
80103f0a:	75 1d                	jne    80103f29 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103f0c:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103f13:	00 00 00 
    lapic = 0;
80103f16:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103f1d:	00 00 00 
    ioapicid = 0;
80103f20:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103f27:	eb 3e                	jmp    80103f67 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103f29:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f2c:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f30:	84 c0                	test   %al,%al
80103f32:	74 33                	je     80103f67 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f34:	83 ec 08             	sub    $0x8,%esp
80103f37:	6a 70                	push   $0x70
80103f39:	6a 22                	push   $0x22
80103f3b:	e8 1c fc ff ff       	call   80103b5c <outb>
80103f40:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f43:	83 ec 0c             	sub    $0xc,%esp
80103f46:	6a 23                	push   $0x23
80103f48:	e8 f2 fb ff ff       	call   80103b3f <inb>
80103f4d:	83 c4 10             	add    $0x10,%esp
80103f50:	83 c8 01             	or     $0x1,%eax
80103f53:	0f b6 c0             	movzbl %al,%eax
80103f56:	83 ec 08             	sub    $0x8,%esp
80103f59:	50                   	push   %eax
80103f5a:	6a 23                	push   $0x23
80103f5c:	e8 fb fb ff ff       	call   80103b5c <outb>
80103f61:	83 c4 10             	add    $0x10,%esp
80103f64:	eb 01                	jmp    80103f67 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103f66:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103f67:	c9                   	leave  
80103f68:	c3                   	ret    

80103f69 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103f69:	55                   	push   %ebp
80103f6a:	89 e5                	mov    %esp,%ebp
80103f6c:	83 ec 08             	sub    $0x8,%esp
80103f6f:	8b 55 08             	mov    0x8(%ebp),%edx
80103f72:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f75:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103f79:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f7c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f80:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f84:	ee                   	out    %al,(%dx)
}
80103f85:	90                   	nop
80103f86:	c9                   	leave  
80103f87:	c3                   	ret    

80103f88 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f88:	55                   	push   %ebp
80103f89:	89 e5                	mov    %esp,%ebp
80103f8b:	83 ec 04             	sub    $0x4,%esp
80103f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f91:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f95:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f99:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103f9f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fa3:	0f b6 c0             	movzbl %al,%eax
80103fa6:	50                   	push   %eax
80103fa7:	6a 21                	push   $0x21
80103fa9:	e8 bb ff ff ff       	call   80103f69 <outb>
80103fae:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103fb1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fb5:	66 c1 e8 08          	shr    $0x8,%ax
80103fb9:	0f b6 c0             	movzbl %al,%eax
80103fbc:	50                   	push   %eax
80103fbd:	68 a1 00 00 00       	push   $0xa1
80103fc2:	e8 a2 ff ff ff       	call   80103f69 <outb>
80103fc7:	83 c4 08             	add    $0x8,%esp
}
80103fca:	90                   	nop
80103fcb:	c9                   	leave  
80103fcc:	c3                   	ret    

80103fcd <picenable>:

void
picenable(int irq)
{
80103fcd:	55                   	push   %ebp
80103fce:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd3:	ba 01 00 00 00       	mov    $0x1,%edx
80103fd8:	89 c1                	mov    %eax,%ecx
80103fda:	d3 e2                	shl    %cl,%edx
80103fdc:	89 d0                	mov    %edx,%eax
80103fde:	f7 d0                	not    %eax
80103fe0:	89 c2                	mov    %eax,%edx
80103fe2:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103fe9:	21 d0                	and    %edx,%eax
80103feb:	0f b7 c0             	movzwl %ax,%eax
80103fee:	50                   	push   %eax
80103fef:	e8 94 ff ff ff       	call   80103f88 <picsetmask>
80103ff4:	83 c4 04             	add    $0x4,%esp
}
80103ff7:	90                   	nop
80103ff8:	c9                   	leave  
80103ff9:	c3                   	ret    

80103ffa <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103ffa:	55                   	push   %ebp
80103ffb:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ffd:	68 ff 00 00 00       	push   $0xff
80104002:	6a 21                	push   $0x21
80104004:	e8 60 ff ff ff       	call   80103f69 <outb>
80104009:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010400c:	68 ff 00 00 00       	push   $0xff
80104011:	68 a1 00 00 00       	push   $0xa1
80104016:	e8 4e ff ff ff       	call   80103f69 <outb>
8010401b:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
8010401e:	6a 11                	push   $0x11
80104020:	6a 20                	push   $0x20
80104022:	e8 42 ff ff ff       	call   80103f69 <outb>
80104027:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
8010402a:	6a 20                	push   $0x20
8010402c:	6a 21                	push   $0x21
8010402e:	e8 36 ff ff ff       	call   80103f69 <outb>
80104033:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104036:	6a 04                	push   $0x4
80104038:	6a 21                	push   $0x21
8010403a:	e8 2a ff ff ff       	call   80103f69 <outb>
8010403f:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104042:	6a 03                	push   $0x3
80104044:	6a 21                	push   $0x21
80104046:	e8 1e ff ff ff       	call   80103f69 <outb>
8010404b:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
8010404e:	6a 11                	push   $0x11
80104050:	68 a0 00 00 00       	push   $0xa0
80104055:	e8 0f ff ff ff       	call   80103f69 <outb>
8010405a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
8010405d:	6a 28                	push   $0x28
8010405f:	68 a1 00 00 00       	push   $0xa1
80104064:	e8 00 ff ff ff       	call   80103f69 <outb>
80104069:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
8010406c:	6a 02                	push   $0x2
8010406e:	68 a1 00 00 00       	push   $0xa1
80104073:	e8 f1 fe ff ff       	call   80103f69 <outb>
80104078:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
8010407b:	6a 03                	push   $0x3
8010407d:	68 a1 00 00 00       	push   $0xa1
80104082:	e8 e2 fe ff ff       	call   80103f69 <outb>
80104087:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
8010408a:	6a 68                	push   $0x68
8010408c:	6a 20                	push   $0x20
8010408e:	e8 d6 fe ff ff       	call   80103f69 <outb>
80104093:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104096:	6a 0a                	push   $0xa
80104098:	6a 20                	push   $0x20
8010409a:	e8 ca fe ff ff       	call   80103f69 <outb>
8010409f:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
801040a2:	6a 68                	push   $0x68
801040a4:	68 a0 00 00 00       	push   $0xa0
801040a9:	e8 bb fe ff ff       	call   80103f69 <outb>
801040ae:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
801040b1:	6a 0a                	push   $0xa
801040b3:	68 a0 00 00 00       	push   $0xa0
801040b8:	e8 ac fe ff ff       	call   80103f69 <outb>
801040bd:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
801040c0:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801040c7:	66 83 f8 ff          	cmp    $0xffff,%ax
801040cb:	74 13                	je     801040e0 <picinit+0xe6>
    picsetmask(irqmask);
801040cd:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801040d4:	0f b7 c0             	movzwl %ax,%eax
801040d7:	50                   	push   %eax
801040d8:	e8 ab fe ff ff       	call   80103f88 <picsetmask>
801040dd:	83 c4 04             	add    $0x4,%esp
}
801040e0:	90                   	nop
801040e1:	c9                   	leave  
801040e2:	c3                   	ret    

801040e3 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801040e3:	55                   	push   %ebp
801040e4:	89 e5                	mov    %esp,%ebp
801040e6:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801040e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801040f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801040f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801040fc:	8b 10                	mov    (%eax),%edx
801040fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104101:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104103:	e8 2d cf ff ff       	call   80101035 <filealloc>
80104108:	89 c2                	mov    %eax,%edx
8010410a:	8b 45 08             	mov    0x8(%ebp),%eax
8010410d:	89 10                	mov    %edx,(%eax)
8010410f:	8b 45 08             	mov    0x8(%ebp),%eax
80104112:	8b 00                	mov    (%eax),%eax
80104114:	85 c0                	test   %eax,%eax
80104116:	0f 84 cb 00 00 00    	je     801041e7 <pipealloc+0x104>
8010411c:	e8 14 cf ff ff       	call   80101035 <filealloc>
80104121:	89 c2                	mov    %eax,%edx
80104123:	8b 45 0c             	mov    0xc(%ebp),%eax
80104126:	89 10                	mov    %edx,(%eax)
80104128:	8b 45 0c             	mov    0xc(%ebp),%eax
8010412b:	8b 00                	mov    (%eax),%eax
8010412d:	85 c0                	test   %eax,%eax
8010412f:	0f 84 b2 00 00 00    	je     801041e7 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104135:	e8 ce eb ff ff       	call   80102d08 <kalloc>
8010413a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010413d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104141:	0f 84 9f 00 00 00    	je     801041e6 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104147:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414a:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104151:	00 00 00 
  p->writeopen = 1;
80104154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104157:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010415e:	00 00 00 
  p->nwrite = 0;
80104161:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104164:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010416b:	00 00 00 
  p->nread = 0;
8010416e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104171:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104178:	00 00 00 
  initlock(&p->lock, "pipe");
8010417b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417e:	83 ec 08             	sub    $0x8,%esp
80104181:	68 f0 95 10 80       	push   $0x801095f0
80104186:	50                   	push   %eax
80104187:	e8 5f 1a 00 00       	call   80105beb <initlock>
8010418c:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010418f:	8b 45 08             	mov    0x8(%ebp),%eax
80104192:	8b 00                	mov    (%eax),%eax
80104194:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010419a:	8b 45 08             	mov    0x8(%ebp),%eax
8010419d:	8b 00                	mov    (%eax),%eax
8010419f:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801041a3:	8b 45 08             	mov    0x8(%ebp),%eax
801041a6:	8b 00                	mov    (%eax),%eax
801041a8:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801041ac:	8b 45 08             	mov    0x8(%ebp),%eax
801041af:	8b 00                	mov    (%eax),%eax
801041b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041b4:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801041b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ba:	8b 00                	mov    (%eax),%eax
801041bc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801041c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801041c5:	8b 00                	mov    (%eax),%eax
801041c7:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801041cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ce:	8b 00                	mov    (%eax),%eax
801041d0:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801041d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801041d7:	8b 00                	mov    (%eax),%eax
801041d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041dc:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801041df:	b8 00 00 00 00       	mov    $0x0,%eax
801041e4:	eb 4e                	jmp    80104234 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801041e6:	90                   	nop
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;

 bad:
  if(p)
801041e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041eb:	74 0e                	je     801041fb <pipealloc+0x118>
    kfree((char*)p);
801041ed:	83 ec 0c             	sub    $0xc,%esp
801041f0:	ff 75 f4             	pushl  -0xc(%ebp)
801041f3:	e8 73 ea ff ff       	call   80102c6b <kfree>
801041f8:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801041fb:	8b 45 08             	mov    0x8(%ebp),%eax
801041fe:	8b 00                	mov    (%eax),%eax
80104200:	85 c0                	test   %eax,%eax
80104202:	74 11                	je     80104215 <pipealloc+0x132>
    fileclose(*f0);
80104204:	8b 45 08             	mov    0x8(%ebp),%eax
80104207:	8b 00                	mov    (%eax),%eax
80104209:	83 ec 0c             	sub    $0xc,%esp
8010420c:	50                   	push   %eax
8010420d:	e8 e1 ce ff ff       	call   801010f3 <fileclose>
80104212:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104215:	8b 45 0c             	mov    0xc(%ebp),%eax
80104218:	8b 00                	mov    (%eax),%eax
8010421a:	85 c0                	test   %eax,%eax
8010421c:	74 11                	je     8010422f <pipealloc+0x14c>
    fileclose(*f1);
8010421e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104221:	8b 00                	mov    (%eax),%eax
80104223:	83 ec 0c             	sub    $0xc,%esp
80104226:	50                   	push   %eax
80104227:	e8 c7 ce ff ff       	call   801010f3 <fileclose>
8010422c:	83 c4 10             	add    $0x10,%esp
  return -1;
8010422f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104234:	c9                   	leave  
80104235:	c3                   	ret    

80104236 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104236:	55                   	push   %ebp
80104237:	89 e5                	mov    %esp,%ebp
80104239:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010423c:	8b 45 08             	mov    0x8(%ebp),%eax
8010423f:	83 ec 0c             	sub    $0xc,%esp
80104242:	50                   	push   %eax
80104243:	e8 c5 19 00 00       	call   80105c0d <acquire>
80104248:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010424b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010424f:	74 23                	je     80104274 <pipeclose+0x3e>
    p->writeopen = 0;
80104251:	8b 45 08             	mov    0x8(%ebp),%eax
80104254:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010425b:	00 00 00 
    wakeup(&p->nread);
8010425e:	8b 45 08             	mov    0x8(%ebp),%eax
80104261:	05 34 02 00 00       	add    $0x234,%eax
80104266:	83 ec 0c             	sub    $0xc,%esp
80104269:	50                   	push   %eax
8010426a:	e8 82 0f 00 00       	call   801051f1 <wakeup>
8010426f:	83 c4 10             	add    $0x10,%esp
80104272:	eb 21                	jmp    80104295 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104274:	8b 45 08             	mov    0x8(%ebp),%eax
80104277:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010427e:	00 00 00 
    wakeup(&p->nwrite);
80104281:	8b 45 08             	mov    0x8(%ebp),%eax
80104284:	05 38 02 00 00       	add    $0x238,%eax
80104289:	83 ec 0c             	sub    $0xc,%esp
8010428c:	50                   	push   %eax
8010428d:	e8 5f 0f 00 00       	call   801051f1 <wakeup>
80104292:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104295:	8b 45 08             	mov    0x8(%ebp),%eax
80104298:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010429e:	85 c0                	test   %eax,%eax
801042a0:	75 2c                	jne    801042ce <pipeclose+0x98>
801042a2:	8b 45 08             	mov    0x8(%ebp),%eax
801042a5:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042ab:	85 c0                	test   %eax,%eax
801042ad:	75 1f                	jne    801042ce <pipeclose+0x98>
    release(&p->lock);
801042af:	8b 45 08             	mov    0x8(%ebp),%eax
801042b2:	83 ec 0c             	sub    $0xc,%esp
801042b5:	50                   	push   %eax
801042b6:	e8 b9 19 00 00       	call   80105c74 <release>
801042bb:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801042be:	83 ec 0c             	sub    $0xc,%esp
801042c1:	ff 75 08             	pushl  0x8(%ebp)
801042c4:	e8 a2 e9 ff ff       	call   80102c6b <kfree>
801042c9:	83 c4 10             	add    $0x10,%esp
801042cc:	eb 0f                	jmp    801042dd <pipeclose+0xa7>
  } else
    release(&p->lock);
801042ce:	8b 45 08             	mov    0x8(%ebp),%eax
801042d1:	83 ec 0c             	sub    $0xc,%esp
801042d4:	50                   	push   %eax
801042d5:	e8 9a 19 00 00       	call   80105c74 <release>
801042da:	83 c4 10             	add    $0x10,%esp
}
801042dd:	90                   	nop
801042de:	c9                   	leave  
801042df:	c3                   	ret    

801042e0 <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
801042e0:	55                   	push   %ebp
801042e1:	89 e5                	mov    %esp,%ebp
801042e3:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801042e6:	8b 45 08             	mov    0x8(%ebp),%eax
801042e9:	83 ec 0c             	sub    $0xc,%esp
801042ec:	50                   	push   %eax
801042ed:	e8 1b 19 00 00       	call   80105c0d <acquire>
801042f2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801042f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042fc:	e9 ad 00 00 00       	jmp    801043ae <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104301:	8b 45 08             	mov    0x8(%ebp),%eax
80104304:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010430a:	85 c0                	test   %eax,%eax
8010430c:	74 0d                	je     8010431b <pipewrite+0x3b>
8010430e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104314:	8b 40 24             	mov    0x24(%eax),%eax
80104317:	85 c0                	test   %eax,%eax
80104319:	74 19                	je     80104334 <pipewrite+0x54>
        release(&p->lock);
8010431b:	8b 45 08             	mov    0x8(%ebp),%eax
8010431e:	83 ec 0c             	sub    $0xc,%esp
80104321:	50                   	push   %eax
80104322:	e8 4d 19 00 00       	call   80105c74 <release>
80104327:	83 c4 10             	add    $0x10,%esp
        return -1;
8010432a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010432f:	e9 a8 00 00 00       	jmp    801043dc <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104334:	8b 45 08             	mov    0x8(%ebp),%eax
80104337:	05 34 02 00 00       	add    $0x234,%eax
8010433c:	83 ec 0c             	sub    $0xc,%esp
8010433f:	50                   	push   %eax
80104340:	e8 ac 0e 00 00       	call   801051f1 <wakeup>
80104345:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104348:	8b 45 08             	mov    0x8(%ebp),%eax
8010434b:	8b 55 08             	mov    0x8(%ebp),%edx
8010434e:	81 c2 38 02 00 00    	add    $0x238,%edx
80104354:	83 ec 08             	sub    $0x8,%esp
80104357:	50                   	push   %eax
80104358:	52                   	push   %edx
80104359:	e8 76 0d 00 00       	call   801050d4 <sleep>
8010435e:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104361:	8b 45 08             	mov    0x8(%ebp),%eax
80104364:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010436a:	8b 45 08             	mov    0x8(%ebp),%eax
8010436d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104373:	05 00 02 00 00       	add    $0x200,%eax
80104378:	39 c2                	cmp    %eax,%edx
8010437a:	74 85                	je     80104301 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010437c:	8b 45 08             	mov    0x8(%ebp),%eax
8010437f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104385:	8d 48 01             	lea    0x1(%eax),%ecx
80104388:	8b 55 08             	mov    0x8(%ebp),%edx
8010438b:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104391:	25 ff 01 00 00       	and    $0x1ff,%eax
80104396:	89 c1                	mov    %eax,%ecx
80104398:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010439b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010439e:	01 d0                	add    %edx,%eax
801043a0:	0f b6 10             	movzbl (%eax),%edx
801043a3:	8b 45 08             	mov    0x8(%ebp),%eax
801043a6:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801043aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b1:	3b 45 10             	cmp    0x10(%ebp),%eax
801043b4:	7c ab                	jl     80104361 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801043b6:	8b 45 08             	mov    0x8(%ebp),%eax
801043b9:	05 34 02 00 00       	add    $0x234,%eax
801043be:	83 ec 0c             	sub    $0xc,%esp
801043c1:	50                   	push   %eax
801043c2:	e8 2a 0e 00 00       	call   801051f1 <wakeup>
801043c7:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043ca:	8b 45 08             	mov    0x8(%ebp),%eax
801043cd:	83 ec 0c             	sub    $0xc,%esp
801043d0:	50                   	push   %eax
801043d1:	e8 9e 18 00 00       	call   80105c74 <release>
801043d6:	83 c4 10             	add    $0x10,%esp
  return n;
801043d9:	8b 45 10             	mov    0x10(%ebp),%eax
}
801043dc:	c9                   	leave  
801043dd:	c3                   	ret    

801043de <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801043de:	55                   	push   %ebp
801043df:	89 e5                	mov    %esp,%ebp
801043e1:	53                   	push   %ebx
801043e2:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801043e5:	8b 45 08             	mov    0x8(%ebp),%eax
801043e8:	83 ec 0c             	sub    $0xc,%esp
801043eb:	50                   	push   %eax
801043ec:	e8 1c 18 00 00       	call   80105c0d <acquire>
801043f1:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043f4:	eb 3f                	jmp    80104435 <piperead+0x57>
    if(proc->killed){
801043f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043fc:	8b 40 24             	mov    0x24(%eax),%eax
801043ff:	85 c0                	test   %eax,%eax
80104401:	74 19                	je     8010441c <piperead+0x3e>
      release(&p->lock);
80104403:	8b 45 08             	mov    0x8(%ebp),%eax
80104406:	83 ec 0c             	sub    $0xc,%esp
80104409:	50                   	push   %eax
8010440a:	e8 65 18 00 00       	call   80105c74 <release>
8010440f:	83 c4 10             	add    $0x10,%esp
      return -1;
80104412:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104417:	e9 bf 00 00 00       	jmp    801044db <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010441c:	8b 45 08             	mov    0x8(%ebp),%eax
8010441f:	8b 55 08             	mov    0x8(%ebp),%edx
80104422:	81 c2 34 02 00 00    	add    $0x234,%edx
80104428:	83 ec 08             	sub    $0x8,%esp
8010442b:	50                   	push   %eax
8010442c:	52                   	push   %edx
8010442d:	e8 a2 0c 00 00       	call   801050d4 <sleep>
80104432:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104435:	8b 45 08             	mov    0x8(%ebp),%eax
80104438:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010443e:	8b 45 08             	mov    0x8(%ebp),%eax
80104441:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104447:	39 c2                	cmp    %eax,%edx
80104449:	75 0d                	jne    80104458 <piperead+0x7a>
8010444b:	8b 45 08             	mov    0x8(%ebp),%eax
8010444e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104454:	85 c0                	test   %eax,%eax
80104456:	75 9e                	jne    801043f6 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104458:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010445f:	eb 49                	jmp    801044aa <piperead+0xcc>
    if(p->nread == p->nwrite)
80104461:	8b 45 08             	mov    0x8(%ebp),%eax
80104464:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010446a:	8b 45 08             	mov    0x8(%ebp),%eax
8010446d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104473:	39 c2                	cmp    %eax,%edx
80104475:	74 3d                	je     801044b4 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104477:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010447a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010447d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104480:	8b 45 08             	mov    0x8(%ebp),%eax
80104483:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104489:	8d 48 01             	lea    0x1(%eax),%ecx
8010448c:	8b 55 08             	mov    0x8(%ebp),%edx
8010448f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104495:	25 ff 01 00 00       	and    $0x1ff,%eax
8010449a:	89 c2                	mov    %eax,%edx
8010449c:	8b 45 08             	mov    0x8(%ebp),%eax
8010449f:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801044a4:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801044a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801044aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ad:	3b 45 10             	cmp    0x10(%ebp),%eax
801044b0:	7c af                	jl     80104461 <piperead+0x83>
801044b2:	eb 01                	jmp    801044b5 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
801044b4:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801044b5:	8b 45 08             	mov    0x8(%ebp),%eax
801044b8:	05 38 02 00 00       	add    $0x238,%eax
801044bd:	83 ec 0c             	sub    $0xc,%esp
801044c0:	50                   	push   %eax
801044c1:	e8 2b 0d 00 00       	call   801051f1 <wakeup>
801044c6:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801044c9:	8b 45 08             	mov    0x8(%ebp),%eax
801044cc:	83 ec 0c             	sub    $0xc,%esp
801044cf:	50                   	push   %eax
801044d0:	e8 9f 17 00 00       	call   80105c74 <release>
801044d5:	83 c4 10             	add    $0x10,%esp
  return i;
801044d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044de:	c9                   	leave  
801044df:	c3                   	ret    

801044e0 <hlt>:
}

// hlt() added by Noah Zentzis, Fall 2016.
static inline void
hlt()
{
801044e0:	55                   	push   %ebp
801044e1:	89 e5                	mov    %esp,%ebp
  asm volatile("hlt");
801044e3:	f4                   	hlt    
}
801044e4:	90                   	nop
801044e5:	5d                   	pop    %ebp
801044e6:	c3                   	ret    

801044e7 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801044e7:	55                   	push   %ebp
801044e8:	89 e5                	mov    %esp,%ebp
801044ea:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801044ed:	9c                   	pushf  
801044ee:	58                   	pop    %eax
801044ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801044f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801044f5:	c9                   	leave  
801044f6:	c3                   	ret    

801044f7 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801044f7:	55                   	push   %ebp
801044f8:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801044fa:	fb                   	sti    
}
801044fb:	90                   	nop
801044fc:	5d                   	pop    %ebp
801044fd:	c3                   	ret    

801044fe <pinit>:
int remove_helper(struct proc ** sList, struct proc * p);
#endif

void
pinit(void)
{
801044fe:	55                   	push   %ebp
801044ff:	89 e5                	mov    %esp,%ebp
80104501:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104504:	83 ec 08             	sub    $0x8,%esp
80104507:	68 f8 95 10 80       	push   $0x801095f8
8010450c:	68 80 39 11 80       	push   $0x80113980
80104511:	e8 d5 16 00 00       	call   80105beb <initlock>
80104516:	83 c4 10             	add    $0x10,%esp
}
80104519:	90                   	nop
8010451a:	c9                   	leave  
8010451b:	c3                   	ret    

8010451c <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010451c:	55                   	push   %ebp
8010451d:	89 e5                	mov    %esp,%ebp
8010451f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104522:	83 ec 0c             	sub    $0xc,%esp
80104525:	68 80 39 11 80       	push   $0x80113980
8010452a:	e8 de 16 00 00       	call   80105c0d <acquire>
8010452f:	83 c4 10             	add    $0x10,%esp
#ifdef CS333_P3P4
  if((p = ptable.pLists.free))
80104532:	a1 b8 5e 11 80       	mov    0x80115eb8,%eax
80104537:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010453a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010453e:	75 1a                	jne    8010455a <allocproc+0x3e>
    goto found;
  release(&ptable.lock);
80104540:	83 ec 0c             	sub    $0xc,%esp
80104543:	68 80 39 11 80       	push   $0x80113980
80104548:	e8 27 17 00 00       	call   80105c74 <release>
8010454d:	83 c4 10             	add    $0x10,%esp
  return 0;
80104550:	b8 00 00 00 00       	mov    $0x0,%eax
80104555:	e9 06 01 00 00       	jmp    80104660 <allocproc+0x144>
  char *sp;

  acquire(&ptable.lock);
#ifdef CS333_P3P4
  if((p = ptable.pLists.free))
    goto found;
8010455a:	90                   	nop
  p->cpu_ticks_total = p->cpu_ticks_in = 0;
#endif

found:
#ifdef CS333_P3P4
  removeAndHeadInsert(p, &ptable.pLists.free, &ptable.pLists.embryo, UNUSED, EMBRYO);// p - remove - add - check - assign state
8010455b:	83 ec 0c             	sub    $0xc,%esp
8010455e:	6a 01                	push   $0x1
80104560:	6a 00                	push   $0x0
80104562:	68 c8 5e 11 80       	push   $0x80115ec8
80104567:	68 b8 5e 11 80       	push   $0x80115eb8
8010456c:	ff 75 f4             	pushl  -0xc(%ebp)
8010456f:	e8 8f 13 00 00       	call   80105903 <removeAndHeadInsert>
80104574:	83 c4 20             	add    $0x20,%esp
#else
  p->state = EMBRYO;
#endif
  p->pid = nextpid++;
80104577:	a1 04 c0 10 80       	mov    0x8010c004,%eax
8010457c:	8d 50 01             	lea    0x1(%eax),%edx
8010457f:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104585:	89 c2                	mov    %eax,%edx
80104587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458a:	89 50 10             	mov    %edx,0x10(%eax)
  release(&ptable.lock);
8010458d:	83 ec 0c             	sub    $0xc,%esp
80104590:	68 80 39 11 80       	push   $0x80113980
80104595:	e8 da 16 00 00       	call   80105c74 <release>
8010459a:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010459d:	e8 66 e7 ff ff       	call   80102d08 <kalloc>
801045a2:	89 c2                	mov    %eax,%edx
801045a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a7:	89 50 08             	mov    %edx,0x8(%eax)
801045aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ad:	8b 40 08             	mov    0x8(%eax),%eax
801045b0:	85 c0                	test   %eax,%eax
801045b2:	75 43                	jne    801045f7 <allocproc+0xdb>
#ifdef CS333_P3P4
  acquire(&ptable.lock);
801045b4:	83 ec 0c             	sub    $0xc,%esp
801045b7:	68 80 39 11 80       	push   $0x80113980
801045bc:	e8 4c 16 00 00       	call   80105c0d <acquire>
801045c1:	83 c4 10             	add    $0x10,%esp
  removeAndHeadInsert(p, &ptable.pLists.embryo, &ptable.pLists.free, EMBRYO, UNUSED);// p - remove - add - check - assign state
801045c4:	83 ec 0c             	sub    $0xc,%esp
801045c7:	6a 00                	push   $0x0
801045c9:	6a 01                	push   $0x1
801045cb:	68 b8 5e 11 80       	push   $0x80115eb8
801045d0:	68 c8 5e 11 80       	push   $0x80115ec8
801045d5:	ff 75 f4             	pushl  -0xc(%ebp)
801045d8:	e8 26 13 00 00       	call   80105903 <removeAndHeadInsert>
801045dd:	83 c4 20             	add    $0x20,%esp
  release(&ptable.lock);
801045e0:	83 ec 0c             	sub    $0xc,%esp
801045e3:	68 80 39 11 80       	push   $0x80113980
801045e8:	e8 87 16 00 00       	call   80105c74 <release>
801045ed:	83 c4 10             	add    $0x10,%esp
  return 0;
801045f0:	b8 00 00 00 00       	mov    $0x0,%eax
801045f5:	eb 69                	jmp    80104660 <allocproc+0x144>
#else
  p->state = UNUSED;
  return 0;
#endif 
  }
  sp = p->kstack + KSTACKSIZE;
801045f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fa:	8b 40 08             	mov    0x8(%eax),%eax
801045fd:	05 00 10 00 00       	add    $0x1000,%eax
80104602:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104605:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010460f:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104612:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104616:	ba c5 73 10 80       	mov    $0x801073c5,%edx
8010461b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010461e:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104620:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104627:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010462a:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010462d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104630:	8b 40 1c             	mov    0x1c(%eax),%eax
80104633:	83 ec 04             	sub    $0x4,%esp
80104636:	6a 14                	push   $0x14
80104638:	6a 00                	push   $0x0
8010463a:	50                   	push   %eax
8010463b:	e8 30 18 00 00       	call   80105e70 <memset>
80104640:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104646:	8b 40 1c             	mov    0x1c(%eax),%eax
80104649:	ba 8e 50 10 80       	mov    $0x8010508e,%edx
8010464e:	89 50 10             	mov    %edx,0x10(%eax)

#ifdef CS333_P1
  p->start_ticks = ticks;
80104651:	8b 15 e0 66 11 80    	mov    0x801166e0,%edx
80104657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465a:	89 50 7c             	mov    %edx,0x7c(%eax)
#endif

  return p;
8010465d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104660:	c9                   	leave  
80104661:	c3                   	ret    

80104662 <userinit>:

// Set up first user process.
void
userinit(void)
{
80104662:	55                   	push   %ebp
80104663:	89 e5                	mov    %esp,%ebp
80104665:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
#ifdef CS333_P3P4
  ptable.pLists.ready = 0;
80104668:	c7 05 b4 5e 11 80 00 	movl   $0x0,0x80115eb4
8010466f:	00 00 00 
  ptable.pLists.sleep = 0;
80104672:	c7 05 bc 5e 11 80 00 	movl   $0x0,0x80115ebc
80104679:	00 00 00 
  ptable.pLists.zombie = 0;
8010467c:	c7 05 c0 5e 11 80 00 	movl   $0x0,0x80115ec0
80104683:	00 00 00 
  ptable.pLists.running = 0;
80104686:	c7 05 c4 5e 11 80 00 	movl   $0x0,0x80115ec4
8010468d:	00 00 00 
  ptable.pLists.embryo = 0;
80104690:	c7 05 c8 5e 11 80 00 	movl   $0x0,0x80115ec8
80104697:	00 00 00 
  ptable.pLists.free = 0;
8010469a:	c7 05 b8 5e 11 80 00 	movl   $0x0,0x80115eb8
801046a1:	00 00 00 

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801046a4:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801046ab:	eb 36                	jmp    801046e3 <userinit+0x81>
  {
    assertState(p, UNUSED);
801046ad:	83 ec 08             	sub    $0x8,%esp
801046b0:	6a 00                	push   $0x0
801046b2:	ff 75 f4             	pushl  -0xc(%ebp)
801046b5:	e8 62 11 00 00       	call   8010581c <assertState>
801046ba:	83 c4 10             	add    $0x10,%esp
    checker(addToStateListHead(&ptable.pLists.free, p));//,5, 0, 0);
801046bd:	83 ec 08             	sub    $0x8,%esp
801046c0:	ff 75 f4             	pushl  -0xc(%ebp)
801046c3:	68 b8 5e 11 80       	push   $0x80115eb8
801046c8:	e8 09 12 00 00       	call   801058d6 <addToStateListHead>
801046cd:	83 c4 10             	add    $0x10,%esp
801046d0:	83 ec 0c             	sub    $0xc,%esp
801046d3:	50                   	push   %eax
801046d4:	e8 4e 10 00 00       	call   80105727 <checker>
801046d9:	83 c4 10             	add    $0x10,%esp
  ptable.pLists.zombie = 0;
  ptable.pLists.running = 0;
  ptable.pLists.embryo = 0;
  ptable.pLists.free = 0;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801046dc:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801046e3:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
801046ea:	72 c1                	jb     801046ad <userinit+0x4b>
  {
    assertState(p, UNUSED);
    checker(addToStateListHead(&ptable.pLists.free, p));//,5, 0, 0);
  }
#endif
  p = allocproc();// p should be embryo
801046ec:	e8 2b fe ff ff       	call   8010451c <allocproc>
801046f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801046f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f7:	a3 68 c6 10 80       	mov    %eax,0x8010c668
#ifdef CS333_P2
  initproc->parent = initproc;
801046fc:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104701:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104707:	89 50 14             	mov    %edx,0x14(%eax)
  initproc->uid = initproc->gid = UIDGID;
8010470a:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104710:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104715:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
8010471c:	00 00 00 
8010471f:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104725:	89 82 80 00 00 00    	mov    %eax,0x80(%edx)
#endif

  if((p->pgdir = setupkvm()) == 0)
8010472b:	e8 57 43 00 00       	call   80108a87 <setupkvm>
80104730:	89 c2                	mov    %eax,%edx
80104732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104735:	89 50 04             	mov    %edx,0x4(%eax)
80104738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473b:	8b 40 04             	mov    0x4(%eax),%eax
8010473e:	85 c0                	test   %eax,%eax
80104740:	75 0d                	jne    8010474f <userinit+0xed>
    panic("userinit: out of memory?");
80104742:	83 ec 0c             	sub    $0xc,%esp
80104745:	68 ff 95 10 80       	push   $0x801095ff
8010474a:	e8 17 be ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010474f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104757:	8b 40 04             	mov    0x4(%eax),%eax
8010475a:	83 ec 04             	sub    $0x4,%esp
8010475d:	52                   	push   %edx
8010475e:	68 00 c5 10 80       	push   $0x8010c500
80104763:	50                   	push   %eax
80104764:	e8 78 45 00 00       	call   80108ce1 <inituvm>
80104769:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010476c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104778:	8b 40 18             	mov    0x18(%eax),%eax
8010477b:	83 ec 04             	sub    $0x4,%esp
8010477e:	6a 4c                	push   $0x4c
80104780:	6a 00                	push   $0x0
80104782:	50                   	push   %eax
80104783:	e8 e8 16 00 00       	call   80105e70 <memset>
80104788:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010478b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478e:	8b 40 18             	mov    0x18(%eax),%eax
80104791:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479a:	8b 40 18             	mov    0x18(%eax),%eax
8010479d:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801047a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a6:	8b 40 18             	mov    0x18(%eax),%eax
801047a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047ac:	8b 52 18             	mov    0x18(%edx),%edx
801047af:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801047b3:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801047b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ba:	8b 40 18             	mov    0x18(%eax),%eax
801047bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047c0:	8b 52 18             	mov    0x18(%edx),%edx
801047c3:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801047c7:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801047cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ce:	8b 40 18             	mov    0x18(%eax),%eax
801047d1:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801047d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047db:	8b 40 18             	mov    0x18(%eax),%eax
801047de:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801047e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e8:	8b 40 18             	mov    0x18(%eax),%eax
801047eb:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801047f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f5:	83 c0 6c             	add    $0x6c,%eax
801047f8:	83 ec 04             	sub    $0x4,%esp
801047fb:	6a 10                	push   $0x10
801047fd:	68 18 96 10 80       	push   $0x80109618
80104802:	50                   	push   %eax
80104803:	e8 6b 18 00 00       	call   80106073 <safestrcpy>
80104808:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010480b:	83 ec 0c             	sub    $0xc,%esp
8010480e:	68 21 96 10 80       	push   $0x80109621
80104813:	e8 b2 dd ff ff       	call   801025ca <namei>
80104818:	83 c4 10             	add    $0x10,%esp
8010481b:	89 c2                	mov    %eax,%edx
8010481d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104820:	89 50 68             	mov    %edx,0x68(%eax)

#ifdef CS333_P3P4
  acquire(&ptable.lock);
80104823:	83 ec 0c             	sub    $0xc,%esp
80104826:	68 80 39 11 80       	push   $0x80113980
8010482b:	e8 dd 13 00 00       	call   80105c0d <acquire>
80104830:	83 c4 10             	add    $0x10,%esp
  removeAndEndInsert(p, &ptable.pLists.embryo, &ptable.pLists.ready, EMBRYO, RUNNABLE);// p - remove - add - check - assign state
80104833:	83 ec 0c             	sub    $0xc,%esp
80104836:	6a 03                	push   $0x3
80104838:	6a 01                	push   $0x1
8010483a:	68 b4 5e 11 80       	push   $0x80115eb4
8010483f:	68 c8 5e 11 80       	push   $0x80115ec8
80104844:	ff 75 f4             	pushl  -0xc(%ebp)
80104847:	e8 14 11 00 00       	call   80105960 <removeAndEndInsert>
8010484c:	83 c4 20             	add    $0x20,%esp
  release(&ptable.lock);
8010484f:	83 ec 0c             	sub    $0xc,%esp
80104852:	68 80 39 11 80       	push   $0x80113980
80104857:	e8 18 14 00 00       	call   80105c74 <release>
8010485c:	83 c4 10             	add    $0x10,%esp
#else 
  p->state = RUNNABLE;
#endif
}
8010485f:	90                   	nop
80104860:	c9                   	leave  
80104861:	c3                   	ret    

80104862 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104862:	55                   	push   %ebp
80104863:	89 e5                	mov    %esp,%ebp
80104865:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104868:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486e:	8b 00                	mov    (%eax),%eax
80104870:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104873:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104877:	7e 31                	jle    801048aa <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104879:	8b 55 08             	mov    0x8(%ebp),%edx
8010487c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487f:	01 c2                	add    %eax,%edx
80104881:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104887:	8b 40 04             	mov    0x4(%eax),%eax
8010488a:	83 ec 04             	sub    $0x4,%esp
8010488d:	52                   	push   %edx
8010488e:	ff 75 f4             	pushl  -0xc(%ebp)
80104891:	50                   	push   %eax
80104892:	e8 97 45 00 00       	call   80108e2e <allocuvm>
80104897:	83 c4 10             	add    $0x10,%esp
8010489a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010489d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801048a1:	75 3e                	jne    801048e1 <growproc+0x7f>
      return -1;
801048a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048a8:	eb 59                	jmp    80104903 <growproc+0xa1>
  } else if(n < 0){
801048aa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801048ae:	79 31                	jns    801048e1 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801048b0:	8b 55 08             	mov    0x8(%ebp),%edx
801048b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b6:	01 c2                	add    %eax,%edx
801048b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048be:	8b 40 04             	mov    0x4(%eax),%eax
801048c1:	83 ec 04             	sub    $0x4,%esp
801048c4:	52                   	push   %edx
801048c5:	ff 75 f4             	pushl  -0xc(%ebp)
801048c8:	50                   	push   %eax
801048c9:	e8 29 46 00 00       	call   80108ef7 <deallocuvm>
801048ce:	83 c4 10             	add    $0x10,%esp
801048d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801048d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801048d8:	75 07                	jne    801048e1 <growproc+0x7f>
      return -1;
801048da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048df:	eb 22                	jmp    80104903 <growproc+0xa1>
  }
  proc->sz = sz;
801048e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048ea:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801048ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048f2:	83 ec 0c             	sub    $0xc,%esp
801048f5:	50                   	push   %eax
801048f6:	e8 73 42 00 00       	call   80108b6e <switchuvm>
801048fb:	83 c4 10             	add    $0x10,%esp
  return 0;
801048fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104903:	c9                   	leave  
80104904:	c3                   	ret    

80104905 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104905:	55                   	push   %ebp
80104906:	89 e5                	mov    %esp,%ebp
80104908:	57                   	push   %edi
80104909:	56                   	push   %esi
8010490a:	53                   	push   %ebx
8010490b:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)// np should be an embryo
8010490e:	e8 09 fc ff ff       	call   8010451c <allocproc>
80104913:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104916:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010491a:	75 0a                	jne    80104926 <fork+0x21>
    return -1;
8010491c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104921:	e9 d6 01 00 00       	jmp    80104afc <fork+0x1f7>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104926:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010492c:	8b 10                	mov    (%eax),%edx
8010492e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104934:	8b 40 04             	mov    0x4(%eax),%eax
80104937:	83 ec 08             	sub    $0x8,%esp
8010493a:	52                   	push   %edx
8010493b:	50                   	push   %eax
8010493c:	e8 54 47 00 00       	call   80109095 <copyuvm>
80104941:	83 c4 10             	add    $0x10,%esp
80104944:	89 c2                	mov    %eax,%edx
80104946:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104949:	89 50 04             	mov    %edx,0x4(%eax)
8010494c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010494f:	8b 40 04             	mov    0x4(%eax),%eax
80104952:	85 c0                	test   %eax,%eax
80104954:	75 62                	jne    801049b8 <fork+0xb3>
    kfree(np->kstack);
80104956:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104959:	8b 40 08             	mov    0x8(%eax),%eax
8010495c:	83 ec 0c             	sub    $0xc,%esp
8010495f:	50                   	push   %eax
80104960:	e8 06 e3 ff ff       	call   80102c6b <kfree>
80104965:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104968:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010496b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#ifdef CS333_P3P4
    acquire(&ptable.lock);
80104972:	83 ec 0c             	sub    $0xc,%esp
80104975:	68 80 39 11 80       	push   $0x80113980
8010497a:	e8 8e 12 00 00       	call   80105c0d <acquire>
8010497f:	83 c4 10             	add    $0x10,%esp
    removeAndHeadInsert(np, &ptable.pLists.embryo, &ptable.pLists.free, EMBRYO, UNUSED);//np - remove - add - check - assign state
80104982:	83 ec 0c             	sub    $0xc,%esp
80104985:	6a 00                	push   $0x0
80104987:	6a 01                	push   $0x1
80104989:	68 b8 5e 11 80       	push   $0x80115eb8
8010498e:	68 c8 5e 11 80       	push   $0x80115ec8
80104993:	ff 75 e0             	pushl  -0x20(%ebp)
80104996:	e8 68 0f 00 00       	call   80105903 <removeAndHeadInsert>
8010499b:	83 c4 20             	add    $0x20,%esp
    release(&ptable.lock);
8010499e:	83 ec 0c             	sub    $0xc,%esp
801049a1:	68 80 39 11 80       	push   $0x80113980
801049a6:	e8 c9 12 00 00       	call   80105c74 <release>
801049ab:	83 c4 10             	add    $0x10,%esp
#else 
    np->state = UNUSED;
#endif
    return -1;
801049ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049b3:	e9 44 01 00 00       	jmp    80104afc <fork+0x1f7>
  }
  np->sz = proc->sz;
801049b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049be:	8b 10                	mov    (%eax),%edx
801049c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049c3:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801049c5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801049cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049cf:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801049d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049d5:	8b 50 18             	mov    0x18(%eax),%edx
801049d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049de:	8b 40 18             	mov    0x18(%eax),%eax
801049e1:	89 c3                	mov    %eax,%ebx
801049e3:	b8 13 00 00 00       	mov    $0x13,%eax
801049e8:	89 d7                	mov    %edx,%edi
801049ea:	89 de                	mov    %ebx,%esi
801049ec:	89 c1                	mov    %eax,%ecx
801049ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
#ifdef CS333_P2
  np->uid = proc->uid;
801049f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f6:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801049fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049ff:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  np->gid = proc->gid;
80104a05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a0b:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104a11:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a14:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
#endif
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104a1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a1d:	8b 40 18             	mov    0x18(%eax),%eax
80104a20:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104a27:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104a2e:	eb 43                	jmp    80104a73 <fork+0x16e>
    if(proc->ofile[i])
80104a30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a36:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a39:	83 c2 08             	add    $0x8,%edx
80104a3c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a40:	85 c0                	test   %eax,%eax
80104a42:	74 2b                	je     80104a6f <fork+0x16a>
      np->ofile[i] = filedup(proc->ofile[i]);
80104a44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a4a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a4d:	83 c2 08             	add    $0x8,%edx
80104a50:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a54:	83 ec 0c             	sub    $0xc,%esp
80104a57:	50                   	push   %eax
80104a58:	e8 45 c6 ff ff       	call   801010a2 <filedup>
80104a5d:	83 c4 10             	add    $0x10,%esp
80104a60:	89 c1                	mov    %eax,%ecx
80104a62:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a65:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a68:	83 c2 08             	add    $0x8,%edx
80104a6b:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  np->gid = proc->gid;
#endif
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104a6f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104a73:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104a77:	7e b7                	jle    80104a30 <fork+0x12b>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104a79:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a7f:	8b 40 68             	mov    0x68(%eax),%eax
80104a82:	83 ec 0c             	sub    $0xc,%esp
80104a85:	50                   	push   %eax
80104a86:	e8 47 cf ff ff       	call   801019d2 <idup>
80104a8b:	83 c4 10             	add    $0x10,%esp
80104a8e:	89 c2                	mov    %eax,%edx
80104a90:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a93:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104a96:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a9c:	8d 50 6c             	lea    0x6c(%eax),%edx
80104a9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104aa2:	83 c0 6c             	add    $0x6c,%eax
80104aa5:	83 ec 04             	sub    $0x4,%esp
80104aa8:	6a 10                	push   $0x10
80104aaa:	52                   	push   %edx
80104aab:	50                   	push   %eax
80104aac:	e8 c2 15 00 00       	call   80106073 <safestrcpy>
80104ab1:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104ab4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ab7:	8b 40 10             	mov    0x10(%eax),%eax
80104aba:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104abd:	83 ec 0c             	sub    $0xc,%esp
80104ac0:	68 80 39 11 80       	push   $0x80113980
80104ac5:	e8 43 11 00 00       	call   80105c0d <acquire>
80104aca:	83 c4 10             	add    $0x10,%esp
#ifdef CS333_P3P4
  removeAndEndInsert(np, &ptable.pLists.embryo, &ptable.pLists.ready, EMBRYO, RUNNABLE);//np - remove - add - check - assign state
80104acd:	83 ec 0c             	sub    $0xc,%esp
80104ad0:	6a 03                	push   $0x3
80104ad2:	6a 01                	push   $0x1
80104ad4:	68 b4 5e 11 80       	push   $0x80115eb4
80104ad9:	68 c8 5e 11 80       	push   $0x80115ec8
80104ade:	ff 75 e0             	pushl  -0x20(%ebp)
80104ae1:	e8 7a 0e 00 00       	call   80105960 <removeAndEndInsert>
80104ae6:	83 c4 20             	add    $0x20,%esp
#else
  np->state = RUNNABLE;
#endif
  release(&ptable.lock);
80104ae9:	83 ec 0c             	sub    $0xc,%esp
80104aec:	68 80 39 11 80       	push   $0x80113980
80104af1:	e8 7e 11 00 00       	call   80105c74 <release>
80104af6:	83 c4 10             	add    $0x10,%esp
  return pid;
80104af9:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104afc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104aff:	5b                   	pop    %ebx
80104b00:	5e                   	pop    %esi
80104b01:	5f                   	pop    %edi
80104b02:	5d                   	pop    %ebp
80104b03:	c3                   	ret    

80104b04 <exit>:
  panic("zombie exit");
}
#else
void
exit(void)
{
80104b04:	55                   	push   %ebp
80104b05:	89 e5                	mov    %esp,%ebp
80104b07:	83 ec 18             	sub    $0x18,%esp
  int fd;

  if(proc == initproc)
80104b0a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b11:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104b16:	39 c2                	cmp    %eax,%edx
80104b18:	75 0d                	jne    80104b27 <exit+0x23>
    panic("init exiting");
80104b1a:	83 ec 0c             	sub    $0xc,%esp
80104b1d:	68 23 96 10 80       	push   $0x80109623
80104b22:	e8 3f ba ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104b27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104b2e:	eb 48                	jmp    80104b78 <exit+0x74>
    if(proc->ofile[fd]){
80104b30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b36:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b39:	83 c2 08             	add    $0x8,%edx
80104b3c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b40:	85 c0                	test   %eax,%eax
80104b42:	74 30                	je     80104b74 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104b44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b4d:	83 c2 08             	add    $0x8,%edx
80104b50:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b54:	83 ec 0c             	sub    $0xc,%esp
80104b57:	50                   	push   %eax
80104b58:	e8 96 c5 ff ff       	call   801010f3 <fileclose>
80104b5d:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104b60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b69:	83 c2 08             	add    $0x8,%edx
80104b6c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104b73:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104b74:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104b78:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104b7c:	7e b2                	jle    80104b30 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104b7e:	e8 6c ea ff ff       	call   801035ef <begin_op>
  iput(proc->cwd);
80104b83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b89:	8b 40 68             	mov    0x68(%eax),%eax
80104b8c:	83 ec 0c             	sub    $0xc,%esp
80104b8f:	50                   	push   %eax
80104b90:	e8 47 d0 ff ff       	call   80101bdc <iput>
80104b95:	83 c4 10             	add    $0x10,%esp
  end_op();
80104b98:	e8 de ea ff ff       	call   8010367b <end_op>
  proc->cwd = 0;
80104b9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba3:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104baa:	83 ec 0c             	sub    $0xc,%esp
80104bad:	68 80 39 11 80       	push   $0x80113980
80104bb2:	e8 56 10 00 00       	call   80105c0d <acquire>
80104bb7:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104bba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc0:	8b 40 14             	mov    0x14(%eax),%eax
80104bc3:	83 ec 0c             	sub    $0xc,%esp
80104bc6:	50                   	push   %eax
80104bc7:	e8 ce 05 00 00       	call   8010519a <wakeup1>
80104bcc:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init. //
  //Free donst not have parents
  exit_helper(&ptable.pLists.ready);
80104bcf:	83 ec 0c             	sub    $0xc,%esp
80104bd2:	68 b4 5e 11 80       	push   $0x80115eb4
80104bd7:	e8 75 00 00 00       	call   80104c51 <exit_helper>
80104bdc:	83 c4 10             	add    $0x10,%esp
  exit_helper(&ptable.pLists.running);
80104bdf:	83 ec 0c             	sub    $0xc,%esp
80104be2:	68 c4 5e 11 80       	push   $0x80115ec4
80104be7:	e8 65 00 00 00       	call   80104c51 <exit_helper>
80104bec:	83 c4 10             	add    $0x10,%esp
  exit_helper(&ptable.pLists.zombie);
80104bef:	83 ec 0c             	sub    $0xc,%esp
80104bf2:	68 c0 5e 11 80       	push   $0x80115ec0
80104bf7:	e8 55 00 00 00       	call   80104c51 <exit_helper>
80104bfc:	83 c4 10             	add    $0x10,%esp
  exit_helper(&ptable.pLists.embryo);//yes, embry have parents
80104bff:	83 ec 0c             	sub    $0xc,%esp
80104c02:	68 c8 5e 11 80       	push   $0x80115ec8
80104c07:	e8 45 00 00 00       	call   80104c51 <exit_helper>
80104c0c:	83 c4 10             	add    $0x10,%esp
  exit_helper(&ptable.pLists.sleep);
80104c0f:	83 ec 0c             	sub    $0xc,%esp
80104c12:	68 bc 5e 11 80       	push   $0x80115ebc
80104c17:	e8 35 00 00 00       	call   80104c51 <exit_helper>
80104c1c:	83 c4 10             	add    $0x10,%esp

  // Jump into the scheduler, never to return.
  // running -exit-> zombie --- proc should be running 
  //cprintf("exit\n");
  removeAndHeadInsert(proc, &ptable.pLists.running, &ptable.pLists.zombie, RUNNING, ZOMBIE);//proc - remove - add - check - assign state
80104c1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c25:	83 ec 0c             	sub    $0xc,%esp
80104c28:	6a 05                	push   $0x5
80104c2a:	6a 04                	push   $0x4
80104c2c:	68 c0 5e 11 80       	push   $0x80115ec0
80104c31:	68 c4 5e 11 80       	push   $0x80115ec4
80104c36:	50                   	push   %eax
80104c37:	e8 c7 0c 00 00       	call   80105903 <removeAndHeadInsert>
80104c3c:	83 c4 20             	add    $0x20,%esp
  //cprintf("exit done\n");
  sched();
80104c3f:	e8 0a 03 00 00       	call   80104f4e <sched>
  panic("zombie exit");
80104c44:	83 ec 0c             	sub    $0xc,%esp
80104c47:	68 30 96 10 80       	push   $0x80109630
80104c4c:	e8 15 b9 ff ff       	call   80100566 <panic>

80104c51 <exit_helper>:
}
void
exit_helper(struct proc ** sList)
{
80104c51:	55                   	push   %ebp
80104c52:	89 e5                	mov    %esp,%ebp
80104c54:	83 ec 18             	sub    $0x18,%esp
  struct proc * p = *sList;
80104c57:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5a:	8b 00                	mov    (%eax),%eax
80104c5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!p)
80104c5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c63:	74 4e                	je     80104cb3 <exit_helper+0x62>
    return;
  if(p->parent == proc){
80104c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c68:	8b 50 14             	mov    0x14(%eax),%edx
80104c6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c71:	39 c2                	cmp    %eax,%edx
80104c73:	75 28                	jne    80104c9d <exit_helper+0x4c>
    p->parent = initproc;
80104c75:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7e:	89 50 14             	mov    %edx,0x14(%eax)
    if(p->state == ZOMBIE)
80104c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c84:	8b 40 0c             	mov    0xc(%eax),%eax
80104c87:	83 f8 05             	cmp    $0x5,%eax
80104c8a:	75 11                	jne    80104c9d <exit_helper+0x4c>
      wakeup1(initproc);
80104c8c:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104c91:	83 ec 0c             	sub    $0xc,%esp
80104c94:	50                   	push   %eax
80104c95:	e8 00 05 00 00       	call   8010519a <wakeup1>
80104c9a:	83 c4 10             	add    $0x10,%esp
  }
  exit_helper(&p->next);
80104c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca0:	05 90 00 00 00       	add    $0x90,%eax
80104ca5:	83 ec 0c             	sub    $0xc,%esp
80104ca8:	50                   	push   %eax
80104ca9:	e8 a3 ff ff ff       	call   80104c51 <exit_helper>
80104cae:	83 c4 10             	add    $0x10,%esp
80104cb1:	eb 01                	jmp    80104cb4 <exit_helper+0x63>
void
exit_helper(struct proc ** sList)
{
  struct proc * p = *sList;
  if(!p)
    return;
80104cb3:	90                   	nop
    p->parent = initproc;
    if(p->state == ZOMBIE)
      wakeup1(initproc);
  }
  exit_helper(&p->next);
}
80104cb4:	c9                   	leave  
80104cb5:	c3                   	ret    

80104cb6 <wait>:
  }
}
#else
int
wait(void)
{
80104cb6:	55                   	push   %ebp
80104cb7:	89 e5                	mov    %esp,%ebp
80104cb9:	83 ec 18             	sub    $0x18,%esp
  int havekids, pid;

  acquire(&ptable.lock);
80104cbc:	83 ec 0c             	sub    $0xc,%esp
80104cbf:	68 80 39 11 80       	push   $0x80113980
80104cc4:	e8 44 0f 00 00       	call   80105c0d <acquire>
80104cc9:	83 c4 10             	add    $0x10,%esp
  for(;;){
    havekids = 0;
80104ccc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    // Scan through table looking for zombie children.
    pid = wait_helper(&ptable.pLists.zombie, &havekids);
80104cd3:	83 ec 08             	sub    $0x8,%esp
80104cd6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cd9:	50                   	push   %eax
80104cda:	68 c0 5e 11 80       	push   $0x80115ec0
80104cdf:	e8 ad 00 00 00       	call   80104d91 <wait_helper>
80104ce4:	83 c4 10             	add    $0x10,%esp
80104ce7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid) return pid;//only with zombie list
80104cea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104cee:	74 08                	je     80104cf8 <wait+0x42>
80104cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf3:	e9 97 00 00 00       	jmp    80104d8f <wait+0xd9>
    wait_helper(&ptable.pLists.ready, &havekids);
80104cf8:	83 ec 08             	sub    $0x8,%esp
80104cfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cfe:	50                   	push   %eax
80104cff:	68 b4 5e 11 80       	push   $0x80115eb4
80104d04:	e8 88 00 00 00       	call   80104d91 <wait_helper>
80104d09:	83 c4 10             	add    $0x10,%esp
    wait_helper(&ptable.pLists.running, &havekids);
80104d0c:	83 ec 08             	sub    $0x8,%esp
80104d0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d12:	50                   	push   %eax
80104d13:	68 c4 5e 11 80       	push   $0x80115ec4
80104d18:	e8 74 00 00 00       	call   80104d91 <wait_helper>
80104d1d:	83 c4 10             	add    $0x10,%esp
    wait_helper(&ptable.pLists.sleep, &havekids);
80104d20:	83 ec 08             	sub    $0x8,%esp
80104d23:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d26:	50                   	push   %eax
80104d27:	68 bc 5e 11 80       	push   $0x80115ebc
80104d2c:	e8 60 00 00 00       	call   80104d91 <wait_helper>
80104d31:	83 c4 10             	add    $0x10,%esp
    wait_helper(&ptable.pLists.embryo, &havekids);
80104d34:	83 ec 08             	sub    $0x8,%esp
80104d37:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d3a:	50                   	push   %eax
80104d3b:	68 c8 5e 11 80       	push   $0x80115ec8
80104d40:	e8 4c 00 00 00       	call   80104d91 <wait_helper>
80104d45:	83 c4 10             	add    $0x10,%esp
    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d4b:	85 c0                	test   %eax,%eax
80104d4d:	74 0d                	je     80104d5c <wait+0xa6>
80104d4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d55:	8b 40 24             	mov    0x24(%eax),%eax
80104d58:	85 c0                	test   %eax,%eax
80104d5a:	74 17                	je     80104d73 <wait+0xbd>
      release(&ptable.lock);
80104d5c:	83 ec 0c             	sub    $0xc,%esp
80104d5f:	68 80 39 11 80       	push   $0x80113980
80104d64:	e8 0b 0f 00 00       	call   80105c74 <release>
80104d69:	83 c4 10             	add    $0x10,%esp
      return -1;
80104d6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d71:	eb 1c                	jmp    80104d8f <wait+0xd9>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104d73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d79:	83 ec 08             	sub    $0x8,%esp
80104d7c:	68 80 39 11 80       	push   $0x80113980
80104d81:	50                   	push   %eax
80104d82:	e8 4d 03 00 00       	call   801050d4 <sleep>
80104d87:	83 c4 10             	add    $0x10,%esp
  }
80104d8a:	e9 3d ff ff ff       	jmp    80104ccc <wait+0x16>
}
80104d8f:	c9                   	leave  
80104d90:	c3                   	ret    

80104d91 <wait_helper>:
int
wait_helper(struct proc ** sList, int * havekids)
{
80104d91:	55                   	push   %ebp
80104d92:	89 e5                	mov    %esp,%ebp
80104d94:	83 ec 18             	sub    $0x18,%esp
  struct proc * p = *sList;
80104d97:	8b 45 08             	mov    0x8(%ebp),%eax
80104d9a:	8b 00                	mov    (%eax),%eax
80104d9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int pid;

  if(!p)
80104d9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104da3:	75 0a                	jne    80104daf <wait_helper+0x1e>
    return 0;
80104da5:	b8 00 00 00 00       	mov    $0x0,%eax
80104daa:	e9 d0 00 00 00       	jmp    80104e7f <wait_helper+0xee>
  if(p->parent == proc)
80104daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db2:	8b 50 14             	mov    0x14(%eax),%edx
80104db5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dbb:	39 c2                	cmp    %eax,%edx
80104dbd:	0f 85 a5 00 00 00    	jne    80104e68 <wait_helper+0xd7>
  {
    *havekids = 1;
80104dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dc6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    if(p->state == ZOMBIE){
80104dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dcf:	8b 40 0c             	mov    0xc(%eax),%eax
80104dd2:	83 f8 05             	cmp    $0x5,%eax
80104dd5:	0f 85 8d 00 00 00    	jne    80104e68 <wait_helper+0xd7>
      // Found one.
      pid = p->pid;
80104ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dde:	8b 40 10             	mov    0x10(%eax),%eax
80104de1:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(p->kstack);
80104de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de7:	8b 40 08             	mov    0x8(%eax),%eax
80104dea:	83 ec 0c             	sub    $0xc,%esp
80104ded:	50                   	push   %eax
80104dee:	e8 78 de ff ff       	call   80102c6b <kfree>
80104df3:	83 c4 10             	add    $0x10,%esp
      p->kstack = 0;
80104df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      freevm(p->pgdir);
80104e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e03:	8b 40 04             	mov    0x4(%eax),%eax
80104e06:	83 ec 0c             	sub    $0xc,%esp
80104e09:	50                   	push   %eax
80104e0a:	e8 a5 41 00 00       	call   80108fb4 <freevm>
80104e0f:	83 c4 10             	add    $0x10,%esp
      removeAndHeadInsert(p, &ptable.pLists.zombie, &ptable.pLists.free, ZOMBIE, UNUSED);//proc - remove - add - check - assign state
80104e12:	83 ec 0c             	sub    $0xc,%esp
80104e15:	6a 00                	push   $0x0
80104e17:	6a 05                	push   $0x5
80104e19:	68 b8 5e 11 80       	push   $0x80115eb8
80104e1e:	68 c0 5e 11 80       	push   $0x80115ec0
80104e23:	ff 75 f4             	pushl  -0xc(%ebp)
80104e26:	e8 d8 0a 00 00       	call   80105903 <removeAndHeadInsert>
80104e2b:	83 c4 20             	add    $0x20,%esp
      p->pid = 0;
80104e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e31:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
      p->parent = 0;
80104e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
      p->name[0] = 0;
80104e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e45:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
      p->killed = 0;
80104e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4c:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
      release(&ptable.lock);
80104e53:	83 ec 0c             	sub    $0xc,%esp
80104e56:	68 80 39 11 80       	push   $0x80113980
80104e5b:	e8 14 0e 00 00       	call   80105c74 <release>
80104e60:	83 c4 10             	add    $0x10,%esp
      return pid;
80104e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e66:	eb 17                	jmp    80104e7f <wait_helper+0xee>
    }
  }
  return wait_helper(&p->next, havekids);
80104e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6b:	05 90 00 00 00       	add    $0x90,%eax
80104e70:	83 ec 08             	sub    $0x8,%esp
80104e73:	ff 75 0c             	pushl  0xc(%ebp)
80104e76:	50                   	push   %eax
80104e77:	e8 15 ff ff ff       	call   80104d91 <wait_helper>
80104e7c:	83 c4 10             	add    $0x10,%esp
}
80104e7f:	c9                   	leave  
80104e80:	c3                   	ret    

80104e81 <scheduler>:
}

#else
void
scheduler(void)
{
80104e81:	55                   	push   %ebp
80104e82:	89 e5                	mov    %esp,%ebp
80104e84:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104e87:	e8 6b f6 ff ff       	call   801044f7 <sti>

    idle = 1;  // assume idle unless we schedule a process
80104e8c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104e93:	83 ec 0c             	sub    $0xc,%esp
80104e96:	68 80 39 11 80       	push   $0x80113980
80104e9b:	e8 6d 0d 00 00       	call   80105c0d <acquire>
80104ea0:	83 c4 10             	add    $0x10,%esp
    if((p = ptable.pLists.ready))//rnnable loop and o running -- START
80104ea3:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
80104ea8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104eab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104eaf:	74 79                	je     80104f2a <scheduler+0xa9>
    {
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
80104eb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
      proc = p;
80104eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ebb:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104ec1:	83 ec 0c             	sub    $0xc,%esp
80104ec4:	ff 75 f0             	pushl  -0x10(%ebp)
80104ec7:	e8 a2 3c 00 00       	call   80108b6e <switchuvm>
80104ecc:	83 c4 10             	add    $0x10,%esp

      //cprintf("schedular\n");
      removeAndHeadInsert(p, &ptable.pLists.ready, &ptable.pLists.running, RUNNABLE, RUNNING);//proc - remove - add - check - assign state
80104ecf:	83 ec 0c             	sub    $0xc,%esp
80104ed2:	6a 04                	push   $0x4
80104ed4:	6a 03                	push   $0x3
80104ed6:	68 c4 5e 11 80       	push   $0x80115ec4
80104edb:	68 b4 5e 11 80       	push   $0x80115eb4
80104ee0:	ff 75 f0             	pushl  -0x10(%ebp)
80104ee3:	e8 1b 0a 00 00       	call   80105903 <removeAndHeadInsert>
80104ee8:	83 c4 20             	add    $0x20,%esp
      //cprintf("schedualr done\n");
      swtch(&cpu->scheduler, proc->context);
80104eeb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ef1:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ef4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104efb:	83 c2 04             	add    $0x4,%edx
80104efe:	83 ec 08             	sub    $0x8,%esp
80104f01:	50                   	push   %eax
80104f02:	52                   	push   %edx
80104f03:	e8 dc 11 00 00       	call   801060e4 <swtch>
80104f08:	83 c4 10             	add    $0x10,%esp

#ifdef CS333_P2
      p->cpu_ticks_in = ticks; // Start ticks when the procceser enters 
80104f0b:	8b 15 e0 66 11 80    	mov    0x801166e0,%edx
80104f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f14:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
#endif

      switchkvm();
80104f1a:	e8 32 3c 00 00       	call   80108b51 <switchkvm>
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104f1f:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104f26:	00 00 00 00 
    }
    release(&ptable.lock);
80104f2a:	83 ec 0c             	sub    $0xc,%esp
80104f2d:	68 80 39 11 80       	push   $0x80113980
80104f32:	e8 3d 0d 00 00       	call   80105c74 <release>
80104f37:	83 c4 10             	add    $0x10,%esp
    // if idle, wait for next interrupt
    if (idle) 
80104f3a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f3e:	0f 84 43 ff ff ff    	je     80104e87 <scheduler+0x6>
      hlt();
80104f44:	e8 97 f5 ff ff       	call   801044e0 <hlt>
    }
80104f49:	e9 39 ff ff ff       	jmp    80104e87 <scheduler+0x6>

80104f4e <sched>:
// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
#ifdef CS333_P3P4
void
sched(void)
{
80104f4e:	55                   	push   %ebp
80104f4f:	89 e5                	mov    %esp,%ebp
80104f51:	53                   	push   %ebx
80104f52:	83 ec 14             	sub    $0x14,%esp
  int intena;

  if(!holding(&ptable.lock))
80104f55:	83 ec 0c             	sub    $0xc,%esp
80104f58:	68 80 39 11 80       	push   $0x80113980
80104f5d:	e8 de 0d 00 00       	call   80105d40 <holding>
80104f62:	83 c4 10             	add    $0x10,%esp
80104f65:	85 c0                	test   %eax,%eax
80104f67:	75 0d                	jne    80104f76 <sched+0x28>
    panic("sched ptable.lock");
80104f69:	83 ec 0c             	sub    $0xc,%esp
80104f6c:	68 3c 96 10 80       	push   $0x8010963c
80104f71:	e8 f0 b5 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104f76:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f7c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104f82:	83 f8 01             	cmp    $0x1,%eax
80104f85:	74 0d                	je     80104f94 <sched+0x46>
    panic("sched locks");
80104f87:	83 ec 0c             	sub    $0xc,%esp
80104f8a:	68 4e 96 10 80       	push   $0x8010964e
80104f8f:	e8 d2 b5 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104f94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f9a:	8b 40 0c             	mov    0xc(%eax),%eax
80104f9d:	83 f8 04             	cmp    $0x4,%eax
80104fa0:	75 0d                	jne    80104faf <sched+0x61>
    panic("sched running");
80104fa2:	83 ec 0c             	sub    $0xc,%esp
80104fa5:	68 5a 96 10 80       	push   $0x8010965a
80104faa:	e8 b7 b5 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104faf:	e8 33 f5 ff ff       	call   801044e7 <readeflags>
80104fb4:	25 00 02 00 00       	and    $0x200,%eax
80104fb9:	85 c0                	test   %eax,%eax
80104fbb:	74 0d                	je     80104fca <sched+0x7c>
    panic("sched interruptible");
80104fbd:	83 ec 0c             	sub    $0xc,%esp
80104fc0:	68 68 96 10 80       	push   $0x80109668
80104fc5:	e8 9c b5 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104fca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fd0:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104fd6:	89 45 f4             	mov    %eax,-0xc(%ebp)

#ifdef CS333_P2
  proc->cpu_ticks_total += (ticks - proc->cpu_ticks_in); // Update the total cpu ticks before it switches to the other one
80104fd9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fdf:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fe6:	8b 8a 88 00 00 00    	mov    0x88(%edx),%ecx
80104fec:	8b 1d e0 66 11 80    	mov    0x801166e0,%ebx
80104ff2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ff9:	8b 92 8c 00 00 00    	mov    0x8c(%edx),%edx
80104fff:	29 d3                	sub    %edx,%ebx
80105001:	89 da                	mov    %ebx,%edx
80105003:	01 ca                	add    %ecx,%edx
80105005:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
#endif

  swtch(&proc->context, cpu->scheduler);
8010500b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105011:	8b 40 04             	mov    0x4(%eax),%eax
80105014:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010501b:	83 c2 1c             	add    $0x1c,%edx
8010501e:	83 ec 08             	sub    $0x8,%esp
80105021:	50                   	push   %eax
80105022:	52                   	push   %edx
80105023:	e8 bc 10 00 00       	call   801060e4 <swtch>
80105028:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
8010502b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105031:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105034:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)

}
8010503a:	90                   	nop
8010503b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010503e:	c9                   	leave  
8010503f:	c3                   	ret    

80105040 <yield>:
#endif

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105040:	55                   	push   %ebp
80105041:	89 e5                	mov    %esp,%ebp
80105043:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105046:	83 ec 0c             	sub    $0xc,%esp
80105049:	68 80 39 11 80       	push   $0x80113980
8010504e:	e8 ba 0b 00 00       	call   80105c0d <acquire>
80105053:	83 c4 10             	add    $0x10,%esp
#ifdef CS333_P3P4
  //cprintf("yield\n");
  removeAndEndInsert(proc, &ptable.pLists.running, &ptable.pLists.ready, RUNNING, RUNNABLE);//proc - remove - add - check - assign state
80105056:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010505c:	83 ec 0c             	sub    $0xc,%esp
8010505f:	6a 03                	push   $0x3
80105061:	6a 04                	push   $0x4
80105063:	68 b4 5e 11 80       	push   $0x80115eb4
80105068:	68 c4 5e 11 80       	push   $0x80115ec4
8010506d:	50                   	push   %eax
8010506e:	e8 ed 08 00 00       	call   80105960 <removeAndEndInsert>
80105073:	83 c4 20             	add    $0x20,%esp
  //cprintf("yield done\n");
#else
  proc->state = RUNNABLE;
#endif
  sched();
80105076:	e8 d3 fe ff ff       	call   80104f4e <sched>
  release(&ptable.lock);
8010507b:	83 ec 0c             	sub    $0xc,%esp
8010507e:	68 80 39 11 80       	push   $0x80113980
80105083:	e8 ec 0b 00 00       	call   80105c74 <release>
80105088:	83 c4 10             	add    $0x10,%esp
}
8010508b:	90                   	nop
8010508c:	c9                   	leave  
8010508d:	c3                   	ret    

8010508e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010508e:	55                   	push   %ebp
8010508f:	89 e5                	mov    %esp,%ebp
80105091:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105094:	83 ec 0c             	sub    $0xc,%esp
80105097:	68 80 39 11 80       	push   $0x80113980
8010509c:	e8 d3 0b 00 00       	call   80105c74 <release>
801050a1:	83 c4 10             	add    $0x10,%esp

  if (first) {
801050a4:	a1 20 c0 10 80       	mov    0x8010c020,%eax
801050a9:	85 c0                	test   %eax,%eax
801050ab:	74 24                	je     801050d1 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801050ad:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
801050b4:	00 00 00 
    iinit(ROOTDEV);
801050b7:	83 ec 0c             	sub    $0xc,%esp
801050ba:	6a 01                	push   $0x1
801050bc:	e8 1f c6 ff ff       	call   801016e0 <iinit>
801050c1:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801050c4:	83 ec 0c             	sub    $0xc,%esp
801050c7:	6a 01                	push   $0x1
801050c9:	e8 03 e3 ff ff       	call   801033d1 <initlog>
801050ce:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801050d1:	90                   	nop
801050d2:	c9                   	leave  
801050d3:	c3                   	ret    

801050d4 <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
801050d4:	55                   	push   %ebp
801050d5:	89 e5                	mov    %esp,%ebp
801050d7:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
801050da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050e0:	85 c0                	test   %eax,%eax
801050e2:	75 0d                	jne    801050f1 <sleep+0x1d>
    panic("sleep");
801050e4:	83 ec 0c             	sub    $0xc,%esp
801050e7:	68 7c 96 10 80       	push   $0x8010967c
801050ec:	e8 75 b4 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
801050f1:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
801050f8:	74 24                	je     8010511e <sleep+0x4a>
    acquire(&ptable.lock);
801050fa:	83 ec 0c             	sub    $0xc,%esp
801050fd:	68 80 39 11 80       	push   $0x80113980
80105102:	e8 06 0b 00 00       	call   80105c0d <acquire>
80105107:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
8010510a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010510e:	74 0e                	je     8010511e <sleep+0x4a>
80105110:	83 ec 0c             	sub    $0xc,%esp
80105113:	ff 75 0c             	pushl  0xc(%ebp)
80105116:	e8 59 0b 00 00       	call   80105c74 <release>
8010511b:	83 c4 10             	add    $0x10,%esp
  }

  if(proc->state != SLEEPING)
8010511e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105124:	8b 40 0c             	mov    0xc(%eax),%eax
80105127:	83 f8 02             	cmp    $0x2,%eax
8010512a:	74 0c                	je     80105138 <sleep+0x64>
      //cprintf("not sleep\n");

  // Go to sleep.
  proc->chan = chan;
8010512c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105132:	8b 55 08             	mov    0x8(%ebp),%edx
80105135:	89 50 20             	mov    %edx,0x20(%eax)
#ifdef CS333_P3P4
  //cprintf("sleep\n");
  removeAndHeadInsert(proc, &ptable.pLists.running, &ptable.pLists.sleep, RUNNING, SLEEPING);//proc - remove - add - check - assign state
80105138:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010513e:	83 ec 0c             	sub    $0xc,%esp
80105141:	6a 02                	push   $0x2
80105143:	6a 04                	push   $0x4
80105145:	68 bc 5e 11 80       	push   $0x80115ebc
8010514a:	68 c4 5e 11 80       	push   $0x80115ec4
8010514f:	50                   	push   %eax
80105150:	e8 ae 07 00 00       	call   80105903 <removeAndHeadInsert>
80105155:	83 c4 20             	add    $0x20,%esp
  //cprintf("sleep done\n");
#else
  proc->state = SLEEPING;
#endif
  sched();
80105158:	e8 f1 fd ff ff       	call   80104f4e <sched>

  // Tidy up.
  proc->chan = 0;
8010515d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105163:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){ 
8010516a:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80105171:	74 24                	je     80105197 <sleep+0xc3>
    release(&ptable.lock);
80105173:	83 ec 0c             	sub    $0xc,%esp
80105176:	68 80 39 11 80       	push   $0x80113980
8010517b:	e8 f4 0a 00 00       	call   80105c74 <release>
80105180:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
80105183:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105187:	74 0e                	je     80105197 <sleep+0xc3>
80105189:	83 ec 0c             	sub    $0xc,%esp
8010518c:	ff 75 0c             	pushl  0xc(%ebp)
8010518f:	e8 79 0a 00 00       	call   80105c0d <acquire>
80105194:	83 c4 10             	add    $0x10,%esp
  }
}
80105197:	90                   	nop
80105198:	c9                   	leave  
80105199:	c3                   	ret    

8010519a <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
8010519a:	55                   	push   %ebp
8010519b:	89 e5                	mov    %esp,%ebp
8010519d:	83 ec 18             	sub    $0x18,%esp
  //cprintf("wakeup1\n");
  struct proc * p = ptable.pLists.sleep;
801051a0:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
801051a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p)
801051a8:	eb 3e                	jmp    801051e8 <wakeup1+0x4e>
  {
    if(p->chan == chan && p->state == SLEEPING)
801051aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ad:	8b 40 20             	mov    0x20(%eax),%eax
801051b0:	3b 45 08             	cmp    0x8(%ebp),%eax
801051b3:	75 27                	jne    801051dc <wakeup1+0x42>
801051b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b8:	8b 40 0c             	mov    0xc(%eax),%eax
801051bb:	83 f8 02             	cmp    $0x2,%eax
801051be:	75 1c                	jne    801051dc <wakeup1+0x42>
      removeAndEndInsert(p, &ptable.pLists.sleep, &ptable.pLists.ready, SLEEPING, RUNNABLE);//proc - remove - add - check - assign state
801051c0:	83 ec 0c             	sub    $0xc,%esp
801051c3:	6a 03                	push   $0x3
801051c5:	6a 02                	push   $0x2
801051c7:	68 b4 5e 11 80       	push   $0x80115eb4
801051cc:	68 bc 5e 11 80       	push   $0x80115ebc
801051d1:	ff 75 f4             	pushl  -0xc(%ebp)
801051d4:	e8 87 07 00 00       	call   80105960 <removeAndEndInsert>
801051d9:	83 c4 20             	add    $0x20,%esp
    p = p->next;
801051dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051df:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801051e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
static void
wakeup1(void *chan)
{
  //cprintf("wakeup1\n");
  struct proc * p = ptable.pLists.sleep;
  while(p)
801051e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051ec:	75 bc                	jne    801051aa <wakeup1+0x10>
  {
    if(p->chan == chan && p->state == SLEEPING)
      removeAndEndInsert(p, &ptable.pLists.sleep, &ptable.pLists.ready, SLEEPING, RUNNABLE);//proc - remove - add - check - assign state
    p = p->next;
  }
}
801051ee:	90                   	nop
801051ef:	c9                   	leave  
801051f0:	c3                   	ret    

801051f1 <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801051f1:	55                   	push   %ebp
801051f2:	89 e5                	mov    %esp,%ebp
801051f4:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801051f7:	83 ec 0c             	sub    $0xc,%esp
801051fa:	68 80 39 11 80       	push   $0x80113980
801051ff:	e8 09 0a 00 00       	call   80105c0d <acquire>
80105204:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105207:	83 ec 0c             	sub    $0xc,%esp
8010520a:	ff 75 08             	pushl  0x8(%ebp)
8010520d:	e8 88 ff ff ff       	call   8010519a <wakeup1>
80105212:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105215:	83 ec 0c             	sub    $0xc,%esp
80105218:	68 80 39 11 80       	push   $0x80113980
8010521d:	e8 52 0a 00 00       	call   80105c74 <release>
80105222:	83 c4 10             	add    $0x10,%esp
}
80105225:	90                   	nop
80105226:	c9                   	leave  
80105227:	c3                   	ret    

80105228 <kill>:
  return -1;
}
#else
int
kill(int pid)
{
80105228:	55                   	push   %ebp
80105229:	89 e5                	mov    %esp,%ebp
8010522b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010522e:	83 ec 0c             	sub    $0xc,%esp
80105231:	68 80 39 11 80       	push   $0x80113980
80105236:	e8 d2 09 00 00       	call   80105c0d <acquire>
8010523b:	83 c4 10             	add    $0x10,%esp
  if(kill_helper(pid, &ptable.pLists.ready))
8010523e:	83 ec 08             	sub    $0x8,%esp
80105241:	68 b4 5e 11 80       	push   $0x80115eb4
80105246:	ff 75 08             	pushl  0x8(%ebp)
80105249:	e8 a0 00 00 00       	call   801052ee <kill_helper>
8010524e:	83 c4 10             	add    $0x10,%esp
80105251:	85 c0                	test   %eax,%eax
80105253:	74 0a                	je     8010525f <kill+0x37>
      return 0;
80105255:	b8 00 00 00 00       	mov    $0x0,%eax
8010525a:	e9 8d 00 00 00       	jmp    801052ec <kill+0xc4>
  else if(kill_helper(pid, &ptable.pLists.running))
8010525f:	83 ec 08             	sub    $0x8,%esp
80105262:	68 c4 5e 11 80       	push   $0x80115ec4
80105267:	ff 75 08             	pushl  0x8(%ebp)
8010526a:	e8 7f 00 00 00       	call   801052ee <kill_helper>
8010526f:	83 c4 10             	add    $0x10,%esp
80105272:	85 c0                	test   %eax,%eax
80105274:	74 07                	je     8010527d <kill+0x55>
      return 0;
80105276:	b8 00 00 00 00       	mov    $0x0,%eax
8010527b:	eb 6f                	jmp    801052ec <kill+0xc4>
  else if(kill_helper(pid, &ptable.pLists.zombie))
8010527d:	83 ec 08             	sub    $0x8,%esp
80105280:	68 c0 5e 11 80       	push   $0x80115ec0
80105285:	ff 75 08             	pushl  0x8(%ebp)
80105288:	e8 61 00 00 00       	call   801052ee <kill_helper>
8010528d:	83 c4 10             	add    $0x10,%esp
80105290:	85 c0                	test   %eax,%eax
80105292:	74 07                	je     8010529b <kill+0x73>
      return 0;
80105294:	b8 00 00 00 00       	mov    $0x0,%eax
80105299:	eb 51                	jmp    801052ec <kill+0xc4>
  else if(kill_helper(pid, &ptable.pLists.embryo))
8010529b:	83 ec 08             	sub    $0x8,%esp
8010529e:	68 c8 5e 11 80       	push   $0x80115ec8
801052a3:	ff 75 08             	pushl  0x8(%ebp)
801052a6:	e8 43 00 00 00       	call   801052ee <kill_helper>
801052ab:	83 c4 10             	add    $0x10,%esp
801052ae:	85 c0                	test   %eax,%eax
801052b0:	74 07                	je     801052b9 <kill+0x91>
      return 0;
801052b2:	b8 00 00 00 00       	mov    $0x0,%eax
801052b7:	eb 33                	jmp    801052ec <kill+0xc4>
  else if(kill_helper(pid, &ptable.pLists.sleep))//last so we dont add to runable list
801052b9:	83 ec 08             	sub    $0x8,%esp
801052bc:	68 bc 5e 11 80       	push   $0x80115ebc
801052c1:	ff 75 08             	pushl  0x8(%ebp)
801052c4:	e8 25 00 00 00       	call   801052ee <kill_helper>
801052c9:	83 c4 10             	add    $0x10,%esp
801052cc:	85 c0                	test   %eax,%eax
801052ce:	74 07                	je     801052d7 <kill+0xaf>
      return 0;
801052d0:	b8 00 00 00 00       	mov    $0x0,%eax
801052d5:	eb 15                	jmp    801052ec <kill+0xc4>
  release(&ptable.lock);
801052d7:	83 ec 0c             	sub    $0xc,%esp
801052da:	68 80 39 11 80       	push   $0x80113980
801052df:	e8 90 09 00 00       	call   80105c74 <release>
801052e4:	83 c4 10             	add    $0x10,%esp
  return -1;
801052e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052ec:	c9                   	leave  
801052ed:	c3                   	ret    

801052ee <kill_helper>:
int
kill_helper(int pid, struct proc ** sList)
{
801052ee:	55                   	push   %ebp
801052ef:	89 e5                	mov    %esp,%ebp
801052f1:	83 ec 18             	sub    $0x18,%esp
  struct proc * p = *sList;
801052f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f7:	8b 00                	mov    (%eax),%eax
801052f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!p)
801052fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105300:	75 07                	jne    80105309 <kill_helper+0x1b>
    return 0;
80105302:	b8 00 00 00 00       	mov    $0x0,%eax
80105307:	eb 6c                	jmp    80105375 <kill_helper+0x87>
  if(p->pid == pid){
80105309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010530c:	8b 50 10             	mov    0x10(%eax),%edx
8010530f:	8b 45 08             	mov    0x8(%ebp),%eax
80105312:	39 c2                	cmp    %eax,%edx
80105314:	75 48                	jne    8010535e <kill_helper+0x70>
    p->killed = 1;
80105316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105319:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
    if(p->state == SLEEPING)
80105320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105323:	8b 40 0c             	mov    0xc(%eax),%eax
80105326:	83 f8 02             	cmp    $0x2,%eax
80105329:	75 1c                	jne    80105347 <kill_helper+0x59>
      removeAndEndInsert(p, &ptable.pLists.sleep, &ptable.pLists.ready, SLEEPING, RUNNABLE);//proc - remove - add - check - assign state
8010532b:	83 ec 0c             	sub    $0xc,%esp
8010532e:	6a 03                	push   $0x3
80105330:	6a 02                	push   $0x2
80105332:	68 b4 5e 11 80       	push   $0x80115eb4
80105337:	68 bc 5e 11 80       	push   $0x80115ebc
8010533c:	ff 75 f4             	pushl  -0xc(%ebp)
8010533f:	e8 1c 06 00 00       	call   80105960 <removeAndEndInsert>
80105344:	83 c4 20             	add    $0x20,%esp
    release(&ptable.lock);
80105347:	83 ec 0c             	sub    $0xc,%esp
8010534a:	68 80 39 11 80       	push   $0x80113980
8010534f:	e8 20 09 00 00       	call   80105c74 <release>
80105354:	83 c4 10             	add    $0x10,%esp
    return 1;
80105357:	b8 01 00 00 00       	mov    $0x1,%eax
8010535c:	eb 17                	jmp    80105375 <kill_helper+0x87>
  }
  return kill_helper(pid, &p->next);
8010535e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105361:	05 90 00 00 00       	add    $0x90,%eax
80105366:	83 ec 08             	sub    $0x8,%esp
80105369:	50                   	push   %eax
8010536a:	ff 75 08             	pushl  0x8(%ebp)
8010536d:	e8 7c ff ff ff       	call   801052ee <kill_helper>
80105372:	83 c4 10             	add    $0x10,%esp
}
80105375:	c9                   	leave  
80105376:	c3                   	ret    

80105377 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105377:	55                   	push   %ebp
80105378:	89 e5                	mov    %esp,%ebp
8010537a:	57                   	push   %edi
8010537b:	56                   	push   %esi
8010537c:	53                   	push   %ebx
8010537d:	83 ec 5c             	sub    $0x5c,%esp
#ifdef CS333_P2
  int i, sec, milisec, cpu_sec, cpu_milisec;
  char * zeros = "", *cpu_zeros = "";
80105380:	c7 45 e0 ac 96 10 80 	movl   $0x801096ac,-0x20(%ebp)
80105387:	c7 45 dc ac 96 10 80 	movl   $0x801096ac,-0x24(%ebp)
#endif
  struct proc *p;
  char *state;
  uint pc[10];
#ifdef CS333_P2
  cprintf("PID\tName\tUID\tGID\tPPID\tElapsed\t CPU\tState\tSize\t PCs\n");
8010538e:	83 ec 0c             	sub    $0xc,%esp
80105391:	68 b0 96 10 80       	push   $0x801096b0
80105396:	e8 2b b0 ff ff       	call   801003c6 <cprintf>
8010539b:	83 c4 10             	add    $0x10,%esp
#elif CS333_P1
  cprintf("PID\tState\tName\tElapsed\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010539e:	c7 45 d8 b4 39 11 80 	movl   $0x801139b4,-0x28(%ebp)
801053a5:	e9 ef 01 00 00       	jmp    80105599 <procdump+0x222>
    if(p->state == UNUSED)
801053aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
801053ad:	8b 40 0c             	mov    0xc(%eax),%eax
801053b0:	85 c0                	test   %eax,%eax
801053b2:	0f 84 d9 01 00 00    	je     80105591 <procdump+0x21a>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801053b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801053bb:	8b 40 0c             	mov    0xc(%eax),%eax
801053be:	83 f8 05             	cmp    $0x5,%eax
801053c1:	77 23                	ja     801053e6 <procdump+0x6f>
801053c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801053c6:	8b 40 0c             	mov    0xc(%eax),%eax
801053c9:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801053d0:	85 c0                	test   %eax,%eax
801053d2:	74 12                	je     801053e6 <procdump+0x6f>
      state = states[p->state];
801053d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801053d7:	8b 40 0c             	mov    0xc(%eax),%eax
801053da:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801053e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801053e4:	eb 07                	jmp    801053ed <procdump+0x76>
    else
      state = "???";
801053e6:	c7 45 d4 e4 96 10 80 	movl   $0x801096e4,-0x2c(%ebp)
#ifdef CS333_P2
    sec = (ticks - p->start_ticks)/1000;
801053ed:	8b 15 e0 66 11 80    	mov    0x801166e0,%edx
801053f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801053f6:	8b 40 7c             	mov    0x7c(%eax),%eax
801053f9:	29 c2                	sub    %eax,%edx
801053fb:	89 d0                	mov    %edx,%eax
801053fd:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105402:	f7 e2                	mul    %edx
80105404:	89 d0                	mov    %edx,%eax
80105406:	c1 e8 06             	shr    $0x6,%eax
80105409:	89 45 d0             	mov    %eax,-0x30(%ebp)
    milisec = (ticks - p->start_ticks) % 1000;
8010540c:	8b 15 e0 66 11 80    	mov    0x801166e0,%edx
80105412:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105415:	8b 40 7c             	mov    0x7c(%eax),%eax
80105418:	89 d1                	mov    %edx,%ecx
8010541a:	29 c1                	sub    %eax,%ecx
8010541c:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105421:	89 c8                	mov    %ecx,%eax
80105423:	f7 e2                	mul    %edx
80105425:	89 d0                	mov    %edx,%eax
80105427:	c1 e8 06             	shr    $0x6,%eax
8010542a:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105430:	29 c1                	sub    %eax,%ecx
80105432:	89 c8                	mov    %ecx,%eax
80105434:	89 45 cc             	mov    %eax,-0x34(%ebp)
    cpu_sec = p->cpu_ticks_total/1000;
80105437:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010543a:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105440:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105445:	f7 e2                	mul    %edx
80105447:	89 d0                	mov    %edx,%eax
80105449:	c1 e8 06             	shr    $0x6,%eax
8010544c:	89 45 c8             	mov    %eax,-0x38(%ebp)
    cpu_milisec = p->cpu_ticks_total % 1000;
8010544f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105452:	8b 88 88 00 00 00    	mov    0x88(%eax),%ecx
80105458:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
8010545d:	89 c8                	mov    %ecx,%eax
8010545f:	f7 e2                	mul    %edx
80105461:	89 d0                	mov    %edx,%eax
80105463:	c1 e8 06             	shr    $0x6,%eax
80105466:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
8010546c:	29 c1                	sub    %eax,%ecx
8010546e:	89 c8                	mov    %ecx,%eax
80105470:	89 45 c4             	mov    %eax,-0x3c(%ebp)

    if((milisec < 10 && milisec > 1))
80105473:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
80105477:	7f 0f                	jg     80105488 <procdump+0x111>
80105479:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
8010547d:	7e 09                	jle    80105488 <procdump+0x111>
        zeros = "00";
8010547f:	c7 45 e0 e8 96 10 80 	movl   $0x801096e8,-0x20(%ebp)
80105486:	eb 16                	jmp    8010549e <procdump+0x127>
    else if(milisec < 100)
80105488:	83 7d cc 63          	cmpl   $0x63,-0x34(%ebp)
8010548c:	7f 09                	jg     80105497 <procdump+0x120>
        zeros = "0";
8010548e:	c7 45 e0 eb 96 10 80 	movl   $0x801096eb,-0x20(%ebp)
80105495:	eb 07                	jmp    8010549e <procdump+0x127>
    else
        zeros = "";
80105497:	c7 45 e0 ac 96 10 80 	movl   $0x801096ac,-0x20(%ebp)
    if((cpu_milisec < 10 && cpu_milisec > 1))
8010549e:	83 7d c4 09          	cmpl   $0x9,-0x3c(%ebp)
801054a2:	7f 0f                	jg     801054b3 <procdump+0x13c>
801054a4:	83 7d c4 01          	cmpl   $0x1,-0x3c(%ebp)
801054a8:	7e 09                	jle    801054b3 <procdump+0x13c>
        cpu_zeros = "00";
801054aa:	c7 45 dc e8 96 10 80 	movl   $0x801096e8,-0x24(%ebp)
801054b1:	eb 16                	jmp    801054c9 <procdump+0x152>
    else if(cpu_milisec < 100)
801054b3:	83 7d c4 63          	cmpl   $0x63,-0x3c(%ebp)
801054b7:	7f 09                	jg     801054c2 <procdump+0x14b>
        cpu_zeros = "0";
801054b9:	c7 45 dc eb 96 10 80 	movl   $0x801096eb,-0x24(%ebp)
801054c0:	eb 07                	jmp    801054c9 <procdump+0x152>
    else
        cpu_zeros = "";
801054c2:	c7 45 dc ac 96 10 80 	movl   $0x801096ac,-0x24(%ebp)

    cprintf("%d\t%s\t%d\t%d\t%d\t%d.%s%d\t %d.%s%d\t%s\t%d\t", p->pid, p->name, p->uid, p->gid, p->parent->pid, sec, zeros, milisec, cpu_sec, cpu_zeros, cpu_milisec, state, p->sz);
801054c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054cc:	8b 30                	mov    (%eax),%esi
801054ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054d1:	8b 40 14             	mov    0x14(%eax),%eax
801054d4:	8b 58 10             	mov    0x10(%eax),%ebx
801054d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054da:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
801054e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054e3:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801054e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054ec:	8d 78 6c             	lea    0x6c(%eax),%edi
801054ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054f2:	8b 40 10             	mov    0x10(%eax),%eax
801054f5:	83 ec 08             	sub    $0x8,%esp
801054f8:	56                   	push   %esi
801054f9:	ff 75 d4             	pushl  -0x2c(%ebp)
801054fc:	ff 75 c4             	pushl  -0x3c(%ebp)
801054ff:	ff 75 dc             	pushl  -0x24(%ebp)
80105502:	ff 75 c8             	pushl  -0x38(%ebp)
80105505:	ff 75 cc             	pushl  -0x34(%ebp)
80105508:	ff 75 e0             	pushl  -0x20(%ebp)
8010550b:	ff 75 d0             	pushl  -0x30(%ebp)
8010550e:	53                   	push   %ebx
8010550f:	51                   	push   %ecx
80105510:	52                   	push   %edx
80105511:	57                   	push   %edi
80105512:	50                   	push   %eax
80105513:	68 f0 96 10 80       	push   $0x801096f0
80105518:	e8 a9 ae ff ff       	call   801003c6 <cprintf>
8010551d:	83 c4 40             	add    $0x40,%esp

    cprintf("%d\t%s\t%s\t%d.%s%d\t", p->pid, state, p->name, sec, zeros,  milisec);
#else
    cprintf("%d %s %s", p->pid, state, p->name);
#endif
    if(p->state == SLEEPING){
80105520:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105523:	8b 40 0c             	mov    0xc(%eax),%eax
80105526:	83 f8 02             	cmp    $0x2,%eax
80105529:	75 54                	jne    8010557f <procdump+0x208>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010552b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010552e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105531:	8b 40 0c             	mov    0xc(%eax),%eax
80105534:	83 c0 08             	add    $0x8,%eax
80105537:	89 c2                	mov    %eax,%edx
80105539:	83 ec 08             	sub    $0x8,%esp
8010553c:	8d 45 9c             	lea    -0x64(%ebp),%eax
8010553f:	50                   	push   %eax
80105540:	52                   	push   %edx
80105541:	e8 80 07 00 00       	call   80105cc6 <getcallerpcs>
80105546:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105549:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105550:	eb 1c                	jmp    8010556e <procdump+0x1f7>
        cprintf(" %p", pc[i]);
80105552:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105555:	8b 44 85 9c          	mov    -0x64(%ebp,%eax,4),%eax
80105559:	83 ec 08             	sub    $0x8,%esp
8010555c:	50                   	push   %eax
8010555d:	68 17 97 10 80       	push   $0x80109717
80105562:	e8 5f ae ff ff       	call   801003c6 <cprintf>
80105567:	83 c4 10             	add    $0x10,%esp
#else
    cprintf("%d %s %s", p->pid, state, p->name);
#endif
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010556a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010556e:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
80105572:	7f 0b                	jg     8010557f <procdump+0x208>
80105574:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105577:	8b 44 85 9c          	mov    -0x64(%ebp,%eax,4),%eax
8010557b:	85 c0                	test   %eax,%eax
8010557d:	75 d3                	jne    80105552 <procdump+0x1db>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010557f:	83 ec 0c             	sub    $0xc,%esp
80105582:	68 1b 97 10 80       	push   $0x8010971b
80105587:	e8 3a ae ff ff       	call   801003c6 <cprintf>
8010558c:	83 c4 10             	add    $0x10,%esp
8010558f:	eb 01                	jmp    80105592 <procdump+0x21b>
#elif CS333_P1
  cprintf("PID\tState\tName\tElapsed\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105591:	90                   	nop
#ifdef CS333_P2
  cprintf("PID\tName\tUID\tGID\tPPID\tElapsed\t CPU\tState\tSize\t PCs\n");
#elif CS333_P1
  cprintf("PID\tState\tName\tElapsed\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105592:	81 45 d8 94 00 00 00 	addl   $0x94,-0x28(%ebp)
80105599:	81 7d d8 b4 5e 11 80 	cmpl   $0x80115eb4,-0x28(%ebp)
801055a0:	0f 82 04 fe ff ff    	jb     801053aa <procdump+0x33>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801055a6:	90                   	nop
801055a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801055aa:	5b                   	pop    %ebx
801055ab:	5e                   	pop    %esi
801055ac:	5f                   	pop    %edi
801055ad:	5d                   	pop    %ebp
801055ae:	c3                   	ret    

801055af <getprocs>:
#ifdef CS333_P2
int getprocs(uint max, struct uproc * table){
801055af:	55                   	push   %ebp
801055b0:	89 e5                	mov    %esp,%ebp
801055b2:	83 ec 18             	sub    $0x18,%esp
  struct proc * p;
  int i;

  for(i = 0, p = ptable.proc; p < &ptable.proc[NPROC] && i < max; p++){
801055b5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801055bc:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801055c3:	e9 45 01 00 00       	jmp    8010570d <getprocs+0x15e>
    if(p->state == UNUSED || p->state == EMBRYO)
801055c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055cb:	8b 40 0c             	mov    0xc(%eax),%eax
801055ce:	85 c0                	test   %eax,%eax
801055d0:	0f 84 2f 01 00 00    	je     80105705 <getprocs+0x156>
801055d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d9:	8b 40 0c             	mov    0xc(%eax),%eax
801055dc:	83 f8 01             	cmp    $0x1,%eax
801055df:	0f 84 20 01 00 00    	je     80105705 <getprocs+0x156>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801055e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e8:	8b 40 0c             	mov    0xc(%eax),%eax
801055eb:	83 f8 05             	cmp    $0x5,%eax
801055ee:	0f 87 0a 01 00 00    	ja     801056fe <getprocs+0x14f>
801055f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f7:	8b 40 0c             	mov    0xc(%eax),%eax
801055fa:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105601:	85 c0                	test   %eax,%eax
80105603:	0f 84 f5 00 00 00    	je     801056fe <getprocs+0x14f>
    {
        table[i].pid = p->pid;
80105609:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010560c:	6b d0 5c             	imul   $0x5c,%eax,%edx
8010560f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105612:	01 c2                	add    %eax,%edx
80105614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105617:	8b 40 10             	mov    0x10(%eax),%eax
8010561a:	89 02                	mov    %eax,(%edx)
        table[i].uid = p->uid;
8010561c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010561f:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105622:	8b 45 0c             	mov    0xc(%ebp),%eax
80105625:	01 c2                	add    %eax,%edx
80105627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010562a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105630:	89 42 04             	mov    %eax,0x4(%edx)
        table[i].gid = p->gid;
80105633:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105636:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105639:	8b 45 0c             	mov    0xc(%ebp),%eax
8010563c:	01 c2                	add    %eax,%edx
8010563e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105641:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80105647:	89 42 08             	mov    %eax,0x8(%edx)
        table[i].ppid = p->parent->pid;
8010564a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010564d:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105650:	8b 45 0c             	mov    0xc(%ebp),%eax
80105653:	01 c2                	add    %eax,%edx
80105655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105658:	8b 40 14             	mov    0x14(%eax),%eax
8010565b:	8b 40 10             	mov    0x10(%eax),%eax
8010565e:	89 42 0c             	mov    %eax,0xc(%edx)
        table[i].elapsed_ticks = ticks - p->start_ticks;
80105661:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105664:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105667:	8b 45 0c             	mov    0xc(%ebp),%eax
8010566a:	01 c2                	add    %eax,%edx
8010566c:	8b 0d e0 66 11 80    	mov    0x801166e0,%ecx
80105672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105675:	8b 40 7c             	mov    0x7c(%eax),%eax
80105678:	29 c1                	sub    %eax,%ecx
8010567a:	89 c8                	mov    %ecx,%eax
8010567c:	89 42 10             	mov    %eax,0x10(%edx)
        table[i].CPU_total_ticks = p->cpu_ticks_total;
8010567f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105682:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105685:	8b 45 0c             	mov    0xc(%ebp),%eax
80105688:	01 c2                	add    %eax,%edx
8010568a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568d:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105693:	89 42 14             	mov    %eax,0x14(%edx)
        table[i].size = p->sz;
80105696:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105699:	6b d0 5c             	imul   $0x5c,%eax,%edx
8010569c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010569f:	01 c2                	add    %eax,%edx
801056a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a4:	8b 00                	mov    (%eax),%eax
801056a6:	89 42 38             	mov    %eax,0x38(%edx)

        safestrcpy(table[i].state, states[p->state], STRMAX);
801056a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ac:	8b 40 0c             	mov    0xc(%eax),%eax
801056af:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801056b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056b9:	6b ca 5c             	imul   $0x5c,%edx,%ecx
801056bc:	8b 55 0c             	mov    0xc(%ebp),%edx
801056bf:	01 ca                	add    %ecx,%edx
801056c1:	83 c2 18             	add    $0x18,%edx
801056c4:	83 ec 04             	sub    $0x4,%esp
801056c7:	6a 20                	push   $0x20
801056c9:	50                   	push   %eax
801056ca:	52                   	push   %edx
801056cb:	e8 a3 09 00 00       	call   80106073 <safestrcpy>
801056d0:	83 c4 10             	add    $0x10,%esp
        safestrcpy(table[i++].name, p->name, STRMAX);
801056d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d6:	8d 48 6c             	lea    0x6c(%eax),%ecx
801056d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056dc:	8d 50 01             	lea    0x1(%eax),%edx
801056df:	89 55 f0             	mov    %edx,-0x10(%ebp)
801056e2:	6b d0 5c             	imul   $0x5c,%eax,%edx
801056e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801056e8:	01 d0                	add    %edx,%eax
801056ea:	83 c0 3c             	add    $0x3c,%eax
801056ed:	83 ec 04             	sub    $0x4,%esp
801056f0:	6a 20                	push   $0x20
801056f2:	51                   	push   %ecx
801056f3:	50                   	push   %eax
801056f4:	e8 7a 09 00 00       	call   80106073 <safestrcpy>
801056f9:	83 c4 10             	add    $0x10,%esp
801056fc:	eb 08                	jmp    80105706 <getprocs+0x157>
    }
    else
      return -1;
801056fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105703:	eb 20                	jmp    80105725 <getprocs+0x176>
  struct proc * p;
  int i;

  for(i = 0, p = ptable.proc; p < &ptable.proc[NPROC] && i < max; p++){
    if(p->state == UNUSED || p->state == EMBRYO)
      continue;
80105705:	90                   	nop
#ifdef CS333_P2
int getprocs(uint max, struct uproc * table){
  struct proc * p;
  int i;

  for(i = 0, p = ptable.proc; p < &ptable.proc[NPROC] && i < max; p++){
80105706:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
8010570d:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
80105714:	73 0c                	jae    80105722 <getprocs+0x173>
80105716:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105719:	3b 45 08             	cmp    0x8(%ebp),%eax
8010571c:	0f 82 a6 fe ff ff    	jb     801055c8 <getprocs+0x19>
        safestrcpy(table[i++].name, p->name, STRMAX);
    }
    else
      return -1;
  }
  return i;
80105722:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105725:	c9                   	leave  
80105726:	c3                   	ret    

80105727 <checker>:
#endif

#ifdef CS333_P3P4
static void
checker(int to_check)//, int t, enum procstate c, enum procstate s)
{
80105727:	55                   	push   %ebp
80105728:	89 e5                	mov    %esp,%ebp
8010572a:	83 ec 08             	sub    $0x8,%esp
  if(to_check)   //cprintf("- type %d  c - %s   s -  %s", t, states[c],states[s]);
8010572d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105731:	74 0d                	je     80105740 <checker+0x19>
    panic("Error: Add/remove Failed");
80105733:	83 ec 0c             	sub    $0xc,%esp
80105736:	68 1d 97 10 80       	push   $0x8010971d
8010573b:	e8 26 ae ff ff       	call   80100566 <panic>
}
80105740:	90                   	nop
80105741:	c9                   	leave  
80105742:	c3                   	ret    

80105743 <removeFromStateList>:
static int
removeFromStateList(struct proc ** sList, struct proc * p)
{
80105743:	55                   	push   %ebp
80105744:	89 e5                	mov    %esp,%ebp
80105746:	83 ec 18             	sub    $0x18,%esp
    struct proc * head = *sList;
80105749:	8b 45 08             	mov    0x8(%ebp),%eax
8010574c:	8b 00                	mov    (%eax),%eax
8010574e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!p || !head)
80105751:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105755:	74 06                	je     8010575d <removeFromStateList+0x1a>
80105757:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010575b:	75 07                	jne    80105764 <removeFromStateList+0x21>
        return -1;
8010575d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105762:	eb 3b                	jmp    8010579f <removeFromStateList+0x5c>
    if(p == head)
80105764:	8b 45 0c             	mov    0xc(%ebp),%eax
80105767:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010576a:	75 22                	jne    8010578e <removeFromStateList+0x4b>
    {
      *sList = head->next;
8010576c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010576f:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105775:	8b 45 08             	mov    0x8(%ebp),%eax
80105778:	89 10                	mov    %edx,(%eax)
      p->next = 0;
8010577a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010577d:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105784:	00 00 00 
      return 0;
80105787:	b8 00 00 00 00       	mov    $0x0,%eax
8010578c:	eb 11                	jmp    8010579f <removeFromStateList+0x5c>
    }
    else
      return remove_helper(sList, p);
8010578e:	83 ec 08             	sub    $0x8,%esp
80105791:	ff 75 0c             	pushl  0xc(%ebp)
80105794:	ff 75 08             	pushl  0x8(%ebp)
80105797:	e8 05 00 00 00       	call   801057a1 <remove_helper>
8010579c:	83 c4 10             	add    $0x10,%esp
}
8010579f:	c9                   	leave  
801057a0:	c3                   	ret    

801057a1 <remove_helper>:
int
remove_helper(struct proc ** sList, struct proc * p)
{
801057a1:	55                   	push   %ebp
801057a2:	89 e5                	mov    %esp,%ebp
801057a4:	83 ec 18             	sub    $0x18,%esp
    struct proc * head = *sList;
801057a7:	8b 45 08             	mov    0x8(%ebp),%eax
801057aa:	8b 00                	mov    (%eax),%eax
801057ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!head)
801057af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057b3:	75 07                	jne    801057bc <remove_helper+0x1b>
      return -1;
801057b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057ba:	eb 5e                	jmp    8010581a <remove_helper+0x79>
    if(head->next)
801057bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057bf:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801057c5:	85 c0                	test   %eax,%eax
801057c7:	74 3a                	je     80105803 <remove_helper+0x62>
      if(p == head->next)
801057c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057cc:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801057d2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801057d5:	75 2c                	jne    80105803 <remove_helper+0x62>
        {
          head->next = head->next->next;
801057d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057da:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801057e0:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
801057e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e9:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
          p->next = 0;
801057ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801057f2:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801057f9:	00 00 00 
          return 0;
801057fc:	b8 00 00 00 00       	mov    $0x0,%eax
80105801:	eb 17                	jmp    8010581a <remove_helper+0x79>
        }
    return remove_helper(&head->next, p);
80105803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105806:	05 90 00 00 00       	add    $0x90,%eax
8010580b:	83 ec 08             	sub    $0x8,%esp
8010580e:	ff 75 0c             	pushl  0xc(%ebp)
80105811:	50                   	push   %eax
80105812:	e8 8a ff ff ff       	call   801057a1 <remove_helper>
80105817:	83 c4 10             	add    $0x10,%esp
}
8010581a:	c9                   	leave  
8010581b:	c3                   	ret    

8010581c <assertState>:
static void
assertState(struct proc * p, enum procstate state)
{
8010581c:	55                   	push   %ebp
8010581d:	89 e5                	mov    %esp,%ebp
8010581f:	83 ec 08             	sub    $0x8,%esp
  if(p->state != state)
80105822:	8b 45 08             	mov    0x8(%ebp),%eax
80105825:	8b 40 0c             	mov    0xc(%eax),%eax
80105828:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010582b:	74 36                	je     80105863 <assertState+0x47>
  {
    cprintf("Error: States does not match! process state is %s - It should be %s", states[p->state], states[state]);
8010582d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105830:	8b 14 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%edx
80105837:	8b 45 08             	mov    0x8(%ebp),%eax
8010583a:	8b 40 0c             	mov    0xc(%eax),%eax
8010583d:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105844:	83 ec 04             	sub    $0x4,%esp
80105847:	52                   	push   %edx
80105848:	50                   	push   %eax
80105849:	68 38 97 10 80       	push   $0x80109738
8010584e:	e8 73 ab ff ff       	call   801003c6 <cprintf>
80105853:	83 c4 10             	add    $0x10,%esp
    panic("\n");
80105856:	83 ec 0c             	sub    $0xc,%esp
80105859:	68 1b 97 10 80       	push   $0x8010971b
8010585e:	e8 03 ad ff ff       	call   80100566 <panic>
  }
}
80105863:	90                   	nop
80105864:	c9                   	leave  
80105865:	c3                   	ret    

80105866 <addToStateListEnd>:
static int
addToStateListEnd(struct proc ** sList, struct proc * p)
{
80105866:	55                   	push   %ebp
80105867:	89 e5                	mov    %esp,%ebp
80105869:	83 ec 18             	sub    $0x18,%esp
  struct proc * temp = *sList;
8010586c:	8b 45 08             	mov    0x8(%ebp),%eax
8010586f:	8b 00                	mov    (%eax),%eax
80105871:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!*sList)
80105874:	8b 45 08             	mov    0x8(%ebp),%eax
80105877:	8b 00                	mov    (%eax),%eax
80105879:	85 c0                	test   %eax,%eax
8010587b:	75 13                	jne    80105890 <addToStateListEnd+0x2a>
    return addToStateListHead(sList, p);
8010587d:	83 ec 08             	sub    $0x8,%esp
80105880:	ff 75 0c             	pushl  0xc(%ebp)
80105883:	ff 75 08             	pushl  0x8(%ebp)
80105886:	e8 4b 00 00 00       	call   801058d6 <addToStateListHead>
8010588b:	83 c4 10             	add    $0x10,%esp
8010588e:	eb 44                	jmp    801058d4 <addToStateListEnd+0x6e>
  if(!p)
80105890:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105894:	75 13                	jne    801058a9 <addToStateListEnd+0x43>
    return -1;
80105896:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010589b:	eb 37                	jmp    801058d4 <addToStateListEnd+0x6e>
  while(temp->next)
    temp = temp->next;
8010589d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a0:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801058a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct proc * temp = *sList;
  if(!*sList)
    return addToStateListHead(sList, p);
  if(!p)
    return -1;
  while(temp->next)
801058a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ac:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801058b2:	85 c0                	test   %eax,%eax
801058b4:	75 e7                	jne    8010589d <addToStateListEnd+0x37>
    temp = temp->next;
  p->next = 0;
801058b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801058b9:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801058c0:	00 00 00 
  temp->next = p;
801058c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c6:	8b 55 0c             	mov    0xc(%ebp),%edx
801058c9:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
  return 0;
801058cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058d4:	c9                   	leave  
801058d5:	c3                   	ret    

801058d6 <addToStateListHead>:
static int
addToStateListHead(struct proc ** sList, struct proc * p)
{
801058d6:	55                   	push   %ebp
801058d7:	89 e5                	mov    %esp,%ebp
  if(!p)
801058d9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058dd:	75 07                	jne    801058e6 <addToStateListHead+0x10>
    return -1;
801058df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058e4:	eb 1b                	jmp    80105901 <addToStateListHead+0x2b>
  p->next = *sList;
801058e6:	8b 45 08             	mov    0x8(%ebp),%eax
801058e9:	8b 10                	mov    (%eax),%edx
801058eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ee:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
  *sList = p;
801058f4:	8b 45 08             	mov    0x8(%ebp),%eax
801058f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801058fa:	89 10                	mov    %edx,(%eax)
  return 0;
801058fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105901:	5d                   	pop    %ebp
80105902:	c3                   	ret    

80105903 <removeAndHeadInsert>:
static void
removeAndHeadInsert(struct proc * p, struct proc ** to_remove, struct proc ** to_add, enum procstate to_check, enum procstate assign_state)//for readability 
{
80105903:	55                   	push   %ebp
80105904:	89 e5                	mov    %esp,%ebp
80105906:	83 ec 08             	sub    $0x8,%esp
  //cprintf("in head - p = %s || to_check = %s\n", states[p->state], states[to_check]);
  assertState(p, to_check);
80105909:	83 ec 08             	sub    $0x8,%esp
8010590c:	ff 75 14             	pushl  0x14(%ebp)
8010590f:	ff 75 08             	pushl  0x8(%ebp)
80105912:	e8 05 ff ff ff       	call   8010581c <assertState>
80105917:	83 c4 10             	add    $0x10,%esp
  checker(removeFromStateList(to_remove, p));//, 1, to_check , assign_state);
8010591a:	83 ec 08             	sub    $0x8,%esp
8010591d:	ff 75 08             	pushl  0x8(%ebp)
80105920:	ff 75 0c             	pushl  0xc(%ebp)
80105923:	e8 1b fe ff ff       	call   80105743 <removeFromStateList>
80105928:	83 c4 10             	add    $0x10,%esp
8010592b:	83 ec 0c             	sub    $0xc,%esp
8010592e:	50                   	push   %eax
8010592f:	e8 f3 fd ff ff       	call   80105727 <checker>
80105934:	83 c4 10             	add    $0x10,%esp
  p->state = assign_state;
80105937:	8b 45 08             	mov    0x8(%ebp),%eax
8010593a:	8b 55 18             	mov    0x18(%ebp),%edx
8010593d:	89 50 0c             	mov    %edx,0xc(%eax)
  checker(addToStateListHead(to_add, p));//, 2, p->state, to_check);
80105940:	83 ec 08             	sub    $0x8,%esp
80105943:	ff 75 08             	pushl  0x8(%ebp)
80105946:	ff 75 10             	pushl  0x10(%ebp)
80105949:	e8 88 ff ff ff       	call   801058d6 <addToStateListHead>
8010594e:	83 c4 10             	add    $0x10,%esp
80105951:	83 ec 0c             	sub    $0xc,%esp
80105954:	50                   	push   %eax
80105955:	e8 cd fd ff ff       	call   80105727 <checker>
8010595a:	83 c4 10             	add    $0x10,%esp
}
8010595d:	90                   	nop
8010595e:	c9                   	leave  
8010595f:	c3                   	ret    

80105960 <removeAndEndInsert>:
static void
removeAndEndInsert(struct proc * p, struct proc ** to_remove, struct proc ** to_add, enum procstate to_check, enum procstate assign_state)//for readability 
{
80105960:	55                   	push   %ebp
80105961:	89 e5                	mov    %esp,%ebp
80105963:	83 ec 08             	sub    $0x8,%esp
  assertState(p, to_check);
80105966:	83 ec 08             	sub    $0x8,%esp
80105969:	ff 75 14             	pushl  0x14(%ebp)
8010596c:	ff 75 08             	pushl  0x8(%ebp)
8010596f:	e8 a8 fe ff ff       	call   8010581c <assertState>
80105974:	83 c4 10             	add    $0x10,%esp
  checker(removeFromStateList(to_remove, p));//, 3, to_check, assign_state);
80105977:	83 ec 08             	sub    $0x8,%esp
8010597a:	ff 75 08             	pushl  0x8(%ebp)
8010597d:	ff 75 0c             	pushl  0xc(%ebp)
80105980:	e8 be fd ff ff       	call   80105743 <removeFromStateList>
80105985:	83 c4 10             	add    $0x10,%esp
80105988:	83 ec 0c             	sub    $0xc,%esp
8010598b:	50                   	push   %eax
8010598c:	e8 96 fd ff ff       	call   80105727 <checker>
80105991:	83 c4 10             	add    $0x10,%esp
  p->state = assign_state;
80105994:	8b 45 08             	mov    0x8(%ebp),%eax
80105997:	8b 55 18             	mov    0x18(%ebp),%edx
8010599a:	89 50 0c             	mov    %edx,0xc(%eax)
  checker(addToStateListEnd(to_add, p));//, 4, p->state, to_check);
8010599d:	83 ec 08             	sub    $0x8,%esp
801059a0:	ff 75 08             	pushl  0x8(%ebp)
801059a3:	ff 75 10             	pushl  0x10(%ebp)
801059a6:	e8 bb fe ff ff       	call   80105866 <addToStateListEnd>
801059ab:	83 c4 10             	add    $0x10,%esp
801059ae:	83 ec 0c             	sub    $0xc,%esp
801059b1:	50                   	push   %eax
801059b2:	e8 70 fd ff ff       	call   80105727 <checker>
801059b7:	83 c4 10             	add    $0x10,%esp

}
801059ba:	90                   	nop
801059bb:	c9                   	leave  
801059bc:	c3                   	ret    

801059bd <control_r>:
void 
control_r(void)
{
801059bd:	55                   	push   %ebp
801059be:	89 e5                	mov    %esp,%ebp
801059c0:	83 ec 18             	sub    $0x18,%esp
  struct proc * p = ptable.pLists.ready;
801059c3:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
801059c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("Ready List Processes:\n");
801059cb:	83 ec 0c             	sub    $0xc,%esp
801059ce:	68 7c 97 10 80       	push   $0x8010977c
801059d3:	e8 ee a9 ff ff       	call   801003c6 <cprintf>
801059d8:	83 c4 10             	add    $0x10,%esp
  if(!p)
801059db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059df:	75 5b                	jne    80105a3c <control_r+0x7f>
    cprintf("Empty\n");
801059e1:	83 ec 0c             	sub    $0xc,%esp
801059e4:	68 93 97 10 80       	push   $0x80109793
801059e9:	e8 d8 a9 ff ff       	call   801003c6 <cprintf>
801059ee:	83 c4 10             	add    $0x10,%esp

  while(p)
801059f1:	eb 49                	jmp    80105a3c <control_r+0x7f>
  {
    if(p->next)
801059f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f6:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801059fc:	85 c0                	test   %eax,%eax
801059fe:	74 19                	je     80105a19 <control_r+0x5c>
      cprintf("%d -> ", p->pid);
80105a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a03:	8b 40 10             	mov    0x10(%eax),%eax
80105a06:	83 ec 08             	sub    $0x8,%esp
80105a09:	50                   	push   %eax
80105a0a:	68 9a 97 10 80       	push   $0x8010979a
80105a0f:	e8 b2 a9 ff ff       	call   801003c6 <cprintf>
80105a14:	83 c4 10             	add    $0x10,%esp
80105a17:	eb 17                	jmp    80105a30 <control_r+0x73>
    else
      cprintf("%d\n", p->pid);
80105a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1c:	8b 40 10             	mov    0x10(%eax),%eax
80105a1f:	83 ec 08             	sub    $0x8,%esp
80105a22:	50                   	push   %eax
80105a23:	68 a1 97 10 80       	push   $0x801097a1
80105a28:	e8 99 a9 ff ff       	call   801003c6 <cprintf>
80105a2d:	83 c4 10             	add    $0x10,%esp
    p = p->next;
80105a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a33:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105a39:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct proc * p = ptable.pLists.ready;
  cprintf("Ready List Processes:\n");
  if(!p)
    cprintf("Empty\n");

  while(p)
80105a3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a40:	75 b1                	jne    801059f3 <control_r+0x36>
      cprintf("%d -> ", p->pid);
    else
      cprintf("%d\n", p->pid);
    p = p->next;
  }
}
80105a42:	90                   	nop
80105a43:	c9                   	leave  
80105a44:	c3                   	ret    

80105a45 <control_f>:
void 
control_f(void)
{
80105a45:	55                   	push   %ebp
80105a46:	89 e5                	mov    %esp,%ebp
80105a48:	83 ec 18             	sub    $0x18,%esp
  int i = 0;
80105a4b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  struct proc * p = ptable.pLists.free;
80105a52:	a1 b8 5e 11 80       	mov    0x80115eb8,%eax
80105a57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; p; ++i)
80105a5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105a61:	eb 10                	jmp    80105a73 <control_f+0x2e>
    p = p->next;
80105a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a66:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105a6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
void 
control_f(void)
{
  int i = 0;
  struct proc * p = ptable.pLists.free;
  for(i = 0; p; ++i)
80105a6f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105a73:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a77:	75 ea                	jne    80105a63 <control_f+0x1e>
    p = p->next;
  cprintf("Free List Size: %d processes\n", i);
80105a79:	83 ec 08             	sub    $0x8,%esp
80105a7c:	ff 75 f4             	pushl  -0xc(%ebp)
80105a7f:	68 a5 97 10 80       	push   $0x801097a5
80105a84:	e8 3d a9 ff ff       	call   801003c6 <cprintf>
80105a89:	83 c4 10             	add    $0x10,%esp
}
80105a8c:	90                   	nop
80105a8d:	c9                   	leave  
80105a8e:	c3                   	ret    

80105a8f <control_s>:
void 
control_s(void)
{
80105a8f:	55                   	push   %ebp
80105a90:	89 e5                	mov    %esp,%ebp
80105a92:	83 ec 18             	sub    $0x18,%esp
  struct proc * p = ptable.pLists.sleep;
80105a95:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
80105a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("Sleep List Processes:\n");
80105a9d:	83 ec 0c             	sub    $0xc,%esp
80105aa0:	68 c3 97 10 80       	push   $0x801097c3
80105aa5:	e8 1c a9 ff ff       	call   801003c6 <cprintf>
80105aaa:	83 c4 10             	add    $0x10,%esp
  if(!p)
80105aad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ab1:	75 5b                	jne    80105b0e <control_s+0x7f>
    cprintf("Empty\n");
80105ab3:	83 ec 0c             	sub    $0xc,%esp
80105ab6:	68 93 97 10 80       	push   $0x80109793
80105abb:	e8 06 a9 ff ff       	call   801003c6 <cprintf>
80105ac0:	83 c4 10             	add    $0x10,%esp

  while(p)
80105ac3:	eb 49                	jmp    80105b0e <control_s+0x7f>
  {
    if(p->next)
80105ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac8:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105ace:	85 c0                	test   %eax,%eax
80105ad0:	74 19                	je     80105aeb <control_s+0x5c>
      cprintf("%d -> ", p->pid);
80105ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad5:	8b 40 10             	mov    0x10(%eax),%eax
80105ad8:	83 ec 08             	sub    $0x8,%esp
80105adb:	50                   	push   %eax
80105adc:	68 9a 97 10 80       	push   $0x8010979a
80105ae1:	e8 e0 a8 ff ff       	call   801003c6 <cprintf>
80105ae6:	83 c4 10             	add    $0x10,%esp
80105ae9:	eb 17                	jmp    80105b02 <control_s+0x73>
    else
      cprintf("%d\n", p->pid);
80105aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aee:	8b 40 10             	mov    0x10(%eax),%eax
80105af1:	83 ec 08             	sub    $0x8,%esp
80105af4:	50                   	push   %eax
80105af5:	68 a1 97 10 80       	push   $0x801097a1
80105afa:	e8 c7 a8 ff ff       	call   801003c6 <cprintf>
80105aff:	83 c4 10             	add    $0x10,%esp
    p = p->next;
80105b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b05:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105b0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct proc * p = ptable.pLists.sleep;
  cprintf("Sleep List Processes:\n");
  if(!p)
    cprintf("Empty\n");

  while(p)
80105b0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b12:	75 b1                	jne    80105ac5 <control_s+0x36>
      cprintf("%d -> ", p->pid);
    else
      cprintf("%d\n", p->pid);
    p = p->next;
  }
}
80105b14:	90                   	nop
80105b15:	c9                   	leave  
80105b16:	c3                   	ret    

80105b17 <control_z>:
void 
control_z(void)
{
80105b17:	55                   	push   %ebp
80105b18:	89 e5                	mov    %esp,%ebp
80105b1a:	83 ec 18             	sub    $0x18,%esp
  struct proc * p = ptable.pLists.zombie;
80105b1d:	a1 c0 5e 11 80       	mov    0x80115ec0,%eax
80105b22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("Zombie List Processes:\n");
80105b25:	83 ec 0c             	sub    $0xc,%esp
80105b28:	68 da 97 10 80       	push   $0x801097da
80105b2d:	e8 94 a8 ff ff       	call   801003c6 <cprintf>
80105b32:	83 c4 10             	add    $0x10,%esp
  if(!p)
80105b35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b39:	75 6f                	jne    80105baa <control_z+0x93>
    cprintf("Empty\n");
80105b3b:	83 ec 0c             	sub    $0xc,%esp
80105b3e:	68 93 97 10 80       	push   $0x80109793
80105b43:	e8 7e a8 ff ff       	call   801003c6 <cprintf>
80105b48:	83 c4 10             	add    $0x10,%esp

  while(p)
80105b4b:	eb 5d                	jmp    80105baa <control_z+0x93>
  {
    if(p->next)
80105b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b50:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105b56:	85 c0                	test   %eax,%eax
80105b58:	74 23                	je     80105b7d <control_z+0x66>
      cprintf("(%d, %d) -> ", p->pid, p->parent->pid);
80105b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5d:	8b 40 14             	mov    0x14(%eax),%eax
80105b60:	8b 50 10             	mov    0x10(%eax),%edx
80105b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b66:	8b 40 10             	mov    0x10(%eax),%eax
80105b69:	83 ec 04             	sub    $0x4,%esp
80105b6c:	52                   	push   %edx
80105b6d:	50                   	push   %eax
80105b6e:	68 f2 97 10 80       	push   $0x801097f2
80105b73:	e8 4e a8 ff ff       	call   801003c6 <cprintf>
80105b78:	83 c4 10             	add    $0x10,%esp
80105b7b:	eb 21                	jmp    80105b9e <control_z+0x87>
    else
      cprintf("(%d, %d)\n", p->pid, p->parent->pid);;
80105b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b80:	8b 40 14             	mov    0x14(%eax),%eax
80105b83:	8b 50 10             	mov    0x10(%eax),%edx
80105b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b89:	8b 40 10             	mov    0x10(%eax),%eax
80105b8c:	83 ec 04             	sub    $0x4,%esp
80105b8f:	52                   	push   %edx
80105b90:	50                   	push   %eax
80105b91:	68 ff 97 10 80       	push   $0x801097ff
80105b96:	e8 2b a8 ff ff       	call   801003c6 <cprintf>
80105b9b:	83 c4 10             	add    $0x10,%esp
    p = p->next;
80105b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba1:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105ba7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct proc * p = ptable.pLists.zombie;
  cprintf("Zombie List Processes:\n");
  if(!p)
    cprintf("Empty\n");

  while(p)
80105baa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bae:	75 9d                	jne    80105b4d <control_z+0x36>
      cprintf("(%d, %d) -> ", p->pid, p->parent->pid);
    else
      cprintf("(%d, %d)\n", p->pid, p->parent->pid);;
    p = p->next;
  }
}
80105bb0:	90                   	nop
80105bb1:	c9                   	leave  
80105bb2:	c3                   	ret    

80105bb3 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105bb3:	55                   	push   %ebp
80105bb4:	89 e5                	mov    %esp,%ebp
80105bb6:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105bb9:	9c                   	pushf  
80105bba:	58                   	pop    %eax
80105bbb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105bbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105bc1:	c9                   	leave  
80105bc2:	c3                   	ret    

80105bc3 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105bc3:	55                   	push   %ebp
80105bc4:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105bc6:	fa                   	cli    
}
80105bc7:	90                   	nop
80105bc8:	5d                   	pop    %ebp
80105bc9:	c3                   	ret    

80105bca <sti>:

static inline void
sti(void)
{
80105bca:	55                   	push   %ebp
80105bcb:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105bcd:	fb                   	sti    
}
80105bce:	90                   	nop
80105bcf:	5d                   	pop    %ebp
80105bd0:	c3                   	ret    

80105bd1 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105bd1:	55                   	push   %ebp
80105bd2:	89 e5                	mov    %esp,%ebp
80105bd4:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105bd7:	8b 55 08             	mov    0x8(%ebp),%edx
80105bda:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105be0:	f0 87 02             	lock xchg %eax,(%edx)
80105be3:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105be6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105be9:	c9                   	leave  
80105bea:	c3                   	ret    

80105beb <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105beb:	55                   	push   %ebp
80105bec:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105bee:	8b 45 08             	mov    0x8(%ebp),%eax
80105bf1:	8b 55 0c             	mov    0xc(%ebp),%edx
80105bf4:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80105bfa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105c00:	8b 45 08             	mov    0x8(%ebp),%eax
80105c03:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105c0a:	90                   	nop
80105c0b:	5d                   	pop    %ebp
80105c0c:	c3                   	ret    

80105c0d <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105c0d:	55                   	push   %ebp
80105c0e:	89 e5                	mov    %esp,%ebp
80105c10:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105c13:	e8 52 01 00 00       	call   80105d6a <pushcli>
  if(holding(lk))
80105c18:	8b 45 08             	mov    0x8(%ebp),%eax
80105c1b:	83 ec 0c             	sub    $0xc,%esp
80105c1e:	50                   	push   %eax
80105c1f:	e8 1c 01 00 00       	call   80105d40 <holding>
80105c24:	83 c4 10             	add    $0x10,%esp
80105c27:	85 c0                	test   %eax,%eax
80105c29:	74 0d                	je     80105c38 <acquire+0x2b>
    panic("acquire");
80105c2b:	83 ec 0c             	sub    $0xc,%esp
80105c2e:	68 09 98 10 80       	push   $0x80109809
80105c33:	e8 2e a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105c38:	90                   	nop
80105c39:	8b 45 08             	mov    0x8(%ebp),%eax
80105c3c:	83 ec 08             	sub    $0x8,%esp
80105c3f:	6a 01                	push   $0x1
80105c41:	50                   	push   %eax
80105c42:	e8 8a ff ff ff       	call   80105bd1 <xchg>
80105c47:	83 c4 10             	add    $0x10,%esp
80105c4a:	85 c0                	test   %eax,%eax
80105c4c:	75 eb                	jne    80105c39 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c51:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105c58:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80105c5e:	83 c0 0c             	add    $0xc,%eax
80105c61:	83 ec 08             	sub    $0x8,%esp
80105c64:	50                   	push   %eax
80105c65:	8d 45 08             	lea    0x8(%ebp),%eax
80105c68:	50                   	push   %eax
80105c69:	e8 58 00 00 00       	call   80105cc6 <getcallerpcs>
80105c6e:	83 c4 10             	add    $0x10,%esp
}
80105c71:	90                   	nop
80105c72:	c9                   	leave  
80105c73:	c3                   	ret    

80105c74 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105c74:	55                   	push   %ebp
80105c75:	89 e5                	mov    %esp,%ebp
80105c77:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105c7a:	83 ec 0c             	sub    $0xc,%esp
80105c7d:	ff 75 08             	pushl  0x8(%ebp)
80105c80:	e8 bb 00 00 00       	call   80105d40 <holding>
80105c85:	83 c4 10             	add    $0x10,%esp
80105c88:	85 c0                	test   %eax,%eax
80105c8a:	75 0d                	jne    80105c99 <release+0x25>
    panic("release");
80105c8c:	83 ec 0c             	sub    $0xc,%esp
80105c8f:	68 11 98 10 80       	push   $0x80109811
80105c94:	e8 cd a8 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105c99:	8b 45 08             	mov    0x8(%ebp),%eax
80105c9c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105cad:	8b 45 08             	mov    0x8(%ebp),%eax
80105cb0:	83 ec 08             	sub    $0x8,%esp
80105cb3:	6a 00                	push   $0x0
80105cb5:	50                   	push   %eax
80105cb6:	e8 16 ff ff ff       	call   80105bd1 <xchg>
80105cbb:	83 c4 10             	add    $0x10,%esp

  popcli();
80105cbe:	e8 ec 00 00 00       	call   80105daf <popcli>
}
80105cc3:	90                   	nop
80105cc4:	c9                   	leave  
80105cc5:	c3                   	ret    

80105cc6 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105cc6:	55                   	push   %ebp
80105cc7:	89 e5                	mov    %esp,%ebp
80105cc9:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105ccc:	8b 45 08             	mov    0x8(%ebp),%eax
80105ccf:	83 e8 08             	sub    $0x8,%eax
80105cd2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105cd5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105cdc:	eb 38                	jmp    80105d16 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105cde:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105ce2:	74 53                	je     80105d37 <getcallerpcs+0x71>
80105ce4:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105ceb:	76 4a                	jbe    80105d37 <getcallerpcs+0x71>
80105ced:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105cf1:	74 44                	je     80105d37 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105cf3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105cf6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d00:	01 c2                	add    %eax,%edx
80105d02:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d05:	8b 40 04             	mov    0x4(%eax),%eax
80105d08:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105d0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d0d:	8b 00                	mov    (%eax),%eax
80105d0f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105d12:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105d16:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105d1a:	7e c2                	jle    80105cde <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105d1c:	eb 19                	jmp    80105d37 <getcallerpcs+0x71>
    pcs[i] = 0;
80105d1e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d21:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105d28:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d2b:	01 d0                	add    %edx,%eax
80105d2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105d33:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105d37:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105d3b:	7e e1                	jle    80105d1e <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105d3d:	90                   	nop
80105d3e:	c9                   	leave  
80105d3f:	c3                   	ret    

80105d40 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105d40:	55                   	push   %ebp
80105d41:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105d43:	8b 45 08             	mov    0x8(%ebp),%eax
80105d46:	8b 00                	mov    (%eax),%eax
80105d48:	85 c0                	test   %eax,%eax
80105d4a:	74 17                	je     80105d63 <holding+0x23>
80105d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80105d4f:	8b 50 08             	mov    0x8(%eax),%edx
80105d52:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d58:	39 c2                	cmp    %eax,%edx
80105d5a:	75 07                	jne    80105d63 <holding+0x23>
80105d5c:	b8 01 00 00 00       	mov    $0x1,%eax
80105d61:	eb 05                	jmp    80105d68 <holding+0x28>
80105d63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d68:	5d                   	pop    %ebp
80105d69:	c3                   	ret    

80105d6a <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105d6a:	55                   	push   %ebp
80105d6b:	89 e5                	mov    %esp,%ebp
80105d6d:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105d70:	e8 3e fe ff ff       	call   80105bb3 <readeflags>
80105d75:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105d78:	e8 46 fe ff ff       	call   80105bc3 <cli>
  if(cpu->ncli++ == 0)
80105d7d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105d84:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105d8a:	8d 48 01             	lea    0x1(%eax),%ecx
80105d8d:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105d93:	85 c0                	test   %eax,%eax
80105d95:	75 15                	jne    80105dac <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105d97:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d9d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105da0:	81 e2 00 02 00 00    	and    $0x200,%edx
80105da6:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105dac:	90                   	nop
80105dad:	c9                   	leave  
80105dae:	c3                   	ret    

80105daf <popcli>:

void
popcli(void)
{
80105daf:	55                   	push   %ebp
80105db0:	89 e5                	mov    %esp,%ebp
80105db2:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105db5:	e8 f9 fd ff ff       	call   80105bb3 <readeflags>
80105dba:	25 00 02 00 00       	and    $0x200,%eax
80105dbf:	85 c0                	test   %eax,%eax
80105dc1:	74 0d                	je     80105dd0 <popcli+0x21>
    panic("popcli - interruptible");
80105dc3:	83 ec 0c             	sub    $0xc,%esp
80105dc6:	68 19 98 10 80       	push   $0x80109819
80105dcb:	e8 96 a7 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105dd0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105dd6:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105ddc:	83 ea 01             	sub    $0x1,%edx
80105ddf:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105de5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105deb:	85 c0                	test   %eax,%eax
80105ded:	79 0d                	jns    80105dfc <popcli+0x4d>
    panic("popcli");
80105def:	83 ec 0c             	sub    $0xc,%esp
80105df2:	68 30 98 10 80       	push   $0x80109830
80105df7:	e8 6a a7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105dfc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e02:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105e08:	85 c0                	test   %eax,%eax
80105e0a:	75 15                	jne    80105e21 <popcli+0x72>
80105e0c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e12:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105e18:	85 c0                	test   %eax,%eax
80105e1a:	74 05                	je     80105e21 <popcli+0x72>
    sti();
80105e1c:	e8 a9 fd ff ff       	call   80105bca <sti>
}
80105e21:	90                   	nop
80105e22:	c9                   	leave  
80105e23:	c3                   	ret    

80105e24 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105e24:	55                   	push   %ebp
80105e25:	89 e5                	mov    %esp,%ebp
80105e27:	57                   	push   %edi
80105e28:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105e29:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105e2c:	8b 55 10             	mov    0x10(%ebp),%edx
80105e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e32:	89 cb                	mov    %ecx,%ebx
80105e34:	89 df                	mov    %ebx,%edi
80105e36:	89 d1                	mov    %edx,%ecx
80105e38:	fc                   	cld    
80105e39:	f3 aa                	rep stos %al,%es:(%edi)
80105e3b:	89 ca                	mov    %ecx,%edx
80105e3d:	89 fb                	mov    %edi,%ebx
80105e3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105e42:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105e45:	90                   	nop
80105e46:	5b                   	pop    %ebx
80105e47:	5f                   	pop    %edi
80105e48:	5d                   	pop    %ebp
80105e49:	c3                   	ret    

80105e4a <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105e4a:	55                   	push   %ebp
80105e4b:	89 e5                	mov    %esp,%ebp
80105e4d:	57                   	push   %edi
80105e4e:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105e4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105e52:	8b 55 10             	mov    0x10(%ebp),%edx
80105e55:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e58:	89 cb                	mov    %ecx,%ebx
80105e5a:	89 df                	mov    %ebx,%edi
80105e5c:	89 d1                	mov    %edx,%ecx
80105e5e:	fc                   	cld    
80105e5f:	f3 ab                	rep stos %eax,%es:(%edi)
80105e61:	89 ca                	mov    %ecx,%edx
80105e63:	89 fb                	mov    %edi,%ebx
80105e65:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105e68:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105e6b:	90                   	nop
80105e6c:	5b                   	pop    %ebx
80105e6d:	5f                   	pop    %edi
80105e6e:	5d                   	pop    %ebp
80105e6f:	c3                   	ret    

80105e70 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105e70:	55                   	push   %ebp
80105e71:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105e73:	8b 45 08             	mov    0x8(%ebp),%eax
80105e76:	83 e0 03             	and    $0x3,%eax
80105e79:	85 c0                	test   %eax,%eax
80105e7b:	75 43                	jne    80105ec0 <memset+0x50>
80105e7d:	8b 45 10             	mov    0x10(%ebp),%eax
80105e80:	83 e0 03             	and    $0x3,%eax
80105e83:	85 c0                	test   %eax,%eax
80105e85:	75 39                	jne    80105ec0 <memset+0x50>
    c &= 0xFF;
80105e87:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105e8e:	8b 45 10             	mov    0x10(%ebp),%eax
80105e91:	c1 e8 02             	shr    $0x2,%eax
80105e94:	89 c1                	mov    %eax,%ecx
80105e96:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e99:	c1 e0 18             	shl    $0x18,%eax
80105e9c:	89 c2                	mov    %eax,%edx
80105e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ea1:	c1 e0 10             	shl    $0x10,%eax
80105ea4:	09 c2                	or     %eax,%edx
80105ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ea9:	c1 e0 08             	shl    $0x8,%eax
80105eac:	09 d0                	or     %edx,%eax
80105eae:	0b 45 0c             	or     0xc(%ebp),%eax
80105eb1:	51                   	push   %ecx
80105eb2:	50                   	push   %eax
80105eb3:	ff 75 08             	pushl  0x8(%ebp)
80105eb6:	e8 8f ff ff ff       	call   80105e4a <stosl>
80105ebb:	83 c4 0c             	add    $0xc,%esp
80105ebe:	eb 12                	jmp    80105ed2 <memset+0x62>
  } else
    stosb(dst, c, n);
80105ec0:	8b 45 10             	mov    0x10(%ebp),%eax
80105ec3:	50                   	push   %eax
80105ec4:	ff 75 0c             	pushl  0xc(%ebp)
80105ec7:	ff 75 08             	pushl  0x8(%ebp)
80105eca:	e8 55 ff ff ff       	call   80105e24 <stosb>
80105ecf:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105ed2:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105ed5:	c9                   	leave  
80105ed6:	c3                   	ret    

80105ed7 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105ed7:	55                   	push   %ebp
80105ed8:	89 e5                	mov    %esp,%ebp
80105eda:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105edd:	8b 45 08             	mov    0x8(%ebp),%eax
80105ee0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ee6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105ee9:	eb 30                	jmp    80105f1b <memcmp+0x44>
    if(*s1 != *s2)
80105eeb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105eee:	0f b6 10             	movzbl (%eax),%edx
80105ef1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ef4:	0f b6 00             	movzbl (%eax),%eax
80105ef7:	38 c2                	cmp    %al,%dl
80105ef9:	74 18                	je     80105f13 <memcmp+0x3c>
      return *s1 - *s2;
80105efb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105efe:	0f b6 00             	movzbl (%eax),%eax
80105f01:	0f b6 d0             	movzbl %al,%edx
80105f04:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f07:	0f b6 00             	movzbl (%eax),%eax
80105f0a:	0f b6 c0             	movzbl %al,%eax
80105f0d:	29 c2                	sub    %eax,%edx
80105f0f:	89 d0                	mov    %edx,%eax
80105f11:	eb 1a                	jmp    80105f2d <memcmp+0x56>
    s1++, s2++;
80105f13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105f17:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105f1b:	8b 45 10             	mov    0x10(%ebp),%eax
80105f1e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f21:	89 55 10             	mov    %edx,0x10(%ebp)
80105f24:	85 c0                	test   %eax,%eax
80105f26:	75 c3                	jne    80105eeb <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105f28:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f2d:	c9                   	leave  
80105f2e:	c3                   	ret    

80105f2f <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105f2f:	55                   	push   %ebp
80105f30:	89 e5                	mov    %esp,%ebp
80105f32:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105f35:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f38:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80105f3e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105f41:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f44:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105f47:	73 54                	jae    80105f9d <memmove+0x6e>
80105f49:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f4c:	8b 45 10             	mov    0x10(%ebp),%eax
80105f4f:	01 d0                	add    %edx,%eax
80105f51:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105f54:	76 47                	jbe    80105f9d <memmove+0x6e>
    s += n;
80105f56:	8b 45 10             	mov    0x10(%ebp),%eax
80105f59:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105f5c:	8b 45 10             	mov    0x10(%ebp),%eax
80105f5f:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105f62:	eb 13                	jmp    80105f77 <memmove+0x48>
      *--d = *--s;
80105f64:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105f68:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105f6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f6f:	0f b6 10             	movzbl (%eax),%edx
80105f72:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f75:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105f77:	8b 45 10             	mov    0x10(%ebp),%eax
80105f7a:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f7d:	89 55 10             	mov    %edx,0x10(%ebp)
80105f80:	85 c0                	test   %eax,%eax
80105f82:	75 e0                	jne    80105f64 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105f84:	eb 24                	jmp    80105faa <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105f86:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f89:	8d 50 01             	lea    0x1(%eax),%edx
80105f8c:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105f8f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f92:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f95:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105f98:	0f b6 12             	movzbl (%edx),%edx
80105f9b:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105f9d:	8b 45 10             	mov    0x10(%ebp),%eax
80105fa0:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fa3:	89 55 10             	mov    %edx,0x10(%ebp)
80105fa6:	85 c0                	test   %eax,%eax
80105fa8:	75 dc                	jne    80105f86 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105faa:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105fad:	c9                   	leave  
80105fae:	c3                   	ret    

80105faf <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105faf:	55                   	push   %ebp
80105fb0:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105fb2:	ff 75 10             	pushl  0x10(%ebp)
80105fb5:	ff 75 0c             	pushl  0xc(%ebp)
80105fb8:	ff 75 08             	pushl  0x8(%ebp)
80105fbb:	e8 6f ff ff ff       	call   80105f2f <memmove>
80105fc0:	83 c4 0c             	add    $0xc,%esp
}
80105fc3:	c9                   	leave  
80105fc4:	c3                   	ret    

80105fc5 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105fc5:	55                   	push   %ebp
80105fc6:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105fc8:	eb 0c                	jmp    80105fd6 <strncmp+0x11>
    n--, p++, q++;
80105fca:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105fce:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105fd2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105fd6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105fda:	74 1a                	je     80105ff6 <strncmp+0x31>
80105fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80105fdf:	0f b6 00             	movzbl (%eax),%eax
80105fe2:	84 c0                	test   %al,%al
80105fe4:	74 10                	je     80105ff6 <strncmp+0x31>
80105fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80105fe9:	0f b6 10             	movzbl (%eax),%edx
80105fec:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fef:	0f b6 00             	movzbl (%eax),%eax
80105ff2:	38 c2                	cmp    %al,%dl
80105ff4:	74 d4                	je     80105fca <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105ff6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ffa:	75 07                	jne    80106003 <strncmp+0x3e>
    return 0;
80105ffc:	b8 00 00 00 00       	mov    $0x0,%eax
80106001:	eb 16                	jmp    80106019 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80106003:	8b 45 08             	mov    0x8(%ebp),%eax
80106006:	0f b6 00             	movzbl (%eax),%eax
80106009:	0f b6 d0             	movzbl %al,%edx
8010600c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010600f:	0f b6 00             	movzbl (%eax),%eax
80106012:	0f b6 c0             	movzbl %al,%eax
80106015:	29 c2                	sub    %eax,%edx
80106017:	89 d0                	mov    %edx,%eax
}
80106019:	5d                   	pop    %ebp
8010601a:	c3                   	ret    

8010601b <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010601b:	55                   	push   %ebp
8010601c:	89 e5                	mov    %esp,%ebp
8010601e:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106021:	8b 45 08             	mov    0x8(%ebp),%eax
80106024:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80106027:	90                   	nop
80106028:	8b 45 10             	mov    0x10(%ebp),%eax
8010602b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010602e:	89 55 10             	mov    %edx,0x10(%ebp)
80106031:	85 c0                	test   %eax,%eax
80106033:	7e 2c                	jle    80106061 <strncpy+0x46>
80106035:	8b 45 08             	mov    0x8(%ebp),%eax
80106038:	8d 50 01             	lea    0x1(%eax),%edx
8010603b:	89 55 08             	mov    %edx,0x8(%ebp)
8010603e:	8b 55 0c             	mov    0xc(%ebp),%edx
80106041:	8d 4a 01             	lea    0x1(%edx),%ecx
80106044:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106047:	0f b6 12             	movzbl (%edx),%edx
8010604a:	88 10                	mov    %dl,(%eax)
8010604c:	0f b6 00             	movzbl (%eax),%eax
8010604f:	84 c0                	test   %al,%al
80106051:	75 d5                	jne    80106028 <strncpy+0xd>
    ;
  while(n-- > 0)
80106053:	eb 0c                	jmp    80106061 <strncpy+0x46>
    *s++ = 0;
80106055:	8b 45 08             	mov    0x8(%ebp),%eax
80106058:	8d 50 01             	lea    0x1(%eax),%edx
8010605b:	89 55 08             	mov    %edx,0x8(%ebp)
8010605e:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106061:	8b 45 10             	mov    0x10(%ebp),%eax
80106064:	8d 50 ff             	lea    -0x1(%eax),%edx
80106067:	89 55 10             	mov    %edx,0x10(%ebp)
8010606a:	85 c0                	test   %eax,%eax
8010606c:	7f e7                	jg     80106055 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010606e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106071:	c9                   	leave  
80106072:	c3                   	ret    

80106073 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106073:	55                   	push   %ebp
80106074:	89 e5                	mov    %esp,%ebp
80106076:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106079:	8b 45 08             	mov    0x8(%ebp),%eax
8010607c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010607f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106083:	7f 05                	jg     8010608a <safestrcpy+0x17>
    return os;
80106085:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106088:	eb 31                	jmp    801060bb <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010608a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010608e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106092:	7e 1e                	jle    801060b2 <safestrcpy+0x3f>
80106094:	8b 45 08             	mov    0x8(%ebp),%eax
80106097:	8d 50 01             	lea    0x1(%eax),%edx
8010609a:	89 55 08             	mov    %edx,0x8(%ebp)
8010609d:	8b 55 0c             	mov    0xc(%ebp),%edx
801060a0:	8d 4a 01             	lea    0x1(%edx),%ecx
801060a3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801060a6:	0f b6 12             	movzbl (%edx),%edx
801060a9:	88 10                	mov    %dl,(%eax)
801060ab:	0f b6 00             	movzbl (%eax),%eax
801060ae:	84 c0                	test   %al,%al
801060b0:	75 d8                	jne    8010608a <safestrcpy+0x17>
    ;
  *s = 0;
801060b2:	8b 45 08             	mov    0x8(%ebp),%eax
801060b5:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801060b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801060bb:	c9                   	leave  
801060bc:	c3                   	ret    

801060bd <strlen>:

int
strlen(const char *s)
{
801060bd:	55                   	push   %ebp
801060be:	89 e5                	mov    %esp,%ebp
801060c0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801060c3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801060ca:	eb 04                	jmp    801060d0 <strlen+0x13>
801060cc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801060d0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060d3:	8b 45 08             	mov    0x8(%ebp),%eax
801060d6:	01 d0                	add    %edx,%eax
801060d8:	0f b6 00             	movzbl (%eax),%eax
801060db:	84 c0                	test   %al,%al
801060dd:	75 ed                	jne    801060cc <strlen+0xf>
    ;
  return n;
801060df:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801060e2:	c9                   	leave  
801060e3:	c3                   	ret    

801060e4 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801060e4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801060e8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801060ec:	55                   	push   %ebp
  pushl %ebx
801060ed:	53                   	push   %ebx
  pushl %esi
801060ee:	56                   	push   %esi
  pushl %edi
801060ef:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801060f0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801060f2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801060f4:	5f                   	pop    %edi
  popl %esi
801060f5:	5e                   	pop    %esi
  popl %ebx
801060f6:	5b                   	pop    %ebx
  popl %ebp
801060f7:	5d                   	pop    %ebp
  ret
801060f8:	c3                   	ret    

801060f9 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801060f9:	55                   	push   %ebp
801060fa:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801060fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106102:	8b 00                	mov    (%eax),%eax
80106104:	3b 45 08             	cmp    0x8(%ebp),%eax
80106107:	76 12                	jbe    8010611b <fetchint+0x22>
80106109:	8b 45 08             	mov    0x8(%ebp),%eax
8010610c:	8d 50 04             	lea    0x4(%eax),%edx
8010610f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106115:	8b 00                	mov    (%eax),%eax
80106117:	39 c2                	cmp    %eax,%edx
80106119:	76 07                	jbe    80106122 <fetchint+0x29>
    return -1;
8010611b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106120:	eb 0f                	jmp    80106131 <fetchint+0x38>
  *ip = *(int*)(addr);
80106122:	8b 45 08             	mov    0x8(%ebp),%eax
80106125:	8b 10                	mov    (%eax),%edx
80106127:	8b 45 0c             	mov    0xc(%ebp),%eax
8010612a:	89 10                	mov    %edx,(%eax)
  return 0;
8010612c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106131:	5d                   	pop    %ebp
80106132:	c3                   	ret    

80106133 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106133:	55                   	push   %ebp
80106134:	89 e5                	mov    %esp,%ebp
80106136:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80106139:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010613f:	8b 00                	mov    (%eax),%eax
80106141:	3b 45 08             	cmp    0x8(%ebp),%eax
80106144:	77 07                	ja     8010614d <fetchstr+0x1a>
    return -1;
80106146:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614b:	eb 46                	jmp    80106193 <fetchstr+0x60>
  *pp = (char*)addr;
8010614d:	8b 55 08             	mov    0x8(%ebp),%edx
80106150:	8b 45 0c             	mov    0xc(%ebp),%eax
80106153:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106155:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010615b:	8b 00                	mov    (%eax),%eax
8010615d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106160:	8b 45 0c             	mov    0xc(%ebp),%eax
80106163:	8b 00                	mov    (%eax),%eax
80106165:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106168:	eb 1c                	jmp    80106186 <fetchstr+0x53>
    if(*s == 0)
8010616a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010616d:	0f b6 00             	movzbl (%eax),%eax
80106170:	84 c0                	test   %al,%al
80106172:	75 0e                	jne    80106182 <fetchstr+0x4f>
      return s - *pp;
80106174:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106177:	8b 45 0c             	mov    0xc(%ebp),%eax
8010617a:	8b 00                	mov    (%eax),%eax
8010617c:	29 c2                	sub    %eax,%edx
8010617e:	89 d0                	mov    %edx,%eax
80106180:	eb 11                	jmp    80106193 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106182:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106186:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106189:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010618c:	72 dc                	jb     8010616a <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010618e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106193:	c9                   	leave  
80106194:	c3                   	ret    

80106195 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106195:	55                   	push   %ebp
80106196:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106198:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010619e:	8b 40 18             	mov    0x18(%eax),%eax
801061a1:	8b 40 44             	mov    0x44(%eax),%eax
801061a4:	8b 55 08             	mov    0x8(%ebp),%edx
801061a7:	c1 e2 02             	shl    $0x2,%edx
801061aa:	01 d0                	add    %edx,%eax
801061ac:	83 c0 04             	add    $0x4,%eax
801061af:	ff 75 0c             	pushl  0xc(%ebp)
801061b2:	50                   	push   %eax
801061b3:	e8 41 ff ff ff       	call   801060f9 <fetchint>
801061b8:	83 c4 08             	add    $0x8,%esp
}
801061bb:	c9                   	leave  
801061bc:	c3                   	ret    

801061bd <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801061bd:	55                   	push   %ebp
801061be:	89 e5                	mov    %esp,%ebp
801061c0:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
801061c3:	8d 45 fc             	lea    -0x4(%ebp),%eax
801061c6:	50                   	push   %eax
801061c7:	ff 75 08             	pushl  0x8(%ebp)
801061ca:	e8 c6 ff ff ff       	call   80106195 <argint>
801061cf:	83 c4 08             	add    $0x8,%esp
801061d2:	85 c0                	test   %eax,%eax
801061d4:	79 07                	jns    801061dd <argptr+0x20>
    return -1;
801061d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061db:	eb 3b                	jmp    80106218 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801061dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061e3:	8b 00                	mov    (%eax),%eax
801061e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061e8:	39 d0                	cmp    %edx,%eax
801061ea:	76 16                	jbe    80106202 <argptr+0x45>
801061ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061ef:	89 c2                	mov    %eax,%edx
801061f1:	8b 45 10             	mov    0x10(%ebp),%eax
801061f4:	01 c2                	add    %eax,%edx
801061f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061fc:	8b 00                	mov    (%eax),%eax
801061fe:	39 c2                	cmp    %eax,%edx
80106200:	76 07                	jbe    80106209 <argptr+0x4c>
    return -1;
80106202:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106207:	eb 0f                	jmp    80106218 <argptr+0x5b>
  *pp = (char*)i;
80106209:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010620c:	89 c2                	mov    %eax,%edx
8010620e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106211:	89 10                	mov    %edx,(%eax)
  return 0;
80106213:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106218:	c9                   	leave  
80106219:	c3                   	ret    

8010621a <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010621a:	55                   	push   %ebp
8010621b:	89 e5                	mov    %esp,%ebp
8010621d:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106220:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106223:	50                   	push   %eax
80106224:	ff 75 08             	pushl  0x8(%ebp)
80106227:	e8 69 ff ff ff       	call   80106195 <argint>
8010622c:	83 c4 08             	add    $0x8,%esp
8010622f:	85 c0                	test   %eax,%eax
80106231:	79 07                	jns    8010623a <argstr+0x20>
    return -1;
80106233:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106238:	eb 0f                	jmp    80106249 <argstr+0x2f>
  return fetchstr(addr, pp);
8010623a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010623d:	ff 75 0c             	pushl  0xc(%ebp)
80106240:	50                   	push   %eax
80106241:	e8 ed fe ff ff       	call   80106133 <fetchstr>
80106246:	83 c4 08             	add    $0x8,%esp
}
80106249:	c9                   	leave  
8010624a:	c3                   	ret    

8010624b <syscall>:
#endif
};
#endif
void
syscall(void)
{
8010624b:	55                   	push   %ebp
8010624c:	89 e5                	mov    %esp,%ebp
8010624e:	53                   	push   %ebx
8010624f:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106252:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106258:	8b 40 18             	mov    0x18(%eax),%eax
8010625b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010625e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106261:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106265:	7e 30                	jle    80106297 <syscall+0x4c>
80106267:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626a:	83 f8 1d             	cmp    $0x1d,%eax
8010626d:	77 28                	ja     80106297 <syscall+0x4c>
8010626f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106272:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106279:	85 c0                	test   %eax,%eax
8010627b:	74 1a                	je     80106297 <syscall+0x4c>
#ifdef PRINT_SYSCALLS
    int sys_ret = syscalls[num]();
    proc->tf->eax = sys_ret;
#else
    proc->tf->eax = syscalls[num]();
8010627d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106283:	8b 58 18             	mov    0x18(%eax),%ebx
80106286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106289:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106290:	ff d0                	call   *%eax
80106292:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106295:	eb 34                	jmp    801062cb <syscall+0x80>
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num], sys_ret);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106297:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010629d:	8d 50 6c             	lea    0x6c(%eax),%edx
801062a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// some code goes here
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num], sys_ret);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801062a6:	8b 40 10             	mov    0x10(%eax),%eax
801062a9:	ff 75 f4             	pushl  -0xc(%ebp)
801062ac:	52                   	push   %edx
801062ad:	50                   	push   %eax
801062ae:	68 37 98 10 80       	push   $0x80109837
801062b3:	e8 0e a1 ff ff       	call   801003c6 <cprintf>
801062b8:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801062bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062c1:	8b 40 18             	mov    0x18(%eax),%eax
801062c4:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801062cb:	90                   	nop
801062cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801062cf:	c9                   	leave  
801062d0:	c3                   	ret    

801062d1 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801062d1:	55                   	push   %ebp
801062d2:	89 e5                	mov    %esp,%ebp
801062d4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801062d7:	83 ec 08             	sub    $0x8,%esp
801062da:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062dd:	50                   	push   %eax
801062de:	ff 75 08             	pushl  0x8(%ebp)
801062e1:	e8 af fe ff ff       	call   80106195 <argint>
801062e6:	83 c4 10             	add    $0x10,%esp
801062e9:	85 c0                	test   %eax,%eax
801062eb:	79 07                	jns    801062f4 <argfd+0x23>
    return -1;
801062ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f2:	eb 50                	jmp    80106344 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801062f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f7:	85 c0                	test   %eax,%eax
801062f9:	78 21                	js     8010631c <argfd+0x4b>
801062fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062fe:	83 f8 0f             	cmp    $0xf,%eax
80106301:	7f 19                	jg     8010631c <argfd+0x4b>
80106303:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106309:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010630c:	83 c2 08             	add    $0x8,%edx
8010630f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106313:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106316:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010631a:	75 07                	jne    80106323 <argfd+0x52>
    return -1;
8010631c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106321:	eb 21                	jmp    80106344 <argfd+0x73>
  if(pfd)
80106323:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106327:	74 08                	je     80106331 <argfd+0x60>
    *pfd = fd;
80106329:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010632c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010632f:	89 10                	mov    %edx,(%eax)
  if(pf)
80106331:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106335:	74 08                	je     8010633f <argfd+0x6e>
    *pf = f;
80106337:	8b 45 10             	mov    0x10(%ebp),%eax
8010633a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010633d:	89 10                	mov    %edx,(%eax)
  return 0;
8010633f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106344:	c9                   	leave  
80106345:	c3                   	ret    

80106346 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106346:	55                   	push   %ebp
80106347:	89 e5                	mov    %esp,%ebp
80106349:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010634c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106353:	eb 30                	jmp    80106385 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106355:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010635b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010635e:	83 c2 08             	add    $0x8,%edx
80106361:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106365:	85 c0                	test   %eax,%eax
80106367:	75 18                	jne    80106381 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80106369:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010636f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106372:	8d 4a 08             	lea    0x8(%edx),%ecx
80106375:	8b 55 08             	mov    0x8(%ebp),%edx
80106378:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010637c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010637f:	eb 0f                	jmp    80106390 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106381:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106385:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106389:	7e ca                	jle    80106355 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010638b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106390:	c9                   	leave  
80106391:	c3                   	ret    

80106392 <sys_dup>:

int
sys_dup(void)
{
80106392:	55                   	push   %ebp
80106393:	89 e5                	mov    %esp,%ebp
80106395:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80106398:	83 ec 04             	sub    $0x4,%esp
8010639b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010639e:	50                   	push   %eax
8010639f:	6a 00                	push   $0x0
801063a1:	6a 00                	push   $0x0
801063a3:	e8 29 ff ff ff       	call   801062d1 <argfd>
801063a8:	83 c4 10             	add    $0x10,%esp
801063ab:	85 c0                	test   %eax,%eax
801063ad:	79 07                	jns    801063b6 <sys_dup+0x24>
    return -1;
801063af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b4:	eb 31                	jmp    801063e7 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801063b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b9:	83 ec 0c             	sub    $0xc,%esp
801063bc:	50                   	push   %eax
801063bd:	e8 84 ff ff ff       	call   80106346 <fdalloc>
801063c2:	83 c4 10             	add    $0x10,%esp
801063c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063cc:	79 07                	jns    801063d5 <sys_dup+0x43>
    return -1;
801063ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d3:	eb 12                	jmp    801063e7 <sys_dup+0x55>
  filedup(f);
801063d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d8:	83 ec 0c             	sub    $0xc,%esp
801063db:	50                   	push   %eax
801063dc:	e8 c1 ac ff ff       	call   801010a2 <filedup>
801063e1:	83 c4 10             	add    $0x10,%esp
  return fd;
801063e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063e7:	c9                   	leave  
801063e8:	c3                   	ret    

801063e9 <sys_read>:

int
sys_read(void)
{
801063e9:	55                   	push   %ebp
801063ea:	89 e5                	mov    %esp,%ebp
801063ec:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063ef:	83 ec 04             	sub    $0x4,%esp
801063f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063f5:	50                   	push   %eax
801063f6:	6a 00                	push   $0x0
801063f8:	6a 00                	push   $0x0
801063fa:	e8 d2 fe ff ff       	call   801062d1 <argfd>
801063ff:	83 c4 10             	add    $0x10,%esp
80106402:	85 c0                	test   %eax,%eax
80106404:	78 2e                	js     80106434 <sys_read+0x4b>
80106406:	83 ec 08             	sub    $0x8,%esp
80106409:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010640c:	50                   	push   %eax
8010640d:	6a 02                	push   $0x2
8010640f:	e8 81 fd ff ff       	call   80106195 <argint>
80106414:	83 c4 10             	add    $0x10,%esp
80106417:	85 c0                	test   %eax,%eax
80106419:	78 19                	js     80106434 <sys_read+0x4b>
8010641b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641e:	83 ec 04             	sub    $0x4,%esp
80106421:	50                   	push   %eax
80106422:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106425:	50                   	push   %eax
80106426:	6a 01                	push   $0x1
80106428:	e8 90 fd ff ff       	call   801061bd <argptr>
8010642d:	83 c4 10             	add    $0x10,%esp
80106430:	85 c0                	test   %eax,%eax
80106432:	79 07                	jns    8010643b <sys_read+0x52>
    return -1;
80106434:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106439:	eb 17                	jmp    80106452 <sys_read+0x69>
  return fileread(f, p, n);
8010643b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010643e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106444:	83 ec 04             	sub    $0x4,%esp
80106447:	51                   	push   %ecx
80106448:	52                   	push   %edx
80106449:	50                   	push   %eax
8010644a:	e8 e3 ad ff ff       	call   80101232 <fileread>
8010644f:	83 c4 10             	add    $0x10,%esp
}
80106452:	c9                   	leave  
80106453:	c3                   	ret    

80106454 <sys_write>:

int
sys_write(void)
{
80106454:	55                   	push   %ebp
80106455:	89 e5                	mov    %esp,%ebp
80106457:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010645a:	83 ec 04             	sub    $0x4,%esp
8010645d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106460:	50                   	push   %eax
80106461:	6a 00                	push   $0x0
80106463:	6a 00                	push   $0x0
80106465:	e8 67 fe ff ff       	call   801062d1 <argfd>
8010646a:	83 c4 10             	add    $0x10,%esp
8010646d:	85 c0                	test   %eax,%eax
8010646f:	78 2e                	js     8010649f <sys_write+0x4b>
80106471:	83 ec 08             	sub    $0x8,%esp
80106474:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106477:	50                   	push   %eax
80106478:	6a 02                	push   $0x2
8010647a:	e8 16 fd ff ff       	call   80106195 <argint>
8010647f:	83 c4 10             	add    $0x10,%esp
80106482:	85 c0                	test   %eax,%eax
80106484:	78 19                	js     8010649f <sys_write+0x4b>
80106486:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106489:	83 ec 04             	sub    $0x4,%esp
8010648c:	50                   	push   %eax
8010648d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106490:	50                   	push   %eax
80106491:	6a 01                	push   $0x1
80106493:	e8 25 fd ff ff       	call   801061bd <argptr>
80106498:	83 c4 10             	add    $0x10,%esp
8010649b:	85 c0                	test   %eax,%eax
8010649d:	79 07                	jns    801064a6 <sys_write+0x52>
    return -1;
8010649f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a4:	eb 17                	jmp    801064bd <sys_write+0x69>
  return filewrite(f, p, n);
801064a6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801064a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801064ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064af:	83 ec 04             	sub    $0x4,%esp
801064b2:	51                   	push   %ecx
801064b3:	52                   	push   %edx
801064b4:	50                   	push   %eax
801064b5:	e8 30 ae ff ff       	call   801012ea <filewrite>
801064ba:	83 c4 10             	add    $0x10,%esp
}
801064bd:	c9                   	leave  
801064be:	c3                   	ret    

801064bf <sys_close>:

int
sys_close(void)
{
801064bf:	55                   	push   %ebp
801064c0:	89 e5                	mov    %esp,%ebp
801064c2:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801064c5:	83 ec 04             	sub    $0x4,%esp
801064c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064cb:	50                   	push   %eax
801064cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064cf:	50                   	push   %eax
801064d0:	6a 00                	push   $0x0
801064d2:	e8 fa fd ff ff       	call   801062d1 <argfd>
801064d7:	83 c4 10             	add    $0x10,%esp
801064da:	85 c0                	test   %eax,%eax
801064dc:	79 07                	jns    801064e5 <sys_close+0x26>
    return -1;
801064de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e3:	eb 28                	jmp    8010650d <sys_close+0x4e>
  proc->ofile[fd] = 0;
801064e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064ee:	83 c2 08             	add    $0x8,%edx
801064f1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801064f8:	00 
  fileclose(f);
801064f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064fc:	83 ec 0c             	sub    $0xc,%esp
801064ff:	50                   	push   %eax
80106500:	e8 ee ab ff ff       	call   801010f3 <fileclose>
80106505:	83 c4 10             	add    $0x10,%esp
  return 0;
80106508:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010650d:	c9                   	leave  
8010650e:	c3                   	ret    

8010650f <sys_fstat>:

int
sys_fstat(void)
{
8010650f:	55                   	push   %ebp
80106510:	89 e5                	mov    %esp,%ebp
80106512:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106515:	83 ec 04             	sub    $0x4,%esp
80106518:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010651b:	50                   	push   %eax
8010651c:	6a 00                	push   $0x0
8010651e:	6a 00                	push   $0x0
80106520:	e8 ac fd ff ff       	call   801062d1 <argfd>
80106525:	83 c4 10             	add    $0x10,%esp
80106528:	85 c0                	test   %eax,%eax
8010652a:	78 17                	js     80106543 <sys_fstat+0x34>
8010652c:	83 ec 04             	sub    $0x4,%esp
8010652f:	6a 14                	push   $0x14
80106531:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106534:	50                   	push   %eax
80106535:	6a 01                	push   $0x1
80106537:	e8 81 fc ff ff       	call   801061bd <argptr>
8010653c:	83 c4 10             	add    $0x10,%esp
8010653f:	85 c0                	test   %eax,%eax
80106541:	79 07                	jns    8010654a <sys_fstat+0x3b>
    return -1;
80106543:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106548:	eb 13                	jmp    8010655d <sys_fstat+0x4e>
  return filestat(f, st);
8010654a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010654d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106550:	83 ec 08             	sub    $0x8,%esp
80106553:	52                   	push   %edx
80106554:	50                   	push   %eax
80106555:	e8 81 ac ff ff       	call   801011db <filestat>
8010655a:	83 c4 10             	add    $0x10,%esp
}
8010655d:	c9                   	leave  
8010655e:	c3                   	ret    

8010655f <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010655f:	55                   	push   %ebp
80106560:	89 e5                	mov    %esp,%ebp
80106562:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106565:	83 ec 08             	sub    $0x8,%esp
80106568:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010656b:	50                   	push   %eax
8010656c:	6a 00                	push   $0x0
8010656e:	e8 a7 fc ff ff       	call   8010621a <argstr>
80106573:	83 c4 10             	add    $0x10,%esp
80106576:	85 c0                	test   %eax,%eax
80106578:	78 15                	js     8010658f <sys_link+0x30>
8010657a:	83 ec 08             	sub    $0x8,%esp
8010657d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106580:	50                   	push   %eax
80106581:	6a 01                	push   $0x1
80106583:	e8 92 fc ff ff       	call   8010621a <argstr>
80106588:	83 c4 10             	add    $0x10,%esp
8010658b:	85 c0                	test   %eax,%eax
8010658d:	79 0a                	jns    80106599 <sys_link+0x3a>
    return -1;
8010658f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106594:	e9 68 01 00 00       	jmp    80106701 <sys_link+0x1a2>

  begin_op();
80106599:	e8 51 d0 ff ff       	call   801035ef <begin_op>
  if((ip = namei(old)) == 0){
8010659e:	8b 45 d8             	mov    -0x28(%ebp),%eax
801065a1:	83 ec 0c             	sub    $0xc,%esp
801065a4:	50                   	push   %eax
801065a5:	e8 20 c0 ff ff       	call   801025ca <namei>
801065aa:	83 c4 10             	add    $0x10,%esp
801065ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065b4:	75 0f                	jne    801065c5 <sys_link+0x66>
    end_op();
801065b6:	e8 c0 d0 ff ff       	call   8010367b <end_op>
    return -1;
801065bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c0:	e9 3c 01 00 00       	jmp    80106701 <sys_link+0x1a2>
  }

  ilock(ip);
801065c5:	83 ec 0c             	sub    $0xc,%esp
801065c8:	ff 75 f4             	pushl  -0xc(%ebp)
801065cb:	e8 3c b4 ff ff       	call   80101a0c <ilock>
801065d0:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801065d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065da:	66 83 f8 01          	cmp    $0x1,%ax
801065de:	75 1d                	jne    801065fd <sys_link+0x9e>
    iunlockput(ip);
801065e0:	83 ec 0c             	sub    $0xc,%esp
801065e3:	ff 75 f4             	pushl  -0xc(%ebp)
801065e6:	e8 e1 b6 ff ff       	call   80101ccc <iunlockput>
801065eb:	83 c4 10             	add    $0x10,%esp
    end_op();
801065ee:	e8 88 d0 ff ff       	call   8010367b <end_op>
    return -1;
801065f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f8:	e9 04 01 00 00       	jmp    80106701 <sys_link+0x1a2>
  }

  ip->nlink++;
801065fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106600:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106604:	83 c0 01             	add    $0x1,%eax
80106607:	89 c2                	mov    %eax,%edx
80106609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010660c:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106610:	83 ec 0c             	sub    $0xc,%esp
80106613:	ff 75 f4             	pushl  -0xc(%ebp)
80106616:	e8 17 b2 ff ff       	call   80101832 <iupdate>
8010661b:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010661e:	83 ec 0c             	sub    $0xc,%esp
80106621:	ff 75 f4             	pushl  -0xc(%ebp)
80106624:	e8 41 b5 ff ff       	call   80101b6a <iunlock>
80106629:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010662c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010662f:	83 ec 08             	sub    $0x8,%esp
80106632:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106635:	52                   	push   %edx
80106636:	50                   	push   %eax
80106637:	e8 aa bf ff ff       	call   801025e6 <nameiparent>
8010663c:	83 c4 10             	add    $0x10,%esp
8010663f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106642:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106646:	74 71                	je     801066b9 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80106648:	83 ec 0c             	sub    $0xc,%esp
8010664b:	ff 75 f0             	pushl  -0x10(%ebp)
8010664e:	e8 b9 b3 ff ff       	call   80101a0c <ilock>
80106653:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106659:	8b 10                	mov    (%eax),%edx
8010665b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010665e:	8b 00                	mov    (%eax),%eax
80106660:	39 c2                	cmp    %eax,%edx
80106662:	75 1d                	jne    80106681 <sys_link+0x122>
80106664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106667:	8b 40 04             	mov    0x4(%eax),%eax
8010666a:	83 ec 04             	sub    $0x4,%esp
8010666d:	50                   	push   %eax
8010666e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106671:	50                   	push   %eax
80106672:	ff 75 f0             	pushl  -0x10(%ebp)
80106675:	e8 b4 bc ff ff       	call   8010232e <dirlink>
8010667a:	83 c4 10             	add    $0x10,%esp
8010667d:	85 c0                	test   %eax,%eax
8010667f:	79 10                	jns    80106691 <sys_link+0x132>
    iunlockput(dp);
80106681:	83 ec 0c             	sub    $0xc,%esp
80106684:	ff 75 f0             	pushl  -0x10(%ebp)
80106687:	e8 40 b6 ff ff       	call   80101ccc <iunlockput>
8010668c:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010668f:	eb 29                	jmp    801066ba <sys_link+0x15b>
  }
  iunlockput(dp);
80106691:	83 ec 0c             	sub    $0xc,%esp
80106694:	ff 75 f0             	pushl  -0x10(%ebp)
80106697:	e8 30 b6 ff ff       	call   80101ccc <iunlockput>
8010669c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010669f:	83 ec 0c             	sub    $0xc,%esp
801066a2:	ff 75 f4             	pushl  -0xc(%ebp)
801066a5:	e8 32 b5 ff ff       	call   80101bdc <iput>
801066aa:	83 c4 10             	add    $0x10,%esp

  end_op();
801066ad:	e8 c9 cf ff ff       	call   8010367b <end_op>

  return 0;
801066b2:	b8 00 00 00 00       	mov    $0x0,%eax
801066b7:	eb 48                	jmp    80106701 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801066b9:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801066ba:	83 ec 0c             	sub    $0xc,%esp
801066bd:	ff 75 f4             	pushl  -0xc(%ebp)
801066c0:	e8 47 b3 ff ff       	call   80101a0c <ilock>
801066c5:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801066c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066cb:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801066cf:	83 e8 01             	sub    $0x1,%eax
801066d2:	89 c2                	mov    %eax,%edx
801066d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d7:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801066db:	83 ec 0c             	sub    $0xc,%esp
801066de:	ff 75 f4             	pushl  -0xc(%ebp)
801066e1:	e8 4c b1 ff ff       	call   80101832 <iupdate>
801066e6:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801066e9:	83 ec 0c             	sub    $0xc,%esp
801066ec:	ff 75 f4             	pushl  -0xc(%ebp)
801066ef:	e8 d8 b5 ff ff       	call   80101ccc <iunlockput>
801066f4:	83 c4 10             	add    $0x10,%esp
  end_op();
801066f7:	e8 7f cf ff ff       	call   8010367b <end_op>
  return -1;
801066fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106701:	c9                   	leave  
80106702:	c3                   	ret    

80106703 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106703:	55                   	push   %ebp
80106704:	89 e5                	mov    %esp,%ebp
80106706:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106709:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106710:	eb 40                	jmp    80106752 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106715:	6a 10                	push   $0x10
80106717:	50                   	push   %eax
80106718:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010671b:	50                   	push   %eax
8010671c:	ff 75 08             	pushl  0x8(%ebp)
8010671f:	e8 56 b8 ff ff       	call   80101f7a <readi>
80106724:	83 c4 10             	add    $0x10,%esp
80106727:	83 f8 10             	cmp    $0x10,%eax
8010672a:	74 0d                	je     80106739 <isdirempty+0x36>
      panic("isdirempty: readi");
8010672c:	83 ec 0c             	sub    $0xc,%esp
8010672f:	68 53 98 10 80       	push   $0x80109853
80106734:	e8 2d 9e ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80106739:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010673d:	66 85 c0             	test   %ax,%ax
80106740:	74 07                	je     80106749 <isdirempty+0x46>
      return 0;
80106742:	b8 00 00 00 00       	mov    $0x0,%eax
80106747:	eb 1b                	jmp    80106764 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674c:	83 c0 10             	add    $0x10,%eax
8010674f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106752:	8b 45 08             	mov    0x8(%ebp),%eax
80106755:	8b 50 18             	mov    0x18(%eax),%edx
80106758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675b:	39 c2                	cmp    %eax,%edx
8010675d:	77 b3                	ja     80106712 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010675f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106764:	c9                   	leave  
80106765:	c3                   	ret    

80106766 <sys_unlink>:

int
sys_unlink(void)
{
80106766:	55                   	push   %ebp
80106767:	89 e5                	mov    %esp,%ebp
80106769:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010676c:	83 ec 08             	sub    $0x8,%esp
8010676f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106772:	50                   	push   %eax
80106773:	6a 00                	push   $0x0
80106775:	e8 a0 fa ff ff       	call   8010621a <argstr>
8010677a:	83 c4 10             	add    $0x10,%esp
8010677d:	85 c0                	test   %eax,%eax
8010677f:	79 0a                	jns    8010678b <sys_unlink+0x25>
    return -1;
80106781:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106786:	e9 bc 01 00 00       	jmp    80106947 <sys_unlink+0x1e1>

  begin_op();
8010678b:	e8 5f ce ff ff       	call   801035ef <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106790:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106793:	83 ec 08             	sub    $0x8,%esp
80106796:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106799:	52                   	push   %edx
8010679a:	50                   	push   %eax
8010679b:	e8 46 be ff ff       	call   801025e6 <nameiparent>
801067a0:	83 c4 10             	add    $0x10,%esp
801067a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067aa:	75 0f                	jne    801067bb <sys_unlink+0x55>
    end_op();
801067ac:	e8 ca ce ff ff       	call   8010367b <end_op>
    return -1;
801067b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b6:	e9 8c 01 00 00       	jmp    80106947 <sys_unlink+0x1e1>
  }

  ilock(dp);
801067bb:	83 ec 0c             	sub    $0xc,%esp
801067be:	ff 75 f4             	pushl  -0xc(%ebp)
801067c1:	e8 46 b2 ff ff       	call   80101a0c <ilock>
801067c6:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801067c9:	83 ec 08             	sub    $0x8,%esp
801067cc:	68 65 98 10 80       	push   $0x80109865
801067d1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067d4:	50                   	push   %eax
801067d5:	e8 7f ba ff ff       	call   80102259 <namecmp>
801067da:	83 c4 10             	add    $0x10,%esp
801067dd:	85 c0                	test   %eax,%eax
801067df:	0f 84 4a 01 00 00    	je     8010692f <sys_unlink+0x1c9>
801067e5:	83 ec 08             	sub    $0x8,%esp
801067e8:	68 67 98 10 80       	push   $0x80109867
801067ed:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067f0:	50                   	push   %eax
801067f1:	e8 63 ba ff ff       	call   80102259 <namecmp>
801067f6:	83 c4 10             	add    $0x10,%esp
801067f9:	85 c0                	test   %eax,%eax
801067fb:	0f 84 2e 01 00 00    	je     8010692f <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106801:	83 ec 04             	sub    $0x4,%esp
80106804:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106807:	50                   	push   %eax
80106808:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010680b:	50                   	push   %eax
8010680c:	ff 75 f4             	pushl  -0xc(%ebp)
8010680f:	e8 60 ba ff ff       	call   80102274 <dirlookup>
80106814:	83 c4 10             	add    $0x10,%esp
80106817:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010681a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010681e:	0f 84 0a 01 00 00    	je     8010692e <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80106824:	83 ec 0c             	sub    $0xc,%esp
80106827:	ff 75 f0             	pushl  -0x10(%ebp)
8010682a:	e8 dd b1 ff ff       	call   80101a0c <ilock>
8010682f:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106832:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106835:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106839:	66 85 c0             	test   %ax,%ax
8010683c:	7f 0d                	jg     8010684b <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010683e:	83 ec 0c             	sub    $0xc,%esp
80106841:	68 6a 98 10 80       	push   $0x8010986a
80106846:	e8 1b 9d ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010684b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010684e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106852:	66 83 f8 01          	cmp    $0x1,%ax
80106856:	75 25                	jne    8010687d <sys_unlink+0x117>
80106858:	83 ec 0c             	sub    $0xc,%esp
8010685b:	ff 75 f0             	pushl  -0x10(%ebp)
8010685e:	e8 a0 fe ff ff       	call   80106703 <isdirempty>
80106863:	83 c4 10             	add    $0x10,%esp
80106866:	85 c0                	test   %eax,%eax
80106868:	75 13                	jne    8010687d <sys_unlink+0x117>
    iunlockput(ip);
8010686a:	83 ec 0c             	sub    $0xc,%esp
8010686d:	ff 75 f0             	pushl  -0x10(%ebp)
80106870:	e8 57 b4 ff ff       	call   80101ccc <iunlockput>
80106875:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106878:	e9 b2 00 00 00       	jmp    8010692f <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
8010687d:	83 ec 04             	sub    $0x4,%esp
80106880:	6a 10                	push   $0x10
80106882:	6a 00                	push   $0x0
80106884:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106887:	50                   	push   %eax
80106888:	e8 e3 f5 ff ff       	call   80105e70 <memset>
8010688d:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106890:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106893:	6a 10                	push   $0x10
80106895:	50                   	push   %eax
80106896:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106899:	50                   	push   %eax
8010689a:	ff 75 f4             	pushl  -0xc(%ebp)
8010689d:	e8 2f b8 ff ff       	call   801020d1 <writei>
801068a2:	83 c4 10             	add    $0x10,%esp
801068a5:	83 f8 10             	cmp    $0x10,%eax
801068a8:	74 0d                	je     801068b7 <sys_unlink+0x151>
    panic("unlink: writei");
801068aa:	83 ec 0c             	sub    $0xc,%esp
801068ad:	68 7c 98 10 80       	push   $0x8010987c
801068b2:	e8 af 9c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
801068b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068ba:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068be:	66 83 f8 01          	cmp    $0x1,%ax
801068c2:	75 21                	jne    801068e5 <sys_unlink+0x17f>
    dp->nlink--;
801068c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068c7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068cb:	83 e8 01             	sub    $0x1,%eax
801068ce:	89 c2                	mov    %eax,%edx
801068d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d3:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801068d7:	83 ec 0c             	sub    $0xc,%esp
801068da:	ff 75 f4             	pushl  -0xc(%ebp)
801068dd:	e8 50 af ff ff       	call   80101832 <iupdate>
801068e2:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801068e5:	83 ec 0c             	sub    $0xc,%esp
801068e8:	ff 75 f4             	pushl  -0xc(%ebp)
801068eb:	e8 dc b3 ff ff       	call   80101ccc <iunlockput>
801068f0:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801068f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068f6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068fa:	83 e8 01             	sub    $0x1,%eax
801068fd:	89 c2                	mov    %eax,%edx
801068ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106902:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106906:	83 ec 0c             	sub    $0xc,%esp
80106909:	ff 75 f0             	pushl  -0x10(%ebp)
8010690c:	e8 21 af ff ff       	call   80101832 <iupdate>
80106911:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106914:	83 ec 0c             	sub    $0xc,%esp
80106917:	ff 75 f0             	pushl  -0x10(%ebp)
8010691a:	e8 ad b3 ff ff       	call   80101ccc <iunlockput>
8010691f:	83 c4 10             	add    $0x10,%esp

  end_op();
80106922:	e8 54 cd ff ff       	call   8010367b <end_op>

  return 0;
80106927:	b8 00 00 00 00       	mov    $0x0,%eax
8010692c:	eb 19                	jmp    80106947 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
8010692e:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
8010692f:	83 ec 0c             	sub    $0xc,%esp
80106932:	ff 75 f4             	pushl  -0xc(%ebp)
80106935:	e8 92 b3 ff ff       	call   80101ccc <iunlockput>
8010693a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010693d:	e8 39 cd ff ff       	call   8010367b <end_op>
  return -1;
80106942:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106947:	c9                   	leave  
80106948:	c3                   	ret    

80106949 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106949:	55                   	push   %ebp
8010694a:	89 e5                	mov    %esp,%ebp
8010694c:	83 ec 38             	sub    $0x38,%esp
8010694f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106952:	8b 55 10             	mov    0x10(%ebp),%edx
80106955:	8b 45 14             	mov    0x14(%ebp),%eax
80106958:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010695c:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106960:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106964:	83 ec 08             	sub    $0x8,%esp
80106967:	8d 45 de             	lea    -0x22(%ebp),%eax
8010696a:	50                   	push   %eax
8010696b:	ff 75 08             	pushl  0x8(%ebp)
8010696e:	e8 73 bc ff ff       	call   801025e6 <nameiparent>
80106973:	83 c4 10             	add    $0x10,%esp
80106976:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106979:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010697d:	75 0a                	jne    80106989 <create+0x40>
    return 0;
8010697f:	b8 00 00 00 00       	mov    $0x0,%eax
80106984:	e9 90 01 00 00       	jmp    80106b19 <create+0x1d0>
  ilock(dp);
80106989:	83 ec 0c             	sub    $0xc,%esp
8010698c:	ff 75 f4             	pushl  -0xc(%ebp)
8010698f:	e8 78 b0 ff ff       	call   80101a0c <ilock>
80106994:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106997:	83 ec 04             	sub    $0x4,%esp
8010699a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010699d:	50                   	push   %eax
8010699e:	8d 45 de             	lea    -0x22(%ebp),%eax
801069a1:	50                   	push   %eax
801069a2:	ff 75 f4             	pushl  -0xc(%ebp)
801069a5:	e8 ca b8 ff ff       	call   80102274 <dirlookup>
801069aa:	83 c4 10             	add    $0x10,%esp
801069ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069b4:	74 50                	je     80106a06 <create+0xbd>
    iunlockput(dp);
801069b6:	83 ec 0c             	sub    $0xc,%esp
801069b9:	ff 75 f4             	pushl  -0xc(%ebp)
801069bc:	e8 0b b3 ff ff       	call   80101ccc <iunlockput>
801069c1:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801069c4:	83 ec 0c             	sub    $0xc,%esp
801069c7:	ff 75 f0             	pushl  -0x10(%ebp)
801069ca:	e8 3d b0 ff ff       	call   80101a0c <ilock>
801069cf:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801069d2:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801069d7:	75 15                	jne    801069ee <create+0xa5>
801069d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069dc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801069e0:	66 83 f8 02          	cmp    $0x2,%ax
801069e4:	75 08                	jne    801069ee <create+0xa5>
      return ip;
801069e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069e9:	e9 2b 01 00 00       	jmp    80106b19 <create+0x1d0>
    iunlockput(ip);
801069ee:	83 ec 0c             	sub    $0xc,%esp
801069f1:	ff 75 f0             	pushl  -0x10(%ebp)
801069f4:	e8 d3 b2 ff ff       	call   80101ccc <iunlockput>
801069f9:	83 c4 10             	add    $0x10,%esp
    return 0;
801069fc:	b8 00 00 00 00       	mov    $0x0,%eax
80106a01:	e9 13 01 00 00       	jmp    80106b19 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106a06:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a0d:	8b 00                	mov    (%eax),%eax
80106a0f:	83 ec 08             	sub    $0x8,%esp
80106a12:	52                   	push   %edx
80106a13:	50                   	push   %eax
80106a14:	e8 42 ad ff ff       	call   8010175b <ialloc>
80106a19:	83 c4 10             	add    $0x10,%esp
80106a1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a23:	75 0d                	jne    80106a32 <create+0xe9>
    panic("create: ialloc");
80106a25:	83 ec 0c             	sub    $0xc,%esp
80106a28:	68 8b 98 10 80       	push   $0x8010988b
80106a2d:	e8 34 9b ff ff       	call   80100566 <panic>

  ilock(ip);
80106a32:	83 ec 0c             	sub    $0xc,%esp
80106a35:	ff 75 f0             	pushl  -0x10(%ebp)
80106a38:	e8 cf af ff ff       	call   80101a0c <ilock>
80106a3d:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a43:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106a47:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a4e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106a52:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a59:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106a5f:	83 ec 0c             	sub    $0xc,%esp
80106a62:	ff 75 f0             	pushl  -0x10(%ebp)
80106a65:	e8 c8 ad ff ff       	call   80101832 <iupdate>
80106a6a:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106a6d:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106a72:	75 6a                	jne    80106ade <create+0x195>
    dp->nlink++;  // for ".."
80106a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a77:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106a7b:	83 c0 01             	add    $0x1,%eax
80106a7e:	89 c2                	mov    %eax,%edx
80106a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a83:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106a87:	83 ec 0c             	sub    $0xc,%esp
80106a8a:	ff 75 f4             	pushl  -0xc(%ebp)
80106a8d:	e8 a0 ad ff ff       	call   80101832 <iupdate>
80106a92:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a98:	8b 40 04             	mov    0x4(%eax),%eax
80106a9b:	83 ec 04             	sub    $0x4,%esp
80106a9e:	50                   	push   %eax
80106a9f:	68 65 98 10 80       	push   $0x80109865
80106aa4:	ff 75 f0             	pushl  -0x10(%ebp)
80106aa7:	e8 82 b8 ff ff       	call   8010232e <dirlink>
80106aac:	83 c4 10             	add    $0x10,%esp
80106aaf:	85 c0                	test   %eax,%eax
80106ab1:	78 1e                	js     80106ad1 <create+0x188>
80106ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab6:	8b 40 04             	mov    0x4(%eax),%eax
80106ab9:	83 ec 04             	sub    $0x4,%esp
80106abc:	50                   	push   %eax
80106abd:	68 67 98 10 80       	push   $0x80109867
80106ac2:	ff 75 f0             	pushl  -0x10(%ebp)
80106ac5:	e8 64 b8 ff ff       	call   8010232e <dirlink>
80106aca:	83 c4 10             	add    $0x10,%esp
80106acd:	85 c0                	test   %eax,%eax
80106acf:	79 0d                	jns    80106ade <create+0x195>
      panic("create dots");
80106ad1:	83 ec 0c             	sub    $0xc,%esp
80106ad4:	68 9a 98 10 80       	push   $0x8010989a
80106ad9:	e8 88 9a ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ae1:	8b 40 04             	mov    0x4(%eax),%eax
80106ae4:	83 ec 04             	sub    $0x4,%esp
80106ae7:	50                   	push   %eax
80106ae8:	8d 45 de             	lea    -0x22(%ebp),%eax
80106aeb:	50                   	push   %eax
80106aec:	ff 75 f4             	pushl  -0xc(%ebp)
80106aef:	e8 3a b8 ff ff       	call   8010232e <dirlink>
80106af4:	83 c4 10             	add    $0x10,%esp
80106af7:	85 c0                	test   %eax,%eax
80106af9:	79 0d                	jns    80106b08 <create+0x1bf>
    panic("create: dirlink");
80106afb:	83 ec 0c             	sub    $0xc,%esp
80106afe:	68 a6 98 10 80       	push   $0x801098a6
80106b03:	e8 5e 9a ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106b08:	83 ec 0c             	sub    $0xc,%esp
80106b0b:	ff 75 f4             	pushl  -0xc(%ebp)
80106b0e:	e8 b9 b1 ff ff       	call   80101ccc <iunlockput>
80106b13:	83 c4 10             	add    $0x10,%esp

  return ip;
80106b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106b19:	c9                   	leave  
80106b1a:	c3                   	ret    

80106b1b <sys_open>:

int
sys_open(void)
{
80106b1b:	55                   	push   %ebp
80106b1c:	89 e5                	mov    %esp,%ebp
80106b1e:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106b21:	83 ec 08             	sub    $0x8,%esp
80106b24:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106b27:	50                   	push   %eax
80106b28:	6a 00                	push   $0x0
80106b2a:	e8 eb f6 ff ff       	call   8010621a <argstr>
80106b2f:	83 c4 10             	add    $0x10,%esp
80106b32:	85 c0                	test   %eax,%eax
80106b34:	78 15                	js     80106b4b <sys_open+0x30>
80106b36:	83 ec 08             	sub    $0x8,%esp
80106b39:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106b3c:	50                   	push   %eax
80106b3d:	6a 01                	push   $0x1
80106b3f:	e8 51 f6 ff ff       	call   80106195 <argint>
80106b44:	83 c4 10             	add    $0x10,%esp
80106b47:	85 c0                	test   %eax,%eax
80106b49:	79 0a                	jns    80106b55 <sys_open+0x3a>
    return -1;
80106b4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b50:	e9 61 01 00 00       	jmp    80106cb6 <sys_open+0x19b>

  begin_op();
80106b55:	e8 95 ca ff ff       	call   801035ef <begin_op>

  if(omode & O_CREATE){
80106b5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b5d:	25 00 02 00 00       	and    $0x200,%eax
80106b62:	85 c0                	test   %eax,%eax
80106b64:	74 2a                	je     80106b90 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106b66:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b69:	6a 00                	push   $0x0
80106b6b:	6a 00                	push   $0x0
80106b6d:	6a 02                	push   $0x2
80106b6f:	50                   	push   %eax
80106b70:	e8 d4 fd ff ff       	call   80106949 <create>
80106b75:	83 c4 10             	add    $0x10,%esp
80106b78:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106b7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b7f:	75 75                	jne    80106bf6 <sys_open+0xdb>
      end_op();
80106b81:	e8 f5 ca ff ff       	call   8010367b <end_op>
      return -1;
80106b86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b8b:	e9 26 01 00 00       	jmp    80106cb6 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106b90:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b93:	83 ec 0c             	sub    $0xc,%esp
80106b96:	50                   	push   %eax
80106b97:	e8 2e ba ff ff       	call   801025ca <namei>
80106b9c:	83 c4 10             	add    $0x10,%esp
80106b9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ba2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ba6:	75 0f                	jne    80106bb7 <sys_open+0x9c>
      end_op();
80106ba8:	e8 ce ca ff ff       	call   8010367b <end_op>
      return -1;
80106bad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bb2:	e9 ff 00 00 00       	jmp    80106cb6 <sys_open+0x19b>
    }
    ilock(ip);
80106bb7:	83 ec 0c             	sub    $0xc,%esp
80106bba:	ff 75 f4             	pushl  -0xc(%ebp)
80106bbd:	e8 4a ae ff ff       	call   80101a0c <ilock>
80106bc2:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106bcc:	66 83 f8 01          	cmp    $0x1,%ax
80106bd0:	75 24                	jne    80106bf6 <sys_open+0xdb>
80106bd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106bd5:	85 c0                	test   %eax,%eax
80106bd7:	74 1d                	je     80106bf6 <sys_open+0xdb>
      iunlockput(ip);
80106bd9:	83 ec 0c             	sub    $0xc,%esp
80106bdc:	ff 75 f4             	pushl  -0xc(%ebp)
80106bdf:	e8 e8 b0 ff ff       	call   80101ccc <iunlockput>
80106be4:	83 c4 10             	add    $0x10,%esp
      end_op();
80106be7:	e8 8f ca ff ff       	call   8010367b <end_op>
      return -1;
80106bec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bf1:	e9 c0 00 00 00       	jmp    80106cb6 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106bf6:	e8 3a a4 ff ff       	call   80101035 <filealloc>
80106bfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106bfe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c02:	74 17                	je     80106c1b <sys_open+0x100>
80106c04:	83 ec 0c             	sub    $0xc,%esp
80106c07:	ff 75 f0             	pushl  -0x10(%ebp)
80106c0a:	e8 37 f7 ff ff       	call   80106346 <fdalloc>
80106c0f:	83 c4 10             	add    $0x10,%esp
80106c12:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106c15:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106c19:	79 2e                	jns    80106c49 <sys_open+0x12e>
    if(f)
80106c1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c1f:	74 0e                	je     80106c2f <sys_open+0x114>
      fileclose(f);
80106c21:	83 ec 0c             	sub    $0xc,%esp
80106c24:	ff 75 f0             	pushl  -0x10(%ebp)
80106c27:	e8 c7 a4 ff ff       	call   801010f3 <fileclose>
80106c2c:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106c2f:	83 ec 0c             	sub    $0xc,%esp
80106c32:	ff 75 f4             	pushl  -0xc(%ebp)
80106c35:	e8 92 b0 ff ff       	call   80101ccc <iunlockput>
80106c3a:	83 c4 10             	add    $0x10,%esp
    end_op();
80106c3d:	e8 39 ca ff ff       	call   8010367b <end_op>
    return -1;
80106c42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c47:	eb 6d                	jmp    80106cb6 <sys_open+0x19b>
  }
  iunlock(ip);
80106c49:	83 ec 0c             	sub    $0xc,%esp
80106c4c:	ff 75 f4             	pushl  -0xc(%ebp)
80106c4f:	e8 16 af ff ff       	call   80101b6a <iunlock>
80106c54:	83 c4 10             	add    $0x10,%esp
  end_op();
80106c57:	e8 1f ca ff ff       	call   8010367b <end_op>

  f->type = FD_INODE;
80106c5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c5f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106c65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c68:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c6b:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c71:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106c78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c7b:	83 e0 01             	and    $0x1,%eax
80106c7e:	85 c0                	test   %eax,%eax
80106c80:	0f 94 c0             	sete   %al
80106c83:	89 c2                	mov    %eax,%edx
80106c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c88:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106c8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c8e:	83 e0 01             	and    $0x1,%eax
80106c91:	85 c0                	test   %eax,%eax
80106c93:	75 0a                	jne    80106c9f <sys_open+0x184>
80106c95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c98:	83 e0 02             	and    $0x2,%eax
80106c9b:	85 c0                	test   %eax,%eax
80106c9d:	74 07                	je     80106ca6 <sys_open+0x18b>
80106c9f:	b8 01 00 00 00       	mov    $0x1,%eax
80106ca4:	eb 05                	jmp    80106cab <sys_open+0x190>
80106ca6:	b8 00 00 00 00       	mov    $0x0,%eax
80106cab:	89 c2                	mov    %eax,%edx
80106cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cb0:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106cb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106cb6:	c9                   	leave  
80106cb7:	c3                   	ret    

80106cb8 <sys_mkdir>:

int
sys_mkdir(void)
{
80106cb8:	55                   	push   %ebp
80106cb9:	89 e5                	mov    %esp,%ebp
80106cbb:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106cbe:	e8 2c c9 ff ff       	call   801035ef <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106cc3:	83 ec 08             	sub    $0x8,%esp
80106cc6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106cc9:	50                   	push   %eax
80106cca:	6a 00                	push   $0x0
80106ccc:	e8 49 f5 ff ff       	call   8010621a <argstr>
80106cd1:	83 c4 10             	add    $0x10,%esp
80106cd4:	85 c0                	test   %eax,%eax
80106cd6:	78 1b                	js     80106cf3 <sys_mkdir+0x3b>
80106cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cdb:	6a 00                	push   $0x0
80106cdd:	6a 00                	push   $0x0
80106cdf:	6a 01                	push   $0x1
80106ce1:	50                   	push   %eax
80106ce2:	e8 62 fc ff ff       	call   80106949 <create>
80106ce7:	83 c4 10             	add    $0x10,%esp
80106cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ced:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cf1:	75 0c                	jne    80106cff <sys_mkdir+0x47>
    end_op();
80106cf3:	e8 83 c9 ff ff       	call   8010367b <end_op>
    return -1;
80106cf8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cfd:	eb 18                	jmp    80106d17 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106cff:	83 ec 0c             	sub    $0xc,%esp
80106d02:	ff 75 f4             	pushl  -0xc(%ebp)
80106d05:	e8 c2 af ff ff       	call   80101ccc <iunlockput>
80106d0a:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d0d:	e8 69 c9 ff ff       	call   8010367b <end_op>
  return 0;
80106d12:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d17:	c9                   	leave  
80106d18:	c3                   	ret    

80106d19 <sys_mknod>:

int
sys_mknod(void)
{
80106d19:	55                   	push   %ebp
80106d1a:	89 e5                	mov    %esp,%ebp
80106d1c:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106d1f:	e8 cb c8 ff ff       	call   801035ef <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106d24:	83 ec 08             	sub    $0x8,%esp
80106d27:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106d2a:	50                   	push   %eax
80106d2b:	6a 00                	push   $0x0
80106d2d:	e8 e8 f4 ff ff       	call   8010621a <argstr>
80106d32:	83 c4 10             	add    $0x10,%esp
80106d35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d3c:	78 4f                	js     80106d8d <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106d3e:	83 ec 08             	sub    $0x8,%esp
80106d41:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106d44:	50                   	push   %eax
80106d45:	6a 01                	push   $0x1
80106d47:	e8 49 f4 ff ff       	call   80106195 <argint>
80106d4c:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106d4f:	85 c0                	test   %eax,%eax
80106d51:	78 3a                	js     80106d8d <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106d53:	83 ec 08             	sub    $0x8,%esp
80106d56:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106d59:	50                   	push   %eax
80106d5a:	6a 02                	push   $0x2
80106d5c:	e8 34 f4 ff ff       	call   80106195 <argint>
80106d61:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106d64:	85 c0                	test   %eax,%eax
80106d66:	78 25                	js     80106d8d <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106d68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d6b:	0f bf c8             	movswl %ax,%ecx
80106d6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d71:	0f bf d0             	movswl %ax,%edx
80106d74:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106d77:	51                   	push   %ecx
80106d78:	52                   	push   %edx
80106d79:	6a 03                	push   $0x3
80106d7b:	50                   	push   %eax
80106d7c:	e8 c8 fb ff ff       	call   80106949 <create>
80106d81:	83 c4 10             	add    $0x10,%esp
80106d84:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d8b:	75 0c                	jne    80106d99 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106d8d:	e8 e9 c8 ff ff       	call   8010367b <end_op>
    return -1;
80106d92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d97:	eb 18                	jmp    80106db1 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106d99:	83 ec 0c             	sub    $0xc,%esp
80106d9c:	ff 75 f0             	pushl  -0x10(%ebp)
80106d9f:	e8 28 af ff ff       	call   80101ccc <iunlockput>
80106da4:	83 c4 10             	add    $0x10,%esp
  end_op();
80106da7:	e8 cf c8 ff ff       	call   8010367b <end_op>
  return 0;
80106dac:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106db1:	c9                   	leave  
80106db2:	c3                   	ret    

80106db3 <sys_chdir>:

int
sys_chdir(void)
{
80106db3:	55                   	push   %ebp
80106db4:	89 e5                	mov    %esp,%ebp
80106db6:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106db9:	e8 31 c8 ff ff       	call   801035ef <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106dbe:	83 ec 08             	sub    $0x8,%esp
80106dc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106dc4:	50                   	push   %eax
80106dc5:	6a 00                	push   $0x0
80106dc7:	e8 4e f4 ff ff       	call   8010621a <argstr>
80106dcc:	83 c4 10             	add    $0x10,%esp
80106dcf:	85 c0                	test   %eax,%eax
80106dd1:	78 18                	js     80106deb <sys_chdir+0x38>
80106dd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dd6:	83 ec 0c             	sub    $0xc,%esp
80106dd9:	50                   	push   %eax
80106dda:	e8 eb b7 ff ff       	call   801025ca <namei>
80106ddf:	83 c4 10             	add    $0x10,%esp
80106de2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106de5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106de9:	75 0c                	jne    80106df7 <sys_chdir+0x44>
    end_op();
80106deb:	e8 8b c8 ff ff       	call   8010367b <end_op>
    return -1;
80106df0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106df5:	eb 6e                	jmp    80106e65 <sys_chdir+0xb2>
  }
  ilock(ip);
80106df7:	83 ec 0c             	sub    $0xc,%esp
80106dfa:	ff 75 f4             	pushl  -0xc(%ebp)
80106dfd:	e8 0a ac ff ff       	call   80101a0c <ilock>
80106e02:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e08:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106e0c:	66 83 f8 01          	cmp    $0x1,%ax
80106e10:	74 1a                	je     80106e2c <sys_chdir+0x79>
    iunlockput(ip);
80106e12:	83 ec 0c             	sub    $0xc,%esp
80106e15:	ff 75 f4             	pushl  -0xc(%ebp)
80106e18:	e8 af ae ff ff       	call   80101ccc <iunlockput>
80106e1d:	83 c4 10             	add    $0x10,%esp
    end_op();
80106e20:	e8 56 c8 ff ff       	call   8010367b <end_op>
    return -1;
80106e25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e2a:	eb 39                	jmp    80106e65 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106e2c:	83 ec 0c             	sub    $0xc,%esp
80106e2f:	ff 75 f4             	pushl  -0xc(%ebp)
80106e32:	e8 33 ad ff ff       	call   80101b6a <iunlock>
80106e37:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106e3a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e40:	8b 40 68             	mov    0x68(%eax),%eax
80106e43:	83 ec 0c             	sub    $0xc,%esp
80106e46:	50                   	push   %eax
80106e47:	e8 90 ad ff ff       	call   80101bdc <iput>
80106e4c:	83 c4 10             	add    $0x10,%esp
  end_op();
80106e4f:	e8 27 c8 ff ff       	call   8010367b <end_op>
  proc->cwd = ip;
80106e54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106e5d:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106e60:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e65:	c9                   	leave  
80106e66:	c3                   	ret    

80106e67 <sys_exec>:

int
sys_exec(void)
{
80106e67:	55                   	push   %ebp
80106e68:	89 e5                	mov    %esp,%ebp
80106e6a:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106e70:	83 ec 08             	sub    $0x8,%esp
80106e73:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e76:	50                   	push   %eax
80106e77:	6a 00                	push   $0x0
80106e79:	e8 9c f3 ff ff       	call   8010621a <argstr>
80106e7e:	83 c4 10             	add    $0x10,%esp
80106e81:	85 c0                	test   %eax,%eax
80106e83:	78 18                	js     80106e9d <sys_exec+0x36>
80106e85:	83 ec 08             	sub    $0x8,%esp
80106e88:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106e8e:	50                   	push   %eax
80106e8f:	6a 01                	push   $0x1
80106e91:	e8 ff f2 ff ff       	call   80106195 <argint>
80106e96:	83 c4 10             	add    $0x10,%esp
80106e99:	85 c0                	test   %eax,%eax
80106e9b:	79 0a                	jns    80106ea7 <sys_exec+0x40>
    return -1;
80106e9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ea2:	e9 c6 00 00 00       	jmp    80106f6d <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106ea7:	83 ec 04             	sub    $0x4,%esp
80106eaa:	68 80 00 00 00       	push   $0x80
80106eaf:	6a 00                	push   $0x0
80106eb1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106eb7:	50                   	push   %eax
80106eb8:	e8 b3 ef ff ff       	call   80105e70 <memset>
80106ebd:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106ec0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eca:	83 f8 1f             	cmp    $0x1f,%eax
80106ecd:	76 0a                	jbe    80106ed9 <sys_exec+0x72>
      return -1;
80106ecf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ed4:	e9 94 00 00 00       	jmp    80106f6d <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106edc:	c1 e0 02             	shl    $0x2,%eax
80106edf:	89 c2                	mov    %eax,%edx
80106ee1:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106ee7:	01 c2                	add    %eax,%edx
80106ee9:	83 ec 08             	sub    $0x8,%esp
80106eec:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106ef2:	50                   	push   %eax
80106ef3:	52                   	push   %edx
80106ef4:	e8 00 f2 ff ff       	call   801060f9 <fetchint>
80106ef9:	83 c4 10             	add    $0x10,%esp
80106efc:	85 c0                	test   %eax,%eax
80106efe:	79 07                	jns    80106f07 <sys_exec+0xa0>
      return -1;
80106f00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f05:	eb 66                	jmp    80106f6d <sys_exec+0x106>
    if(uarg == 0){
80106f07:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f0d:	85 c0                	test   %eax,%eax
80106f0f:	75 27                	jne    80106f38 <sys_exec+0xd1>
      argv[i] = 0;
80106f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f14:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106f1b:	00 00 00 00 
      break;
80106f1f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f23:	83 ec 08             	sub    $0x8,%esp
80106f26:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106f2c:	52                   	push   %edx
80106f2d:	50                   	push   %eax
80106f2e:	e8 e0 9c ff ff       	call   80100c13 <exec>
80106f33:	83 c4 10             	add    $0x10,%esp
80106f36:	eb 35                	jmp    80106f6d <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106f38:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106f3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f41:	c1 e2 02             	shl    $0x2,%edx
80106f44:	01 c2                	add    %eax,%edx
80106f46:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f4c:	83 ec 08             	sub    $0x8,%esp
80106f4f:	52                   	push   %edx
80106f50:	50                   	push   %eax
80106f51:	e8 dd f1 ff ff       	call   80106133 <fetchstr>
80106f56:	83 c4 10             	add    $0x10,%esp
80106f59:	85 c0                	test   %eax,%eax
80106f5b:	79 07                	jns    80106f64 <sys_exec+0xfd>
      return -1;
80106f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f62:	eb 09                	jmp    80106f6d <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106f64:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106f68:	e9 5a ff ff ff       	jmp    80106ec7 <sys_exec+0x60>
  return exec(path, argv);
}
80106f6d:	c9                   	leave  
80106f6e:	c3                   	ret    

80106f6f <sys_pipe>:

int
sys_pipe(void)
{
80106f6f:	55                   	push   %ebp
80106f70:	89 e5                	mov    %esp,%ebp
80106f72:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106f75:	83 ec 04             	sub    $0x4,%esp
80106f78:	6a 08                	push   $0x8
80106f7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106f7d:	50                   	push   %eax
80106f7e:	6a 00                	push   $0x0
80106f80:	e8 38 f2 ff ff       	call   801061bd <argptr>
80106f85:	83 c4 10             	add    $0x10,%esp
80106f88:	85 c0                	test   %eax,%eax
80106f8a:	79 0a                	jns    80106f96 <sys_pipe+0x27>
    return -1;
80106f8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f91:	e9 af 00 00 00       	jmp    80107045 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106f96:	83 ec 08             	sub    $0x8,%esp
80106f99:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106f9c:	50                   	push   %eax
80106f9d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106fa0:	50                   	push   %eax
80106fa1:	e8 3d d1 ff ff       	call   801040e3 <pipealloc>
80106fa6:	83 c4 10             	add    $0x10,%esp
80106fa9:	85 c0                	test   %eax,%eax
80106fab:	79 0a                	jns    80106fb7 <sys_pipe+0x48>
    return -1;
80106fad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fb2:	e9 8e 00 00 00       	jmp    80107045 <sys_pipe+0xd6>
  fd0 = -1;
80106fb7:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106fbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106fc1:	83 ec 0c             	sub    $0xc,%esp
80106fc4:	50                   	push   %eax
80106fc5:	e8 7c f3 ff ff       	call   80106346 <fdalloc>
80106fca:	83 c4 10             	add    $0x10,%esp
80106fcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106fd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fd4:	78 18                	js     80106fee <sys_pipe+0x7f>
80106fd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106fd9:	83 ec 0c             	sub    $0xc,%esp
80106fdc:	50                   	push   %eax
80106fdd:	e8 64 f3 ff ff       	call   80106346 <fdalloc>
80106fe2:	83 c4 10             	add    $0x10,%esp
80106fe5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106fe8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106fec:	79 3f                	jns    8010702d <sys_pipe+0xbe>
    if(fd0 >= 0)
80106fee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ff2:	78 14                	js     80107008 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106ff4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ffa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ffd:	83 c2 08             	add    $0x8,%edx
80107000:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107007:	00 
    fileclose(rf);
80107008:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010700b:	83 ec 0c             	sub    $0xc,%esp
8010700e:	50                   	push   %eax
8010700f:	e8 df a0 ff ff       	call   801010f3 <fileclose>
80107014:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80107017:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010701a:	83 ec 0c             	sub    $0xc,%esp
8010701d:	50                   	push   %eax
8010701e:	e8 d0 a0 ff ff       	call   801010f3 <fileclose>
80107023:	83 c4 10             	add    $0x10,%esp
    return -1;
80107026:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010702b:	eb 18                	jmp    80107045 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
8010702d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107030:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107033:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80107035:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107038:	8d 50 04             	lea    0x4(%eax),%edx
8010703b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010703e:	89 02                	mov    %eax,(%edx)
  return 0;
80107040:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107045:	c9                   	leave  
80107046:	c3                   	ret    

80107047 <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
80107047:	55                   	push   %ebp
80107048:	89 e5                	mov    %esp,%ebp
8010704a:	83 ec 08             	sub    $0x8,%esp
8010704d:	8b 55 08             	mov    0x8(%ebp),%edx
80107050:	8b 45 0c             	mov    0xc(%ebp),%eax
80107053:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107057:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010705b:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
8010705f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107063:	66 ef                	out    %ax,(%dx)
}
80107065:	90                   	nop
80107066:	c9                   	leave  
80107067:	c3                   	ret    

80107068 <sys_fork>:
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
int
sys_fork(void)
{
80107068:	55                   	push   %ebp
80107069:	89 e5                	mov    %esp,%ebp
8010706b:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010706e:	e8 92 d8 ff ff       	call   80104905 <fork>
}
80107073:	c9                   	leave  
80107074:	c3                   	ret    

80107075 <sys_exit>:

int
sys_exit(void)
{
80107075:	55                   	push   %ebp
80107076:	89 e5                	mov    %esp,%ebp
80107078:	83 ec 08             	sub    $0x8,%esp
  exit();
8010707b:	e8 84 da ff ff       	call   80104b04 <exit>
  return 0;  // not reached
80107080:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107085:	c9                   	leave  
80107086:	c3                   	ret    

80107087 <sys_wait>:

int
sys_wait(void)
{
80107087:	55                   	push   %ebp
80107088:	89 e5                	mov    %esp,%ebp
8010708a:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010708d:	e8 24 dc ff ff       	call   80104cb6 <wait>
}
80107092:	c9                   	leave  
80107093:	c3                   	ret    

80107094 <sys_kill>:

int
sys_kill(void)
{
80107094:	55                   	push   %ebp
80107095:	89 e5                	mov    %esp,%ebp
80107097:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010709a:	83 ec 08             	sub    $0x8,%esp
8010709d:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070a0:	50                   	push   %eax
801070a1:	6a 00                	push   $0x0
801070a3:	e8 ed f0 ff ff       	call   80106195 <argint>
801070a8:	83 c4 10             	add    $0x10,%esp
801070ab:	85 c0                	test   %eax,%eax
801070ad:	79 07                	jns    801070b6 <sys_kill+0x22>
    return -1;
801070af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070b4:	eb 0f                	jmp    801070c5 <sys_kill+0x31>
  return kill(pid);
801070b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b9:	83 ec 0c             	sub    $0xc,%esp
801070bc:	50                   	push   %eax
801070bd:	e8 66 e1 ff ff       	call   80105228 <kill>
801070c2:	83 c4 10             	add    $0x10,%esp
}
801070c5:	c9                   	leave  
801070c6:	c3                   	ret    

801070c7 <sys_getpid>:

int
sys_getpid(void)
{
801070c7:	55                   	push   %ebp
801070c8:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801070ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070d0:	8b 40 10             	mov    0x10(%eax),%eax
}
801070d3:	5d                   	pop    %ebp
801070d4:	c3                   	ret    

801070d5 <sys_getuid>:
#ifdef CS333_P2
int
sys_getuid(void)
{
801070d5:	55                   	push   %ebp
801070d6:	89 e5                	mov    %esp,%ebp
  return proc->uid;
801070d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070de:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
801070e4:	5d                   	pop    %ebp
801070e5:	c3                   	ret    

801070e6 <sys_getgid>:
int
sys_getgid(void)
{
801070e6:	55                   	push   %ebp
801070e7:	89 e5                	mov    %esp,%ebp
  return proc->gid;
801070e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070ef:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
801070f5:	5d                   	pop    %ebp
801070f6:	c3                   	ret    

801070f7 <sys_getppid>:
int
sys_getppid(void)
{
801070f7:	55                   	push   %ebp
801070f8:	89 e5                	mov    %esp,%ebp
  if(!proc->parent)
801070fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107100:	8b 40 14             	mov    0x14(%eax),%eax
80107103:	85 c0                	test   %eax,%eax
80107105:	75 0b                	jne    80107112 <sys_getppid+0x1b>
    return proc->pid;
80107107:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010710d:	8b 40 10             	mov    0x10(%eax),%eax
80107110:	eb 0c                	jmp    8010711e <sys_getppid+0x27>
  return proc->parent->pid;
80107112:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107118:	8b 40 14             	mov    0x14(%eax),%eax
8010711b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010711e:	5d                   	pop    %ebp
8010711f:	c3                   	ret    

80107120 <sys_setuid>:

int 
sys_setuid(void)
{
80107120:	55                   	push   %ebp
80107121:	89 e5                	mov    %esp,%ebp
80107123:	83 ec 18             	sub    $0x18,%esp
  int uid;
  if(argint(0, &uid) < 0)
80107126:	83 ec 08             	sub    $0x8,%esp
80107129:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010712c:	50                   	push   %eax
8010712d:	6a 00                	push   $0x0
8010712f:	e8 61 f0 ff ff       	call   80106195 <argint>
80107134:	83 c4 10             	add    $0x10,%esp
80107137:	85 c0                	test   %eax,%eax
80107139:	79 07                	jns    80107142 <sys_setuid+0x22>
    return -1;
8010713b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107140:	eb 2a                	jmp    8010716c <sys_setuid+0x4c>
  if(uid < 0 || uid > 32767)
80107142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107145:	85 c0                	test   %eax,%eax
80107147:	78 0a                	js     80107153 <sys_setuid+0x33>
80107149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010714c:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107151:	7e 07                	jle    8010715a <sys_setuid+0x3a>
    return 0;
80107153:	b8 00 00 00 00       	mov    $0x0,%eax
80107158:	eb 12                	jmp    8010716c <sys_setuid+0x4c>
  proc->uid = uid;
8010715a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107160:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107163:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  return uid;
80107169:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010716c:	c9                   	leave  
8010716d:	c3                   	ret    

8010716e <sys_setgid>:

int 
sys_setgid(void)
{
8010716e:	55                   	push   %ebp
8010716f:	89 e5                	mov    %esp,%ebp
80107171:	83 ec 18             	sub    $0x18,%esp
  int gid;
  if(argint(0, &gid) < 0)// fetch int 
80107174:	83 ec 08             	sub    $0x8,%esp
80107177:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010717a:	50                   	push   %eax
8010717b:	6a 00                	push   $0x0
8010717d:	e8 13 f0 ff ff       	call   80106195 <argint>
80107182:	83 c4 10             	add    $0x10,%esp
80107185:	85 c0                	test   %eax,%eax
80107187:	79 07                	jns    80107190 <sys_setgid+0x22>
    return -1;
80107189:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010718e:	eb 2a                	jmp    801071ba <sys_setgid+0x4c>
  if(gid < 0 || gid > 32767)// check bound return 0
80107190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107193:	85 c0                	test   %eax,%eax
80107195:	78 0a                	js     801071a1 <sys_setgid+0x33>
80107197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719a:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
8010719f:	7e 07                	jle    801071a8 <sys_setgid+0x3a>
    return 0;
801071a1:	b8 00 00 00 00       	mov    $0x0,%eax
801071a6:	eb 12                	jmp    801071ba <sys_setgid+0x4c>
  proc->gid = gid;
801071a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071b1:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  return gid;
801071b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801071ba:	c9                   	leave  
801071bb:	c3                   	ret    

801071bc <sys_getprocs>:
int sys_getprocs(void)
{
801071bc:	55                   	push   %ebp
801071bd:	89 e5                	mov    %esp,%ebp
801071bf:	83 ec 18             	sub    $0x18,%esp
    int max;
    struct uproc * table;
    if(argint(0, &max) < 0)
801071c2:	83 ec 08             	sub    $0x8,%esp
801071c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071c8:	50                   	push   %eax
801071c9:	6a 00                	push   $0x0
801071cb:	e8 c5 ef ff ff       	call   80106195 <argint>
801071d0:	83 c4 10             	add    $0x10,%esp
801071d3:	85 c0                	test   %eax,%eax
801071d5:	79 07                	jns    801071de <sys_getprocs+0x22>
        return -1;
801071d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071dc:	eb 36                	jmp    80107214 <sys_getprocs+0x58>
    if(argptr(1, (void*)&table, (sizeof(struct uproc) * max)) < 0)//fetch int and uproc
801071de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e1:	6b c0 5c             	imul   $0x5c,%eax,%eax
801071e4:	83 ec 04             	sub    $0x4,%esp
801071e7:	50                   	push   %eax
801071e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801071eb:	50                   	push   %eax
801071ec:	6a 01                	push   $0x1
801071ee:	e8 ca ef ff ff       	call   801061bd <argptr>
801071f3:	83 c4 10             	add    $0x10,%esp
801071f6:	85 c0                	test   %eax,%eax
801071f8:	79 07                	jns    80107201 <sys_getprocs+0x45>
        return -1;
801071fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071ff:	eb 13                	jmp    80107214 <sys_getprocs+0x58>
    return getprocs(max, table);
80107201:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107204:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107207:	83 ec 08             	sub    $0x8,%esp
8010720a:	50                   	push   %eax
8010720b:	52                   	push   %edx
8010720c:	e8 9e e3 ff ff       	call   801055af <getprocs>
80107211:	83 c4 10             	add    $0x10,%esp
}
80107214:	c9                   	leave  
80107215:	c3                   	ret    

80107216 <sys_sbrk>:
#endif
int
sys_sbrk(void)
{
80107216:	55                   	push   %ebp
80107217:	89 e5                	mov    %esp,%ebp
80107219:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010721c:	83 ec 08             	sub    $0x8,%esp
8010721f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107222:	50                   	push   %eax
80107223:	6a 00                	push   $0x0
80107225:	e8 6b ef ff ff       	call   80106195 <argint>
8010722a:	83 c4 10             	add    $0x10,%esp
8010722d:	85 c0                	test   %eax,%eax
8010722f:	79 07                	jns    80107238 <sys_sbrk+0x22>
    return -1;
80107231:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107236:	eb 28                	jmp    80107260 <sys_sbrk+0x4a>
  addr = proc->sz;
80107238:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010723e:	8b 00                	mov    (%eax),%eax
80107240:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107243:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107246:	83 ec 0c             	sub    $0xc,%esp
80107249:	50                   	push   %eax
8010724a:	e8 13 d6 ff ff       	call   80104862 <growproc>
8010724f:	83 c4 10             	add    $0x10,%esp
80107252:	85 c0                	test   %eax,%eax
80107254:	79 07                	jns    8010725d <sys_sbrk+0x47>
    return -1;
80107256:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010725b:	eb 03                	jmp    80107260 <sys_sbrk+0x4a>
  return addr;
8010725d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107260:	c9                   	leave  
80107261:	c3                   	ret    

80107262 <sys_sleep>:

int
sys_sleep(void)
{
80107262:	55                   	push   %ebp
80107263:	89 e5                	mov    %esp,%ebp
80107265:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80107268:	83 ec 08             	sub    $0x8,%esp
8010726b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010726e:	50                   	push   %eax
8010726f:	6a 00                	push   $0x0
80107271:	e8 1f ef ff ff       	call   80106195 <argint>
80107276:	83 c4 10             	add    $0x10,%esp
80107279:	85 c0                	test   %eax,%eax
8010727b:	79 07                	jns    80107284 <sys_sleep+0x22>
    return -1;
8010727d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107282:	eb 44                	jmp    801072c8 <sys_sleep+0x66>
  ticks0 = ticks;
80107284:	a1 e0 66 11 80       	mov    0x801166e0,%eax
80107289:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010728c:	eb 26                	jmp    801072b4 <sys_sleep+0x52>
    if(proc->killed){
8010728e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107294:	8b 40 24             	mov    0x24(%eax),%eax
80107297:	85 c0                	test   %eax,%eax
80107299:	74 07                	je     801072a2 <sys_sleep+0x40>
      return -1;
8010729b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072a0:	eb 26                	jmp    801072c8 <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
801072a2:	83 ec 08             	sub    $0x8,%esp
801072a5:	6a 00                	push   $0x0
801072a7:	68 e0 66 11 80       	push   $0x801166e0
801072ac:	e8 23 de ff ff       	call   801050d4 <sleep>
801072b1:	83 c4 10             	add    $0x10,%esp
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801072b4:	a1 e0 66 11 80       	mov    0x801166e0,%eax
801072b9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801072bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801072bf:	39 d0                	cmp    %edx,%eax
801072c1:	72 cb                	jb     8010728e <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
801072c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072c8:	c9                   	leave  
801072c9:	c3                   	ret    

801072ca <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start. 
int
sys_uptime(void)
{
801072ca:	55                   	push   %ebp
801072cb:	89 e5                	mov    %esp,%ebp
801072cd:	83 ec 10             	sub    $0x10,%esp
  uint xticks;
  
  xticks = ticks;
801072d0:	a1 e0 66 11 80       	mov    0x801166e0,%eax
801072d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
801072d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801072db:	c9                   	leave  
801072dc:	c3                   	ret    

801072dd <sys_halt>:

//Turn of the computer
int
sys_halt(void){
801072dd:	55                   	push   %ebp
801072de:	89 e5                	mov    %esp,%ebp
801072e0:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
801072e3:	83 ec 0c             	sub    $0xc,%esp
801072e6:	68 b6 98 10 80       	push   $0x801098b6
801072eb:	e8 d6 90 ff ff       	call   801003c6 <cprintf>
801072f0:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
801072f3:	83 ec 08             	sub    $0x8,%esp
801072f6:	68 00 20 00 00       	push   $0x2000
801072fb:	68 04 06 00 00       	push   $0x604
80107300:	e8 42 fd ff ff       	call   80107047 <outw>
80107305:	83 c4 10             	add    $0x10,%esp
  return 0;
80107308:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010730d:	c9                   	leave  
8010730e:	c3                   	ret    

8010730f <sys_date>:

#ifdef CS333_P1
int
sys_date(void)
{
8010730f:	55                   	push   %ebp
80107310:	89 e5                	mov    %esp,%ebp
80107312:	83 ec 18             	sub    $0x18,%esp
    struct rtcdate *d;
    if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
80107315:	83 ec 04             	sub    $0x4,%esp
80107318:	6a 18                	push   $0x18
8010731a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010731d:	50                   	push   %eax
8010731e:	6a 00                	push   $0x0
80107320:	e8 98 ee ff ff       	call   801061bd <argptr>
80107325:	83 c4 10             	add    $0x10,%esp
80107328:	85 c0                	test   %eax,%eax
8010732a:	79 07                	jns    80107333 <sys_date+0x24>
        return -1;
8010732c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107331:	eb 14                	jmp    80107347 <sys_date+0x38>
    cmostime(d);
80107333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107336:	83 ec 0c             	sub    $0xc,%esp
80107339:	50                   	push   %eax
8010733a:	e8 2b bf ff ff       	call   8010326a <cmostime>
8010733f:	83 c4 10             	add    $0x10,%esp
    return 0;
80107342:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107347:	c9                   	leave  
80107348:	c3                   	ret    

80107349 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107349:	55                   	push   %ebp
8010734a:	89 e5                	mov    %esp,%ebp
8010734c:	83 ec 08             	sub    $0x8,%esp
8010734f:	8b 55 08             	mov    0x8(%ebp),%edx
80107352:	8b 45 0c             	mov    0xc(%ebp),%eax
80107355:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107359:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010735c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107360:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107364:	ee                   	out    %al,(%dx)
}
80107365:	90                   	nop
80107366:	c9                   	leave  
80107367:	c3                   	ret    

80107368 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107368:	55                   	push   %ebp
80107369:	89 e5                	mov    %esp,%ebp
8010736b:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010736e:	6a 34                	push   $0x34
80107370:	6a 43                	push   $0x43
80107372:	e8 d2 ff ff ff       	call   80107349 <outb>
80107377:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
8010737a:	68 a9 00 00 00       	push   $0xa9
8010737f:	6a 40                	push   $0x40
80107381:	e8 c3 ff ff ff       	call   80107349 <outb>
80107386:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
80107389:	6a 04                	push   $0x4
8010738b:	6a 40                	push   $0x40
8010738d:	e8 b7 ff ff ff       	call   80107349 <outb>
80107392:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107395:	83 ec 0c             	sub    $0xc,%esp
80107398:	6a 00                	push   $0x0
8010739a:	e8 2e cc ff ff       	call   80103fcd <picenable>
8010739f:	83 c4 10             	add    $0x10,%esp
}
801073a2:	90                   	nop
801073a3:	c9                   	leave  
801073a4:	c3                   	ret    

801073a5 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801073a5:	1e                   	push   %ds
  pushl %es
801073a6:	06                   	push   %es
  pushl %fs
801073a7:	0f a0                	push   %fs
  pushl %gs
801073a9:	0f a8                	push   %gs
  pushal
801073ab:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801073ac:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801073b0:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801073b2:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801073b4:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801073b8:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801073ba:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801073bc:	54                   	push   %esp
  call trap
801073bd:	e8 ce 01 00 00       	call   80107590 <trap>
  addl $4, %esp
801073c2:	83 c4 04             	add    $0x4,%esp

801073c5 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801073c5:	61                   	popa   
  popl %gs
801073c6:	0f a9                	pop    %gs
  popl %fs
801073c8:	0f a1                	pop    %fs
  popl %es
801073ca:	07                   	pop    %es
  popl %ds
801073cb:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801073cc:	83 c4 08             	add    $0x8,%esp
  iret
801073cf:	cf                   	iret   

801073d0 <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
801073d0:	55                   	push   %ebp
801073d1:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
801073d3:	8b 45 08             	mov    0x8(%ebp),%eax
801073d6:	f0 ff 00             	lock incl (%eax)
}
801073d9:	90                   	nop
801073da:	5d                   	pop    %ebp
801073db:	c3                   	ret    

801073dc <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801073dc:	55                   	push   %ebp
801073dd:	89 e5                	mov    %esp,%ebp
801073df:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801073e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801073e5:	83 e8 01             	sub    $0x1,%eax
801073e8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801073ec:	8b 45 08             	mov    0x8(%ebp),%eax
801073ef:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801073f3:	8b 45 08             	mov    0x8(%ebp),%eax
801073f6:	c1 e8 10             	shr    $0x10,%eax
801073f9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801073fd:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107400:	0f 01 18             	lidtl  (%eax)
}
80107403:	90                   	nop
80107404:	c9                   	leave  
80107405:	c3                   	ret    

80107406 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107406:	55                   	push   %ebp
80107407:	89 e5                	mov    %esp,%ebp
80107409:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010740c:	0f 20 d0             	mov    %cr2,%eax
8010740f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107412:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107415:	c9                   	leave  
80107416:	c3                   	ret    

80107417 <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
80107417:	55                   	push   %ebp
80107418:	89 e5                	mov    %esp,%ebp
8010741a:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
8010741d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80107424:	e9 c3 00 00 00       	jmp    801074ec <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107429:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010742c:	8b 04 85 b8 c0 10 80 	mov    -0x7fef3f48(,%eax,4),%eax
80107433:	89 c2                	mov    %eax,%edx
80107435:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107438:	66 89 14 c5 e0 5e 11 	mov    %dx,-0x7feea120(,%eax,8)
8010743f:	80 
80107440:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107443:	66 c7 04 c5 e2 5e 11 	movw   $0x8,-0x7feea11e(,%eax,8)
8010744a:	80 08 00 
8010744d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107450:	0f b6 14 c5 e4 5e 11 	movzbl -0x7feea11c(,%eax,8),%edx
80107457:	80 
80107458:	83 e2 e0             	and    $0xffffffe0,%edx
8010745b:	88 14 c5 e4 5e 11 80 	mov    %dl,-0x7feea11c(,%eax,8)
80107462:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107465:	0f b6 14 c5 e4 5e 11 	movzbl -0x7feea11c(,%eax,8),%edx
8010746c:	80 
8010746d:	83 e2 1f             	and    $0x1f,%edx
80107470:	88 14 c5 e4 5e 11 80 	mov    %dl,-0x7feea11c(,%eax,8)
80107477:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010747a:	0f b6 14 c5 e5 5e 11 	movzbl -0x7feea11b(,%eax,8),%edx
80107481:	80 
80107482:	83 e2 f0             	and    $0xfffffff0,%edx
80107485:	83 ca 0e             	or     $0xe,%edx
80107488:	88 14 c5 e5 5e 11 80 	mov    %dl,-0x7feea11b(,%eax,8)
8010748f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107492:	0f b6 14 c5 e5 5e 11 	movzbl -0x7feea11b(,%eax,8),%edx
80107499:	80 
8010749a:	83 e2 ef             	and    $0xffffffef,%edx
8010749d:	88 14 c5 e5 5e 11 80 	mov    %dl,-0x7feea11b(,%eax,8)
801074a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801074a7:	0f b6 14 c5 e5 5e 11 	movzbl -0x7feea11b(,%eax,8),%edx
801074ae:	80 
801074af:	83 e2 9f             	and    $0xffffff9f,%edx
801074b2:	88 14 c5 e5 5e 11 80 	mov    %dl,-0x7feea11b(,%eax,8)
801074b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801074bc:	0f b6 14 c5 e5 5e 11 	movzbl -0x7feea11b(,%eax,8),%edx
801074c3:	80 
801074c4:	83 ca 80             	or     $0xffffff80,%edx
801074c7:	88 14 c5 e5 5e 11 80 	mov    %dl,-0x7feea11b(,%eax,8)
801074ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801074d1:	8b 04 85 b8 c0 10 80 	mov    -0x7fef3f48(,%eax,4),%eax
801074d8:	c1 e8 10             	shr    $0x10,%eax
801074db:	89 c2                	mov    %eax,%edx
801074dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801074e0:	66 89 14 c5 e6 5e 11 	mov    %dx,-0x7feea11a(,%eax,8)
801074e7:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801074e8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801074ec:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
801074f3:	0f 8e 30 ff ff ff    	jle    80107429 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801074f9:	a1 b8 c1 10 80       	mov    0x8010c1b8,%eax
801074fe:	66 a3 e0 60 11 80    	mov    %ax,0x801160e0
80107504:	66 c7 05 e2 60 11 80 	movw   $0x8,0x801160e2
8010750b:	08 00 
8010750d:	0f b6 05 e4 60 11 80 	movzbl 0x801160e4,%eax
80107514:	83 e0 e0             	and    $0xffffffe0,%eax
80107517:	a2 e4 60 11 80       	mov    %al,0x801160e4
8010751c:	0f b6 05 e4 60 11 80 	movzbl 0x801160e4,%eax
80107523:	83 e0 1f             	and    $0x1f,%eax
80107526:	a2 e4 60 11 80       	mov    %al,0x801160e4
8010752b:	0f b6 05 e5 60 11 80 	movzbl 0x801160e5,%eax
80107532:	83 c8 0f             	or     $0xf,%eax
80107535:	a2 e5 60 11 80       	mov    %al,0x801160e5
8010753a:	0f b6 05 e5 60 11 80 	movzbl 0x801160e5,%eax
80107541:	83 e0 ef             	and    $0xffffffef,%eax
80107544:	a2 e5 60 11 80       	mov    %al,0x801160e5
80107549:	0f b6 05 e5 60 11 80 	movzbl 0x801160e5,%eax
80107550:	83 c8 60             	or     $0x60,%eax
80107553:	a2 e5 60 11 80       	mov    %al,0x801160e5
80107558:	0f b6 05 e5 60 11 80 	movzbl 0x801160e5,%eax
8010755f:	83 c8 80             	or     $0xffffff80,%eax
80107562:	a2 e5 60 11 80       	mov    %al,0x801160e5
80107567:	a1 b8 c1 10 80       	mov    0x8010c1b8,%eax
8010756c:	c1 e8 10             	shr    $0x10,%eax
8010756f:	66 a3 e6 60 11 80    	mov    %ax,0x801160e6
  
}
80107575:	90                   	nop
80107576:	c9                   	leave  
80107577:	c3                   	ret    

80107578 <idtinit>:

void
idtinit(void)
{
80107578:	55                   	push   %ebp
80107579:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010757b:	68 00 08 00 00       	push   $0x800
80107580:	68 e0 5e 11 80       	push   $0x80115ee0
80107585:	e8 52 fe ff ff       	call   801073dc <lidt>
8010758a:	83 c4 08             	add    $0x8,%esp
}
8010758d:	90                   	nop
8010758e:	c9                   	leave  
8010758f:	c3                   	ret    

80107590 <trap>:

void
trap(struct trapframe *tf)
{
80107590:	55                   	push   %ebp
80107591:	89 e5                	mov    %esp,%ebp
80107593:	57                   	push   %edi
80107594:	56                   	push   %esi
80107595:	53                   	push   %ebx
80107596:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80107599:	8b 45 08             	mov    0x8(%ebp),%eax
8010759c:	8b 40 30             	mov    0x30(%eax),%eax
8010759f:	83 f8 40             	cmp    $0x40,%eax
801075a2:	75 3e                	jne    801075e2 <trap+0x52>
    if(proc->killed)
801075a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075aa:	8b 40 24             	mov    0x24(%eax),%eax
801075ad:	85 c0                	test   %eax,%eax
801075af:	74 05                	je     801075b6 <trap+0x26>
      exit();
801075b1:	e8 4e d5 ff ff       	call   80104b04 <exit>
    proc->tf = tf;
801075b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075bc:	8b 55 08             	mov    0x8(%ebp),%edx
801075bf:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801075c2:	e8 84 ec ff ff       	call   8010624b <syscall>
    if(proc->killed)
801075c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075cd:	8b 40 24             	mov    0x24(%eax),%eax
801075d0:	85 c0                	test   %eax,%eax
801075d2:	0f 84 21 02 00 00    	je     801077f9 <trap+0x269>
      exit();
801075d8:	e8 27 d5 ff ff       	call   80104b04 <exit>
    return;
801075dd:	e9 17 02 00 00       	jmp    801077f9 <trap+0x269>
  }

  switch(tf->trapno){
801075e2:	8b 45 08             	mov    0x8(%ebp),%eax
801075e5:	8b 40 30             	mov    0x30(%eax),%eax
801075e8:	83 e8 20             	sub    $0x20,%eax
801075eb:	83 f8 1f             	cmp    $0x1f,%eax
801075ee:	0f 87 a3 00 00 00    	ja     80107697 <trap+0x107>
801075f4:	8b 04 85 6c 99 10 80 	mov    -0x7fef6694(,%eax,4),%eax
801075fb:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
801075fd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107603:	0f b6 00             	movzbl (%eax),%eax
80107606:	84 c0                	test   %al,%al
80107608:	75 20                	jne    8010762a <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
8010760a:	83 ec 0c             	sub    $0xc,%esp
8010760d:	68 e0 66 11 80       	push   $0x801166e0
80107612:	e8 b9 fd ff ff       	call   801073d0 <atom_inc>
80107617:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
8010761a:	83 ec 0c             	sub    $0xc,%esp
8010761d:	68 e0 66 11 80       	push   $0x801166e0
80107622:	e8 ca db ff ff       	call   801051f1 <wakeup>
80107627:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010762a:	e8 98 ba ff ff       	call   801030c7 <lapiceoi>
    break;
8010762f:	e9 1c 01 00 00       	jmp    80107750 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107634:	e8 a1 b2 ff ff       	call   801028da <ideintr>
    lapiceoi();
80107639:	e8 89 ba ff ff       	call   801030c7 <lapiceoi>
    break;
8010763e:	e9 0d 01 00 00       	jmp    80107750 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107643:	e8 81 b8 ff ff       	call   80102ec9 <kbdintr>
    lapiceoi();
80107648:	e8 7a ba ff ff       	call   801030c7 <lapiceoi>
    break;
8010764d:	e9 fe 00 00 00       	jmp    80107750 <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107652:	e8 83 03 00 00       	call   801079da <uartintr>
    lapiceoi();
80107657:	e8 6b ba ff ff       	call   801030c7 <lapiceoi>
    break;
8010765c:	e9 ef 00 00 00       	jmp    80107750 <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107661:	8b 45 08             	mov    0x8(%ebp),%eax
80107664:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107667:	8b 45 08             	mov    0x8(%ebp),%eax
8010766a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010766e:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107671:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107677:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010767a:	0f b6 c0             	movzbl %al,%eax
8010767d:	51                   	push   %ecx
8010767e:	52                   	push   %edx
8010767f:	50                   	push   %eax
80107680:	68 cc 98 10 80       	push   $0x801098cc
80107685:	e8 3c 8d ff ff       	call   801003c6 <cprintf>
8010768a:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010768d:	e8 35 ba ff ff       	call   801030c7 <lapiceoi>
    break;
80107692:	e9 b9 00 00 00       	jmp    80107750 <trap+0x1c0>
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107697:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010769d:	85 c0                	test   %eax,%eax
8010769f:	74 11                	je     801076b2 <trap+0x122>
801076a1:	8b 45 08             	mov    0x8(%ebp),%eax
801076a4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801076a8:	0f b7 c0             	movzwl %ax,%eax
801076ab:	83 e0 03             	and    $0x3,%eax
801076ae:	85 c0                	test   %eax,%eax
801076b0:	75 40                	jne    801076f2 <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801076b2:	e8 4f fd ff ff       	call   80107406 <rcr2>
801076b7:	89 c3                	mov    %eax,%ebx
801076b9:	8b 45 08             	mov    0x8(%ebp),%eax
801076bc:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801076bf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801076c5:	0f b6 00             	movzbl (%eax),%eax
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801076c8:	0f b6 d0             	movzbl %al,%edx
801076cb:	8b 45 08             	mov    0x8(%ebp),%eax
801076ce:	8b 40 30             	mov    0x30(%eax),%eax
801076d1:	83 ec 0c             	sub    $0xc,%esp
801076d4:	53                   	push   %ebx
801076d5:	51                   	push   %ecx
801076d6:	52                   	push   %edx
801076d7:	50                   	push   %eax
801076d8:	68 f0 98 10 80       	push   $0x801098f0
801076dd:	e8 e4 8c ff ff       	call   801003c6 <cprintf>
801076e2:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801076e5:	83 ec 0c             	sub    $0xc,%esp
801076e8:	68 22 99 10 80       	push   $0x80109922
801076ed:	e8 74 8e ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801076f2:	e8 0f fd ff ff       	call   80107406 <rcr2>
801076f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801076fa:	8b 45 08             	mov    0x8(%ebp),%eax
801076fd:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107700:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107706:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107709:	0f b6 d8             	movzbl %al,%ebx
8010770c:	8b 45 08             	mov    0x8(%ebp),%eax
8010770f:	8b 48 34             	mov    0x34(%eax),%ecx
80107712:	8b 45 08             	mov    0x8(%ebp),%eax
80107715:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107718:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010771e:	8d 78 6c             	lea    0x6c(%eax),%edi
80107721:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107727:	8b 40 10             	mov    0x10(%eax),%eax
8010772a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010772d:	56                   	push   %esi
8010772e:	53                   	push   %ebx
8010772f:	51                   	push   %ecx
80107730:	52                   	push   %edx
80107731:	57                   	push   %edi
80107732:	50                   	push   %eax
80107733:	68 28 99 10 80       	push   $0x80109928
80107738:	e8 89 8c ff ff       	call   801003c6 <cprintf>
8010773d:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80107740:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107746:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010774d:	eb 01                	jmp    80107750 <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010774f:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107750:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107756:	85 c0                	test   %eax,%eax
80107758:	74 24                	je     8010777e <trap+0x1ee>
8010775a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107760:	8b 40 24             	mov    0x24(%eax),%eax
80107763:	85 c0                	test   %eax,%eax
80107765:	74 17                	je     8010777e <trap+0x1ee>
80107767:	8b 45 08             	mov    0x8(%ebp),%eax
8010776a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010776e:	0f b7 c0             	movzwl %ax,%eax
80107771:	83 e0 03             	and    $0x3,%eax
80107774:	83 f8 03             	cmp    $0x3,%eax
80107777:	75 05                	jne    8010777e <trap+0x1ee>
    exit();
80107779:	e8 86 d3 ff ff       	call   80104b04 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
8010777e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107784:	85 c0                	test   %eax,%eax
80107786:	74 41                	je     801077c9 <trap+0x239>
80107788:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010778e:	8b 40 0c             	mov    0xc(%eax),%eax
80107791:	83 f8 04             	cmp    $0x4,%eax
80107794:	75 33                	jne    801077c9 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80107796:	8b 45 08             	mov    0x8(%ebp),%eax
80107799:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
8010779c:	83 f8 20             	cmp    $0x20,%eax
8010779f:	75 28                	jne    801077c9 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
801077a1:	8b 0d e0 66 11 80    	mov    0x801166e0,%ecx
801077a7:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801077ac:	89 c8                	mov    %ecx,%eax
801077ae:	f7 e2                	mul    %edx
801077b0:	c1 ea 03             	shr    $0x3,%edx
801077b3:	89 d0                	mov    %edx,%eax
801077b5:	c1 e0 02             	shl    $0x2,%eax
801077b8:	01 d0                	add    %edx,%eax
801077ba:	01 c0                	add    %eax,%eax
801077bc:	29 c1                	sub    %eax,%ecx
801077be:	89 ca                	mov    %ecx,%edx
801077c0:	85 d2                	test   %edx,%edx
801077c2:	75 05                	jne    801077c9 <trap+0x239>
    yield();
801077c4:	e8 77 d8 ff ff       	call   80105040 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801077c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077cf:	85 c0                	test   %eax,%eax
801077d1:	74 27                	je     801077fa <trap+0x26a>
801077d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077d9:	8b 40 24             	mov    0x24(%eax),%eax
801077dc:	85 c0                	test   %eax,%eax
801077de:	74 1a                	je     801077fa <trap+0x26a>
801077e0:	8b 45 08             	mov    0x8(%ebp),%eax
801077e3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801077e7:	0f b7 c0             	movzwl %ax,%eax
801077ea:	83 e0 03             	and    $0x3,%eax
801077ed:	83 f8 03             	cmp    $0x3,%eax
801077f0:	75 08                	jne    801077fa <trap+0x26a>
    exit();
801077f2:	e8 0d d3 ff ff       	call   80104b04 <exit>
801077f7:	eb 01                	jmp    801077fa <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801077f9:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801077fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801077fd:	5b                   	pop    %ebx
801077fe:	5e                   	pop    %esi
801077ff:	5f                   	pop    %edi
80107800:	5d                   	pop    %ebp
80107801:	c3                   	ret    

80107802 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80107802:	55                   	push   %ebp
80107803:	89 e5                	mov    %esp,%ebp
80107805:	83 ec 14             	sub    $0x14,%esp
80107808:	8b 45 08             	mov    0x8(%ebp),%eax
8010780b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010780f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107813:	89 c2                	mov    %eax,%edx
80107815:	ec                   	in     (%dx),%al
80107816:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107819:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010781d:	c9                   	leave  
8010781e:	c3                   	ret    

8010781f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010781f:	55                   	push   %ebp
80107820:	89 e5                	mov    %esp,%ebp
80107822:	83 ec 08             	sub    $0x8,%esp
80107825:	8b 55 08             	mov    0x8(%ebp),%edx
80107828:	8b 45 0c             	mov    0xc(%ebp),%eax
8010782b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010782f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107832:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107836:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010783a:	ee                   	out    %al,(%dx)
}
8010783b:	90                   	nop
8010783c:	c9                   	leave  
8010783d:	c3                   	ret    

8010783e <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010783e:	55                   	push   %ebp
8010783f:	89 e5                	mov    %esp,%ebp
80107841:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107844:	6a 00                	push   $0x0
80107846:	68 fa 03 00 00       	push   $0x3fa
8010784b:	e8 cf ff ff ff       	call   8010781f <outb>
80107850:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107853:	68 80 00 00 00       	push   $0x80
80107858:	68 fb 03 00 00       	push   $0x3fb
8010785d:	e8 bd ff ff ff       	call   8010781f <outb>
80107862:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107865:	6a 0c                	push   $0xc
80107867:	68 f8 03 00 00       	push   $0x3f8
8010786c:	e8 ae ff ff ff       	call   8010781f <outb>
80107871:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107874:	6a 00                	push   $0x0
80107876:	68 f9 03 00 00       	push   $0x3f9
8010787b:	e8 9f ff ff ff       	call   8010781f <outb>
80107880:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107883:	6a 03                	push   $0x3
80107885:	68 fb 03 00 00       	push   $0x3fb
8010788a:	e8 90 ff ff ff       	call   8010781f <outb>
8010788f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107892:	6a 00                	push   $0x0
80107894:	68 fc 03 00 00       	push   $0x3fc
80107899:	e8 81 ff ff ff       	call   8010781f <outb>
8010789e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801078a1:	6a 01                	push   $0x1
801078a3:	68 f9 03 00 00       	push   $0x3f9
801078a8:	e8 72 ff ff ff       	call   8010781f <outb>
801078ad:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801078b0:	68 fd 03 00 00       	push   $0x3fd
801078b5:	e8 48 ff ff ff       	call   80107802 <inb>
801078ba:	83 c4 04             	add    $0x4,%esp
801078bd:	3c ff                	cmp    $0xff,%al
801078bf:	74 6e                	je     8010792f <uartinit+0xf1>
    return;
  uart = 1;
801078c1:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
801078c8:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801078cb:	68 fa 03 00 00       	push   $0x3fa
801078d0:	e8 2d ff ff ff       	call   80107802 <inb>
801078d5:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801078d8:	68 f8 03 00 00       	push   $0x3f8
801078dd:	e8 20 ff ff ff       	call   80107802 <inb>
801078e2:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
801078e5:	83 ec 0c             	sub    $0xc,%esp
801078e8:	6a 04                	push   $0x4
801078ea:	e8 de c6 ff ff       	call   80103fcd <picenable>
801078ef:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801078f2:	83 ec 08             	sub    $0x8,%esp
801078f5:	6a 00                	push   $0x0
801078f7:	6a 04                	push   $0x4
801078f9:	e8 7e b2 ff ff       	call   80102b7c <ioapicenable>
801078fe:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107901:	c7 45 f4 ec 99 10 80 	movl   $0x801099ec,-0xc(%ebp)
80107908:	eb 19                	jmp    80107923 <uartinit+0xe5>
    uartputc(*p);
8010790a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790d:	0f b6 00             	movzbl (%eax),%eax
80107910:	0f be c0             	movsbl %al,%eax
80107913:	83 ec 0c             	sub    $0xc,%esp
80107916:	50                   	push   %eax
80107917:	e8 16 00 00 00       	call   80107932 <uartputc>
8010791c:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010791f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107926:	0f b6 00             	movzbl (%eax),%eax
80107929:	84 c0                	test   %al,%al
8010792b:	75 dd                	jne    8010790a <uartinit+0xcc>
8010792d:	eb 01                	jmp    80107930 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
8010792f:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107930:	c9                   	leave  
80107931:	c3                   	ret    

80107932 <uartputc>:

void
uartputc(int c)
{
80107932:	55                   	push   %ebp
80107933:	89 e5                	mov    %esp,%ebp
80107935:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107938:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
8010793d:	85 c0                	test   %eax,%eax
8010793f:	74 53                	je     80107994 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107948:	eb 11                	jmp    8010795b <uartputc+0x29>
    microdelay(10);
8010794a:	83 ec 0c             	sub    $0xc,%esp
8010794d:	6a 0a                	push   $0xa
8010794f:	e8 8e b7 ff ff       	call   801030e2 <microdelay>
80107954:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107957:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010795b:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010795f:	7f 1a                	jg     8010797b <uartputc+0x49>
80107961:	83 ec 0c             	sub    $0xc,%esp
80107964:	68 fd 03 00 00       	push   $0x3fd
80107969:	e8 94 fe ff ff       	call   80107802 <inb>
8010796e:	83 c4 10             	add    $0x10,%esp
80107971:	0f b6 c0             	movzbl %al,%eax
80107974:	83 e0 20             	and    $0x20,%eax
80107977:	85 c0                	test   %eax,%eax
80107979:	74 cf                	je     8010794a <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
8010797b:	8b 45 08             	mov    0x8(%ebp),%eax
8010797e:	0f b6 c0             	movzbl %al,%eax
80107981:	83 ec 08             	sub    $0x8,%esp
80107984:	50                   	push   %eax
80107985:	68 f8 03 00 00       	push   $0x3f8
8010798a:	e8 90 fe ff ff       	call   8010781f <outb>
8010798f:	83 c4 10             	add    $0x10,%esp
80107992:	eb 01                	jmp    80107995 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107994:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107995:	c9                   	leave  
80107996:	c3                   	ret    

80107997 <uartgetc>:

static int
uartgetc(void)
{
80107997:	55                   	push   %ebp
80107998:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010799a:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
8010799f:	85 c0                	test   %eax,%eax
801079a1:	75 07                	jne    801079aa <uartgetc+0x13>
    return -1;
801079a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079a8:	eb 2e                	jmp    801079d8 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801079aa:	68 fd 03 00 00       	push   $0x3fd
801079af:	e8 4e fe ff ff       	call   80107802 <inb>
801079b4:	83 c4 04             	add    $0x4,%esp
801079b7:	0f b6 c0             	movzbl %al,%eax
801079ba:	83 e0 01             	and    $0x1,%eax
801079bd:	85 c0                	test   %eax,%eax
801079bf:	75 07                	jne    801079c8 <uartgetc+0x31>
    return -1;
801079c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079c6:	eb 10                	jmp    801079d8 <uartgetc+0x41>
  return inb(COM1+0);
801079c8:	68 f8 03 00 00       	push   $0x3f8
801079cd:	e8 30 fe ff ff       	call   80107802 <inb>
801079d2:	83 c4 04             	add    $0x4,%esp
801079d5:	0f b6 c0             	movzbl %al,%eax
}
801079d8:	c9                   	leave  
801079d9:	c3                   	ret    

801079da <uartintr>:

void
uartintr(void)
{
801079da:	55                   	push   %ebp
801079db:	89 e5                	mov    %esp,%ebp
801079dd:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801079e0:	83 ec 0c             	sub    $0xc,%esp
801079e3:	68 97 79 10 80       	push   $0x80107997
801079e8:	e8 0c 8e ff ff       	call   801007f9 <consoleintr>
801079ed:	83 c4 10             	add    $0x10,%esp
}
801079f0:	90                   	nop
801079f1:	c9                   	leave  
801079f2:	c3                   	ret    

801079f3 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801079f3:	6a 00                	push   $0x0
  pushl $0
801079f5:	6a 00                	push   $0x0
  jmp alltraps
801079f7:	e9 a9 f9 ff ff       	jmp    801073a5 <alltraps>

801079fc <vector1>:
.globl vector1
vector1:
  pushl $0
801079fc:	6a 00                	push   $0x0
  pushl $1
801079fe:	6a 01                	push   $0x1
  jmp alltraps
80107a00:	e9 a0 f9 ff ff       	jmp    801073a5 <alltraps>

80107a05 <vector2>:
.globl vector2
vector2:
  pushl $0
80107a05:	6a 00                	push   $0x0
  pushl $2
80107a07:	6a 02                	push   $0x2
  jmp alltraps
80107a09:	e9 97 f9 ff ff       	jmp    801073a5 <alltraps>

80107a0e <vector3>:
.globl vector3
vector3:
  pushl $0
80107a0e:	6a 00                	push   $0x0
  pushl $3
80107a10:	6a 03                	push   $0x3
  jmp alltraps
80107a12:	e9 8e f9 ff ff       	jmp    801073a5 <alltraps>

80107a17 <vector4>:
.globl vector4
vector4:
  pushl $0
80107a17:	6a 00                	push   $0x0
  pushl $4
80107a19:	6a 04                	push   $0x4
  jmp alltraps
80107a1b:	e9 85 f9 ff ff       	jmp    801073a5 <alltraps>

80107a20 <vector5>:
.globl vector5
vector5:
  pushl $0
80107a20:	6a 00                	push   $0x0
  pushl $5
80107a22:	6a 05                	push   $0x5
  jmp alltraps
80107a24:	e9 7c f9 ff ff       	jmp    801073a5 <alltraps>

80107a29 <vector6>:
.globl vector6
vector6:
  pushl $0
80107a29:	6a 00                	push   $0x0
  pushl $6
80107a2b:	6a 06                	push   $0x6
  jmp alltraps
80107a2d:	e9 73 f9 ff ff       	jmp    801073a5 <alltraps>

80107a32 <vector7>:
.globl vector7
vector7:
  pushl $0
80107a32:	6a 00                	push   $0x0
  pushl $7
80107a34:	6a 07                	push   $0x7
  jmp alltraps
80107a36:	e9 6a f9 ff ff       	jmp    801073a5 <alltraps>

80107a3b <vector8>:
.globl vector8
vector8:
  pushl $8
80107a3b:	6a 08                	push   $0x8
  jmp alltraps
80107a3d:	e9 63 f9 ff ff       	jmp    801073a5 <alltraps>

80107a42 <vector9>:
.globl vector9
vector9:
  pushl $0
80107a42:	6a 00                	push   $0x0
  pushl $9
80107a44:	6a 09                	push   $0x9
  jmp alltraps
80107a46:	e9 5a f9 ff ff       	jmp    801073a5 <alltraps>

80107a4b <vector10>:
.globl vector10
vector10:
  pushl $10
80107a4b:	6a 0a                	push   $0xa
  jmp alltraps
80107a4d:	e9 53 f9 ff ff       	jmp    801073a5 <alltraps>

80107a52 <vector11>:
.globl vector11
vector11:
  pushl $11
80107a52:	6a 0b                	push   $0xb
  jmp alltraps
80107a54:	e9 4c f9 ff ff       	jmp    801073a5 <alltraps>

80107a59 <vector12>:
.globl vector12
vector12:
  pushl $12
80107a59:	6a 0c                	push   $0xc
  jmp alltraps
80107a5b:	e9 45 f9 ff ff       	jmp    801073a5 <alltraps>

80107a60 <vector13>:
.globl vector13
vector13:
  pushl $13
80107a60:	6a 0d                	push   $0xd
  jmp alltraps
80107a62:	e9 3e f9 ff ff       	jmp    801073a5 <alltraps>

80107a67 <vector14>:
.globl vector14
vector14:
  pushl $14
80107a67:	6a 0e                	push   $0xe
  jmp alltraps
80107a69:	e9 37 f9 ff ff       	jmp    801073a5 <alltraps>

80107a6e <vector15>:
.globl vector15
vector15:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $15
80107a70:	6a 0f                	push   $0xf
  jmp alltraps
80107a72:	e9 2e f9 ff ff       	jmp    801073a5 <alltraps>

80107a77 <vector16>:
.globl vector16
vector16:
  pushl $0
80107a77:	6a 00                	push   $0x0
  pushl $16
80107a79:	6a 10                	push   $0x10
  jmp alltraps
80107a7b:	e9 25 f9 ff ff       	jmp    801073a5 <alltraps>

80107a80 <vector17>:
.globl vector17
vector17:
  pushl $17
80107a80:	6a 11                	push   $0x11
  jmp alltraps
80107a82:	e9 1e f9 ff ff       	jmp    801073a5 <alltraps>

80107a87 <vector18>:
.globl vector18
vector18:
  pushl $0
80107a87:	6a 00                	push   $0x0
  pushl $18
80107a89:	6a 12                	push   $0x12
  jmp alltraps
80107a8b:	e9 15 f9 ff ff       	jmp    801073a5 <alltraps>

80107a90 <vector19>:
.globl vector19
vector19:
  pushl $0
80107a90:	6a 00                	push   $0x0
  pushl $19
80107a92:	6a 13                	push   $0x13
  jmp alltraps
80107a94:	e9 0c f9 ff ff       	jmp    801073a5 <alltraps>

80107a99 <vector20>:
.globl vector20
vector20:
  pushl $0
80107a99:	6a 00                	push   $0x0
  pushl $20
80107a9b:	6a 14                	push   $0x14
  jmp alltraps
80107a9d:	e9 03 f9 ff ff       	jmp    801073a5 <alltraps>

80107aa2 <vector21>:
.globl vector21
vector21:
  pushl $0
80107aa2:	6a 00                	push   $0x0
  pushl $21
80107aa4:	6a 15                	push   $0x15
  jmp alltraps
80107aa6:	e9 fa f8 ff ff       	jmp    801073a5 <alltraps>

80107aab <vector22>:
.globl vector22
vector22:
  pushl $0
80107aab:	6a 00                	push   $0x0
  pushl $22
80107aad:	6a 16                	push   $0x16
  jmp alltraps
80107aaf:	e9 f1 f8 ff ff       	jmp    801073a5 <alltraps>

80107ab4 <vector23>:
.globl vector23
vector23:
  pushl $0
80107ab4:	6a 00                	push   $0x0
  pushl $23
80107ab6:	6a 17                	push   $0x17
  jmp alltraps
80107ab8:	e9 e8 f8 ff ff       	jmp    801073a5 <alltraps>

80107abd <vector24>:
.globl vector24
vector24:
  pushl $0
80107abd:	6a 00                	push   $0x0
  pushl $24
80107abf:	6a 18                	push   $0x18
  jmp alltraps
80107ac1:	e9 df f8 ff ff       	jmp    801073a5 <alltraps>

80107ac6 <vector25>:
.globl vector25
vector25:
  pushl $0
80107ac6:	6a 00                	push   $0x0
  pushl $25
80107ac8:	6a 19                	push   $0x19
  jmp alltraps
80107aca:	e9 d6 f8 ff ff       	jmp    801073a5 <alltraps>

80107acf <vector26>:
.globl vector26
vector26:
  pushl $0
80107acf:	6a 00                	push   $0x0
  pushl $26
80107ad1:	6a 1a                	push   $0x1a
  jmp alltraps
80107ad3:	e9 cd f8 ff ff       	jmp    801073a5 <alltraps>

80107ad8 <vector27>:
.globl vector27
vector27:
  pushl $0
80107ad8:	6a 00                	push   $0x0
  pushl $27
80107ada:	6a 1b                	push   $0x1b
  jmp alltraps
80107adc:	e9 c4 f8 ff ff       	jmp    801073a5 <alltraps>

80107ae1 <vector28>:
.globl vector28
vector28:
  pushl $0
80107ae1:	6a 00                	push   $0x0
  pushl $28
80107ae3:	6a 1c                	push   $0x1c
  jmp alltraps
80107ae5:	e9 bb f8 ff ff       	jmp    801073a5 <alltraps>

80107aea <vector29>:
.globl vector29
vector29:
  pushl $0
80107aea:	6a 00                	push   $0x0
  pushl $29
80107aec:	6a 1d                	push   $0x1d
  jmp alltraps
80107aee:	e9 b2 f8 ff ff       	jmp    801073a5 <alltraps>

80107af3 <vector30>:
.globl vector30
vector30:
  pushl $0
80107af3:	6a 00                	push   $0x0
  pushl $30
80107af5:	6a 1e                	push   $0x1e
  jmp alltraps
80107af7:	e9 a9 f8 ff ff       	jmp    801073a5 <alltraps>

80107afc <vector31>:
.globl vector31
vector31:
  pushl $0
80107afc:	6a 00                	push   $0x0
  pushl $31
80107afe:	6a 1f                	push   $0x1f
  jmp alltraps
80107b00:	e9 a0 f8 ff ff       	jmp    801073a5 <alltraps>

80107b05 <vector32>:
.globl vector32
vector32:
  pushl $0
80107b05:	6a 00                	push   $0x0
  pushl $32
80107b07:	6a 20                	push   $0x20
  jmp alltraps
80107b09:	e9 97 f8 ff ff       	jmp    801073a5 <alltraps>

80107b0e <vector33>:
.globl vector33
vector33:
  pushl $0
80107b0e:	6a 00                	push   $0x0
  pushl $33
80107b10:	6a 21                	push   $0x21
  jmp alltraps
80107b12:	e9 8e f8 ff ff       	jmp    801073a5 <alltraps>

80107b17 <vector34>:
.globl vector34
vector34:
  pushl $0
80107b17:	6a 00                	push   $0x0
  pushl $34
80107b19:	6a 22                	push   $0x22
  jmp alltraps
80107b1b:	e9 85 f8 ff ff       	jmp    801073a5 <alltraps>

80107b20 <vector35>:
.globl vector35
vector35:
  pushl $0
80107b20:	6a 00                	push   $0x0
  pushl $35
80107b22:	6a 23                	push   $0x23
  jmp alltraps
80107b24:	e9 7c f8 ff ff       	jmp    801073a5 <alltraps>

80107b29 <vector36>:
.globl vector36
vector36:
  pushl $0
80107b29:	6a 00                	push   $0x0
  pushl $36
80107b2b:	6a 24                	push   $0x24
  jmp alltraps
80107b2d:	e9 73 f8 ff ff       	jmp    801073a5 <alltraps>

80107b32 <vector37>:
.globl vector37
vector37:
  pushl $0
80107b32:	6a 00                	push   $0x0
  pushl $37
80107b34:	6a 25                	push   $0x25
  jmp alltraps
80107b36:	e9 6a f8 ff ff       	jmp    801073a5 <alltraps>

80107b3b <vector38>:
.globl vector38
vector38:
  pushl $0
80107b3b:	6a 00                	push   $0x0
  pushl $38
80107b3d:	6a 26                	push   $0x26
  jmp alltraps
80107b3f:	e9 61 f8 ff ff       	jmp    801073a5 <alltraps>

80107b44 <vector39>:
.globl vector39
vector39:
  pushl $0
80107b44:	6a 00                	push   $0x0
  pushl $39
80107b46:	6a 27                	push   $0x27
  jmp alltraps
80107b48:	e9 58 f8 ff ff       	jmp    801073a5 <alltraps>

80107b4d <vector40>:
.globl vector40
vector40:
  pushl $0
80107b4d:	6a 00                	push   $0x0
  pushl $40
80107b4f:	6a 28                	push   $0x28
  jmp alltraps
80107b51:	e9 4f f8 ff ff       	jmp    801073a5 <alltraps>

80107b56 <vector41>:
.globl vector41
vector41:
  pushl $0
80107b56:	6a 00                	push   $0x0
  pushl $41
80107b58:	6a 29                	push   $0x29
  jmp alltraps
80107b5a:	e9 46 f8 ff ff       	jmp    801073a5 <alltraps>

80107b5f <vector42>:
.globl vector42
vector42:
  pushl $0
80107b5f:	6a 00                	push   $0x0
  pushl $42
80107b61:	6a 2a                	push   $0x2a
  jmp alltraps
80107b63:	e9 3d f8 ff ff       	jmp    801073a5 <alltraps>

80107b68 <vector43>:
.globl vector43
vector43:
  pushl $0
80107b68:	6a 00                	push   $0x0
  pushl $43
80107b6a:	6a 2b                	push   $0x2b
  jmp alltraps
80107b6c:	e9 34 f8 ff ff       	jmp    801073a5 <alltraps>

80107b71 <vector44>:
.globl vector44
vector44:
  pushl $0
80107b71:	6a 00                	push   $0x0
  pushl $44
80107b73:	6a 2c                	push   $0x2c
  jmp alltraps
80107b75:	e9 2b f8 ff ff       	jmp    801073a5 <alltraps>

80107b7a <vector45>:
.globl vector45
vector45:
  pushl $0
80107b7a:	6a 00                	push   $0x0
  pushl $45
80107b7c:	6a 2d                	push   $0x2d
  jmp alltraps
80107b7e:	e9 22 f8 ff ff       	jmp    801073a5 <alltraps>

80107b83 <vector46>:
.globl vector46
vector46:
  pushl $0
80107b83:	6a 00                	push   $0x0
  pushl $46
80107b85:	6a 2e                	push   $0x2e
  jmp alltraps
80107b87:	e9 19 f8 ff ff       	jmp    801073a5 <alltraps>

80107b8c <vector47>:
.globl vector47
vector47:
  pushl $0
80107b8c:	6a 00                	push   $0x0
  pushl $47
80107b8e:	6a 2f                	push   $0x2f
  jmp alltraps
80107b90:	e9 10 f8 ff ff       	jmp    801073a5 <alltraps>

80107b95 <vector48>:
.globl vector48
vector48:
  pushl $0
80107b95:	6a 00                	push   $0x0
  pushl $48
80107b97:	6a 30                	push   $0x30
  jmp alltraps
80107b99:	e9 07 f8 ff ff       	jmp    801073a5 <alltraps>

80107b9e <vector49>:
.globl vector49
vector49:
  pushl $0
80107b9e:	6a 00                	push   $0x0
  pushl $49
80107ba0:	6a 31                	push   $0x31
  jmp alltraps
80107ba2:	e9 fe f7 ff ff       	jmp    801073a5 <alltraps>

80107ba7 <vector50>:
.globl vector50
vector50:
  pushl $0
80107ba7:	6a 00                	push   $0x0
  pushl $50
80107ba9:	6a 32                	push   $0x32
  jmp alltraps
80107bab:	e9 f5 f7 ff ff       	jmp    801073a5 <alltraps>

80107bb0 <vector51>:
.globl vector51
vector51:
  pushl $0
80107bb0:	6a 00                	push   $0x0
  pushl $51
80107bb2:	6a 33                	push   $0x33
  jmp alltraps
80107bb4:	e9 ec f7 ff ff       	jmp    801073a5 <alltraps>

80107bb9 <vector52>:
.globl vector52
vector52:
  pushl $0
80107bb9:	6a 00                	push   $0x0
  pushl $52
80107bbb:	6a 34                	push   $0x34
  jmp alltraps
80107bbd:	e9 e3 f7 ff ff       	jmp    801073a5 <alltraps>

80107bc2 <vector53>:
.globl vector53
vector53:
  pushl $0
80107bc2:	6a 00                	push   $0x0
  pushl $53
80107bc4:	6a 35                	push   $0x35
  jmp alltraps
80107bc6:	e9 da f7 ff ff       	jmp    801073a5 <alltraps>

80107bcb <vector54>:
.globl vector54
vector54:
  pushl $0
80107bcb:	6a 00                	push   $0x0
  pushl $54
80107bcd:	6a 36                	push   $0x36
  jmp alltraps
80107bcf:	e9 d1 f7 ff ff       	jmp    801073a5 <alltraps>

80107bd4 <vector55>:
.globl vector55
vector55:
  pushl $0
80107bd4:	6a 00                	push   $0x0
  pushl $55
80107bd6:	6a 37                	push   $0x37
  jmp alltraps
80107bd8:	e9 c8 f7 ff ff       	jmp    801073a5 <alltraps>

80107bdd <vector56>:
.globl vector56
vector56:
  pushl $0
80107bdd:	6a 00                	push   $0x0
  pushl $56
80107bdf:	6a 38                	push   $0x38
  jmp alltraps
80107be1:	e9 bf f7 ff ff       	jmp    801073a5 <alltraps>

80107be6 <vector57>:
.globl vector57
vector57:
  pushl $0
80107be6:	6a 00                	push   $0x0
  pushl $57
80107be8:	6a 39                	push   $0x39
  jmp alltraps
80107bea:	e9 b6 f7 ff ff       	jmp    801073a5 <alltraps>

80107bef <vector58>:
.globl vector58
vector58:
  pushl $0
80107bef:	6a 00                	push   $0x0
  pushl $58
80107bf1:	6a 3a                	push   $0x3a
  jmp alltraps
80107bf3:	e9 ad f7 ff ff       	jmp    801073a5 <alltraps>

80107bf8 <vector59>:
.globl vector59
vector59:
  pushl $0
80107bf8:	6a 00                	push   $0x0
  pushl $59
80107bfa:	6a 3b                	push   $0x3b
  jmp alltraps
80107bfc:	e9 a4 f7 ff ff       	jmp    801073a5 <alltraps>

80107c01 <vector60>:
.globl vector60
vector60:
  pushl $0
80107c01:	6a 00                	push   $0x0
  pushl $60
80107c03:	6a 3c                	push   $0x3c
  jmp alltraps
80107c05:	e9 9b f7 ff ff       	jmp    801073a5 <alltraps>

80107c0a <vector61>:
.globl vector61
vector61:
  pushl $0
80107c0a:	6a 00                	push   $0x0
  pushl $61
80107c0c:	6a 3d                	push   $0x3d
  jmp alltraps
80107c0e:	e9 92 f7 ff ff       	jmp    801073a5 <alltraps>

80107c13 <vector62>:
.globl vector62
vector62:
  pushl $0
80107c13:	6a 00                	push   $0x0
  pushl $62
80107c15:	6a 3e                	push   $0x3e
  jmp alltraps
80107c17:	e9 89 f7 ff ff       	jmp    801073a5 <alltraps>

80107c1c <vector63>:
.globl vector63
vector63:
  pushl $0
80107c1c:	6a 00                	push   $0x0
  pushl $63
80107c1e:	6a 3f                	push   $0x3f
  jmp alltraps
80107c20:	e9 80 f7 ff ff       	jmp    801073a5 <alltraps>

80107c25 <vector64>:
.globl vector64
vector64:
  pushl $0
80107c25:	6a 00                	push   $0x0
  pushl $64
80107c27:	6a 40                	push   $0x40
  jmp alltraps
80107c29:	e9 77 f7 ff ff       	jmp    801073a5 <alltraps>

80107c2e <vector65>:
.globl vector65
vector65:
  pushl $0
80107c2e:	6a 00                	push   $0x0
  pushl $65
80107c30:	6a 41                	push   $0x41
  jmp alltraps
80107c32:	e9 6e f7 ff ff       	jmp    801073a5 <alltraps>

80107c37 <vector66>:
.globl vector66
vector66:
  pushl $0
80107c37:	6a 00                	push   $0x0
  pushl $66
80107c39:	6a 42                	push   $0x42
  jmp alltraps
80107c3b:	e9 65 f7 ff ff       	jmp    801073a5 <alltraps>

80107c40 <vector67>:
.globl vector67
vector67:
  pushl $0
80107c40:	6a 00                	push   $0x0
  pushl $67
80107c42:	6a 43                	push   $0x43
  jmp alltraps
80107c44:	e9 5c f7 ff ff       	jmp    801073a5 <alltraps>

80107c49 <vector68>:
.globl vector68
vector68:
  pushl $0
80107c49:	6a 00                	push   $0x0
  pushl $68
80107c4b:	6a 44                	push   $0x44
  jmp alltraps
80107c4d:	e9 53 f7 ff ff       	jmp    801073a5 <alltraps>

80107c52 <vector69>:
.globl vector69
vector69:
  pushl $0
80107c52:	6a 00                	push   $0x0
  pushl $69
80107c54:	6a 45                	push   $0x45
  jmp alltraps
80107c56:	e9 4a f7 ff ff       	jmp    801073a5 <alltraps>

80107c5b <vector70>:
.globl vector70
vector70:
  pushl $0
80107c5b:	6a 00                	push   $0x0
  pushl $70
80107c5d:	6a 46                	push   $0x46
  jmp alltraps
80107c5f:	e9 41 f7 ff ff       	jmp    801073a5 <alltraps>

80107c64 <vector71>:
.globl vector71
vector71:
  pushl $0
80107c64:	6a 00                	push   $0x0
  pushl $71
80107c66:	6a 47                	push   $0x47
  jmp alltraps
80107c68:	e9 38 f7 ff ff       	jmp    801073a5 <alltraps>

80107c6d <vector72>:
.globl vector72
vector72:
  pushl $0
80107c6d:	6a 00                	push   $0x0
  pushl $72
80107c6f:	6a 48                	push   $0x48
  jmp alltraps
80107c71:	e9 2f f7 ff ff       	jmp    801073a5 <alltraps>

80107c76 <vector73>:
.globl vector73
vector73:
  pushl $0
80107c76:	6a 00                	push   $0x0
  pushl $73
80107c78:	6a 49                	push   $0x49
  jmp alltraps
80107c7a:	e9 26 f7 ff ff       	jmp    801073a5 <alltraps>

80107c7f <vector74>:
.globl vector74
vector74:
  pushl $0
80107c7f:	6a 00                	push   $0x0
  pushl $74
80107c81:	6a 4a                	push   $0x4a
  jmp alltraps
80107c83:	e9 1d f7 ff ff       	jmp    801073a5 <alltraps>

80107c88 <vector75>:
.globl vector75
vector75:
  pushl $0
80107c88:	6a 00                	push   $0x0
  pushl $75
80107c8a:	6a 4b                	push   $0x4b
  jmp alltraps
80107c8c:	e9 14 f7 ff ff       	jmp    801073a5 <alltraps>

80107c91 <vector76>:
.globl vector76
vector76:
  pushl $0
80107c91:	6a 00                	push   $0x0
  pushl $76
80107c93:	6a 4c                	push   $0x4c
  jmp alltraps
80107c95:	e9 0b f7 ff ff       	jmp    801073a5 <alltraps>

80107c9a <vector77>:
.globl vector77
vector77:
  pushl $0
80107c9a:	6a 00                	push   $0x0
  pushl $77
80107c9c:	6a 4d                	push   $0x4d
  jmp alltraps
80107c9e:	e9 02 f7 ff ff       	jmp    801073a5 <alltraps>

80107ca3 <vector78>:
.globl vector78
vector78:
  pushl $0
80107ca3:	6a 00                	push   $0x0
  pushl $78
80107ca5:	6a 4e                	push   $0x4e
  jmp alltraps
80107ca7:	e9 f9 f6 ff ff       	jmp    801073a5 <alltraps>

80107cac <vector79>:
.globl vector79
vector79:
  pushl $0
80107cac:	6a 00                	push   $0x0
  pushl $79
80107cae:	6a 4f                	push   $0x4f
  jmp alltraps
80107cb0:	e9 f0 f6 ff ff       	jmp    801073a5 <alltraps>

80107cb5 <vector80>:
.globl vector80
vector80:
  pushl $0
80107cb5:	6a 00                	push   $0x0
  pushl $80
80107cb7:	6a 50                	push   $0x50
  jmp alltraps
80107cb9:	e9 e7 f6 ff ff       	jmp    801073a5 <alltraps>

80107cbe <vector81>:
.globl vector81
vector81:
  pushl $0
80107cbe:	6a 00                	push   $0x0
  pushl $81
80107cc0:	6a 51                	push   $0x51
  jmp alltraps
80107cc2:	e9 de f6 ff ff       	jmp    801073a5 <alltraps>

80107cc7 <vector82>:
.globl vector82
vector82:
  pushl $0
80107cc7:	6a 00                	push   $0x0
  pushl $82
80107cc9:	6a 52                	push   $0x52
  jmp alltraps
80107ccb:	e9 d5 f6 ff ff       	jmp    801073a5 <alltraps>

80107cd0 <vector83>:
.globl vector83
vector83:
  pushl $0
80107cd0:	6a 00                	push   $0x0
  pushl $83
80107cd2:	6a 53                	push   $0x53
  jmp alltraps
80107cd4:	e9 cc f6 ff ff       	jmp    801073a5 <alltraps>

80107cd9 <vector84>:
.globl vector84
vector84:
  pushl $0
80107cd9:	6a 00                	push   $0x0
  pushl $84
80107cdb:	6a 54                	push   $0x54
  jmp alltraps
80107cdd:	e9 c3 f6 ff ff       	jmp    801073a5 <alltraps>

80107ce2 <vector85>:
.globl vector85
vector85:
  pushl $0
80107ce2:	6a 00                	push   $0x0
  pushl $85
80107ce4:	6a 55                	push   $0x55
  jmp alltraps
80107ce6:	e9 ba f6 ff ff       	jmp    801073a5 <alltraps>

80107ceb <vector86>:
.globl vector86
vector86:
  pushl $0
80107ceb:	6a 00                	push   $0x0
  pushl $86
80107ced:	6a 56                	push   $0x56
  jmp alltraps
80107cef:	e9 b1 f6 ff ff       	jmp    801073a5 <alltraps>

80107cf4 <vector87>:
.globl vector87
vector87:
  pushl $0
80107cf4:	6a 00                	push   $0x0
  pushl $87
80107cf6:	6a 57                	push   $0x57
  jmp alltraps
80107cf8:	e9 a8 f6 ff ff       	jmp    801073a5 <alltraps>

80107cfd <vector88>:
.globl vector88
vector88:
  pushl $0
80107cfd:	6a 00                	push   $0x0
  pushl $88
80107cff:	6a 58                	push   $0x58
  jmp alltraps
80107d01:	e9 9f f6 ff ff       	jmp    801073a5 <alltraps>

80107d06 <vector89>:
.globl vector89
vector89:
  pushl $0
80107d06:	6a 00                	push   $0x0
  pushl $89
80107d08:	6a 59                	push   $0x59
  jmp alltraps
80107d0a:	e9 96 f6 ff ff       	jmp    801073a5 <alltraps>

80107d0f <vector90>:
.globl vector90
vector90:
  pushl $0
80107d0f:	6a 00                	push   $0x0
  pushl $90
80107d11:	6a 5a                	push   $0x5a
  jmp alltraps
80107d13:	e9 8d f6 ff ff       	jmp    801073a5 <alltraps>

80107d18 <vector91>:
.globl vector91
vector91:
  pushl $0
80107d18:	6a 00                	push   $0x0
  pushl $91
80107d1a:	6a 5b                	push   $0x5b
  jmp alltraps
80107d1c:	e9 84 f6 ff ff       	jmp    801073a5 <alltraps>

80107d21 <vector92>:
.globl vector92
vector92:
  pushl $0
80107d21:	6a 00                	push   $0x0
  pushl $92
80107d23:	6a 5c                	push   $0x5c
  jmp alltraps
80107d25:	e9 7b f6 ff ff       	jmp    801073a5 <alltraps>

80107d2a <vector93>:
.globl vector93
vector93:
  pushl $0
80107d2a:	6a 00                	push   $0x0
  pushl $93
80107d2c:	6a 5d                	push   $0x5d
  jmp alltraps
80107d2e:	e9 72 f6 ff ff       	jmp    801073a5 <alltraps>

80107d33 <vector94>:
.globl vector94
vector94:
  pushl $0
80107d33:	6a 00                	push   $0x0
  pushl $94
80107d35:	6a 5e                	push   $0x5e
  jmp alltraps
80107d37:	e9 69 f6 ff ff       	jmp    801073a5 <alltraps>

80107d3c <vector95>:
.globl vector95
vector95:
  pushl $0
80107d3c:	6a 00                	push   $0x0
  pushl $95
80107d3e:	6a 5f                	push   $0x5f
  jmp alltraps
80107d40:	e9 60 f6 ff ff       	jmp    801073a5 <alltraps>

80107d45 <vector96>:
.globl vector96
vector96:
  pushl $0
80107d45:	6a 00                	push   $0x0
  pushl $96
80107d47:	6a 60                	push   $0x60
  jmp alltraps
80107d49:	e9 57 f6 ff ff       	jmp    801073a5 <alltraps>

80107d4e <vector97>:
.globl vector97
vector97:
  pushl $0
80107d4e:	6a 00                	push   $0x0
  pushl $97
80107d50:	6a 61                	push   $0x61
  jmp alltraps
80107d52:	e9 4e f6 ff ff       	jmp    801073a5 <alltraps>

80107d57 <vector98>:
.globl vector98
vector98:
  pushl $0
80107d57:	6a 00                	push   $0x0
  pushl $98
80107d59:	6a 62                	push   $0x62
  jmp alltraps
80107d5b:	e9 45 f6 ff ff       	jmp    801073a5 <alltraps>

80107d60 <vector99>:
.globl vector99
vector99:
  pushl $0
80107d60:	6a 00                	push   $0x0
  pushl $99
80107d62:	6a 63                	push   $0x63
  jmp alltraps
80107d64:	e9 3c f6 ff ff       	jmp    801073a5 <alltraps>

80107d69 <vector100>:
.globl vector100
vector100:
  pushl $0
80107d69:	6a 00                	push   $0x0
  pushl $100
80107d6b:	6a 64                	push   $0x64
  jmp alltraps
80107d6d:	e9 33 f6 ff ff       	jmp    801073a5 <alltraps>

80107d72 <vector101>:
.globl vector101
vector101:
  pushl $0
80107d72:	6a 00                	push   $0x0
  pushl $101
80107d74:	6a 65                	push   $0x65
  jmp alltraps
80107d76:	e9 2a f6 ff ff       	jmp    801073a5 <alltraps>

80107d7b <vector102>:
.globl vector102
vector102:
  pushl $0
80107d7b:	6a 00                	push   $0x0
  pushl $102
80107d7d:	6a 66                	push   $0x66
  jmp alltraps
80107d7f:	e9 21 f6 ff ff       	jmp    801073a5 <alltraps>

80107d84 <vector103>:
.globl vector103
vector103:
  pushl $0
80107d84:	6a 00                	push   $0x0
  pushl $103
80107d86:	6a 67                	push   $0x67
  jmp alltraps
80107d88:	e9 18 f6 ff ff       	jmp    801073a5 <alltraps>

80107d8d <vector104>:
.globl vector104
vector104:
  pushl $0
80107d8d:	6a 00                	push   $0x0
  pushl $104
80107d8f:	6a 68                	push   $0x68
  jmp alltraps
80107d91:	e9 0f f6 ff ff       	jmp    801073a5 <alltraps>

80107d96 <vector105>:
.globl vector105
vector105:
  pushl $0
80107d96:	6a 00                	push   $0x0
  pushl $105
80107d98:	6a 69                	push   $0x69
  jmp alltraps
80107d9a:	e9 06 f6 ff ff       	jmp    801073a5 <alltraps>

80107d9f <vector106>:
.globl vector106
vector106:
  pushl $0
80107d9f:	6a 00                	push   $0x0
  pushl $106
80107da1:	6a 6a                	push   $0x6a
  jmp alltraps
80107da3:	e9 fd f5 ff ff       	jmp    801073a5 <alltraps>

80107da8 <vector107>:
.globl vector107
vector107:
  pushl $0
80107da8:	6a 00                	push   $0x0
  pushl $107
80107daa:	6a 6b                	push   $0x6b
  jmp alltraps
80107dac:	e9 f4 f5 ff ff       	jmp    801073a5 <alltraps>

80107db1 <vector108>:
.globl vector108
vector108:
  pushl $0
80107db1:	6a 00                	push   $0x0
  pushl $108
80107db3:	6a 6c                	push   $0x6c
  jmp alltraps
80107db5:	e9 eb f5 ff ff       	jmp    801073a5 <alltraps>

80107dba <vector109>:
.globl vector109
vector109:
  pushl $0
80107dba:	6a 00                	push   $0x0
  pushl $109
80107dbc:	6a 6d                	push   $0x6d
  jmp alltraps
80107dbe:	e9 e2 f5 ff ff       	jmp    801073a5 <alltraps>

80107dc3 <vector110>:
.globl vector110
vector110:
  pushl $0
80107dc3:	6a 00                	push   $0x0
  pushl $110
80107dc5:	6a 6e                	push   $0x6e
  jmp alltraps
80107dc7:	e9 d9 f5 ff ff       	jmp    801073a5 <alltraps>

80107dcc <vector111>:
.globl vector111
vector111:
  pushl $0
80107dcc:	6a 00                	push   $0x0
  pushl $111
80107dce:	6a 6f                	push   $0x6f
  jmp alltraps
80107dd0:	e9 d0 f5 ff ff       	jmp    801073a5 <alltraps>

80107dd5 <vector112>:
.globl vector112
vector112:
  pushl $0
80107dd5:	6a 00                	push   $0x0
  pushl $112
80107dd7:	6a 70                	push   $0x70
  jmp alltraps
80107dd9:	e9 c7 f5 ff ff       	jmp    801073a5 <alltraps>

80107dde <vector113>:
.globl vector113
vector113:
  pushl $0
80107dde:	6a 00                	push   $0x0
  pushl $113
80107de0:	6a 71                	push   $0x71
  jmp alltraps
80107de2:	e9 be f5 ff ff       	jmp    801073a5 <alltraps>

80107de7 <vector114>:
.globl vector114
vector114:
  pushl $0
80107de7:	6a 00                	push   $0x0
  pushl $114
80107de9:	6a 72                	push   $0x72
  jmp alltraps
80107deb:	e9 b5 f5 ff ff       	jmp    801073a5 <alltraps>

80107df0 <vector115>:
.globl vector115
vector115:
  pushl $0
80107df0:	6a 00                	push   $0x0
  pushl $115
80107df2:	6a 73                	push   $0x73
  jmp alltraps
80107df4:	e9 ac f5 ff ff       	jmp    801073a5 <alltraps>

80107df9 <vector116>:
.globl vector116
vector116:
  pushl $0
80107df9:	6a 00                	push   $0x0
  pushl $116
80107dfb:	6a 74                	push   $0x74
  jmp alltraps
80107dfd:	e9 a3 f5 ff ff       	jmp    801073a5 <alltraps>

80107e02 <vector117>:
.globl vector117
vector117:
  pushl $0
80107e02:	6a 00                	push   $0x0
  pushl $117
80107e04:	6a 75                	push   $0x75
  jmp alltraps
80107e06:	e9 9a f5 ff ff       	jmp    801073a5 <alltraps>

80107e0b <vector118>:
.globl vector118
vector118:
  pushl $0
80107e0b:	6a 00                	push   $0x0
  pushl $118
80107e0d:	6a 76                	push   $0x76
  jmp alltraps
80107e0f:	e9 91 f5 ff ff       	jmp    801073a5 <alltraps>

80107e14 <vector119>:
.globl vector119
vector119:
  pushl $0
80107e14:	6a 00                	push   $0x0
  pushl $119
80107e16:	6a 77                	push   $0x77
  jmp alltraps
80107e18:	e9 88 f5 ff ff       	jmp    801073a5 <alltraps>

80107e1d <vector120>:
.globl vector120
vector120:
  pushl $0
80107e1d:	6a 00                	push   $0x0
  pushl $120
80107e1f:	6a 78                	push   $0x78
  jmp alltraps
80107e21:	e9 7f f5 ff ff       	jmp    801073a5 <alltraps>

80107e26 <vector121>:
.globl vector121
vector121:
  pushl $0
80107e26:	6a 00                	push   $0x0
  pushl $121
80107e28:	6a 79                	push   $0x79
  jmp alltraps
80107e2a:	e9 76 f5 ff ff       	jmp    801073a5 <alltraps>

80107e2f <vector122>:
.globl vector122
vector122:
  pushl $0
80107e2f:	6a 00                	push   $0x0
  pushl $122
80107e31:	6a 7a                	push   $0x7a
  jmp alltraps
80107e33:	e9 6d f5 ff ff       	jmp    801073a5 <alltraps>

80107e38 <vector123>:
.globl vector123
vector123:
  pushl $0
80107e38:	6a 00                	push   $0x0
  pushl $123
80107e3a:	6a 7b                	push   $0x7b
  jmp alltraps
80107e3c:	e9 64 f5 ff ff       	jmp    801073a5 <alltraps>

80107e41 <vector124>:
.globl vector124
vector124:
  pushl $0
80107e41:	6a 00                	push   $0x0
  pushl $124
80107e43:	6a 7c                	push   $0x7c
  jmp alltraps
80107e45:	e9 5b f5 ff ff       	jmp    801073a5 <alltraps>

80107e4a <vector125>:
.globl vector125
vector125:
  pushl $0
80107e4a:	6a 00                	push   $0x0
  pushl $125
80107e4c:	6a 7d                	push   $0x7d
  jmp alltraps
80107e4e:	e9 52 f5 ff ff       	jmp    801073a5 <alltraps>

80107e53 <vector126>:
.globl vector126
vector126:
  pushl $0
80107e53:	6a 00                	push   $0x0
  pushl $126
80107e55:	6a 7e                	push   $0x7e
  jmp alltraps
80107e57:	e9 49 f5 ff ff       	jmp    801073a5 <alltraps>

80107e5c <vector127>:
.globl vector127
vector127:
  pushl $0
80107e5c:	6a 00                	push   $0x0
  pushl $127
80107e5e:	6a 7f                	push   $0x7f
  jmp alltraps
80107e60:	e9 40 f5 ff ff       	jmp    801073a5 <alltraps>

80107e65 <vector128>:
.globl vector128
vector128:
  pushl $0
80107e65:	6a 00                	push   $0x0
  pushl $128
80107e67:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107e6c:	e9 34 f5 ff ff       	jmp    801073a5 <alltraps>

80107e71 <vector129>:
.globl vector129
vector129:
  pushl $0
80107e71:	6a 00                	push   $0x0
  pushl $129
80107e73:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107e78:	e9 28 f5 ff ff       	jmp    801073a5 <alltraps>

80107e7d <vector130>:
.globl vector130
vector130:
  pushl $0
80107e7d:	6a 00                	push   $0x0
  pushl $130
80107e7f:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107e84:	e9 1c f5 ff ff       	jmp    801073a5 <alltraps>

80107e89 <vector131>:
.globl vector131
vector131:
  pushl $0
80107e89:	6a 00                	push   $0x0
  pushl $131
80107e8b:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107e90:	e9 10 f5 ff ff       	jmp    801073a5 <alltraps>

80107e95 <vector132>:
.globl vector132
vector132:
  pushl $0
80107e95:	6a 00                	push   $0x0
  pushl $132
80107e97:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107e9c:	e9 04 f5 ff ff       	jmp    801073a5 <alltraps>

80107ea1 <vector133>:
.globl vector133
vector133:
  pushl $0
80107ea1:	6a 00                	push   $0x0
  pushl $133
80107ea3:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107ea8:	e9 f8 f4 ff ff       	jmp    801073a5 <alltraps>

80107ead <vector134>:
.globl vector134
vector134:
  pushl $0
80107ead:	6a 00                	push   $0x0
  pushl $134
80107eaf:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107eb4:	e9 ec f4 ff ff       	jmp    801073a5 <alltraps>

80107eb9 <vector135>:
.globl vector135
vector135:
  pushl $0
80107eb9:	6a 00                	push   $0x0
  pushl $135
80107ebb:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107ec0:	e9 e0 f4 ff ff       	jmp    801073a5 <alltraps>

80107ec5 <vector136>:
.globl vector136
vector136:
  pushl $0
80107ec5:	6a 00                	push   $0x0
  pushl $136
80107ec7:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107ecc:	e9 d4 f4 ff ff       	jmp    801073a5 <alltraps>

80107ed1 <vector137>:
.globl vector137
vector137:
  pushl $0
80107ed1:	6a 00                	push   $0x0
  pushl $137
80107ed3:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107ed8:	e9 c8 f4 ff ff       	jmp    801073a5 <alltraps>

80107edd <vector138>:
.globl vector138
vector138:
  pushl $0
80107edd:	6a 00                	push   $0x0
  pushl $138
80107edf:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107ee4:	e9 bc f4 ff ff       	jmp    801073a5 <alltraps>

80107ee9 <vector139>:
.globl vector139
vector139:
  pushl $0
80107ee9:	6a 00                	push   $0x0
  pushl $139
80107eeb:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107ef0:	e9 b0 f4 ff ff       	jmp    801073a5 <alltraps>

80107ef5 <vector140>:
.globl vector140
vector140:
  pushl $0
80107ef5:	6a 00                	push   $0x0
  pushl $140
80107ef7:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107efc:	e9 a4 f4 ff ff       	jmp    801073a5 <alltraps>

80107f01 <vector141>:
.globl vector141
vector141:
  pushl $0
80107f01:	6a 00                	push   $0x0
  pushl $141
80107f03:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107f08:	e9 98 f4 ff ff       	jmp    801073a5 <alltraps>

80107f0d <vector142>:
.globl vector142
vector142:
  pushl $0
80107f0d:	6a 00                	push   $0x0
  pushl $142
80107f0f:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107f14:	e9 8c f4 ff ff       	jmp    801073a5 <alltraps>

80107f19 <vector143>:
.globl vector143
vector143:
  pushl $0
80107f19:	6a 00                	push   $0x0
  pushl $143
80107f1b:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107f20:	e9 80 f4 ff ff       	jmp    801073a5 <alltraps>

80107f25 <vector144>:
.globl vector144
vector144:
  pushl $0
80107f25:	6a 00                	push   $0x0
  pushl $144
80107f27:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107f2c:	e9 74 f4 ff ff       	jmp    801073a5 <alltraps>

80107f31 <vector145>:
.globl vector145
vector145:
  pushl $0
80107f31:	6a 00                	push   $0x0
  pushl $145
80107f33:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107f38:	e9 68 f4 ff ff       	jmp    801073a5 <alltraps>

80107f3d <vector146>:
.globl vector146
vector146:
  pushl $0
80107f3d:	6a 00                	push   $0x0
  pushl $146
80107f3f:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107f44:	e9 5c f4 ff ff       	jmp    801073a5 <alltraps>

80107f49 <vector147>:
.globl vector147
vector147:
  pushl $0
80107f49:	6a 00                	push   $0x0
  pushl $147
80107f4b:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107f50:	e9 50 f4 ff ff       	jmp    801073a5 <alltraps>

80107f55 <vector148>:
.globl vector148
vector148:
  pushl $0
80107f55:	6a 00                	push   $0x0
  pushl $148
80107f57:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107f5c:	e9 44 f4 ff ff       	jmp    801073a5 <alltraps>

80107f61 <vector149>:
.globl vector149
vector149:
  pushl $0
80107f61:	6a 00                	push   $0x0
  pushl $149
80107f63:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107f68:	e9 38 f4 ff ff       	jmp    801073a5 <alltraps>

80107f6d <vector150>:
.globl vector150
vector150:
  pushl $0
80107f6d:	6a 00                	push   $0x0
  pushl $150
80107f6f:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107f74:	e9 2c f4 ff ff       	jmp    801073a5 <alltraps>

80107f79 <vector151>:
.globl vector151
vector151:
  pushl $0
80107f79:	6a 00                	push   $0x0
  pushl $151
80107f7b:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107f80:	e9 20 f4 ff ff       	jmp    801073a5 <alltraps>

80107f85 <vector152>:
.globl vector152
vector152:
  pushl $0
80107f85:	6a 00                	push   $0x0
  pushl $152
80107f87:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107f8c:	e9 14 f4 ff ff       	jmp    801073a5 <alltraps>

80107f91 <vector153>:
.globl vector153
vector153:
  pushl $0
80107f91:	6a 00                	push   $0x0
  pushl $153
80107f93:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107f98:	e9 08 f4 ff ff       	jmp    801073a5 <alltraps>

80107f9d <vector154>:
.globl vector154
vector154:
  pushl $0
80107f9d:	6a 00                	push   $0x0
  pushl $154
80107f9f:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107fa4:	e9 fc f3 ff ff       	jmp    801073a5 <alltraps>

80107fa9 <vector155>:
.globl vector155
vector155:
  pushl $0
80107fa9:	6a 00                	push   $0x0
  pushl $155
80107fab:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107fb0:	e9 f0 f3 ff ff       	jmp    801073a5 <alltraps>

80107fb5 <vector156>:
.globl vector156
vector156:
  pushl $0
80107fb5:	6a 00                	push   $0x0
  pushl $156
80107fb7:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107fbc:	e9 e4 f3 ff ff       	jmp    801073a5 <alltraps>

80107fc1 <vector157>:
.globl vector157
vector157:
  pushl $0
80107fc1:	6a 00                	push   $0x0
  pushl $157
80107fc3:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107fc8:	e9 d8 f3 ff ff       	jmp    801073a5 <alltraps>

80107fcd <vector158>:
.globl vector158
vector158:
  pushl $0
80107fcd:	6a 00                	push   $0x0
  pushl $158
80107fcf:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107fd4:	e9 cc f3 ff ff       	jmp    801073a5 <alltraps>

80107fd9 <vector159>:
.globl vector159
vector159:
  pushl $0
80107fd9:	6a 00                	push   $0x0
  pushl $159
80107fdb:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107fe0:	e9 c0 f3 ff ff       	jmp    801073a5 <alltraps>

80107fe5 <vector160>:
.globl vector160
vector160:
  pushl $0
80107fe5:	6a 00                	push   $0x0
  pushl $160
80107fe7:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107fec:	e9 b4 f3 ff ff       	jmp    801073a5 <alltraps>

80107ff1 <vector161>:
.globl vector161
vector161:
  pushl $0
80107ff1:	6a 00                	push   $0x0
  pushl $161
80107ff3:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107ff8:	e9 a8 f3 ff ff       	jmp    801073a5 <alltraps>

80107ffd <vector162>:
.globl vector162
vector162:
  pushl $0
80107ffd:	6a 00                	push   $0x0
  pushl $162
80107fff:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108004:	e9 9c f3 ff ff       	jmp    801073a5 <alltraps>

80108009 <vector163>:
.globl vector163
vector163:
  pushl $0
80108009:	6a 00                	push   $0x0
  pushl $163
8010800b:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108010:	e9 90 f3 ff ff       	jmp    801073a5 <alltraps>

80108015 <vector164>:
.globl vector164
vector164:
  pushl $0
80108015:	6a 00                	push   $0x0
  pushl $164
80108017:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010801c:	e9 84 f3 ff ff       	jmp    801073a5 <alltraps>

80108021 <vector165>:
.globl vector165
vector165:
  pushl $0
80108021:	6a 00                	push   $0x0
  pushl $165
80108023:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108028:	e9 78 f3 ff ff       	jmp    801073a5 <alltraps>

8010802d <vector166>:
.globl vector166
vector166:
  pushl $0
8010802d:	6a 00                	push   $0x0
  pushl $166
8010802f:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108034:	e9 6c f3 ff ff       	jmp    801073a5 <alltraps>

80108039 <vector167>:
.globl vector167
vector167:
  pushl $0
80108039:	6a 00                	push   $0x0
  pushl $167
8010803b:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108040:	e9 60 f3 ff ff       	jmp    801073a5 <alltraps>

80108045 <vector168>:
.globl vector168
vector168:
  pushl $0
80108045:	6a 00                	push   $0x0
  pushl $168
80108047:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010804c:	e9 54 f3 ff ff       	jmp    801073a5 <alltraps>

80108051 <vector169>:
.globl vector169
vector169:
  pushl $0
80108051:	6a 00                	push   $0x0
  pushl $169
80108053:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108058:	e9 48 f3 ff ff       	jmp    801073a5 <alltraps>

8010805d <vector170>:
.globl vector170
vector170:
  pushl $0
8010805d:	6a 00                	push   $0x0
  pushl $170
8010805f:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108064:	e9 3c f3 ff ff       	jmp    801073a5 <alltraps>

80108069 <vector171>:
.globl vector171
vector171:
  pushl $0
80108069:	6a 00                	push   $0x0
  pushl $171
8010806b:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108070:	e9 30 f3 ff ff       	jmp    801073a5 <alltraps>

80108075 <vector172>:
.globl vector172
vector172:
  pushl $0
80108075:	6a 00                	push   $0x0
  pushl $172
80108077:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010807c:	e9 24 f3 ff ff       	jmp    801073a5 <alltraps>

80108081 <vector173>:
.globl vector173
vector173:
  pushl $0
80108081:	6a 00                	push   $0x0
  pushl $173
80108083:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108088:	e9 18 f3 ff ff       	jmp    801073a5 <alltraps>

8010808d <vector174>:
.globl vector174
vector174:
  pushl $0
8010808d:	6a 00                	push   $0x0
  pushl $174
8010808f:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108094:	e9 0c f3 ff ff       	jmp    801073a5 <alltraps>

80108099 <vector175>:
.globl vector175
vector175:
  pushl $0
80108099:	6a 00                	push   $0x0
  pushl $175
8010809b:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801080a0:	e9 00 f3 ff ff       	jmp    801073a5 <alltraps>

801080a5 <vector176>:
.globl vector176
vector176:
  pushl $0
801080a5:	6a 00                	push   $0x0
  pushl $176
801080a7:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801080ac:	e9 f4 f2 ff ff       	jmp    801073a5 <alltraps>

801080b1 <vector177>:
.globl vector177
vector177:
  pushl $0
801080b1:	6a 00                	push   $0x0
  pushl $177
801080b3:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801080b8:	e9 e8 f2 ff ff       	jmp    801073a5 <alltraps>

801080bd <vector178>:
.globl vector178
vector178:
  pushl $0
801080bd:	6a 00                	push   $0x0
  pushl $178
801080bf:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801080c4:	e9 dc f2 ff ff       	jmp    801073a5 <alltraps>

801080c9 <vector179>:
.globl vector179
vector179:
  pushl $0
801080c9:	6a 00                	push   $0x0
  pushl $179
801080cb:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801080d0:	e9 d0 f2 ff ff       	jmp    801073a5 <alltraps>

801080d5 <vector180>:
.globl vector180
vector180:
  pushl $0
801080d5:	6a 00                	push   $0x0
  pushl $180
801080d7:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801080dc:	e9 c4 f2 ff ff       	jmp    801073a5 <alltraps>

801080e1 <vector181>:
.globl vector181
vector181:
  pushl $0
801080e1:	6a 00                	push   $0x0
  pushl $181
801080e3:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801080e8:	e9 b8 f2 ff ff       	jmp    801073a5 <alltraps>

801080ed <vector182>:
.globl vector182
vector182:
  pushl $0
801080ed:	6a 00                	push   $0x0
  pushl $182
801080ef:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801080f4:	e9 ac f2 ff ff       	jmp    801073a5 <alltraps>

801080f9 <vector183>:
.globl vector183
vector183:
  pushl $0
801080f9:	6a 00                	push   $0x0
  pushl $183
801080fb:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108100:	e9 a0 f2 ff ff       	jmp    801073a5 <alltraps>

80108105 <vector184>:
.globl vector184
vector184:
  pushl $0
80108105:	6a 00                	push   $0x0
  pushl $184
80108107:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010810c:	e9 94 f2 ff ff       	jmp    801073a5 <alltraps>

80108111 <vector185>:
.globl vector185
vector185:
  pushl $0
80108111:	6a 00                	push   $0x0
  pushl $185
80108113:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108118:	e9 88 f2 ff ff       	jmp    801073a5 <alltraps>

8010811d <vector186>:
.globl vector186
vector186:
  pushl $0
8010811d:	6a 00                	push   $0x0
  pushl $186
8010811f:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108124:	e9 7c f2 ff ff       	jmp    801073a5 <alltraps>

80108129 <vector187>:
.globl vector187
vector187:
  pushl $0
80108129:	6a 00                	push   $0x0
  pushl $187
8010812b:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108130:	e9 70 f2 ff ff       	jmp    801073a5 <alltraps>

80108135 <vector188>:
.globl vector188
vector188:
  pushl $0
80108135:	6a 00                	push   $0x0
  pushl $188
80108137:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010813c:	e9 64 f2 ff ff       	jmp    801073a5 <alltraps>

80108141 <vector189>:
.globl vector189
vector189:
  pushl $0
80108141:	6a 00                	push   $0x0
  pushl $189
80108143:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108148:	e9 58 f2 ff ff       	jmp    801073a5 <alltraps>

8010814d <vector190>:
.globl vector190
vector190:
  pushl $0
8010814d:	6a 00                	push   $0x0
  pushl $190
8010814f:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108154:	e9 4c f2 ff ff       	jmp    801073a5 <alltraps>

80108159 <vector191>:
.globl vector191
vector191:
  pushl $0
80108159:	6a 00                	push   $0x0
  pushl $191
8010815b:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108160:	e9 40 f2 ff ff       	jmp    801073a5 <alltraps>

80108165 <vector192>:
.globl vector192
vector192:
  pushl $0
80108165:	6a 00                	push   $0x0
  pushl $192
80108167:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010816c:	e9 34 f2 ff ff       	jmp    801073a5 <alltraps>

80108171 <vector193>:
.globl vector193
vector193:
  pushl $0
80108171:	6a 00                	push   $0x0
  pushl $193
80108173:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108178:	e9 28 f2 ff ff       	jmp    801073a5 <alltraps>

8010817d <vector194>:
.globl vector194
vector194:
  pushl $0
8010817d:	6a 00                	push   $0x0
  pushl $194
8010817f:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108184:	e9 1c f2 ff ff       	jmp    801073a5 <alltraps>

80108189 <vector195>:
.globl vector195
vector195:
  pushl $0
80108189:	6a 00                	push   $0x0
  pushl $195
8010818b:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108190:	e9 10 f2 ff ff       	jmp    801073a5 <alltraps>

80108195 <vector196>:
.globl vector196
vector196:
  pushl $0
80108195:	6a 00                	push   $0x0
  pushl $196
80108197:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010819c:	e9 04 f2 ff ff       	jmp    801073a5 <alltraps>

801081a1 <vector197>:
.globl vector197
vector197:
  pushl $0
801081a1:	6a 00                	push   $0x0
  pushl $197
801081a3:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801081a8:	e9 f8 f1 ff ff       	jmp    801073a5 <alltraps>

801081ad <vector198>:
.globl vector198
vector198:
  pushl $0
801081ad:	6a 00                	push   $0x0
  pushl $198
801081af:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801081b4:	e9 ec f1 ff ff       	jmp    801073a5 <alltraps>

801081b9 <vector199>:
.globl vector199
vector199:
  pushl $0
801081b9:	6a 00                	push   $0x0
  pushl $199
801081bb:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801081c0:	e9 e0 f1 ff ff       	jmp    801073a5 <alltraps>

801081c5 <vector200>:
.globl vector200
vector200:
  pushl $0
801081c5:	6a 00                	push   $0x0
  pushl $200
801081c7:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801081cc:	e9 d4 f1 ff ff       	jmp    801073a5 <alltraps>

801081d1 <vector201>:
.globl vector201
vector201:
  pushl $0
801081d1:	6a 00                	push   $0x0
  pushl $201
801081d3:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801081d8:	e9 c8 f1 ff ff       	jmp    801073a5 <alltraps>

801081dd <vector202>:
.globl vector202
vector202:
  pushl $0
801081dd:	6a 00                	push   $0x0
  pushl $202
801081df:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801081e4:	e9 bc f1 ff ff       	jmp    801073a5 <alltraps>

801081e9 <vector203>:
.globl vector203
vector203:
  pushl $0
801081e9:	6a 00                	push   $0x0
  pushl $203
801081eb:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801081f0:	e9 b0 f1 ff ff       	jmp    801073a5 <alltraps>

801081f5 <vector204>:
.globl vector204
vector204:
  pushl $0
801081f5:	6a 00                	push   $0x0
  pushl $204
801081f7:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801081fc:	e9 a4 f1 ff ff       	jmp    801073a5 <alltraps>

80108201 <vector205>:
.globl vector205
vector205:
  pushl $0
80108201:	6a 00                	push   $0x0
  pushl $205
80108203:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108208:	e9 98 f1 ff ff       	jmp    801073a5 <alltraps>

8010820d <vector206>:
.globl vector206
vector206:
  pushl $0
8010820d:	6a 00                	push   $0x0
  pushl $206
8010820f:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108214:	e9 8c f1 ff ff       	jmp    801073a5 <alltraps>

80108219 <vector207>:
.globl vector207
vector207:
  pushl $0
80108219:	6a 00                	push   $0x0
  pushl $207
8010821b:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108220:	e9 80 f1 ff ff       	jmp    801073a5 <alltraps>

80108225 <vector208>:
.globl vector208
vector208:
  pushl $0
80108225:	6a 00                	push   $0x0
  pushl $208
80108227:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010822c:	e9 74 f1 ff ff       	jmp    801073a5 <alltraps>

80108231 <vector209>:
.globl vector209
vector209:
  pushl $0
80108231:	6a 00                	push   $0x0
  pushl $209
80108233:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108238:	e9 68 f1 ff ff       	jmp    801073a5 <alltraps>

8010823d <vector210>:
.globl vector210
vector210:
  pushl $0
8010823d:	6a 00                	push   $0x0
  pushl $210
8010823f:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108244:	e9 5c f1 ff ff       	jmp    801073a5 <alltraps>

80108249 <vector211>:
.globl vector211
vector211:
  pushl $0
80108249:	6a 00                	push   $0x0
  pushl $211
8010824b:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108250:	e9 50 f1 ff ff       	jmp    801073a5 <alltraps>

80108255 <vector212>:
.globl vector212
vector212:
  pushl $0
80108255:	6a 00                	push   $0x0
  pushl $212
80108257:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010825c:	e9 44 f1 ff ff       	jmp    801073a5 <alltraps>

80108261 <vector213>:
.globl vector213
vector213:
  pushl $0
80108261:	6a 00                	push   $0x0
  pushl $213
80108263:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108268:	e9 38 f1 ff ff       	jmp    801073a5 <alltraps>

8010826d <vector214>:
.globl vector214
vector214:
  pushl $0
8010826d:	6a 00                	push   $0x0
  pushl $214
8010826f:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108274:	e9 2c f1 ff ff       	jmp    801073a5 <alltraps>

80108279 <vector215>:
.globl vector215
vector215:
  pushl $0
80108279:	6a 00                	push   $0x0
  pushl $215
8010827b:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108280:	e9 20 f1 ff ff       	jmp    801073a5 <alltraps>

80108285 <vector216>:
.globl vector216
vector216:
  pushl $0
80108285:	6a 00                	push   $0x0
  pushl $216
80108287:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010828c:	e9 14 f1 ff ff       	jmp    801073a5 <alltraps>

80108291 <vector217>:
.globl vector217
vector217:
  pushl $0
80108291:	6a 00                	push   $0x0
  pushl $217
80108293:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108298:	e9 08 f1 ff ff       	jmp    801073a5 <alltraps>

8010829d <vector218>:
.globl vector218
vector218:
  pushl $0
8010829d:	6a 00                	push   $0x0
  pushl $218
8010829f:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801082a4:	e9 fc f0 ff ff       	jmp    801073a5 <alltraps>

801082a9 <vector219>:
.globl vector219
vector219:
  pushl $0
801082a9:	6a 00                	push   $0x0
  pushl $219
801082ab:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801082b0:	e9 f0 f0 ff ff       	jmp    801073a5 <alltraps>

801082b5 <vector220>:
.globl vector220
vector220:
  pushl $0
801082b5:	6a 00                	push   $0x0
  pushl $220
801082b7:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801082bc:	e9 e4 f0 ff ff       	jmp    801073a5 <alltraps>

801082c1 <vector221>:
.globl vector221
vector221:
  pushl $0
801082c1:	6a 00                	push   $0x0
  pushl $221
801082c3:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801082c8:	e9 d8 f0 ff ff       	jmp    801073a5 <alltraps>

801082cd <vector222>:
.globl vector222
vector222:
  pushl $0
801082cd:	6a 00                	push   $0x0
  pushl $222
801082cf:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801082d4:	e9 cc f0 ff ff       	jmp    801073a5 <alltraps>

801082d9 <vector223>:
.globl vector223
vector223:
  pushl $0
801082d9:	6a 00                	push   $0x0
  pushl $223
801082db:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801082e0:	e9 c0 f0 ff ff       	jmp    801073a5 <alltraps>

801082e5 <vector224>:
.globl vector224
vector224:
  pushl $0
801082e5:	6a 00                	push   $0x0
  pushl $224
801082e7:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801082ec:	e9 b4 f0 ff ff       	jmp    801073a5 <alltraps>

801082f1 <vector225>:
.globl vector225
vector225:
  pushl $0
801082f1:	6a 00                	push   $0x0
  pushl $225
801082f3:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801082f8:	e9 a8 f0 ff ff       	jmp    801073a5 <alltraps>

801082fd <vector226>:
.globl vector226
vector226:
  pushl $0
801082fd:	6a 00                	push   $0x0
  pushl $226
801082ff:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108304:	e9 9c f0 ff ff       	jmp    801073a5 <alltraps>

80108309 <vector227>:
.globl vector227
vector227:
  pushl $0
80108309:	6a 00                	push   $0x0
  pushl $227
8010830b:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108310:	e9 90 f0 ff ff       	jmp    801073a5 <alltraps>

80108315 <vector228>:
.globl vector228
vector228:
  pushl $0
80108315:	6a 00                	push   $0x0
  pushl $228
80108317:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010831c:	e9 84 f0 ff ff       	jmp    801073a5 <alltraps>

80108321 <vector229>:
.globl vector229
vector229:
  pushl $0
80108321:	6a 00                	push   $0x0
  pushl $229
80108323:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108328:	e9 78 f0 ff ff       	jmp    801073a5 <alltraps>

8010832d <vector230>:
.globl vector230
vector230:
  pushl $0
8010832d:	6a 00                	push   $0x0
  pushl $230
8010832f:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108334:	e9 6c f0 ff ff       	jmp    801073a5 <alltraps>

80108339 <vector231>:
.globl vector231
vector231:
  pushl $0
80108339:	6a 00                	push   $0x0
  pushl $231
8010833b:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108340:	e9 60 f0 ff ff       	jmp    801073a5 <alltraps>

80108345 <vector232>:
.globl vector232
vector232:
  pushl $0
80108345:	6a 00                	push   $0x0
  pushl $232
80108347:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010834c:	e9 54 f0 ff ff       	jmp    801073a5 <alltraps>

80108351 <vector233>:
.globl vector233
vector233:
  pushl $0
80108351:	6a 00                	push   $0x0
  pushl $233
80108353:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108358:	e9 48 f0 ff ff       	jmp    801073a5 <alltraps>

8010835d <vector234>:
.globl vector234
vector234:
  pushl $0
8010835d:	6a 00                	push   $0x0
  pushl $234
8010835f:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108364:	e9 3c f0 ff ff       	jmp    801073a5 <alltraps>

80108369 <vector235>:
.globl vector235
vector235:
  pushl $0
80108369:	6a 00                	push   $0x0
  pushl $235
8010836b:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108370:	e9 30 f0 ff ff       	jmp    801073a5 <alltraps>

80108375 <vector236>:
.globl vector236
vector236:
  pushl $0
80108375:	6a 00                	push   $0x0
  pushl $236
80108377:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010837c:	e9 24 f0 ff ff       	jmp    801073a5 <alltraps>

80108381 <vector237>:
.globl vector237
vector237:
  pushl $0
80108381:	6a 00                	push   $0x0
  pushl $237
80108383:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108388:	e9 18 f0 ff ff       	jmp    801073a5 <alltraps>

8010838d <vector238>:
.globl vector238
vector238:
  pushl $0
8010838d:	6a 00                	push   $0x0
  pushl $238
8010838f:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108394:	e9 0c f0 ff ff       	jmp    801073a5 <alltraps>

80108399 <vector239>:
.globl vector239
vector239:
  pushl $0
80108399:	6a 00                	push   $0x0
  pushl $239
8010839b:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801083a0:	e9 00 f0 ff ff       	jmp    801073a5 <alltraps>

801083a5 <vector240>:
.globl vector240
vector240:
  pushl $0
801083a5:	6a 00                	push   $0x0
  pushl $240
801083a7:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801083ac:	e9 f4 ef ff ff       	jmp    801073a5 <alltraps>

801083b1 <vector241>:
.globl vector241
vector241:
  pushl $0
801083b1:	6a 00                	push   $0x0
  pushl $241
801083b3:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801083b8:	e9 e8 ef ff ff       	jmp    801073a5 <alltraps>

801083bd <vector242>:
.globl vector242
vector242:
  pushl $0
801083bd:	6a 00                	push   $0x0
  pushl $242
801083bf:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801083c4:	e9 dc ef ff ff       	jmp    801073a5 <alltraps>

801083c9 <vector243>:
.globl vector243
vector243:
  pushl $0
801083c9:	6a 00                	push   $0x0
  pushl $243
801083cb:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801083d0:	e9 d0 ef ff ff       	jmp    801073a5 <alltraps>

801083d5 <vector244>:
.globl vector244
vector244:
  pushl $0
801083d5:	6a 00                	push   $0x0
  pushl $244
801083d7:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801083dc:	e9 c4 ef ff ff       	jmp    801073a5 <alltraps>

801083e1 <vector245>:
.globl vector245
vector245:
  pushl $0
801083e1:	6a 00                	push   $0x0
  pushl $245
801083e3:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801083e8:	e9 b8 ef ff ff       	jmp    801073a5 <alltraps>

801083ed <vector246>:
.globl vector246
vector246:
  pushl $0
801083ed:	6a 00                	push   $0x0
  pushl $246
801083ef:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801083f4:	e9 ac ef ff ff       	jmp    801073a5 <alltraps>

801083f9 <vector247>:
.globl vector247
vector247:
  pushl $0
801083f9:	6a 00                	push   $0x0
  pushl $247
801083fb:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108400:	e9 a0 ef ff ff       	jmp    801073a5 <alltraps>

80108405 <vector248>:
.globl vector248
vector248:
  pushl $0
80108405:	6a 00                	push   $0x0
  pushl $248
80108407:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010840c:	e9 94 ef ff ff       	jmp    801073a5 <alltraps>

80108411 <vector249>:
.globl vector249
vector249:
  pushl $0
80108411:	6a 00                	push   $0x0
  pushl $249
80108413:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108418:	e9 88 ef ff ff       	jmp    801073a5 <alltraps>

8010841d <vector250>:
.globl vector250
vector250:
  pushl $0
8010841d:	6a 00                	push   $0x0
  pushl $250
8010841f:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108424:	e9 7c ef ff ff       	jmp    801073a5 <alltraps>

80108429 <vector251>:
.globl vector251
vector251:
  pushl $0
80108429:	6a 00                	push   $0x0
  pushl $251
8010842b:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108430:	e9 70 ef ff ff       	jmp    801073a5 <alltraps>

80108435 <vector252>:
.globl vector252
vector252:
  pushl $0
80108435:	6a 00                	push   $0x0
  pushl $252
80108437:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010843c:	e9 64 ef ff ff       	jmp    801073a5 <alltraps>

80108441 <vector253>:
.globl vector253
vector253:
  pushl $0
80108441:	6a 00                	push   $0x0
  pushl $253
80108443:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108448:	e9 58 ef ff ff       	jmp    801073a5 <alltraps>

8010844d <vector254>:
.globl vector254
vector254:
  pushl $0
8010844d:	6a 00                	push   $0x0
  pushl $254
8010844f:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108454:	e9 4c ef ff ff       	jmp    801073a5 <alltraps>

80108459 <vector255>:
.globl vector255
vector255:
  pushl $0
80108459:	6a 00                	push   $0x0
  pushl $255
8010845b:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108460:	e9 40 ef ff ff       	jmp    801073a5 <alltraps>

80108465 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108465:	55                   	push   %ebp
80108466:	89 e5                	mov    %esp,%ebp
80108468:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010846b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010846e:	83 e8 01             	sub    $0x1,%eax
80108471:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108475:	8b 45 08             	mov    0x8(%ebp),%eax
80108478:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010847c:	8b 45 08             	mov    0x8(%ebp),%eax
8010847f:	c1 e8 10             	shr    $0x10,%eax
80108482:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108486:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108489:	0f 01 10             	lgdtl  (%eax)
}
8010848c:	90                   	nop
8010848d:	c9                   	leave  
8010848e:	c3                   	ret    

8010848f <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010848f:	55                   	push   %ebp
80108490:	89 e5                	mov    %esp,%ebp
80108492:	83 ec 04             	sub    $0x4,%esp
80108495:	8b 45 08             	mov    0x8(%ebp),%eax
80108498:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010849c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801084a0:	0f 00 d8             	ltr    %ax
}
801084a3:	90                   	nop
801084a4:	c9                   	leave  
801084a5:	c3                   	ret    

801084a6 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801084a6:	55                   	push   %ebp
801084a7:	89 e5                	mov    %esp,%ebp
801084a9:	83 ec 04             	sub    $0x4,%esp
801084ac:	8b 45 08             	mov    0x8(%ebp),%eax
801084af:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801084b3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801084b7:	8e e8                	mov    %eax,%gs
}
801084b9:	90                   	nop
801084ba:	c9                   	leave  
801084bb:	c3                   	ret    

801084bc <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801084bc:	55                   	push   %ebp
801084bd:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801084bf:	8b 45 08             	mov    0x8(%ebp),%eax
801084c2:	0f 22 d8             	mov    %eax,%cr3
}
801084c5:	90                   	nop
801084c6:	5d                   	pop    %ebp
801084c7:	c3                   	ret    

801084c8 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801084c8:	55                   	push   %ebp
801084c9:	89 e5                	mov    %esp,%ebp
801084cb:	8b 45 08             	mov    0x8(%ebp),%eax
801084ce:	05 00 00 00 80       	add    $0x80000000,%eax
801084d3:	5d                   	pop    %ebp
801084d4:	c3                   	ret    

801084d5 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801084d5:	55                   	push   %ebp
801084d6:	89 e5                	mov    %esp,%ebp
801084d8:	8b 45 08             	mov    0x8(%ebp),%eax
801084db:	05 00 00 00 80       	add    $0x80000000,%eax
801084e0:	5d                   	pop    %ebp
801084e1:	c3                   	ret    

801084e2 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801084e2:	55                   	push   %ebp
801084e3:	89 e5                	mov    %esp,%ebp
801084e5:	53                   	push   %ebx
801084e6:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801084e9:	e8 80 ab ff ff       	call   8010306e <cpunum>
801084ee:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801084f4:	05 80 33 11 80       	add    $0x80113380,%eax
801084f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801084fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ff:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108508:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010850e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108511:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108518:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010851c:	83 e2 f0             	and    $0xfffffff0,%edx
8010851f:	83 ca 0a             	or     $0xa,%edx
80108522:	88 50 7d             	mov    %dl,0x7d(%eax)
80108525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108528:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010852c:	83 ca 10             	or     $0x10,%edx
8010852f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108535:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108539:	83 e2 9f             	and    $0xffffff9f,%edx
8010853c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010853f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108542:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108546:	83 ca 80             	or     $0xffffff80,%edx
80108549:	88 50 7d             	mov    %dl,0x7d(%eax)
8010854c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108553:	83 ca 0f             	or     $0xf,%edx
80108556:	88 50 7e             	mov    %dl,0x7e(%eax)
80108559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108560:	83 e2 ef             	and    $0xffffffef,%edx
80108563:	88 50 7e             	mov    %dl,0x7e(%eax)
80108566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108569:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010856d:	83 e2 df             	and    $0xffffffdf,%edx
80108570:	88 50 7e             	mov    %dl,0x7e(%eax)
80108573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108576:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010857a:	83 ca 40             	or     $0x40,%edx
8010857d:	88 50 7e             	mov    %dl,0x7e(%eax)
80108580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108583:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108587:	83 ca 80             	or     $0xffffff80,%edx
8010858a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010858d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108590:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108597:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010859e:	ff ff 
801085a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a3:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801085aa:	00 00 
801085ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085af:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801085b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801085c0:	83 e2 f0             	and    $0xfffffff0,%edx
801085c3:	83 ca 02             	or     $0x2,%edx
801085c6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801085cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085cf:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801085d6:	83 ca 10             	or     $0x10,%edx
801085d9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801085df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801085e9:	83 e2 9f             	and    $0xffffff9f,%edx
801085ec:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801085f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801085fc:	83 ca 80             	or     $0xffffff80,%edx
801085ff:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108608:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010860f:	83 ca 0f             	or     $0xf,%edx
80108612:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108622:	83 e2 ef             	and    $0xffffffef,%edx
80108625:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010862b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108635:	83 e2 df             	and    $0xffffffdf,%edx
80108638:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010863e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108641:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108648:	83 ca 40             	or     $0x40,%edx
8010864b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108654:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010865b:	83 ca 80             	or     $0xffffff80,%edx
8010865e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108667:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010866e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108671:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108678:	ff ff 
8010867a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867d:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108684:	00 00 
80108686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108689:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108693:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010869a:	83 e2 f0             	and    $0xfffffff0,%edx
8010869d:	83 ca 0a             	or     $0xa,%edx
801086a0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801086b0:	83 ca 10             	or     $0x10,%edx
801086b3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086bc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801086c3:	83 ca 60             	or     $0x60,%edx
801086c6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cf:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801086d6:	83 ca 80             	or     $0xffffff80,%edx
801086d9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086e9:	83 ca 0f             	or     $0xf,%edx
801086ec:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086fc:	83 e2 ef             	and    $0xffffffef,%edx
801086ff:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108708:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010870f:	83 e2 df             	and    $0xffffffdf,%edx
80108712:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108722:	83 ca 40             	or     $0x40,%edx
80108725:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010872b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108735:	83 ca 80             	or     $0xffffff80,%edx
80108738:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010873e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108741:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874b:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108752:	ff ff 
80108754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108757:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
8010875e:	00 00 
80108760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108763:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010876a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108774:	83 e2 f0             	and    $0xfffffff0,%edx
80108777:	83 ca 02             	or     $0x2,%edx
8010877a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108783:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010878a:	83 ca 10             	or     $0x10,%edx
8010878d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108796:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010879d:	83 ca 60             	or     $0x60,%edx
801087a0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801087a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801087b0:	83 ca 80             	or     $0xffffff80,%edx
801087b3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801087b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bc:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087c3:	83 ca 0f             	or     $0xf,%edx
801087c6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801087cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cf:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087d6:	83 e2 ef             	and    $0xffffffef,%edx
801087d9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801087df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e2:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087e9:	83 e2 df             	and    $0xffffffdf,%edx
801087ec:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801087f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f5:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087fc:	83 ca 40             	or     $0x40,%edx
801087ff:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108808:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010880f:	83 ca 80             	or     $0xffffff80,%edx
80108812:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881b:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108825:	05 b4 00 00 00       	add    $0xb4,%eax
8010882a:	89 c3                	mov    %eax,%ebx
8010882c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882f:	05 b4 00 00 00       	add    $0xb4,%eax
80108834:	c1 e8 10             	shr    $0x10,%eax
80108837:	89 c2                	mov    %eax,%edx
80108839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883c:	05 b4 00 00 00       	add    $0xb4,%eax
80108841:	c1 e8 18             	shr    $0x18,%eax
80108844:	89 c1                	mov    %eax,%ecx
80108846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108849:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108850:	00 00 
80108852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108855:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010885c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885f:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108868:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010886f:	83 e2 f0             	and    $0xfffffff0,%edx
80108872:	83 ca 02             	or     $0x2,%edx
80108875:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010887b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108885:	83 ca 10             	or     $0x10,%edx
80108888:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010888e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108891:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108898:	83 e2 9f             	and    $0xffffff9f,%edx
8010889b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801088a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801088ab:	83 ca 80             	or     $0xffffff80,%edx
801088ae:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801088b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b7:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801088be:	83 e2 f0             	and    $0xfffffff0,%edx
801088c1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ca:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801088d1:	83 e2 ef             	and    $0xffffffef,%edx
801088d4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088dd:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801088e4:	83 e2 df             	and    $0xffffffdf,%edx
801088e7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f0:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801088f7:	83 ca 40             	or     $0x40,%edx
801088fa:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108903:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010890a:	83 ca 80             	or     $0xffffff80,%edx
8010890d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108916:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010891c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891f:	83 c0 70             	add    $0x70,%eax
80108922:	83 ec 08             	sub    $0x8,%esp
80108925:	6a 38                	push   $0x38
80108927:	50                   	push   %eax
80108928:	e8 38 fb ff ff       	call   80108465 <lgdt>
8010892d:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108930:	83 ec 0c             	sub    $0xc,%esp
80108933:	6a 18                	push   $0x18
80108935:	e8 6c fb ff ff       	call   801084a6 <loadgs>
8010893a:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
8010893d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108940:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108946:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010894d:	00 00 00 00 
}
80108951:	90                   	nop
80108952:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108955:	c9                   	leave  
80108956:	c3                   	ret    

80108957 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108957:	55                   	push   %ebp
80108958:	89 e5                	mov    %esp,%ebp
8010895a:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010895d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108960:	c1 e8 16             	shr    $0x16,%eax
80108963:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010896a:	8b 45 08             	mov    0x8(%ebp),%eax
8010896d:	01 d0                	add    %edx,%eax
8010896f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108972:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108975:	8b 00                	mov    (%eax),%eax
80108977:	83 e0 01             	and    $0x1,%eax
8010897a:	85 c0                	test   %eax,%eax
8010897c:	74 18                	je     80108996 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
8010897e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108981:	8b 00                	mov    (%eax),%eax
80108983:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108988:	50                   	push   %eax
80108989:	e8 47 fb ff ff       	call   801084d5 <p2v>
8010898e:	83 c4 04             	add    $0x4,%esp
80108991:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108994:	eb 48                	jmp    801089de <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108996:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010899a:	74 0e                	je     801089aa <walkpgdir+0x53>
8010899c:	e8 67 a3 ff ff       	call   80102d08 <kalloc>
801089a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801089a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801089a8:	75 07                	jne    801089b1 <walkpgdir+0x5a>
      return 0;
801089aa:	b8 00 00 00 00       	mov    $0x0,%eax
801089af:	eb 44                	jmp    801089f5 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801089b1:	83 ec 04             	sub    $0x4,%esp
801089b4:	68 00 10 00 00       	push   $0x1000
801089b9:	6a 00                	push   $0x0
801089bb:	ff 75 f4             	pushl  -0xc(%ebp)
801089be:	e8 ad d4 ff ff       	call   80105e70 <memset>
801089c3:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801089c6:	83 ec 0c             	sub    $0xc,%esp
801089c9:	ff 75 f4             	pushl  -0xc(%ebp)
801089cc:	e8 f7 fa ff ff       	call   801084c8 <v2p>
801089d1:	83 c4 10             	add    $0x10,%esp
801089d4:	83 c8 07             	or     $0x7,%eax
801089d7:	89 c2                	mov    %eax,%edx
801089d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089dc:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801089de:	8b 45 0c             	mov    0xc(%ebp),%eax
801089e1:	c1 e8 0c             	shr    $0xc,%eax
801089e4:	25 ff 03 00 00       	and    $0x3ff,%eax
801089e9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f3:	01 d0                	add    %edx,%eax
}
801089f5:	c9                   	leave  
801089f6:	c3                   	ret    

801089f7 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801089f7:	55                   	push   %ebp
801089f8:	89 e5                	mov    %esp,%ebp
801089fa:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
801089fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a00:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a05:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108a08:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a0b:	8b 45 10             	mov    0x10(%ebp),%eax
80108a0e:	01 d0                	add    %edx,%eax
80108a10:	83 e8 01             	sub    $0x1,%eax
80108a13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108a1b:	83 ec 04             	sub    $0x4,%esp
80108a1e:	6a 01                	push   $0x1
80108a20:	ff 75 f4             	pushl  -0xc(%ebp)
80108a23:	ff 75 08             	pushl  0x8(%ebp)
80108a26:	e8 2c ff ff ff       	call   80108957 <walkpgdir>
80108a2b:	83 c4 10             	add    $0x10,%esp
80108a2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a31:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a35:	75 07                	jne    80108a3e <mappages+0x47>
      return -1;
80108a37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a3c:	eb 47                	jmp    80108a85 <mappages+0x8e>
    if(*pte & PTE_P)
80108a3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a41:	8b 00                	mov    (%eax),%eax
80108a43:	83 e0 01             	and    $0x1,%eax
80108a46:	85 c0                	test   %eax,%eax
80108a48:	74 0d                	je     80108a57 <mappages+0x60>
      panic("remap");
80108a4a:	83 ec 0c             	sub    $0xc,%esp
80108a4d:	68 f4 99 10 80       	push   $0x801099f4
80108a52:	e8 0f 7b ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108a57:	8b 45 18             	mov    0x18(%ebp),%eax
80108a5a:	0b 45 14             	or     0x14(%ebp),%eax
80108a5d:	83 c8 01             	or     $0x1,%eax
80108a60:	89 c2                	mov    %eax,%edx
80108a62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a65:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108a6d:	74 10                	je     80108a7f <mappages+0x88>
      break;
    a += PGSIZE;
80108a6f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108a76:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108a7d:	eb 9c                	jmp    80108a1b <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108a7f:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108a80:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a85:	c9                   	leave  
80108a86:	c3                   	ret    

80108a87 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108a87:	55                   	push   %ebp
80108a88:	89 e5                	mov    %esp,%ebp
80108a8a:	53                   	push   %ebx
80108a8b:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108a8e:	e8 75 a2 ff ff       	call   80102d08 <kalloc>
80108a93:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a9a:	75 0a                	jne    80108aa6 <setupkvm+0x1f>
    return 0;
80108a9c:	b8 00 00 00 00       	mov    $0x0,%eax
80108aa1:	e9 8e 00 00 00       	jmp    80108b34 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108aa6:	83 ec 04             	sub    $0x4,%esp
80108aa9:	68 00 10 00 00       	push   $0x1000
80108aae:	6a 00                	push   $0x0
80108ab0:	ff 75 f0             	pushl  -0x10(%ebp)
80108ab3:	e8 b8 d3 ff ff       	call   80105e70 <memset>
80108ab8:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108abb:	83 ec 0c             	sub    $0xc,%esp
80108abe:	68 00 00 00 0e       	push   $0xe000000
80108ac3:	e8 0d fa ff ff       	call   801084d5 <p2v>
80108ac8:	83 c4 10             	add    $0x10,%esp
80108acb:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108ad0:	76 0d                	jbe    80108adf <setupkvm+0x58>
    panic("PHYSTOP too high");
80108ad2:	83 ec 0c             	sub    $0xc,%esp
80108ad5:	68 fa 99 10 80       	push   $0x801099fa
80108ada:	e8 87 7a ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108adf:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108ae6:	eb 40                	jmp    80108b28 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aeb:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af1:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af7:	8b 58 08             	mov    0x8(%eax),%ebx
80108afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108afd:	8b 40 04             	mov    0x4(%eax),%eax
80108b00:	29 c3                	sub    %eax,%ebx
80108b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b05:	8b 00                	mov    (%eax),%eax
80108b07:	83 ec 0c             	sub    $0xc,%esp
80108b0a:	51                   	push   %ecx
80108b0b:	52                   	push   %edx
80108b0c:	53                   	push   %ebx
80108b0d:	50                   	push   %eax
80108b0e:	ff 75 f0             	pushl  -0x10(%ebp)
80108b11:	e8 e1 fe ff ff       	call   801089f7 <mappages>
80108b16:	83 c4 20             	add    $0x20,%esp
80108b19:	85 c0                	test   %eax,%eax
80108b1b:	79 07                	jns    80108b24 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108b1d:	b8 00 00 00 00       	mov    $0x0,%eax
80108b22:	eb 10                	jmp    80108b34 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108b24:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108b28:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108b2f:	72 b7                	jb     80108ae8 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108b34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b37:	c9                   	leave  
80108b38:	c3                   	ret    

80108b39 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108b39:	55                   	push   %ebp
80108b3a:	89 e5                	mov    %esp,%ebp
80108b3c:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108b3f:	e8 43 ff ff ff       	call   80108a87 <setupkvm>
80108b44:	a3 38 67 11 80       	mov    %eax,0x80116738
  switchkvm();
80108b49:	e8 03 00 00 00       	call   80108b51 <switchkvm>
}
80108b4e:	90                   	nop
80108b4f:	c9                   	leave  
80108b50:	c3                   	ret    

80108b51 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108b51:	55                   	push   %ebp
80108b52:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108b54:	a1 38 67 11 80       	mov    0x80116738,%eax
80108b59:	50                   	push   %eax
80108b5a:	e8 69 f9 ff ff       	call   801084c8 <v2p>
80108b5f:	83 c4 04             	add    $0x4,%esp
80108b62:	50                   	push   %eax
80108b63:	e8 54 f9 ff ff       	call   801084bc <lcr3>
80108b68:	83 c4 04             	add    $0x4,%esp
}
80108b6b:	90                   	nop
80108b6c:	c9                   	leave  
80108b6d:	c3                   	ret    

80108b6e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108b6e:	55                   	push   %ebp
80108b6f:	89 e5                	mov    %esp,%ebp
80108b71:	56                   	push   %esi
80108b72:	53                   	push   %ebx
  pushcli();
80108b73:	e8 f2 d1 ff ff       	call   80105d6a <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108b78:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108b7e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108b85:	83 c2 08             	add    $0x8,%edx
80108b88:	89 d6                	mov    %edx,%esi
80108b8a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108b91:	83 c2 08             	add    $0x8,%edx
80108b94:	c1 ea 10             	shr    $0x10,%edx
80108b97:	89 d3                	mov    %edx,%ebx
80108b99:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108ba0:	83 c2 08             	add    $0x8,%edx
80108ba3:	c1 ea 18             	shr    $0x18,%edx
80108ba6:	89 d1                	mov    %edx,%ecx
80108ba8:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108baf:	67 00 
80108bb1:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108bb8:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108bbe:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108bc5:	83 e2 f0             	and    $0xfffffff0,%edx
80108bc8:	83 ca 09             	or     $0x9,%edx
80108bcb:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108bd1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108bd8:	83 ca 10             	or     $0x10,%edx
80108bdb:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108be1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108be8:	83 e2 9f             	and    $0xffffff9f,%edx
80108beb:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108bf1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108bf8:	83 ca 80             	or     $0xffffff80,%edx
80108bfb:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c01:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c08:	83 e2 f0             	and    $0xfffffff0,%edx
80108c0b:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108c11:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c18:	83 e2 ef             	and    $0xffffffef,%edx
80108c1b:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108c21:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c28:	83 e2 df             	and    $0xffffffdf,%edx
80108c2b:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108c31:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c38:	83 ca 40             	or     $0x40,%edx
80108c3b:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108c41:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c48:	83 e2 7f             	and    $0x7f,%edx
80108c4b:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108c51:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108c57:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c5d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c64:	83 e2 ef             	and    $0xffffffef,%edx
80108c67:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108c6d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c73:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108c79:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c7f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108c86:	8b 52 08             	mov    0x8(%edx),%edx
80108c89:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108c8f:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108c92:	83 ec 0c             	sub    $0xc,%esp
80108c95:	6a 30                	push   $0x30
80108c97:	e8 f3 f7 ff ff       	call   8010848f <ltr>
80108c9c:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca2:	8b 40 04             	mov    0x4(%eax),%eax
80108ca5:	85 c0                	test   %eax,%eax
80108ca7:	75 0d                	jne    80108cb6 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108ca9:	83 ec 0c             	sub    $0xc,%esp
80108cac:	68 0b 9a 10 80       	push   $0x80109a0b
80108cb1:	e8 b0 78 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80108cb9:	8b 40 04             	mov    0x4(%eax),%eax
80108cbc:	83 ec 0c             	sub    $0xc,%esp
80108cbf:	50                   	push   %eax
80108cc0:	e8 03 f8 ff ff       	call   801084c8 <v2p>
80108cc5:	83 c4 10             	add    $0x10,%esp
80108cc8:	83 ec 0c             	sub    $0xc,%esp
80108ccb:	50                   	push   %eax
80108ccc:	e8 eb f7 ff ff       	call   801084bc <lcr3>
80108cd1:	83 c4 10             	add    $0x10,%esp
  popcli();
80108cd4:	e8 d6 d0 ff ff       	call   80105daf <popcli>
}
80108cd9:	90                   	nop
80108cda:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108cdd:	5b                   	pop    %ebx
80108cde:	5e                   	pop    %esi
80108cdf:	5d                   	pop    %ebp
80108ce0:	c3                   	ret    

80108ce1 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108ce1:	55                   	push   %ebp
80108ce2:	89 e5                	mov    %esp,%ebp
80108ce4:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108ce7:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108cee:	76 0d                	jbe    80108cfd <inituvm+0x1c>
    panic("inituvm: more than a page");
80108cf0:	83 ec 0c             	sub    $0xc,%esp
80108cf3:	68 1f 9a 10 80       	push   $0x80109a1f
80108cf8:	e8 69 78 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108cfd:	e8 06 a0 ff ff       	call   80102d08 <kalloc>
80108d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108d05:	83 ec 04             	sub    $0x4,%esp
80108d08:	68 00 10 00 00       	push   $0x1000
80108d0d:	6a 00                	push   $0x0
80108d0f:	ff 75 f4             	pushl  -0xc(%ebp)
80108d12:	e8 59 d1 ff ff       	call   80105e70 <memset>
80108d17:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108d1a:	83 ec 0c             	sub    $0xc,%esp
80108d1d:	ff 75 f4             	pushl  -0xc(%ebp)
80108d20:	e8 a3 f7 ff ff       	call   801084c8 <v2p>
80108d25:	83 c4 10             	add    $0x10,%esp
80108d28:	83 ec 0c             	sub    $0xc,%esp
80108d2b:	6a 06                	push   $0x6
80108d2d:	50                   	push   %eax
80108d2e:	68 00 10 00 00       	push   $0x1000
80108d33:	6a 00                	push   $0x0
80108d35:	ff 75 08             	pushl  0x8(%ebp)
80108d38:	e8 ba fc ff ff       	call   801089f7 <mappages>
80108d3d:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108d40:	83 ec 04             	sub    $0x4,%esp
80108d43:	ff 75 10             	pushl  0x10(%ebp)
80108d46:	ff 75 0c             	pushl  0xc(%ebp)
80108d49:	ff 75 f4             	pushl  -0xc(%ebp)
80108d4c:	e8 de d1 ff ff       	call   80105f2f <memmove>
80108d51:	83 c4 10             	add    $0x10,%esp
}
80108d54:	90                   	nop
80108d55:	c9                   	leave  
80108d56:	c3                   	ret    

80108d57 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108d57:	55                   	push   %ebp
80108d58:	89 e5                	mov    %esp,%ebp
80108d5a:	53                   	push   %ebx
80108d5b:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d61:	25 ff 0f 00 00       	and    $0xfff,%eax
80108d66:	85 c0                	test   %eax,%eax
80108d68:	74 0d                	je     80108d77 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108d6a:	83 ec 0c             	sub    $0xc,%esp
80108d6d:	68 3c 9a 10 80       	push   $0x80109a3c
80108d72:	e8 ef 77 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108d77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d7e:	e9 95 00 00 00       	jmp    80108e18 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108d83:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d89:	01 d0                	add    %edx,%eax
80108d8b:	83 ec 04             	sub    $0x4,%esp
80108d8e:	6a 00                	push   $0x0
80108d90:	50                   	push   %eax
80108d91:	ff 75 08             	pushl  0x8(%ebp)
80108d94:	e8 be fb ff ff       	call   80108957 <walkpgdir>
80108d99:	83 c4 10             	add    $0x10,%esp
80108d9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d9f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108da3:	75 0d                	jne    80108db2 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108da5:	83 ec 0c             	sub    $0xc,%esp
80108da8:	68 5f 9a 10 80       	push   $0x80109a5f
80108dad:	e8 b4 77 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108db2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108db5:	8b 00                	mov    (%eax),%eax
80108db7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108dbc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108dbf:	8b 45 18             	mov    0x18(%ebp),%eax
80108dc2:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108dc5:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108dca:	77 0b                	ja     80108dd7 <loaduvm+0x80>
      n = sz - i;
80108dcc:	8b 45 18             	mov    0x18(%ebp),%eax
80108dcf:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108dd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108dd5:	eb 07                	jmp    80108dde <loaduvm+0x87>
    else
      n = PGSIZE;
80108dd7:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108dde:	8b 55 14             	mov    0x14(%ebp),%edx
80108de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de4:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108de7:	83 ec 0c             	sub    $0xc,%esp
80108dea:	ff 75 e8             	pushl  -0x18(%ebp)
80108ded:	e8 e3 f6 ff ff       	call   801084d5 <p2v>
80108df2:	83 c4 10             	add    $0x10,%esp
80108df5:	ff 75 f0             	pushl  -0x10(%ebp)
80108df8:	53                   	push   %ebx
80108df9:	50                   	push   %eax
80108dfa:	ff 75 10             	pushl  0x10(%ebp)
80108dfd:	e8 78 91 ff ff       	call   80101f7a <readi>
80108e02:	83 c4 10             	add    $0x10,%esp
80108e05:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108e08:	74 07                	je     80108e11 <loaduvm+0xba>
      return -1;
80108e0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e0f:	eb 18                	jmp    80108e29 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108e11:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e1b:	3b 45 18             	cmp    0x18(%ebp),%eax
80108e1e:	0f 82 5f ff ff ff    	jb     80108d83 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108e24:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e2c:	c9                   	leave  
80108e2d:	c3                   	ret    

80108e2e <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108e2e:	55                   	push   %ebp
80108e2f:	89 e5                	mov    %esp,%ebp
80108e31:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108e34:	8b 45 10             	mov    0x10(%ebp),%eax
80108e37:	85 c0                	test   %eax,%eax
80108e39:	79 0a                	jns    80108e45 <allocuvm+0x17>
    return 0;
80108e3b:	b8 00 00 00 00       	mov    $0x0,%eax
80108e40:	e9 b0 00 00 00       	jmp    80108ef5 <allocuvm+0xc7>
  if(newsz < oldsz)
80108e45:	8b 45 10             	mov    0x10(%ebp),%eax
80108e48:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e4b:	73 08                	jae    80108e55 <allocuvm+0x27>
    return oldsz;
80108e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e50:	e9 a0 00 00 00       	jmp    80108ef5 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108e55:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e58:	05 ff 0f 00 00       	add    $0xfff,%eax
80108e5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108e65:	eb 7f                	jmp    80108ee6 <allocuvm+0xb8>
    mem = kalloc();
80108e67:	e8 9c 9e ff ff       	call   80102d08 <kalloc>
80108e6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108e6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e73:	75 2b                	jne    80108ea0 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108e75:	83 ec 0c             	sub    $0xc,%esp
80108e78:	68 7d 9a 10 80       	push   $0x80109a7d
80108e7d:	e8 44 75 ff ff       	call   801003c6 <cprintf>
80108e82:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108e85:	83 ec 04             	sub    $0x4,%esp
80108e88:	ff 75 0c             	pushl  0xc(%ebp)
80108e8b:	ff 75 10             	pushl  0x10(%ebp)
80108e8e:	ff 75 08             	pushl  0x8(%ebp)
80108e91:	e8 61 00 00 00       	call   80108ef7 <deallocuvm>
80108e96:	83 c4 10             	add    $0x10,%esp
      return 0;
80108e99:	b8 00 00 00 00       	mov    $0x0,%eax
80108e9e:	eb 55                	jmp    80108ef5 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108ea0:	83 ec 04             	sub    $0x4,%esp
80108ea3:	68 00 10 00 00       	push   $0x1000
80108ea8:	6a 00                	push   $0x0
80108eaa:	ff 75 f0             	pushl  -0x10(%ebp)
80108ead:	e8 be cf ff ff       	call   80105e70 <memset>
80108eb2:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108eb5:	83 ec 0c             	sub    $0xc,%esp
80108eb8:	ff 75 f0             	pushl  -0x10(%ebp)
80108ebb:	e8 08 f6 ff ff       	call   801084c8 <v2p>
80108ec0:	83 c4 10             	add    $0x10,%esp
80108ec3:	89 c2                	mov    %eax,%edx
80108ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ec8:	83 ec 0c             	sub    $0xc,%esp
80108ecb:	6a 06                	push   $0x6
80108ecd:	52                   	push   %edx
80108ece:	68 00 10 00 00       	push   $0x1000
80108ed3:	50                   	push   %eax
80108ed4:	ff 75 08             	pushl  0x8(%ebp)
80108ed7:	e8 1b fb ff ff       	call   801089f7 <mappages>
80108edc:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108edf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee9:	3b 45 10             	cmp    0x10(%ebp),%eax
80108eec:	0f 82 75 ff ff ff    	jb     80108e67 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108ef2:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108ef5:	c9                   	leave  
80108ef6:	c3                   	ret    

80108ef7 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108ef7:	55                   	push   %ebp
80108ef8:	89 e5                	mov    %esp,%ebp
80108efa:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108efd:	8b 45 10             	mov    0x10(%ebp),%eax
80108f00:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f03:	72 08                	jb     80108f0d <deallocuvm+0x16>
    return oldsz;
80108f05:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f08:	e9 a5 00 00 00       	jmp    80108fb2 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108f0d:	8b 45 10             	mov    0x10(%ebp),%eax
80108f10:	05 ff 0f 00 00       	add    $0xfff,%eax
80108f15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108f1d:	e9 81 00 00 00       	jmp    80108fa3 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f25:	83 ec 04             	sub    $0x4,%esp
80108f28:	6a 00                	push   $0x0
80108f2a:	50                   	push   %eax
80108f2b:	ff 75 08             	pushl  0x8(%ebp)
80108f2e:	e8 24 fa ff ff       	call   80108957 <walkpgdir>
80108f33:	83 c4 10             	add    $0x10,%esp
80108f36:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108f39:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f3d:	75 09                	jne    80108f48 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108f3f:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108f46:	eb 54                	jmp    80108f9c <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f4b:	8b 00                	mov    (%eax),%eax
80108f4d:	83 e0 01             	and    $0x1,%eax
80108f50:	85 c0                	test   %eax,%eax
80108f52:	74 48                	je     80108f9c <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108f54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f57:	8b 00                	mov    (%eax),%eax
80108f59:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108f61:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f65:	75 0d                	jne    80108f74 <deallocuvm+0x7d>
        panic("kfree");
80108f67:	83 ec 0c             	sub    $0xc,%esp
80108f6a:	68 95 9a 10 80       	push   $0x80109a95
80108f6f:	e8 f2 75 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80108f74:	83 ec 0c             	sub    $0xc,%esp
80108f77:	ff 75 ec             	pushl  -0x14(%ebp)
80108f7a:	e8 56 f5 ff ff       	call   801084d5 <p2v>
80108f7f:	83 c4 10             	add    $0x10,%esp
80108f82:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108f85:	83 ec 0c             	sub    $0xc,%esp
80108f88:	ff 75 e8             	pushl  -0x18(%ebp)
80108f8b:	e8 db 9c ff ff       	call   80102c6b <kfree>
80108f90:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108f9c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108fa9:	0f 82 73 ff ff ff    	jb     80108f22 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108faf:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108fb2:	c9                   	leave  
80108fb3:	c3                   	ret    

80108fb4 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108fb4:	55                   	push   %ebp
80108fb5:	89 e5                	mov    %esp,%ebp
80108fb7:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108fba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108fbe:	75 0d                	jne    80108fcd <freevm+0x19>
    panic("freevm: no pgdir");
80108fc0:	83 ec 0c             	sub    $0xc,%esp
80108fc3:	68 9b 9a 10 80       	push   $0x80109a9b
80108fc8:	e8 99 75 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108fcd:	83 ec 04             	sub    $0x4,%esp
80108fd0:	6a 00                	push   $0x0
80108fd2:	68 00 00 00 80       	push   $0x80000000
80108fd7:	ff 75 08             	pushl  0x8(%ebp)
80108fda:	e8 18 ff ff ff       	call   80108ef7 <deallocuvm>
80108fdf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108fe2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108fe9:	eb 4f                	jmp    8010903a <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80108ff8:	01 d0                	add    %edx,%eax
80108ffa:	8b 00                	mov    (%eax),%eax
80108ffc:	83 e0 01             	and    $0x1,%eax
80108fff:	85 c0                	test   %eax,%eax
80109001:	74 33                	je     80109036 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109006:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010900d:	8b 45 08             	mov    0x8(%ebp),%eax
80109010:	01 d0                	add    %edx,%eax
80109012:	8b 00                	mov    (%eax),%eax
80109014:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109019:	83 ec 0c             	sub    $0xc,%esp
8010901c:	50                   	push   %eax
8010901d:	e8 b3 f4 ff ff       	call   801084d5 <p2v>
80109022:	83 c4 10             	add    $0x10,%esp
80109025:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109028:	83 ec 0c             	sub    $0xc,%esp
8010902b:	ff 75 f0             	pushl  -0x10(%ebp)
8010902e:	e8 38 9c ff ff       	call   80102c6b <kfree>
80109033:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109036:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010903a:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109041:	76 a8                	jbe    80108feb <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109043:	83 ec 0c             	sub    $0xc,%esp
80109046:	ff 75 08             	pushl  0x8(%ebp)
80109049:	e8 1d 9c ff ff       	call   80102c6b <kfree>
8010904e:	83 c4 10             	add    $0x10,%esp
}
80109051:	90                   	nop
80109052:	c9                   	leave  
80109053:	c3                   	ret    

80109054 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109054:	55                   	push   %ebp
80109055:	89 e5                	mov    %esp,%ebp
80109057:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010905a:	83 ec 04             	sub    $0x4,%esp
8010905d:	6a 00                	push   $0x0
8010905f:	ff 75 0c             	pushl  0xc(%ebp)
80109062:	ff 75 08             	pushl  0x8(%ebp)
80109065:	e8 ed f8 ff ff       	call   80108957 <walkpgdir>
8010906a:	83 c4 10             	add    $0x10,%esp
8010906d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109070:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109074:	75 0d                	jne    80109083 <clearpteu+0x2f>
    panic("clearpteu");
80109076:	83 ec 0c             	sub    $0xc,%esp
80109079:	68 ac 9a 10 80       	push   $0x80109aac
8010907e:	e8 e3 74 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109086:	8b 00                	mov    (%eax),%eax
80109088:	83 e0 fb             	and    $0xfffffffb,%eax
8010908b:	89 c2                	mov    %eax,%edx
8010908d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109090:	89 10                	mov    %edx,(%eax)
}
80109092:	90                   	nop
80109093:	c9                   	leave  
80109094:	c3                   	ret    

80109095 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109095:	55                   	push   %ebp
80109096:	89 e5                	mov    %esp,%ebp
80109098:	53                   	push   %ebx
80109099:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010909c:	e8 e6 f9 ff ff       	call   80108a87 <setupkvm>
801090a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801090a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801090a8:	75 0a                	jne    801090b4 <copyuvm+0x1f>
    return 0;
801090aa:	b8 00 00 00 00       	mov    $0x0,%eax
801090af:	e9 f8 00 00 00       	jmp    801091ac <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801090b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090bb:	e9 c4 00 00 00       	jmp    80109184 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801090c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c3:	83 ec 04             	sub    $0x4,%esp
801090c6:	6a 00                	push   $0x0
801090c8:	50                   	push   %eax
801090c9:	ff 75 08             	pushl  0x8(%ebp)
801090cc:	e8 86 f8 ff ff       	call   80108957 <walkpgdir>
801090d1:	83 c4 10             	add    $0x10,%esp
801090d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801090d7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801090db:	75 0d                	jne    801090ea <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801090dd:	83 ec 0c             	sub    $0xc,%esp
801090e0:	68 b6 9a 10 80       	push   $0x80109ab6
801090e5:	e8 7c 74 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
801090ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090ed:	8b 00                	mov    (%eax),%eax
801090ef:	83 e0 01             	and    $0x1,%eax
801090f2:	85 c0                	test   %eax,%eax
801090f4:	75 0d                	jne    80109103 <copyuvm+0x6e>
      panic("copyuvm: page not present");
801090f6:	83 ec 0c             	sub    $0xc,%esp
801090f9:	68 d0 9a 10 80       	push   $0x80109ad0
801090fe:	e8 63 74 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109103:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109106:	8b 00                	mov    (%eax),%eax
80109108:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010910d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109110:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109113:	8b 00                	mov    (%eax),%eax
80109115:	25 ff 0f 00 00       	and    $0xfff,%eax
8010911a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010911d:	e8 e6 9b ff ff       	call   80102d08 <kalloc>
80109122:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109125:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109129:	74 6a                	je     80109195 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010912b:	83 ec 0c             	sub    $0xc,%esp
8010912e:	ff 75 e8             	pushl  -0x18(%ebp)
80109131:	e8 9f f3 ff ff       	call   801084d5 <p2v>
80109136:	83 c4 10             	add    $0x10,%esp
80109139:	83 ec 04             	sub    $0x4,%esp
8010913c:	68 00 10 00 00       	push   $0x1000
80109141:	50                   	push   %eax
80109142:	ff 75 e0             	pushl  -0x20(%ebp)
80109145:	e8 e5 cd ff ff       	call   80105f2f <memmove>
8010914a:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010914d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109150:	83 ec 0c             	sub    $0xc,%esp
80109153:	ff 75 e0             	pushl  -0x20(%ebp)
80109156:	e8 6d f3 ff ff       	call   801084c8 <v2p>
8010915b:	83 c4 10             	add    $0x10,%esp
8010915e:	89 c2                	mov    %eax,%edx
80109160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109163:	83 ec 0c             	sub    $0xc,%esp
80109166:	53                   	push   %ebx
80109167:	52                   	push   %edx
80109168:	68 00 10 00 00       	push   $0x1000
8010916d:	50                   	push   %eax
8010916e:	ff 75 f0             	pushl  -0x10(%ebp)
80109171:	e8 81 f8 ff ff       	call   801089f7 <mappages>
80109176:	83 c4 20             	add    $0x20,%esp
80109179:	85 c0                	test   %eax,%eax
8010917b:	78 1b                	js     80109198 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010917d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109187:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010918a:	0f 82 30 ff ff ff    	jb     801090c0 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109190:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109193:	eb 17                	jmp    801091ac <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109195:	90                   	nop
80109196:	eb 01                	jmp    80109199 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109198:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109199:	83 ec 0c             	sub    $0xc,%esp
8010919c:	ff 75 f0             	pushl  -0x10(%ebp)
8010919f:	e8 10 fe ff ff       	call   80108fb4 <freevm>
801091a4:	83 c4 10             	add    $0x10,%esp
  return 0;
801091a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801091ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801091af:	c9                   	leave  
801091b0:	c3                   	ret    

801091b1 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801091b1:	55                   	push   %ebp
801091b2:	89 e5                	mov    %esp,%ebp
801091b4:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801091b7:	83 ec 04             	sub    $0x4,%esp
801091ba:	6a 00                	push   $0x0
801091bc:	ff 75 0c             	pushl  0xc(%ebp)
801091bf:	ff 75 08             	pushl  0x8(%ebp)
801091c2:	e8 90 f7 ff ff       	call   80108957 <walkpgdir>
801091c7:	83 c4 10             	add    $0x10,%esp
801091ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801091cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d0:	8b 00                	mov    (%eax),%eax
801091d2:	83 e0 01             	and    $0x1,%eax
801091d5:	85 c0                	test   %eax,%eax
801091d7:	75 07                	jne    801091e0 <uva2ka+0x2f>
    return 0;
801091d9:	b8 00 00 00 00       	mov    $0x0,%eax
801091de:	eb 29                	jmp    80109209 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801091e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e3:	8b 00                	mov    (%eax),%eax
801091e5:	83 e0 04             	and    $0x4,%eax
801091e8:	85 c0                	test   %eax,%eax
801091ea:	75 07                	jne    801091f3 <uva2ka+0x42>
    return 0;
801091ec:	b8 00 00 00 00       	mov    $0x0,%eax
801091f1:	eb 16                	jmp    80109209 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801091f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f6:	8b 00                	mov    (%eax),%eax
801091f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091fd:	83 ec 0c             	sub    $0xc,%esp
80109200:	50                   	push   %eax
80109201:	e8 cf f2 ff ff       	call   801084d5 <p2v>
80109206:	83 c4 10             	add    $0x10,%esp
}
80109209:	c9                   	leave  
8010920a:	c3                   	ret    

8010920b <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010920b:	55                   	push   %ebp
8010920c:	89 e5                	mov    %esp,%ebp
8010920e:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109211:	8b 45 10             	mov    0x10(%ebp),%eax
80109214:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109217:	eb 7f                	jmp    80109298 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109219:	8b 45 0c             	mov    0xc(%ebp),%eax
8010921c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109221:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109224:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109227:	83 ec 08             	sub    $0x8,%esp
8010922a:	50                   	push   %eax
8010922b:	ff 75 08             	pushl  0x8(%ebp)
8010922e:	e8 7e ff ff ff       	call   801091b1 <uva2ka>
80109233:	83 c4 10             	add    $0x10,%esp
80109236:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109239:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010923d:	75 07                	jne    80109246 <copyout+0x3b>
      return -1;
8010923f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109244:	eb 61                	jmp    801092a7 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109246:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109249:	2b 45 0c             	sub    0xc(%ebp),%eax
8010924c:	05 00 10 00 00       	add    $0x1000,%eax
80109251:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109254:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109257:	3b 45 14             	cmp    0x14(%ebp),%eax
8010925a:	76 06                	jbe    80109262 <copyout+0x57>
      n = len;
8010925c:	8b 45 14             	mov    0x14(%ebp),%eax
8010925f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109262:	8b 45 0c             	mov    0xc(%ebp),%eax
80109265:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109268:	89 c2                	mov    %eax,%edx
8010926a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010926d:	01 d0                	add    %edx,%eax
8010926f:	83 ec 04             	sub    $0x4,%esp
80109272:	ff 75 f0             	pushl  -0x10(%ebp)
80109275:	ff 75 f4             	pushl  -0xc(%ebp)
80109278:	50                   	push   %eax
80109279:	e8 b1 cc ff ff       	call   80105f2f <memmove>
8010927e:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109281:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109284:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109287:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010928a:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010928d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109290:	05 00 10 00 00       	add    $0x1000,%eax
80109295:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109298:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010929c:	0f 85 77 ff ff ff    	jne    80109219 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801092a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801092a7:	c9                   	leave  
801092a8:	c3                   	ret    
