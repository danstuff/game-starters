using UnityEngine;

namespace StarterAssets
{
    public class UICanvasControllerInput : MonoBehaviour
    {

        [Header("Output")]
        public StarterAssetsInputs starterAssetsInputs;

        public void VirtualMoveInput(Vector2 virtualMoveDirection)
        {
            starterAssetsInputs.MoveInput(virtualMoveDirection);
        }

        public void VirtualAimInput(Vector2 virtualAimPos)
        {
            starterAssetsInputs.AimInput(virtualAimPos);
        }

        public void VirtualJumpInput(bool virtualJumpState)
        {
            starterAssetsInputs.JumpInput(virtualJumpState);
        }
        
        public void VirtualShootInput(bool virtualShootState)
        {
            starterAssetsInputs.ShootInput(virtualShootState);
        }

        public void VirtualSwitchInput(bool virtualSwitchState)
        {
            starterAssetsInputs.SwitchInput(virtualSwitchState);
        }
    }

}
