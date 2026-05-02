using Godot;

namespace command;

public class Destroy : Command
{
    public IDestroyable target;

    public Destroy(IDestroyable target)
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