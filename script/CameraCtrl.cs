using Godot;
using System;

[GlobalClass]
public partial class CameraCtrl : Node
{
	[Export]
	public Camera3D camera;

	[Export]
	public Node3D target;

	[Export]
	public float speed = 5;

	[Export]
	public Vector3 offset = new(5,10,5);

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		if (camera == null)
		{
			camera = GetParent() as Camera3D;
		}
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _PhysicsProcess(double delta)
	{
		if (target != null && camera != null)
		{

			camera.LookAt(target.Position);

			// 移动
			var pos = camera.Position;
			pos = pos.Lerp(target.Position + offset, speed * (float)delta);
			camera.Position = pos;
		}

	}
}
