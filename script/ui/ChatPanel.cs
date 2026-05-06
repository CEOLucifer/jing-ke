using Godot;
using System;

public partial class ChatPanel : Control
{
	[Export] public TextEdit textEdit;
	[Export] public Button btnSend;

	[Export]
	public Agent agent;

	public override void _Ready()
	{
		base._Ready();
		btnSend.Pressed += () =>
		{
			var content = textEdit.Text;
			agent.Send(content, (res) =>
			{
				GD.Print(res);
			});
			textEdit.Clear();
		};
	}

}
