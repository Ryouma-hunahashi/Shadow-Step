using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowMain : MonoBehaviour
{
    [System.Serializable]
    public struct SHADOWS
    {
        [Header("影がどのライトに当てられたものか")]
        public GameObject light;
        [Header("影の生成方向")]
        public Vector3 toLightVec;
        [Header("使用している影のオブジェクト")]
        public List<GameObject> shadowObjs;
        // 影の長さ
        public float shadowDis;
        // 前方影かどうか
        public bool isFront;
    }

    // エネミーのタイプ
    public enum E_ENEMY_TYPE
    {
        [Tooltip("通常")]Normal,
        [Tooltip("バリア持ち")]Barrir,
    }

    private Transform trans;


    //[Header("影のオブジェクトプレハブ")]
    //[SerializeField] private GameObject shadowObj;
    // 影オブジェのプール
    private ObjectPool shadowPool;

    // 使用している影のオブジェクト
    //[SerializeField]private List<GameObject> shadowObjs = new List<GameObject>();
    [Header("Enemyの属性設定")]
    [SerializeField] private E_ENEMY_TYPE emType = E_ENEMY_TYPE.Normal;
    public E_ENEMY_TYPE GetEnemyType() { return emType; }

    // パワーアップの際に格納
    private ShadowHitChecker[] powerUpPoints;
    private GameObject[] powerUpObjs;
    public bool CheckHitPowerUp(Transform _trans)
    {
        for(int i = 0; i < powerUpPoints.Length; i++)
        {
            if (powerUpPoints[i].CheckHitShadow(_trans))
            {
                return true;
            }
        }
        return false;
    }



    [SerializeField] private SHADOWS[] shadows = new SHADOWS[4];
    public SHADOWS GetShadow(int _num) { return shadows[_num]; }
    public bool GetFront(int _num) { return shadows[_num].isFront; }
    public Vector3[] GetLightsVec() 
    {
        Vector3[] lightPos = new Vector3[shadows.Length];

        for(int i = 0; i < shadows.Length; i++)
        {
            if(shadows[i].light != null)
                lightPos[i] = shadows[i].toLightVec;
            else
                lightPos[i] = Vector3.zero;
        }

        return lightPos;
    }


    [Header("使ってる影を保管しておくオブジェクト")]
    [SerializeField] private GameObject shadowManageObj;
    public GameObject GetManagerObj() { return shadowManageObj; }
    private GameObject[] oneShadowManages = new GameObject[4];
    private FireController[] fireCon = new FireController[4];
    public FireController GetFireCon(int _num) {  return fireCon[_num]; }
    // 使っている影のマネージャー

    private ShadowManager shadowManager;
    public ShadowManager GetShadowManager() { return shadowManager; }
    private Enemy_Main em_Main;

    [Header("当たり判定一つのZスケール")]
    [SerializeField, PersistentAmongPlayMode] private float oneShadowScale = 0.5f;
    public float GetShadowScale() { return oneShadowScale; }

    // 伸びているかどうか
    private bool extendFg = false;
    public bool GetExtendFg() { return extendFg; }

    private int extendNum;
    public int GetExtendNum() { return extendNum; }

    // ライト接続フラグ
    private bool lightOn = false;
    public bool GetLightOn() { return lightOn; }
    private GameObject fixObj = null;

    [SerializeField] private float lightLimit = 15.0f;
    private float lightElapTime = 0.0f;



    // 伸びている時の先端オブジェ
    public GameObject extendObj;
    /// <summary>
    /// プレイヤーに触れられている影を取得
    /// </summary>
    public GameObject GetHitShadow() { return shadowManager.hitchild; }
    // 伸ばすときの初期設定をしたかどうか
    public bool extendSetting = false;
    // この影が燃やされたかどうか
    public bool isFire = false;
    // プレイヤーオブジェクト
    private GameObject player;
    private Transform extendBase;
    // プレイヤーの影状態管理スクリプト
    public PlayerShadowMode shadowMode { get; set; }

    private bool isEnemy;
    public bool GetIsEnemy() { return isEnemy; }

    void Start()
    {
        shadowPool = GetComponent<ObjectPool>();
        shadowPool.SetParent(transform.parent);
        if (shadowPool == null)
        {
            Debug.LogError("影用のオブジェクトプールをコンポーネントしてください");
        }
        if (shadowManageObj == null)
        {
            Debug.LogError("影保管用オブジェクトを設定してください");
        }

        shadowManager = shadowManageObj.GetComponent<ShadowManager>();
        if (shadowManager == null)
        {
            Debug.LogError("影保管オブジェクトにShadowManagerをコンポーネントしてください");
        }
        shadowManager.mainSqript = this;
        // 影保管オブジェクトの子オブジェクトに新しい空オブジェを登録
        for (int i = 0; i < 4; i++)
        {
            GameObject manageObj = new GameObject("oneShadowManage_" + i.ToString());
            manageObj.transform.parent = shadowManageObj.transform;
            FireController buf = manageObj.AddComponent<FireController>();
            buf.manager = shadowManager;
            fireCon[i] = buf;
            oneShadowManages[i] = manageObj;
            shadows[i].shadowObjs = new List<GameObject>();
        }


        powerUpObjs = GameObject.FindGameObjectsWithTag("PowerUp");
        powerUpPoints = new ShadowHitChecker[powerUpObjs.Length];
        for (int i = 0; i < powerUpObjs.Length; i++)
        {
            powerUpPoints[i] = powerUpObjs[i].GetComponent<ShadowHitChecker>();
        }

        trans = transform;

        GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
        player = objs[objs.Length - 1];
        extendBase = player.transform.GetChild(4);
        shadowMode = player.GetComponent<PlayerShadowMode>();

        em_Main = GetComponent<Enemy_Main>();
        isEnemy = em_Main!=null;
    }

    void FixedUpdate()
    {
        // 伸びている状態であれば
        if(extendFg)
        {
            if (shadowMode.goFire)
            {
                return;
            }
            InitExtend();
            int ind = extendObj.transform.parent.GetSiblingIndex();
            if (ind >= fireCon.Length) { return; }
            // プレイヤーと影の先端の距離
            Vector3 dis = extendBase.position- extendObj.transform.position;
            dis.y = 0;
            // 距離が影のXサイズを超えれば
            if (dis.sqrMagnitude >= oneShadowScale*oneShadowScale)
            {
                // 新たな影を生成
                GameObject addObj = shadowPool.GetPool();
                shadows[ind].shadowObjs.Add(addObj);
                // 親を設定
                addObj.transform.parent = extendObj.transform.parent;
                // ポジションをずらした位置に
                addObj.transform.position = extendObj.transform.position + dis;
                // スケールを規定サイズに
                Vector3 scale = addObj.transform.lossyScale;
                scale.x = 1.0f;
                scale.z = oneShadowScale;
                addObj.transform.localScale = scale;
                // プレイヤーと影の先端の間の角度を計算
                float disDeg = Mathf.Atan2(dis.x, dis.z) * Mathf.Rad2Deg;
                // 角度を影の回転に変換
                addObj.transform.rotation = Quaternion.identity * Quaternion.Euler(0,disDeg,0);
                // 先端のオブジェを更新
                extendObj = addObj;
            }
        }
        else if(lightOn)
        {
            lightElapTime += Time.deltaTime;
            if(lightElapTime>=lightLimit)
            {
                EndLightOn();
            }
        }
    }

    private void OnTriggerStay(Collider other)
    {
        // 伸びている状態なら実行しない
        if (extendFg||lightOn)
        {
            return;
        }
        if (shadowMode.goFire)
        {
            return;
        }
        if(isEnemy&&em_Main.GetIsDespawn())
        {
            return ;
        }
        // 光に当たったとき
        if (other.gameObject.tag == "Light")
        {
            // 登録されているライトの番号
            int managerNum = -1;
            // 見つからなかった場合に備えた空番号
            int space = -1;
            for (int i = 0; i < shadows.Length; i++)
            {
                // 登録されていればその添え字を取得
                if (shadows[i].light == other.gameObject)
                {
                    //Debug.Log(i);
                    managerNum = i;
                    break;
                }
                // 登録されていないとき、空番号があれば一番前の物を取得しておく
                else if (space == -1 && shadows[i].light == null)
                {
                    space = i;
                }

            }

            if (managerNum == -1)
            {
                if (space == -1)
                {
                    return;
                }
                managerNum = space;

                // ライトの登録
                shadows[managerNum].light = other.gameObject;
            }


            // ライトのTransformとその親を保存
            Transform lightTrans = other.transform;
            Transform lightParTrans = other.transform.parent;

            // ライトの親の左右の座標を取得
            Vector3 parLeftPos = new Vector3(lightParTrans.position.x - lightParTrans.lossyScale.x / 2,
                lightParTrans.position.y, lightParTrans.position.z);
            Vector3 parRightPos = new Vector3(lightParTrans.position.x + lightParTrans.lossyScale.x / 2,
                lightParTrans.position.y, lightParTrans.position.z);

            // 左右座標を親の回転分回す
            parLeftPos -= lightParTrans.position;
            parRightPos -= lightParTrans.position;
            parLeftPos = lightParTrans.rotation * parLeftPos;
            parRightPos = lightParTrans.rotation * parRightPos;
            parLeftPos += lightParTrans.position;
            parRightPos += lightParTrans.position;

            // 右端からこのオブジェクトまでのベクトルを生成
            Vector3 thisCtoParRightVec = trans.position - parRightPos;
            // 親の左端から右端までのベクトルを生成
            Vector3 parLineVec = parLeftPos - parRightPos;
            // 上記二つの外積を計算。この座標とライトの親までの距離を計算する
            float cross_parLineToCRvec = parLineVec.x * thisCtoParRightVec.z - parLineVec.z * thisCtoParRightVec.x;

            // 距離をライトのサイズから減算する事で、このオブジェクトからライトの端までの距離を求める。
            shadows[managerNum].shadowDis = lightTrans.lossyScale.z - Mathf.Abs(cross_parLineToCRvec) / parLineVec.magnitude;
            // 回転を登録
            Vector3 shadowVec = lightParTrans.rotation * Vector3.back;
            // 影の発生方向を保存
            shadows[managerNum].toLightVec = shadowVec;

            // 光源の回転座標を取得する
            Quaternion rot = Quaternion.LookRotation(shadowVec, Vector3.up);

            if (isEnemy)
            {
                // 前方にあるかどうかを判定
                shadows[managerNum].isFront = Quaternion.Angle(trans.rotation, rot) < 1f;
            }
            // 必要な影の距離を保存
            float restDis = shadows[managerNum].shadowDis;
            // 使用した影の数を保存
            int shadowNum = 0;
            // 影の距離の残りが0以下になるまで繰り返す
            while (restDis >= 0)
            {
                // オブジェクトの数が足りなければ追加する
                if (shadows[managerNum].shadowObjs.Count < shadowNum + 1)
                {
                    GameObject addObj = shadowPool.GetPool();
                    shadows[managerNum].shadowObjs.Add(addObj);
                    addObj.transform.parent = oneShadowManages[managerNum].transform;

                }


                // スケールを規定値に登録
                var scale = shadows[managerNum].shadowObjs[shadowNum].transform.lossyScale;
                scale.x = 1.0f;
                scale.z = restDis < oneShadowScale ? restDis : oneShadowScale;
                shadows[managerNum].shadowObjs[shadowNum].transform.localScale = scale;

                // ポジションを影の数によって少しずつずらす
                shadows[managerNum].shadowObjs[shadowNum].transform.position = trans.position + shadowVec * (oneShadowScale * (shadowNum) + scale.z);

                // 回転を登録
                shadows[managerNum].shadowObjs[shadowNum].transform.rotation = Quaternion.identity * lightTrans.rotation;


                // 影の数を増やす
                shadowNum++;
                // 残り距離を計算
                restDis -= oneShadowScale;
            }
            // 影の数が、使用している数より少なければ
            if (shadowNum <= shadows[managerNum].shadowObjs.Count)
            {
                // 不要分を未使用状態に
                for (int i = shadows[managerNum].shadowObjs.Count - 1; i >= shadowNum; i--)
                {
                    if (shadowPool.ReturnPool(shadows[managerNum].shadowObjs[i]))
                    {
                        //shadowObjs[i].transform.parent = null;
                        shadows[managerNum].shadowObjs.RemoveAt(i);

                    }
                }
            }
        }
    }

    public void ReturnShadowObj(GameObject _obj)
    {
        for(int i = 0;i<oneShadowManages.Length;i++)
        {
            if(oneShadowManages[i] == _obj.transform.parent.gameObject)
            {
                if (shadowPool.ReturnPool(_obj))
                {
                    shadows[i].shadowObjs.Remove(_obj);
                    //_obj.transform.parent = null;
                }

            }
        }
    }

    public void ReturnAllShadow()
    {
        for (int i = 0; i < shadows.Length; i++)
        {
            for (int j = shadows[i].shadowObjs.Count - 1; j >= 0; j--)
            {
                if (shadowPool.ReturnPool(shadows[i].shadowObjs[j]))
                {
                    shadows[i].shadowObjs.RemoveAt(j);
                }
            }
            shadows[i].light = null;
            shadows[i].toLightVec = Vector3.zero;
            shadows[i].shadowDis = 0;
        }
    }

    public void ResetData()
    {
        extendFg = false;
        extendNum = -1;
        extendObj = null;
        extendSetting = false;
        this.ReturnAllShadow();
    }

    private void OnTriggerExit(Collider other)
    {
        // 離れたのがライトの時
        if(other.gameObject.tag =="Light")
        {
            if(extendFg) return;

            // 登録されているライトの番号
            int managerNum = -1;
            for (int i = 0; i < shadows.Length; i++)
            {
                // 登録されていればその添え字を取得
                if (shadows[i].light == other.gameObject)
                {
                    managerNum = i;
                    break;
                }

            }

            if (managerNum == -1)
            {
                return;
            }


            if(shadowManager.hitchild!=null&&shadowManager.hitchild.transform.parent.GetSiblingIndex() == managerNum)
            {
                shadowManager.hitchild = null;
            }

            // 影を全て消滅させる
            for (int i= 0;i< shadows[managerNum].shadowObjs.Count; i++)
            {
                //shadows[managerNum].shadowObjs[i].transform.parent = null;
                shadowPool.ReturnPool(shadows[managerNum].shadowObjs[i]);
            }
            shadows[managerNum].light = null;
            shadows[managerNum].toLightVec = Vector3.zero;
            shadows[managerNum].shadowObjs.Clear();
            shadows[managerNum].shadowDis = 0;
        }
    }


    private void OnApplicationQuit()
    {
        for(int i = 0;i<shadows.Length;i++)
        {
            // 影をリセット
            shadows[i].shadowObjs.Clear();

        }
    }

    public bool NowFixing(GameObject _obj)
    {
        return _obj!=null&&_obj == fixObj;
    }

    public void OutFix()
    {
        extendSetting = false;
        lightOn = false;
        extendFg = true;
        InitExtend();
        fixObj = null;
    }

    //public void SetExtend(GameObject _extendObj)
    //{
    //    extendFg = true;
    //    lightOn = false;
    //    extendNum = _extendObj.transform.parent.GetSiblingIndex();
    //    extendObj = _extendObj;
    //}

    public void InitExtend()
    {
        // 初期設定を行っていない場合
        if (extendSetting)
        {
            return;
        }
        if (shadowManager.hitchild != null)
        {
            extendObj = shadowManager.hitchild;
            extendNum = extendObj.transform.parent.GetSiblingIndex();
        }
        if (extendNum >= fireCon.Length) { return; }

        // 先端をプレイヤーの当たっているオブジェクトにし、それ以外を一度未使用状態に
        for (int i = shadows[extendNum].shadowObjs.Count - 1; i > extendObj.transform.GetSiblingIndex(); i--)
        {
            //shadows[ind].shadowObjs[i].transform.parent = null;
            if (shadowPool.ReturnPool(shadows[extendNum].shadowObjs[i]))
            {
                shadows[extendNum].shadowObjs.RemoveAt(i);
            }
        }
        for (int i = 0; i < shadows.Length; i++)
        {
            if (i != extendNum)
            {
                for (int j = shadows[i].shadowObjs.Count - 1; j >= 0; j--)
                {
                    if (shadowPool.ReturnPool(shadows[i].shadowObjs[j]))
                    {
                        //shadows[i].shadowObjs[j].transform.parent = null;
                        shadows[i].shadowObjs.RemoveAt(j);
                    }
                }
            }
        }
        // 初期設定を行った
        extendSetting = true;
        extendFg = true;
        lightOn = false;

    }

    public void EndExtend()
    {
        if (!extendSetting) { return; }
        if (lightOn) { return; }

        if(shadowMode.isLSwitchHit)
        {
            SetLightOn(shadowMode.LSwitchObj);
            return;
        }

        if (extendObj != null)
        {
            Debug.Log("extendObj"+extendObj.ToString());
            int shadowsNum = extendObj.transform.parent.GetSiblingIndex();
            for (int i = shadows[shadowsNum].shadowObjs.Count-1; i >=0 ; i--)
            {
                GameObject obj = shadows[shadowsNum].shadowObjs[i];
                if (shadowPool.ReturnPool(obj))
                {
                    shadows[shadowsNum].shadowObjs.RemoveAt(i);
                }
            }
        }

        shadowManager.hitchild = null;
        extendFg = false;
        extendSetting = false;
        extendObj = null;
        extendNum = -1;

    }

    public void SetLightOn(GameObject _obj)
    {
        shadowManager.hitchild = null;
        lightOn = true;
        extendFg = false;
        fixObj = _obj;
    }

    public void EndLightOn()
    {
        lightOn = false;
        EndExtend();
    }
}
