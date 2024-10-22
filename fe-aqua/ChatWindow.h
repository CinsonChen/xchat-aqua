/* X-Chat Aqua
 * Copyright (C) 2002 Steve Green
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */

#import "XAChatTextView.h"
#import "TabOrWindowView.h"

@class MySplitView;

@interface ChatWindow : NSObject
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
<NSTextViewDelegate,NSTextFieldDelegate,NSTableViewDataSource,NSTableViewDelegate,NSSplitViewDelegate>
#endif
{
	IBOutlet TabOrWindowView	*chatView;
	IBOutlet XAChatTextView		*chatTextView;
	IBOutlet NSTextField		*inputTextField;
	IBOutlet NSTextField		*nickTextField;
	IBOutlet NSTableView		*userlistTableView;
	IBOutlet NSScrollView		*chatScrollView;
	
	NSButton *tButton, *nButton, *sButton, *iButton, *pButton, *mButton,
			 *bButton, *lButton, *kButton, *CButton, *NButton, *uButton;
	
	IBOutlet NSTextField	*limitTextField;
	IBOutlet NSTextField	*keyTextField;

	IBOutlet NSImageView	*myOpOrVoiceIconImageView;
	IBOutlet NSTextField	*userlistStatusTextField;
	IBOutlet NSTextField	*topicTextField;
	IBOutlet SGHBoxView		*headerBoxView;
	IBOutlet MySplitView	*bodyBoxView;
	IBOutlet SGRowColView	*buttonBoxView;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSControl		*throttleIndicator;
	IBOutlet NSControl		*lagIndicator;
	IBOutlet NSPopUpButton	*sessMenuButton;
	
	NSMutableArray	*users;
	NSMenuItem		*userlistMenuItem;
	struct User		*userlistMenuItemCurrentUser;
/* CL */
	CGFloat maxNickWidth;
	CGFloat maxHostWidth;
	CGFloat maxRowHeight;
/* CL end */
	
	NSInteger completionIndex; // Current index when cycling through tab-completions.
	
	struct session *sess;
}

@property (nonatomic, readonly) TabOrWindowView *view;
@property (nonatomic, readonly) int inputTextPosition;
@property (nonatomic, assign) NSString *inputText;
@property (nonatomic, readonly) NSWindow *window;
@property (nonatomic, readonly) struct session *session;

- (IBAction) doMircColor:(id)sender;
- (IBAction) doConferenceMode:(id)sender;

- (id) initWithSession:(struct session *)sess;
- (void) insertText:(NSString *)text;
- (void) preferencesChanged;
- (void) saveBuffer:(NSString *)filename;
- (void) highlight:(NSString *)string;
- (BOOL) processFileDrop:(id<NSDraggingInfo>)info forUser:(NSString *) nick;
- (NSMenu *)menuForEvent:(NSEvent *)theEvent rowIndexes:(NSIndexSet *)rows;

// Front end methods
- (void) closeWindow;
- (void) clear:(NSUInteger)lines;
- (void) clearChannel;
- (void) printText:(NSString *)text;
- (void) printText:(NSString *)text stamp:(time_t)stamp;
- (void) setNick;
- (void) setTitle;
- (void) setHilight;
- (void) userlistInsert:(struct User *)user row:(NSInteger)row select:(BOOL)select;
- (BOOL) userlistRemove:(struct User *)user;
- (void) userlistMove:(struct User *)user row:(NSInteger)row;
- (void) userlistUpdate:(struct User *)user;
- (void) userlistNumbers;
- (void) userlistClear;
- (void) userlistRehash:(struct User *) user;
- (void) userlistSelectNames:(char **)names clear:(int)clear scrollTo:(int)scroll_to;
- (void) channelLimit;
- (void) modeButtons:(char)mode sign:(char)sign;
- (void) progressbarStart;
- (void) progressbarEnd;
- (void) setThrottle;
- (void) setChannel;
- (void) setNonchannel:(bool)state;
- (void) setTopic:(const char *)topic;
- (void) setupUserlistButtons;
- (void) setupDialogButtons;
- (void) setLag:(NSNumber *) percent;
- (void) setTabColor:(int)color flash:(BOOL)flash;
- (void) setInputTextPosition:(int)pos delta:(bool) delta;
- (void) userlistSetSelected;
- (void) doUserlistCommand:(const char *)cmd;
- (void) lastlogIntoWindow:(ChatWindow *)logWin key:(char *)ckey;

@property NSInteger completionIndex; // Current index when cycling through tab-completions.

@end
