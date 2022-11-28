#import "../YouTubeHeader/YTColor.h"
#import "../YouTubeHeader/YTCommonUtils.h"
#import "../YouTubeHeader/YTMainAppControlsOverlayView.h"
#import "../YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h"
#import "../YouTubeHeader/YTSingleVideoController.h"
#import "../YouTubeHeader/YTQTMButton.h"
#import "../YouTubeHeader/QTMIcon.h"

@interface YTMainAppControlsOverlayView (YouMute)
@property (retain, nonatomic) YTQTMButton *muteButton;
- (void)didPressMute:(id)arg;
@end

static BOOL UseMuteButton() {
    return YES;
}

static BOOL isMuted(YTMainAppControlsOverlayView *self) {
    YTMainAppVideoPlayerOverlayViewController *c = [self valueForKey:@"_eventsDelegate"];
    YTSingleVideoController *video = [c valueForKey:@"_currentSingleVideoObservable"];
    return [video isMuted];
}

static NSBundle *YTEditResourcesBundle() {
    Class YTCommonUtilsClass = %c(YTCommonUtils);
    return [YTCommonUtilsClass resourceBundleForModuleName:@"Edit" appBundle:[YTCommonUtilsClass bundleForClass:%c(YTEditBundleIdentifier)]];
}

static UIImage *muteImage(BOOL muted) {
    return [%c(QTMIcon) tintImage:[UIImage imageNamed:muted ? @"ic_volume_off" : @"ic_volume_up" inBundle:YTEditResourcesBundle() compatibleWithTraitCollection:nil] color:[%c(YTColor) white1]];
}

static void createMuteButton(YTMainAppControlsOverlayView *self) {
    if (self) {
        CGFloat padding = [[self class] topButtonAdditionalPadding];
        UIImage *image = muteImage(isMuted(self));
        self.muteButton = [self buttonWithImage:image accessibilityLabel:@"Mute" verticalContentPadding:padding];
        self.muteButton.hidden = YES;
        self.muteButton.alpha = 0;
        [self.muteButton addTarget:self action:@selector(didPressMute:) forControlEvents:UIControlEventTouchUpInside];
        @try {
            [[self valueForKey:@"_topControlsAccessibilityContainerView"] addSubview:self.muteButton];
        } @catch (id ex) {
            [self addSubview:self.muteButton];
        }
    }
}

static NSMutableArray *topControls(YTMainAppControlsOverlayView *self, NSMutableArray *controls) {
    if (UseMuteButton())
        [controls insertObject:self.muteButton atIndex:0];
    return controls;
}

%hook YTMainAppVideoPlayerOverlayViewController

- (void)updateTopRightButtonAvailability {
    %orig;
    YTMainAppVideoPlayerOverlayView *v = [self videoPlayerOverlayView];
    YTMainAppControlsOverlayView *c = [v valueForKey:@"_controlsOverlayView"];
    c.muteButton.hidden = !UseMuteButton();
    [c setNeedsLayout];
}

%end

%hook YTMainAppControlsOverlayView

%property (retain, nonatomic) YTQTMButton *muteButton;

- (id)initWithDelegate:(id)delegate {
    self = %orig;
    createMuteButton(self);
    return self;
}

- (id)initWithDelegate:(id)delegate autoplaySwitchEnabled:(BOOL)autoplaySwitchEnabled {
    self = %orig;
    createMuteButton(self);
    return self;
}

- (NSMutableArray *)topButtonControls {
    return topControls(self, %orig);
}

- (NSMutableArray *)topControls {
    return topControls(self, %orig);
}

- (void)setTopOverlayVisible:(BOOL)visible isAutonavCanceledState:(BOOL)canceledState {
    if (UseMuteButton())
        self.muteButton.alpha = canceledState || !visible ? 0.0 : 1.0;
    %orig;
}

%new(v@:@)
- (void)didPressMute:(id)arg {
    YTMainAppVideoPlayerOverlayViewController *c = [self valueForKey:@"_eventsDelegate"];
    YTSingleVideoController *video = [c valueForKey:@"_currentSingleVideoObservable"];
    [video setMuted:![video isMuted]];
    [self.muteButton setImage:muteImage([video isMuted]) forState:0];
}

%end
