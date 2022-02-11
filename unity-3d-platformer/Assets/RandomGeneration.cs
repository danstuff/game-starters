using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomGeneration : MonoBehaviour
{
    public static float MoveRate = 50;

    public static float HiddenY = -50;
    public static float HideDistance = 80;
    public static float NextDistance = 8;

    public bool Active = false;
    public Vector3 TargetPosition = new Vector3(0.0f, HiddenY, 0.0f);

    public GameObject NextBlock;
    
    void Hide() {
        if(!Active) return;

        Active = false;
        TargetPosition = new Vector3(transform.position.x, HiddenY, 0);
    }

    void Show(float x, float y) {
        if(Active) return;

        Active = true;
        transform.position = new Vector3(x, HiddenY, 0);
        TargetPosition = new Vector3(x, y, 0);

        //set player respawn point
        var PlayerRsp = GameObject.FindWithTag("Player")
            .GetComponent(typeof(Respawner)) as Respawner;

        PlayerRsp.RespawnPos = 
            new Vector3(x, y, 0);
    }

    // Update is called once per frame
    void Update()
    {
        if(Active) {
            //find the player position, and start/end points
            var Player = GameObject.FindWithTag("Player");
            var PlayerPos = Player.transform.position;
            var EndPoint = transform.Find("EndPoint").position;

            if(EndPoint.x - PlayerPos.x < NextDistance) {
                
                //activate the next level block
                if(NextBlock != null) {
                    var nc = NextBlock
                        .GetComponent(typeof(RandomGeneration))
                        as RandomGeneration;

                    nc.Show(EndPoint.x, EndPoint.y);

                    Active = false;
                }
            }
        }

        //move towards TargetPosition
    	if(Vector3.Distance(transform.position, TargetPosition) < 0.001f) {
    	    transform.position = TargetPosition;
        } else {
            transform.position = 
                Vector3.MoveTowards(transform.position,
                        TargetPosition, MoveRate * Time.deltaTime);
        }
    }
}
