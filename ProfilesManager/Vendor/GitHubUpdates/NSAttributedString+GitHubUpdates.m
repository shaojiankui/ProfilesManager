/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2017 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

/*!
 * @file        NSAttributedString+GitHubUpdates.m
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import "NSAttributedString+GitHubUpdates.h"
#import "NSMutableAttributedString+GitHubUpdates.h"

@interface NSAttributedString( GitHubUpdates_Private )

+ ( NSDictionary * )markdownAttributesForRegularText;
+ ( NSDictionary * )markdownAttributesForBoldText;
+ ( NSDictionary * )markdownAttributesForItalicText;
+ ( NSDictionary * )markdownAttributesForCodeText;
+ ( NSDictionary * )markdownAttributesForHeading1;
+ ( NSDictionary * )markdownAttributesForHeading2;
+ ( NSDictionary * )markdownAttributesForHeading3;
+ ( NSDictionary * )markdownAttributesForHeading4;
+ ( NSDictionary * )markdownAttributesForHeading5;
+ ( NSDictionary * )markdownAttributesForHeading6;

@end

@implementation NSAttributedString( GitHubUpdates )

+ ( NSAttributedString * )attributedStringFromMarkdownString: ( NSString * )md
{
    NSMutableAttributedString * ret;
    
    md  = [ md stringByTrimmingCharactersInSet: [ NSCharacterSet newlineCharacterSet ] ];
    ret = [ [ NSMutableAttributedString alloc ] initWithString: md attributes: [ self markdownAttributesForRegularText ] ];
    
    [ ret processMarker: @"**" attributes: [ self markdownAttributesForBoldText ] ];
    [ ret processMarker: @"__" attributes: [ self markdownAttributesForBoldText ] ];
    [ ret processMarker: @"*"  attributes: [ self markdownAttributesForItalicText ] ];
    [ ret processMarker: @"_"  attributes: [ self markdownAttributesForItalicText ] ];
    [ ret processMarker: @"`"  attributes: [ self markdownAttributesForCodeText ] ];
    
    [ ret processLineStart: @"# "      attributes: [ self markdownAttributesForHeading1 ] ];
    [ ret processLineStart: @"## "     attributes: [ self markdownAttributesForHeading2 ] ];
    [ ret processLineStart: @"### "    attributes: [ self markdownAttributesForHeading3 ] ];
    [ ret processLineStart: @"#### "   attributes: [ self markdownAttributesForHeading4 ] ];
    [ ret processLineStart: @"##### "  attributes: [ self markdownAttributesForHeading5 ] ];
    [ ret processLineStart: @"###### " attributes: [ self markdownAttributesForHeading6 ] ];
    
    return ret;
}

@end

@implementation NSAttributedString( GitHubUpdates_Private )

+ ( NSDictionary * )markdownAttributesForRegularText
{
    return
    @{
        NSFontAttributeName            : [ NSFont systemFontOfSize: 10 weight: NSFontWeightThin ],
        NSForegroundColorAttributeName : [ NSColor textColor ]
    };
}

+ ( NSDictionary * )markdownAttributesForBoldText
{
    return
    @{
        NSFontAttributeName            : [ NSFont systemFontOfSize: 10 weight: NSFontWeightBold ],
        NSForegroundColorAttributeName : [ NSColor textColor ]
    };
}

+ ( NSDictionary * )markdownAttributesForItalicText
{
    NSFont * font;
    
    font = [ NSFont systemFontOfSize: 10 weight: NSFontWeightThin ];
    font = [ [ NSFontManager sharedFontManager ] convertFont: font toHaveTrait: NSItalicFontMask ];
    
    return
    @{
        NSFontAttributeName            : font,
        NSForegroundColorAttributeName : [ NSColor textColor ]
    };
}

+ ( NSDictionary * )markdownAttributesForCodeText
{
    NSFont  * font;
    NSColor * foreground;
    
    font       = [ NSFont fontWithName: @"Menlo" size: 10 ];
    foreground = [ NSColor colorWithDeviceRed: 199.0 / 255.0 green:  37.0 / 255.0 blue:  78.0 / 255.0 alpha: 1.0 ];
    
    return @{ NSFontAttributeName : font, NSForegroundColorAttributeName : foreground };
}

+ ( NSDictionary * )markdownAttributesForHeading1
{
    return
    @{
        NSFontAttributeName            : [ NSFont systemFontOfSize: 20 weight: NSFontWeightRegular ],
        NSForegroundColorAttributeName : [ NSColor textColor ]
    };
}

+ ( NSDictionary * )markdownAttributesForHeading2
{
    return
    @{
        NSFontAttributeName            : [ NSFont systemFontOfSize: 18 weight: NSFontWeightRegular ],
        NSForegroundColorAttributeName : [ NSColor textColor ]
    };
}

+ ( NSDictionary * )markdownAttributesForHeading3
{
    return
    @{
        NSFontAttributeName            : [ NSFont systemFontOfSize: 16 weight: NSFontWeightRegular ],
        NSForegroundColorAttributeName : [ NSColor textColor ]
    };
}

+ ( NSDictionary * )markdownAttributesForHeading4
{
    return
    @{
        NSFontAttributeName            : [ NSFont systemFontOfSize: 14 weight: NSFontWeightRegular ],
        NSForegroundColorAttributeName : [ NSColor textColor ]
    };
}

+ ( NSDictionary * )markdownAttributesForHeading5
{
    return
    @{
        NSFontAttributeName            : [ NSFont systemFontOfSize: 12 weight: NSFontWeightRegular ],
        NSForegroundColorAttributeName : [ NSColor textColor ]
    };
}

+ ( NSDictionary * )markdownAttributesForHeading6
{
    return
    @{
        NSFontAttributeName            : [ NSFont systemFontOfSize: 10 weight: NSFontWeightRegular ],
        NSForegroundColorAttributeName : [ NSColor textColor ]
    };
}

@end
