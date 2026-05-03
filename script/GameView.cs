using Godot;
using Godot.Collections;
using System;

/// <summary>
/// 游戏视图
/// </summary>
public partial class GameView : SingletonNode<GameView>
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
    {
        base._Ready();
    }

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	public MouseRaycastResult get_mouse_raycast_result()
	{
		var mouse_pos = GetViewport().GetMousePosition();
		var camera = CameraCtrl.Instance.camera;
		var from = camera.ProjectRayOrigin(mouse_pos);
		var to = from + camera.ProjectRayNormal(mouse_pos) * 100;
		var param = PhysicsRayQueryParameters3D.Create(from, to);
		param.CollideWithBodies = true;
		

		var space_state = camera.GetWorld3D().DirectSpaceState;
		var dic = space_state.IntersectRay(param);

		var res = new MouseRaycastResult();
		res.dic = dic;

		return res;
	}
}


public struct MouseRaycastResult
{
	public Dictionary dic;
	public Vector3 hit_position => (Vector3)dic["position"];
	public Variant collider => dic["collider"];
	public bool has_value => dic.Count > 0;
}
