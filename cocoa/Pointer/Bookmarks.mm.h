//
//  BookmarksViewController.h
//  Pointer
//
//  Created by Yu Li on 2018-10-19.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <docviewer/docviewer.h>

NS_ASSUME_NONNULL_BEGIN

@interface BookmarksViewController : NSViewController
{
    IBOutlet NSView* m_parent;
}
@end

@interface BookmarksCollectionViewDataSource : NSObject<NSCollectionViewDataSource>

@end

@interface BookmarksCollectionViewDelegate : NSObject<NSCollectionViewDelegate>

@end

@interface BookmarksCollectionViewItem : NSCollectionViewItem
{
    Webpage_ m_webpage;
}
@property Webpage_ webpage;
@end

NS_ASSUME_NONNULL_END
