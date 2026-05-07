using Godot;
using System;

[GlobalClass]
public partial class CameraCtrl : SingletonNode<CameraCtrl>
{
	[Export]
	public Camera3D camera;

	[Export]
	public Node3D target;

	[Export]
	public float speed = 5;

	[Export]
	public Vector3 offset = new(5, 10, 5);

	[Export]
	public bool enableMouseOrbit = true;

	[Export]
	public float mouseSensitivity = 0.006f;

	[Export]
	public float minPitch = 0.25f;

	[Export]
	public float maxPitch = 1.25f;

	[Export]
	public float minDistance = 4.0f;

	[Export]
	public float maxDistance = 18.0f;

	[Export]
	public float zoomStep = 0.8f;

	[Export]
	public bool enableInteriorPerspective = false;

	[Export]
	public Vector3 interiorCenter = Vector3.Zero;

	[Export]
	public Vector3 interiorSize = new(8, 4, 6);

	[Export]
	public Vector3 interiorOffset = new(3.5f, 3.2f, 4.5f);

	[Export]
	public float defaultFov = 65f;

	[Export]
	public float interiorFov = 48f;

	[Export]
	public Godot.Collections.Array<Node3D> interiorOccluders = new();

	private bool orbitDragging = false;
	private bool orbitInitialized = false;
	private float orbitYaw = 0f;
	private float orbitPitch = 0.75f;
	private float orbitDistance = 10f;

	public override void _Ready()
	{
		base._Ready();
		if (camera == null)
		{
			camera = GetParent() as Camera3D;
		}
		if (interiorOccluders.Count == 0)
		{
			AddDefaultInteriorOccluder("YanCampSet/MainHall/HallRoof");
			AddDefaultInteriorOccluder("YanCampSet/MainHall/HallUpperRoof");
			AddDefaultInteriorOccluder("YanCampSet/MainHall/HallFrontEave");
			AddDefaultInteriorOccluder("YanCampSet/MainHall/HallBackEave");
			AddDefaultInteriorOccluder("YanCampSet/MainHall/HallLeftEave");
			AddDefaultInteriorOccluder("YanCampSet/MainHall/HallRightEave");
			AddDefaultInteriorOccluder("YanCampSet/MainHall/HallRidge");
		}
		InitializeOrbitFromOffset(offset);
	}

	public override void _Input(InputEvent @event)
	{
		if (!enableMouseOrbit)
		{
			return;
		}

		if (@event is InputEventMouseButton mouseButton)
		{
			if (mouseButton.ButtonIndex == MouseButton.Middle)
			{
				orbitDragging = mouseButton.Pressed;
				return;
			}

			if (mouseButton.Pressed && mouseButton.ButtonIndex == MouseButton.WheelUp)
			{
				orbitDistance = Mathf.Max(minDistance, orbitDistance - zoomStep);
				return;
			}

			if (mouseButton.Pressed && mouseButton.ButtonIndex == MouseButton.WheelDown)
			{
				orbitDistance = Mathf.Min(maxDistance, orbitDistance + zoomStep);
				return;
			}
		}

		if (@event is InputEventMouseMotion mouseMotion && orbitDragging)
		{
			orbitYaw -= mouseMotion.Relative.X * mouseSensitivity;
			orbitPitch = Mathf.Clamp(orbitPitch - mouseMotion.Relative.Y * mouseSensitivity, minPitch, maxPitch);
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		if (target == null || camera == null)
		{
			return;
		}

		var inInterior = enableInteriorPerspective && IsTargetInsideInterior();
		var activeOffset = GetActiveOffset(inInterior ? interiorOffset : offset);
		var activeFov = inInterior ? interiorFov : defaultFov;
		SetInteriorOccludersVisible(!inInterior);

		camera.LookAt(target.Position + new Vector3(0, inInterior ? 1.2f : 0, 0));
		camera.Position = camera.Position.Lerp(target.Position + activeOffset, speed * (float)delta);
		camera.Fov = Mathf.Lerp(camera.Fov, activeFov, speed * 0.65f * (float)delta);
	}

	private void InitializeOrbitFromOffset(Vector3 sourceOffset)
	{
		if (orbitInitialized)
		{
			return;
		}

		orbitDistance = Mathf.Clamp(sourceOffset.Length(), minDistance, maxDistance);
		if (orbitDistance > 0.01f)
		{
			orbitYaw = Mathf.Atan2(sourceOffset.X, sourceOffset.Z);
			orbitPitch = Mathf.Clamp(Mathf.Asin(sourceOffset.Y / orbitDistance), minPitch, maxPitch);
		}
		orbitInitialized = true;
	}

	private Vector3 GetActiveOffset(Vector3 fallbackOffset)
	{
		if (!enableMouseOrbit)
		{
			return fallbackOffset;
		}

		var horizontalDistance = Mathf.Cos(orbitPitch) * orbitDistance;
		return new Vector3(
			Mathf.Sin(orbitYaw) * horizontalDistance,
			Mathf.Sin(orbitPitch) * orbitDistance,
			Mathf.Cos(orbitYaw) * horizontalDistance
		);
	}

	private bool IsTargetInsideInterior()
	{
		var pos = target.Position;
		var half = interiorSize * 0.5f;
		return Math.Abs(pos.X - interiorCenter.X) <= half.X
			&& Math.Abs(pos.Y - interiorCenter.Y) <= half.Y
			&& Math.Abs(pos.Z - interiorCenter.Z) <= half.Z;
	}

	private void SetInteriorOccludersVisible(bool visible)
	{
		foreach (var node in interiorOccluders)
		{
			if (node != null)
			{
				node.Visible = visible;
			}
		}
	}

	private void AddDefaultInteriorOccluder(string path)
	{
		var scene = GetTree().CurrentScene;
		var node = scene?.GetNodeOrNull<Node3D>(path);
		if (node != null)
		{
			interiorOccluders.Add(node);
		}
	}
}
