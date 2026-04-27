public interface ICommand
{
    public bool IsDone
    {
        get;
    }

    public void Do(Context context);

    public void Done();

}