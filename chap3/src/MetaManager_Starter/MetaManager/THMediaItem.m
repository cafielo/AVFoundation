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
//

#import "THMediaItem.h"

#import "AVMetadataItem+THAdditions.h"
#import "NSFileManager+DirectoryLocations.h"

#define COMMON_META_KEY     @"commonMetadata"
#define AVAILABLE_META_KEY  @"availableMetadataFormats"

@interface THMediaItem ()
@property (strong) NSURL *url;
@property (strong) AVAsset *asset;
@property (strong) THMetadata *metadata;
@property (strong) NSArray *acceptedFormats;
@property BOOL prepared;
@end

@implementation THMediaItem

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        // Listing 3.3
        _url = url;
        _asset = [AVAsset assetWithURL:url];
        _filename = [self fileTypeForURL:url];
        _editable = ![_filetype isEqualToString:AVFileTypeMPEGLayer3];
        _acceptedFormats = @[
                             AVMetadataFormatQuickTimeMetadata,
                             AVMetadataFormatiTunesMetadata,
                             AVMetadataFormatID3Metadata
                             ];
    }
    return self;
}

- (NSString *)fileTypeForURL:(NSURL *)url {

    // Listing 3.3
    NSString *ext = [[self.url lastPathComponent] pathExtension];
    NSString *type = nil;
    if ([ext isEqualToString:@"m4a"]) {
        type = AVFileTypeAppleM4A;
    } else if ([ext isEqualToString:@"m4v"]) {
        type = AVFileTypeAppleM4V;
    } else if ([ext isEqualToString:@"mov"]) {
        type = AVFileTypeQuickTimeMovie;
    } else if ([ext isEqualToString:@"mp4"]) {
        type = AVFileTypeMPEG4;
    } else {
        type = AVFileTypeMPEGLayer3;
    }
    return type;
}

- (void)prepareWithCompletionHandler:(THCompletionHandler)completionHandler {
    
    // Listing 3.4
    if (self.prepared) {
        completionHandler(self.prepared);
        return;
    }
    
    self.metadata = [[THMetadata alloc] init];
    
    NSArray *keys = @[COMMON_META_KEY, AVAILABLE_META_KEY];
    
    [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        
        AVKeyValueStatus commonStatus =
        [self.asset statusOfValueForKey:COMMON_META_KEY error:nil];
        
        AVKeyValueStatus formatsStatus =
        [self.asset statusOfValueForKey:AVAILABLE_META_KEY error:nil];
        
        self.prepared = (commonStatus == AVKeyValueStatusLoaded) &&
        (formatsStatus == AVKeyValueStatusLoaded);
        
        if (self.prepared) {
            for (AVMetadataItem *item in self.asset.commonMetadata) {
                [self.metadata addMetadataItem:item withKey:item.commonKey];
            }
            
            for (id format in self.asset.availableMetadataFormats) {
                if ([self.acceptedFormats containsObject:format]) {
                    NSArray *items = [self.asset metadataForFormat:format];
                    for (AVMetadataItem *item in items) {
                        [self.metadata addMetadataItem:item
                                               withKey:item.keyString];
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(self.prepared);
        });
        
    }];
}

- (void)saveWithCompletionHandler:(THCompletionHandler)handler {

    // Listing 3.17
    
    // Header Explanation: AVAssetExportPresetPassthrough
    /* This export option will cause the media of all tracks to be passed through to the output exactly as stored in the source asset, except for
     tracks for which passthrough is not possible, usually because of constraints of the container format as indicated by the specified outputFileType.
     This option is not included in the arrays returned by -allExportPresets and -exportPresetsCompatibleWithAsset. */
    
    NSString *presetName = AVAssetExportPresetPassthrough;
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:self.asset
                                                                     presetName:presetName];
    
    NSURL *outputURL = [self tempURL];
    session.outputURL = outputURL;
    session.outputFileType = self.filetype;
    session.metadata = [self.metadata metadataItems];
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = session.status;
        BOOL success = (status == AVAssetExportSessionStatusCompleted);
        if (success) {
            NSURL *sourceURL = self.url;
            NSFileManager *manager = [NSFileManager defaultManager];
            [manager removeItemAtURL:sourceURL error:nil];
            [manager moveItemAtURL:outputURL toURL:sourceURL error:nil];
            [self reset];
        }
        
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(success);
            });
        }
    }];
    
}

- (NSURL *)tempURL {
    NSString *tempDir = NSTemporaryDirectory();
    NSString *ext = [[self.url lastPathComponent] pathExtension];
    NSString *tempName = [NSString stringWithFormat:@"temp.%@", ext];
    NSString *tempPath = [tempDir stringByAppendingPathComponent:tempName];
    return [NSURL fileURLWithPath:tempPath];
}

- (void)reset {
    _prepared = NO;
    _asset = [AVAsset assetWithURL:self.url];
}

@end
