比如，有一个目录下每天会生成一个备份目录，但是我们并不需要这么多，只需要保存最新的 10 个目录就好了，这样的话 awk 就能派上用场了。

ls -lt | grep drwx | awk '{if(NR>10){print $9}}' | xargs -I {} rm -rf {}

类似应用场景非常多

3次GC一次CMS GC:
Jhipster 
K8S
event sourcing

-Xmx42M -Xmn12M -XX:SurvivorRatio=4 -XX:CMSInitiatingOccupancyFraction=50  -XX:+PrintGCDetails -XX:+PrintGCDateStamps 
-XX:+UseConcMarkSweepGC -XX:+UseParNewGC -Xloggc:/test_gc.log
public static void main(String[] args) {
	// 每次new分配1M内存, 24次分配, 8， 16， 24次分别Young GC
	for(int i=0; i<24; i++) {
		byte[] byte1m = new byte[1 * 1024 * 1024];
	}
	// 10M内存Eden区容不下, S区也容不下, 直接进入Old区, 但是还不够30*50%=15M CMS GC触发条件
	byte[] byte10m = new byte[10 * 1024 * 1024];
	// 再分配10M 就够CMS GC触发条件了
	byte[] byte10m2 = new byte[10 * 1024 * 1024];
}
