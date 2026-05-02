using Godot;
using System;
using ui;

public partial class GameCtrl : SingletonNode<GameCtrl>
{

	[Export]
	public GameModel model;
	public GameView view;

	[Export]
	public BagCtrl bag_ctrl;

	[Export]
	public Agent agent;


	public override void _Ready()
	{
		base._Ready();
		agent.Init();
	}

	public override void _Process(double delta)
	{
		base._Process(delta);
	}


}
