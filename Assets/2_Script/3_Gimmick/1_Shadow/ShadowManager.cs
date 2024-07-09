using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class ShadowManager : MonoBehaviour
{
    // 当たっている最も手前の影
    public GameObject hitStartShadow = null;

    // 当たっている影
    public GameObject hitchild = null;

    [SerializeField] private float extendAbleDis = 3.0f;
    public float GetExtendAbleDis() { return extendAbleDis; }

    // プレイヤーのシャドウ状態管理
    public PlayerShadowMode shadowModeSqript;
    // このマネージャーに登録する影の根に付いている影管理スクリプト
    public ShadowMain mainSqript;

    // 当たっているこのオブジェクト以外の影の根
    public List<GameObject> hitShadowMain = new List<GameObject>();
    public List<GameObject> chainList = new List<GameObject>();

    [SerializeField] private GameObject firePar;
    private VisualEffect normalFire;
    private VisualEffect powerFire;
    private bool isFireWait = false;

    int num = 0;

    public bool fireEnd = false;
    public bool enemyFlame = false;
    public bool barrirBreak = false;

    public void ResetShadowData()
    {
        shadowModeSqript.goFire = false;
        fireEnd = false;
        enemyFlame = false;
        barrirBreak = false;
        hitchild = null;
        hitStartShadow = null;
        for (int i = 0; i < transform.childCount; i++)
        {
            mainSqript.GetFireCon(i).ResetFireData();
        }
        normalFire.gameObject.SetActive(false);
        powerFire.gameObject.SetActive(false);
        StartCoroutine(shadowModeSqript.CameraReturnWait());
        mainSqript.ResetData();

        //mainSqript.gameObject.transform.position = new Vector3(1000, 1000, 1000);
    }

    void Start()
    {
        // プレイヤーの管理スクリプトを取得
        GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
        shadowModeSqript = objs[objs.Length-1].GetComponent<PlayerShadowMode>();
        if(shadowModeSqript == null)
        {
            Debug.LogError("プレイヤー、又はプレイヤーのシャドウ状態管理スクリプトが見当たりません");
        }
        if(firePar!=null)
        {
            normalFire = firePar.transform.GetChild(0).GetComponent<VisualEffect>();
            powerFire = firePar.transform.GetChild(1).GetComponent<VisualEffect>();
        }
    }

    void Update()
    {
        // プレイヤーに、自身の影とのヒット情報をチェックさせる。
        shadowModeSqript.SetHitShadow(this);

        //// プレイヤーと当たっている影がある状態で、プレイヤーが影を掴んだ時
        //// まだ掴まれた判定を行っていなければ、掴まれた状態へ変化
        //if (hitchild != null && shadowModeSqript.isShadow && !mainSqript.GetExtendFg()
        //    &!mainSqript.GetLightOn())
        //{
        //    mainSqript.SetExtend(hitchild);
        //}
        //else if (!shadowModeSqript.isShadow)
        //{
        //    if(mainSqript.GetLightOn())
        //    {
        //        return ;
        //    }
        //    if (mainSqript.GetExtendFg())
        //    {

        //        hitchild = null;

        //    }
        //    if (shadowModeSqript.isLSwitchHit)
        //    {
        //        mainSqript.SetLightOn(shadowModeSqript.LSwitchObj);
        //        return;
        //    }
        //    mainSqript.EndExtend();
        //}
    }

    private void LateUpdate()
    {

        if (mainSqript.GetExtendFg())
        {
            this.CountChainNum();
            killEnemy();

        }
    }

    public void SetHitShadowMain(GameObject _obj)
    {
        // もし登録がゼロなら一つ目を追加
        if (hitShadowMain.Count == 0)
        {
            hitShadowMain.Add(_obj);
            return;
        }
        // マネージャーに登録されている影をチェック
        for (int i = 0; i < hitShadowMain.Count; i++)
        {
            // 同じものがあれば処理を抜ける
            if (hitShadowMain[i].gameObject == _obj)
            {
                return;
            }
            // 最後まで同じものが見つからなければ追加する
            else if (i == hitShadowMain.Count - 1)
            {
                hitShadowMain.Add(_obj);
                break;
            }
        }
    }

    public int GetExtendAbleNum()
    {
        int num = (int)(extendAbleDis / mainSqript.GetShadowScale());
        return num - 1;
    }

    private void CountChainNum()
    {
        int cnt = hitShadowMain.Count;
        chainList.Clear();
        for(int i = 0; i < cnt; i++)
        {
            if (hitShadowMain[i] != this.gameObject)
            {
                chainList.Add(hitShadowMain[i]);
            }
        }
        cnt = chainList.Count + 1;
        for (int i = 0; i < chainList.Count; i++)
        {
            ShadowManager buf = shadowModeSqript.GetShadowManager(chainList[i].transform);
            if(buf == null) continue;
            for (int j = 0; j < buf.hitShadowMain.Count; j++)
            {
                bool search = true;
                for(int n = 0;n<chainList.Count; n++)
                {
                    if(buf.hitShadowMain[j] == 
                        chainList[n]
                        ||buf.hitShadowMain[j] == this.gameObject)
                    {
                        search = false;
                        break;
                    }
                }
                if(search)
                {
                    chainList.Add(buf.hitShadowMain[j]);
                    cnt++;
                }
            }
        }
        num = cnt;
    }

    private void killEnemy()
    {
        bool bf = fireEnd;

        for (int i = 0; i < chainList.Count; i++) 
        {
            bf &= shadowModeSqript.GetShadowManager(chainList[i].transform).fireEnd;

        }
        if (bf)
        {
            StartCoroutine(DestroySet());
        }
    }

    private IEnumerator DestroySet()
    {
        if(isFireWait)
        {
            yield break;
        }
        isFireWait = true;

        for (int i = 0; i < chainList.Count; i++)
        {
            shadowModeSqript.GetShadowManager(chainList[i].transform).PlayFlameEff();
        }
        this.PlayFlameEff();

        for(int i = 0;i<45;i++)
        {
            yield return null;
        }

        Debug.Log("では死にましょうね");
        for (int i = 0; i < chainList.Count; i++)
        {
            shadowModeSqript.GetShadowManager(chainList[i].transform).destroyDis();
        }
        this.destroyDis();

        shadowModeSqript.EndFire();

        isFireWait =false;
    }

    private void PlayFlameEff()
    {

        bool search = false;
        for (int i = 0; i < 4; i++)
        {
            if (mainSqript.GetFireCon(i).powerUp)
            {
                search = true;
                break;
            }
        }
        if (search)
        {
            powerFire.gameObject.SetActive(true);
            powerFire.SendEvent("Play");
        }
        else
        {
            normalFire.gameObject.SetActive(true);
            normalFire.SendEvent("Play");
        }
    }

    private void destroyDis()
    {
        if(enemyFlame&&mainSqript.GetEnemyType() == ShadowMain.E_ENEMY_TYPE.Barrir)
        {
            bool search = false;
            for (int i = 0; i < 4; i++)
            {
                if(mainSqript.GetFireCon(i).powerUp)
                {
                    search = true;
                    break;
                }
            }
            if(!search)
            {
                enemyFlame = false;
            }
        }
        if(enemyFlame)
        {
            mainSqript.transform.parent.gameObject.SetActive(false);
            normalFire.gameObject.SetActive(false);
            powerFire.gameObject.SetActive(false);
            gameObject.SetActive(false);
            shadowModeSqript.goFire = false;
        }
        else
        {
            ResetShadowData();
        }
        //switch(mainSqript.GetEnemyType())
        //{
        //    case ShadowMain.E_ENEMY_TYPE.Normal:

        //        mainSqript.transform.parent.gameObject.SetActive(false);
        //        gameObject.SetActive(false);
        //        shadowModeSqript.goFire = false;
        //        break;

        //    case ShadowMain.E_ENEMY_TYPE.Barrir:
        //        if(enemyFlame)
        //        {
        //            mainSqript.transform.parent.gameObject.SetActive(false);
        //            gameObject.SetActive(false);
        //            shadowModeSqript.goFire = false;
        //            fireEnd = false;
        //            break;
        //        }
        //        ResetShadowData();
        //        break;
        //}

    }

    private void OnApplicationQuit()
    {
        hitShadowMain.Clear();
    }
}
