/*
 * Copyright 2022 Google LLC. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "GooglePlacesXCFrameworkDemos/DemoSceneDelegate.h"

#import "GooglePlacesXCFrameworkDemos/DemoData.h"
#import "GooglePlacesXCFrameworkDemos/DemoListViewController.h"

@implementation DemoSceneDelegate

- (void)scene:(UIScene *)scene
    willConnectToSession:(UISceneSession *)session
                 options:(UISceneConnectionOptions *)connectionOptions {
  if (![scene isKindOfClass:[UIWindowScene class]]) {
    return;
  }
  UIWindowScene *windowScene = (UIWindowScene *)scene;
  self.window = [[UIWindow alloc] initWithWindowScene:windowScene];

  // Create our view controller with the list of demos.
  DemoData *demoData = [[DemoData alloc] init];
  DemoListViewController *masterViewController =
      [[DemoListViewController alloc] initWithDemoData:demoData];
  UINavigationController *masterNavigationController =
      [[UINavigationController alloc] initWithRootViewController:masterViewController];
  self.window.rootViewController = masterNavigationController;

  [self.window makeKeyAndVisible];
}

@end
