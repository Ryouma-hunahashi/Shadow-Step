using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class VFX_NormalShadow : MonoBehaviour
{
    private VisualEffect effect;
    private ShadowMain shadowMain;
    // Start is called before the first frame update
    void Start()
    {
        effect = GetComponent<VisualEffect>();
        shadowMain = transform.parent.parent.parent.GetChild(0).GetComponent<ShadowMain>();
    }

    // Update is called once per frame
    void Update()
    {
        if (!shadowMain.GetExtendFg())
        {
            effect.SetFloat("length", shadowMain.GetShadow(transform.GetSiblingIndex()).shadowDis <= shadowMain.GetShadowManager().GetExtendAbleDis() ?
                shadowMain.GetShadow(transform.GetSiblingIndex()).shadowDis :
                shadowMain.GetShadow(transform.GetSiblingIndex()).shadowDis + 1.0f);
            effect.SetVector3("Direction",shadowMain.GetShadow(transform.GetSiblingIndex()).toLightVec);
            effect.SetFloat("grabLength", shadowMain.GetShadowManager().GetExtendAbleDis()-0.3f);
            effect.SetBool("Flg", shadowMain.GetFront(transform.GetSiblingIndex()));
        }
        else
        {
            effect.SetFloat("length", 0);
        }
    }
}
