using Godot;
using System;
using System.Collections.Generic;

namespace ui;

/// <summary>
/// 背包面板
/// </summary>
public partial class BagPanel : Control
{
	/*
 	点击物品，拿起物品，读取格子占用数据，放下物品，修改数据
	*/

	[Export]
	private Vector2I col_row = new(10, 5);
	[Export]
	public PackedScene scene_slot;
	[Export]
	public GridContainer grid_container;
	[Export]
	public Control panel;
	public List<List<Control>> slots = new();
	[Export]
	public PackedScene scene_item;

	/// <summary>
	/// 当前正在处理的背包
	/// </summary>
	private Bag bag;

	public Vector2 SlotSize => slots[0][0].Size;

	public Vector2I ColRow
	{
		get => col_row;
		set
		{
			col_row = value;
			refresh_grid();
		}
	}

	private void refresh_grid()
	{
		if (grid_container == null || scene_slot == null)
			return;

		// 1. 更新 GridContainer 设置
		grid_container.Columns = col_row.X;

		// 2. 清理旧格子
		slots.Clear();
		var children = grid_container.GetChildren();
		foreach (var child in children)
		{
			child.QueueFree();
		}

		// 3. 实例化新格子
		var total_count = col_row.X * col_row.Y;
		for (var i = 0; i < total_count; ++i)
		{
			var slot = scene_slot.Instantiate();
			grid_container.AddChild(slot);
		}

		// 4. 刷新内部数据
		collect_slots();
	}


	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		refresh_grid();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	private void collect_slots()
	{
		var children = grid_container.GetChildren();
		for (var col = 0; col < col_row.X; col++)
		{
			var col_list = new List<Control>();
			for (var row = 0; row < col_row.Y; row++)
			{
				var index = row * col_row.X + col;
				col_list.Add(children[index] as Control); // todo：index越界
			}
			slots.Add(col_list);
		}
	}

	/// <summary>
	/// 根据背包内容来布局
	/// </summary>
	/// <param name="bag"></param>
	public void set_bag(Bag bag)
	{
		this.bag = bag;

		CallDeferred(nameof(_arrange));
		// 这里要延迟一帧执行，是因为bag_panel_unit本身在第一帧还没有被grid_container布局，而改变大小。
		// 物品ui大小由bag_panel_unit决定。
	}

	private void _arrange()
	{
		if (bag != null)
		{
			var item_adapters = bag.item_adapters;
			for (var i = 0; i < item_adapters.Count; ++i)
			{
				var ui_item = scene_item.Instantiate() as ui.Item;
				var item_adpater = item_adapters[i];
				set_item(ui_item, item_adpater);
			}
		}

	}

	public void set_item(ui.Item ui_item, bag.ItemAdapter item_adpater)
	{
		// 调整大小
		ui_item.Size = new Vector2(SlotSize.X * item_adpater.item.volumn.X, SlotSize.Y * item_adpater.item.volumn.Y);
		// 放置位置，相对panel
		var pos = new Vector2(item_adpater.coord.X * SlotSize.X, item_adpater.coord.Y * SlotSize.Y);
		ui_item.GetParent()?.RemoveChild(ui_item); // 必须先从Parent移除才能AddChild
		panel.AddChild(ui_item);
		ui_item.Position = pos;

		// 图片
		ui_item.texture_rect.Texture = item_adpater.item.texture;

		ui_item.item_adapter = item_adpater;
		ui_item.btn.Visible = true;
	}

	public void print_slots_name()
	{
		foreach (var each in grid_container.GetChildren())
		{
			GD.Print(each.Name);
		}
	}
}
