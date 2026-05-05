using Godot;

namespace bag;

/// <summary>
/// 物品适配器。物品在背包中存在“坐标”。
/// </summary>
[GlobalClass]
public partial class ItemAdapter : Resource
{
    /// <summary>
    /// 物品
    /// </summary>
    [Export]
    public Item item;

    /// <summary>
    /// 物品坐标
    /// </summary>
    [Export]
    public Vector2I coord;
}