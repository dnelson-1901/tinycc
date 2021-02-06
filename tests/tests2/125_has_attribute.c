/* check that __has_attribute works */
#if defined __has_attribute
#define HAS_HAS_ATTRIBUTE 1
#else
#define HAS_HAS_ATTRIBUTE 0
#endif
#if __has_attribute(__section__)
#define HAS_KNOWN_ATTRIBUTE 1
#else
#define HAS_KNOWN_ATTRIBUTE 0
#endif
#if __has_attribute(__not_an_attribute__)
#define HAS_UNKNOWN_ATTRIBUTE 1
#else
#define HAS_UNKNOWN_ATTRIBUTE 0
#endif

#include <stdio.h>

int main(void)
{
  printf ("h_h_a=%d h_k_a=%d h_u_a=%d\n", 
    HAS_HAS_ATTRIBUTE, HAS_KNOWN_ATTRIBUTE, HAS_UNKNOWN_ATTRIBUTE);
}
