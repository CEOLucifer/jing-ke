using Godot;
using System;
using ui;

public partial class GameCtrl : SingletonNode<GameCtrl>
{

	[Export]
	public GameModel model;
	[Export]
	public GameView view;
	[Export]
	public BagCtrl bag_ctrl;
	[Export]
	public Agent agent;
	[Export]
	public CommandQueue command_queue;


	public override void _Ready()
	{
		base._Ready();

		view.ctrl_panel.set_character(model.character);
	}

	public override void _Process(double delta)
	{
		base._Process(delta);
	}

	public Context get_context()
    {
		// todo
        return new Context();
    }
}