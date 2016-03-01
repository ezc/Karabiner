#import "AppDelegate.h"
#import "ClientForKernelspace.h"
#import "KarabinerKeys.h"
#import "PreferencesKeys.h"
#import "PreferencesManager.h"
#import "Relauncher.h"
#import "ServerForUserspace.h"
#import "XMLCompiler.h"

@interface ServerForUserspace () {
  NSConnection* connection_;
}

@property(weak) IBOutlet AppDelegate* appDelegate;
@property(weak) IBOutlet ClientForKernelspace* clientForKernelspace;
@property(weak) IBOutlet PreferencesManager* preferencesManager;
@property(weak) IBOutlet XMLCompiler* xmlCompiler;

@end

@implementation ServerForUserspace

- (id)init {
  self = [super init];

  if (self) {
    connection_ = [NSConnection new];
  }

  return self;
}

// ----------------------------------------------------------------------
- (BOOL) register {
  [connection_ setRootObject:self];
  if (![connection_ registerName:kKarabinerConnectionName]) {
    return NO;
  }
  return YES;
}

// ----------------------------------------------------------------------
- (int)value:(NSString*)name {
  return [self.preferencesManager value:name];
}

- (int)defaultValue:(NSString*)name {
  return [self.preferencesManager defaultValue:name];
}

- (void)setValue:(int)newval forName:(NSString*)name {
  [self.preferencesManager setValue:newval forName:name];
}

- (NSDictionary*)changed {
  return [self.preferencesManager changed];
}

// ----------------------------------------------------------------------
- (NSInteger)configlist_selectedIndex {
  return [self.preferencesManager configlist_selectedIndex];
}

- (NSArray*)configlist_getConfigList {
  return [self.preferencesManager configlist_getConfigList];
}

- (void)configlist_select:(NSInteger)newIndex {
  [self.preferencesManager configlist_select:newIndex];
}

- (void)configlist_setName:(NSInteger)rowIndex name:(NSString*)name {
  [self.preferencesManager configlist_setName:rowIndex name:name];
}

- (void)configlist_append {
  [self.preferencesManager configlist_append];
}

- (void)configlist_delete:(NSInteger)rowIndex {
  [self.preferencesManager configlist_delete:rowIndex];
}

- (void)configlist_clear_all_values:(NSInteger)rowIndex {
  [self.preferencesManager configlist_clear_all_values:rowIndex];
}

// ----------------------------------------------------------------------
- (void)configxml_reload {
  [self.xmlCompiler reload];
}

- (NSString*)symbolMapName:(NSString*)type value:(NSInteger)value {
  return [self.xmlCompiler symbolMapName:type value:(uint32_t)(value)];
}

- (void)relaunch {
  // Use dispatch_async in order to avoid "disconnected from server".
  //
  // Example error message of disconnection:
  //   "karabiner: connection went invalid while waiting for a reply because a mach port died"
  dispatch_async(dispatch_get_main_queue(), ^{
    [Relauncher relaunch];
  });
}

// ----------------------------------------------------------------------
- (NSDictionary*)preferencesForAXNotifier {
  return @{
    @"kAXNotifierDisabledInJavaApps" : @([[NSUserDefaults standardUserDefaults] boolForKey:kAXNotifierDisabledInJavaApps]),
    @"kAXNotifierDisabledInQtApps" : @([[NSUserDefaults standardUserDefaults] boolForKey:kAXNotifierDisabledInQtApps]),
    @"kAXNotifierDisabledInPreview" : @([[NSUserDefaults standardUserDefaults] boolForKey:kAXNotifierDisabledInPreview]),
    @"kAXNotifierDisabledInMicrosoftOffice" : @([[NSUserDefaults standardUserDefaults] boolForKey:kAXNotifierDisabledInMicrosoftOffice]),
  };
}

- (void)updateFocusedUIElementInformation:(NSDictionary*)information {
  return [self.appDelegate updateFocusedUIElementInformation:information];
}

// ----------------------------------------------------------------------
- (NSArray*)device_information:(NSInteger)type {
  return [self.clientForKernelspace device_information:type];
}

- (NSDictionary*)focused_uielement_information {
  return [self.appDelegate getFocusedUIElementInformation];
}

- (NSArray*)workspace_app_ids {
  return [self.appDelegate getWorkspaceAppIds];
}

- (NSArray*)workspace_window_name_ids {
  return [self.appDelegate getWorkspaceWindowNameIds];
}

- (NSArray*)workspace_inputsource_ids {
  return [self.appDelegate getWorkspaceInputSourceIds];
}

- (NSDictionary*)inputsource_information {
  return [self.appDelegate getInputSourceInformation];
}

@end
