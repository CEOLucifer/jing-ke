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
		process_mouse();
	}

	private void process_mouse()
	{
		if (Input.IsActionJustPressed("left_click"))
		{
			var control = GetViewport().GuiGetHoveredControl();
			if (control == null)
			{
				// 进行鼠标射线检测
				var res = GameView.Instance.get_mouse_raycast_result();
				if (res.has_value)
				{
					var node = res.collider.AsGodotObject() as Node;

					if (node.Name == "Terrain3D")
					{
						// 执行移动玩家命令
						var command = new command.MoveCharacter();
						command.character = character;
						command.target_pos = res.hit_position;
						GameCtrl.Instance.command_queue.Push(command);
					}

					// 检测到的是Physics body
					var physics_body = node as PhysicsBody3D;
					if (physics_body != null)
					{
						// character.move_to(hit_position);
						// 执行移动玩家命令
						var command = new command.MoveCharacter();
						command.character = character;
						command.target_pos = res.hit_position;
						GameCtrl.Instance.command_queue.Push(command);

						// 检测到的是角色
						var character_body = physics_body as CharacterBody3D;
						if (character_body != null)
						{
							// 进入对话
							var command_chat = new command.Chat();
							command_chat.I = character;
							command_chat.you = character_body.get_child<Character>();
							GameCtrl.Instance.command_queue.Push(command_chat);
						}
					}


				}
			}

		}



		if (Input.IsActionJustPressed("right_click"))
		{
			var control = GetViewport().GuiGetHoveredControl();
			if (control == null)
			{

				// 测试：向前跳跃
				var com = new command.Jump();
				com.character = character;
				var pos = character.GetParent<Node3D>().Position;
				pos += character.GetParent<Node3D>().Transform.Basis.Z.Normalized() * 4;
				com.target_pos = pos;
				GameCtrl.Instance.command_queue.Push(com);
			}
		}
	}

}
