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
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA */

#include "../common/xchat.h"
#include "../common/xchatc.h"
#include "../common/network.h"
#include "../common/dcc.h"

#import "DccRecvWin.h"

extern int dcc_getcpssum;

//////////////////////////////////////////////////////////////////////

@interface DccRecvItem : DCCFileItem
{
	NSString *from;
}

@property (nonatomic, retain) NSString *from;
		   
- (id) initWithDCC:(struct DCC *) the_dcc;
- (void) update;

@end

@implementation DccRecvItem
@synthesize from;

- (id) initWithDCC:(struct DCC *) the_dcc
{
	[super initWithDCC:the_dcc];
	
	[self update];
   
	return self;
}

- (void) dealloc
{
	self.from = nil;

	[super dealloc];
}

- (void) update
{
	[super update];
	self.from = [NSString stringWithUTF8String:dcc->nick];
}

@end

//////////////////////////////////////////////////////////////////////

@implementation DccRecvWin

+ (NSSet *) keyPathsForValuesAffectingActiveString {
	return [NSSet setWithObject:@"activeCount"];
}

- (id) init
{
	self = [super initWithNibNamed:@"DccRecv"];	/* awakeFromNib is called from inside here */
	
	return self;
}

- (DCCItem *)itemWithDCC:(struct DCC *) dcc
{
	if (dcc->type != TYPE_RECV) return nil;
	else return [[[DccRecvItem alloc] initWithDCC:dcc] autorelease];
}

- (void) awakeFromNib
{
	cpssum = &dcc_getcpssum;
	[super awakeFromNib];
	
	[dccListView setTitle:NSLocalizedStringFromTable(@"XChat: File Recieve List", @"xchataqua", @"")];
	[dccListView setTabTitle:NSLocalizedStringFromTable(@"dccrecv", @"xchataqua", @"")];
}

- (void) doReveal:(id)sender
{
	NSInteger row = [itemTableView selectedRow];
	if (row >= 0)
	{
		DccRecvItem *item = [dccItems objectAtIndex:row];
		
		// Reveal the proper file
		NSString *fileToReveal;
		if (item->dcc->dccstat == STAT_DONE)
		{
			NSString *dir = [NSString stringWithUTF8String:prefs.dcc_completed_dir];
			NSString *file = [NSString stringWithUTF8String:item->dcc->file];
			fileToReveal = [dir stringByAppendingPathComponent:file];
		}
		else
		{
			// We want destfile, not destfile_fs.
			// NSWorkspace will take care of getting the fs representation
			fileToReveal = [NSString stringWithUTF8String:item->dcc->destfile];
		}
		
		[[NSWorkspace sharedWorkspace] selectFile:fileToReveal inFileViewerRootedAtPath:nil];
	}
}

- (void) doAccept:(id)sender
{
	NSInteger row = [itemTableView selectedRow];
	if (row >= 0)
	{
		DccRecvItem *item = [dccItems objectAtIndex:row];
		struct DCC *dcc = item->dcc;
		dcc_get (dcc);
	}
}

- (void) doResume:(id)sender
{
	NSInteger row = [itemTableView selectedRow];
	if (row >= 0)
	{
		DccRecvItem *item = [dccItems objectAtIndex:row];
		struct DCC *dcc = item->dcc;
		dcc_resume (dcc);
	}
}

- (void) doInfo:(id)sender
{
	NSInteger row = [itemTableView selectedRow];
	if (row >= 0)
	{
		DccRecvItem *item = [dccItems objectAtIndex:row];

		struct DCC *dcc = item->dcc;

		NSString *msg = [NSString stringWithFormat:NSLocalizedStringFromTable(@"	  File: %@\n	  From: %s\n	  Size: %"DCC_SIZE_FMT"\n	  Port: %d\n IP Number: %s\nStart Time: %s", @"xchataqua", @""),
						 [item file], dcc->nick, dcc->size, dcc->port,
						 net_ip (dcc->addr), ctime (&dcc->starttime)];

		[SGAlert noticeWithString:msg andWait:NO];
	}
}

- (NSString *)activeString
{
	switch (activeCount) {
		case 0: return NSLocalizedStringFromTable(@"No active download", @"xchataqua", @"label of DCC Recv List: MainMenu->Window->DCC Recv List...");
		case 1: return NSLocalizedStringFromTable(@"1 active download", @"xchataqua", @"label of DCC Recv List: MainMenu->Window->DCC Recv List...");
		default:return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d active downloads", @"xchataqua", @"label of DCC Recv List: MainMenu->Window->DCC Recv List..."), activeCount];
	}
}

- (NSNumber *)globalSpeedLimit
{
	if (prefs.dcc_global_max_get_cps) return [NSNumber numberWithInt:prefs.dcc_global_max_get_cps / 1024];
	else return nil;
}

- (void)setGlobalSpeedLimit:(id)value
{
	if ([value respondsToSelector:@selector(intValue)]) prefs.dcc_global_max_get_cps = [value intValue] * 1024;
	else prefs.dcc_global_max_get_cps = 0;
}

//////////////
//

- (id) tableView:(NSTableView *)aTableView
	objectValueForTableColumn:(NSTableColumn *)aTableColumn
	row:(NSInteger) rowIndex
{
	DccRecvItem *item = [dccItems objectAtIndex:rowIndex];

	switch ([[aTableView tableColumns] indexOfObjectIdenticalTo:aTableColumn])
	{
		case 0: return [item status];
		case 1: return [item file];
		case 2: return [item size];
		case 3: return [item position];
		case 4: return [item per];
		case 5: return [item kbs];
		case 6: return [item eta];
		case 7: return [item from];
	}
	
	return @"";
}

@end
