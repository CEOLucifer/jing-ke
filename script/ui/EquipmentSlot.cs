using Godot;
using System;

namespace ui;

/// <summary>
/// 装备槽控件
/// </summary>
public partial class EquipmentSlot : Control
{
	[Export]
	public Button btn;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
    {
        base._Ready();
		btn.Pressed += () =>
        {
			BagCtrl.Instance?.put_equipment_slot();
        };
    }

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
