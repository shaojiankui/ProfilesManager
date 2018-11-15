//
//  NSFileManager+Trash.m
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "NSFileManager+Trash.h"

@implementation NSFileManager (Trash)

//    This software is provided 'as-is', without any express or implied
//    warranty. In no event will the authors be held liable for any damages
//    arising from the use of this software.
//
//    Permission is granted to anyone to use this software for any purpose,
//    including commercial applications, and to alter it and redistribute it
//    freely, subject to the following restrictions:
//
//       1. The origin of this software must not be misrepresented; you must not
//       claim that you wrote the original software. If you use this software
//       in a product, an acknowledgment in the product documentation would be
//       appreciated but is not required.
//
//       2. Altered source versions must be plainly marked as such, and must not be
//       misrepresented as being the original software.
//
//       3. This notice may not be removed or altered from any source
//       distribution.
//
//获取sandbox之外的路径
- (NSString *)realHomeDirectory{
    //    struct passwd *pw = getpwuid(getuid());
    //    assert(pw);
    //    return [NSString stringWithUTF8String:pw->pw_dir];
    //
    NSString *home = NSHomeDirectory();
    NSArray *pathArray = [home componentsSeparatedByString:@"/"];
    NSString *absolutePath;
    if ([pathArray count] > 2) {
        absolutePath = [NSString stringWithFormat:@"/%@/%@", [pathArray objectAtIndex:1], [pathArray objectAtIndex:2]];
    }
    return absolutePath;
}
// Adapted from UliKit by Uli Kusterer (thanks):
// http://github.com/uliwitness/UliKit/blob/master/NSFileManager+NameForTempFile.m
NSString *Trash_RealHomeDirectory() {
    //    struct passwd *pw = getpwuid(getuid());
    //    assert(pw);
    //    return [NSString stringWithUTF8String:pw->pw_dir];
    //
    NSString *home = NSHomeDirectory();
    NSArray *pathArray = [home componentsSeparatedByString:@"/"];
    NSString *absolutePath;
    if ([pathArray count] > 2) {
        absolutePath = [NSString stringWithFormat:@"/%@/%@", [pathArray objectAtIndex:1], [pathArray objectAtIndex:2]];
    }
    return absolutePath;
}
- (NSString *)mr_uniqueFileNameWithPath:(NSString *)aPath {
	NSParameterAssert(aPath != nil);
	
	NSString *baseName = [aPath stringByDeletingPathExtension];
	NSString *suffix = [aPath pathExtension];
	NSUInteger n = 2;
	NSString *fname = aPath;
	
	while ([self fileExistsAtPath:fname]) {
		if ([suffix length] == 0)
			fname = [baseName stringByAppendingString:[NSString stringWithFormat:@" %zi", n++]];
		else
			fname = [baseName stringByAppendingString:[NSString stringWithFormat:@" %zi.%@", n++, suffix]];
		
		if (n <= 0)
			return nil;
	}
	
	return fname;
}

- (BOOL)mr_moveFileAtPathToTrash:(NSString *)aPath error:(NSError **)outError {
	NSParameterAssert(aPath != nil);
	
//	NSString *trashPath = [@"~/.Trash" stringByExpandingTildeInPath];
    NSString *trashPath = [NSString stringWithFormat:@"%@/.Trash",Trash_RealHomeDirectory()];
	NSString *proposedPath = [trashPath stringByAppendingPathComponent:[aPath lastPathComponent]];
	
	return [self moveItemAtPath:aPath
						 toPath:[self mr_uniqueFileNameWithPath:proposedPath]
						  error:outError];
}

@end
