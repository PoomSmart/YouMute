#import "../YTVideoOverlay/Header.h"
#import "../YTVideoOverlay/Init.x"
#import "../YouTubeHeader/YTColor.h"
#import "../YouTubeHeader/YTCommonUtils.h"
#import "../YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h"
#import "../YouTubeHeader/YTSingleVideoController.h"

#define TweakKey @"YouMute"

@interface YTMainAppControlsOverlayView (YouMute)
@property (retain, nonatomic) YTQTMButton *muteButton;
- (void)didPressMute:(id)arg;
@end

@interface YTInlinePlayerBarContainerView (YouMute)
@property (retain, nonatomic) YTQTMButton *muteButton;
- (void)didPressMute:(id)arg;
@end

static BOOL isMutedTop(YTMainAppControlsOverlayView *self) {
    YTMainAppVideoPlayerOverlayViewController *c = [self valueForKey:@"_eventsDelegate"];
    YTSingleVideoController *video = [c valueForKey:@"_currentSingleVideoObservable"];
    return [video isMuted];
}

static BOOL isMutedBottom(YTInlinePlayerBarContainerView *self) {
    YTSingleVideoController *video = [self.delegate valueForKey:@"_currentSingleVideo"];
    return [video isMuted];
}

static NSBundle *YTEditResourcesBundle() {
    Class YTCommonUtilsClass = %c(YTCommonUtils);
    return [YTCommonUtilsClass resourceBundleForModuleName:@"Edit" appBundle:[YTCommonUtilsClass bundleForClass:%c(YTEditBundleIdentifier)]];
}

static UIImage *muteImage(BOOL muted) {
    return [%c(QTMIcon) tintImage:[UIImage imageNamed:muted ? @"ic_volume_off" : @"ic_volume_up" inBundle:YTEditResourcesBundle() compatibleWithTraitCollection:nil] color:[%c(YTColor) white1]];
}

%group Top

%hook YTMainAppControlsOverlayView

%property (retain, nonatomic) YTQTMButton *muteButton;

- (id)initWithDelegate:(id)delegate {
    self = %orig;
    self.muteButton = [self createButton:TweakKey accessibilityLabel:@"Mute" selector:@selector(didPressMute:)];
    return self;
}

- (id)initWithDelegate:(id)delegate autoplaySwitchEnabled:(BOOL)autoplaySwitchEnabled {
    self = %orig;
    self.muteButton = [self createButton:TweakKey accessibilityLabel:@"Mute" selector:@selector(didPressMute:)];
    return self;
}

- (YTQTMButton *)button:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakKey] ? self.muteButton : %orig;
}

- (UIImage *)buttonImage:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakKey] ? muteImage(isMutedTop(self)) : %orig;
}

%new(v@:@)
- (void)didPressMute:(id)arg {
    YTMainAppVideoPlayerOverlayViewController *c = [self valueForKey:@"_eventsDelegate"];
    YTSingleVideoController *video = [c valueForKey:@"_currentSingleVideoObservable"];
    [video setMuted:![video isMuted]];
    [self.muteButton setImage:muteImage([video isMuted]) forState:0];
}

%end

%end

%group Bottom

%hook YTInlinePlayerBarContainerView

%property (retain, nonatomic) YTQTMButton *muteButton;

- (id)init {
    self = %orig;
    self.muteButton = [self createButton:TweakKey accessibilityLabel:@"Mute" selector:@selector(didPressMute:)];
    return self;
}

- (YTQTMButton *)button:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakKey] ? self.muteButton : %orig;
}

- (UIImage *)buttonImage:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakKey] ? muteImage(isMutedBottom(self)) : %orig;
}

%new(v@:@)
- (void)didPressMute:(id)arg {
    YTSingleVideoController *video = [self.delegate valueForKey:@"_currentSingleVideo"];
    [video setMuted:![video isMuted]];
    [self.muteButton setImage:muteImage([video isMuted]) forState:0];
}

%end

%end

%ctor {
    initYTVideoOverlay(TweakKey);
    %init(Top);
    %init(Bottom);
}
