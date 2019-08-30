#include <sys/param.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <sys/file.h>
#include <sys/ioctl.h>

#include <netinet/in_systm.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <netinet/udp.h>

#include <arpa/inet.h>

#include <netdb.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h>

#include "common.h"

#define MAXPACKET    65535 // max ip packet size
#ifndef MAXHOSTNAMELEN
#define MAXHOSTNAMELEN    64
#endif

#ifndef FD_SET
#define NFDBITS         (8*sizeof(fd_set))
#define FD_SETSIZE      NFDBITS
#define FD_SET(n, p)    ((p)->fds_bits[(n)/NFDBITS] |= (1 << ((n) % NFDBITS)))
#define FD_CLR(n, p)    ((p)->fds_bits[(n)/NFDBITS] &= ~(1 << ((n) % NFDBITS)))
#define FD_ISSET(n, p)  ((p)->fds_bits[(n)/NFDBITS] & (1 << ((n) % NFDBITS)))
#define FD_ZERO(p)      bzero((char *)(p), sizeof(*(p)))
#endif

// format of a (udp) probe packet.
struct opacket {
    struct ip ip;
    struct udphdr udp;
    u_char seq; // sequence number of this packet
    u_char ttl; // ttl packet left with
    struct timeval tv; // time packet left
};

static u_char packet[512]; // last inbound (icmp) packet
static struct opacket* outpacket; // last output (udp) packet

static char* pr_type(u_char);
static long wait_for_reply(int, struct sockaddr_in*);
static void send_probe(int, int);
static double deltaT(struct timeval*, struct timeval*);
static int packet_ok(u_char*, long, struct sockaddr_in*, int);
static void tvsub(register struct timeval*, register struct timeval*);
static char * inetname(struct in_addr);
int start_trace_route(const int, char**, char*, char*, void (^call)(char*, char*));
static void print_host(u_char*, long, struct sockaddr_in*);
static u_short in_cksum(u_short*, int);
