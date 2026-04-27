using Godot;

public class Command_Destroy : Command
{
    public IDestroyable target;

    public Command_Destroy(IDestroyable target)
    {
        this.target = target;
    }

    public override void Do(Context context)
    {
        target?.DestroyThis();

        GD.Print($"{target} destroyed.");

        Done();
    }
}