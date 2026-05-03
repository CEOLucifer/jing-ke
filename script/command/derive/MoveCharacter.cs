using System;
using Godot;

namespace command;

public class MoveCharacter : Command
{
    public Character character;
    public Vector3 target_pos;

    private Action callback;

    public override void Do(Context context)
    {
        if (character != null)
        {
            character.move_to(target_pos);
            callback = () =>
            {
                Done();
            };
            character.on_move_complete += callback;
        }
    }

    public override void Done_complete()
    {
        GD.Print("命令完成: MoveCharacter");
        character.on_move_complete -= callback;
        character.stop_move();
    }
}