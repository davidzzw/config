### 快捷键

* `快速找到Controller方法`:`ctrl+alt+shift+n`
* `Ctrl+Shift+Alt+J`:`批量修改变量快捷键`
* `Ctrl+Alt+Shift+T`:`弹出重构菜单`
* `Shift+F6`：`重命名类文件`
* `ctr+shift+u`：`小写转大写`
* `Ctrl + G`:` 跳到指定行`

###idea参数优化

```
-Xms1024m
-Xmx1024m
-Xmn372m
-XX:MetaspaceSize=256m
-XX:MaxMetaspaceSize=512m
-XX:ReservedCodeCacheSize=240m
-XX:+UseConcMarkSweepGC
-XX:+UseParNewGC
-XX:+CMSParallelRemarkEnabled
-XX:+CMSScavengeBeforeRemark
-XX:CMSInitiatingOccupancyFraction=75
-XX:+UseCMSInitiatingOccupancyOnly
-XX:+UseCMSCompactAtFullCollection
-XX:CMSFullGCsBeforeCompaction=3
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:+HeapDumpOnOutOfMemoryError
-XX:CICompilerCount=2 
-XX:InitialHeapSize=31457280
-XX:+ManagementServer 
-XX:MaxHeapSize=480247808 
-XX:MaxNewSize=160038912
-XX:MinHeapDeltaBytes=196608 
-XX:NewSize=10485760 
-XX:OldSize=20971520 
-XX:+UseCompressedClassPointers 
-XX:+UseCompressedOops 
-XX:+UseFastUnorderedTimeStamps 
CATALINA_OPTS="$CATALINA_OPTS 
-Dcom.sun.management.jmxremote
-Djava.rmi.server.hostname=192.168.220.131 
-Dcom.sun.management.jmxremote.port=8999 
-Dcom.sun.management.jmxremote.ssl=false 
-Dcom.sun.management.jmxremote.authenticate=false"
MaxMetaspaceSize
CompressedClassSpaceSize
Klass Metaspace
NoKlass Metaspace
-XX:CompressedClassSpaceSize
UseLargePagesInMetaspace
InitialBootClassLoaderMetaspaceSize
MetaspaceSize
MaxMetaspaceSize
CompressedClassSpaceSize
MinMetaspaceExpansion
MaxMetaspaceExpansion
MinMetaspaceFreeRatio
MaxMetaspaceFreeRatio
```

```
格式化代码：格式化import列表Ctrl+Alt+O，格式化代码Ctrl+Alt+L。
Ctrl+Shift + Enter，语句完成
“！”，否定完成，输入表达式时按 “！”键
Ctrl+E，最近的文件
Ctrl+Shift+E，最近更改的文件
Shift+Click，可以关闭文件
Ctrl+[ OR ]，可以跑到大括号的开头与结尾
Ctrl+F12，可以显示当前文件的结构
Ctrl+F7，可以查询当前元素在当前文件中的引用，然后按 F3 可以选择

Ctrl+N，可以快速打开类

Ctrl+Shift+N，可以快速打开文件

Alt+Q，可以看到当前方法的声明

Ctrl+P，可以显示参数信息

Ctrl+Shift+Insert，可以选择剪贴板内容并插入

Alt+Insert，可以生成构造器/Getter/Setter等

Ctrl+Alt+V，可以引入变量。例如：new String(); 自动导入变量定义

Ctrl+Alt+T，可以把代码包在一个块内，例如：try/catch

Ctrl+Enter，导入包，自动修正

Ctrl+Alt+L，格式化代码

Ctrl+Alt+I，将选中的代码进行自动缩进编排，这个功能在编辑 JSP 文件时也可以工作

Ctrl+Alt+O，优化导入的类和包

Ctrl+R，替换文本

Ctrl+F，查找文本

Ctrl+Shift+Space，自动补全代码

Ctrl+空格，代码提示（与系统输入法快捷键冲突）

Ctrl+Shift+Alt+N，查找类中的方法或变量

Alt+Shift+C，最近的更改

Alt+Shift+Up/Down，上/下移一行

Shift+F6，重构 – 重命名

Ctrl+X，删除行

Ctrl+D，复制行

Ctrl+/或Ctrl+Shift+/，注释（//或者/**/）

Ctrl+J，自动代码（例如：serr）

Ctrl+Alt+J，用动态模板环绕

Ctrl+H，显示类结构图（类的继承层次）

Ctrl+Q，显示注释文档

Alt+F1，查找代码所在位置

Alt+1，快速打开或隐藏工程面板

Ctrl+Alt+left/right，返回至上次浏览的位置

Alt+left/right，切换代码视图

Alt+Up/Down，在方法间快速移动定位

Ctrl+Shift+Up/Down，向上/下移动语句

F2 或 Shift+F2，高亮错误或警告快速定位

Tab，代码标签输入完成后，按 Tab，生成代码

Ctrl+Shift+F7，高亮显示所有该文本，按 Esc 高亮消失

Alt+F3，逐个往下查找相同文本，并高亮显示

Ctrl+Up/Down，光标中转到第一行或最后一行下

Ctrl+B/Ctrl+Click，快速打开光标处的类或方法（跳转到定义处）

Ctrl+Alt+B，跳转到方法实现处

Ctrl+Shift+Backspace，跳转到上次编辑的地方

Ctrl+O，重写方法

Ctrl+Alt+Space，类名自动完成

Ctrl+Alt+Up/Down，快速跳转搜索结果

Ctrl+Shift+J，整合两行

Alt+F8，计算变量值

Ctrl+Shift+V，可以将最近使用的剪贴板内容选择插入到文本

Ctrl+Alt+Shift+V，简单粘贴

Shift+Esc，不仅可以把焦点移到编辑器上，而且还可以隐藏当前（或最后活动的）工具窗口

F12，把焦点从编辑器移到最近使用的工具窗口

Shift+F1，要打开编辑器光标字符处使用的类或者方法 Java 文档的浏览器

Ctrl+W，可以选择单词继而语句继而行继而函数

Ctrl+Shift+W，取消选择光标所在词

Alt+F7，查找整个工程中使用地某一个类、方法或者变量的位置

Ctrl+I，实现方法

Ctrl+Shift+U，大小写转化

Ctrl+Y，删除当前行

Shift+Enter，向下插入新行

psvm/sout，main/System.out.println(); Ctrl+J，查看更多

Ctrl+Shift+F，全局查找

Ctrl+F，查找/Shift+F3，向上查找/F3，向下查找

Ctrl+Shift+S，高级搜索

Ctrl+U，转到父类

Ctrl+Alt+S，打开设置对话框

Alt+Shift+Inert，开启/关闭列选择模式

Ctrl+Alt+Shift+S，打开当前项目/模块属性

Ctrl+G，定位行

Alt+Home，跳转到导航栏

Ctrl+Enter，上插一行

Ctrl+Backspace，按单词删除

Ctrl+”+/-”，当前方法展开、折叠

Ctrl+Shift+”+/-”，全部展开、折叠

【调试部分、编译】

Ctrl+F2，停止

Alt+Shift+F9，选择 Debug

Alt+Shift+F10，选择 Run

Ctrl+Shift+F9，编译

Ctrl+Shift+F10，运行

Ctrl+Shift+F8，查看断点

F8，步过

F7，步入

Shift+F7，智能步入

Shift+F8，步出

Alt+Shift+F8，强制步过

Alt+Shift+F7，强制步入

Alt+F9，运行至光标处

Ctrl+Alt+F9，强制运行至光标处

F9，恢复程序

Alt+F10，定位到断点

Ctrl+F8，切换行断点

Ctrl+F9，生成项目

Alt+1，项目

Alt+2，收藏

Alt+6，TODO

Alt+7，结构

Ctrl+Shift+C，复制路径

Ctrl+Alt+Shift+C，复制引用，必须选择类名

Ctrl+Alt+Y，同步

Ctrl+~，快速切换方案（界面外观、代码风格、快捷键映射等菜单）

Shift+F12，还原默认布局

Ctrl+Shift+F12，隐藏/恢复所有窗口

Ctrl+F4，关闭

Ctrl+Shift+F4，关闭活动选项卡

Ctrl+Tab，转到下一个拆分器

Ctrl+Shift+Tab，转到上一个拆分器

【重构】

Ctrl+Alt+Shift+T，弹出重构菜单

Shift+F6，重命名

F6，移动

F5，复制

Alt+Delete，安全删除

Ctrl+Alt+N，内联

【查找】

Ctrl+F，查找

Ctrl+R，替换

F3，查找下一个

Shift+F3，查找上一个

Ctrl+Shift+F，在路径中查找

Ctrl+Shift+R，在路径中替换

Ctrl+Shift+S，搜索结构

Ctrl+Shift+M，替换结构

Alt+F7，查找用法

Ctrl+Alt+F7，显示用法

Ctrl+F7，在文件中查找用法

Ctrl+Shift+F7，在文件中高亮显示用法

1、文本编辑

删除    ctr + y

        复制    ctr + D

2、智能提示

       提示    ctr + space

       智能提示 ctr + shift + space

       完成当前语句  ctr + shift + enter

       建议提示为参数  ctr + alt + P

       对代码重新排列格式 Ctrl + Alt + L

           对imports进行优化                                                            Ctrl + Alt + O

3、位置定位

定位到下一个或上一个错误 F2 / Shift + F2

定位文件头   ctr+G    （定位到文件行数）

定位文件尾   ctr+G    

       定位到代码块开始  ctr + [

       定位到代码块结束  ctr + ]

       回到最近的窗口      F12

         回到之前的文件  alt + left

        回到之后的文件   alt + right

       定位到最后编辑位置  Ctrl?+?Shift?+?Backspace

      从tool window或其他window切换到文件编辑    esc

     关闭最近打开的窗口    shift + esc

4、类、方法、文件定位

查找类    ctr + N

        查找文件  Ctrl + Shift + N

          符号定位     Ctrl + Alt + Shift + N

       查看文件结构   ctrl + F12

       最近打开的文件  ctr + E

       定位下一个方法 alt + down

       定位上一个方法  alt + up

      查看方法参数信息  ctr + p

     查看方法、类的doc ctr + Q

5、类、方法的结构查看、定位

      跳到类或方法的声明         ctr + B

       定位到类的父类、接口     ctr + U

       查看类的继承结构             ctr + H

      查看方法的继承结构          ctr + shift + H

      查看类或方法被调用情况  ctr + alt +H 

      原地参看类、方法的声明 Ctrl + Shift + I

6、运行与调试

    Compile and Run

Ctrl + F9 Make project (compile modifed and dependent)

Ctrl + Shift + F9 Compile selected file, package or module

Alt + Shift + F10 Select configuration and run

Alt + Shift + F9 Select configuration and debug

Shift + F10 Run

Shift + F9 Debug

Ctrl + Shift + F10 Run context configuration from editor

Debugging

F8 Step over

F7 Step into

Shift + F7 Smart step into

Shift + F8 Step out

Alt + F9 Run to cursor

Alt + F8 Evaluate expression

F9 Resume program

Ctrl + F8 Toggle breakpoint

Ctrl + Shift + F8 View breakpoints

1. IDEA内存优化 
   \IntelliJ IDEA 9\bin\idea.exe.vmoptions

---

-Xms64m

-Xmx256m

-XX:MaxPermSize=92m

-ea

-server

-Dsun.awt.keepWorkingSetOnMinimize=true

2、查询快捷键

CTRL+N           查找类

CTRL+SHIFT+N     查找文件

CTRL+SHIFT+ALT+N 查找类中的方法或变量

CIRL+B           找变量的来源

CTRL+ALT+B       找所有的子类

CTRL+SHIFT+B     找变量的类

CTRL+G           定位行

CTRL+F           在当前窗口查找文本

CTRL+SHIFT+F     在指定窗口查找文本

CTRL+R           在当前窗口替换文本

CTRL+SHIFT+R     在指定窗口替换文本

ALT+SHIFT+C      查找修改的文件

CTRL+E           最近打开的文件

F3               向下查找关键字出现位置

SHIFT+F3         向上一个关键字出现位置

F4               查找变量来源

CTRL+ALT+F7      选中的字符查找工程出现的地方

CTRL+SHIFT+O     弹出显示查找内容

3、SVN 管理

把SVN库添加到IDEA中 SETTING ->  VERSION CONTROL -> VCS = SVBVERSION

4、自动代码

ALT+ENTER        导入包,自动修正

CTRL+ALT+L       格式化代码

CTRL+ALT+I       自动缩进

CTRL+ALT+O       优化导入的类和包

ALT+INSERT       生成代码(如GET,SET方法,构造函数等)

CTRL+E           最近更改的代码

ALT+SHIFT+C      最近更改的代码

CTRL+SHIFT+SPACE 自动补全代码

CTRL+空格        代码提示

CTRL+ALT+SPACE   类名或接口名提示

CTRL+P           方法参数提示

CTRL+J           自动代码

CTRL+ALT+T       把选中的代码放在 TRY{} IF{} ELSE{} 里

5、复制快捷方式

F5            拷贝文件快捷方式

CTRL+D        复制行

CTRL+X        剪切,删除行

CTRL+SHIFT+V  可以复制多个文本

6、高亮

CTRL+F         选中的文字,高亮显示 上下跳到下一个或者上一个

F2或SHIFT+F2   高亮错误或警告快速定位

CTRL+SHIFT+F7  高亮显示多个关键字.

7、其他快捷方式

CIRL+U            大小写切换

CTRL+Z            倒退

CTRL+SHIFT+Z      向前

CTRL+ALT+F12      资源管理器打开文件夹

ALT+F1            查找文件所在目录位置

SHIFT+ALT+INSERT  竖编辑模式

CTRL+/            注释// 

CTRL+SHIFT+/      注释/.../

CTRL+W            选中代码，连续按会 有其他效果

CTRL+B            快速打开光标处的类或方法

ALT+ ←/→          切换代码视图

CTRL+ALT ←/→      返回上次编辑的位置

ALT+ ↑/↓          在方法间快速移动定位

SHIFT+F6          重构-重命名

CTRL+H            显示类结构图

CTRL+Q            显示注释文档

ALT+1             快速打开或隐藏工程面板

CTRL+SHIFT+UP/DOWN 代码 向上/下移动。

CTRL+UP/DOWN      光标跳转到第一行或最后一行下

ESC               光标返回编辑框

SHIFT+ESC         光标返回编辑框,关闭无用的窗口

F1                帮助千万别按,很卡!

CTRL+F4           非常重要下班都用

8、重要的设置

不编译某个MODULES的方法，但在视图上还是有显示

SETTINGS -> COMPILER -> EXCLUDES ->

不编译某个MODULES，并且不显示在视图上

MODULES SETTINGS -> (选择你的MODULE) -> SOURCES -> EXCLUDED -> 整个工程文件夹

9、IDEA编码设置3步曲

FILE -> SETTINGS -> FILE ENCODINGS -> IDE ENCODING

FILE -> SETTINGS -> FILE ENCODINGS -> DEFAULT ENCODING FOR PROPERTIES FILES

FILE -> SETTINGS -> COMPILER -> Java COMPILER -> ADDITIONAL COMMAND LINE PARAMETERS加上参数 -ENCODING UTF-8 编译GROOVY文件的时候如果不加，STRING S = "中文"; 这样的GROOVY文件编译不过去.

10、编译中添加其他类型文件比如 *.TXT *.INI

FILE -> SETTINGS -> RESOURCE PATTERNS

改变编辑文本字体大小

FILE -> SETTINGS -> EDITOR COLORS & FONTS -> FONT -> SIZE

11、修改智能提示快捷键

FILE -> SETTINGS -> KEYMAP -> MAIN MENU -> CODE -> COMPLETE CODE -> BASIC

12、显示文件过滤

FILE -> SETTINGS -> FILE TYPES -> IGNORE FILES...

下边是我过滤的类型,区分大小写的

CVS;SCCS;RCS;rcs;.DS_Store;.svn;.pyc;.pyo;.pyc;.pyo;.Git;.hprof;_svn;.sbas;.IJI.;vssver.scc;vssver2.scc;.;.iml;.ipr;.iws;*.ids

13、在PROJECT窗口中快速定位,编辑窗口中的文件 

在编辑的所选文件按ALT+F1, 然后选择PROJECT VIEW

```

