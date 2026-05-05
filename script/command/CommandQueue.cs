using System.Collections.Generic;
using Godot;

/// <summary>
/// 命令队列
/// </summary>
public partial class CommandQueue : Node
{
    private LinkedList<ICommand> queue = new();
    private ICommand cur;

    public void Push(ICommand command)
    {
        queue.AddLast(command);
        Do();
    }

    public void Do()
    {
        if (cur == null)
        {
            if (queue.Count > 0)
            {
                cur = queue.First.Value;
                queue.RemoveFirst();
                cur.Do(null); // todo
            }
        }

    }

    public void Clear()
    {
        queue.Clear();
        if (cur != null)
        {
            cur.Done();
            cur = null;
        }
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
        if (cur != null)
        {
            if (cur.IsDone)
            {
                cur = null;
                Do();
            }
            else
            {
                cur.Process();
            }
        }
    }

    public override void _PhysicsProcess(double delta)
    {
        base._PhysicsProcess(delta);
        if (cur != null)
        {
            if (!cur.IsDone)
            {
                cur.Process_physics();
            }
        }
    }
}