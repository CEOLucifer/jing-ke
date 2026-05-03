namespace skill;

public partial class Move : Skill
{
    public override void use(Character character)
    {
        base.use(character);
        // 选择地点
        var select_pos = new command.SelectPos();
        select_pos.callback += (pos) =>
        {
            // 移动玩家
            var command_move = new command.MoveCharacter();
            command_move.character = character;
            command_move.target_pos = pos;
            GameCtrl.Instance.command_queue.Push(command_move);
        };
        GameCtrl.Instance.command_queue.Push(select_pos);

    }
}