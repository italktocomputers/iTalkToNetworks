//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

/*
 * Copyright (c) 2008 Apple Inc. All rights reserved.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. The rights granted to you under the License
 * may not be used to create, or enable the creation or redistribution of,
 * unlawful or unlicensed copies of an Apple operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any
 * terms of an Apple operating system software license agreement.
 *
 * Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_END@
 */
/*
 * Copyright (c) 1989, 1993
 *    The Regents of the University of California.  All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Mike Muuss.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
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

/*
 *            P I N G . C
 *
 * Using the Internet Control Message Protocol (ICMP) "ECHO" facility,
 * measure round-trip-delays and packet loss across network paths.
 *
 * Author -
 *    Mike Muuss
 *    U. S. Army Ballistic Research Laboratory
 *    December, 1983
 *
 * Status -
 *    Public Domain.  Distribution Unlimited.
 * Bugs -
 *    More statistics could always be gathered.
 *    This program has to run SUID to ROOT to access the ICMP socket.
 */

#include "ping.h"

int mx_dup_ck = MAX_DUP_CHK;
char rcvd_tbl[MAX_DUP_CHK / 8];

struct sockaddr_in whereto; // who to ping
static int datalen = DEFDATALEN;
static int maxpayload;
static int s; // socket file descriptor
static u_char outpackhdr[IP_MAXPACKET], *outpack;
static char BBELL = '\a'; // characters written for MISSED and AUDIBLE
static char BSPACE = '\b'; // characters written for flood
static char DOT = '.';
static char *hostname;
static char *shostname;
static int ident; // process id to identify our packets
static int uid; // cached uid for micro-optimization
static u_char icmp_type = ICMP_ECHO;
static u_char icmp_type_rsp = ICMP_ECHOREPLY;
static int phdr_len = 0;
static int send_len;
static char *boundif;
static unsigned int ifscope;
#if defined(IP_FORCE_OUT_IFP) && TARGET_OS_EMBEDDED
static char boundifname[IFNAMSIZ];
#endif //IP_FORCE_OUT_IFP

// counters
static long nmissedmax; // max value of ntransmitted - nreceived - 1
static long npackets; // max packets to transmit
static long nreceived; // # of packets we got back
static long nrepeats;  // number of duplicates
static long ntransmitted; // sequence # for outbound packets = #sent
static long snpackets; // max packets to transmit in one sweep
static long snreceived; // # of packets we got back in this sweep
static long sntransmitted; // # of packets we sent in this sweep
static int sweepmax; // max value of payload in sweep
static int sweepmin = 0; // start value of payload in sweep
static int sweepincr = 1; // payload increment in sweep
static int interval = 1000; // interval between packets, ms
static int waittime = MAXWAIT; // timeout for each packet
static long nrcvtimeout = 0; // # of packets we got back after waittime

// timing
static int timing; // flag to do timing
static double tmin = 999999999.0; // minimum round trip time
static double tmax = 0.0; // maximum round trip time
static double tsum = 0.0; // sum of all times, for doing average
static double tsumsq = 0.0; // sum of all times squared, for std. dev.

static volatile sig_atomic_t finish_up; // nonzero if we've been told to finish up
static volatile sig_atomic_t siginfo_p;

void init() {
    phdr_len = 0;
    send_len = 0;
    ifscope = 0;
    nmissedmax = 0;
    npackets = 0;
    nreceived = 0;
    nrepeats = 0;
    ntransmitted = 0;
    snpackets = 0;
    snreceived = 0;
    sntransmitted = 0;
    sweepmax = 0;
    sweepmin = 0;
    sweepincr = 1;
    interval = 1000;
    nrcvtimeout = 0;
    timing = 0;
    tmin = 999999999.0;
    tmax = 0.0;
    tsum = 0.0;
    tsumsq = 0.0;
}

int start_ping(int argc, char** argv, char* response, void (^c)(char*), bool* ok_to_ping) {
    init();
    struct sockaddr_in from, sock_in;
    struct in_addr ifaddr;
    struct timeval last, intvl;
    struct iovec iov;
    struct ip *ip;
    struct msghdr msg;
    struct sigaction si_sa;
    size_t sz;
    u_char *datap, packet[IP_MAXPACKET];
    char *ep, *source, *target, *payload;
    struct hostent *hp;
    
    #ifdef IPSEC_POLICY_IPSEC
    char *policy_in, *policy_out;
    #endif
    
    struct sockaddr_in *to;
    double t;
    u_long alarmtimeout, ultmp;
    int almost_done, ch, df, hold, i, icmp_len, mib[4], preload, sockerrno,
    tos, ttl;
    char ctrl[CMSG_SPACE(sizeof(struct timeval))];
    char hnamebuf[MAXHOSTNAMELEN], snamebuf[MAXHOSTNAMELEN];
    
    #ifdef IP_OPTIONS
    char rspace[MAX_IPOPTLEN]; // record route space
    #endif
    
    unsigned char loop, mttl;
    
    payload = source = NULL;
    
    #ifdef IPSEC_POLICY_IPSEC
    policy_in = policy_out = NULL;
    #endif
    
    // Do the stuff that we need root priv's for *first*, and
    // then drop our setuid bit.  Save error reporting for
    // after arg parsing.
    if (getuid()) {
        s = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP);
    }
    else {
        s = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
    }

    sockerrno = errno;

    setuid(getuid());
    uid = getuid();

    alarmtimeout = df = preload = tos = 0;

    outpack = outpackhdr + sizeof(struct ip);
    while ((ch = getopt(argc, argv, "Aab:c:DdfG:g:h:I:i:Ll:M:m:nop:QqRrS:s:T:t:vW:z:"
    #ifdef IPSEC
    #ifdef IPSEC_POLICY_IPSEC
    "P:"
    #endif //IPSEC_POLICY_IPSEC
    #endif //IPSEC
    #if defined(IP_FORCE_OUT_IFP) && TARGET_OS_EMBEDDED
    "B:"
    #endif //IP_FORCE_OUT_IFP
    )) != -1)
    {
        switch(ch) {
            case 'A':
                options |= F_MISSED;
                break;
            case 'a':
                options |= F_AUDIBLE;
                break;
            #if defined(IP_FORCE_OUT_IFP) && TARGET_OS_EMBEDDED
            case 'B':
                (void) snprintf(boundifname, sizeof (boundifname), "%s", optarg);
                break;
            #endif //IP_FORCE_OUT_IFP
            case 'b':
                boundif = optarg;
                break;
            case 'c':
                ultmp = strtoul(optarg, &ep, 0);
                if (*ep || ep == optarg || ultmp > LONG_MAX || !ultmp) {
                    to_res(response, "invalid count of packets to transmit: `%s'", optarg);
                    return 1;
                }
                npackets = ultmp;
                break;
            case 'D':
                options |= F_HDRINCL;
                df = 1;
                break;
            case 'd':
                options |= F_SO_DEBUG;
                break;
            case 'f':
                if (uid) {
                    to_res(response, "-f flag");
                    return 1;
                }
                options |= F_FLOOD;
                setbuf(stdout, (char *)NULL);
                break;
            case 'G': // Maximum packet size for ping sweep
                ultmp = strtoul(optarg, &ep, 0);
                if (*ep || ep == optarg) {
                    to_res(response, "invalid packet size: `%s'", optarg);
                    return 1;
                }
                #ifndef __APPLE__
                if (uid != 0 && ultmp > DEFDATALEN) {
                    to_res(response, "packet size too large: %lu > %u", ultmp, DEFDATALEN);
                    return 1;
                }
                #endif //__APPLE__
                options |= F_SWEEP;
                sweepmax = ultmp;
                break;
            case 'g': // Minimum packet size for ping sweep
                ultmp = strtoul(optarg, &ep, 0);
                if (*ep || ep == optarg) {
                    to_res(response, "invalid packet size: `%s'", optarg);
                    return 1;
                }
                #ifndef __APPLE__
                if (uid != 0 && ultmp > DEFDATALEN) {
                    to_res(response, "packet size too large: %lu > %u", ultmp, DEFDATALEN);
                    return 1;
                }
                #endif // __APPLE__
                options |= F_SWEEP;
                sweepmin = ultmp;
                break;
            case 'h': // Packet size increment for ping sweep
                ultmp = strtoul(optarg, &ep, 0);
                if (*ep || ep == optarg || ultmp < 1) {
                    to_res(response, "invalid increment size: `%s'", optarg);
                    return 1;
                }
                #ifndef __APPLE__
                if (uid != 0 && ultmp > DEFDATALEN) {
                    to_res(response, "packet size too large: %lu > %u", ultmp, DEFDATALEN);
                    return 1;
                }
                #endif // __APPLE__
                options |= F_SWEEP;
                sweepincr = ultmp;
                break;
            case 'I': // multicast interface
                if (inet_aton(optarg, &ifaddr) == 0) {
                    to_res(response, "invalid multicast interface: `%s'", optarg);
                    return 1;
                }
                options |= F_MIF;
                break;
            case 'i': // wait between sending packets
                t = strtod(optarg, &ep) * 1000.0;
                if (*ep || ep == optarg || t > (double)INT_MAX) {
                    to_res(response, "invalid timing interval: `%s'", optarg);
                    return 1;
                }
                options |= F_INTERVAL;
                interval = (int)t;
                if (uid && interval < 1000) {
                    to_res(response, "-i interval too short");
                    return 1;
                }
                break;
            case 'L':
                options |= F_NOLOOP;
                loop = 0;
                break;
            case 'l':
                ultmp = strtoul(optarg, &ep, 0);
                if (*ep || ep == optarg || ultmp > INT_MAX) {
                    to_res(response, "invalid preload value: `%s'", optarg);
                    return 1;
                }
                if (uid) {
                    to_res(response, "-l flag");
                    return 1;
                }
                preload = ultmp;
                break;
            case 'M':
                switch(optarg[0]) {
                    case 'M':
                    case 'm':
                        options |= F_MASK;
                        break;
                    case 'T':
                    case 't':
                        options |= F_TIME;
                        break;
                    default:
                        to_res(response, "invalid message: `%c'", optarg[0]);
                        return 1;
                }
                break;
            case 'm': // TTL
                ultmp = strtoul(optarg, &ep, 0);
                if (*ep || ep == optarg || ultmp > MAXTTL) {
                    to_res(response, "invalid TTL: `%s'", optarg);
                    return 1;
                }
                ttl = ultmp;
                options |= F_TTL;
                break;
            case 'n':
                options |= F_NUMERIC;
                break;
            case 'o':
                options |= F_ONCE;
                break;
            #ifdef IPSEC
            #ifdef IPSEC_POLICY_IPSEC
            case 'P':
                options |= F_POLICY;
                if (!strncmp("in", optarg, 2)) {
                    policy_in = strdup(optarg);
                }
                else if (!strncmp("out", optarg, 3)) {
                    policy_out = strdup(optarg);
                }
                else {
                    to_res(response, "invalid security policy");
                    return 1;
                }
                break;
                #endif // IPSEC_POLICY_IPSEC
                #endif // IPSEC
            case 'p': // fill buffer with user pattern
                options |= F_PINGFILLED;
                payload = optarg;
                break;
            case 'Q':
                options |= F_QUIET2;
                break;
            case 'q':
                options |= F_QUIET;
                break;
            case 'R':
                options |= F_RROUTE;
                break;
            case 'r':
                options |= F_SO_DONTROUTE;
                break;
            case 'S':
                source = optarg;
                break;
            case 's': // size of packet to send
                ultmp = strtoul(optarg, &ep, 0);
                if (*ep || ep == optarg) {
                    to_res(response, "invalid packet size: `%s'", optarg);
                    return 1;
                }
                #ifndef __APPLE__
                if (uid != 0 && ultmp > DEFDATALEN) {
                    to_res(response, "packet size too large: %lu > %u", ultmp, DEFDATALEN);
                    return 1;
                }
                #endif //__APPLE__
                datalen = ultmp;
                break;
            case 'T': // multicast TTL
                ultmp = strtoul(optarg, &ep, 0);
                if (*ep || ep == optarg || ultmp > MAXTTL) {
                    to_res(response, "invalid multicast TTL: `%s'", optarg);
                    return 1;
                }
                mttl = ultmp;
                options |= F_MTTL;
                break;
            case 't':
                alarmtimeout = strtoul(optarg, &ep, 0);
                if ((alarmtimeout < 1) || (alarmtimeout == ULONG_MAX)) {
                    to_res(response, "invalid timeout: `%s'", optarg);
                    return 1;
                }
                if (alarmtimeout > MAXALARM) {
                    to_res(response, "invalid timeout: `%s' > %d", optarg, MAXALARM);
                    return 1;
                }
                alarm((unsigned int)alarmtimeout);
                break;
            case 'v':
                options |= F_VERBOSE;
                break;
            case 'W': // wait ms for answer
                t = strtod(optarg, &ep);
                if (*ep || ep == optarg || t > (double)INT_MAX) {
                    to_res(response, "invalid timing interval: `%s'", optarg);
                    return 1;
                }
                options |= F_WAITTIME;
                waittime = (int)t;
                break;
            case 'z':
                options |= F_HDRINCL;
                ultmp = strtoul(optarg, &ep, 0);
                if (*ep || ep == optarg || ultmp > MAXTOS) {
                    to_res(response, "invalid TOS: `%s'", optarg);
                    return 1;
                }
                tos = ultmp;
                break;
            default:
                return 1;
        }
    }
    
    if (boundif != NULL && (ifscope = if_nametoindex(boundif)) == 0) {
        to_res(response, "bad interface name");
        return 1;
    }
        
    if (argc - optind != 1) {
        // wrong arugments
        return 1;
    }

    target = argv[optind];

    switch (options & (F_MASK|F_TIME)) {
        case 0: break;
        case F_MASK:
            icmp_type = ICMP_MASKREQ;
            icmp_type_rsp = ICMP_MASKREPLY;
            phdr_len = MASK_LEN;
            if (!(options & F_QUIET))
                (void)printf("ICMP_MASKREQ\n");
            break;
        case F_TIME:
            icmp_type = ICMP_TSTAMP;
            icmp_type_rsp = ICMP_TSTAMPREPLY;
            phdr_len = TS_LEN;
            if (!(options & F_QUIET))
                (void)printf("ICMP_TSTAMP\n");
            break;
        default:
            to_res(response, "ICMP_TSTAMP and ICMP_MASKREQ are exclusive.");
            return 1;
    }

    icmp_len = sizeof(struct ip) + ICMP_MINLEN + phdr_len;

    if (options & F_RROUTE) {
        icmp_len += MAX_IPOPTLEN;
    }

    maxpayload = IP_MAXPACKET - icmp_len;

    if (datalen > maxpayload) {
        to_res(response, "packet size too large: %d > %d", datalen, maxpayload);
        return 1;
    }

    send_len = icmp_len + datalen;
    datap = &outpack[ICMP_MINLEN + phdr_len + TIMEVAL_LEN];

    if (options & F_PINGFILLED) {
        fill((char *)datap, payload, response);
    }

    if (source) {
        bzero((char *)&sock_in, sizeof(sock_in));
        sock_in.sin_family = AF_INET;

        if (inet_aton(source, &sock_in.sin_addr) != 0) {
            shostname = source;
        }
        else {
            hp = gethostbyname2(source, AF_INET);
            if (!hp) {
                to_res(response, "cannot resolve %s: %s", source, hstrerror(h_errno));
                return 1;
            }
            
            sock_in.sin_len = sizeof sock_in;
            if ((unsigned)hp->h_length > sizeof(sock_in.sin_addr) || hp->h_length < 0) {
                to_res(response, "gethostbyname2: illegal address");
                return 1;
            }

            memcpy(&sock_in.sin_addr, hp->h_addr_list[0], sizeof(sock_in.sin_addr));
            (void)strncpy(snamebuf, hp->h_name, sizeof(snamebuf) - 1);
            snamebuf[sizeof(snamebuf) - 1] = '\0';
            shostname = snamebuf;
        }

        if (bind(s, (struct sockaddr *)&sock_in, sizeof sock_in) == -1) {
            to_res(response, "bind");
            return 1;
        }
    }
    
    bzero(&whereto, sizeof(whereto));
    to = &whereto;
    to->sin_family = AF_INET;
    to->sin_len = sizeof *to;

    if (inet_aton(target, &to->sin_addr) != 0) {
        hostname = target;
    }
    else {
        hp = gethostbyname2(target, AF_INET);
        if (!hp) {
            to_res(response, "cannot resolve %s: %s", target, hstrerror(h_errno));
            return 1;
        }
        
        if ((unsigned)hp->h_length > sizeof(to->sin_addr)) {
            to_res(response, "gethostbyname2 returned an illegal address");
            return 1;
        }

        memcpy(&to->sin_addr, hp->h_addr_list[0], sizeof to->sin_addr);
        (void)strncpy(hnamebuf, hp->h_name, sizeof(hnamebuf) - 1);
        hnamebuf[sizeof(hnamebuf) - 1] = '\0';
        hostname = hnamebuf;
    }
    
    if (options & F_FLOOD && options & F_INTERVAL) {
        to_res(response, "-f and -i: incompatible options");
        return 1;
    }
        
    if (options & F_FLOOD && IN_MULTICAST(ntohl(to->sin_addr.s_addr))) {
        to_res(response, "-f flag cannot be used with multicast destination");
        return 1;
    }

    if (options & (F_MIF | F_NOLOOP | F_MTTL) && !IN_MULTICAST(ntohl(to->sin_addr.s_addr))) {
        to_res(response, "-I, -L, -T flags cannot be used with unicast destination");
        return 1;
    }

    if (datalen >= TIMEVAL_LEN) { // can we time transfer
        timing = 1;
    }

    if (!(options & F_PINGFILLED))
        for (i = TIMEVAL_LEN; i < datalen; ++i)
            *datap++ = i;

    ident = getpid() & 0xFFFF;

    if (s < 0) {
        to_res(response, "socket");
        return 1;
    }

    hold = 1;
    if (ifscope != 0) {
        if (setsockopt(s, IPPROTO_IP, IP_BOUND_IF, (char *)&ifscope, sizeof (ifscope)) != 0) {
            to_res(response, "setsockopt(IP_BOUND_IF)");
            return 1;
        }
    }
    #if defined(IP_FORCE_OUT_IFP) && TARGET_OS_EMBEDDED
    else if (boundifname[0] != 0) {
        if (setsockopt(s, IPPROTO_IP, IP_FORCE_OUT_IFP, boundifname, sizeof (boundifname)) != 0) {
            to_res(response, "setsockopt(IP_FORCE_OUT_IFP)");
            return 1;
        }
    }
    #endif //IP_FORCE_OUT_IFP
    if (options & F_SO_DEBUG) {
        (void)setsockopt(s, SOL_SOCKET, SO_DEBUG, (char *)&hold, sizeof(hold));
    }

    if (options & F_SO_DONTROUTE) {
        (void)setsockopt(s, SOL_SOCKET, SO_DONTROUTE, (char *)&hold, sizeof(hold));
    }

    #ifdef IPSEC
    #ifdef IPSEC_POLICY_IPSEC
    if (options & F_POLICY) {
        char *buf;
        if (policy_in != NULL) {
            buf = ipsec_set_policy(policy_in, strlen(policy_in));

            if (buf == NULL) {
                to_res(response, "%s", ipsec_strerror());
                return 1;
            }

            if (setsockopt(s, IPPROTO_IP, IP_IPSEC_POLICY, buf, ipsec_get_policylen(buf)) < 0) {
                to_res(response, "ipsec policy cannot be configured");
                return 1;
            }

            free(buf);
        }

        if (policy_out != NULL) {
            buf = ipsec_set_policy(policy_out, strlen(policy_out));

            if (buf == NULL) {
                to_res(response, "%s", ipsec_strerror());
                return 1;
            }

            if (setsockopt(s, IPPROTO_IP, IP_IPSEC_POLICY, buf, ipsec_get_policylen(buf)) < 0) {
                to_res(response, "ipsec policy cannot be configured");
                return 1;
            }

            free(buf);
        }
    }
    #endif //IPSEC_POLICY_IPSEC
    #endif //IPSEC
    
    if (options & F_HDRINCL) {
        ip = (struct ip*)outpackhdr;

        if (!(options & (F_TTL | F_MTTL))) {
            mib[0] = CTL_NET;
            mib[1] = PF_INET;
            mib[2] = IPPROTO_IP;
            mib[3] = IPCTL_DEFTTL;
            sz = sizeof(ttl);
            if (sysctl(mib, 4, &ttl, &sz, NULL, 0) == -1) {
                to_res(response, "sysctl(net.inet.ip.ttl)");
                return 1;
            }
        }

        setsockopt(s, IPPROTO_IP, IP_HDRINCL, &hold, sizeof(hold));
        ip->ip_v = IPVERSION;
        ip->ip_hl = sizeof(struct ip) >> 2;
        ip->ip_tos = tos;
        ip->ip_id = 0;
        ip->ip_off = df ? IP_DF : 0;
        ip->ip_ttl = ttl;
        ip->ip_p = IPPROTO_ICMP;
        ip->ip_src.s_addr = source ? sock_in.sin_addr.s_addr : INADDR_ANY;
        ip->ip_dst = to->sin_addr;
    }
    
    // record route option
    if (options & F_RROUTE) {
        #ifdef IP_OPTIONS
        bzero(rspace, sizeof(rspace));
        rspace[IPOPT_OPTVAL] = IPOPT_RR;
        rspace[IPOPT_OLEN] = sizeof(rspace) - 1;
        rspace[IPOPT_OFFSET] = IPOPT_MINOFF;
        rspace[sizeof(rspace) - 1] = IPOPT_EOL;
        
        if (setsockopt(s, IPPROTO_IP, IP_OPTIONS, rspace, sizeof(rspace)) < 0) {
            to_res(response, "setsockopt IP_OPTIONS");
            return 1;
        }
        #else
        to_res(response, "record route not available in this implementation");
        return 1;
        #endif //IP_OPTIONS
    }
    
    if (options & F_TTL) {
        if (setsockopt(s, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl)) < 0) {
            to_res(response, "setsockopt IP_TTL");
            return 1;
        }
    }
    
    if (options & F_NOLOOP) {
        if (setsockopt(s, IPPROTO_IP, IP_MULTICAST_LOOP, &loop, sizeof(loop)) < 0) {
            to_res(response, "setsockopt IP_MULTICAST_LOOP");
            return 1;
        }
    }
    
    if (options & F_MTTL) {
        if (setsockopt(s, IPPROTO_IP, IP_MULTICAST_TTL, &mttl, sizeof(mttl)) < 0) {
            to_res(response, "setsockopt IP_MULTICAST_TTL");
            return 1;
        }
    }
    
    if (options & F_MIF) {
        if (setsockopt(s, IPPROTO_IP, IP_MULTICAST_IF, &ifaddr, sizeof(ifaddr)) < 0) {
            to_res(response, "setsockopt IP_MULTICAST_IF");
            return 1;
        }
    }
    
    #ifdef SO_TIMESTAMP
    { int on = 1;
        if (setsockopt(s, SOL_SOCKET, SO_TIMESTAMP, &on, sizeof(on)) < 0) {
            to_res(response, "setsockopt SO_TIMESTAMP");
            return 1;
        }
    }
    #endif
    
    if (sweepmax) {
        if (sweepmin >= sweepmax) {
            to_res(response, "Maximum packet size must be greater than the minimum packet size");
            return 1;
        }
        
        if (datalen != DEFDATALEN) {
            to_res(response, "Packet size and ping sweep are mutually exclusive");
            return 1;
        }
        
        if (npackets > 0) {
            snpackets = npackets;
            npackets = 0;
        }
        else {
            snpackets = 1;
        }
        
        datalen = sweepmin;
        send_len = icmp_len + sweepmin;
    }
    
    if (options & F_SWEEP && !sweepmax) {
        to_res(response, "Maximum sweep size must be specified");
        return 1;
    }
    
    // When pinging the broadcast address, you can get a lot of answers.
    // Doing something so evil is useful if you are trying to stress the
    // ethernet, or just want to fill the arp cache to get some stuff for
    // /etc/ethers.  But beware: RFC 1122 allows hosts to ignore broadcast
    // or multicast pings if they wish.
        
    // XXX receive buffer needs undetermined space for mbuf overhead as well.
    hold = IP_MAXPACKET + 128;
    
    (void)setsockopt(s, SOL_SOCKET, SO_RCVBUF, (char *)&hold, sizeof(hold));
    if (uid == 0) {
        (void)setsockopt(s, SOL_SOCKET, SO_SNDBUF, (char *)&hold, sizeof(hold));
    }
            
    if (to->sin_family == AF_INET) {
        to_res(response, "PING %s (%s)", hostname, inet_ntoa(to->sin_addr));

        if (source) {
            to_res(response, " from %s", shostname);
        }

        if (sweepmax) {
            to_res(response, ": (%d ... %d) data bytes\n", sweepmin, sweepmax);
        }
        else {
            to_res(response, ": %d data bytes\n", datalen);
        }
    }
    else {
        if (sweepmax) {
            to_res(response, "PING %s: (%d ... %d) data bytes\n", hostname, sweepmin, sweepmax);
        }
        else {
            to_res(response, "PING %s: %d data bytes\n", hostname, datalen);
        }
    }
    
    // Use sigaction() instead of signal() to get unambiguous semantics,
    // in particular with SA_RESTART not set.
    
    sigemptyset(&si_sa.sa_mask);
    si_sa.sa_flags = 0;
    
    si_sa.sa_handler = stopit;
    if (sigaction(SIGINT, &si_sa, 0) == -1) {
        to_res(response, "sigaction SIGINT");
        return 1;
    }
    
    si_sa.sa_handler = status;
    if (sigaction(SIGINFO, &si_sa, 0) == -1) {
        to_res(response, "sigaction");
        return 1;
    }
    
    if (alarmtimeout > 0) {
        si_sa.sa_handler = stopit;
        if (sigaction(SIGALRM, &si_sa, 0) == -1) {
            to_res(response, "sigaction SIGALRM");
            return 1;
        }
    }
    
    bzero(&msg, sizeof(msg));
    msg.msg_name = (caddr_t)&from;
    msg.msg_iov = &iov;
    msg.msg_iovlen = 1;

    #ifdef SO_TIMESTAMP
    msg.msg_control = (caddr_t)ctrl;
    #endif

    iov.iov_base = packet;
    iov.iov_len = IP_MAXPACKET;
    
    if (preload == 0) {
        pinger(); // send the first ping
    }
    else {
        if (npackets != 0 && preload > npackets)
            preload = npackets;

        while (preload--) // fire off them quickies
            pinger();
    }

    (void)gettimeofday(&last, NULL);
    
    if (options & F_FLOOD) {
        intvl.tv_sec = 0;
        intvl.tv_usec = 10000;
    }
    else {
        intvl.tv_sec = interval / 1000;
        intvl.tv_usec = interval % 1000 * 1000;
    }
    
    almost_done = 0;

    while (!finish_up && *ok_to_ping) {
        struct timeval now, timeout;
        fd_set rfds;
        int cc, n;
        
        check_status(response);

        if ((unsigned)s >= FD_SETSIZE) {
            to_res(response, "descriptor too large");
            return 1;
        }

        FD_ZERO(&rfds);
        FD_SET(s, &rfds);
        (void)gettimeofday(&now, NULL);
        timeout.tv_sec = last.tv_sec + intvl.tv_sec - now.tv_sec;
        timeout.tv_usec = last.tv_usec + intvl.tv_usec - now.tv_usec;

        while (timeout.tv_usec < 0) {
            timeout.tv_usec += 1000000;
            timeout.tv_sec--;
        }

        while (timeout.tv_usec >= 1000000) {
            timeout.tv_usec -= 1000000;
            timeout.tv_sec++;
        }

        if (timeout.tv_sec < 0)
            timeout.tv_sec = timeout.tv_usec = 0;

        n = select(s + 1, &rfds, NULL, NULL, &timeout);

        if (n < 0)
            continue; // Must be EINTR.

        if (n == 1) {
            struct timeval *tv = NULL;

        #ifdef SO_TIMESTAMP
        struct cmsghdr *cmsg = (struct cmsghdr *)&ctrl;
        msg.msg_controllen = sizeof(ctrl);
        #endif

        msg.msg_namelen = sizeof(from);
        if ((cc = recvmsg(s, &msg, 0)) < 0) {
            if (errno == EINTR)
                continue;
            warn("recvmsg");
            continue;
        }

        #ifdef SO_TIMESTAMP
        if (cmsg->cmsg_level == SOL_SOCKET && cmsg->cmsg_type == SCM_TIMESTAMP && cmsg->cmsg_len == CMSG_LEN(sizeof *tv)) {
            // Copy to avoid alignment problems:
            memcpy(&now, CMSG_DATA(cmsg), sizeof(now));
            tv = &now;
        }
        #endif

        if (tv == NULL) {
            (void)gettimeofday(&now, NULL);
            tv = &now;
        }

        pr_pack((char *)packet, cc, &from, tv, response);
        if ((options & F_ONCE && nreceived) || (npackets && nreceived >= npackets))
            break;
        }

        if (n == 0 || options & F_FLOOD) {
            if (sweepmax && sntransmitted == snpackets) {
                for (i = 0; i < sweepincr ; ++i)
                    *datap++ = i;
                datalen += sweepincr;
                if (datalen > sweepmax)
                    break;
                send_len = icmp_len + datalen;
                sntransmitted = 0;
            }

            if (!npackets || ntransmitted < npackets) {
                pinger();
            }
            else {
                if (almost_done)
                    break;
                almost_done = 1;
                intvl.tv_usec = 0;

                if (nreceived) {
                    intvl.tv_sec = 2 * tmax / 1000;
                    if (!intvl.tv_sec)
                        intvl.tv_sec = 1;
                }
                else {
                    intvl.tv_sec = waittime / 1000;
                    intvl.tv_usec = waittime % 1000 * 1000;
                }
            }

            (void)gettimeofday(&last, NULL);
            if (ntransmitted - nreceived - 1 > nmissedmax) {
                nmissedmax = ntransmitted - nreceived - 1;

                if (options & F_MISSED)
                    (void)write(STDOUT_FILENO, &BBELL, 1);
                if (!(options & F_QUIET))
                    to_res(response, "Request timeout for icmp_seq %ld\n", ntransmitted - 2);
            }
        }

        c(response);
    }

    finish(response);
    
    return 0;
}

// stopit --
// Set the global bit that causes the main loop to quit.
// Do NOT call finish() from here, since finish() does far too much
// to be called from a signal handler.
static void stopit(int sig __unused) {
    // When doing reverse DNS lookups, the finish_up flag might not
    // be noticed for a while.  Just exit if we get a second SIGINT.
    if (!(options & F_NUMERIC) && finish_up)
        _exit(nreceived ? 0 : 2);
    finish_up = 1;
}

// pinger --
// Compose and transmit an ICMP ECHO REQUEST packet.  The IP packet
// will be added on by the kernel.  The ID field is our UNIX process ID,
// and the sequence number is an ascending integer.  The first TIMEVAL_LEN
// bytes of the data portion are used to hold a UNIX "timeval" struct in
// host byte-order, to compute the round-trip time.
static void pinger(void) {
    struct timeval now;
    struct tv32 tv32;
    struct ip *ip;
    struct icmp *icp;
    int cc, i;
    u_char *packet;
    
    packet = outpack;
    icp = (struct icmp *)outpack;
    icp->icmp_type = icmp_type;
    icp->icmp_code = 0;
    icp->icmp_cksum = 0;
    icp->icmp_seq = htons(ntransmitted);
    icp->icmp_id = ident; // ID
    
    CLR(ntransmitted % mx_dup_ck);
    
    if ((options & F_TIME) || timing) {
        (void)gettimeofday(&now, NULL);
        
        tv32.tv32_sec = htonl(now.tv_sec);
        tv32.tv32_usec = htonl(now.tv_usec);

        if (options & F_TIME)
            icp->icmp_otime = htonl((now.tv_sec % (24*60*60)) * 1000 + now.tv_usec / 1000);

        if (timing)
            bcopy((void *)&tv32, (void *)&outpack[ICMP_MINLEN + phdr_len], sizeof(tv32));
    }
    
    cc = ICMP_MINLEN + phdr_len + datalen;
    
    // compute ICMP checksum here
    icp->icmp_cksum = in_cksum((u_short *)icp, cc);
    
    if (options & F_HDRINCL) {
        cc += sizeof(struct ip);
        ip = (struct ip *)outpackhdr;
        ip->ip_len = cc;
        ip->ip_sum = in_cksum((u_short *)outpackhdr, cc);
        packet = outpackhdr;
    }

    i = sendto(s, (char *)packet, cc, 0, (struct sockaddr *)&whereto, sizeof(whereto));
    
    if (i < 0 || i != cc)  {
        if (i < 0) {
            if (options & F_FLOOD && errno == ENOBUFS) {
                usleep(FLOOD_BACKOFF);
                return;
            }
            warn("sendto");
        }
        else {
            warn("%s: partial write: %d of %d bytes", hostname, i, cc);
        }
    }

    ntransmitted++;
    sntransmitted++;

    if (!(options & F_QUIET) && options & F_FLOOD)
        (void)write(STDOUT_FILENO, &DOT, 1);
}

// pr_pack --
// Print out the packet, if it came from us.  This logic is necessary
// because ALL readers of the ICMP socket get a copy of ALL ICMP packets
// which arrive ('tis only fair).  This permits multiple copies of this
// program to be run without having intermingled output (or statistics!).
static void pr_pack(char* buf, int cc, struct sockaddr_in* from, struct timeval* tv, char* response) {
    struct in_addr ina;
    u_char *cp, *dp;
    struct icmp *icp;
    struct ip *ip;
    const void *tp;
    double triptime;
    int dupflag, hlen, i, j, recv_len, seq;
    static int old_rrlen;
    static char old_rr[MAX_IPOPTLEN];
    
    // Check the IP header
    ip = (struct ip *)buf;
    hlen = ip->ip_hl << 2;
    recv_len = cc;
    if (cc < hlen + ICMP_MINLEN) {
        if (options & F_VERBOSE)
            warn("packet too short (%d bytes) from %s", cc, inet_ntoa(from->sin_addr));
        return;
    }
    
    // Now the ICMP part
    cc -= hlen;
    icp = (struct icmp *)(buf + hlen);
    if (icp->icmp_type == icmp_type_rsp) {
        if (icp->icmp_id != ident)
            return; // 'Twas not our ECHO
        ++nreceived;
        triptime = 0.0;

        if (timing) {
            struct timeval tv1;
            struct tv32 tv32;

            #ifndef icmp_data
            tp = &icp->icmp_ip;
            #else
            tp = icp->icmp_data;
            #endif

            tp = (const char *)tp + phdr_len;
            
            if (cc - ICMP_MINLEN - phdr_len >= sizeof(tv1)) {
                // Copy to avoid alignment problems:
                memcpy(&tv32, tp, sizeof(tv32));
                tv1.tv_sec = ntohl(tv32.tv32_sec);
                tv1.tv_usec = ntohl(tv32.tv32_usec);
                tvsub(tv, &tv1);
                triptime = ((double)tv->tv_sec) * 1000.0 +
                ((double)tv->tv_usec) / 1000.0;
                tsum += triptime;
                tsumsq += triptime * triptime;

                if (triptime < tmin)
                    tmin = triptime;

                if (triptime > tmax)
                    tmax = triptime;
            }
            else {
                timing = 0;
            }
        }
        
        seq = ntohs(icp->icmp_seq);
        
        if (TST(seq % mx_dup_ck)) {
            ++nrepeats;
            --nreceived;
            dupflag = 1;
        }
        else {
            SET(seq % mx_dup_ck);
            dupflag = 0;
        }
        
        if (options & F_QUIET)
            return;
        
        if (options & F_WAITTIME && triptime > waittime) {
            ++nrcvtimeout;
            return;
        }
        
        if (options & F_FLOOD) {
            (void)write(STDOUT_FILENO, &BSPACE, 1);
        }
        else {
            to_res(response, "%d bytes from %s: icmp_seq=%u", cc, inet_ntoa(*(struct in_addr *)&from->sin_addr.s_addr), seq);
            to_res(response, " ttl=%d", ip->ip_ttl);

            if (timing)
                to_res(response, " time=%.3f ms", triptime);

            if (dupflag) {
                if (!IN_MULTICAST(ntohl(whereto.sin_addr.s_addr)))
                    to_res(response, " (DUP!)");
            }

            if (options & F_AUDIBLE)
                (void)write(STDOUT_FILENO, &BBELL, 1);

            if (options & F_MASK) {
                // Just prentend this cast isn't ugly
                to_res(response, " mask=%s", pr_addr(*(struct in_addr *)&(icp->icmp_mask), response));
            }

            if (options & F_TIME) {
                to_res(response, " tso=%s", pr_ntime(icp->icmp_otime, response));
                to_res(response, " tsr=%s", pr_ntime(icp->icmp_rtime, response));
                to_res(response, " tst=%s", pr_ntime(icp->icmp_ttime, response));
            }

            if (recv_len != send_len) {
                to_res(response, "\nwrong total length %d instead of %d", recv_len, send_len);
            }

            // check the data
            cp = (u_char*)&icp->icmp_data[phdr_len];
            dp = &outpack[ICMP_MINLEN + phdr_len];
            cc -= ICMP_MINLEN + phdr_len;
            i = 0;

            if (timing) { // don't check variable timestamp
                cp += TIMEVAL_LEN;
                dp += TIMEVAL_LEN;
                cc -= TIMEVAL_LEN;
                i += TIMEVAL_LEN;
            }

            for (; i < datalen && cc > 0; ++i, ++cp, ++dp, --cc) {
                if (*cp != *dp) {
                    to_res(response, "\nwrong data byte #%d should be 0x%x but was 0x%x", i, *dp, *cp);
                    to_res(response, "\ncp:");

                    cp = (u_char*)&icp->icmp_data[0];

                    for (i = 0; i < datalen; ++i, ++cp) {
                        if ((i % 16) == 8)
                            to_res(response, "\n\t");
                        to_res(response, "%2x ", *cp);
                    }

                    to_res(response, "\ndp:");
                    cp = &outpack[ICMP_MINLEN];

                    for (i = 0; i < datalen; ++i, ++cp) {
                        if ((i % 16) == 8)
                            to_res(response, "\n\t");
                        to_res(response, "%2x ", *cp);
                    }

                    break;
                }
            }
        }
    }
    else {
        // We've got something other than an ECHOREPLY.
        // See if it's a reply to something that we sent.
        // We can compare IP destination, protocol,
        // and ICMP type and ID.
        // Only print all the error messages if we are running
        // as root to avoid leaking information not normally
        // available to those not running as root.

        #ifndef icmp_data
        struct ip *oip = &icp->icmp_ip;
        #else
        struct ip *oip = (struct ip *)icp->icmp_data;
        #endif

        struct icmp *oicmp = (struct icmp *)(oip + 1);
        
        if (((options & F_VERBOSE) && uid == 0) ||
            (!(options & F_QUIET2) &&
             (oip->ip_dst.s_addr == whereto.sin_addr.s_addr) &&
             (oip->ip_p == IPPROTO_ICMP) &&
             (oicmp->icmp_type == ICMP_ECHO) &&
             (oicmp->icmp_id == ident))) {
                to_res(response, "%d bytes from %s: ", cc, pr_addr(from->sin_addr, response));
                pr_icmph(icp, response);
        }
        else {
            return;
        }
    }
    
    // Display any IP options
    cp = (u_char *)buf + sizeof(struct ip);
    
    for (; hlen > (int)sizeof(struct ip); --hlen, ++cp)
        switch (*cp) {
            case IPOPT_EOL:
                hlen = 0;
                break;
            case IPOPT_LSRR:
            case IPOPT_SSRR:
                to_res(response, *cp == IPOPT_LSRR ? "\nLSRR: " : "\nSSRR: ");
                j = cp[IPOPT_OLEN] - IPOPT_MINOFF + 1;
                hlen -= 2;
                cp += 2;
                if (j >= INADDR_LEN &&
                    j <= hlen - (int)sizeof(struct ip)) {
                    for (;;) {
                        bcopy(++cp, &ina.s_addr, INADDR_LEN);
                        if (ina.s_addr == 0)
                            to_res(response, "\t0.0.0.0");
                        else
                            to_res(response, "\t%s", pr_addr(ina, response));
                        hlen -= INADDR_LEN;
                        cp += INADDR_LEN - 1;
                        j -= INADDR_LEN;
                        if (j < INADDR_LEN)
                            break;
                        (void)putchar('\n');
                    }
                }
                else {
                    to_res(response, "\t(truncated route)\n");
                }
                break;
            case IPOPT_RR:
                j = cp[IPOPT_OLEN]; // get length
                i = cp[IPOPT_OFFSET]; // and pointer
                hlen -= 2;
                cp += 2;

                if (i > j)
                    i = j;

                i = i - IPOPT_MINOFF + 1;

                if (i < 0 || i > (hlen - (int)sizeof(struct ip))) {
                    old_rrlen = 0;
                    continue;
                }

                if (i == old_rrlen && !bcmp((char *)cp, old_rr, i) && !(options & F_FLOOD)) {
                    to_res(response, "\t(same route)");
                    hlen -= i;
                    cp += i;
                    break;
                }

                old_rrlen = i;
                bcopy((char *)cp, old_rr, i);
                to_res(response, "\nRR: ");

                if (i >= INADDR_LEN && i <= hlen - (int)sizeof(struct ip)) {
                    for (;;) {
                        bcopy(++cp, &ina.s_addr, INADDR_LEN);

                        if (ina.s_addr == 0)
                            to_res(response, "\t0.0.0.0");
                        else
                            to_res(response, "\t%s", pr_addr(ina, response));

                        hlen -= INADDR_LEN;
                        cp += INADDR_LEN - 1;
                        i -= INADDR_LEN;

                        if (i < INADDR_LEN)
                            break;

                        to_res(response, "\n");
                    }
                }
                else {
                    to_res(response, "\t(truncated route)");
                }

                break;
            case IPOPT_NOP:
                to_res(response, "\nNOP");
                break;
            default:
                to_res(response, "\nunknown option %x", *cp);
                break;
        }
    if (!(options & F_FLOOD)) {
        to_res(response, "\n");
    }
}

// in_cksum --
// Checksum routine for Internet Protocol family headers (C Version)
static u_short in_cksum(u_short* addr, int len) {
    int nleft, sum;
    u_short *w;
    union {
        u_short    us;
        u_char    uc[2];
    } last;
    u_short answer;
    
    nleft = len;
    sum = 0;
    w = addr;
    
    // Our algorithm is simple, using a 32 bit accumulator (sum), we add
    // sequential 16 bit words to it, and at the end, fold back all the
    // carry bits from the top 16 bits into the lower 16 bits.
    while (nleft > 1)  {
        sum += *w++;
        nleft -= 2;
    }
    
    // mop up an odd byte, if necessary
    if (nleft == 1) {
        last.uc[0] = *(u_char *)w;
        last.uc[1] = 0;
        sum += last.us;
    }
    
    // add back carry outs from top 16 bits to low 16 bits
    sum = (sum >> 16) + (sum & 0xffff); // add hi 16 to low 16
    sum += (sum >> 16);// add carry
    answer = ~sum; // truncate to 16 bits
    return(answer);
}

// tvsub --
// Subtract 2 timeval structs:  out = out - in.  Out is assumed to
// be >= in.
static void tvsub(struct timeval* out, struct timeval* in) {
    if ((out->tv_usec -= in->tv_usec) < 0) {
        --out->tv_sec;
        out->tv_usec += 1000000;
    }
    out->tv_sec -= in->tv_sec;
}

// status --
// Print out statistics when SIGINFO is received.

static void status(int sig __unused) {
    siginfo_p = 1;
}

static void check_status(char* response) {
    if (siginfo_p) {
        siginfo_p = 0;
        to_res(response, "\r%ld/%ld packets received (%.1f%%)", nreceived, ntransmitted, ntransmitted ? nreceived * 100.0 / ntransmitted : 0.0);
        if (nreceived && timing)
            to_res(response, " %.3f min / %.3f avg / %.3f max", tmin, tsum / (nreceived + nrepeats), tmax);
        to_res(response, "\n");
    }
}

// finish --
// Print out statistics, and give up.
static int finish(char* response) {
    (void)signal(SIGINT, SIG_IGN);
    (void)signal(SIGALRM, SIG_IGN);
    to_res(response, "\n");
    to_res(response, "--- %s ping statistics ---\n", hostname);
    to_res(response, "%ld packets transmitted, ", ntransmitted);
    to_res(response, "%ld packets received, ", nreceived);
    if (nrepeats)
        to_res(response, "+%ld duplicates, ", nrepeats);
    if (ntransmitted) {
        if (nreceived > ntransmitted)
            to_res(response, "-- somebody's printing up packets!");
        else
            to_res(response, "%.1f%% packet loss", ((ntransmitted - nreceived) * 100.0) / ntransmitted);
    }
    if (nrcvtimeout)
        to_res(response, ", %ld packets out of wait time", nrcvtimeout);
    to_res(response, "\n");

    if (nreceived && timing) {
        double n = nreceived + nrepeats;
        double avg = tsum / n;
        double vari = tsumsq / n - avg * avg;
        to_res(response, "round-trip min/avg/max/stddev = %.3f/%.3f/%.3f/%.3f ms\n", tmin, avg, tmax, sqrt(vari));
    }
    
    if (nreceived)
        return 0;
    else
        return 2;
}

#ifdef notdef
static char *ttab[] = {
    "Echo Reply", // ip + seq + udata
    "Dest Unreachable",// net, host, proto, port, frag, sr + IP
    "Source Quench",// IP
    "Redirect",// redirect type, gateway, + IP
    "Echo",
    "Time Exceeded",// transit, frag reassem + IP
    "Parameter Problem",// pointer + IP
    "Timestamp",// id + seq + three timestamps
    "Timestamp Reply",
    "Info Request",// id + sq
    "Info Reply"
};
#endif

// pr_icmph --
// Print a descriptive string about an ICMP header.
static void pr_icmph(struct icmp* icp, char* response) {
    switch(icp->icmp_type) {
        case ICMP_ECHOREPLY:
            to_res(response, "Echo Reply\n");
            // XXX ID + Seq + Data
            break;
        case ICMP_UNREACH:
            switch(icp->icmp_code) {
                case ICMP_UNREACH_NET:
                    to_res(response, "Destination Net Unreachable\n");
                    break;
                case ICMP_UNREACH_HOST:
                    to_res(response, "Destination Host Unreachable\n");
                    break;
                case ICMP_UNREACH_PROTOCOL:
                    to_res(response, "Destination Protocol Unreachable\n");
                    break;
                case ICMP_UNREACH_PORT:
                    to_res(response, "Destination Port Unreachable\n");
                    break;
                case ICMP_UNREACH_NEEDFRAG:
                    to_res(response, "frag needed and DF set (MTU %d)\n", ntohs(icp->icmp_nextmtu));
                    break;
                case ICMP_UNREACH_SRCFAIL:
                    to_res(response, "Source Route Failed\n");
                    break;
                case ICMP_UNREACH_FILTER_PROHIB:
                    to_res(response, "Communication prohibited by filter\n");
                    break;
                default:
                    to_res(response, "Dest Unreachable, Bad Code: %d\n", icp->icmp_code);
                    break;
            }
            // Print returned IP header information
            #ifndef icmp_data
            pr_retip(&icp->icmp_ip);
            #else
            pr_retip((struct ip *)icp->icmp_data, response);
            #endif
            break;
        case ICMP_SOURCEQUENCH:
            to_res(response, "Source Quench\n");
            #ifndef icmp_data
            pr_retip(&icp->icmp_ip);
            #else
            pr_retip((struct ip *)icp->icmp_data, response);
            #endif
            break;
        case ICMP_REDIRECT:
            switch(icp->icmp_code) {
                case ICMP_REDIRECT_NET:
                    to_res(response, "Redirect Network");
                    break;
                case ICMP_REDIRECT_HOST:
                    to_res(response, "Redirect Host");
                    break;
                case ICMP_REDIRECT_TOSNET:
                    to_res(response, "Redirect Type of Service and Network");
                    break;
                case ICMP_REDIRECT_TOSHOST:
                    to_res(response, "Redirect Type of Service and Host");
                    break;
                default:
                    to_res(response, "Redirect, Bad Code: %d", icp->icmp_code);
                    break;
            }
            to_res(response, "(New addr: %s)\n", inet_ntoa(icp->icmp_gwaddr));
            #ifndef icmp_data
            pr_retip(&icp->icmp_ip);
            #else
            pr_retip((struct ip *)icp->icmp_data, response);
            #endif
            break;
        case ICMP_ECHO:
            to_res(response, "Echo Request\n");
            // XXX ID + Seq + Data
            break;
        case ICMP_TIMXCEED:
            switch(icp->icmp_code) {
                case ICMP_TIMXCEED_INTRANS:
                    to_res(response, "Time to live exceeded\n");
                    break;
                case ICMP_TIMXCEED_REASS:
                    to_res(response, "Frag reassembly time exceeded\n");
                    break;
                default:
                    to_res(response, "Time exceeded, Bad Code: %d\n", icp->icmp_code);
                    break;
            }
            #ifndef icmp_data
            pr_retip(&icp->icmp_ip);
            #else
            pr_retip((struct ip *)icp->icmp_data, response);
            #endif
            break;
        case ICMP_PARAMPROB:
            to_res(response, "Parameter problem: pointer = 0x%02x\n", icp->icmp_hun.ih_pptr);
            #ifndef icmp_data
            pr_retip(&icp->icmp_ip);
            #else
            pr_retip((struct ip *)icp->icmp_data, response);
            #endif
            break;
        case ICMP_TSTAMP:
            to_res(response, "Timestamp\n");
            // XXX ID + Seq + 3 timestamps
            break;
        case ICMP_TSTAMPREPLY:
            to_res(response, "Timestamp Reply\n");
            // XXX ID + Seq + 3 timestamps
            break;
        case ICMP_IREQ:
            to_res(response, "Information Request\n");
            // XXX ID + Seq
            break;
        case ICMP_IREQREPLY:
            to_res(response, "Information Reply\n");
            // XXX ID + Seq
            break;
        case ICMP_MASKREQ:
            to_res(response, "Address Mask Request\n");
            break;
        case ICMP_MASKREPLY:
            to_res(response, "Address Mask Reply\n");
            break;
        case ICMP_ROUTERADVERT:
            to_res(response, "Router Advertisement\n");
            break;
        case ICMP_ROUTERSOLICIT:
            to_res(response, "Router Solicitation\n");
            break;
        default:
            to_res(response, "Bad ICMP type: %d\n", icp->icmp_type);
    }
}

// pr_iph --
// Print an IP header with options.
static void pr_iph(struct ip* ip, char* response) {
    u_char *cp;
    int hlen;
    
    hlen = ip->ip_hl << 2;
    cp = (u_char *)ip + 20; // point to options
    
    to_res(response, "Vr HL TOS  Len   ID Flg  off TTL Pro  cks      Src      Dst\n");
    to_res(response, " %1x  %1x  %02x %04x %04x", ip->ip_v, ip->ip_hl, ip->ip_tos, ntohs(ip->ip_len), ntohs(ip->ip_id));
    to_res(response, "   %1lx %04lx", (u_long) (ntohl(ip->ip_off) & 0xe000) >> 13, (u_long) ntohl(ip->ip_off) & 0x1fff);
    to_res(response, "  %02x  %02x %04x", ip->ip_ttl, ip->ip_p, ntohs(ip->ip_sum));
    to_res(response, " %s ", inet_ntoa(*(struct in_addr *)&ip->ip_src.s_addr));
    to_res(response, " %s ", inet_ntoa(*(struct in_addr *)&ip->ip_dst.s_addr));

    // dump any option bytes
    while (hlen-- > 20) {
        to_res(response, "%02x", *cp++);
    }

    to_res(response, "\n");
}

// pr_addr --
// Return an ascii host address as a dotted quad and optionally with a hostname.
static char* pr_addr(struct in_addr ina, char* response) {
    struct hostent *hp;
    static char buf[16 + 3 + MAXHOSTNAMELEN];
    
    if ((options & F_NUMERIC) || !(hp = gethostbyaddr((char *)&ina, 4, AF_INET)))
        return inet_ntoa(ina);
    else
        to_res(response, "%s (%s)", hp->h_name, inet_ntoa(ina)); // @todo: check for buffer overflow!

    return(buf);
}

// pr_retip --
// Dump some info on a returned (via ICMP) IP packet.
static void pr_retip(struct ip* ip, char* response) {
    u_char *cp;
    int hlen;
    
    pr_iph(ip, response);
    hlen = ip->ip_hl << 2;
    cp = (u_char *)ip + hlen;
    
    if (ip->ip_p == 6) {
        to_res(response, "TCP: from port %u, to port %u (decimal)\n", (*cp * 256 + *(cp + 1)), (*(cp + 2) * 256 + *(cp + 3)));
    }
    else if (ip->ip_p == 17) {
        to_res(response, "UDP: from port %u, to port %u (decimal)\n", (*cp * 256 + *(cp + 1)), (*(cp + 2) * 256 + *(cp + 3)));
    }
}

static char* pr_ntime (n_time timestamp, char* response) {
    static char buf[10];
    int hour, min, sec;
    
    sec = ntohl(timestamp) / 1000;
    hour = sec / 60 / 60;
    min = (sec % (60 * 60)) / 60;
    sec = (sec % (60 * 60)) % 60;
    
    to_res(response, "%02d:%02d:%02d", hour, min, sec); // @todo: check for buffer overflow!
    
    return (buf);
}

static int fill(char* bp, char* patp, char* response) {
    char *cp;
    int pat[16];
    u_int ii, jj, kk;
    
    for (cp = patp; *cp; cp++) {
        if (!isxdigit(*cp)) {
            to_res(response, "patterns must be specified as hex digits");
            return 1; // @todo: This is an ERROR that needs to bubble up to main function!
        }
    }

    ii = sscanf(patp,
                "%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x",
                &pat[0], &pat[1], &pat[2], &pat[3], &pat[4], &pat[5], &pat[6],
                &pat[7], &pat[8], &pat[9], &pat[10], &pat[11], &pat[12],
                &pat[13], &pat[14], &pat[15]);
    
    if (ii > 0)
        for (kk = 0; kk <= maxpayload - (TIMEVAL_LEN + ii); kk += ii)
            for (jj = 0; jj < ii; ++jj)
                bp[jj + kk] = pat[jj];
                if (!(options & F_QUIET)) {
                    to_res(response, "PATTERN: 0x");
                    for (jj = 0; jj < ii; ++jj)
                        to_res(response, "%02x", bp[jj] & 0xFF);
                    to_res(response, "\n");
                }
    return 0;
}

static void to_res(char* res, char* format, ...) {
    char buffer[256];
    va_list args;
    va_start(args, format);
    vsprintf(buffer, format, args);
    strcat(res, buffer);
    va_end (args);
}

#if defined(IPSEC) && defined(IPSEC_POLICY_IPSEC)
#define    SECOPT        " [-P policy]"
#else
#define    SECOPT        ""
#endif
