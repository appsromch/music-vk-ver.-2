//
//  PlayerViewController.m
//  MusicVk reload
//
//  Created by David Dreval on 10.02.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "PlayerViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DirectionPanGestureRecognizer.h"

@interface PlayerViewController ()

@end

@implementation PlayerViewController
@synthesize songDictionary, allSongs, managedObjectContext, fetchedResultsController, back;

- (id)initWithRevealBlock:(RevealBlock)revealBlock andManagedObject:(NSManagedObjectContext *)managedObjectC
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSLog(@"player inited");
        _revealBlock = [revealBlock copy];
        managedObjectContext = managedObjectC;
        songDictionary = [[NSMutableArray alloc] init];
        self.fetchedResultsController = [self fetchedResultsController];
        [[AVAudioSession sharedInstance] setDelegate: self];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newSong:)
                                                     name:@"newSong"
                                                   object:nil];
        
        isRandom = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRandom"];
        loops = [[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"isRepeat"]] intValue];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didGetPlayerPlay)
                                                     name:@"PlayerPlay"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didGetPlayerRwd)
                                                     name:@"PlayerRwd"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didGetPlayerFwd)
                                                     name:@"PlayerFwd"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeChanged:)
                                                name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                   object:nil];
        mplayer = [MPMusicPlayerController iPodMusicPlayer];
        [self performSelectorOnMainThread:@selector(customMake2) withObject:self waitUntilDone:YES];
        [self registerForBackgroundNotifications];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self.navigationController.navigationBar setHidden:YES];
    [super viewDidLoad];
    
}

- (void) customMake2 {
    [self.navigationController.navigationBar setHidden:YES];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[ud objectForKey:@"bgPic"]]]];
    circleView = [[circle alloc] initWithFrame:self.view.bounds];
    //[m_testView setAlpha:0.3];
    circleView.percent = 100;
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    songTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, screen.size.height/2 - 60, 280, 50)];
    songArtistLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, screen.size.height/2 - 10, 280, 40)];
    
    songTime = [[UILabel alloc] initWithFrame:CGRectMake(screen.size.width/2 - 40, screen.size.height/2 + 40, 55, 30)];
    [songTime setBackgroundColor:[UIColor clearColor]];
    [songTime setTextAlignment:NSTextAlignmentCenter];
    [songTime setTextColor:[UIColor colorWithWhite:1 alpha:0.5]];
    [songTime setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [songTime setText:@"00:00 /"];
    
    songTimeLeft = [[UILabel alloc] initWithFrame:CGRectMake(screen.size.width/2, screen.size.height/2 + 40, 40, 30)];
    [songTimeLeft setBackgroundColor:[UIColor clearColor]];
    [songTimeLeft setTextAlignment:NSTextAlignmentCenter];
    [songTimeLeft setTextColor:[UIColor colorWithWhite:1 alpha:0.5]];
    [songTimeLeft setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [songTimeLeft setText:@"00:00"];
    
    [songTitleLabel setBackgroundColor:[UIColor clearColor]];
    [songTitleLabel setNumberOfLines:0];
    [songTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [songTitleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:20]];
    [songTitleLabel setTextColor:[UIColor colorWithWhite:1 alpha:1]];
    [songTitleLabel setNumberOfLines:2];
   // [songTitleLabel setShadowColor:[UIColor blackColor]];
   // [songTitleLabel setShadowOffset:CGSizeMake(0, 1)];
    [songTitleLabel setText:@""];
    
    [songArtistLabel setBackgroundColor:[UIColor clearColor]];
    [songArtistLabel setNumberOfLines:0];
    [songArtistLabel setTextAlignment:NSTextAlignmentCenter];
    [songArtistLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:14]];
    [songArtistLabel setTextColor:[UIColor colorWithWhite:1 alpha:1]];
  //  [songArtistLabel setShadowColor:[UIColor blackColor]];
  //  [songArtistLabel setShadowOffset:CGSizeMake(0, 1)];
    [songArtistLabel setText:@""];
    
    loadLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen.size.width/2 - 50, 10, 100, 20)];
    [loadLabel setBackgroundColor:[UIColor clearColor]];
    [loadLabel setTextAlignment:NSTextAlignmentCenter];
    [loadLabel setTextColor:[UIColor colorWithWhite:0.99 alpha:0.4]];
    [loadLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:12]];
    [loadLabel setHidden:YES];
    
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake(screen.size.width/2 - 12, 5, 25, 25)];
    [saveButton setImage:[UIImage imageNamed:@"cellSave.png"] forState:UIControlStateNormal];
    [saveButton setImage:[UIImage imageNamed:@"cellSaved.png"] forState:UIControlStateSelected];
    [saveButton addTarget:self action:@selector(saveFunc) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setShowsTouchWhenHighlighted:YES];
    [saveButton setHidden:YES];
    
    playBtnBg = [UIImage imageNamed:@"bigplay.png"];
    pauseBtnBg = [UIImage imageNamed:@"bigpause.png"];
    
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setFrame:CGRectMake(screen.size.width/2 - 52, screen.size.height/2 - 70, 111, 122)];
    [playButton setBackgroundColor:[UIColor clearColor]];
    [playButton setAlpha:0.12];
    [playButton setShowsTouchWhenHighlighted:YES];
    [playButton setImage:playBtnBg forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(didGetPlayerPlay) forControlEvents:UIControlEventTouchUpInside];
    
    UISwipeGestureRecognizer *fwd = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didGetPlayerFwd)];
    fwd.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:fwd];
    UISwipeGestureRecognizer *rwd = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didGetPlayerRwd)];
    rwd.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:rwd];
    
    repeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [repeatButton setFrame:CGRectMake(screen.size.width - 94, 5, 40, 32)];
    [repeatButton setAlpha:0.25];
    [repeatButton setImage:[UIImage imageNamed:@"repeat.png"] forState:UIControlStateNormal];
    [repeatButton addTarget:self action:@selector(repeatButton:) forControlEvents:UIControlEventTouchUpInside];
    
    randomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [randomButton setFrame:CGRectMake(screen.size.width - 54, 5, 40, 32)];
    [randomButton setAlpha:0.25];
    [randomButton setImage:[UIImage imageNamed:@"rand.png"] forState:UIControlStateNormal];
    [randomButton addTarget:self action:@selector(randomButton:) forControlEvents:UIControlEventTouchUpInside];
    
    settings = [UIButton buttonWithType:UIButtonTypeCustom];
    [settings setFrame:CGRectMake(screen.size.width/2 - 20, screen.size.height - 60, 40, 40)];
    [settings setImage:[UIImage imageNamed:@"set.png"] forState:UIControlStateNormal];
    [settings setAlpha:0.25];
    [settings addTarget:self action:@selector(settingsFunc) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *strRepeat = [ud objectForKey:@"isRepeat"];
    isRandom = [ud boolForKey:@"isRandom"];
    if (isRandom) {
        [randomButton setAlpha:0.7];
    }
    else {
        [randomButton setAlpha:0.25];
    }
    if ([strRepeat intValue] == -1) {
        player.numberOfLoops = -1;
        loops = -1;
        [repeatButton setAlpha:0.7];
    }
    else if ([strRepeat intValue] == 0) {
        player.numberOfLoops = 0;
        loops = 0;
        [repeatButton setAlpha:0.25];
    }
    else if ([strRepeat intValue] == 1) {
        player.numberOfLoops = 0;
        loops = 1;
        [repeatButton setAlpha:0.7];
    }
    
    [self performSelectorOnMainThread:@selector(addToView2) withObject:self waitUntilDone:NO];
}

- (void) customMake {
    CGRect screen = [[UIScreen mainScreen] bounds];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1]];
    songTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 280, 40)];
    songArtistLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 122, 280, 40)];
    
    songNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 12, 200, 20)];
    [songNumLabel setBackgroundColor:[UIColor clearColor]];
    [songNumLabel setTextAlignment:NSTextAlignmentCenter];
    [songNumLabel setTextColor:[UIColor colorWithWhite:0.9 alpha:1]];
    [songNumLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    NSString *songNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"songNumber"];
    currentNumber = songNumber.intValue;
    int numForLabel = currentNumber + 1;
    [songNumLabel setText:[NSString stringWithFormat:@"%d из %d", numForLabel, [[self.fetchedResultsController fetchedObjects] count]]]; 
    
    progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(40, 10, 240, 30)];
    [progressSlider setBackgroundColor:[UIColor clearColor]];
    [progressSlider setMinimumTrackTintColor:[UIColor colorWithRed:180/255.0f green:180/255.0f blue:180/255.0f alpha:1]];
    [progressSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
    [progressSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.1 alpha:1]];
    [progressSlider setThumbImage:[UIImage imageNamed:@"volumepointer.png"] forState:UIControlStateNormal];
    [progressSlider setThumbImage:[UIImage imageNamed:@"volumepointer.png"] forState:UIControlStateHighlighted]; 
    
    songTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 40, 30)];
    [songTime setBackgroundColor:[UIColor clearColor]];
    [songTime setTextAlignment:NSTextAlignmentCenter];
    [songTime setTextColor:[UIColor colorWithWhite:0.8 alpha:1]];
    [songTime setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [songTime setText:@"00:00"];
    
    songTimeLeft = [[UILabel alloc] initWithFrame:CGRectMake(280, 10, 40, 30)];
    [songTimeLeft setBackgroundColor:[UIColor clearColor]];
    [songTimeLeft setTextAlignment:NSTextAlignmentCenter];
    [songTimeLeft setTextColor:[UIColor colorWithWhite:0.8 alpha:1]];
    [songTimeLeft setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [songTimeLeft setText:@"00:00"];
    
    [songTitleLabel setBackgroundColor:[UIColor clearColor]];
    [songTitleLabel setNumberOfLines:0];
    [songTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [songTitleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [songTitleLabel setTextColor:[UIColor colorWithWhite:0.9 alpha:1]];
    [songTitleLabel setShadowColor:[UIColor blackColor]];
    [songTitleLabel setShadowOffset:CGSizeMake(0, 1)];
    [songTitleLabel setText:@""];
    
    [songArtistLabel setBackgroundColor:[UIColor clearColor]];
    [songArtistLabel setNumberOfLines:0];
    [songArtistLabel setTextAlignment:NSTextAlignmentCenter];
    [songArtistLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    [songArtistLabel setTextColor:[UIColor colorWithWhite:0.7 alpha:1]];
    [songArtistLabel setShadowColor:[UIColor blackColor]];
    [songArtistLabel setShadowOffset:CGSizeMake(0, 1)];
    [songArtistLabel setText:@""];
    
    loadLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen.size.width/2 - 50, 40, 100, 20)];
    [loadLabel setBackgroundColor:[UIColor clearColor]];
    [loadLabel setTextAlignment:NSTextAlignmentCenter];
    [loadLabel setTextColor:[UIColor colorWithWhite:0.8 alpha:1]];
    [loadLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:12]];
    [loadLabel setHidden:YES];
    
    bottomView = [[UIView alloc]initWithFrame:CGRectMake(22, screen.size.height - 130, 276, 24)];
    [bottomView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"volumebg.png"]]];
    UIImageView *nosound = [[UIImageView alloc] initWithFrame:CGRectMake(6, 7, 12, 11)];
    [nosound setImage:[UIImage imageNamed:@"nosound.png"]];
    [nosound setBackgroundColor:[UIColor clearColor]];
    [bottomView addSubview:nosound];
    UIImageView *fullsound = [[UIImageView alloc] initWithFrame:CGRectMake(256, 7, 16, 12)];
    [fullsound setImage:[UIImage imageNamed:@"fullsound.png"]];
    [fullsound setBackgroundColor:[UIColor clearColor]];
    [bottomView addSubview:fullsound];
    
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake(screen.size.width - 50, 5, 25, 25)];
    [saveButton setImage:[UIImage imageNamed:@"cellSave.png"] forState:UIControlStateNormal];
    [saveButton setImage:[UIImage imageNamed:@"cellSaved.png"] forState:UIControlStateSelected];
    [saveButton addTarget:self action:@selector(saveFunc) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setShowsTouchWhenHighlighted:YES];
    [saveButton setHidden:YES];
    UIBarButtonItem *sButton = [[UIBarButtonItem alloc]
                                   initWithCustomView:saveButton];
    [self.navigationItem setRightBarButtonItem: sButton];
    
    volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, -1, 236, 24)];
    [volumeSlider setBackgroundColor:[UIColor clearColor]];
    [volumeSlider setMinimumTrackTintColor:[UIColor colorWithRed:40/255.0f green:180/255.0f blue:0/255.0f alpha:1]];
    volumeSlider.value = mplayer.volume;
    [volumeSlider addTarget:self action:@selector(volumeSliderMoved:) forControlEvents:UIControlEventValueChanged];
    [volumeSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.05 alpha:0.7]];
    [volumeSlider setThumbImage:[UIImage imageNamed:@"volumepointer.png"] forState:UIControlStateNormal];
    [volumeSlider setThumbImage:[UIImage imageNamed:@"volumepointer.png"] forState:UIControlStateHighlighted];
    [bottomView addSubview:volumeSlider]; 
    
    playBtnBg = [UIImage imageNamed:@"play.png"];
    pauseBtnBg = [UIImage imageNamed:@"pause.png"];
    
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setFrame:CGRectMake(screen.size.width/2 - 15, bottomView.frame.origin.y - 42, 30, 28)];
    [playButton setBackgroundColor:[UIColor clearColor]];
    [playButton setShowsTouchWhenHighlighted:YES];
    [playButton setImage:playBtnBg forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(didGetPlayerPlay) forControlEvents:UIControlEventTouchUpInside];
    
    rwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rwdButton setFrame:CGRectMake(playButton.frame.origin.x - 48, playButton.frame.origin.y, 29, 28)];
    [rwdButton setBackgroundColor:[UIColor clearColor]];
    [rwdButton setShowsTouchWhenHighlighted:YES];
    [rwdButton setImage:[UIImage imageNamed:@"reward.png"] forState:UIControlStateNormal];
    [rwdButton addTarget:self action:@selector(didGetPlayerRwd) forControlEvents:UIControlEventTouchUpInside];
    
    fwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fwdButton setFrame:CGRectMake(playButton.frame.origin.x + 48, playButton.frame.origin.y, 29, 28)];
    [fwdButton setBackgroundColor:[UIColor clearColor]];
    [fwdButton setShowsTouchWhenHighlighted:YES];
    [fwdButton setImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
    [fwdButton addTarget:self action:@selector(didGetPlayerFwd) forControlEvents:UIControlEventTouchUpInside];
    
    repeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [repeatButton setFrame:CGRectMake(fwdButton.frame.origin.x + 50, fwdButton.frame.origin.y + 2 , 24, 25)];
    [repeatButton setImage:[UIImage imageNamed:@"repeat.png"] forState:UIControlStateNormal];
    [repeatButton addTarget:self action:@selector(repeatButton:) forControlEvents:UIControlEventTouchUpInside];
    
    randomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [randomButton setFrame:CGRectMake(rwdButton.frame.origin.x - 50, rwdButton.frame.origin.y + 2, 24, 25)];
    [randomButton setImage:[UIImage imageNamed:@"rand.png"] forState:UIControlStateNormal];
    [randomButton addTarget:self action:@selector(randomButton:) forControlEvents:UIControlEventTouchUpInside]; 
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *strRepeat = [ud objectForKey:@"isRepeat"];
    isRandom = [ud boolForKey:@"isRandom"];
    if (isRandom) {
        [randomButton setImage:[UIImage imageNamed:@"random.png"] forState:UIControlStateNormal];
    }
    else {
        [randomButton setImage:[UIImage imageNamed:@"rand.png"] forState:UIControlStateNormal];
    }
    if ([strRepeat intValue] == -1) {
        player.numberOfLoops = -1;
        loops = -1;
        [repeatButton setImage:[UIImage imageNamed:@"repeaton1.png"] forState:UIControlStateNormal];
    }
    else if ([strRepeat intValue] == 0) {
        player.numberOfLoops = 0;
        loops = 0;
        [repeatButton setImage:[UIImage imageNamed:@"repeat.png"] forState:UIControlStateNormal];
    }
    else if ([strRepeat intValue] == 1) {
        player.numberOfLoops = 0;
        loops = 1;
        [repeatButton setImage:[UIImage imageNamed:@"repeaton.png"] forState:UIControlStateNormal];
    }
    
    [self performSelectorOnMainThread:@selector(addToView) withObject:self waitUntilDone:NO];
}

- (void) addToView2 {
    [self.view addSubview:circleView];
    [self.view addSubview:songTimeLeft];
    [self.view addSubview:songTime];
    [self.view addSubview:songArtistLabel];
    [self.view addSubview:songTitleLabel];
    [self.view addSubview:loadLabel];
    [self.view addSubview:playButton];
    [self.view addSubview:repeatButton];
    [self.view addSubview:randomButton];
    [self.view addSubview:saveButton];
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonBack setFrame:CGRectMake(10, 7, 50, 30)];
    [buttonBack setAlpha:0.2];
   // [buttonBack setImage:[UIImage imageNamed:@"newback2.png"] forState:UIControlStateNormal];
    [buttonBack setImage:[UIImage imageNamed:@"playerBack.png"] forState:UIControlStateNormal];
    
    [buttonBack addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
    // [buttonBack setImage:[UIImage imageNamed:@"menu2pressed.png"] forState:UIControlStateHighlighted];
    [buttonBack setShowsTouchWhenHighlighted:NO];
    [self.view addSubview:buttonBack];
    //  [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"playerNavBg.png"] forBarMetrics:UIBarMetricsDefault];
    
    DirectionPanGestureRecognizer *volume = [[DirectionPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleVolume:)];
    volume.direction = DirectionPanGestureRecognizerHorizontal;
    [volume setMaximumNumberOfTouches:1];
    [volume setDelaysTouchesBegan:YES];
    UIView *volumeView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    [volumeView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:volumeView];
    [volumeView addGestureRecognizer:volume];
     [self.view addSubview:settings];
}

- (void) addToView {
    [self.navigationController.navigationBar addSubview:songNumLabel];
    [self.view addSubview:progressSlider];
    [self.view addSubview:songTimeLeft];
    [self.view addSubview:songTime];
    [self.view addSubview:songArtistLabel];
    [self.view addSubview:songTitleLabel];
    [self.view addSubview:loadLabel];
    [self.view addSubview:bottomView];
    [self.view addSubview:playButton];
    [self.view addSubview:fwdButton];
    [self.view addSubview:rwdButton];
    [self.view addSubview:repeatButton];
    [self.view addSubview:randomButton];
}

- (void) settingsFunc {
    NSArray *arr = [NSArray arrayWithObjects:@"playerbg1.jpg", @"playerbg2.jpg", @"playerbg3.jpg", @"playerbg4.jpg", @"playerbg5.jpg", nil];
    int randNum = arc4random_uniform(5);
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[arr objectAtIndex:randNum]]]];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:[arr objectAtIndex:randNum] forKey:@"bgPic"];
    [ud synchronize];
    NSLog(@"settings");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newBg" object:nil];
}

- (void)handleVolume:(UIPanGestureRecognizer*)recognizer {
    
    CGPoint translation = [recognizer translationInView:recognizer.view];
    
    if (translation.x < 0.0f) {
        mplayer.volume = mplayer.volume - 0.01;
    }
    else {
        mplayer.volume = mplayer.volume + 0.01;
    }
    player.volume = mplayer.volume;
  //  recognizer.view.center=CGPointMake(recognizer.view.center.x+translation.x, recognizer.view.center.y+ translation.y);
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view];
    
}

- (void)randomButton:(id)sender {
    if (isRandom == YES) {
        isRandom = NO;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setBool:NO forKey:@"isRandom"];
        [ud synchronize];
        [randomButton setAlpha:0.25];
    }
    else {
        isRandom = YES;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setBool:YES forKey:@"isRandom"];
        [ud synchronize];
        [randomButton setAlpha:0.7];
    }
}

- (void)repeatButton:(id)sender {
    if (loops == 0) {
        NSLog(@"2");
        loops = 1;
        player.numberOfLoops = -1;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *strToUd = [NSString stringWithFormat:@"-1"];
        [ud setObject:strToUd forKey:@"isRepeat"];
        [ud synchronize];
        [repeatButton setAlpha:0.7];
    }
    else if (loops == -1) {
        NSLog(@"3");
        player.numberOfLoops = 0;
        loops = 1;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *strToUd = [NSString stringWithFormat:@"1"];
        [ud setObject:strToUd forKey:@"isRepeat"];
        [ud synchronize];
        [repeatButton setImage:[UIImage imageNamed:@"repeaton.png"] forState:UIControlStateNormal];
    }
    else if (loops == 1) {
        NSLog(@"4");
        player.numberOfLoops = 0;
        loops = 0;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *strToUd = [NSString stringWithFormat:@"0"];
        [ud setObject:strToUd forKey:@"isRepeat"];
        [ud synchronize];
        [repeatButton setAlpha:0.25];
    }
}

- (void)revealSidebar {
	_revealBlock();
}

- (void) newSong: (NSNotification *)notification {
    NSString *window = [[NSUserDefaults standardUserDefaults] objectForKey:@"window"];
    NSString *songNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"songNumber"];
    [saveButton setHidden:YES];
    [saveButton setSelected:NO];
    if ([window isEqualToString:@"saved"]) {
        currentNumber = songNumber.intValue;
        [self setSongToPlayer:songNumber.intValue]; 
    }
    else if ([window isEqualToString:@"audios"]){
        [player stop];
        player = nil;
        [self updateViewForPlayerState:player];
        songDictionary = [[notification userInfo] valueForKey:@"audioArray"];
        currentNumber = songNumber.intValue;
      //  NSLog(@"%d, %d", songDictionary.count, songNumber.intValue);
        NSDictionary *dict = [songDictionary objectAtIndex:currentNumber];
      //  NSLog(@"dict = %@", dict);
        NSString *name = [dict objectForKey:@"title"];
        name = [name stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
        name = [name stringByReplacingOccurrencesOfString:@"&#33;" withString:@"!"];
        name = [name stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        name = [name stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        NSString *art = [dict objectForKey:@"artist"];
        art = [art stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
        art = [art stringByReplacingOccurrencesOfString:@"&#33;" withString:@"!"];
        art = [art stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        art = [art stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        [songTitleLabel setText:name];
        [songArtistLabel setText:art];
        int numForLabel = currentNumber + 1;
        [songNumLabel setText:[NSString stringWithFormat:@"%d из %d", numForLabel, [songDictionary count]]];
     
        NSString *authString = [NSString stringWithFormat:@"%@", [dict objectForKey:@"url"]];
        NSURL *authURL = [[NSURL alloc] initWithString:authString];
        
        theRequest =
        [NSURLRequest requestWithURL:authURL
                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                     timeoutInterval:10.0];
        [theConnection cancel];
        theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if (theConnection) {
            rData = nil;
            rData = [NSMutableData data];
        } 
    }
    
}

- (void) setSongToPlayer: (int) songNumber {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:songNumber inSection:0]];
        NSString *songPath = [[managedObject valueForKey:@"filepath"] description];
      //  NSData *soundData = [[NSData alloc] initWithContentsOfFile:songPath];
      //  NSLog(@"%d", soundData.length);
        player = nil;
        NSURL *fileURL = [NSURL fileURLWithPath:songPath];
        NSLog(@"%@", fileURL);
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        [player setDelegate:self];
        if (loops == -1) {
            [player setNumberOfLoops:loops];
        }else {
            [player setNumberOfLoops:0];
        }
        [player play];
        dispatch_async(dispatch_get_main_queue(), ^{
            [songTitleLabel setText:[[managedObject valueForKey:@"title"] description]];
            [songArtistLabel setText:[[managedObject valueForKey:@"artist"] description]];
            int numForLabel = currentNumber + 1;
            [songNumLabel setText:[NSString stringWithFormat:@"%d из %d", numForLabel, [[self.fetchedResultsController fetchedObjects] count]]];
            NSDictionary *ar = [NSDictionary dictionaryWithObjectsAndKeys:songTitleLabel.text, @"title", songArtistLabel.text, @"artist", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSideBarLabel" object:nil userInfo:ar];
            [self updateViewForPlayerInfo:player];
            [self updateViewForPlayerState:player];
            [self performSelector:@selector(NowPlayingInfoCenter) withObject:self afterDelay:0.3];
            //[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        });
    });
}

- (void) didGetPlayerPlay {
    NSLog(@"Play");
    if (player.playing == YES)
        [self pausePlaybackForPlayer: player];
    else
        [self startPlaybackForPlayer: player];
}

- (void) didGetPlayerRwd {
    if (player.currentTime > 5.0) {
        [player stop];
        [player setCurrentTime:0];
        [self updateCurrentTime];
        [player play];
        NSLog(@"before 5");
    }
    else {
        NSString *window = [[NSUserDefaults standardUserDefaults] objectForKey:@"window"];
        [player stop];
        player = nil;
        if ([window isEqualToString:@"saved"]) {
            if (currentNumber == 0) {
                currentNumber = [self.fetchedResultsController fetchedObjects].count - 1;
            }
            else {
                currentNumber --;
            }
            [self setSongToPlayer:currentNumber];
        }
        else if ([window isEqualToString:@"audios"]) {
            if (currentNumber == 0) {
                currentNumber = songDictionary.count - 1;
            }
            else {
                currentNumber --;
            }
            [self updateViewForPlayerState:player];
            NSDictionary *dict = [songDictionary objectAtIndex:currentNumber];
            NSLog(@"dict = %@", dict);
            NSString *name = [dict objectForKey:@"title"];
            name = [name stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
            name = [name stringByReplacingOccurrencesOfString:@"&#33;" withString:@"!"];
            name = [name stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            name = [name stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
            NSString *art = [dict objectForKey:@"artist"];
            art = [art stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
            art = [art stringByReplacingOccurrencesOfString:@"&#33;" withString:@"!"];
            art = [art stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            art = [art stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
            [songTitleLabel setText:name];
            [songArtistLabel setText:art];
            int numForLabel = currentNumber + 1;
            [songNumLabel setText:[NSString stringWithFormat:@"%d из %d", numForLabel, [songDictionary count]]];
            NSString *authString = [NSString stringWithFormat:@"%@", [dict objectForKey:@"url"]];
            NSURL *authURL = [[NSURL alloc] initWithString:authString];
            theRequest =
            [NSURLRequest requestWithURL:authURL
                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                         timeoutInterval:10.0];
            [theConnection cancel];
            theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
            
            if (theConnection) {
                rData = nil;
                rData = [NSMutableData data];
            }
        }
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGRect defRect1 = CGRectMake(20, screen.size.height/2 - 60, 280, 50);
        CGRect defRect2 = CGRectMake(20, screen.size.height/2 - 10, 280, 40);
        [UIView animateWithDuration:0.2 animations:^{
            [songTitleLabel setFrame:CGRectMake(-defRect1.size.width - 10, defRect1.origin.y, defRect1.size.width, defRect1.size.height)];
            [songArtistLabel setFrame:CGRectMake(-defRect2.size.width - 10, defRect2.origin.y, defRect2.size.width, defRect2.size.height)];
            
        }completion:^(BOOL finished){
            [songTitleLabel setFrame:CGRectMake(self.view.frame.size.width + 10, defRect1.origin.y, defRect1.size.width, defRect1.size.height)];
            [songArtistLabel setFrame:CGRectMake(self.view.frame.size.width + 10, defRect2.origin.y, defRect2.size.width, defRect2.size.height)];
            [UIView animateWithDuration:0.2 animations:^{
                [songTitleLabel setFrame:CGRectMake(defRect1.origin.x, defRect1.origin.y, defRect1.size.width, defRect1.size.height)];
                [songArtistLabel setFrame:CGRectMake(defRect2.origin.x, defRect2.origin.y, defRect2.size.width, defRect2.size.height)];
            }completion:^(BOOL finished){
                
            }];
        }];
    }
    NSLog(@"rewind called");
}

- (void) didGetPlayerFwd {
    [player stop];
    player = nil;
    [self audioPlayerDidFinishPlaying:player successfully:YES];
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect defRect1 = CGRectMake(20, screen.size.height/2 - 60, 280, 50);
    CGRect defRect2 = CGRectMake(20, screen.size.height/2 - 10, 280, 40);
    [UIView animateWithDuration:0.2 animations:^{
        [songTitleLabel setFrame:CGRectMake(self.view.frame.size.width + 10, defRect1.origin.y, defRect1.size.width, defRect1.size.height)];
        [songArtistLabel setFrame:CGRectMake(self.view.frame.size.width + 10, defRect2.origin.y, defRect2.size.width, defRect2.size.height)];
    }completion:^(BOOL finished){
        [songTitleLabel setFrame:CGRectMake(-defRect1.size.width - 10, defRect1.origin.y, defRect1.size.width, defRect1.size.height)];
        [songArtistLabel setFrame:CGRectMake(-defRect2.size.width - 10, defRect2.origin.y, defRect2.size.width, defRect2.size.height)];
        [UIView animateWithDuration:0.2 animations:^{
            [songTitleLabel setFrame:CGRectMake(defRect1.origin.x, defRect1.origin.y, defRect1.size.width, defRect1.size.height)];
            [songArtistLabel setFrame:CGRectMake(defRect2.origin.x, defRect2.origin.y, defRect2.size.width, defRect2.size.height)];
        }completion:^(BOOL finished){
            
        }];
    }];
    NSLog(@"Fwd");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return fetchedResultsController;
}

#pragma mark Audio Methods

- (void) setSongNumber:(int) count {
    if (!isRandom) {
        NSString *songNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"songNumber"];
        if (songNumber.intValue < count) {
            int newNumber = songNumber.intValue + 1;
            currentNumber = newNumber;
            songNumber = [NSString stringWithFormat:@"%d", newNumber];
            [[NSUserDefaults standardUserDefaults] setObject:songNumber forKey:@"songNumber"];
        }
        else {
            int newNumber = 0;
            currentNumber = newNumber;
            songNumber = [NSString stringWithFormat:@"%d", newNumber];
            [[NSUserDefaults standardUserDefaults] setObject:songNumber forKey:@"songNumber"];
        }
    }
    else {
        NSString *songNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"songNumber"];
        int newNumber = arc4random_uniform(count);
        currentNumber = newNumber;
        if (songNumber.intValue != currentNumber) {
            songNumber = [NSString stringWithFormat:@"%d", newNumber];
            [[NSUserDefaults standardUserDefaults] setObject:songNumber forKey:@"songNumber"];
        }
        else {
            newNumber = arc4random_uniform(count);
            currentNumber = newNumber;
            songNumber = [NSString stringWithFormat:@"%d", newNumber];
            [[NSUserDefaults standardUserDefaults] setObject:songNumber forKey:@"songNumber"];
        }
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player1 successfully:(BOOL)flag {
    NSLog(@"Audio Player did finish playing");
    NSString *window = [[NSUserDefaults standardUserDefaults] objectForKey:@"window"];
    [player stop];
    if ([window isEqualToString:@"saved"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setSongNumber:[self.fetchedResultsController fetchedObjects].count];
            NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:currentNumber inSection:0]];
            NSString *songPath = [[managedObject valueForKey:@"filepath"] description];
            NSData *soundData = [[NSData alloc] initWithContentsOfFile:songPath];
            NSLog(@"%d", soundData.length);
            player = nil;
            player = [[AVAudioPlayer alloc] initWithData:soundData error:nil];
            NSLog(@"song path = %@", songPath);
            [player setDelegate:self];
            if (loops == -1) {
                [player setNumberOfLoops:loops];
            }else {
                [player setNumberOfLoops:0];
            }
            [player play];
            dispatch_async(dispatch_get_main_queue(), ^{
                [songTitleLabel setText:[[managedObject valueForKey:@"title"] description]];
                [songArtistLabel setText:[[managedObject valueForKey:@"artist"] description]];
                NSDictionary *ar = [NSDictionary dictionaryWithObjectsAndKeys:songTitleLabel.text, @"title", songArtistLabel.text, @"artist", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSideBarLabel" object:nil userInfo:ar];
                int numForLabel = currentNumber + 1;
                [songNumLabel setText:[NSString stringWithFormat:@"%d из %d", numForLabel, [[self.fetchedResultsController fetchedObjects] count]]];
                [self updateViewForPlayerInfo:player];
                [self updateViewForPlayerState:player];
                [self performSelector:@selector(NowPlayingInfoCenter) withObject:self afterDelay:0.3];
                // [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            });
        });
    }
    else if ([window isEqualToString:@"audios"]) {
        [self setSongNumber:songDictionary.count];
        [self updateViewForPlayerState:player];
        NSDictionary *dict = [songDictionary objectAtIndex:currentNumber];
        NSLog(@"dict = %@", dict);
        NSString *name = [dict objectForKey:@"title"];
        name = [name stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
        name = [name stringByReplacingOccurrencesOfString:@"&#33;" withString:@"!"];
        name = [name stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        name = [name stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        NSString *art = [dict objectForKey:@"artist"];
        art = [art stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
        art = [art stringByReplacingOccurrencesOfString:@"&#33;" withString:@"!"];
        art = [art stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        art = [art stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        [songTitleLabel setText:name];
        [songArtistLabel setText:art];
        int numForLabel = currentNumber + 1;
        [songNumLabel setText:[NSString stringWithFormat:@"%d из %d", numForLabel, [songDictionary count]]];
        NSString *authString = [NSString stringWithFormat:@"%@", [dict objectForKey:@"url"]];
        NSURL *authURL = [[NSURL alloc] initWithString:authString];
        theRequest =
        [NSURLRequest requestWithURL:authURL
                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                     timeoutInterval:10.0];
        [theConnection cancel];
        theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if (theConnection) {
            rData = nil;
            rData = [NSMutableData data];
        }
    }
    
}

- (void) audioPlayerBeginInterruption:(AVAudioPlayer *)player1 {
    NSLog(@"begin interruption");
    [player1 pause];
}

- (void) audioPlayerEndInterruption:(AVAudioPlayer *)player1 withOptions:(NSUInteger)flags {
    NSLog(@"stop interruption");
    [player1 play];
}

- (void)NowPlayingInfoCenter {
    Class MPNowPlayingClass = (NSClassFromString(@"MPNowPlayingInfoCenter"));
    if (MPNowPlayingClass != nil) {
        // UIImage *albumArtImage = [UIImage imageNamed:@"RadioKitImage.png"]; // TODO: replace with actual album artwork
        
        //  MPMediaItemArtwork *pmAlbumArt = [[MPMediaItemArtwork alloc] initWithImage:albumArtImage];
        NSDictionary *currentlyPlayingTrackInfo;
        
        NSString *newArtist = songArtistLabel.text;
        NSString *newSongName = songTitleLabel.text;
        currentlyPlayingTrackInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:newArtist, newSongName, nil] forKeys:[NSArray arrayWithObjects:MPMediaItemPropertyArtist, MPMediaItemPropertyTitle, nil]];
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = currentlyPlayingTrackInfo;
    }
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error);
}

- (void)volumeSliderMoved:(UISlider *)sender
{
	//player.volume = [sender value];
    mplayer.volume = [sender value];
}

- (void)progressSliderMoved:(UISlider *)sender
{
    NSLog(@"moved slider %f", sender.value);
	player.currentTime = sender.value;
	[self updateCurrentTimeForPlayer:player];
}

-(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)p
{
	songTime.text = [NSString stringWithFormat:@"%d:%02d /", (int)p.currentTime / 60, (int)p.currentTime % 60, nil];
	[progressSlider setValue:p.currentTime animated:YES];
    
    circleView.percent = (p.currentTime / p.duration) * 100;
   [circleView setNeedsDisplay];
}

- (void)updateCurrentTime
{
	[self updateCurrentTimeForPlayer:player];
}

#pragma mark background notifications
- (void)registerForBackgroundNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(setInBackgroundFlag)
												 name:UIApplicationWillResignActiveNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(clearInBackgroundFlag)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
        NSLog(@"UIEventSubtypeRemoteControlPlayPause");
		[self performSelectorOnMainThread:@selector(didGetPlayerPlay) withObject:self waitUntilDone:YES];
	}
	if (event.subtype == UIEventSubtypeRemoteControlPlay) {
        NSLog(@"UIEventSubtypeRemoteControlPlay");
		[self performSelectorOnMainThread:@selector(didGetPlayerPlay) withObject:self waitUntilDone:YES];
	}
	if (event.subtype == UIEventSubtypeRemoteControlPause) {
        NSLog(@"UIEventSubtypeRemoteControlPause");
		[self performSelectorOnMainThread:@selector(didGetPlayerPlay) withObject:self waitUntilDone:YES];
	}
	if (event.subtype == UIEventSubtypeRemoteControlStop) {
		NSLog(@"UIEventSubtypeRemoteControlStop");
		[player stop];
	}
	if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
		NSLog(@"UIEventSubtypeRemoteControlNextTrack");
		[self performSelectorOnMainThread:@selector(didGetPlayerFwd) withObject:self waitUntilDone:YES];
	}
	if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
		NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
		[self performSelectorOnMainThread:@selector(didGetPlayerRwd) withObject:self waitUntilDone:YES];
	}
}

- (void)volumeChanged:(NSNotification *)notification {
    float volume =
    [[[notification userInfo]
      objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]
     floatValue];
    [volumeSlider setValue:volume animated:YES];
    // Do stuff with volume
}

-(void)pausePlaybackForPlayer:(AVAudioPlayer*)p
{
	[p pause];
	[self updateViewForPlayerState:p];
}

-(void)startPlaybackForPlayer:(AVAudioPlayer*)p
{
	if ([p play])
	{
		[self updateViewForPlayerState:p];
	}
	else {
      //  isRandom = NO;
		NSLog(@"Could not play %@\n", p.url);
    }
}

- (void)updateViewForPlayerState:(AVAudioPlayer *)p
{
	[self updateCurrentTimeForPlayer:p];
    
	if (updateTimer) [updateTimer invalidate];
    UIImage *buttImg;
	if (p.playing)
	{
		buttImg = ((p.playing == YES) ? pauseBtnBg : playBtnBg);
		[playButton setImage:buttImg forState:UIControlStateNormal];

		updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCurrentTime) userInfo:p repeats:YES];
	}
	else
	{
		buttImg = ((p.playing == YES) ? pauseBtnBg : playBtnBg);
		[playButton setImage:buttImg forState:UIControlStateNormal];
		updateTimer = nil;
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePlayPause" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:buttImg, @"image", nil]];
}

- (void)updateViewForPlayerStateInBackground:(AVAudioPlayer *)p
{
	[self updateCurrentTimeForPlayer:p];
	UIImage *buttImg;
	if (p.playing)
	{
        buttImg = ((p.playing == YES) ? pauseBtnBg : playBtnBg);
		[playButton setImage:buttImg forState:UIControlStateNormal];
	}
	else
	{
        buttImg = ((p.playing == YES) ? pauseBtnBg : playBtnBg);
		[playButton setImage:buttImg forState:UIControlStateNormal];
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePlayPause" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:buttImg, @"image", nil]];
}

-(void)updateViewForPlayerInfo:(AVAudioPlayer*)p
{
	songTimeLeft.text = [NSString stringWithFormat:@"%d:%02d", (int)p.duration / 60, (int)p.duration % 60, nil];
	progressSlider.maximumValue = p.duration;
    progressSlider.minimumValue = 0.0f;
//	p.volume = volumeSlider.value;
    p.volume = mplayer.volume;
}

- (void)setInBackgroundFlag
{
	inBackground = true;
}

- (void)clearInBackgroundFlag
{
	inBackground = false;
}

#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [rData setLength:0];
    [loadLabel setText:@"Loading... 0%"];
    [loadLabel setHidden:NO];
    [saveButton setHidden:YES];
    [saveButton setSelected:NO];
    rLenght = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [rData appendData:data];
  //  NSLog(@"rData updated");
    float r = [rData length];
    if (r <= rLenght) {
        NSNumber *prsnt = [NSNumber numberWithFloat: (r/rLenght) * 100];
        NSString *str = [NSString stringWithFormat:@"Loading... %d%%", [prsnt intValue]];
        [loadLabel setText:str];
    }
    else {
        [connection cancel];
        NSLog(@"more than 100%%");
        if (player) {
            [player stop];
            player = nil;
        }
        [theConnection cancel];
        theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        if (theConnection) {
            rData = nil;
            rData = [NSMutableData data];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"finished");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        player = nil;
        NSError *e = nil;
        player = [[AVAudioPlayer alloc] initWithData:rData error:&e];
        NSLog(@"settings %@", player.settings);
        
        if (player == nil) {
            NSLog(@"extra method");
            NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filePath = [NSString stringWithFormat:@"%@/temp.mp3", docDirPath];
            [rData writeToFile:filePath atomically:YES];
            
            NSError *error;
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        }
        
        [player setDelegate:self];
        if (loops == -1) {
            [player setNumberOfLoops:loops];
        }else {
            [player setNumberOfLoops:0];
        }
        [player play];
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadLabel setHidden:YES];
            [saveButton setHidden:NO];
            NSDictionary *ar = [NSDictionary dictionaryWithObjectsAndKeys:songTitleLabel.text, @"title", songArtistLabel.text, @"artist", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSideBarLabel" object:nil userInfo:ar];
            [self updateViewForPlayerInfo:player];
            [self updateViewForPlayerState:player];
            [self performSelector:@selector(NowPlayingInfoCenter) withObject:self afterDelay:0.3];
        });
    });
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    self.fetchedResultsController = [self fetchedResultsController];
}

- (void)insertNewObject:(NSData *)data withTitle:(NSString *)name andArtist:(NSString *)art {
    name = [name stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    name = [name stringByReplacingOccurrencesOfString:@"&#33;" withString:@"!"];
    name = [name stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    name = [name stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    art = [art stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    art = [art stringByReplacingOccurrencesOfString:@"&#33;" withString:@"!"];
    art = [art stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    art = [art stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    for (NSManagedObject *obj in self.fetchedResultsController.fetchedObjects) {
        if ([[obj valueForKey:@"title"] isEqualToString:name] && [[obj valueForKey:@"artist"] isEqualToString:art]) {
            NSLog(@"already exist");
            return;
        }
    }
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                                      inManagedObjectContext:context];
    NSString *randomUUID = [self GetUUID];
    NSLog(@"%@", randomUUID);
    randomUUID = [randomUUID stringByAppendingPathExtension:@"mp3"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:randomUUID];
    BOOL written = [data writeToFile:filePath atomically:YES];
    
    [newManagedObject setValue:filePath forKey:@"filepath"];
    [newManagedObject setValue:name forKey:@"title"];
    [newManagedObject setValue:art forKey:@"artist"];
    
    [self saveContext];
    if (written) {
        [saveButton setSelected:YES];
    }
}

- (void)saveContext {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

- (void) saveFunc {
    NSDictionary *dict = [songDictionary objectAtIndex:currentNumber];
    [self insertNewObject:rData withTitle:[dict objectForKey:@"title"] andArtist:[dict objectForKey:@"artist"]];
}

@end
