//
//  PlayerViewController.h
//  MusicVk reload
//
//  Created by David Dreval on 10.02.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHRootViewController.h"
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlayerViewController : UIViewController <NSFetchedResultsControllerDelegate, AVAudioPlayerDelegate, AVAudioSessionDelegate, NSURLConnectionDelegate> {
    MPMusicPlayerController *mplayer;
    AVAudioPlayer *player;
    RevealBlock _revealBlock;
    NSMutableArray *songDictionary;
    NSURLConnection *theConnection;
    NSURLRequest *theRequest;
    NSMutableData *rData;
    UILabel *loadLabel;
    UILabel *songNumLabel;
    UILabel *songTitleLabel;
    UILabel *songArtistLabel;
    UILabel *songTime;
    UILabel *songTimeLeft;
    UIView *bottomView;
    UISlider *progressSlider;
    UISlider *volumeSlider;
    UIButton *playButton;
    UIButton *fwdButton;
    UIButton *rwdButton;
    UIButton *repeatButton;
    UIButton *randomButton;
    UIButton *saveButton;
    UIImage *playBtnBg;
    UIImage *pauseBtnBg;
    int currentNumber;
    BOOL inBackground;
    NSTimer *updateTimer;
    BOOL isRandom;
    int loops;
    float rLenght;
}

@property (nonatomic, retain) NSMutableArray *songDictionary;
@property (nonatomic, retain) NSDictionary *allSongs;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)initWithRevealBlock:(RevealBlock)revealBlock andManagedObject:(NSManagedObjectContext *)managedObjectC;

@end
