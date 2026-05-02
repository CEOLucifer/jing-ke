using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

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
	public NavigationAgent3D nav_agent;
	public Bag bag = new();

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		root = GetParent<Node3D>();

		init_equipment_list();

		if (nav_agent == null)
		{
			nav_agent = GetParent().FindChild("NavigationAgent3D", false) as NavigationAgent3D;
		}

		init_anim_player();
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
			anim_player.Play("human/idle");
			return;
		}

		var next_pos = nav_agent.GetNextPathPosition();
		var direction = (next_pos - root.Position).Normalized();
		root.Position += direction * (float)(speed * delta);

		// 调整朝向
		root.LookAt(next_pos, Vector3.Up, true);

		anim_player.Play("human/slow_run");
	}

	#endregion


	#region 装备
	public List<Equipment> equipments = new();

	private void init_equipment_list()
	{
		for (var i = 0; i < (int)Equipment.EType.None; ++i)
		{
			equipments.Add(null);
		}
	}

	/// <summary>
	/// 获取指定类型装备，该装备已被装配于该角色身上。
	/// </summary>
	/// <param name="type"></param>
	/// <returns></returns>
	public Equipment get_equipment(Equipment.EType type)
	{
		return equipments[(int)type];
	}
	#endregion

	#region 动画
	public AnimationPlayer anim_player;

	private void init_anim_player()
	{
		anim_player = this.get_sibling<AnimationPlayer>();
	}
	#endregion
}
