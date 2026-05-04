using Godot;
using System;
using System.Collections.Generic;

/// <summary>
/// 背包
/// </summary>
public class Bag
{
	/// <summary>
	/// 列数-行数
	/// </summary>
	public Vector2I col_row = new(10, 5);
	public List<ItemAdapter> item_adapters = new();
	public List<List<Slot>> slots;

	public Bag()
	{
		// slots
		slots = new();
		for (var col = 0; col < col_row.X; ++col)
		{
			var col_slot = new List<Slot>();
			for (var row = 0; row < col_row.Y; ++row)
			{
				col_slot.Add(new());
			}
			slots.Add(col_slot);
		}
	}

	public bool add(Item item)
	{
		if (Contains(item))
		{
			GD.Print("已存在该物品！");
			return false;
		}

		var coord = calculate_coord(item);
		if (coord.HasValue)
		{
			var adapter = new ItemAdapter();
			adapter.item = item;
			_add(adapter, coord.Value);
			return true;
		}
		else
		{
			GD.Print("背包空间不足");
			return false;
		}
	}

	public bool add(Item item, Vector2I coord)
	{
		if (Contains(item))
		{
			GD.Print("已存在该物品！");
			return false;
		}

		if (can_place(item, coord))
		{
			var adapter = new ItemAdapter();
			adapter.item = item;
			_add(adapter, coord);
			return true;
		}
		else
		{
			GD.Print("无法放置此处");
			return false;
		}
	}

	public bool add(ItemAdapter adapter, Vector2I coord)
	{
		if (Contains(adapter.item))
		{
			GD.Print("已存在该物品！");
			return false;
		}

		if (can_place(adapter.item, coord))
		{
			_add(adapter, coord);
			return true;
		}
		else
		{
			GD.Print("无法放置此处");
			return false;
		}

	}

	private void _add(ItemAdapter adapter, Vector2I coord)
	{
		var item = adapter.item;
		adapter.coord = coord;
		item_adapters.Add(adapter);

		// 设置slots，置is_occupied为true
		for (var col = coord.X; col < coord.X + item.volumn.X; ++col)
		{
			for (var row = coord.Y; row < coord.Y + item.volumn.Y; ++row)
			{
				var new_slot = new Slot();
				new_slot.is_occupied = true;
				slots[col][row] = new_slot;
			}
		}

		GD.Print($"添加物品：{adapter.item}");
	}

	public void remove(Item item)
	{
		foreach (var each in item_adapters)
		{
			if (each.item == item)
			{
				item_adapters.Remove(each);
				reset_slots(each);
				break;
			}
		}
	}


	/// <summary>
	/// 计算某物品在加入背包后的位置
	/// </summary>
	/// <param name="item"></param>
	/// <returns>如果没有位置可放置，为null</returns>
	private Vector2I? calculate_coord(Item item)
	{
		for (var col = 0; col < col_row.X; col++)
		{
			for (var row = 0; row < col_row.Y; row++)
			{
				if (can_place(item, new Vector2I(col, row)))
				{
					return new Vector2I(col, row);
				}
			}
		}
		return null;
	}

	public bool can_place(Item item, Vector2I coord)
	{
		if (coord.X + item.volumn.X > col_row.X || coord.Y + item.volumn.Y > col_row.Y)
		{
			return false;
		}

		for (var col = 0; col < item.volumn.X; col++)
		{
			for (var row = 0; row < item.volumn.Y; row++)
			{
				if (slots[coord.X + col][coord.Y + row].is_occupied)
				{
					return false;
				}
			}
		}
		return true;
	}

	public bool Contains(Item item)
	{
		return item_adapters.Find((adapter) => adapter.item == item) != null;
	}

	/// <summary>
	/// 移除adapter后，相应slot is_occupied置false
	/// </summary>
	/// <param name="adapter"></param>
	private void reset_slots(ItemAdapter adapter)
	{
		var coord = adapter.coord;
		var volumn = adapter.item.volumn;
		for (int i = coord.X; i < coord.X + volumn.X; ++i)
		{
			for (int j = coord.Y; j < coord.Y + volumn.Y; ++j)
			{
				var new_slot = new Slot();
				new_slot.is_occupied = false;
				slots[i][j] = new_slot;
			}
		}
	}


	/// <summary>
	/// 物品适配器。物品在背包中存在“坐标”。
	/// </summary>
	public class ItemAdapter
	{
		/// <summary>
		/// 物品
		/// </summary>
		public Item item;

		/// <summary>
		/// 物品坐标
		/// </summary>
		public Vector2I coord;
	}

	public struct Slot
	{
		public bool is_occupied = false;

		public Slot()
		{
		}
	}

}


