//
//  config.h
//  HECA
//
//  Created by Chehab Mustafa Hilmy on 8/1/12.
//  Copyright (c) 2012 Freelance. All rights reserved.
//

#ifndef HECA_config_h
#define HECA_config_h


#define VERBOSE 1

#define STATUSCELL 3


#define APIURL @"http://api.chehab.me/HECA/?"
#define FORCECACHE @"cache=force&"
#define NOCACHE @"cache=false&"
#define APIKEY @"&key=94a3a5c610532a30d73c866041d8e81878db5da28d161a7cb725198a62b27421"


#if VERBOSE > 3
#define LOGFUNCTION {NSLog(@"%s", __FUNCTION__);}
#else
#define LOGFUNCTION //NOTLOGINGFUNCTION
#endif


#endif
