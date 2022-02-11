using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Recoil : MonoBehaviour
{
    // Update is called once per frame
    void Update()
    {
        float z = transform.localRotation.z;
        transform.localRotation.Set(0.0f, 90.0f, z*0.75f, 1.0f);
    }

    public void Trigger() {
        transform.localRotation.Set(0.0f, 90.0f, 10.0f, 1.0f);
    }
}
