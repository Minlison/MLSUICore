//
//  NICollectionViewCellFactory+Private.h
//  MLSProject
//
//  Created by minlison on 2018/12/1.
//  Copyright © 2018年 minlison. All rights reserved.
//

#import "NICollectionViewCellFactory.h"

@interface NINibCollectionViewCellObject ()

// A property to change the cell class of this cell object.
@property (assign, nonatomic) Class collectionViewCellClass;

@property (strong, nonatomic) UINib *collectionViewCellNib;
@end

@interface NICollectionViewCellObject ()
// A property to change the cell class of this cell object.
@property (assign, nonatomic) Class collectionViewCellClass;
@end
