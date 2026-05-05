using Godot;
using Godot.Collections;
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
	public int id;
	[Export]
	public string name;
	[Export]
	private uint hp;
	[Export]
	private uint max_hp;
	private Node3D root;
	[Export]
	public NavigationAgent3D nav_agent;
	public Bag bag = new();
	[Export]
	public Node3D model_root;


	#region 属性
	[Export]
	public int strength;
	[Export]
	public int agility;
	[Export]
	public int constitution;
	[Export]
	public int intelligence;
	[Export]
	public int perception;
	[Export]
	public int appeal;


	#endregion

	[Export]
	public Array<Skill> skills;


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
		process_move(delta);
	}



	#region 移动
	private Vector3 targetPos;
	[Export]
	private float speed = 50;
	public Action on_move_complete;
	private bool is_moving = false;

	public bool Is_moving => is_moving;

	public void move_to(Vector3 pos)
	{
		targetPos = pos;
		nav_agent.TargetPosition = pos;
		is_moving = true;
	}

	private void process_move(double delta)
	{
		if (is_moving)
		{
			if (nav_agent.IsNavigationFinished())
			{
				anim_player.Play("human/idle");
				is_moving = false;
				on_move_complete?.Invoke();
				return;
			}

			var next_pos = nav_agent.GetNextPathPosition();
			var direction = (next_pos - root.Position).Normalized();
			root.Position += direction * (float)(speed * delta);

			// 调整朝向
			root.LookAt(next_pos, Vector3.Up, true);
			var rotation = root.Rotation;
			rotation.X = 0;
			root.Rotation = rotation;

			anim_player.Play("human/slow_run");
		}
	}

	public void stop_move()
	{
		is_moving = false;
		anim_player.Play("human/idle");
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
		anim_player = model_root.get_child<AnimationPlayer>();
		anim_player.Play("human/idle");
	}
	#endregion
}
