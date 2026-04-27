using Godot;

public partial class MyCommandQueue : CommandQueue
{
    public override void _Ready()
    {
        base._Ready();

        Push(new Command_Destroy(null));
        Push(new Command_Destroy(null));
        Push(new Command_Destroy(null));
        Push(new Command_Destroy(null));
        Push(new Command_Destroy(null));
        Push(new Command_Destroy(null));
    }

    public override void _Process(double delta)
    {
        base._Process(delta);


    }
}