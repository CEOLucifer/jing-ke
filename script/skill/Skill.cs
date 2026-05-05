using Godot;

/// <summary>
/// 技能
/// </summary>
[GlobalClass]
public partial class Skill : Resource
{
    [Export]
    public int id;
    [Export]
    public string name;
    [Export]
    public string description;
    [Export]
    public Texture2D texture;

    public virtual void use(Character character)
    {
        
    }
}