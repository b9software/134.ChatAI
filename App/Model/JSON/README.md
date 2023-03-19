# JSON 目录

存放 JSON 数据模型。

推荐做法：

* 类名用 Entity 结尾；
* 请求发送、接收时有时需要建立只在该场景下的中转 model，此时类名用 RequestEntity 或 ResponseEntity 结尾，此类 model 只是用做封装，不应在其中包含业务逻辑；
* 提倡富 model，在 model 上承担更多的业务逻辑（如请求发送、发送状态变化通知、状态判断、结构转换等任务），而不是简单的只是声明几个属性；
* 跟业务无关的、与特定页面关联紧密的 model 推荐和 view、vc 放在一起。
