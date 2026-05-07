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
			var position = root.Position;
			position.Y = Mathf.Lerp(position.Y, GetDemoGroundHeight(position), 12f * (float)delta);
			root.Position = position;

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

	private float GetDemoGroundHeight(Vector3 position)
	{
		var palaceFrontHeight = GetSteppedHeight(
			position,
			new Vector2(-8.4f, 16.4f),
			new Vector2(5.6f, 20.1f),
			new float[] { 6.31f, 7.03f, 7.75f, 8.47f, 9.19f },
			new float[] { 0.0f, 0.24f, 0.48f, 0.72f, 0.96f, 1.2f }
		);
		if (palaceFrontHeight >= 0)
		{
			return palaceFrontHeight;
		}

		var rearPalaceHeight = GetSteppedHeight(
			position,
			new Vector2(-13.0f, 21.0f),
			new Vector2(14.0f, 21.5f),
			new float[] { 14.0f },
			new float[] { 1.2f, 1.2f }
		);
		if (rearPalaceHeight >= 0)
		{
			return rearPalaceHeight;
		}

		return 0.0f;
	}

	private float GetSteppedHeight(Vector3 position, Vector2 xRange, Vector2 zRange, float[] zThresholds, float[] heights)
	{
		if (position.X < xRange.X || position.X > xRange.Y || position.Z < zRange.X || position.Z > zRange.Y)
		{
			return -1.0f;
		}

		for (var i = 0; i < zThresholds.Length; i++)
		{
			if (position.Z < zThresholds[i])
			{
				return heights[i];
			}
		}

		return heights[^1];
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
