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

		init_move();
	}



	public override void _PhysicsProcess(double delta)
	{
		base._PhysicsProcess(delta);
		process_move(delta);
		process_draw_velocity();
	}



	#region 移动
	private Vector3 target_pos;
	[ExportGroup("移动速率")]
	[Export]
	public float walk_speed = 3;
	[Export]
	public float slow_run_speed = 6;
	[Export]
	public float run_speed = 10;
	private float cur_speed = 0;
	public Action on_move_complete;
	private bool is_moving = false;

	public enum EMoveType
	{
		Walk,
		SlowRun,
		Run,
	}

	private EMoveType move_type;
	[Export]
	public float accelerate = 3;
	public Vector3 target_dir;
	[Export]
	public float rotate_speed = 5;

	public bool Is_moving => is_moving;
	[Export]
	public float CurSpeed
	{
		get => cur_speed;
		set { }
	}


	/// <summary>
	/// 初始化移动相关
	/// </summary>
	private void init_move()
	{
		// 获取路线长度
		// 根据路径长度设置动画混合空间参数
		nav_agent.PathChanged += () =>
		{
			var path_length = nav_agent.GetPathLength();
			if (0 <= path_length && path_length < 3)
			{
				move_type = EMoveType.Walk;
			}
			else if (3 <= path_length && path_length < 10)
			{
				move_type = EMoveType.SlowRun;
			}
			else
			{
				move_type = EMoveType.Run;
			}
		};

		target_dir = root.Transform.Basis.Z;
	}

	public void move_to(Vector3 pos)
	{
		is_moving = true;

		target_pos = pos;

		nav_agent.TargetPosition = pos;
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



			// 增速
			cur_speed += accelerate * (float)delta;
			// 钳制速率，根据移动类型
			if (move_type == EMoveType.Walk)
			{
				cur_speed = Math.Clamp(cur_speed, 0, walk_speed);
			}
			else if (move_type == EMoveType.SlowRun)
			{
				cur_speed = Math.Clamp(cur_speed, 0, slow_run_speed);
			}
			else if (move_type == EMoveType.Run)
			{
				cur_speed = Math.Clamp(cur_speed, 0, run_speed);
			}




			// 位移
			var next_pos = nav_agent.GetNextPathPosition();
			var direction = (next_pos - root.Position).Normalized();
			// root.Position += direction * (float)(speed * delta);
			root.Velocity = direction * cur_speed;
			root.MoveAndSlide();

			target_dir = next_pos - root.Position;
		}
		else
		{
			// 逐渐降速
			cur_speed = Math.Clamp(cur_speed - 24 * (float)delta, 0, run_speed);
		}

		// 动画
		anim_tree.set_param(BLEND_POSITION, cur_speed / run_speed);

		// 调整朝向，平滑地
		var cur_dir = root.Transform.Basis.Z;
		var dir = cur_dir.Lerp(target_dir, rotate_speed * (float)delta);
		root.LookAt(root.Position + dir, Vector3.Up, true);
		// X旋转量置0
		var rotation = root.Rotation;
		rotation.X = 0;
		root.Rotation = rotation;
	}

	public void stop_move()
	{
		is_moving = false;
	}


	// 导航
	public void connect_nav_agent()
	{
		nav_agent.VelocityComputed += (velocity) =>
		{
			GD.Print($"速度：{velocity}");
			DebugDraw.Arrow(root.Position, velocity, color: new Color(1, 0, 0));
			root.Velocity += velocity * walk_speed;
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
	[ExportGroup("")]
	[Export]
	public AnimationPlayer anim_player;
	[Export]
	public AnimationTree anim_tree;
	public const string BLEND_POSITION = "BlendSpace1D/blend_position";

	private void init_anim_player()
	{
		if (anim_player == null)
		{
			anim_player = model_root.get_child<AnimationPlayer>();
		}

		if (anim_tree == null)
		{
			anim_tree = model_root.get_child<AnimationTree>();
			anim_tree.set_param(BLEND_POSITION, 0f);
		}
	}
	#endregion
}
