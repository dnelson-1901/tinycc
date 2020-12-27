#include <stdio.h>

struct big_struct { char a[262144]; };

static const char str[] = "abcdefghijklmnopqrstuvwxyz";

void tst_branch(void)
{
  printf("tst_branch --");
  goto *&&a; 
  printf (" dummy");
a: ;
  printf(" --\n");
}

void tst_void_ptr(void *pv, int i) 
{
  i ? *pv : *pv; // dr106
}

void tst_shift(void)
{
  int i = 1;
  long long l = 1;
  i = i << 32; // illegal. just test
  l = l << 64; // illegal. just test
}

#if !defined(_WIN32)
#include <sys/mman.h>

void tst_const_addr(void)
{
  void *addr = mmap ((void *)0x20000000, 4096, PROT_READ | PROT_WRITE, MAP_FIXED | MAP_ANONYMOUS, -1, 0);
  if (addr != (void *) -1) {
#if !defined(__riscv)
    *(int *)0x20000000 += 42;
#endif
    munmap (addr, 4096);
  }
}
#endif

struct zero_struct {};

struct zero_struct tst_zero_struct(void)
{
  struct zero_struct ret;
  return ret;
}

struct big_struct tst_big(struct big_struct tst)
{
   return tst;
}

void tst_adr (int (*fp)(char *, const char *, ...))
{
  char buf[10];
  (*fp)(buf, "%.0f", 5.0);
  printf("tst_adr %s\n", buf);
}

int tst(void)
{
  long long value = 3;
  return -value;
}

void tst_compare(void)
{
  /* This failed on risc64 */
  printf ("tst_compare: %s\n", tst() > 0 ? "error" : "ok");
}

/* try all the #pragma pack variants */
#pragma pack(push)
#pragma pack(1)
#pragma pack(push,2)
struct S2 { int d:24; int f:14; } i2, j2;
#pragma pack(pop)
struct S1 { int d:24; int f:14; } i1, j1;
#pragma pack()
#pragma pack(pop)

void tst_pack (void)
{
  i1.f = 5; j1.f = 5;
  i2.f = 5; j2.f = 5;
  printf("tst_pack1: size=%zd, j1.f = %d, i1.f = %d\n",
    sizeof(i1), j1.f, i1.f);
  printf("tst_pack2: size=%zd, j2.f = %d, i2.f = %d\n",
    sizeof(i2), j2.f, i2.f);
}

void tst_cast(void)
{
  signed char c = (signed char) 0xaaaaaaaa;
  int r = (unsigned short) c ^ (signed char) 0x99999999;
  printf ("schar to ushort cast: %x\n", r);
}

int
main (void)
{
  struct big_struct big;

  tst_branch();
  tst_shift();
  tst_void_ptr(&big.a[0], 0);
#if !defined(_WIN32)
  tst_const_addr();
#endif
  tst_zero_struct();
  tst_big(big);
  tst_adr(&sprintf);
  tst_compare();
  tst_pack();
  tst_cast();
}
