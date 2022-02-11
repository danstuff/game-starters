using UnityEngine;
using UnityEngine.EventSystems;
#if ENABLE_INPUT_SYSTEM && STARTER_ASSETS_PACKAGES_CHECKED
using UnityEngine.InputSystem;
#endif

namespace StarterAssets
{
	public class StarterAssetsInputs : MonoBehaviour
	{
		[Header("Character Input Values")]
		public Vector2 move;
        public Vector2 aim;
		public bool jump;
		public bool shoot;
		public bool swtch;

#if ENABLE_INPUT_SYSTEM && STARTER_ASSETS_PACKAGES_CHECKED
		public void OnMove(InputValue value)
		{
			MoveInput(value.Get<Vector2>());
		}

        public void OnAim(InputValue value)
        {
            AimInput(value.Get<Vector2>());
        }

		public void OnJump(InputValue value)
		{
			JumpInput(value.isPressed);
		}

		public void OnShoot(InputValue value)
		{
			ShootInput(value.isPressed);
		}

		public void OnSwitch(InputValue value)
		{
			SwitchInput(value.isPressed);
		}
#else
	// old input sys if we do decide to have it (most likely wont)...
#endif

		public void MoveInput(Vector2 newMoveDirection)
		{
			move = newMoveDirection;
		} 

		public void AimInput(Vector2 newAimDirection)
		{
            //if(EventSystem.current.IsPointerOverGameObject()) return;
			aim = newAimDirection;
		} 

        public void ShootInput(bool newShootState)
        {
            //if(EventSystem.current.IsPointerOverGameObject()) return;
            shoot = newShootState;
        }

		public void JumpInput(bool newJumpState)
		{
			jump = newJumpState;
		}

		public void SwitchInput(bool newSwitchState)
		{
			swtch = newSwitchState;
		}
	}
	
}
