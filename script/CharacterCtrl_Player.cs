using Godot;
using System;
using System.Linq;

/// <summary>
/// 角色控制器，玩家
/// </summary>
[GlobalClass]
public partial class CharacterCtrl_Player : Node
{
	[Export]
	public Camera3D camera;

	[Export]
	public Character character;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		if (character == null)
			character = this.get_sibling<Character>();

		GameCtrl.Instance.model.character = character;
	}


	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		ProcessMouse();
	}

	private void ProcessMouse()
	{
		if (Input.IsActionJustPressed("left_click"))
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

				character.MoveTo(hit_position);
			}
			else
			{
				GD.Print("count = 0");
			}
		}
	}

}
