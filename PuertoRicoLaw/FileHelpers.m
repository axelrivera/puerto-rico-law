//
//  FileHelpers.m
//
//  Copyright 2010 Axel Rivera. All rights reserved.
//

#include "FileHelpers.h"

NSString *pathInDocumentDirectory(NSString *fileName)
{
	// Get list of document directories in sandbox
	NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	// Get one and only document directory from that list
	NSString *documentDirectory = [documentDirectories objectAtIndex:0];
	
	// Append passed in file name to that directory, return it
	return [documentDirectory stringByAppendingPathComponent:fileName];
}

NSString *pathInBooksDirectory(NSString *fileName)
{
	NSString *path = pathInDocumentDirectory(@"Books");
	return [path stringByAppendingPathComponent:fileName];
}

NSString *pathInTemporaryDirectory(NSString *fileName)
{
	return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

NSString *bookDataPath(void)
{
	return pathInDocumentDirectory(@"bookData.data");
}

BOOL deletePathInDocumentDirectory(NSString *fileName)
{
	NSString *filePath = pathInDocumentDirectory(fileName);
	return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

BOOL deletePathInBooksDirectory(NSString *fileName)
{
	NSString *filePath = pathInBooksDirectory(fileName);
	return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

BOOL deletePathInTemporaryDirectory(NSString *fileName)
{
	NSString *filePath = pathInTemporaryDirectory(fileName);
	return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}
