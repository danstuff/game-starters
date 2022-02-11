using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class Shooter : MonoBehaviour
{
    public int MagSize = 10;
    public int MagsLeft = 10;
    public int Ammo = 0;
    public int FireState = 0; 

    public Vector3 OnVector = new Vector3(5.0f, 1.0f, 0.0f);
    public Vector3 OffVector = new Vector3(0.1f, 0.0f, 0.0f);

    // Start is called before the first frame update
    void Start()
    {
        Ammo = MagSize;   
        UpdateFireState(Vector3.zero);
    }

    void FireGun(GameObject gun) {
        var pc = gun.GetComponent(typeof(ParticleSystem))
            as ParticleSystem;
        pc.Play();
    }

    void UpdateFireState(Vector3 aimPos, bool shoot = false) {
        var tL = GameObject.FindWithTag("AimTargetL");
        var tR = GameObject.FindWithTag("AimTargetR");
        var gL = GameObject.FindWithTag("GunL");
        var gR = GameObject.FindWithTag("GunR");

        var pfL = tL.GetComponent(typeof(RestPosition))
            as RestPosition;
        var pfR = tR.GetComponent(typeof(RestPosition))
            as RestPosition;

        for(var i = 0; i < 2; i++) {
            switch(FireState) {
                case 0: // Left on
                    pfL.Offset = OnVector;
                    pfR.Offset = OffVector;

                    if(aimPos != Vector3.zero) {
                        tL.transform.position = aimPos;
                    }

                    if(shoot) {
                        FireGun(gL);
                    }
                    break;
                    
                case 1: // Right on
                    pfL.Offset = OffVector;
                    pfR.Offset = OnVector;

                    if(aimPos != Vector3.zero) {
                        tR.transform.position = aimPos;
                    }

                    if(shoot) {
                        FireGun(gR);
                    }
                    break;

                case 2: // Left and Right on
                    pfL.Offset = OnVector;
                    pfR.Offset = OnVector;

                    if(aimPos != Vector3.zero) {
                        tL.transform.position = aimPos;
                        tR.transform.position = aimPos;
                    }

                    if(shoot) {
                        FireGun(gL);
                        FireGun(gR);
                    }
                    break;
            }
        }
    }

    public void Switch() {
        FireState++;
        if(FireState > 2) {
            FireState = 0; 
        }

        UpdateFireState(Vector3.zero);
    }

    public void Aim(Vector2 pointerPos)
    {
        if(EventSystem.current.IsPointerOverGameObject()) return;

        var targetPos = Camera.main.ScreenToWorldPoint(new Vector3(
            pointerPos.x, pointerPos.y,
            -Camera.main.transform.position.z));

        var basePos = GameObject.Find(
            "Skeleton/Hips/Spine/Chest/UpperChest/Left_Shoulder")
            .transform.position;

        var aimPos = basePos +
            (targetPos - basePos).normalized * 2.0f;

        UpdateFireState(new Vector3(aimPos.x, aimPos.y, 0.0f));
    }

    public void Shoot()
    {
        if(EventSystem.current.IsPointerOverGameObject()) return;

        UpdateFireState(Vector3.zero, true);
    }
}
