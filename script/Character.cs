using Godot;
using System;

/// <summary>
/// 角色类
/// </summary>
[GlobalClass]
public partial class Character : Node
{
	[Export]
	private uint hp;
	[Export]
	private uint max_hp;
	private Node3D root;
	[Export]
	public Camera3D camera;
	[Export]
	public NavigationAgent3D nav_agent;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		var a = GetParent();
		GD.Print(a.Name);
		root = GetParent<Node3D>();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		ProcessMouse();
	}

	public override void _PhysicsProcess(double delta)
	{
		base._PhysicsProcess(delta);
		ProcessMove(delta);
	}


	#region 移动
	private Vector3 targetPos;
	[Export]
	private float speed = 50;

	public void MoveTo(Vector3 pos)
	{
		targetPos = pos;
		nav_agent.TargetPosition = pos;
	}

	private void ProcessMove(double delta)
	{
		if (nav_agent.IsNavigationFinished())
		{
			return;
		}

		var next_pos = nav_agent.GetNextPathPosition();
		var direction = (next_pos - root.Position).Normalized();
		root.Position += direction * (float)(speed * delta);
	}

	private void ProcessMouse()
	{
		if (Input.IsActionJustPressed("click"))
		{
			var mouse_pos = GetViewport().GetMousePosition();
			var from = camera.ProjectRayOrigin(mouse_pos);
			var to = from + camera.ProjectRayNormal(mouse_pos) * 100;
			var query = PhysicsRayQueryParameters3D.Create(from, to);
			query.CollideWithBodies = true;

			var space_state = camera.GetWorld3D().DirectSpaceState;
			var result = space_state.IntersectRay(query);

			if (result.Count > 0)
			{
				var hit_position = (Vector3)result["position"];
				var collider = result["collider"];
				GD.Print($"Hit: {hit_position}, {collider}");

				MoveTo(hit_position);
			}
			else
			{
				GD.Print("count = 0");
			}
		}
	}
	#endregion
}
