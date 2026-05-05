using Godot;
using System;

public partial class Bot : Node3D
{
	[Signal]
	public delegate void on_jump_upEventHandler();

	public void jump_up()
	{
		// 接收到动画事件，转发信号给外部
		EmitSignal(SignalName.on_jump_up);
	}
}
