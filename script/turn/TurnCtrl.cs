using System.Collections.Generic;
using Godot;

/// <summary>
/// 回合制控制器
/// </summary>
public partial class TurnCtrl : Node
{
    public List<Turn> turns;

    public Turn cur_turn;

    /// <summary>
    /// 结束当前回合
    /// </summary>
    public void end_turn()
    {
        if(cur_turn != null)
        {
            
        }
    }

    /// <summary>
    /// 初始化回合制
    /// </summary>
    /// <param name="participants">初始参与者</param>
    public void init(List<Character> init_participants)
    {
        
    }

    /// <summary>
    /// 添加一个参与者。战斗中可能会动态增加参与者。
    /// </summary>
    /// <param name="new_participant"></param>
    public void add(Character new_participant)
    {
        
    }

    /// <summary>
    /// 移除一个参与者。例如该角色死亡时，会从回合制中移除。
    /// </summary>
    /// <param name="participant"></param>
    public void remove(Character participant)
    {
        
    }
}