```java
put(byte b)	相对写，向position的位置写入一个byte，并将postion+1，为下次读写作准备
put(int index, byte b)绝对写，向byteBuffer底层的bytes中下标为index的位置插入byte b，不改变position
put(ByteBuffer src)	用相对写，把src中可读的部分（也就是position到limit）写入此byteBuffer
put(byte[] src, int offset, int length)	从src数组中的offset到offset+length区域读取数据并使用相对写写入此byteBuffer
```

