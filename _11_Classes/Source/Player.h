#include "Leadwerks.h"

//using namespace Leadwerks;

class Player
{
public:
	Player();
	Player(Leadwerks::Window* window, Leadwerks::Context* context, Leadwerks::Camera* camera);
	void Update();

	Leadwerks::Window* window;
	Leadwerks::Context* context;
	Leadwerks::Camera* camera;

	Leadwerks::Vec3 camRotation;
	Leadwerks::Vec2 centerMouse;
	Leadwerks::Vec2 mouseDifference;
	float mouseSensitivity;

	//Player
	Leadwerks::Model* playerMesh;
	Leadwerks::Entity* player;

	//Speeds
	Leadwerks::Vec3 playerMovement;
	float moveSpeed;
	float strafeSpeed;

	//jump and crouch
	float jumpForce;
	float tempJumpForce;
	bool crouched;
	float playerHeight;
	float playerCrouchHeight;

	//angles
	float cameraTopAngle;
	float cameraBottomAngle;
	float camSmoothing;
};