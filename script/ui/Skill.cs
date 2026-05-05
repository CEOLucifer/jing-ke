using Godot;

namespace ui;

public partial class Skill : Control
{
    [Export]
    public TextureRect texture_rect;
    [Export]
    public Button btn;
    public Skill skill;
}
