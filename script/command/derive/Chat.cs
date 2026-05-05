using Godot;

namespace command;

public class Chat : Command
{
    public Character I;
    public Character you;

    public override void Do(Context context)
    {
        base.Do(context);
        GD.Print($"开始对话，I:{I}, you:{you}");
        Done();
    }
}