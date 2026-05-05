using System;
using System.ClientModel;
using System.Threading.Tasks;
using Godot;
using OpenAI;
using OpenAI.Chat;

/// <summary>
/// LLM通信层
/// </summary>
public partial class Agent : Node
{
    private ChatClient client;
    private bool isBusy = false;
    private Task<ClientResult<ChatCompletion>> task;
    private Action<string> callback;

    public void Init()
    {
        client = new ChatClient(
            model: "opencode/big-pickle", // Zen 模型 ID（根据系统提示的精确 ID）
            credential: new ApiKeyCredential(
                System.Environment.GetEnvironmentVariable("ZEN_API_KEY") // 替换为你的 Zen API Key 环境变量名
            ),
            options: new OpenAIClientOptions()
            {
                Endpoint = new Uri("https://opencode.ai/zen/v1/chat/completions") // 替换为 Zen 的 OpenAI 兼容端点
            }
        );
    }

    public void Send(string str, Action<string> callback = null)
    {
        if (isBusy)
        {
            return;
        }
        task = client.CompleteChatAsync(str);
        isBusy = true;
        this.callback = callback;
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
        if (isBusy)
        {
            if (task.IsCompleted)
            {
                var res = task.Result.Value.Content[0].Text;
                callback?.Invoke(res);
                isBusy = false;
            }
        }
    }
}