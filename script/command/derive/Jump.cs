using Godot;

namespace command;

public class Jump : Command
{
    public Character character;
    public Vector3 target_pos;

    public override void Do(Context context)
    {
        base.Do(context);
        character.anim_player.Play("human/jump");

        var bot = character.model_root as Bot;

        void on_jump_up()
        {
            // 跳起的那一刻，开始移动角色，做抛物线运动轨迹(todo)
            var tween = character.CreateTween();
            tween.TweenProperty(character.GetParent(), "position", target_pos, 1);
            tween.TweenCallback(Callable.From(() =>
            {
                bot.on_jump_up -= on_jump_up;
                Done();
            }));

        }

        bot.on_jump_up += on_jump_up;
    }

    public override void Done_complete()
    {
        base.Done_complete();
        GD.Print("命令完成: jump");
        character.anim_player.Play("human/idle");
    }

}