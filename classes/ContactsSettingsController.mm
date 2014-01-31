#import "ContactsSettingsController.h"
#import "../ContactsView.h"

//this is just a PSListController being loaded into the preferences
//this is optional and if not wanted just set settingsController to nil
//specify your -settingsController in your main view

@implementation ContactsSettingsController
- (id)specifiers {
	if(_specifiers == nil) {
			NSMutableArray *array = [NSMutableArray array];
			[array addObjectsFromArray:_specifiers];
			
			PSSpecifier *header = [PSSpecifier preferenceSpecifierNamed:@"Contacts" target:self set:NULL get:NULL detail:Nil cell:PSGroupCell edit:Nil];
			[array addObject:header];
			
			
			PSSpecifier *favesToggle = [PSSpecifier preferenceSpecifierNamed:@"Show Favorites" target:self set:@selector(setToggleValue:specifier:) get:@selector(readToggleValue:) detail:Nil cell:PSSwitchCell edit:Nil];			
			[favesToggle setProperty:@"kFavoritesEnabled" forKey:@"id"];
			[array addObject:favesToggle];
			
			PSSpecifier *contactsToggle = [PSSpecifier preferenceSpecifierNamed:@"Show Contacts" target:self set:@selector(setToggleValue:specifier:) get:@selector(readToggleValue:) detail:Nil cell:PSSwitchCell edit:Nil];			
			[contactsToggle setProperty:@"kAllContactsEnabled" forKey:@"id"];
			[array addObject:contactsToggle];
			
			PSSpecifier *composeHeader = [PSSpecifier preferenceSpecifierNamed:@"Compose Sheet" target:self set:NULL get:NULL detail:Nil cell:PSGroupCell edit:Nil];
			[composeHeader setProperty:@"Enable to automatically show compose sheets when activating the specified app view." forKey:@"footerText"];
			[array addObject:composeHeader];
			
			PSSpecifier *smsToggle = [PSSpecifier preferenceSpecifierNamed:@"Messages" target:self set:@selector(setToggleValue:specifier:) get:@selector(readToggleValue:) detail:Nil cell:PSSwitchCell edit:Nil];			
			[smsToggle setProperty:@"kQuickComposeSMSEnabled" forKey:@"id"];
			[array addObject:smsToggle];
			PSSpecifier *biteToggle = [PSSpecifier preferenceSpecifierNamed:@"biteSMS" target:self set:@selector(setToggleValue:specifier:) get:@selector(readToggleValue:) detail:Nil cell:PSSwitchCell edit:Nil];			
			[biteToggle setProperty:@"kBiteSMSEnabled" forKey:@"id"];
			[array addObject:biteToggle];
			
			PSSpecifier *mailToggle = [PSSpecifier preferenceSpecifierNamed:@"Mail" target:self set:@selector(setToggleValue:specifier:) get:@selector(readToggleValue:) detail:Nil cell:PSSwitchCell edit:Nil];			
			[mailToggle setProperty:@"kQuickComposeMailEnabled" forKey:@"id"];
			[array addObject:mailToggle];
			
			PSSpecifier *footer = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:NULL get:NULL detail:Nil cell:PSGroupCell edit:Nil];
			[footer setProperty:@"Tap and hold the phone, facetime, messages or mail icon to reveal the contacts view" forKey:@"footerText"];
			[array addObject:footer];
			
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