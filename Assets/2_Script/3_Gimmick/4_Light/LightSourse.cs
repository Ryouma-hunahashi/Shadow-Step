using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class LightSourse : MonoBehaviour
{
    [Header("照らす距離")]
    [SerializeField, Min(0)] private float dis = 6.0f;
    public void SetDis(float _dis) { dis = _dis; }
    [Header("照らす範囲")]
    [SerializeField, Range(-90, 90)] private float range = 2.0f;
    public void SetRange(float _range) { range = _range; }
    [Header("ライトの当たり判定オブジェクト")]
    [SerializeField] private GameObject lightObj;

    [SerializeField] private VisualEffect effect;
    [SerializeField] private Camera camera;

    [SerializeField] private bool moveable = false;
    public void SetMoveable(bool _fg) { moveable = _fg; }
    [SerializeField] private LayerMask mask = 1 << 8;
    [SerializeField] private float rayWidth = 1.6f;

    private GameObject lightLight;

    void Start()
    {
        Vector3 lightScale = Vector3.one;
        lightScale.x =range+0.1f/* range * Mathf.Cos((illumAngle / 2) * Mathf.Deg2Rad)*/;
        lightScale.y = 5f;
        lightScale.z = dis;


        // 子オブジェクトの生成はここで行う
        GameObject light = Instantiate(lightObj,
            new Vector3(transform.position.x, transform.position.y, transform.position.z - lightScale.z / 2),
            Quaternion.identity);
        lightLight = light;
        effect.transform.parent = null;
        effect.SetVector3("Scale", new Vector3(range/10, 2f, dis/10));
        effect.SetFloat("size", 1);
        effect.transform.position = light.transform.position;
        

        var parRotate = transform.rotation;
        transform.rotation = Quaternion.identity;
        
        
        effect.transform.rotation = Quaternion.identity;
        // 親の設定はここで行う
        light.transform.parent = transform;
        effect.transform.parent = transform;


        transform.rotation *= parRotate;
       light.transform.localScale = lightScale;

        camera.farClipPlane = dis-Mathf.Abs(camera.transform.localPosition.z);
        camera.orthographicSize = range*0.5f+0.1f;

        //camera.depth = camera.depth + transform.GetSiblingIndex() * 0.1f;

        //StartCoroutine(SetCulling());
    }

    void Update()
    {
        if(!moveable)
        {
            return;
        }
        RaycastHit rRay;
        RaycastHit lRay;

        bool rHit = Physics.Raycast(transform.position+transform.right.normalized*1, -transform.forward, out rRay, dis,mask);
        bool lHit = Physics.Raycast(transform.position - transform.right.normalized * 1, -transform.forward, out lRay, mask);
#if UNITY_EDITOR
        Debug.DrawRay(transform.position + transform.right.normalized * rayWidth * 0.5f, -transform.forward * dis, Color.yellow, mask);
        Debug.DrawRay(transform.position - transform.right.normalized * rayWidth * 0.5f, -transform.forward * dis, Color.yellow, mask);
#endif
        float stencilTest = float.MaxValue;
        if(rHit&&stencilTest>rRay.distance)
        {
            //Debug.Log("右ヒット");
            stencilTest = rRay.distance;
        }
        if(lHit&&stencilTest>lRay.distance)
        {
            //Debug.Log("左ヒット");
            stencilTest=lRay.distance;
        }
        if(stencilTest>dis)
        {
            stencilTest = dis;
        }

        Vector3 lightScale =  lightLight.transform.localScale;
        lightScale.z = stencilTest;
        lightLight.transform.localScale = lightScale;

        Vector3 lightPos = lightLight.transform.position;
        lightPos = transform.position - transform.forward * stencilTest / 2;
        lightLight.transform.position = lightPos;

        camera.farClipPlane = stencilTest - Mathf.Abs(camera.transform.localPosition.z);
        // effect.SetVector3("Angle", new Vector3(80, 0, transform.rotation.y));
    }

    private IEnumerator SetCulling()
    {
        camera.useOcclusionCulling = true;

        yield return null;

        camera.useOcclusionCulling = false;
    }
}
