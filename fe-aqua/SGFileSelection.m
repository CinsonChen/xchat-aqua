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

#import "SGFileSelection.h"

static NSString *fixPath (NSString *path)
{
	if ( path == nil ) return nil;
		
	if ( [path isAbsolutePath] ) return path;
	
	// Assume it's relative to the dir with the app bundle
	return [NSString stringWithFormat:@"%@/../%@", [[NSBundle mainBundle] bundlePath], path];
}

@implementation SGFileSelection

+ (NSString *) selectWithWindow:(NSWindow *) win
{
	return [self selectWithWindow:win inDirectory:nil];
}

+ (NSString *) selectWithWindow:(NSWindow *) win inDirectory:(NSString *) dir
{
	dir = fixPath (dir);
	
	NSOpenPanel *panel = [NSOpenPanel openPanel];

	[panel setCanChooseFiles:YES];
	[panel setResolvesAliases:NO];
	[panel setCanChooseDirectories:NO];
	[panel setAllowsMultipleSelection:NO];

	NSInteger sts;

	if (win)
	{
		SInt32 version = 0;
		Gestalt(gestaltSystemVersion, &version);
		if ( version > 0x1050 ) { // snow leopard
			sts = [panel runModalForDirectory:dir file:nil types:nil] == NSOKButton;
		} else {
			[panel beginSheetForDirectory:dir file:nil types:nil modalForWindow:win
						modalDelegate:nil didEndSelector:nil contextInfo:nil];
			sts = [NSApp runModalForWindow:panel];
			[NSApp endSheet:panel];
		}
	}
	else
		sts = [panel runModalForDirectory:dir file:nil types:nil] == NSOKButton;
	
	[panel orderOut:self];

	if (sts)
	{
		return [[panel filenames] objectAtIndex:0];
	}

	return nil;
}

+ (NSString *) saveWithWindow:(NSWindow *) win
{
	NSSavePanel *p = [NSSavePanel savePanel];
	
	[p setPrompt:NSLocalizedStringFromTable(@"Select", @"xchataqua", @"")];
		
	[p beginSheetForDirectory:nil file:nil
	   modalForWindow:win modalDelegate:nil didEndSelector:nil
	   contextInfo:nil];

	NSInteger sts = [NSApp runModalForWindow:p];

	[NSApp endSheet:p];
	
	[p orderOut:self];

	if (sts)
		return [p filename];
	
	return nil;
}

+ (void) getFile:(NSString *)title initial:(NSString *)initial callback:(callback_t)callback userdata:(void *)userdata flags:(int)flags
{
	id panel;
	BOOL dir=NO;
	
	if(flags & FRF_WRITE)
		panel=[NSSavePanel savePanel];
	else
		panel=[NSOpenPanel openPanel];
	
	[panel setTitle:title];
	if(initial)
		[panel setDirectory:initial];
	if(flags & FRF_MULTIPLE)
		[panel setAllowsMultipleSelection:YES];
	if(flags & FRF_CHOOSEFOLDER)
		dir=YES;
	[panel setCanChooseDirectories:dir];
	[panel setCanChooseFiles:!dir];
	
	[panel beginSheetForDirectory:nil file:nil
				   modalForWindow:nil modalDelegate:nil didEndSelector:nil
					  contextInfo:nil];
	
	NSInteger sts = [NSApp runModalForWindow:panel];
	
	[NSApp endSheet:panel];
	
	[panel orderOut:self];
	
	if (sts)
	{
		if(flags & FRF_MULTIPLE)
		{
			NSArray *filenames=[panel filenames];
			for(NSUInteger i=0;i<[filenames count];++i)
			{
				callback(userdata, (char *) [[filenames objectAtIndex:i] UTF8String]);
			}
			callback(userdata, 0);
		}else
			callback(userdata, (char *) [[panel filename] UTF8String]);
	}else
		callback(userdata, 0);
}


@end