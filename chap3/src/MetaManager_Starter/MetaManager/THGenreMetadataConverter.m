//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "THGenreMetadataConverter.h"
#import "THGenre.h"

@implementation THGenreMetadataConverter

- (id)displayValueFromMetadataItem:(AVMetadataItem *)item {
    
    // Listing 3.15
    THGenre *genre = nil;
    
    if ([item.value isKindOfClass:[NSString class]]) {
        if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
            if (item.numberValue) {
                NSUInteger genreIndex = [item.numberValue unsignedIntValue];
                genre = [THGenre id3GenreWithIndex:genreIndex];
            } else {
                genre = [THGenre id3GenreWithName:item.stringValue];
            }
        } else {
            genre = [THGenre videoGenreWithName:item.stringValue];
        }
    }
    else if ([item.value isKindOfClass:[NSData class]]) {
        NSData *data = item.dataValue;
        if (data.length == 2) {
            uint16_t *values = (uint16_t *)[data bytes];
            uint16_t genreIndex = CFSwapInt16BigToHost(values[0]);
            genre = [THGenre iTunesGenreWithIndex:genreIndex];
        }
    }
    return genre;
}

- (AVMetadataItem *)metadataItemFromDisplayValue:(id)value
                                withMetadataItem:(AVMetadataItem *)item {
    
    // Listing 3.15
    AVMutableMetadataItem *metadataItem = [item mutableCopy];
    THGenre *genre = (THGenre *)value;
    if ([item.value isKindOfClass:[NSString class]]) {
        metadataItem.value = genre.name;
    }
    else if ([item.value isKindOfClass:[NSData class]]) {
        NSData *data = item.dataValue;
        if (data.length == 2) {
            uint16_t value = CFSwapInt16HostToBig(genre.index + 1);
            size_t length = sizeof(value);
            metadataItem.value = [NSData dataWithBytes:&value length:length];
        }
    }
    return metadataItem;
}

@end
