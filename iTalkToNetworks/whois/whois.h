//
//  whois.h
//  DomainMaster
//
//  Created by Laura Schools on 8/13/19.
//  Copyright © 2019 Andrew Schools. All rights reserved.
//

#ifndef whois_h
#define whois_h

#include <stdio.h>
#include "common.h"

int start_whois(int, char**, char*, char*);
static char *choose_server(char *);
static struct addrinfo *gethostinfo(char const *host, int exit_on_error);
static void s_asprintf(char **ret, const char *format, ...) __attribute__((__format__(printf, 2, 3)));
static void whois(const char *, const char *, int);

#endif /* whois_h */
