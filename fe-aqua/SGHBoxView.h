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

#import "SGBoxView.h"

typedef enum
{
	SGHBoxVJustificationCenter	= SGBoxMinorJustificationCenter,
	SGHBoxVJustificationTop		= SGBoxMinorJustificationFirst,
	SGHBoxVJustificationBottom	= SGBoxMinorJustificationLast,
	SGHBoxVJustificationFull	= SGBoxMinorJustificationFull,
	SGHBoxVJustificationDefault	= SGBoxMinorJustificationDefault,
}	SGHBoxVJustification;

typedef enum
{
	SGHBoxHJustificationCenter	= SGBoxMajorJustificationCenter,
	SGHBoxHJustificationRight	= SGBoxMajorJustificationLast,
	SGHBoxHJustificationLeft	= SGBoxMajorJustificationFirst,
	SGHBoxHJustificationFull	= SGBoxMajorJustificationFull,
}	SGHBoxHJustification;

@interface SGHBoxView : SGBoxView

@property (nonatomic, assign)	SGHBoxHJustification hJustification;
@property (nonatomic, readonly)	SGHBoxVJustification vJustification;
@property (nonatomic, assign)	SGBoxMargin vMargin;
@property (nonatomic, assign)	SGBoxMargin hInnerMargin;
@property (nonatomic, assign)	SGBoxMargin hOutterMargin;

- (void) setDefaultVJustification:(SGHBoxVJustification)justification;
- (void) setVJustificationFor:(NSView *)view to:(SGHBoxVJustification)justification;

@end
