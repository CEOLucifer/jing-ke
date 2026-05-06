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
		client = new(
			model: "qwen-plus",
			credential: new ApiKeyCredential(System.Environment.GetEnvironmentVariable("BAILIAN_API_KEY")),
			options: new OpenAIClientOptions()
			{
				Endpoint = new Uri("https://dashscope.aliyuncs.com/compatible-mode/v1")
			});

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
