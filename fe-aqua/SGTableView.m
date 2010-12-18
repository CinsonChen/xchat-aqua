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

#import "SGTableView.h"

@implementation SGTableView

- (void) dealloc
{
	if (timer)
	{
		[timer invalidate];
	}
	[super dealloc];
}

- (void) sizeFixups:(id)sender
{
	[timer invalidate];
	timer = nil;
	
	NSTableColumn *column = [[self tableColumns] lastObject];
	id cell = [column dataCell];
	
	CGFloat width = 0;
	CGFloat height = 16;
	
	id datasource = [self dataSource];
	BOOL do_hints = [datasource respondsToSelector:@selector(tableView:sizeHintForTableColumn:row:)];
	
	for (NSInteger i = 0; i < [self numberOfRows]; i ++)
	{
		NSSize size = NSZeroSize;
		
		if (do_hints)
			size = [datasource tableView:self sizeHintForTableColumn:nil row:i];
		
		if (size.width == 0 && size.height == 0)
		{
			id val = [[self dataSource] tableView:self objectValueForTableColumn:column row:i];
			[cell setObjectValue:val];
			size = [cell cellSize];
			
			if (do_hints)
				[datasource tableView:self sizeHintForTableColumn:nil row:i size:size];
		}
		
		if (size.width > width)
			width = size.width;
		if (size.height > height)
			height = size.height;
	}
	
	[column setWidth:width];
	if (height != [self rowHeight])
		[self setRowHeight:height];
}

- (void) startTimer
{
	id<NSObject> dataSource = [self dataSource];
	BOOL do_fixups = [dataSource respondsToSelector:@selector(shouldDoSizeFixupsForTableView:)]
				  && [dataSource performSelector:@selector(shouldDoSizeFixupsForTableView:) withObject:self];
	if (!do_fixups) return;

	if (timer == nil)
		timer = [NSTimer scheduledTimerWithTimeInterval:1.0
												 target:self
											   selector:@selector(sizeFixups:)
											   userInfo:nil
												repeats:NO];
}

- (void) reloadData
{
	[self startTimer];
	[super reloadData];
}

-(void) textDidEndEditing:(NSNotification*) notification 
{
	if ([[[notification userInfo] objectForKey:@"NSTextMovement"] integerValue] == NSReturnTextMovement)
	{
		NSMutableDictionary *newUserInfo = [NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
		[newUserInfo setObject:[NSNumber numberWithInt:NSIllegalTextMovement] forKey:@"NSTextMovement"];
		notification = [NSNotification notificationWithName:[notification name]
													 object:[notification object]
												   userInfo:newUserInfo];
		[super textDidEndEditing:notification];
		[[self window] makeFirstResponder:self];
		[self startTimer];
	}
	else
		[super textDidEndEditing:notification];
}

@end