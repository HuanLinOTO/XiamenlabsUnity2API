编写过程中的注意事项：

1. 所有的开发备忘录和说明文档均输出到 .agent/docs/<StageName>/ 目录
2. 所有的程序功能性调试脚本均输出到 .agent/tests/<StageName> 目录
3. 无论你需要执行什么命令，请务必将你的命令写入到 .agent/do.sh 或者 .agent/do.bat （视操作系统而定）中，并且使用相同的命令调用工具来执行这个脚本，避免我重复确认你的命令
4. 当你启动一个 http 服务器时，请务必使用 Powershell 的 BackgroundTask，并且在完成任务后终止这个 BackgroundTask
5. 如果你当前任务没有足够的代码上下文，请务必阅读足量的代码，使用尽可能多的代码搜索进行项目了解
