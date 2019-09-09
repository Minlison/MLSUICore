//
//  NimbusCommenHeader.h
//  Pods
//
//  Created by minlison on 2018/5/15.
//

#ifndef MLSNimbusCommenHeader_h
#define MLSNimbusCommenHeader_h


#if __has_include("QMUITableViewProtocols.h")

#import "QMUITableViewProtocols.h"
#define NIUITableViewDelegate QMUITableViewDelegate
#define NIUITableViewDataSource QMUITableViewDataSource

#else

#define NIUITableViewDelegate UITableViewDelegate
#define NIUITableViewDataSource UITableViewDataSource

#endif

#endif /* NimbusCommenHeader_h */
