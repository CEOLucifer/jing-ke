using Godot;
using System;

[GlobalClass]
public partial class GameModel : Node
{
	/// <summary>
	/// 当前正在操作的角色
	/// </summary>
	[Export]
	public Character character;

	[Export]
	public CanvasLayer canvas_layer;
}
