using Godot;

namespace command;

public class MoveAndChat: Command
{
    public Character I;
    public Character you;

    public override void Do(Context context)
    {
        base.Do(context);
        I.move_to(you.GetParent<Node3D>().Position);
        
    }
}