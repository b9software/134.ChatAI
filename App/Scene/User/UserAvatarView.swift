//
//  UserAvatarView.swift
//  App
//

/**
 用户头像 view
 */
class UserAvatarView: MBImageView {
    @objc var item: UserEntity? {
        didSet {
            imageURL = item?.avatar
        }
    }

    override func onInit() {
        super.onInit()
        // 头像应低优先加载，为其他内容让路
        imageLoadInLowPriority = true
    }
}
