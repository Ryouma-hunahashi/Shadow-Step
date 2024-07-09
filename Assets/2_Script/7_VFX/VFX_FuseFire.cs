using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class VFX_FuseFire : MonoBehaviour
{
    [System.Serializable]
    public struct FIRE_LIST
    {
        public Transform mainTrans; // 大本のTransform
        public List<VisualEffect> effects; // エフェクトリスト
    }

    private enum E_FIRE_MODE
    { 
        OUT,    // 消失状態
        NORMAL, // 通常状態
        UP,     // 強化状態
    }


    // 発火装置の状態管理用(付いているか消えているか)
    private FuseConditioner fuseCon;
    // 影への連鎖を確認する用(強化状態かどうか)
    private PlayerShadowMode shadowMode;

    // 炎の状態
    E_FIRE_MODE fireMode = E_FIRE_MODE.NORMAL;

    [Header("通常炎のエフェクトリスト")]
    [SerializeField] private FIRE_LIST normalFire;
    [Header("強化炎のエフェクトリスト")]
    [SerializeField] private FIRE_LIST powerUpFire;
    [Header("ポイントライト")]
    [SerializeField] private GameObject light;

    // 消えるかどうか
    private bool dieable = false;




    // Start is called before the first frame update
    void Start()
    {
        // 状態管理スクリプト取得
        fuseCon = transform.parent.GetComponent<FuseConditioner>();
        // この炎が消えるかどうかを判断。
        dieable = fuseCon != null;
        // 影への連鎖管理スクリプト取得
        GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
        shadowMode = objs[objs.Length-1].GetComponent<PlayerShadowMode>();

        // このオブジェクトの炎エフェクトを取得
        Transform normalPar = transform.GetChild(1);
        normalPar.gameObject.SetActive(false);
        normalFire.mainTrans = normalPar;
        SetFireEffect(normalPar, normalFire.effects);

        // このオブジェクトの強化炎エフェクトを取得
        Transform powerPar = transform.GetChild(2);
        powerPar.gameObject.SetActive(false);
        powerUpFire.mainTrans = powerPar;
        SetFireEffect(powerPar, powerUpFire.effects);

        // このオブジェクトのポイントライトを取得
        light = transform.GetChild(0).gameObject;


        light.SetActive(false);
        if (!dieable || fuseCon.active)
        {
            light.SetActive(true);
            StartFire(ref normalFire);
        }

    }

    // Update is called once per frame
    void Update()
    {
        FireSwitch();
    }

    private void FireSwitch()
    {
        switch(fireMode)
        {
            case E_FIRE_MODE.OUT:
                Switch_ForOut();
                break;
            case E_FIRE_MODE.NORMAL:
                Switch_ForNormal();
                break;
            case E_FIRE_MODE.UP:
                Switch_ForUp();
                break;
        }

    }

    private void Switch_ForOut()
    {
        if(fuseCon.active)
        {
            light.SetActive(true);
            StartFire(ref normalFire);
            fireMode = E_FIRE_MODE.NORMAL;
        }
    }

    private void Switch_ForNormal()
    {
        if(shadowMode.goFire)
        {
            EndFire(ref normalFire);
            StartFire(ref powerUpFire);
            fireMode = E_FIRE_MODE.UP;
        }
    }

    private void Switch_ForUp()
    {
        if (!shadowMode.goFire)
        {
            if (dieable&&!fuseCon.active)
            {
                EndFire(ref powerUpFire);
                EndFire(ref normalFire);
                light.SetActive(false);
                fireMode = E_FIRE_MODE.OUT;
            }
            else
            {
                EndFire(ref powerUpFire);
                StartFire(ref normalFire);
                fireMode= E_FIRE_MODE.NORMAL;
            }
        }
    }


    public void StartFire(ref FIRE_LIST _fire)
    {
        _fire.mainTrans.gameObject.SetActive(true);
        for(int i = 0; i < _fire.effects.Count; i++)
        {
            _fire.effects[i].SendEvent("Play");
        }
    }

    public void EndFire(ref FIRE_LIST _fire)
    {
        _fire.mainTrans.gameObject.SetActive(false);
        //for (int i = 0; i < _fire.effects.Count; i++)
        //{
        //    _fire.effects[i].SendEvent("");
        //}
    }

    /// <summary>
    /// 炎エフェクトをリストに登録する
    /// </summary>
    /// <param name="_grandPar">登録したいエフェクトを纏めたオブジェのTransform</param>
    /// <param name="_effects">登録先VisualEffectリスト</param>
    public void SetFireEffect(Transform _grandPar,List<VisualEffect> _effects)
    {
        // 子の数繰り返す
        for (int i = 0; i < _grandPar.childCount; i++)
        {
            // i番目の子を登録
            Transform oneFirePar = _grandPar.GetChild(i);
            // oneFireParの子のVisualEffectを登録
            for (int j = 0; j < oneFirePar.childCount; j++)
            {
                _effects.Add(oneFirePar.GetChild(j).GetComponent<VisualEffect>());
            }
        }
    }

    private void OnApplicationQuit()
    {
        normalFire.effects.Clear();
        powerUpFire.effects.Clear();
    }
}
