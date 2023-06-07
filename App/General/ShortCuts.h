//
//  ShortCuts
//  App
//
#import <UIKit/UIKit.h>

/**
 快速访问一些全局对象，见 ShortCuts.swift
 */

NS_ASSUME_NONNULL_BEGIN

/// 全局导航
FOUNDATION_EXPORT UINavigationController *__nullable AppNavigationController(void);

@class MessageManager;
FOUNDATION_EXPORT MessageManager *__nonnull AppHUD(void);

NS_ASSUME_NONNULL_END
