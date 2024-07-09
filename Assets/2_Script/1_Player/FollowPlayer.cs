using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FollowPlayer : MonoBehaviour
{
    Transform playerTrans;
    Rigidbody rb;
    // Start is called before the first frame update
    void Start()
    {
        GameObject[] objs= GameObject.FindGameObjectsWithTag("Player");
        playerTrans = objs[objs.Length-1].transform;
        rb = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        Vector3 vel = playerTrans.position - transform.position;
        vel.y = 0;
        //vel.Normalize();
        vel *= 30;
        rb.velocity = vel;
    }
}
