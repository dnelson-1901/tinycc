/* check that __has_builtin works */
#if defined __has_builtin
#define HAS_HAS_BUILTIN 1
#else
#define HAS_HAS_BUILTIN 0
#endif
#if __has_builtin(__builtin_return_address)
#define HAS_KNOWN_BUILTIN 1
#else
#define HAS_KNOWN_BUILTIN 0
#endif
#if __has_builtin(__not_a_builtin)
#define HAS_UNKNOWN_BUILTIN 1
#else
#define HAS_UNKNOWN_BUILTIN 0
#endif

#include <stdio.h>

int main(void)
{
  printf ("h_b_b=%d h_k_b=%d h_u_b=%d\n", 
    HAS_HAS_BUILTIN, HAS_KNOWN_BUILTIN, HAS_UNKNOWN_BUILTIN);
}
