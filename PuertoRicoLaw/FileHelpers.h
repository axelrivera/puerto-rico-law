//
//  FileHelpers.h
//
//  Copyright 2010 Axel Rivera. All rights reserved.
//

NSString *pathInDocumentDirectory(NSString *fileName);
NSString *pathInBooksDirectory(NSString *fileName);
NSString *pathInTemporaryDirectory(NSString *fileName);
NSString *bookDataPath(void);
BOOL deletePathInDocumentDirectory(NSString *fileName);
BOOL deletePathInBooksDirectory(NSString *fileName);
BOOL deletePathInTemporaryDirectory(NSString *fileName);
