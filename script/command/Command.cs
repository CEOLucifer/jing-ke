using Godot;

/// <summary>
/// 命令
/// </summary>
public class Command : ICommand
{
    private bool isDone = false;

    public bool IsDone
    {
        get => isDone;
    }

    public virtual void Do(Context context) { }

    public void Done() { isDone = true; Done_complete(); }

    public virtual void Done_complete() { }

    public virtual void Process() { }

    public virtual void Process_physics() { }
}