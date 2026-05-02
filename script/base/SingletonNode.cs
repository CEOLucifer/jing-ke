using Godot;

/// <summary>
/// 单例节点基类
/// </summary>
/// <typeparam name="T"></typeparam>
public partial class SingletonNode<T> : Node
where T : SingletonNode<T>
{
    private static T instance;
    public static T Instance => instance;

    public override void _Ready()
    {
        base._Ready();
        instance = this as T;
    }
}