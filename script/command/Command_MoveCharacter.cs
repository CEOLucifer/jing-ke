using Godot;

public class Command_MoveCharacter : Command
{
    public Character character;
    public Vector3 targetPos;

    public override void Do(Context context)
    {
        if (character != null)
        {
            character.MoveTo(targetPos);
        }
    }
}