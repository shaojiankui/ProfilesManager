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
 * @file        NSMutableAttributedString+GitHubUpdates.m
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import "NSMutableAttributedString+GitHubUpdates.h"

@implementation NSMutableAttributedString( GitHubUpdates )

- ( void )processMarker: ( NSString * )marker attributes: ( NSDictionary * )attributes
{
    NSUInteger start;
    NSRange    r1;
    NSRange    r2;
    
    start = 0;
    
    while( 1 )
    {
        r1 = [ self.string rangeOfString: marker options: ( NSStringCompareOptions )0 range: NSMakeRange( start, self.string.length - start ) ];

        if( r1.location == NSNotFound )
        {
            break;
        }
        
        r2 = [ self.string rangeOfString: marker options: ( NSStringCompareOptions )0 range: NSMakeRange( r1.location + marker.length, self.string.length - ( r1.location + marker.length )) ];
        
        if( r2.location == NSNotFound )
        {
            break;
        }
        
        [ self setAttributes: attributes range: NSMakeRange( r1.location, r2.location - r1.location ) ];
        [ self deleteCharactersInRange: NSMakeRange( r2.location, marker.length ) ];
        [ self deleteCharactersInRange: NSMakeRange( r1.location, marker.length ) ];
        
        start = r2.location + r2.length;
    }
}

- ( void )processLineStart: ( NSString * )lineStart attributes: ( NSDictionary * )attributes
{
    NSUInteger start;
    NSRange    r1;
    NSRange    r2;
    
    [ self insertAttributedString: [ [ NSAttributedString alloc ] initWithString: @"\n" ] atIndex: 0 ];
    
    start     = 0;
    lineStart = [ NSString stringWithFormat: @"\n%@", lineStart ];
    
    while( 1 )
    {
        r1 = [ self.string rangeOfString: lineStart options: ( NSStringCompareOptions )0 range: NSMakeRange( start, self.string.length - start ) ];
        
        if( r1.location == NSNotFound )
        {
            break;
        }
        
        r2 = [ self.string rangeOfString: @"\n" options: ( NSStringCompareOptions )0 range: NSMakeRange( r1.location + lineStart.length, self.string.length - ( r1.location + lineStart.length )) ];
        
        if( r2.location == NSNotFound )
        {
            break;
        }
        
        [ self setAttributes: attributes range: NSMakeRange( r1.location, r2.location - r1.location ) ];
        [ self deleteCharactersInRange: NSMakeRange( r1.location + 1, lineStart.length - 1 ) ];
        
        start = r2.location + r2.length;
    }
    
    [ self deleteCharactersInRange: NSMakeRange( 0, 1 ) ];
}

@end
