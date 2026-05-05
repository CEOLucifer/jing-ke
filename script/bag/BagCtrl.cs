using Godot;
using ui;

/// <summary>
/// 背包控制器
/// </summary>
[GlobalClass]
public partial class BagCtrl : SingletonNode<BagCtrl>
{
    /// <summary>
    /// 正在处理的背包
    /// </summary>
    public Bag bag;

    /// <summary>
    /// 背包面板
    /// </summary>
    [Export]
    public BagPanel bag_panel;

    /// <summary>
    /// 浮动的物品ui
    /// </summary>
    public ui.Item item_floating;

    [Export]
    public PackedScene scene_bag_panel;
    [Export]
    public CanvasLayer canvas_layer;


    public void on_item_pressed(ui.Item ui_item)
    {
        if (item_floating != null)
        {
            return;
        }

        // 跟随鼠标
        ui_item.GetParent().RemoveChild(ui_item);
        ui_item.is_follow_mouse = true;
        GameCtrl.Instance.model.canvas_layer.AddChild(ui_item);

        // 更改样式
        ui_item.btn.Visible = false;

        item_floating = ui_item;

        bag.remove(ui_item.item_adapter.item);
    }

    public void put_item()
    {
        if (bag_panel.grid_container.is_mouse_overlaped())
        {
            // 放背包
            put_inventory_slot();
        }
        else
        {
            // 放装备槽

        }

    }

    public Vector2I get_mouse_grid_coord()
    {
        Vector2I res;
        var mouse_pos = bag_panel.grid_container.GetLocalMousePosition();
        var slot_size = bag_panel.slots[0][0];
        res = new Vector2I((int)(mouse_pos.X / slot_size.Size.X),
                            (int)(mouse_pos.Y / slot_size.Size.Y));
        return res;
    }

    public void put_inventory_slot()
    {
        var mouse_grid_coord = get_mouse_grid_coord();
        GD.Print($"mouse_grid_coord: {mouse_grid_coord}");
        var success = bag.add(item_floating.item_adapter, mouse_grid_coord);
        if (success)
        {
            bag_panel.set_item(item_floating, item_floating.item_adapter);
            GD.Print("放置成功！");

            item_floating.is_follow_mouse = false;
            item_floating = null;


        }
        else
        {
            GD.Print("放置失败！");
        }
    }

    public void put_equipment_slot()
    {
        if (item_floating != null)
        {
            if (item_floating.item_adapter.item is Equipment)
            {

            }
        }
        else
        {
            GD.Print("不是装备");
        }
    }




    public override void _Process(double delta)
    {
        base._Process(delta);
        if (Input.IsActionJustPressed("m"))
        {


            if (bag == null && bag_panel == null)
            {
                bag = GameCtrl.Instance.model.character.bag;

                // 打开背包
                bag_panel = scene_bag_panel.Instantiate() as BagPanel;
                canvas_layer.AddChild(bag_panel);

                // 背包界面传入玩家背包数据
                bag_panel.set_bag(bag);
            }
            else
            {
                // 这里就是体现为什么要BagCtrl这个类，可以控制面板销毁
                bag_panel.QueueFree();
                bag_panel = null;

                bag = null;

                if (item_floating != null)
                {
                    item_floating.QueueFree();
                    item_floating = null;
                }
            }
        }

        // 测试
        if (Input.IsActionJustPressed("n"))
        {
            var item = ResourceLoader.Load("res://item/test.tres").Duplicate() as Item;
            GameCtrl.Instance.model.character.bag.add(item);
        }

    }



}