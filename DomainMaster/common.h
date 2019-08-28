//
//  Created by Andrew Schools on 6/6/19.
//  Copyright © 2019 iTalkToComputers. All rights reserved.
//

#ifndef common_h
#define common_h

#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>

void init_res(int, char*, char*);
void to_res(char*, ...);
void to_err(char*, ...);
void set_ping_notify(void (^ping_notify)(char*, char*, long*, long*));
void set_trace_notify(void (^trace_notify)(char*, char*));

#endif /* common_h */
