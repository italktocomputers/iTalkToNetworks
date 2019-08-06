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

#define MAXPACKET    65535    /* max ip packet size */
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

#define Fprintf (void)fprintf
#define Sprintf (void)sprintf
#define Printf (void)printf

/*
 * format of a (udp) probe packet.
 */
struct opacket {
    struct ip ip;
    struct udphdr udp;
    u_char seq;        /* sequence number of this packet */
    u_char ttl;        /* ttl packet left with */
    struct timeval tv;    /* time packet left */
};

u_char    packet[512];        /* last inbound (icmp) packet */
struct opacket    *outpacket;    /* last output (udp) packet */

char* pr_type(u_char t);
int wait_for_reply(int sock, struct sockaddr_in *from);
void send_probe(int seq, int ttl, char* response);
double deltaT(struct timeval* t1p, struct timeval* t2p);
int packet_ok(u_char *buf, int cc, struct sockaddr_in* from, int seq, char* response);
void tvsub(register struct timeval *out, register struct timeval *in);
char * inetname(struct in_addr in);
int start_trace_route(const int, char**, char*);
void print(u_char *buf, int cc, struct sockaddr_in *from, char* response);
void fprint2(char* res, char* fmt, ...);
u_short in_cksum(u_short *addr, int len);
