using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class VFX_GrabShadow : MonoBehaviour
{
    private VisualEffect effect;
    private GameObject player;
    private ShadowMain shadowMain;
    bool setting = false;
    // Start is called before the first frame update
    void Start()
    {
        effect = GetComponent<VisualEffect>();
        GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
        player = objs[objs.Length - 1].transform.GetChild(4).gameObject;
        shadowMain = transform.parent.parent.GetChild(0).GetComponent<ShadowMain>();
    }

    // Update is called once per frame
    void Update()
    {
        effect.SetBool("GrabFlg", shadowMain.GetExtendFg());
        if (shadowMain.GetExtendFg())
        {
            Vector3 playerPos = player.transform.position;
            playerPos.y -= player.transform.lossyScale.y / 2;
            if (!setting)
            {
                effect.SetVector3("startPos", shadowMain.transform.position);
                //Vector3 
                effect.SetVector3("startPos2", playerPos);
                effect.Play();
                setting = true;
            }
            effect.SetVector3("PlayerPosition", playerPos);
        }
        else
        {
            setting = false;
        }
    }
}
