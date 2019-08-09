#include <sys/param.h> // NB: we rely on this for <sys/types.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <sys/time.h>
#include <sys/uio.h>

#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <netinet/ip_var.h>
#include <arpa/inet.h>
#include <net/if.h>

#ifdef IPSEC
#include <netinet6/ipsec.h>
#endif //IPSEC

#include <ctype.h>
#include <err.h>
#include <errno.h>
#include <math.h>
#include <netdb.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>
#include <unistd.h>
#include <stdarg.h>
#include <stdbool.h> 

#define    INADDR_LEN    ((int)sizeof(in_addr_t))
#define    TIMEVAL_LEN    ((int)sizeof(struct tv32))
#define    MASK_LEN    (ICMP_MASKLEN - ICMP_MINLEN)
#define    TS_LEN        (ICMP_TSLEN - ICMP_MINLEN)
#define    DEFDATALEN    56 // default data length
#define    FLOOD_BACKOFF    20000 // usecs to back off if F_FLOOD mode
//runs out of buffer space
#define    MAXIPLEN    (sizeof(struct ip) + MAX_IPOPTLEN)
#define    MAXICMPLEN    (ICMP_ADVLENMIN + MAX_IPOPTLEN)
#define    MAXWAIT        10000 // max ms to wait for response
#define    MAXALARM    (60 * 60) // max seconds for alarm timeout
#define    MAXTOS        255

#define    A(bit)        rcvd_tbl[(bit)>>3] // identify byte in array
#define    B(bit)        (1 << ((bit) & 0x07)) // identify bit in byte
#define    SET(bit)    (A(bit) |= B(bit))
#define    CLR(bit)    (A(bit) &= (~B(bit)))
#define    TST(bit)    (A(bit) & B(bit))

struct tv32 {
    u_int32_t tv32_sec;
    u_int32_t tv32_usec;
};

// various options
int options;
#define    F_FLOOD        0x0001
#define    F_INTERVAL    0x0002
#define    F_NUMERIC    0x0004
#define    F_PINGFILLED    0x0008
#define    F_QUIET        0x0010
#define    F_RROUTE    0x0020
#define    F_SO_DEBUG    0x0040
#define    F_SO_DONTROUTE    0x0080
#define    F_VERBOSE    0x0100
#define    F_QUIET2    0x0200
#define    F_NOLOOP    0x0400
#define    F_MTTL        0x0800
#define    F_MIF        0x1000
#define    F_AUDIBLE    0x2000
#ifdef IPSEC
#ifdef IPSEC_POLICY_IPSEC
#define F_POLICY    0x4000
#endif // IPSEC_POLICY_IPSEC
#endif // IPSEC
#define    F_TTL        0x8000
#define    F_MISSED    0x10000
#define    F_ONCE        0x20000
#define    F_HDRINCL    0x40000
#define    F_MASK        0x80000
#define    F_TIME        0x100000
#define    F_SWEEP        0x200000
#define    F_WAITTIME    0x400000

// MAX_DUP_CHK is the number of bits in received table, i.e. the maximum
// number of received sequence numbers we can keep track of.  Change 128
// to 8192 for complete accuracy...
#define    MAX_DUP_CHK    (8 * 128)

static int fill(char*, char*, char* response);
static u_short in_cksum(u_short*, int);
static void check_status(char* response);
static int finish(char* response);
static void pinger(void);
static char *pr_addr(struct in_addr, char* response);
static char *pr_ntime(n_time, char* response);
static void pr_icmph(struct icmp*, char* response);
static void pr_iph(struct ip*, char* response);
static void pr_pack(char*, int, struct sockaddr_in*, struct timeval*, char* response);
static void pr_retip(struct ip*, char* response);
static void status(int);
static void stopit(int);
static void tvsub(struct timeval*, struct timeval*);
int start_ping(int, char**, char*, void (^c)(char*), bool*);
static void to_res(char*, char*, ...);
