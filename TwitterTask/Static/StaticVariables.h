//
//  StaticVariables.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import <Foundation/Foundation.h>

#ifndef TwitterTask_StaticVariables_h
#define TwitterTask_StaticVariables_h

typedef enum myLanguages{
    Arabic=0,
    English=1
}MyLanguages;

#define MenuStartX                                70

///////////////////////////////////////////////////////////////////////////////
#define nilOrJSONObjectForKey(JSON_, KEY_) [[JSON_ objectForKey:KEY_] isKindOfClass:[NSNull null]] ? nil : [JSON_ objectForKey:KEY_];



#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



/////////////////////////////////////////////////////////////////
//////////////////////View Seague constants///////////////////////
//////////////////////////////////////////////////////////////////
#define SeagueLoginScreen                          @"LoginViewController"

///////////////////////////Services general/////////////////////////////////


///////////////////////////////////web service////////////////////////////


/////////////////////////////login web service/////////////////////////////



#endif
