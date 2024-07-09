using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Player_test : MonoBehaviour
{
    ControlManager ControlManager;

    [SerializeField,PersistentAmongPlayMode]
    private float speed = 0.5f;

    

    //[PersistentAmongPlayMode,SerializeField]
    private Vector3 position;

    [PersistentAmongPlayMode]
    public Vector3 rotation;


    //[PersistentAmongPlayMode]
    
    public float test;
    // Start is called before the first frame update
    void Start()
    { 
        ControlManager = GetComponent<ControlManager>();
        position = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        Vector2 input = ControlManager.GetStickValue(ControlManager.E_DIRECTION.LEFT);

        position = new Vector3(input.x , 0  , input.y);

        transform.position += position*speed* Time.deltaTime;


        
    }
}
