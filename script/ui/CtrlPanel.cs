using Godot;
using System;

/// <summary>
/// 角色控制面板
/// </summary>
public partial class CtrlPanel : Control
{
    [Export]
    public GridContainer grid_container_skill;

    public Character character;

    [Export]
    public PackedScene scene_ui_skill;


    public void set_character(Character character)
    {
        this.character = character;

        foreach (var each_skill in character.skills)
        {
            add_skill(each_skill);
        }
    }

    public void add_skill(Skill skill)
    {
        var ui_skill = scene_ui_skill.Instantiate() as ui.Skill;
        grid_container_skill.AddChild(ui_skill);
        ui_skill.texture_rect.Texture = skill.texture;
        ui_skill.btn.Pressed += () =>
        {
            skill.use(character);  
        };
    }
}
