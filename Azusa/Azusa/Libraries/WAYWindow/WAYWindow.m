//
//  WAYWindow.m
//  WAYWindow
//
//  Created by Raffael Hannemann on 15.11.14.
//  Copyright (c) 2014 Raffael Hannemann. All rights reserved.
//  Visit weAreYeah.com or follow @weareYeah for updates.
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "WAYWindow.h"

/** 
 Convenience methods to make NSPointerArray act like a stack of selectors. It would be a subclass, but NSPointerArray
 is a class cluster and doesn't really like being subclassed.
 */
#pragma mark - WAY_SelectorStack
@interface NSPointerArray (WAY_SelectorStack)
- (instancetype)initWAYSelectorStack;
- (BOOL)way_containsSelector:(SEL)aSelector;
- (void)way_pushSelector:(SEL)aSelector;
- (SEL)way_pop;
@end

@implementation NSPointerArray (WAY_SelectorStack)
- (instancetype)initWAYSelectorStack {
	NSPointerFunctions *pointerFunctions = [NSPointerFunctions pointerFunctionsWithOptions:(NSPointerFunctionsOpaqueMemory |
																							NSPointerFunctionsOpaquePersonality)];
	self = [self initWithPointerFunctions:pointerFunctions];
	return self;
}

- (BOOL)way_containsSelector:(SEL)aSelector {
	NSInteger count = self.count;
	for (NSInteger i=0; i<count; ++i) {
		SEL sel = [self pointerAtIndex:i];
		if (aSelector == sel) {
			return YES;
		}
	}
	return NO;
}
- (void)way_pushSelector:(SEL)aSelector {
	[self addPointer:aSelector];
}

- (SEL)way_pop {
	NSInteger index = self.count - 1;
	SEL theSel = [self pointerAtIndex:index];
	[self removePointerAtIndex:index];
	return theSel;
}

@end





@interface WAYWindowDelegateProxy : NSProxy <NSWindowDelegate>
@property (nonatomic, weak) id<NSWindowDelegate> secondaryDelegate;
@property (nonatomic, weak) id<NSWindowDelegate> firstDelegate;
@end

/** Since the window needs to update itself at specific events, e.g., windowDidResize:;, we need to set the window as its own delegate. To allow proper window delegates as usual, we need to make use of a proxy object, which forwards all method invovations first to the WAYWindow instance, and then to the real delegate. */
#pragma mark - WAYWindowDelegateProxy
@implementation WAYWindowDelegateProxy {
	NSPointerArray *_selectorStack;
}

- (instancetype)init {
	_selectorStack = [[NSPointerArray alloc] initWAYSelectorStack];
	return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
	NSMethodSignature *signature = [[self.firstDelegate class] instanceMethodSignatureForSelector:selector];
	if (!signature) {
		signature = [[self.secondaryDelegate class] instanceMethodSignatureForSelector:selector];
		if (!signature) {
			signature = [super methodSignatureForSelector:selector];
		}
	}
	return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	if (aSelector==@selector(windowDidResize:)) {
		return YES;
	} else if ([self.secondaryDelegate respondsToSelector:aSelector]) {
		return YES;
	} else {
		return NO;
	}
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	SEL selector = anInvocation.selector;
	if ([_selectorStack way_containsSelector:selector]) {
		// We're already in the middle of forwarding this selector; stop the infinite recursion right here.
		return;
	}
	
	[_selectorStack way_pushSelector:selector];
	{
		if ([self.firstDelegate respondsToSelector:selector]) {
			[anInvocation invokeWithTarget:self.firstDelegate];
		}
		if ([self.secondaryDelegate respondsToSelector:selector]) {
			[anInvocation invokeWithTarget:self.secondaryDelegate];
		}
	}
	[_selectorStack way_pop];
}

- (BOOL)isKindOfClass:(Class)aClass {
	if (self.secondaryDelegate) {
		return [self.secondaryDelegate isKindOfClass:aClass];
	}
	return NO;
}
@end


#pragma mark - WAYWindow
@interface WAYWindow () <NSWindowDelegate>
@property (strong) WAYWindowDelegateProxy* delegateProxy;
@property (strong) NSArray* standardButtons;
@property (strong) NSTitlebarAccessoryViewController *dummyTitlebarAccessoryViewController;

@end

static float kWAYWindowDefaultTrafficLightButtonsLeftMargin = 0;
static float kWAYWindowDefaultTrafficLightButtonsTopMargin = 0;

@implementation WAYWindow

+ (BOOL) supportsVibrantAppearances {
	return (NSClassFromString(@"NSVisualEffectView")!=nil);
}

+ (float) defaultTitleBarHeight {
	NSRect frame = NSMakeRect(0, 0, 800, 600);
	NSRect contentRect = [NSWindow contentRectForFrameRect:frame styleMask: NSWindowStyleMaskTitled];
	return NSHeight(frame) - NSHeight(contentRect);
}

#pragma mark - NSWindow Overwritings

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])) {
		[self _setUp];
	}
	return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
	if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen])) {
		[self _setUp];
	}
	return self;
}

- (void) setDelegate:(id<NSWindowDelegate>)delegate {
	[_delegateProxy setSecondaryDelegate:delegate];
	[super setDelegate:nil];
	[super setDelegate:_delegateProxy];
}

- (id<NSWindowDelegate>) delegate {
	return [_delegateProxy secondaryDelegate];
}

- (void) setFrame:(NSRect)frameRect display:(BOOL)flag {
	[super setFrame:frameRect display:flag];
	[self _setNeedsLayout];
}

- (void) restoreStateWithCoder:(NSCoder *)coder {
	[super restoreStateWithCoder:coder];
	[self _setNeedsLayout];
}

- (void) orderFront:(id)sender {
	[super orderFront:sender];
	[self _setNeedsLayout];
}

#pragma mark - Public

- (NSView *) titleBarView {
	return [_standardButtons[0] superview];
}

- (void) setCenterTrafficLightButtons:(BOOL)centerTrafficLightButtons {
	_centerTrafficLightButtons = centerTrafficLightButtons;
	[self _setNeedsLayout];
}

- (void) setTitleBarHeight:(CGFloat)titleBarHeight {

	titleBarHeight = MAX(titleBarHeight,[[self class] defaultTitleBarHeight]);
	CGFloat delta = titleBarHeight - _titleBarHeight;
	_titleBarHeight = titleBarHeight;
	
	if (_dummyTitlebarAccessoryViewController) {
		[self removeTitlebarAccessoryViewControllerAtIndex:0];
	}
	
	NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 10, titleBarHeight-[WAYWindow defaultTitleBarHeight])];
	_dummyTitlebarAccessoryViewController = [NSTitlebarAccessoryViewController new];
	_dummyTitlebarAccessoryViewController.view = view;
	_dummyTitlebarAccessoryViewController.fullScreenMinHeight = titleBarHeight;
	[self addTitlebarAccessoryViewController:_dummyTitlebarAccessoryViewController];
	
	NSRect frame = self.frame;
	frame.size.height += delta;
	frame.origin.y -= delta;
	
	[self _setNeedsLayout];
	[self setFrame:frame display:NO]; // NO is important.
}

- (void) setHidesTitle:(BOOL)hidesTitle {
	_hidesTitle = hidesTitle;
	[self setTitleVisibility:hidesTitle ? NSWindowTitleHidden : NSWindowTitleVisible];
}

- (void) setContentViewAppearanceVibrantDark {
	[self setContentViewAppearance:NSVisualEffectMaterialDark];
}

- (void) setContentViewAppearanceVibrantLight {
	[self setContentViewAppearance:NSVisualEffectMaterialLight];
}

- (void) setContentViewAppearance: (int) material {
	if (![WAYWindow supportsVibrantAppearances])
		return;
	
	NSVisualEffectView *newContentView = (NSVisualEffectView *)[self replaceSubview:self.contentView withViewOfClass:[NSVisualEffectView class]];
	[newContentView setMaterial:material];
	[self setContentView:newContentView];
}

- (void) setVibrantDarkAppearance {
	[self setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
}

- (void) setVibrantLightAppearance {
	[self setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
}

- (void) setAquaAppearance {
	[self setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameAqua]];
}

- (BOOL) isFullScreen {
	return (([self styleMask] & NSWindowStyleMaskFullScreen) == NSWindowStyleMaskFullScreen);
}

- (void) replaceSubview: (NSView *) aView withView: (NSView *) newView resizing:(BOOL)flag {
	if (flag) {
		[newView setFrame:aView.frame];
	}
	
	[newView setAutoresizesSubviews:aView.autoresizesSubviews];
	[aView.subviews.copy enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger idx, BOOL *stop) {
		NSRect frame = subview.frame;
		if (subview.constraints.count>0) {
			// Note: so far, constraint based contentView subviews are not supported yet
			NSLog(@"WARNING: [%@ %@] does not work yet with NSView instances, that use auto-layout.",
				  NSStringFromClass([self class]),
				  NSStringFromSelector(_cmd));
		}
		[subview removeFromSuperview];
		[newView addSubview:subview];
		[subview setFrame:frame];
	}];
	
	if (aView==self.contentView) {
		[self setContentView: newView];
	} else {
		[aView.superview replaceSubview:aView with:newView];
	}
	[self _setNeedsLayout];
}

- (NSView *) replaceSubview:(NSView *)aView withViewOfClass:(Class)newViewClass {
	NSView *view = [[newViewClass alloc] initWithFrame:aView.frame];
	[self replaceSubview:aView withView:view resizing:YES];
	return view;
}

#pragma mark - Private

- (void) _setUp {
	_delegateProxy = [[WAYWindowDelegateProxy alloc] init];
	_delegateProxy.firstDelegate = self;
	super.delegate = _delegateProxy;
	
	_standardButtons = @[[self standardWindowButton:NSWindowCloseButton],
						 [self standardWindowButton:NSWindowMiniaturizeButton],
						 [self standardWindowButton:NSWindowZoomButton]];
	_centerTrafficLightButtons = YES;
	
	NSButton *closeButton = [self standardWindowButton:NSWindowCloseButton];
	kWAYWindowDefaultTrafficLightButtonsLeftMargin = NSMinX(closeButton.frame);
	kWAYWindowDefaultTrafficLightButtonsTopMargin = NSHeight(closeButton.superview.frame)-NSMaxY(closeButton.frame);
	
	self.styleMask |= NSWindowStyleMaskFullSizeContentView;
	_trafficLightButtonsLeftMargin = kWAYWindowDefaultTrafficLightButtonsLeftMargin;
	_trafficLightButtonsTopMargin = kWAYWindowDefaultTrafficLightButtonsTopMargin;
	
	self.hidesTitle = YES;
	
	[super setDelegate:self];
	[self _setNeedsLayout];
}

- (void) _setNeedsLayout {
	[_standardButtons enumerateObjectsUsingBlock:^(NSButton *standardButton, NSUInteger idx, BOOL *stop) {
		NSRect frame = standardButton.frame;
		if (_centerTrafficLightButtons)
			frame.origin.y = round(NSHeight(standardButton.superview.frame)/2-NSHeight(standardButton.frame)/2);
		else
			frame.origin.y = NSHeight(standardButton.superview.frame)-NSHeight(standardButton.frame)-_trafficLightButtonsTopMargin;
		
		frame.origin.x = _trafficLightButtonsLeftMargin +idx*(NSWidth(frame) + 6);
		[standardButton setFrame:frame];
	}];
}

#pragma mark - NSWindow Delegate

- (void) windowDidResize:(NSNotification *)notification {
	[self _setNeedsLayout];
}

@end
