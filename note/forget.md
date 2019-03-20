* 类加载
* 反射生成的源码
* 英文文档
* 如果你看这个之前，先研究一下 multipart/form-data 的 MIME 的 HTTP body 是什么样的结构会更明白一些
  服务端推送有很多方式，从旧到新的技术：
  1. ajax 轮询
  2. Flash 插件
  3. Comet
  4. WebSocket
  5. SSE（仅服务端到客户端单向）
  6. HTTP/2