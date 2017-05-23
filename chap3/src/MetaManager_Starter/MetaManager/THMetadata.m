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

#import "THMetadata.h"
#import "THMetadataConverterFactory.h"
#import "THMetadataKeys.h"

@interface THMetadata ()
@property (strong) NSDictionary *keyMapping;
@property (strong) NSMutableDictionary *metadata;
@property (strong) THMetadataConverterFactory *converterFactory;
@end

@implementation THMetadata

- (id)init {
    self = [super init];
    if (self) {
        
        // Listing 3.6
        _keyMapping = [self buildKeyMapping];
        _metadata = [NSMutableDictionary dictionary];
        _converterFactory = [[THMetadataConverterFactory alloc] init];
    }
    return self;
}

- (NSDictionary *)buildKeyMapping {

    return @{
        // Name Mapping
        AVMetadataCommonKeyTitle : THMetadataKeyName,

        // Artist Mapping
        AVMetadataCommonKeyArtist : THMetadataKeyArtist,
        AVMetadataQuickTimeMetadataKeyProducer : THMetadataKeyArtist,

        // Album Artist Mapping
        AVMetadataID3MetadataKeyBand : THMetadataKeyAlbumArtist,
        AVMetadataiTunesMetadataKeyAlbumArtist : THMetadataKeyAlbumArtist,
        @"TP2" : THMetadataKeyAlbumArtist,

        // Album Mapping
        AVMetadataCommonKeyAlbumName : THMetadataKeyAlbum,

        // Artwork Mapping
        AVMetadataCommonKeyArtwork : THMetadataKeyArtwork,

        // Year Mapping
        AVMetadataCommonKeyCreationDate : THMetadataKeyYear,
        AVMetadataID3MetadataKeyYear : THMetadataKeyYear,
        @"TYE" : THMetadataKeyYear,
        AVMetadataQuickTimeMetadataKeyYear : THMetadataKeyYear,
        AVMetadataID3MetadataKeyRecordingTime : THMetadataKeyYear,

        // BPM Mapping
        AVMetadataiTunesMetadataKeyBeatsPerMin : THMetadataKeyBPM,
        AVMetadataID3MetadataKeyBeatsPerMinute : THMetadataKeyBPM,
        @"TBP" : THMetadataKeyBPM,

        // Grouping Mapping
        AVMetadataiTunesMetadataKeyGrouping : THMetadataKeyGrouping,
        @"@grp" : THMetadataKeyGrouping,
        AVMetadataCommonKeySubject : THMetadataKeyGrouping,

        // Track Number Mapping
        AVMetadataiTunesMetadataKeyTrackNumber : THMetadataKeyTrackNumber,
        AVMetadataID3MetadataKeyTrackNumber : THMetadataKeyTrackNumber,
        @"TRK" : THMetadataKeyTrackNumber,

        // Composer Mapping
        AVMetadataQuickTimeMetadataKeyDirector : THMetadataKeyComposer,
        AVMetadataiTunesMetadataKeyComposer : THMetadataKeyComposer,
        AVMetadataCommonKeyCreator : THMetadataKeyComposer,

        // Disc Number Mapping
        AVMetadataiTunesMetadataKeyDiscNumber : THMetadataKeyDiscNumber,
        AVMetadataID3MetadataKeyPartOfASet : THMetadataKeyDiscNumber,
        @"TPA" : THMetadataKeyDiscNumber,

        // Comments Mapping
        @"ldes" : THMetadataKeyComments,
        AVMetadataCommonKeyDescription : THMetadataKeyComments,
        AVMetadataiTunesMetadataKeyUserComment : THMetadataKeyComments,
        AVMetadataID3MetadataKeyComments : THMetadataKeyComments,
        @"COM" : THMetadataKeyComments,

        // Genre Mapping
        AVMetadataQuickTimeMetadataKeyGenre : THMetadataKeyGenre,
        AVMetadataiTunesMetadataKeyUserGenre : THMetadataKeyGenre,
        AVMetadataCommonKeyType : THMetadataKeyGenre
    };
}


- (void)addMetadataItem:(AVMetadataItem *)item withKey:(id)key {

    // Listing 3.7
    NSString *normalizedKey = self.keyMapping[key];
    
    if (normalizedKey) {
        
        id <THMetadataConverter> converter =
        [self.converterFactory converterForKey:normalizedKey];
        
        // Extract and convert
        id value = [converter displayValueFromMetadataItem:item];
        
        // Set values into Dictionary
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *data = (NSDictionary *) value;
            for (NSString *currentKey in data) {
                if (![data[currentKey] isKindOfClass:[NSNull class]]) {
                    [self setValue:data[currentKey] forKey:currentKey];
                }
            }
        } else {
            [self setValue:value forKey:normalizedKey];
        }
        
        // Store
        self.metadata[normalizedKey] = item;
    }
    
}

- (NSArray *)metadataItems {

    // Listing 3.16
    NSMutableArray *items = [NSMutableArray array];
    [self addMetadataItemForNumber:self.trackNumber
                             count:self.trackCount
                         numberKey:THMetadataKeyTrackNumber
                          countKey:THMetadataKeyTrackCount
                           toArray:items];
    
    [self addMetadataItemForNumber:self.discNumber
                             count:self.discCount
                         numberKey:THMetadataKeyDiscNumber
                          countKey:THMetadataKeyDiscCount
                           toArray:items];
    
    NSMutableDictionary *metaDict = [self.metadata mutableCopy];
    [metaDict removeObjectForKey:THMetadataKeyTrackNumber];
    [metaDict removeObjectForKey:THMetadataKeyDiscNumber];
    
    for (NSString *key in metaDict) {
        id <THMetadataConverter> converter =
        [self.converterFactory converterForKey:key];
        id value = [self valueForKey:key];
        
        AVMetadataItem *item = [converter metadataItemFromDisplayValue:value
                                                      withMetadataItem:metaDict[key]];
        if (item) {
            [items addObject:item];
        }
    }
    return items;
}
- (void)addMetadataItemForNumber:(NSNumber *)number
                           count:(NSNumber *)count
                       numberKey:(NSString *)numberKey
                        countKey:(NSString *)countKey
                         toArray:(NSMutableArray *)items {
    
    id <THMetadataConverter> converter =
    [self.converterFactory converterForKey:numberKey];
    
    NSDictionary *data = @{numberKey: number ?: [NSNull null],
                           countKey: count ?: [NSNull null]};
    
    AVMetadataItem *sourceItem = self.metadata[numberKey];
    
    AVMetadataItem *item =
    [converter metadataItemFromDisplayValue:data
                           withMetadataItem:sourceItem];
    if (item) {
        [items addObject:item];
    }
}

@end
