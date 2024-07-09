using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireController : MonoBehaviour
{
    public enum FIRE_STATE
    {
        NOFIRE,         // 燃えていないとき
        IN_OUT_FIRE,    // 中から外へ燃えているとき
        OUT_IN_FIRE     // 外から中へ燃えているとき
    }
    [SerializeField]private FIRE_STATE fireState = FIRE_STATE.NOFIRE;

    private int fireRoadTime = 5;
    private double oneFireElapTime = 0.0f; // 一個の炎にかかる経過時間
    private double fireElapTime = 0.0f; // 全体の経過時間
    public int GetFireRemain() { return fireRoadTime; } // 残り時間
    private int fireRoadNum = 0; // 現在も得ている最低値
    public int GetFireRoad() { return fireRoadNum; }
    private double oneShadowFireTime = 0; // 一個の影のかかる時間
    private float accelCheckTime;
    private bool fireSet = false;
    public bool GetFireSet() { return fireSet; }
    public bool GetFire() { return FIRE_STATE.OUT_IN_FIRE == fireState; }
    public FIRE_STATE GetFireState() { return fireState; }
    public void SetFireState(FIRE_STATE _setState) { fireState = _setState; }

    private bool SetItO = false;

    public ShadowManager manager;

    public bool powerUp = false;
    private bool fireStop = false;
    public void StopFire(int _stopNum)
    {
        fireRoadNum = _stopNum;
        fireStop = true; 
    }


    public void ResetFireData()
    {
        fireState = FIRE_STATE.NOFIRE;
        oneFireElapTime = 0.0f;
        fireRoadNum = 0;
        oneShadowFireTime = 0.0f;
        accelCheckTime = 0.0f;
        fireStop = false;
        fireSet = false;
        SetItO = false;
        powerUp = false;
        Debug.Log("影はしなない");
    }

    void Update()
    {
        // 攻撃実行状態であれば
        if (!fireSet && manager.shadowModeSqript.goFire && manager.mainSqript.GetExtendFg()
            && transform == manager.mainSqript.extendObj.transform.parent)
        {
            fireSet = true;
            //manager.shadowModeSqript.goFire = false;
            // 影の着火をセット
            FireSetting();
        }
        // 影を燃やす処理
        FireUpdate();
        // 影連鎖処理
        ChainUpdate();
    }

    // 影への着火を設定（最後から）
    public void FireSetting()
    {
        // プレイヤーの燃やす時間を取得
        fireRoadTime = manager.shadowModeSqript.initSpeed;
        // 発火開始オブジェクトの子オブジェクト番号を取得
        fireRoadNum = manager.hitchild.transform.parent.childCount;
        // 燃やす時間をオブジェクト番号で除算し一つの発火時間を計算
        oneShadowFireTime = 1.0 / manager.shadowModeSqript.initSpeed;
        // 経過時間等初期化
        oneFireElapTime = 0;
        // 外から内に燃やす状態にする
        fireState = FIRE_STATE.OUT_IN_FIRE;
        //nowFire = true;
    }

    // 影への着火を設定（先頭から）test
    public void FireFirstSetting(int _initSpd,bool _powerUp)
    {
        if (fireSet) { return; }
        // プレイヤーの燃やす時間を取得
        fireRoadTime = _initSpd;
        // 着火開始オブジェクトの子オブジェクト番号を取得(先頭 0)
        fireRoadNum = 0;
        // 燃やす時間を影の個数分で除算して着火時間を計算
        oneShadowFireTime = 1.0 / manager.shadowModeSqript.initSpeed;
        // 経過時間を初期化
        oneFireElapTime = 0;
        // 内から外に燃やす状態にする
        SetFireState(FIRE_STATE.IN_OUT_FIRE);
        powerUp = _powerUp;
        if(powerUp)
        {
            manager.barrirBreak = true;
        }
        fireState = FIRE_STATE.IN_OUT_FIRE;
        fireSet = true;
    }

    /// <summary>
    /// 影からの連鎖を設定
    /// </summary>
    /// <param name="_remainTime">残りの発火時間</param>
    /// <param name="_startNum">連鎖した影コライダーの子番号</param>
    public void ChainSetting(int _initSpd, int _startNum, bool _powerUp)
    {
        // 残り発火時間取得
        fireRoadTime = _initSpd;
        // 子番号取得
        fireRoadNum = _startNum;
        // 一つ当たりの発火時間取得
        oneShadowFireTime = 1 / (double)fireRoadTime;
        // 経過時間等初期化
        oneFireElapTime = 0;
        fireSet = true;
        powerUp = _powerUp;
        if (powerUp)
        {
            manager.barrirBreak = true;
        }
        fireState =FIRE_STATE.OUT_IN_FIRE;
    }

    /// <summary>
    /// 発火の更新処理
    /// </summary>
    private void FireUpdate()
    {
        if(fireState != FIRE_STATE.OUT_IN_FIRE) { return; }
        if (manager.fireEnd) { return; }
        if (fireStop) { return; }
        if (!SetItO&&fireRoadNum <= 0)
        {
            // もし別方向に影が伸びていれば、敵を消さずに影を燃やす
            bool bf = false;
            for (int i = 0; i < 4; i++)
            {
                
                // 自分を参照していれば次の番号に移動する
                if(i == transform.GetSiblingIndex()) { continue; }
                
                // 別方向に影が伸びていれば
                if (this.transform.parent.GetChild(i).childCount != 0)
                {
                    if (!manager.mainSqript.GetFireCon(i).GetFireSet())
                    {

                        manager.mainSqript.GetFireCon(i).FireFirstSetting(fireRoadTime,powerUp);
                        bf = true;
                    }
                }
            }
            if(!bf)
            {
                Debug.Log("連鎖できねえので死ね");
                manager.fireEnd = true;
            }
            SetItO = true;
            manager.enemyFlame = true;

            // 炎をリセット
        }

        // 時間更新
        oneFireElapTime += Time.deltaTime;
        fireElapTime += Time.deltaTime;
        accelCheckTime += Time.deltaTime;

        if(accelCheckTime > PlayerShadowMode.accelTime)
        {
            fireRoadTime+=manager.shadowModeSqript.accel;
            oneShadowFireTime = 1.0 / fireRoadTime;
            accelCheckTime = 0;
        }
        // 一個の経過時間を超えれば
        if (oneFireElapTime >= oneShadowFireTime)
        {
            // 超過した個数を計算
            int overNum = (int)(oneFireElapTime / oneShadowFireTime);

            oneFireElapTime = oneFireElapTime - oneShadowFireTime * overNum;
            // 超過した分ロード数をマイナスする
            fireRoadNum -= overNum;
        }

    }

    // 連鎖の更新処理
    private void ChainUpdate()
    {
        // 燃えていなければ抜ける
        //if(!nowFire) { return; }
        if(fireState != FIRE_STATE.IN_OUT_FIRE) { return; }

        if(fireRoadNum >= this.transform.childCount)
        {
            Debug.Log("先まで燃えたので死ね");
            manager.fireEnd = true;
        }

        // 時間更新
        oneFireElapTime += Time.deltaTime;
        fireElapTime += Time.deltaTime;
        accelCheckTime += Time.deltaTime;

        if (accelCheckTime > PlayerShadowMode.accelTime)
        {
            fireRoadTime += manager.shadowModeSqript.accel;
            oneShadowFireTime = 1.0 / fireRoadTime;
            accelCheckTime = 0;
        }
        // 一個の経過時間を超えれば
        if (oneFireElapTime >= oneShadowFireTime)
        {
            // 超過した個数を計算
            int overNum = (int)(oneFireElapTime / oneShadowFireTime);
            oneFireElapTime = oneFireElapTime - oneShadowFireTime * overNum;
            // 超過した分ロード数をプラスする
            fireRoadNum += overNum;
        }
    }
}
