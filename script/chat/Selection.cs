using System.Collections.Generic;

/// <summary>
/// 对话选项
/// </summary>
public class Selection
{
    public Condition condition;
    public string content;
    public List<Command> commands;
}