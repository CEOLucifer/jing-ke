using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;
using System.Diagnostics;
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
	private CharacterBody3D root;
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
		root = GetParent<CharacterBody3D>();

		init_equipment_list();

		if (nav_agent == null)
		{
			nav_agent = GetParent().FindChild("NavigationAgent3D", false) as NavigationAgent3D;
		}

		init_anim_player();

		connect_nav_agent();
	}



	public override void _PhysicsProcess(double delta)
	{
		base._PhysicsProcess(delta);
		process_move(delta);
		process_draw_velocity();
	}



	#region 移动
	private Vector3 targetPos;
	[Export]
	private float speed = 5;
	public Action on_move_complete;
	private bool is_moving = false;

	public bool Is_moving => is_moving;

	public void move_to(Vector3 pos)
	{
		targetPos = pos;
		nav_agent.TargetPosition = pos;
		is_moving = true;

		anim_tree.set_condition("slow_run", true);
		anim_tree.set_condition("idle", false);
	}

	private void process_move(double delta)
	{
		if (is_moving)
		{
			if (nav_agent.IsNavigationFinished())
			{
				stop_move();
				// anim_player.Play("human/idle");
				on_move_complete?.Invoke();
				return;
			}

			var next_pos = nav_agent.GetNextPathPosition();
			var direction = (next_pos - root.Position).Normalized();
			// root.Position += direction * (float)(speed * delta);
			root.Velocity = direction * speed;

			// 调整朝向，todo:平滑地
			root.LookAt(next_pos, Vector3.Up, true);
			var rotation = root.Rotation;
			rotation.X = 0;
			root.Rotation = rotation;

			root.MoveAndSlide();
		}
	}

	public void stop_move()
	{
		is_moving = false;
		anim_tree.set_condition("slow_run", false);
		anim_tree.set_condition("idle", true);
	}


	// 导航
	public void connect_nav_agent()
	{
		nav_agent.VelocityComputed += (velocity) =>
		{
			GD.Print($"速度：{velocity}");
			DebugDraw.Arrow(root.Position, velocity, color: new Color(1, 0, 0));
			root.Velocity += velocity * speed;
		};
	}

	private void process_draw_velocity()
    {
        DebugDraw.Arrow(root.Position, root.Velocity);
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
	[Export]
	public AnimationPlayer anim_player;
	[Export]
	public AnimationTree anim_tree;

	private void init_anim_player()
	{
		if (anim_player == null)
		{
			anim_player = model_root.get_child<AnimationPlayer>();
			// anim_player.Play("human/idle");
		}

		if (anim_tree == null)
		{
			anim_tree = model_root.get_child<AnimationTree>();
		}
	}
	#endregion
}
