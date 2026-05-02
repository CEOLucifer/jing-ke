using Godot;
using System;

/// <summary>
/// 游戏视图
/// </summary>
public partial class GameView : Node
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
    {
        Raycast_NPC();
    }

	/// <summary>
	/// 鼠标射线检测NPC
	/// </summary>
	public void Raycast_NPC()
	{
		// 高亮
	}
}
