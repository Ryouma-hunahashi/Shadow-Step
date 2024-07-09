using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PlayerShadowMode : MonoBehaviour
{

    private enum PLAYER_STATE
    {
        NORMAL,     // 通常状態（掴んでいない状態）
        ISSHADOW,   // 掴んている状態
        ISFINE      // 影を燃やしている状態
    }


    // フィールド上にあるShadowManagerのデータ
    [System.Serializable]
    private struct FIELD_SH_MAN_DATA
    {
        public Transform managerTrans;  // トランスフォーム
        public ShadowManager shadowManager; // スクリプト
    }


    [SerializeField] private PLAYER_STATE plState;

    [Tooltip("初速度（1秒で何個影を当てるか）")]
    public byte initSpeed;
    [Tooltip("1フレーム毎に加速する値")]
    public byte accel = 1;
    public  const float accelTime = 0.0167f;


    [Tooltip("発火時間")]
    public float fireTime = 5.0f;
    [Header("カメラがもどるまでの時間")]
    [SerializeField] private int cameraReturnWait = 30;
    [Tooltip("影掴み状態")]
    public bool isShadow = false;
    [Tooltip("影に当たっているか")]
    public bool shadowHit = false;
    [Tooltip("発火オブジェに当たっているか")]
    public bool isFuseHit = false;
    [Tooltip("ライトコンセントに当たっているか")]
    public bool isLSwitchHit = false;
    public GameObject LSwitchObj = null;
    [Tooltip("発火開始フラグ")]
    public bool go = false;
    [Tooltip("発火中フラグ")]
    public bool goFire = false;

    private bool isCorutine;

    // 影が当たっているエネミーのマネージャー
    private List<ShadowManager> shadowManagers = new List<ShadowManager>();

    private FIELD_SH_MAN_DATA[] manageDatas;
    // 指定したTransformと一致するマネージャーのスクリプトを返す
    public ShadowManager GetShadowManager(Transform _managerTrans)
    {
        for(int i = 0; i < manageDatas.Length; i++)
        {
            if(manageDatas[i].managerTrans == _managerTrans)
            {
                return manageDatas[i].shadowManager;
            }
        }
        return null;
    }

    private CameraChange cameraChange;

    private WaitForSeconds oneSecond;

    private Animator anim;
    private Rigidbody rb;
    // フィールド上エネミーの格納先
    private GameObject[] enemys;
    [Tooltip("敵全滅フラグ")]
    public bool endFg = false;

    public bool isPause;

    // フィールド上の発火装置格納先
    private GameObject[] fuseObjs;
    private FuseConditioner[] fuses;
    private GameObject hitFuseObj;

    private void Start()
    {
        // シーン上のエネミーを全取得
        GameObject[] enemyBuf = GameObject.FindGameObjectsWithTag("Enemy");
        enemys = enemyBuf;
        fuseObjs = GameObject.FindGameObjectsWithTag("Fuse");
        fuses = new FuseConditioner[fuseObjs.Length];
        for(int i = 0; i < fuses.Length; i++)
        {
            fuses[i] = fuseObjs[i].GetComponent<FuseConditioner>();
        }
        manageDatas = new FIELD_SH_MAN_DATA[enemys.Length];
        for(int i = 0; i < enemys.Length; i++)
        {
            manageDatas[i].shadowManager = enemys[i].GetComponent<ShadowMain>().GetManagerObj().GetComponent<ShadowManager>();
            manageDatas[i].managerTrans = manageDatas[i].shadowManager.transform;
        }
        cameraChange = GetComponent<CameraChange>();
        anim = GetComponent<Animator>();
        rb = GetComponent<Rigidbody>();
        oneSecond = new WaitForSeconds(1.0f);
        SoundManager.Get().ChangeGroupBGM(E_BGM_TYPE.MAIN);
        SoundManager.Get().PlayBGM();
    }

    private void Update()
    {
        // シーンマネージャーが存在するときに
        if (S_Manager.instance != null)
        {
            // enemyの全滅チェックを行う
            endFg = true;
            float toEm_MinDis = float.MaxValue;
            Transform minTrans = null;
            for (int i = 0;i<enemys.Length;i++)
            {
                // エネミーの生存状態を記録
                // trueが一つでもあればfalseが入る
                endFg &= !enemys[i].transform.parent.gameObject.activeSelf;
                Vector3 dir = transform.position - enemys[i].transform.position;
                if(dir.sqrMagnitude>toEm_MinDis*toEm_MinDis)
                {
                    toEm_MinDis = dir.magnitude;
                    minTrans = enemys[i].transform;
                }
            }
            // 全滅していればシーンをセレクトへ。
            // この処理は、リザルトが完成次第消去するものとする

            if (SoundManager.Get() != null)
            {
                if (isShadow)
                {
                    SoundManager.Get().SetBlendTrans(1); // 仮置き。基本はChangeGroupでShadowに変更
                }
                else
                {
                    SoundManager.Get().SetBlendTrans(1 - toEm_MinDis / 10.0f);

                }
                //if (toEm_MinDis <= 10.0f)
                //{
                //    SoundManager.Get().PlaySE3D(E_SE_TYPE.EM_DISCOVERY, minTrans);
                //}
            }
        }
        // 一つでも接触している影があれば

        // 状態処理
        switch (plState)
        {
            // 通常状態
            case PLAYER_STATE.NORMAL:

                // 掴み状態になったとき
                if(isShadow && shadowHit)
                {
                    plState = PLAYER_STATE.ISSHADOW;
                }
                else
                {
                    anim.SetBool("grab", false);
                }

                break;

            // 影掴んでいる状態
            case PLAYER_STATE.ISSHADOW:

                if (!isShadow)
                {

                    //if (goFire && cameraChange != null)
                    //{
                    //    cameraChange.EndTopViewCamera();
                    //}
                    //// 発火状態を切る
                    //goFire = false;
                    //go = false;
                    plState = PLAYER_STATE.NORMAL;
                }
                break;

            // 影が燃えている状態
            case PLAYER_STATE.ISFINE:

                // 発火命令が出てる時発火
                if (go)
                {
                    plState = PLAYER_STATE.ISFINE;
                    if (cameraChange != null)
                    {
                        cameraChange.SetTopViewCamera();
                    }
                    goFire = true;
                    go = false;
                }
                if(goFire)
                {
                   
                }
                if (!isShadow)
                {

                    if (cameraChange != null)
                    {
                        cameraChange.EndTopViewCamera();
                    }
                    // 発火状態を切る
                    // 影セット状態を解除
                    anim.SetBool("grab", false);
                    goFire = false;
                    go = false;
                    plState = PLAYER_STATE.NORMAL;
                }
                break;
        }

        // 影マネージャーが存在しているとき
        if (shadowManagers.Count != 0)
        {
            // ヒット状態をTrueに
            shadowHit = true;

            for(int i = shadowManagers.Count -1;i>=0;i--)
            {
                // 非アクティブ状態なら外す
                if(!shadowManagers[i].mainSqript.transform.parent.gameObject.activeSelf)
                {
                    shadowManagers.RemoveAt(i);
                }
            }
            // 整理した結果0個になれば、消す
            if(shadowManagers.Count == 0)
            {
                shadowHit=false;
                //if (goFire)
                //{
                //    goFire = false;
                //    StartCoroutine(CameraReturnWait());

                //}
            }
        }
        // 一つもなければ
        else
        {
            // 諸々のフラグを消す
            shadowHit=false;
            //if (goFire)
            //{
            //    goFire = false;
            //    StartCoroutine(CameraReturnWait());

            //}
            //else
            //{
            //    isShadow = false;
            //    goFire = false;
            //}
        }

       
    }

    /// <summary>
    /// 掴み状態のフラグ
    /// </summary>
    /// <param name="_fg">掴み状態</param>
    public void SetShadow(bool _fg)
    {
        if (_fg)
        {
            if(isLSwitchHit)
            {
                for(int i = 0;i<shadowManagers.Count;i++)
                {
                    if(shadowManagers[i].mainSqript.NowFixing(LSwitchObj))
                    {
                        if (isShadow != _fg) { anim.SetBool("grab", true); }
                        isShadow = true;
                        shadowManagers[i].mainSqript.OutFix();
                        break;
                    }
                }
            }
            if (shadowHit)
            {
                bool search = false;
                for (int i = 0; i < shadowManagers.Count; i++)
                {
                    if (!shadowManagers[i].mainSqript.GetLightOn())
                    {
                        search |= true;
                        shadowManagers[i].mainSqript.InitExtend();
                    }
                }
                if (search)
                {
                    Debug.Log("isShadow:" + isShadow);
                    if (isShadow != _fg)
                    {
                        anim.SetBool("grab", true);
                        SoundManager.Get().PlaySE3D(E_SE_TYPE.PL_SHADOW_GRAP,transform);
                    }
                    isShadow = true;
                }
            }
        }
        else
        {
            // 発火オブジェに当たっていれば
            if (isFuseHit && isShadow != _fg )
            {
                int num = this.GetHitFuseNum(hitFuseObj);
                if(num==-1)
                {
                    Debug.Log("探索失敗！");
                    // 影セット状態を解除
                    this.EndExtend(_fg);
                    return;
                }
                else if(fuses[num]!=null&&!fuses[num].active)
                {
                    Debug.Log("へっ！女神像は死んだぜ！");
                    // 影セット状態を解除
                    this.EndExtend(_fg);
                    return;
                }
                if (isCorutine) { return; }
                Debug.Log("お前は神の力を得た");
                if (cameraChange != null)
                {
                    cameraChange.SetTopViewCamera();
                }
                // 掴み状態を維持し、燃やす
                anim.Play("Ignition");
                anim.SetBool("grab", false);
                SoundManager.Get().StopAllSE3D();
                SoundManager.Get().PlaySE3D(E_SE_TYPE.FIRE_SHORT,transform);
                SoundManager.Get().PlaySE3D(E_SE_TYPE.FIRE_LONG,transform);
                rb.velocity = Vector3.zero;
                isShadow = true;
                goFire = true;
                //StartCoroutine(CameraReturnWait());
                if (isShadow) plState = PLAYER_STATE.ISFINE;
                return;
            }
            else if (!isCorutine)
            {
                this.EndExtend(_fg);
            }
        }
    }

    private void EndExtend(bool _fg)
    {
        if (!isShadow) return;
        // 影セット状態を解除
        if (isShadow != _fg) { anim.SetBool("grab", false); }
        for (int i = 0; i < shadowManagers.Count; i++)
        {
            shadowManagers[i].mainSqript.EndExtend();
        }
        Debug.Log("掴み終了");
        shadowHit = false;
        isShadow = false;

    }

    /// <summary>
    /// 当たっている影のマネージャーをセットする
    /// </summary>
    /// <param name="_shadowManager">影のマネージャー</param>
    public void SetHitShadow(ShadowManager _shadowManager)
    {
        // プレイヤーが当たっている状態であれば
        if (_shadowManager.hitchild != null)
        {
            // 探索チェックフラグ
            bool sarchHit = false;

            for(int i = 0;i< shadowManagers.Count;i++)
            {
                // 同じマネージャーが既に登録されていれば探索を終了
                if (shadowManagers[i] == _shadowManager)
                {
                    sarchHit = true;
                    break;
                }
            }
            // 登録されていなければリストに追加
            if (!sarchHit)
            {
                shadowManagers.Add(_shadowManager);
            }
        }
        else
        {
            for(int i = 0; i<shadowManagers.Count;i++)
            {
                // 同じものが見つかれば
                if (shadowManagers[i] == _shadowManager)
                {
                    // 最後尾を見つかったものに上書きし、最後尾を削除
                    int endNum = shadowManagers.Count - 1;
                    shadowManagers[i] = shadowManagers[endNum];
                    shadowManagers.RemoveAt(endNum);
                    break;
                }
            }
        }
        if(shadowManagers.Count == 0) { shadowHit = false; }
    }

    public void EndFire()
    {
        shadowHit = false;
        goFire = false;
        StartCoroutine(CameraReturnWait());
    }

    public IEnumerator CameraReturnWait()
    {
        if(isCorutine)
        {
            yield break;
        }
        Debug.Log("コルーチンせっとだわよ！");
        isCorutine = true;
        for(int i = 0;i<cameraReturnWait;i++)
        {
            if(!isFuseHit)
            {
                Debug.Log("コルーチン中断だわよ！");
                SoundManager.Get().StopTypeAllSE3D(E_SE_TYPE.FIRE_LONG);
                isShadow = false;
                isCorutine = false;
                yield break;
            }
            yield return oneSecond;
        }
        Debug.Log("コルーチン終了だわよ！");
        SoundManager.Get().StopTypeAllSE3D(E_SE_TYPE.FIRE_LONG);
        isCorutine =false;
        isShadow = false;
    }

    private int GetHitFuseNum(GameObject _fuseObj)
    {
        for(int i = 0;i<fuseObjs.Length;i++)
        {
            if(fuseObjs[i] == _fuseObj)
            {
                return i;
            }
        }
        return -1;
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Fuse")
        {
            isFuseHit = true;
            hitFuseObj = other.gameObject;
        }
        if(other.gameObject.tag == "LightOn")
        {
            isLSwitchHit = true;
            LSwitchObj = other.gameObject;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if(other.gameObject.tag == "Fuse")
        {
            isFuseHit = false;
            hitFuseObj = null;
            cameraChange.EndTopViewCamera();
            if (isShadow) plState = PLAYER_STATE.ISSHADOW;

        }
        if (other.gameObject.tag == "LightOn")
        {
            isLSwitchHit = false;
            LSwitchObj = null;
        }
    }

    private void OnApplicationQuit()
    {
        shadowManagers.Clear();
    }
}
