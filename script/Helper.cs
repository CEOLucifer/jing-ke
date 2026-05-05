using Godot;

public static class Helper
{
    public static bool is_mouse_overlaped(this Control control)
    {
        var mouse_pos = control.GetLocalMousePosition();
        if (mouse_pos.X < 0 || mouse_pos.Y < 0 || mouse_pos.X > control.Size.X || mouse_pos.Y > control.Size.Y)
        {
            return false;
        }
        return true;
    }

    public static T get_sibling<T>(this Node self) where T : Node
    {
        var children = self.GetParent().GetChildren();
        foreach (var each in children)
        {
            if (each is T res)
            {
                return res;
            }
        }
        return null;
    }

    public static T get_child<T>(this Node self) where T : Node
    {
        var children = self.GetChildren();
        foreach (var each in children)
        {
            if (each is T res)
            {
                return res;
            }
        }
        return null;
    }

    public static void set_param(this AnimationTree @this, string condition, Variant value)
    {
        @this.Set($"parameters/{condition}", value);
    }
}