using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FuseConditioner : MonoBehaviour
{
    private ShadowHitChecker hitChecker;


    private Transform[] hitShadows;
    private ShadowCollider[] shadowColliders;

    private PlayerShadowMode shadowMode;
    private MeshRenderer mesh;


    public bool active = true;

    private bool checkSetting = false;
    private bool checkChange = false;

    private bool hitPlayer;

    void Start()
    {
        hitChecker = GetComponent<ShadowHitChecker>();
        GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
        shadowMode = objs[objs.Length-1].GetComponent<PlayerShadowMode>();
        mesh = GetComponent<MeshRenderer>();
        
    }

    void Update()
    {
        if (!shadowMode.goFire)
        {
            checkChange = false;
            checkSetting = false; 
        }

        if (shadowMode.goFire&&!checkSetting)
        {
            if(hitPlayer)
            {
                checkSetting = true;
                checkChange = true;
                active = !active;
                return;
            }
            if(hitChecker.CountHit() > 0)
            {
                checkSetting = true;
                hitShadows = hitChecker.GetAllHitShadows();
                shadowColliders = new ShadowCollider[hitShadows.Length];
                for (int i = 0; i < hitShadows.Length; i++)
                {
                    shadowColliders[i] = hitShadows[i].GetComponent<ShadowCollider>();
                }
            }
        }
        if(checkSetting&&!checkChange)
        {
            for(int i = 0;i<shadowColliders.Length;i++)
            {
                if(shadowColliders[i].GetPassFire())
                {
                    checkChange = true;
                    active = !active;
                }
            }
        }
        //if (active) { mesh.material.color = Color.blue; }
        //else { mesh.material.color = Color.red; }
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.CompareTag("Player"))
        {
            hitPlayer = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            hitPlayer = false;
        }
    }
}
