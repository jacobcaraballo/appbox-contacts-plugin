#import "ContactsSettingsController.h"
#import "../ContactsView.h"

@implementation ContactsSettingsController
- (id)specifiers {
	if(_specifiers == nil) {
			NSMutableArray *array = [NSMutableArray array];
			[array addObjectsFromArray:_specifiers];
			
			PSSpecifier *header = [PSSpecifier preferenceSpecifierNamed:@"Contacts" target:self set:NULL get:NULL detail:Nil cell:PSGroupCell edit:Nil];
			[header setProperty:@"Tap and hold the phone or messages icon to reveal the contacts view" forKey:@"footerText"];
			[array addObject:header];
			
			
			PSSpecifier *favesToggle = [PSSpecifier preferenceSpecifierNamed:@"Show Favorites" target:self set:@selector(setToggleValue:specifier:) get:@selector(readToggleValue:) detail:Nil cell:PSSwitchCell edit:Nil];			
			[favesToggle setProperty:@"kFavoritesEnabled" forKey:@"id"];
			[array addObject:favesToggle];
			
			PSSpecifier *contactsToggle = [PSSpecifier preferenceSpecifierNamed:@"Show Contacts" target:self set:@selector(setToggleValue:specifier:) get:@selector(readToggleValue:) detail:Nil cell:PSSwitchCell edit:Nil];			
			[contactsToggle setProperty:@"kAllContactsEnabled" forKey:@"id"];
			[array addObject:contactsToggle];
						
			//release specifiers and recreate with new array
			[_specifiers release];
			_specifiers = nil;
			_specifiers = [[NSArray alloc] initWithArray:array];
		}
		
		return _specifiers;
}

- (void)setToggleValue:(NSNumber *)value specifier:(PSSpecifier *)specifier {
	NSMutableDictionary *settings = [[[ContactsView sharedInstance] settings] mutableCopy];
	
	[settings setObject:value forKey:[specifier identifier]];
	[self updateSettings:settings];
	
	[settings release];
	settings = nil;
}

- (NSNumber *)readToggleValue:(PSSpecifier *)specifier {
	NSDictionary *settings = [[ContactsView sharedInstance] settings];
	return [settings objectForKey:[specifier identifier]];
}

- (void)updateSettings:(NSDictionary *)settings {
	[[ContactsView sharedInstance] updateSettings:settings];
}
@end