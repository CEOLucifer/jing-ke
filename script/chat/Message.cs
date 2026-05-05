using System.Collections.Generic;

/// <summary>
/// 表示一个对话消息
/// </summary>
public class Message
{
    /// <summary>
    /// 消息的内容
    /// </summary>
    public string content;

    /// <summary>
    /// 消息包含的选项
    /// </summary>
    public List<Selection> selections;
}