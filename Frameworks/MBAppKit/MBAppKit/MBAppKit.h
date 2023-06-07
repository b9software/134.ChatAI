/*!
 MBAppKit.h
 
 Copyright © 2018 RFUI.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 
 供 App 项目使用，可以导入到所有 App 的文件中，
 但 AppKit 中的文件不应 import 这个文件。
 */
#pragma once

#import <RFKit/RFKit.h>
#import <RFInitializing/RFInitializing.h>

// API、User、AppDelegate 等模块一般都需要在 app 项目中重载，可在项目中的公共头文件中包含
