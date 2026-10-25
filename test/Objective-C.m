#import "AppDelegate.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import <objc/runtime.h>

NSString * const TerminalNotifierBundleID = @"fr.julienxx.oss.terminal-notifier";
NSString * const NotificationCenterUIBundleID = @"com.apple.notificationcenterui";

NSString *_fakeBundleIdentifier = nil;


@interface Box:NSObject {
  double length;    // Length of a box
  double breadth;   // Breadth of a box
  double height;    // Height of a box
}

@property(nonatomic, readwrite) double height;  // Property
-(double) volume;
@end

@implementation Box

@synthesize height;

-(id)init {
   self = [super init];
   length = 1.0;
   breadth = 1.0;
   return self;
}

-(double) volume {
   return length*breadth*height;
}

@end

@implementation NSBundle (FakeBundleIdentifier)

// Overriding bundleIdentifier works, but overriding NSUserNotificationAlertStyle does not work.

- (NSString *)__bundleIdentifier;
{
  if (self == [NSBundle mainBundle]) {
    return _fakeBundleIdentifier ? _fakeBundleIdentifier : TerminalNotifierBundleID;
  } else {
    return [self __bundleIdentifier];
  }
}

@end

static BOOL
InstallFakeBundleIdentifierHook()
{
  Class class = objc_getClass("NSBundle");
  if (class) {
    method_exchangeImplementations(class_getInstanceMethod(class, @selector(bundleIdentifier)),
                                   class_getInstanceMethod(class, @selector(__bundleIdentifier)));
    return YES;
  }
  return NO;
}

@implementation NSUserDefaults (SubscriptAndUnescape)
- (id)objectForKeyedSubscript:(id)key;
{
  id obj = [self objectForKey:key];
  if ([obj isKindOfClass:[NSString class]] && [(NSString *)obj hasPrefix:@"\\"]) {
    obj = [(NSString *)obj substringFromIndex:1];
  }
  return obj;
}
@end


@implementation AppDelegate

+(void)initializeUserDefaults
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  // initialize the dictionary with default values depending on OS level
  NSDictionary *appDefaults;
  appDefaults = @{@"sender": @"com.apple.Terminal"};

  // and set them appropriately
  [defaults registerDefaults:appDefaults];

  if ([identifier isEqualToString:SETTINGS_CELL_LOGOUT])
  {
    [[SocialConnector sharedInstance] doLogoutWithHandler:^{
      [self.navigationController popViewControllerAnimated:YES];
    }];
  }
}

- (void)printHelpBanner;
{
  const char *appName = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"] UTF8String];
  const char *appVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] UTF8String];
  printf("%s (%s) is a command-line tool to send macOS User Notifications.\n" \
         "\n" \
         "Usage: %s -[message|list|remove] [VALUE|ID|ID] [options]\n" \
         "\n" \
         "   Either of these is required (unless message data is piped to the tool):\n" \
         "\n" \
         "       -help              Display this help banner.\n" \
         "       -version           Display terminal-notifier version.\n" \
         "       -message VALUE     The notification message.\n" \
         "       -remove ID         Removes a notification with the specified ‘group’ ID.\n" \
         "       -list ID           If the specified ‘group’ ID exists show when it was delivered,\n" \
         "                          or use ‘ALL’ as ID to see all notifications.\n" \
         "                          The output is a tab-separated list.\n"
         "\n" \
         "   Optional:\n" \
         "\n" \
         "       -title VALUE       The notification title. Defaults to ‘Terminal’.\n" \
         "       -subtitle VALUE    The notification subtitle.\n" \
         "       -sound NAME        The name of a sound to play when the notification appears. The names are listed\n" \
         "                          in Sound Preferences. Use 'default' for the default notification sound.\n" \
         "       -group ID          A string which identifies the group the notifications belong to.\n" \
         "                          Old notifications with the same ID will be removed.\n" \
         "       -activate ID       The bundle identifier of the application to activate when the user clicks the notification.\n" \
         "       -sender ID         The bundle identifier of the application that should be shown as the sender, including its icon.\n" \
         "       -appIcon URL       The URL of a image to display instead of the application icon (Mavericks+ only)\n" \
         "       -contentImage URL  The URL of a image to display attached to the notification (Mavericks+ only)\n" \
         "       -open URL          The URL of a resource to open when the user clicks the notification.\n" \
         "       -execute COMMAND   A shell command to perform when the user clicks the notification.\n" \
         "       -ignoreDnD         Send notification even if Do Not Disturb is enabled.\n" \
         "\n" \
         "When the user activates a notification, the results are logged to the system logs.\n" \
         "Use Console.app to view these logs.\n" \
         "\n" \
         "Note that in some circumstances the first character of a message has to be escaped in order to be recognized.\n" \
         "An example of this is when using an open bracket, which has to be escaped like so: ‘\\[’.\n" \
         "\n" \
         "For more information see https://github.com/julienXX/terminal-notifier.\n",
         appName, appVersion, appName);
}

- (void)printVersion;
{
  const char *appName = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"] UTF8String];
  const char *appVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] UTF8String];
  printf("%s %s.\n", appName, appVersion);
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
  NSUserNotification *userNotification = notification.userInfo[NSApplicationLaunchUserNotificationKey];
  if (userNotification) {
    [self userActivatedNotification:userNotification];

  } else {
    if ([[[NSProcessInfo processInfo] arguments] indexOfObject:@"-help"] != NSNotFound) {
      [self printHelpBanner];
      exit(0);
    }

    if ([[[NSProcessInfo processInfo] arguments] indexOfObject:@"-version"] != NSNotFound) {
      [self printVersion];
      exit(0);
    }

    NSArray *runningProcesses = [[[NSWorkspace sharedWorkspace] runningApplications] valueForKey:@"bundleIdentifier"];
    if ([runningProcesses indexOfObject:NotificationCenterUIBundleID] == NSNotFound) {
      NSLog(@"[!] Unable to post a notification for the current user (%@), as it has no running NotificationCenter instance.", NSUserName());
      exit(1);
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *subtitle = defaults[@"subtitle"];
    NSString *message  = defaults[@"message"];
    NSString *remove   = defaults[@"remove"];
    NSString *list     = defaults[@"list"];
    NSString *sound    = defaults[@"sound"];

    // If there is no message and data is piped to the application, use that
    // instead.
    if (message == nil && !isatty(STDIN_FILENO)) {
      NSData *inputData = [NSData dataWithData:[[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile]];
      message = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
    }

    if (message == nil && remove == nil && list == nil) {
      [self printHelpBanner];
      exit(1);
    }

    if (list) {
      [self listNotificationWithGroupID:list];
      exit(0);
    }

    // Install the fake bundle ID hook so we can fake the sender. This also
    // needs to be done to be able to remove a message.
    if (defaults[@"sender"]) {
      @autoreleasepool {
        if (InstallFakeBundleIdentifierHook()) {
          _fakeBundleIdentifier = defaults[@"sender"];
        }
      }
    }

    if (remove) {
      [self removeNotificationWithGroupID:remove];
      if (message == nil || ([message length] == 0)) {
          exit(0);
      }
    }

    if (message) {
      NSMutableDictionary *options = [NSMutableDictionary dictionary];
      if (defaults[@"activate"]) options[@"bundleID"]         = defaults[@"activate"];
      if (defaults[@"group"])    options[@"groupID"]          = defaults[@"group"];
      if (defaults[@"execute"])  options[@"command"]          = defaults[@"execute"];
      if (defaults[@"appIcon"])  options[@"appIcon"]          = defaults[@"appIcon"];
      if (defaults[@"contentImage"]) options[@"contentImage"] = defaults[@"contentImage"];

      if (defaults[@"open"]) {
        NSURL *url = [NSURL URLWithString:defaults[@"open"]];
        if ((url && url.scheme && url.host) || [url isFileURL]) {
          options[@"open"] = defaults[@"open"];
        }else{
          NSLog(@"'%@' is not a valid URI.", defaults[@"open"]);
          exit(1);
        }
      }

      if([[[NSProcessInfo processInfo] arguments] containsObject:@"-ignoreDnD"] == true) {
        options[@"ignoreDnD"] = @YES;
      }

      [self deliverNotificationWithTitle:defaults[@"title"] ?: @"Terminal"
                                subtitle:subtitle
                                 message:message
                                 options:options
                                   sound:sound];
    }
  }
}

- (NSImage*)getImageFromURL:(NSString *) url;
{
  NSURL *imageURL = [NSURL URLWithString:url];
  if([[imageURL scheme] length] == 0){
    // Prefix 'file://' if no scheme
    imageURL = [NSURL fileURLWithPath:url];
  }
  return [[NSImage alloc] initWithContentsOfURL:imageURL];
}

- (void)deliverNotificationWithTitle:(NSString *)title
                             subtitle:(NSString *)subtitle
                             message:(NSString *)message
                             options:(NSDictionary *)options
                               sound:(NSString *)sound;
{
  // First remove earlier notification with the same group ID.
  if (options[@"groupID"]) [self removeNotificationWithGroupID:options[@"groupID"]];

  NSUserNotification *userNotification = [NSUserNotification new];
  userNotification.title = title;
  userNotification.subtitle = subtitle;
  userNotification.informativeText = message;
  userNotification.userInfo = options;

  if(options[@"appIcon"]){
    [userNotification setValue:[self getImageFromURL:options[@"appIcon"]] forKey:@"_identityImage"];
    [userNotification setValue:@(false) forKey:@"_identityImageHasBorder"];
  }
  if(options[@"contentImage"]){
    userNotification.contentImage = [self getImageFromURL:options[@"contentImage"]];
  }

  if (sound != nil) {
    userNotification.soundName = [sound isEqualToString: @"default"] ? NSUserNotificationDefaultSoundName : sound ;
  }

  if(options[@"ignoreDnD"]){
    [userNotification setValue:@YES forKey:@"_ignoresDoNotDisturb"];
  }

  NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
  center.delegate = self;
  [center scheduleNotification:userNotification];
}

- (void)listNotificationWithGroupID:(NSString *)listGroupID;
{
  NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];

  NSMutableArray *lines = [NSMutableArray array];
  for (NSUserNotification *userNotification in center.deliveredNotifications) {
    NSString *deliveredgroupID = userNotification.userInfo[@"groupID"];
    NSString *title            = userNotification.title;
    NSString *subtitle         = userNotification.subtitle;
    NSString *message          = userNotification.informativeText;
    NSString *deliveredAt      = [userNotification.actualDeliveryDate description];
    if ([@"ALL" isEqualToString:listGroupID] || [deliveredgroupID isEqualToString:listGroupID]) {
      [lines addObject:[NSString stringWithFormat:@"%@\t%@\t%@\t%@\t%@", deliveredgroupID, title, subtitle, message, deliveredAt]];
    }
  }

  if (lines.count > 0) {
    printf("GroupID\tTitle\tSubtitle\tMessage\tDelivered At\n");
    for (NSString *line in lines) {
      printf("%s\n", [line UTF8String]);
    }
  }
}


- (void)userActivatedNotification:(NSUserNotification *)userNotification;
{
  [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:userNotification];

  NSString *groupID  = userNotification.userInfo[@"groupID"];
  NSString *bundleID = userNotification.userInfo[@"bundleID"];
  NSString *command  = userNotification.userInfo[@"command"];
  NSString *open     = userNotification.userInfo[@"open"];

  NSLog(@"User activated notification:");
  NSLog(@" group ID: %@", groupID);
  NSLog(@"    title: %@", userNotification.title);
  NSLog(@" subtitle: %@", userNotification.subtitle);
  NSLog(@"  message: %@", userNotification.informativeText);
  NSLog(@"bundle ID: %@", bundleID);
  NSLog(@"  command: %@", command);
  NSLog(@"     open: %@", open);

  BOOL success = YES;
  if (bundleID) success &= [self activateAppWithBundleID:bundleID];
  if (command)  success &= [self executeShellCommand:command];
  if (open)     success &= [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:open]];

  exit(success ? 0 : 1);
}

- (BOOL)activateAppWithBundleID:(NSString *)bundleID;
{
  id app = [SBApplication applicationWithBundleIdentifier:bundleID];
  if (app) {
    [app activate];
    return YES;

  } else {
    NSLog(@"Unable to find an application with the specified bundle indentifier.");
    return NO;
  }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)userNotification;
{
  return YES;
}

// Once the notification is delivered we can exit.
- (void)userNotificationCenter:(NSUserNotificationCenter *)center
        didDeliverNotification:(NSUserNotification *)userNotification;
{
  exit(0);
}

@end

// When the termination signal is received, call the 'bye' method of the app delegate,
// which removes the current notification from the Notification Center
// and exits the program with a failure status code.
void SIGTERM_handler(int signum) {
    [appDelegate bye];
    exit(EXIT_FAILURE);
}

int main(int argc, char *argv[])
{
    signal(SIGTERM, SIGTERM_handler);
    signal(SIGINT, SIGTERM_handler);

    NSApplication * application = [NSApplication sharedApplication];
    appDelegate = [AppDelegate new];

    [application setDelegate:appDelegate];
    [application run];

    return EXIT_SUCCESS;
}

#pragma mark - Additional syntax coverage

#import <Foundation/Foundation.h>
@import Darwin;
@class TNDeliveryQueue;
@protocol TNQueueDelegate;

#pragma clang assume_nonnull begin

typedef enum TNDeliveryState : NSInteger {
    TNDeliveryStatePending = 0,
    TNDeliveryStateDelivered,
    TNDeliveryStateFailed = -1,
} TNDeliveryState;

typedef enum TNDeliveryOptions : NSUInteger {
    TNDeliveryOptionNone      = 0,
    TNDeliveryOptionSound     = 1 << 0,
    TNDeliveryOptionBadge     = 1 << 1,
    TNDeliveryOptionIgnoreDnD = 1 << 2,
} TNDeliveryOptions;

typedef void (^TNCompletionBlock)(BOOL success, NSError * _Nullable error);
typedef NSString * _Nonnull (^TNFormatter)(id value);
typedef struct { CGFloat x, y; } TNPoint;

static NSString * const TNErrorDomain = @"fr.julienxx.oss.terminal-notifier.error";
static const NSTimeInterval TNDefaultTimeout = 2.5;
static const NSUInteger TNMaxRetries = 3u;
static const long long TNLargeNumber = 0x7FFFFFFFLL;
static const double TNExponent = 6.02e23;
static const unsigned TNBits = 0b1010 | 017;

/// A protocol describing anything able to deliver a notification.
@protocol TNDeliverable <NSObject>
@required
- (void)deliverWithCompletion:(TNCompletionBlock)completion;
@property (nonatomic, readonly, copy) NSString *identifier;
@optional
- (void)cancel;
+ (instancetype)deliverableWithIdentifier:(NSString *)identifier;
@end

/**
 * A FIFO queue of deliverable items.
 * @discussion Uses lightweight generics and KVO-compliant properties.
 */
__attribute__((objc_subclassing_restricted))
@interface TNDeliveryQueue<__covariant ItemType : id<TNDeliverable>> : NSObject <NSCopying, NSFastEnumeration>

@property (nonatomic, strong, readonly) NSMutableArray<ItemType> *items;
@property (nonatomic, weak, nullable) id<TNQueueDelegate> delegate;
@property (nonatomic, copy, nullable) TNFormatter formatter;
@property (nonatomic, assign, getter=isPaused) BOOL paused;
@property (atomic, readwrite) TNDeliveryState state;
@property (class, nonatomic, readonly) TNDeliveryQueue *sharedQueue;
@property (nonatomic, unsafe_unretained, nullable) id legacyObserver;
@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *metrics;
@property (nonatomic) TNPoint anchor;

- (instancetype)initWithCapacity:(NSUInteger)capacity NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)queueWithItems:(NSArray<ItemType> *)items;
- (void)enqueue:(ItemType)item;
- (nullable ItemType)dequeue;
- (void)drainWithOptions:(TNDeliveryOptions)options completion:(nullable TNCompletionBlock)completion;
- (NSArray<NSString *> *)identifiersMatching:(BOOL (^)(ItemType item))predicate;
- (NSString *)formatValue:(id)value withFormatter:(TNFormatter __nullable)formatter NS_SWIFT_NAME(format(_:using:));

@end

@protocol TNQueueDelegate <NSObject>
- (void)queue:(TNDeliveryQueue *)queue didFinishItem:(id<TNDeliverable>)item;
@end

@interface TNDeliveryQueue ()
@property (nonatomic, strong, readwrite) NSMutableArray *items;
@property (nonatomic, strong) dispatch_queue_t workQueue;
@end

@implementation TNDeliveryQueue {
    NSUInteger _capacity;
    NSLock *_lock;
    __weak id _weakRef;
    __block NSInteger _pendingCount;
}

@synthesize paused = _paused;
@dynamic legacyObserver;

static TNDeliveryQueue *_sharedQueue = nil;

+ (TNDeliveryQueue *)sharedQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedQueue = [[self alloc] initWithCapacity:16];
    });
    return _sharedQueue;
}

+ (instancetype)queueWithItems:(NSArray *)items {
    TNDeliveryQueue *queue = [[self alloc] initWithCapacity:items.count];
    for (id<TNDeliverable> item in items) {
        [queue enqueue:item];
    }
    return queue;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    if ((self = [super init])) {
        _capacity = capacity ?: 8;
        _lock = [[NSLock alloc] init];
        _items = [NSMutableArray arrayWithCapacity:capacity];
        _workQueue = dispatch_queue_create("fr.julienxx.queue", DISPATCH_QUEUE_SERIAL);
        _state = TNDeliveryStatePending;
        _metrics = @{@"enqueued": @0, @"failed": @0};
        _anchor = (TNPoint){ .x = 0.0, .y = 1.5 };
    }
    return self;
}

- (void)dealloc {
    _lock = nil;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    TNDeliveryQueue *copy = [[[self class] allocWithZone:zone] initWithCapacity:_capacity];
    copy->_items = [_items mutableCopy];
    return copy;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len {
    return [_items countByEnumeratingWithState:state objects:buffer count:len];
}

- (void)enqueue:(id<TNDeliverable>)item {
    NSParameterAssert(item != nil);
    @synchronized (self) {
        if (_items.count >= _capacity) {
            [_items removeObjectAtIndex:0];
        }
        [_items addObject:item];
        _pendingCount += 1;
    }
    [self willChangeValueForKey:@"items"];
    NSMutableDictionary *metrics = [self.metrics mutableCopy];
    metrics[@"enqueued"] = @([metrics[@"enqueued"] unsignedIntegerValue] + 1);
    self.metrics = metrics;
    [self didChangeValueForKey:@"items"];
}

- (id<TNDeliverable>)dequeue {
    [_lock lock];
    id<TNDeliverable> first = _items.firstObject;
    if (first) [_items removeObjectAtIndex:0];
    [_lock unlock];
    return first;
}

- (void)drainWithOptions:(TNDeliveryOptions)options completion:(TNCompletionBlock)completion {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger failures = 0;
    BOOL wantsSound = (options & TNDeliveryOptionSound) == TNDeliveryOptionSound;
    BOOL ignoresDnD = !!(options & TNDeliveryOptionIgnoreDnD);

    dispatch_async(self.workQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        id<TNDeliverable> item;
        while ((item = [strongSelf dequeue]) != nil) {
            @try {
                [item deliverWithCompletion:^(BOOL success, NSError *error) {
                    if (!success) failures++;
                    if ([strongSelf.delegate respondsToSelector:@selector(queue:didFinishItem:)]) {
                        [strongSelf.delegate queue:strongSelf didFinishItem:item];
                    }
                }];
            }
            @catch (NSException *exception) {
                NSLog(@"delivery raised %@ (%@)", exception.name, exception.userInfo);
                failures++;
                if ([exception.name isEqualToString:NSInternalInconsistencyException]) @throw;
            }
            @finally {
                strongSelf->_pendingCount--;
            }
        }

        NSError *error = failures > 0
            ? [NSError errorWithDomain:TNErrorDomain
                                  code:(NSInteger)failures
                              userInfo:@{NSLocalizedDescriptionKey: @"some deliveries failed",
                                         @"sound": @(wantsSound),
                                         @"ignoresDnD": @(ignoresDnD)}]
            : nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TNDefaultTimeout * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            if (completion) completion(error == nil, error);
        });
    });
}

- (NSArray<NSString *> *)identifiersMatching:(BOOL (^)(id<TNDeliverable>))predicate {
    NSMutableArray<NSString *> *result = [NSMutableArray new];
    [_items enumerateObjectsUsingBlock:^(id<TNDeliverable> obj, NSUInteger idx, BOOL *stop) {
        if (predicate(obj)) {
            [result addObject:obj.identifier];
        }
        if (idx > TNMaxRetries * 100) *stop = YES;
    }];
    NSSortDescriptor *byLength = [NSSortDescriptor sortDescriptorWithKey:@"length" ascending:YES];
    return [result sortedArrayUsingDescriptors:@[byLength]];
}

- (NSString *)formatValue:(id)value withFormatter:(TNFormatter)formatter {
    if (formatter) return formatter(value);
    if ([value isKindOfClass:NSNumber.class]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        nf.numberStyle = NSNumberFormatterDecimalStyle;
        return [nf stringFromNumber:(NSNumber *)value] ?: @"";
    }
    return [value description];
}

- (void)setPaused:(BOOL)paused {
    _paused = paused;
    self.state = paused ? TNDeliveryStatePending : self.state;
}

- (BOOL)isPaused {
    return _paused;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p items=%lu capacity=%lu>",
            NSStringFromClass([self class]), self, (unsigned long)_items.count, (unsigned long)_capacity];
}

@end

@interface NSString (TNEscaping)
- (NSString *)tn_shellEscapedString;
+ (nullable NSString *)tn_stringFromFile:(NSString *)path error:(NSError * _Nullable * _Nullable)error;
@end

@implementation NSString (TNEscaping)

- (NSString *)tn_shellEscapedString {
    NSString *escaped = [self stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"];
    return [NSString stringWithFormat:@"'%@'", escaped];
}

+ (NSString *)tn_stringFromFile:(NSString *)path error:(NSError **)error {
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

@end

static void TNDemonstrateLiterals(void) {
    NSNumber *integer = @42;
    NSNumber *unsignedLong = @42UL;
    NSNumber *floating = @3.14f;
    NSNumber *boolean = @YES;
    NSNumber *character = @'c';
    NSNumber *boxedExpr = @(TNMaxRetries * 2 + 1);
    NSString *boxedCString = @(getenv("HOME") ?: "/");
    NSArray<NSNumber *> *numbers = @[integer, unsignedLong, floating, boolean, character, boxedExpr];
    NSDictionary<NSString *, id> *mapping = @{
        @"numbers": numbers,
        @"nested": @{@"inner": @[@1, @2, @3]},
        @"empty": @[],
        @"string": boxedCString,
    };
    NSArray *copy = [numbers arrayByAddingObject:mapping[@"string"]];
    NSNumber *second = numbers[1];
    id value = [mapping valueForKeyPath:@"nested.inner.@count"];
    SEL selector = @selector(tn_shellEscapedString);
    Protocol *protocol = @protocol(TNDeliverable);
    const char *encoding = @encode(NSRange);
    NSString *className = NSStringFromClass(TNDeliveryQueue.class);
    NSString *multiline = @"first line "
                          @"second line";
    NSString *joined = [@[@"a", @"b"] componentsJoinedByString:@", "];
    NSMutableString *buffer = [NSMutableString stringWithCapacity:64];
    [buffer appendFormat:@"%@ %@ %ld %lld %g %u", joined, className, (long)TNLargeNumber, TNLargeNumber, TNExponent, TNBits];
    NSSet<NSString *> *set = [NSSet setWithArray:@[@"x", @"y"]];
    NSMutableSet *mutableSet = [set mutableCopy];
    [mutableSet unionSet:set];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:0];
    NSData *bytes = [multiline dataUsingEncoding:NSUTF8StringEncoding];
    NSRange range = [multiline rangeOfString:@"second"];
    NSURL *url = [NSURL URLWithString:@"https://example.com/path?q=1"];
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    NSString *stamp = [formatter stringFromDate:now];
    CGFloat ratio = (CGFloat)second.doubleValue / 2.0;
    BOOL responds = [mapping respondsToSelector:selector] && protocol != nil && encoding != NULL;
    NSUInteger count = [[mapping allKeys] count] ^ range.length;
    NSInteger parsed = [@"123" integerValue] + (NSInteger)strtol("0x1F", NULL, 16);
    id<TNDeliverable> __autoreleasing *outItem = NULL;
    void (^simpleBlock)(void) = ^{ NSLog(@"%@ %@ %lu %d %@ %@", value, className, (unsigned long)count, responds, stamp, url.host); };
    int (^adder)(int, int) = ^int(int a, int b) { return a + b; };
    NSComparator cmp = ^NSComparisonResult(id lhs, id rhs) { return [lhs compare:rhs]; };
    NSArray *sorted = [copy sortedArrayUsingComparator:cmp];
    __auto_type inferredCount = sorted.count;
    NSUInteger declaredCount = inferredCount;
    NSString * _Nullable nullableName = nil;
    NSString * _Nonnull nonnullName = @"name";
    id untyped = nullableName ?: nonnullName;
    (void)declaredCount; (void)untyped;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF > %@", @1];
    NSArray *filtered = [sorted filteredArrayUsingPredicate:predicate];
    if (@available(macOS 10.14, *)) {
        simpleBlock();
    } else {
        NSLog(@"%d %@ %@ %@ %lu", adder(1, 2), filtered, indexes, bytes, (unsigned long)parsed);
    }
    for (NSString *key in [mapping keyEnumerator]) {
        if ([key hasPrefix:@"n"]) continue;
        break;
    }
    [mapping enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        *stop = [key isEqualToString:@"empty"];
    }];
    (void)ratio; (void)outItem; (void)mutableSet;
}

#pragma clang assume_nonnull end
