// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: google/protobuf/field_mask.proto

#import "GPBProtocolBuffers_RuntimeSupport.h"
#import "google/protobuf/FieldMask.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma mark - GPBFieldMaskRoot

@implementation GPBFieldMaskRoot

@end

#pragma mark - GPBFieldMaskRoot_FileDescriptor

static GPBFileDescriptor *GPBFieldMaskRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPBDebugCheckRuntimeVersion();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"google.protobuf"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - GPBFieldMask

@implementation GPBFieldMask

@dynamic pathsArray, pathsArray_Count;

typedef struct GPBFieldMask__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *pathsArray;
} GPBFieldMask__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "pathsArray",
        .number = GPBFieldMask_FieldNumber_PathsArray,
        .hasIndex = GPBNoHasBit,
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeString,
        .offset = offsetof(GPBFieldMask__storage_, pathsArray),
        .defaultValue.valueMessage = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[GPBFieldMask class]
                                     rootClass:[GPBFieldMaskRoot class]
                                          file:GPBFieldMaskRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(GPBFieldMask__storage_)
                                    wireFormat:NO];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


// @@protoc_insertion_point(global_scope)
