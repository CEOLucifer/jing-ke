using Godot;
using System;

[GlobalClass]
public partial class Item : Resource
{
    [Export]
    public int id;
    [Export]
    public string name;
    [Export]
    public string description;
    [Export]
    public Vector2I volumn = new(1, 1);
    [Export]
    public Texture2D texture;
}
