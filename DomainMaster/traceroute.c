//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

/*
 * Copyright (c) 1999 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * "Portions Copyright (c) 1999 Apple Computer, Inc.  All Rights
 * Reserved.  This file contains Original Code and/or Modifications of
 * Original Code as defined in and that are subject to the Apple Public
 * Source License Version 1.0 (the 'License').  You may not use this file
 * except in compliance with the License.  Please obtain a copy of the
 * License at http://www.apple.com/publicsource and read it before using
 * this file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT.  Please see the
 * License for the specific language governing rights and limitations
 * under the License."
 *
 * @APPLE_LICENSE_HEADER_END@
 */
/*-
 * Copyright (c) 1990, 1993
 *    The Regents of the University of California.  All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Van Jacobson.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *    This product includes software developed by the University of
 *    California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "traceroute.h"

int s; // receive (icmp) socket file descriptor
int sndsock; // send (udp) socket file descriptor
struct timezone tz; // leftover
struct sockaddr whereto; // who to try to reach
int datalen; // how much data
char *source = 0;
char *hostname;
int nprobes = 3;
int max_ttl = 30;
u_short ident;
u_short port = 32768+666; // start udp dest port # for probe packets
int options; // socket options
int verbose;
int waittime = 5; // time to wait for response (in seconds)
int nflag; // print addresses numerically

int start_trace_route(int argc, char* argv[], char* response) {
    extern char *optarg;
    extern int optind;
    struct hostent *hp;
    struct protoent *pe;
    struct sockaddr_in from, *to;
    int ch, i, on, probe, seq, tos, ttl;

    on = 1;
    seq = tos = 0;
    to = (struct sockaddr_in *)&whereto;

    while ((ch = getopt(argc, argv, "dm:np:q:rs:t:w:v")) != EOF) {
        switch(ch) {
            case 'd':
                options |= SO_DEBUG;
                break;
            case 'm':
                max_ttl = atoi(optarg);
                if (max_ttl <= 1) {
                    strcat(response, "traceroute: max ttl must be >1.\n");
                    return 1;
                }
                break;
            case 'n':
                nflag++;
                break;
            case 'p':
                port = atoi(optarg);
                if (port < 1) {
                    strcat(response, "traceroute: port must be >0.\n");
                    return 1;
                }
                break;
            case 'q':
                nprobes = atoi(optarg);
                if (nprobes < 1) {
                    strcat(response, "traceroute: nprobes must be >0.\n");
                    return 1;
                }
                break;
            case 'r':
                options |= SO_DONTROUTE;
                break;
            case 's':
                // set the ip source address of the outbound probe (e.g., on a multi-homed host).
                source = optarg;
                break;
            case 't':
                tos = atoi(optarg);
                if (tos < 0 || tos > 255) {
                    strcat(response, "traceroute: tos must be 0 to 255.\n");
                    return 1;
                }
                break;
            case 'v':
                verbose++;
                break;
            case 'w':
                waittime = atoi(optarg);
                if (waittime <= 1) {
                    strcat(response, "traceroute: wait must be >1 sec.\n");
                    return 1;
                }
                break;
            default:
                strcat(response, "traceroute: wrong parameters\n");
                return 1;
        }
    }

    argc -= optind;
    argv += optind;

    if (argc < 1) {
        strcat(response, "traceroute: wait must be >1 sec.\n");
        return 1;
    }

    setlinebuf (stdout);

    (void) bzero((char *)&whereto, sizeof(struct sockaddr));
    to->sin_family = AF_INET;
    to->sin_addr.s_addr = inet_addr(*argv);

    if (to->sin_addr.s_addr != -1) {
        hostname = *argv;
    }
    else {
        hp = gethostbyname(*argv);

        if (hp) {
            to->sin_family = hp->h_addrtype;
            bcopy(hp->h_addr, (caddr_t)&to->sin_addr, hp->h_length);
            hostname = hp->h_name;
        } else {
            fprint2(response, "traceroute: unknown host %s\n", *argv);
            return 1;
        }
    }

    if (*++argv) {
        datalen = atoi(*argv);
    }

    if (datalen < 0 || datalen >= MAXPACKET - sizeof(struct opacket)) {
        fprint2(response, "traceroute: packet size must be 0 <= s < %ld.\n", MAXPACKET - sizeof(struct opacket));
        return 1;
    }

    datalen += sizeof(struct opacket);
    outpacket = (struct opacket *)malloc((unsigned)datalen);

    if (! outpacket) {
        perror("traceroute: malloc");
        return 1;
    }

    (void) bzero((char *)outpacket, datalen);
    outpacket->ip.ip_dst = to->sin_addr;
    outpacket->ip.ip_tos = tos;
    outpacket->ip.ip_v = IPVERSION;
    outpacket->ip.ip_id = 0;

    ident = (getpid() & 0xffff) | 0x8000;

    if ((pe = getprotobyname("icmp")) == NULL) {
        strcat(response, "icmp: unknown protocol\n");
        return 10;
    }

    if ((s = socket(AF_INET, SOCK_RAW, pe->p_proto)) < 0) {
        perror("traceroute: icmp socket");
        return 5;
    }

    if (options & SO_DEBUG) {
        (void) setsockopt(s, SOL_SOCKET, SO_DEBUG, (char *)&on, sizeof(on));
    }

    if (options & SO_DONTROUTE) {
        (void) setsockopt(s, SOL_SOCKET, SO_DONTROUTE, (char *)&on, sizeof(on));
    }

    if ((sndsock = socket(AF_INET, SOCK_RAW, IPPROTO_RAW)) < 0) {
        perror("traceroute: raw socket");
        return 5;
    }

    #ifdef SO_SNDBUF
    if (setsockopt(sndsock, SOL_SOCKET, SO_SNDBUF, (char *)&datalen, sizeof(datalen)) < 0) {
        perror("traceroute: SO_SNDBUF");
        return 6;
    }
    #endif //SO_SNDBUF

    #ifdef IP_HDRINCL
    if (setsockopt(sndsock, IPPROTO_IP, IP_HDRINCL, (char *)&on, sizeof(on)) < 0) {
        perror("traceroute: IP_HDRINCL");
        return 6;
    }
    #endif //IP_HDRINCL

    if (options & SO_DEBUG) {
        (void) setsockopt(sndsock, SOL_SOCKET, SO_DEBUG, (char *)&on, sizeof(on));
    }

    if (options & SO_DONTROUTE) {
        (void) setsockopt(sndsock, SOL_SOCKET, SO_DONTROUTE, (char *)&on, sizeof(on));
    }

    if (source) {
        (void) bzero((char *)&from, sizeof(struct sockaddr));
        from.sin_family = AF_INET;
        from.sin_addr.s_addr = inet_addr(source);

        if (from.sin_addr.s_addr == -1) {
            fprint2(response, "traceroute: unknown host %s\n", source);
            return 1;
        }

        outpacket->ip.ip_src = from.sin_addr;

        #ifndef IP_HDRINCL
        if (bind(sndsock, (struct sockaddr *)&from, sizeof(from)) < 0) {
            perror ("traceroute: bind:");
            return 1;
        }
        #endif //IP_HDRINCL
    }

    Fprintf(stderr, "traceroute to %s (%s)", hostname, inet_ntoa(to->sin_addr));

    if (source) {
        fprint2(response, " from %s", source);
    }

    fprint2(response, ", %d hops max, %d byte packets\n", max_ttl, datalen);

    (void) fflush(stderr);

    for (ttl = 1; ttl <= max_ttl; ++ttl) {
        u_long lastaddr = 0;
        int got_there = 0;
        int unreachable = 0;

        fprint2(response, "%2d ", ttl);

        for (probe = 0; probe < nprobes; ++probe) {
            int cc;
            struct timeval t1, t2;
            struct timezone tz;
            struct ip *ip;

            (void) gettimeofday(&t1, &tz);
            send_probe(++seq, ttl, response);

            while (cc = wait_for_reply(s, &from)) {
                (void) gettimeofday(&t2, &tz);

                if ((i = packet_ok(packet, cc, &from, seq, response))) {
                    if (from.sin_addr.s_addr != lastaddr) {
                        print(packet, cc, &from, response);
                        lastaddr = from.sin_addr.s_addr;
                    }
                    
                    fprint2(response, "  %g ms", deltaT(&t1, &t2));

                    switch(i-1) {
                        case ICMP_UNREACH_PORT:
                            #ifndef ARCHAIC
                            ip = (struct ip *)packet;
                            if (ip->ip_ttl <= 1)
                                strcat(response, " !");
                            #endif //ARCHAIC
                            ++got_there;
                            break;
                        case ICMP_UNREACH_NET:
                            ++unreachable;
                            strcat(response, " !N");
                            break;
                        case ICMP_UNREACH_HOST:
                            ++unreachable;
                            strcat(response, " !H");
                            break;
                        case ICMP_UNREACH_PROTOCOL:
                            ++got_there;
                            strcat(response, " !P");
                            break;
                        case ICMP_UNREACH_NEEDFRAG:
                            ++unreachable;
                            strcat(response, " !F");
                            break;
                        case ICMP_UNREACH_SRCFAIL:
                            ++unreachable;
                            strcat(response, " !S");
                            break;
                    }
                    break;
                }
            }

            if (cc == 0) {
                strcat(response, " N/A");
            }

            (void) fflush(stdout);
        }
        
        strcat(response, "|");
    }

    return 0;
}

int wait_for_reply(int sock, struct sockaddr_in *from) {
    fd_set fds;
    struct timeval wait;
    int cc = 0;
    int fromlen = sizeof (*from);

    FD_ZERO(&fds);
    FD_SET(sock, &fds);
    wait.tv_sec = waittime; wait.tv_usec = 0;

    if (select(sock+1, &fds, (fd_set *)0, (fd_set *)0, &wait) > 0) {
        cc=recvfrom(s, (char *)packet, sizeof(packet), 0, (struct sockaddr *)from, &fromlen);
    }

    return(cc);
}

void send_probe(int seq, int ttl, char* response) {
    struct opacket *op = outpacket;
    struct ip *ip = &op->ip;
    struct udphdr *up = &op->udp;
    int i;

    ip->ip_off = 0;
    ip->ip_hl = sizeof(*ip) >> 2;
    ip->ip_p = IPPROTO_UDP;
    ip->ip_len = datalen;
    ip->ip_ttl = ttl;
    ip->ip_v = IPVERSION;
    ip->ip_id = htons(ident+seq);

    up->uh_sport = htons(ident);
    up->uh_dport = htons(port+seq);
    up->uh_ulen = htons((u_short)(datalen - sizeof(struct ip)));
    up->uh_sum = 0;

    op->seq = seq;
    op->ttl = ttl;
    (void) gettimeofday(&op->tv, &tz);

    i = sendto(sndsock, (char *)outpacket, datalen, 0, &whereto, sizeof(struct sockaddr));

    if (i < 0 || i != datalen)  {
        if (i<0) {
            perror("sendto");
        }

        fprint2(response, "traceroute: wrote %s %d chars, ret=%d\n", hostname, datalen, i);
        (void) fflush(stdout);
    }
}


double deltaT(struct timeval* t1p, struct timeval* t2p) {
    register double dt;
    dt = (double)(t2p->tv_sec - t1p->tv_sec) * 1000.0 +
    (double)(t2p->tv_usec - t1p->tv_usec) / 1000.0;
    return (dt);
}


// Convert an ICMP "type" field to a printable string.
char* pr_type(u_char t) {
    static char *ttab[] = {
        "Echo Reply",
        "ICMP 1",
        "ICMP 2",
        "Dest Unreachable",
        "Source Quench",
        "Redirect",
        "ICMP 6",
        "ICMP 7",
        "Echo",
        "ICMP 9",
        "ICMP 10",
        "Time Exceeded",
        "Param Problem",
        "Timestamp",
        "Timestamp Reply",
        "Info Request",
        "Info Reply"
    };

    if(t > 16)
        return("OUT-OF-RANGE");

    return(ttab[t]);
}


int packet_ok(u_char *buf, int cc, struct sockaddr_in* from, int seq, char* response) {
    register struct icmp *icp;
    u_char type, code;
    int hlen;
    #ifndef ARCHAIC
    struct ip *ip;

    ip = (struct ip *) buf;
    hlen = ip->ip_hl << 2;

    if (cc < hlen + ICMP_MINLEN) {
        if (verbose) {
            fprint2(response, "packet too short (%d bytes) from %s\n", cc, inet_ntoa(from->sin_addr));
        }
        return (0);
    }

    cc -= hlen;
    icp = (struct icmp *)(buf + hlen);
    #else
    icp = (struct icmp *)buf;
    #endif //ARCHAIC

    type = icp->icmp_type; code = icp->icmp_code;

    if ((type == ICMP_TIMXCEED && code == ICMP_TIMXCEED_INTRANS) || type == ICMP_UNREACH) {
        struct ip *hip;
        struct udphdr *up;

        hip = &icp->icmp_ip;
        hlen = hip->ip_hl << 2;
        up = (struct udphdr *)((u_char *)hip + hlen);

        if (hlen + 12 <= cc && hip->ip_p == IPPROTO_UDP && up->uh_sport == htons(ident) && up->uh_dport == htons(port+seq))
            return (type == ICMP_TIMXCEED? -1 : code+1);
    }

    #ifndef ARCHAIC
    if (verbose) {
        int i;
        u_long *lp = (u_long *)&icp->icmp_ip;

        fprint2(response, "\n%d bytes from %s to %s", cc, inet_ntoa(from->sin_addr), inet_ntoa(ip->ip_dst));
        fprint2(response, ": icmp type %d (%s) code %d\n", type, pr_type(type), icp->icmp_code);
        for (i = 4; i < cc ; i += sizeof(long))
            fprint2(response, "%2d: x%8.8lx\n", i, *lp++);
    }
    #endif //ARCHAIC

    return(0);
}

void print(u_char *buf, int cc, struct sockaddr_in *from, char* response) {
    struct ip *ip;
    int hlen;

    ip = (struct ip *) buf;
    hlen = ip->ip_hl << 2;
    cc -= hlen;

    if (nflag) {
        fprint2(response, " %s", inet_ntoa(from->sin_addr));
    }
    else {
        fprint2(response, " %s (%s)", inetname(from->sin_addr),inet_ntoa(from->sin_addr));

        if (verbose) {
            fprint2(response, " %d bytes to %s", cc, inet_ntoa (ip->ip_dst));
        }
    }
}


void fprint2(char* res, char* format, ...) {
    char buffer[256];
    va_list args;
    va_start(args, format);
    vsprintf(buffer, format, args);
    strcat(res, buffer);
    va_end (args);
}

#ifdef notyet
// Checksum routine for Internet Protocol family headers (C Version)
u_short in_cksum(u_short *addr, int len) {
    register int nleft = len;
    register u_short *w = addr;
    register u_short answer;
    register int sum = 0;


    // Our algorithm is simple, using a 32 bit accumulator (sum),
    // we add sequential 16 bit words to it, and at the end, fold
    // back all the carry bits from the top 16 bits into the lower
    // 16 bits.
    while (nleft > 1)  {
        sum += *w++;
        nleft -= 2;
    }

    // mop up an odd byte, if necessary
    if (nleft == 1)
        sum += *(u_char *)w;

    // add back carry outs from top 16 bits to low 16 bits
    sum = (sum >> 16) + (sum & 0xffff); // add hi 16 to low 16
    sum += (sum >> 16); // add carry
    answer = ~sum; // truncate to 16 bits

    return (answer);
}
#endif //notyet

// Subtract 2 timeval structs:  out = out - in.  Out is assumed to be >= in.
void tvsub(register struct timeval *out, register struct timeval *in) {
    if ((out->tv_usec -= in->tv_usec) < 0) {
        out->tv_sec--;
        out->tv_usec += 1000000;
    }
    out->tv_sec -= in->tv_sec;
}

// Construct an Internet address representation. If the nflag has been supplied, give
// numeric value, otherwise try for symbolic name.
char * inetname(struct in_addr in) {
    register char *cp;
    static char line[50];
    struct hostent *hp;
    static char domain[MAXHOSTNAMELEN + 1];
    static int first = 1;

    if (first && !nflag) {
        first = 0;
        if (gethostname(domain, MAXHOSTNAMELEN) == 0 && (cp = index(domain, '.'))) {
            (void) strcpy(domain, cp + 1);
        }
        else {
            domain[0] = 0;
        }
    }

    cp = 0;

    if (!nflag && in.s_addr != INADDR_ANY) {
        hp = gethostbyaddr((char *)&in, sizeof (in), AF_INET);
        if (hp) {
            if ((cp = index(hp->h_name, '.')) && !strcmp(cp + 1, domain)) {
                *cp = 0;
            }
            cp = hp->h_name;
        }
    }

    if (cp) {
        (void) strcpy(line, cp);
    }
    else {
        in.s_addr = ntohl(in.s_addr);
        #define C(x)    ((x) & 0xff)
        Sprintf(line, "%lu.%lu.%lu.%lu", C(in.s_addr >> 24), C(in.s_addr >> 16), C(in.s_addr >> 8), C(in.s_addr));
    }

    return (line);
}
