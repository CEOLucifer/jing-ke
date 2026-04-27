using Godot;
using System;

/// <summary>
/// 主入口
/// </summary>
public partial class Main : Node3D
{
    [Export]
    public Agent agent;

    public override void _Ready()
    {
        agent.Init();
    }

}
