using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_HeadLight : MonoBehaviour
{
    private enum E_LIGHT_VEL
    {
        FORWARD,
        BACK,
        RIGHT,
        LEFT,
    }

    [SerializeField] private ShadowMain shadowMain;

    [SerializeField] private E_LIGHT_VEL lightVel = E_LIGHT_VEL.FORWARD;
    private float[] velRotate = new float[4] { 0, 180, -90, 90 };

    [SerializeField] private float illumDis = 5.0f;
    [SerializeField] private float illumRange = 2.0f;
    [SerializeField] private GameObject lightObj;
    [SerializeField] private RenderTexture lightTexture;
    private GameObject light;
    private Transform lightTrans;
    private LightSourse lightSourse;

    [SerializeField] private GameObject[] lightPointObj;
    private ShadowHitChecker[] lightPoint;

    private Animator anim;

    // Start is called before the first frame update
    void Start()
    {
        shadowMain = GetComponent<ShadowMain>();
        anim = GetComponent<Animator>();


        light = Instantiate(lightObj, transform.position, transform.rotation);
        lightTrans = light.transform;
        lightTrans.position = transform.position;

        lightTrans.parent = transform;

        Camera lightCamera =  light.transform.GetChild(1).gameObject.GetComponent<Camera>();
        lightCamera.targetTexture = lightTexture;

        lightSourse = light.GetComponent<LightSourse>();
        Quaternion lightRot = lightTrans.rotation;
        float rotAngle = (180 + velRotate[(int)lightVel]);
        lightRot *= Quaternion.AngleAxis(rotAngle,Vector3.up);
        lightTrans.rotation = lightRot;
        lightSourse.SetDis(illumDis);
        lightSourse.SetRange(illumRange);
        lightSourse.SetMoveable(true);

        lightPointObj = GameObject.FindGameObjectsWithTag("LightOn");
        lightPoint = new ShadowHitChecker[lightPointObj.Length];
        for (int i = 0; i < lightPointObj.Length; i++)
        {
            lightPoint[i] = lightPointObj[i].GetComponent<ShadowHitChecker>();
        }
    }

    // Update is called once per frame
    void Update()
    {
        //for(int i= 0;i<lightPoint.Length;i++)
        //{
        //    if(lightPoint[i].CheckHitTrans(shadowMain.GetShadowManager().transform))
        //    {
        //        light.SetActive(true);
        //        return;
        //    }
        //}
        //light.SetActive(false);
        if(light.activeSelf!=shadowMain.GetLightOn())
        {
            light.SetActive(shadowMain.GetLightOn());
            anim.SetBool("lightOn",shadowMain.GetLightOn());
        }
    }
}
