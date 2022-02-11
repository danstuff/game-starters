using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RestPosition : MonoBehaviour
{
    public float MoveRate = 5;
    public Vector3 Offset;

    // Update is called once per frame
    void Update()
    {
        var ppos = GameObject.FindWithTag("Player").transform.position;
        transform.position = 
            Vector3.MoveTowards(transform.position, ppos + Offset,
                MoveRate * Time.deltaTime);
    }
}
