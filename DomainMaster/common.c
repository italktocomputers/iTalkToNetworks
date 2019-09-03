//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

#include <string.h>
#include <stdlib.h>
#include "common.h"

static int type;
static char* res;
static char* error;

extern long* ntransmitted;
extern long* nreceived;

static void (^ping_notify)(char*, char*, long*, long*);
static void (^trace_notify)(char*, char*);

void init_res(int _type, char* _res, char* _error) {
    type = _type;
    res = _res;
    error = _error;
}

void set_ping_notify(void (^call)(char*, char*, long*, long*)) {
    ping_notify = call;
}

void set_trace_notify(void (^call)(char*, char*)) {
    trace_notify = call;
}

void to_res(char* format, ...) {
    char* buffer;
    va_list args;
    va_start(args, format);
    vasprintf(&buffer, format, args);
    strcat(res, buffer);
    va_end (args);
    if (type == 0) {
        ping_notify(res, error, ntransmitted, nreceived);
    }
    else if (type == 1) {
        trace_notify(res, error);
    }
}

void to_err(char* format, ...) {
    char* buffer;
    va_list args;
    va_start(args, format);
    vasprintf(&buffer, format, args);
    strcat(error, buffer);
    va_end (args);
    if (type == 0) {
        ping_notify(res, error, ntransmitted, nreceived);
    }
    else if (type == 0) {
        trace_notify(res, error);
    }
}
