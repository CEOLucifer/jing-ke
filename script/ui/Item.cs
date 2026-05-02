using Godot;

namespace ui;

/// <summary>
/// 物品
/// </summary>
public partial class Item : Control
{
    [Export]
    public TextureRect texture_rect;
    [Export]
    public Button btn;
    [Export]
    public bool is_follow_mouse = false;
    public global::Bag.ItemAdapter item_adapter;

    public override void _Ready()
    {
        base._Ready();

        btn.Pressed += () =>
        {
            BagCtrl.Instance?.set_item_float(this);
        };
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
        if (is_follow_mouse)
        {
            // 跟随鼠标
            var mouse_pos = GetGlobalMousePosition();
            this.Position = mouse_pos + new Vector2(10, 10);

            if (Input.IsActionJustPressed("left_click"))
            {
                BagCtrl.Instance?.put_item();
            }
        }
    }

}
