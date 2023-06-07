# MBAppKit

[![Build Status](https://img.shields.io/travis/RFUI/MBAppKit.svg?style=flat-square&colorA=333333&colorB=6600cc)](https://travis-ci.com/RFUI/MBAppKit)
[![Codecov](https://img.shields.io/codecov/c/github/RFUI/MBAppKit.svg?style=flat-square&colorA=333333&colorB=6600cc)](https://codecov.io/gh/RFUI/MBAppKit)

## Requirements

Xcode 11+, iOS 9+ / macOS 10.10+.

## Install

Install using CocoaPods is highly recommended.

```ruby
pod 'MBAppKit', :git => 'https://github.com/RFUI/MBAppKit.git', :subspecs => [
    'Button',
    'Environment',
    'Input',
    'Navigation',
    'RootViewController'
    'Worker',
]
```

You must specify the git source, as this pod will never be shipped to the master spec repo.

Because some components must be defined in the main project which contains MBAppKit. So it can never pass the pod lint validation.

## The Core

The core part defines some of the key components of an application and defines a set of paradigm of the application behaviors.

## Subspec list

* UserIDIsString

    By default, the user ID is an integer value. If you want it to be a string, you can include this subspec in your podfile.

* Button

* Environment

* Input

* Navigation

* RootViewController

* Worker

    MBWorker is a very powerful tool that can write logic in a worker to achieve decoupling.

    Typical usage scenario:

    After an application is launched, multiple modules need to synchronize data in the background and send a large number of requests. Usually these requests will not be urgent, but will block the UI data requests, resulting in a bad user experience. By using MBWorker, these requests can be executed one by one to avoid blocking the networking queue.

    In addition, MBWorker also supports:

    * Support priority. Some operations can only be performed when idle, while some others can be performed prioritized.
    * Support timeout mechanism. Some workers may not finish for a long time (due to network timeouts or bugs). The timeout mechanism ensures that the worker queue is not blocked for these reasons.
    * Support trigger control. Some workers should only be executed when the app is in the foreground, while some workers only execute when the user logs in which switching users or logging out should not be performed. Meanwhile, the worker creation and actual execution time is different. MBWorker can handle these cases in a elegant way.

## FAQs

### Build fails because symbol(s) not found

Some debugging tools and managers must be compiled along with the main project.

Check out `shadow.h` and implementation them in the main project.
