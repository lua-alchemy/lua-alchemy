/* lua-alchemy.h -- common Lua Alchemy header
 */
#ifndef LUA_ALCHEMY_H_
#define LUA_ALCHEMY_H_

typedef unsigned char BOOL;
#define TRUE (1)
#define FALSE (0)

/* Uncomment this to get a lot of debug traces */
/*
#define DO_SPAM 1
*/

#ifdef DO_SPAM
  #define SPAM(a) sztrace a
#else
  #define SPAM(a) (void)0
#endif /* DO_SPAM */

void sztrace(char *);

#endif /* LUA_ALCHEMY_H_ */
