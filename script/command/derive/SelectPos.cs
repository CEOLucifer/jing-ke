using System;
using Godot;

namespace command;

public class SelectPos : Command
{
    public Action<Vector3> callback;

    private Vector3 pos;

    public override void Process()
    {
        base.Process();

        if (Input.IsActionJustPressed("left_click"))
        {
            var res = GameView.Instance.get_mouse_raycast_result();
            if (res.has_value)
            {
                pos = res.hit_position;
                Done();
            }
        }
    }

    public override void Done_complete()
    {
        base.Done_complete();
        callback?.Invoke(pos);
    }
}