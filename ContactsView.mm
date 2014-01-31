//plugin for appbox by Jacob Caraballo
//please email admin@jacobcaraballo.com if you need help or for more plugin examples

#import "ContactsView.h"
#import "classes/ContactsSettingsController.h"

//Custom Imports
#import <AVFoundation/AVFoundation.h>
#import "substrate.h"

//helpful functions

static id lockScreenViewController() {
	return MSHookIvar<id>([objc_getClass("SBLockScreenManager") sharedInstance], "_lockScreenViewController");
}
static CGSize screenSize() {
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	
	if ([[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait) {
		screenSize.width = screenSize.height;
		screenSize.height = [UIScreen mainScreen].bounds.size.width;
	}
	
	return screenSize;
}

//Custom
#define contact_split_string @"CONTACTSPLIT||03221989||5951||JJC||03221989||CONTACTSPLIT"

//you can set custom properties/methods here, unless you need them public
@interface ContactsView() {
	NSString *primaryTitle;
	NSString *secondaryTitle;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) UITableViewCell *selectedCell;
@property (nonatomic, retain) NSMutableArray *secondarySectionValues;
@property (nonatomic, retain) NSMutableArray *primarySectionValues;
@end

@implementation ContactsView
@synthesize tweakSettings = _tweakSettings;

//custom
@synthesize tableView = _tableView;
@synthesize secondarySectionValues = _secondarySectionValues;
@synthesize selectedCell = _selectedCell;
@synthesize primarySectionValues = _primarySectionValues;

//I use this to get a hold of your object, so don't delete it
+ (id)sharedInstance {
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
     
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
     
    // executes a block object once and only once for the lifetime of an view
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
     
    // returns the same object each time
    return _sharedObject;
}

//this is the path to appbox settings
- (NSString *)tweakSettingsPath {
	return @"/var/mobile/Library/Preferences/com.zogo.appbox.plist";
}

//if you want to have customizeable options for your plugin return the settings controller class here
//if you don't want settings just return nil
- (id)settingsController {
	return [ContactsSettingsController class];
}

- (id)settings {
	//create default settings
	NSDictionary *defaultProperties = @{
		@"kFavoritesEnabled"		: @YES,
		@"kAllContactsEnabled"		: @YES,
		@"kQuickComposeSMSEnabled"	: @YES,
		@"kQuickComposeMailEnabled"	: @YES,
		@"kBiteSMSEnabled"			: @NO
	};

	NSDictionary *settings = [self.tweakSettings objectForKey:[self identifier]]; //check if settings already exist
	bool shouldUpdate = NO;
	
	//if you don't check if settings already exist, settings are not gonna update, as everytime the settings are returned it will return the primarily created settings	
	if (!settings) { //if settings don't exist, apply default settings
		settings = defaultProperties;
		shouldUpdate = YES;
	} else {
		//iterate through default settings and check to see if there are any missing keys
		//if so, apply the default value
		for (NSString *key in defaultProperties.allKeys) {
			if (![settings objectForKey:key]) {
				shouldUpdate = YES;
				
				id obj = [defaultProperties objectForKey:key];
				
				if ([obj isKindOfClass:[NSNumber class]]) {
					if (strcmp([obj objCType], @encode(BOOL)) == 0) {
						BOOL objValue = [obj boolValue];
						obj = [NSNumber numberWithBool:objValue];
					}
				}
				
				[settings setObject:[defaultProperties objectForKey:key] forKey:key];
			}
		}
	}
	
	if (shouldUpdate) {
		[self.tweakSettings setObject:settings forKey:[self identifier]];
		[self writeTweakSettings];
	}
	
	//return an autoreleased instance
	//if you want to allocate and initialize your object, then remember to release/autorelease it when returning it, as I don't do this for you
	return settings;
	/*
	!!!!! IMPORTANT !!!!!
	these settings are placed in the AppBox Preferences (self.tweakSettings) with your identifier as the key:
		->	[self.tweakSettings setObject:[self settings] forKey:[self identifier]];
	
	so, when you need to retrieve or update your settings, always set in self.tweakSettings and make sure your key is your identifier. Then you can write to file.
		-> you can simply use the following method -updateSettings: which will set your object and write to file for you
	
	--- if you use a key other than your identifier to update settings, your views settings will never update. They will remain with the default settings returned here.
	*/
}
- (void)updateSettings:(id)settings {
	if (![self settings]) return;
	[self.tweakSettings setObject:settings forKey:[self identifier]];
	[self writeTweakSettings];
}

//writes the settings to appbox's preferences
- (void)writeTweakSettings {
	[self.tweakSettings writeToFile:[self tweakSettingsPath] atomically:YES];
}

#pragma mark - main methods

//the lockscreen view
- (UIView *)lockScreenView {
	return [self.tweakView lockScreenView];
}
//you can add your plugin to either view above, as long as you remove it when your done

//update your view when the user changes device orientation
- (void)updateFrameForOrientationChange {
	//this method is called when the orientation is changing
	//I don't use it in this example because i have autoresizing on my views
}

//this returns the entire frame of the screen minus the status bar (optional)
- (CGRect)mainFrame {
	CGRect frame = CGRectMake(0,0, screenSize().width, screenSize().height);
	
	//now you can set your frame's position & dimensions
	
	//accomodate for status bar
	frame.size.height -= 20;
	frame.origin.y += 20;
	
	//return the frame
	return frame;
}

//this returns a padded frame (optional)
- (CGRect)mainFrame:(CGRect)frame WithPadding:(float)padding {
	frame.size.height -= padding*2;
	frame.size.width -= padding*2;
	frame.origin.x += padding;
	frame.origin.y += padding;
	return frame;
}

//return the application identifier of the app icon that will activate this plugin.
- (NSString *)appID {
	//you can use more than one app id by separating them with |
	return @"com.apple.mobilephone|com.apple.MobileSMS|com.apple.mobilemail|com.apple.facetime";
}

//use this to tell me that your plugin will hide and that i need to deactivate your plugin
//you call -hidePlugin and when I'm done doing what i need to do, I call -hide above. that way, everything is kept in order and the user is happy.
- (void)hidePlugin {
	[self.tableView setContentOffset:CGPointZero animated:YES];
	[self.tweakView hideActiveWidget];
}

//this is obviously the name of your plugin. If your plugin contains settings, it will appear in the AppView Settings under this name.
- (NSString *)name {
	return @"Contacts";
}

//this will return your plugin identifier. make it something super unique, because
//only one of these will be loaded if there are multiple plugins with similar id's
- (NSString *)identifier {
	return @"jacobjahzielcaraballo031989-com.zogo.appbox.plugins.contacts-imsosupercool"; //i'm sure no one has this, so looks good :)
}

//this method is called when the user taps and holds the icon with your represented appID
- (void)reveal:(NSString *)appID {
	//show your view
	//appID variable returns the application that was touched by the user (good to use if you have more than one appID for your plugin)
	if ([appID isEqualToString:@"com.apple.mobilephone"] || [appID isEqualToString:@"com.apple.facetime"]) {
		//create objects
		[self createObjects];
		
		//animate frame in
		CGRect frame = self.frame;
		frame.origin.y = 20;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		self.frame = frame;
		[UIView commitAnimations];
	} else if ([appID isEqualToString:@"com.apple.MobileSMS"]) {
		if (![[[self settings] objectForKey:@"kQuickComposeSMSEnabled"] boolValue]) {
			//i don't feel like rewriting the code in the first condition
			//so i'm just calling this method again but with a property to match the first condition
			[self reveal:@"com.apple.mobilephone"];
			return;
		}
		
		if ([[[self settings] objectForKey:@"kBiteSMSEnabled"] boolValue]) {
			[self hidePlugin];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sms:"]];
		} else
			[self textNumber:@""];
	} else if ([appID isEqualToString:@"com.apple.mobilemail"]) {
		if (![[[self settings] objectForKey:@"kQuickComposeMailEnabled"] boolValue]) {
			[self reveal:@"com.apple.mobilephone"];
			return;
		}
		
		[self sendEmail:@""];
	}
}

//this is what I call in my code to hide the view of the plugin
//please don't call this on your own, to hide the plugin, call the -hidePlugin method below.
- (void)hide {
	//you have 0.5 seconds to hide this view before I do ;)
	
	//animate frame out and destroy objects when done
	CGRect frame = self.frame;
	frame.origin.y = -frame.size.height;
	
	[UIView animateWithDuration:0.3 animations:^{
		self.frame = frame;
	} completion:^(BOOL finished){
		[self destroyObjects];
	}];
}

- (id)init {
	if (self = [super init]) {		
		//retrieve buddylock preferences
		self.tweakSettings = [[[NSMutableDictionary alloc] initWithContentsOfFile:[self tweakSettingsPath]] autorelease];
		self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
		
		//set the view ---- always use -mainFrame to set and retrieve the frame, basically leave this alone
		//calling now to set frame for primary orientation
		CGRect frame = [self mainFrame:[self mainFrame] WithPadding:5];
		frame.origin.y = -frame.size.height;
		self.frame = frame;
		
		//no need to add this view to any superview, i'll do that part :)
		
		//set background color
		//if you want the color to match the users theme, set -matchUserTheme below to YES
		self.backgroundColor = [UIColor clearColor];
				
		//custom methods can be put here
		/*
			this init method starts up with appbox, when the lock screen is loaded.
		*/
	}
	return self;
}

- (void)createObjects {
	[self setupArray];
	[self setupCancelButton];
	[self setupTableView];
}
- (void)destroyObjects {
	for(id subview in self.subviews)
		[subview removeFromSuperview];
	
	if (self.tableView) {
		[self.tableView release];
		self.tableView = nil;
	}
	
	self.primarySectionValues = nil;
	self.secondarySectionValues = nil;
	self.selectedCell = nil;
}

//do whatever you want beyond this point
- (void)setupArray {
	bool contactsEnabled = [[[self settings] objectForKey:@"kAllContactsEnabled"] boolValue];
	bool favesEnabled = [[[self settings] objectForKey:@"kFavoritesEnabled"] boolValue];
	
	self.primarySectionValues = (favesEnabled) ? [self favoritesArray] : [self contactDisplayNames];
	self.secondarySectionValues = (favesEnabled && contactsEnabled) ? [self contactDisplayNames] : nil;
	
	primaryTitle = @"";
	secondaryTitle = @"";
	
	if (favesEnabled) {
		primaryTitle = @"Favorites";
		
		if (contactsEnabled)
			secondaryTitle = @"Contacts";
	} else
		primaryTitle = @"Contacts";
	
		
	if (!favesEnabled && !contactsEnabled) {
		NSMutableDictionary *settings = [[self settings] mutableCopy];
	
		[settings setObject:@YES forKey:@"kAllContactsEnabled"];
		[self updateSettings:settings];
	
		[settings release];
		settings = nil;
	}
}
- (void)setupCancelButton {
	UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
	cancel.frame = CGRectMake(0, self.frame.size.height - 44, self.frame.size.width, 44);
	cancel.backgroundColor = [UIColor blackColor];
	[cancel setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancel addTarget:self action:@selector(hidePlugin) forControlEvents:UIControlEventTouchUpInside];
	cancel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
	[self addSubview:cancel];
}

- (void)setupTableView {
	CGRect frame = self.frame;
	
	//accomodate for cancel button
	frame.size.height -= 44;
	
	frame.origin.y = 0;
	frame.origin.x = 0;
	self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.alwaysBounceVertical = YES;
	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.canCancelContentTouches = YES;
	self.tableView.delaysContentTouches = NO;
	self.tableView.separatorColor = [UIColor clearColor];
	self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
	
	[self addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger sections = 1;
	if (self.secondarySectionValues && self.secondarySectionValues.count != 0) sections = 2;
	return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = self.secondarySectionValues.count;
	
	if (self.primarySectionValues && self.primarySectionValues.count != 0 && section == 0) rows = self.primarySectionValues.count;
	
	return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

#define cellColor [UIColor colorWithWhite:0.00f alpha:0.85f];
#define highlightColor [UIColor colorWithWhite:0.00f alpha:0.30f];

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"theCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
		cell.backgroundColor = [UIColor clearColor];
		cell.contentView.backgroundColor = cellColor;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Light" size:19.0];
		[cell.textLabel setTextColor:[UIColor colorWithWhite:0.97 alpha:1]];
		cell.detailTextLabel.hidden = YES;
		cell.detailTextLabel.alpha = 0;
	}
		
	NSString *name = [[[self.secondarySectionValues objectAtIndex:indexPath.row] componentsSeparatedByString:contact_split_string] objectAtIndex:0];
	NSString *identifier = [[[self.secondarySectionValues objectAtIndex:indexPath.row] componentsSeparatedByString:contact_split_string] objectAtIndex:1];
	
	if (self.primarySectionValues && self.primarySectionValues.count != 0 && indexPath.section == 0) {
		name = [[[self.primarySectionValues objectAtIndex:indexPath.row] componentsSeparatedByString:contact_split_string] objectAtIndex:0];
		identifier = [[[self.primarySectionValues objectAtIndex:indexPath.row] componentsSeparatedByString:contact_split_string] objectAtIndex:1];
	}
	
	cell.textLabel.text = name;
	cell.detailTextLabel.text = identifier;
	return cell;
}
- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.selectedCell) {
		self.selectedCell.contentView.backgroundColor = cellColor;
		self.selectedCell = nil;
	}
	
	self.selectedCell = [tableView cellForRowAtIndexPath:indexPath];
	self.selectedCell.contentView.backgroundColor = highlightColor;
}
- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.selectedCell) self.selectedCell.contentView.backgroundColor = cellColor;
	self.selectedCell = nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	[self contactPerson:cell];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 35)] autorelease];
	headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[headerView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.3f]];
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 8, tableView.bounds.size.width, 18)] autorelease];
	
	NSString *title = secondaryTitle;
	if (self.primarySectionValues && self.primarySectionValues.count != 0 && section == 0) title = primaryTitle;
	
	label.text = title;
	label.textColor = [UIColor colorWithWhite:0.97 alpha:1];
	label.textAlignment = NSTextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
	[headerView addSubview:label];
	
	return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 35;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = secondaryTitle;
	if (self.primarySectionValues && self.primarySectionValues.count != 0 && section == 0) title = primaryTitle;
	return title;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if (self.selectedCell) self.selectedCell.contentView.backgroundColor = cellColor;
	self.selectedCell = nil;
}

//semi-dirty hack to prevent empty cells from showing :)
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0.01f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[[UIView alloc] init] autorelease];
	view.backgroundColor = [UIColor clearColor];
    return view;
}

//mark - contacts
- (NSArray *)favoritesArray {
	NSMutableArray *contacts = [[NSMutableArray alloc] init];
	
	for (id entry in [[objc_getClass("ABFavoritesListManager") sharedInstance] entries]) {
		NSString *contact = [NSString stringWithFormat:@"%@%@%@", [entry displayName], contact_split_string, [NSString stringWithFormat:@"%d", [entry _abUid]]];
		[contacts addObject:contact];
	}
	
	if (contacts.count != 0) return [contacts autorelease];
	
	[contacts release];
	contacts = nil;
	return nil;
}
- (NSDictionary *)getAllContacts {
	NSMutableDictionary *allContacts = [[NSMutableDictionary alloc] init];
	NSArray *people = [objc_getClass("IMPerson") allPeople];
	
	if (!people || people.count == 0) {
        [allContacts release];
        allContacts = nil;
		return nil;
	}
	
	for (int i = 0; i < people.count; i++) {
		IMPerson *person = [people objectAtIndex:i];
		NSArray *emails = [person emails];
		NSArray *phoneNumbers = [person phoneNumbers];
		NSString *name = [person displayName];
		NSString *recordID = [NSString stringWithFormat:@"%d", [person recordID]];
		
		NSMutableDictionary *dictPerson = [[NSMutableDictionary alloc] init];
		[dictPerson setObject:recordID forKey:@"id"];
		[dictPerson setObject:name forKey:@"name"];
		[dictPerson setObject:phoneNumbers  forKey:@"numbers"];
		[dictPerson setObject:emails forKey:@"emails"];
		[allContacts setObject:dictPerson forKey:recordID];
		if (dictPerson) [dictPerson release];
		dictPerson = nil;
	}
	return [allContacts autorelease];
}
- (NSArray *)contactDisplayNames {
	NSDictionary *contacts = [self getAllContacts];
	NSMutableArray *displayNames = [[NSMutableArray alloc] initWithCapacity:contacts.count];
	
	for (NSString *key in contacts) {
		NSString *name = [[contacts objectForKey:key] objectForKey:@"name"];
		NSString *identifier = [[contacts objectForKey:key] objectForKey:@"id"];
		NSString *contact = [NSString stringWithFormat:@"%@%@%@", name, contact_split_string, identifier];
		[displayNames addObject:contact];
	}
	
	if (displayNames.count != 0) {
		return [[displayNames autorelease] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	}
	
	[displayNames release];
	displayNames = nil;
	
	return nil;
}
- (NSArray *)numbersForContact:(NSString *)identifier {
	return [[[self getAllContacts] objectForKey:identifier] objectForKey:@"numbers"];
}
- (NSArray *)emailsForContact:(NSString *)identifier {
	return [[[self getAllContacts] objectForKey:identifier] objectForKey:@"emails"];
}
- (bool)contactsExist {
	NSDictionary *allContacts = [self getAllContacts];
	return !(!allContacts || allContacts.count == 0);
}
- (void)callNumber:(NSString *)number {
	[self hidePlugin];
	CTCallDial(number);
}
- (void)disconnectCall {
	CTCallListDisconnectAll();
}
- (void)textNumber:(NSString *)number {
	[self hidePlugin];
	
	if ([MFMessageComposeViewController canSendText]) {
		MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
		picker.messageComposeDelegate = self;
		
		if (number && ![number isEqualToString:@""])
			[picker setRecipients:[NSArray arrayWithObject:number]];
		
		[lockScreenViewController() presentViewController:picker animated:YES completion:nil];
		[picker release];
	}
}
- (void)sendEmail:(NSString *)email {
	[self hidePlugin];
	
	if([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
				
		if (email && ![email isEqualToString:@""])
			[picker setToRecipients:[NSArray arrayWithObject:email]];
		
		[lockScreenViewController() presentViewController:picker animated:YES completion:nil];
		[picker release];
	}
}
- (void)contactPerson:(UITableViewCell *)contact {
	NSString *name = contact.textLabel.text;
	NSString *identifier = contact.detailTextLabel.text;
	
	NSMutableArray *phoneNumbers = [self numbersForContact:identifier].mutableCopy;
	NSMutableArray *emails = [self emailsForContact:identifier].mutableCopy;
	
	NSString *phone = nil;
	BOOL phoneIsNumber = YES;
	BOOL noNumber = NO;

	if ((!phoneNumbers || phoneNumbers.count == 0) && (!emails || emails.count == 0)) {
		phoneIsNumber = NO;
		phone = @"No Number";
	}
			
	if (phoneNumbers.count != 0) {
		phone = [phoneNumbers objectAtIndex:0];
		[phoneNumbers removeObjectAtIndex:0];
	}
		
	if (!phone || [phone isEqualToString:@""]) {
		phoneIsNumber = NO;
		phone = [emails objectAtIndex:0];
		[emails removeObjectAtIndex:0];
	}
		
	NSString *actionSheetTitle = name;
	NSString *destructiveTitle = [NSString stringWithFormat:@"%@%@", (phoneIsNumber) ? @"Call " : @"", phone];
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:destructiveTitle otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
	//add first text
	if (phoneIsNumber) [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Text %@", phone]];
	for (NSString *obj in phoneNumbers) {
		[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Call %@", obj]];
		[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Text %@", obj]];
	}
	
	for (NSString *obj in emails) if (obj.length != 0) [actionSheet addButtonWithTitle:obj];
	
	if (!noNumber) {
		[actionSheet addButtonWithTitle:@"Cancel"];
		[actionSheet setCancelButtonIndex:actionSheet.numberOfButtons-1];
	}
	
	[actionSheet showInView:[self lockScreenView]];
}
//mark - contact delegates
- (NSString *)strippedString:(NSString *)string {
	NSMutableString *strippedString = [NSMutableString stringWithCapacity:string.length];
	NSScanner *scanner = [NSScanner scannerWithString:string];
	NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"+,;*#0123456789"];

	while ([scanner isAtEnd] == NO) {
	  NSString *buffer;
	  if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) [strippedString appendString:buffer];
	  else [scanner setScanLocation:([scanner scanLocation] + 1)];
	}

	return strippedString;
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
	if (![title isEqualToString:@"Cancel"] && ![title isEqualToString:@"No Number"]) {
		NSString *number = [self strippedString:title];
		if ([title rangeOfString:@"Call"].location != NSNotFound) [self callNumber:number];
		else if ([title rangeOfString:@"Text"].location != NSNotFound) [self textNumber:number];
		else [self sendEmail:title];
	}
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[controller dismissViewControllerAnimated:YES completion:NULL];
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {	
	[controller dismissViewControllerAnimated:YES completion:NULL];
}
//endmark
//endmark

//cleanup
- (void)dealloc {
	if (self.tableView) [self.tableView release];
	self.tableView = nil;
	
	self.secondarySectionValues = nil;
	self.selectedCell = nil;
	
	[super dealloc];
}

@end