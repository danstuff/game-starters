using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Respawner : MonoBehaviour
{
    public float KillHeight = -10;
    public Vector3 RespawnPos;

    // Update is called once per frame
    void LateUpdate()
    {
       if(transform.position.y < KillHeight) {
            transform.position = RespawnPos;
       }
    }
}
