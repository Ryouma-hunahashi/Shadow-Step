using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class ShadowCollider : MonoBehaviour
{
    private enum E_FIRE_PATTERN
    {
        MAIN_SPEED_UP,
        CHAIN_SPEED_UP,
    }
    [SerializeField] private E_FIRE_PATTERN firePat = E_FIRE_PATTERN.CHAIN_SPEED_UP;

    // 親オブジェクトトランスフォーム
    private Transform par;
    // このオブジェクトのトランスフォーム
    private Transform trans;
    private Vector3 oldPos;
    // 親オブジェクト
    public GameObject parObj;
    // 親オブジェクトの持つ、影の制御用スクリプト
    private ShadowManager shadowManager;
    // 影制御スクリプトのトランスフォーム。親比較の際に使用
    private Transform managerTrans;
    // このオブジェクトのメッシュ。燃やす際に色を変えるのに使用している。
    // この後エフェクトが完成次第、エフェクトに変更する。
    [SerializeField]private MeshRenderer mesh;
    public void SetColor(Color _color) { mesh.material.color = _color; }
    [SerializeField]private VisualEffect effect1;
    [SerializeField]private VisualEffect effect2;
    [SerializeField]private VisualEffect barrirEffect;
    [SerializeField] private VisualEffect powerEffect1;
    [SerializeField] private VisualEffect powerEffect2;
    // このオブジェクトのコライダー
    [SerializeField]private CapsuleCollider col;

    // 炎が通過したかのフラグ
    private bool passFire = false;
    public bool GetPassFire() { return passFire; }

    private bool isBarrir = false;

    // オブジェクトアクティブ状態。外からの参照は親の比較等で行う
    private bool isActive = true;

    // 当たっている影の親オブジェクト
    private List<GameObject> hitObjs = new List<GameObject>();
    // 当たっている影オブジェクト
    private List<GameObject> hitShadows = new List<GameObject>();

    void Awake()
    {
        // メッシュが登録されていなければ登録
        if(mesh == null)
        {
            mesh = GetComponent<MeshRenderer>();
            if(mesh == null)
            {
                Debug.LogError("影の当たり判定にメッシュがないです");
            }
        }
        // コライダーが登録されていなければ登録
        if(col == null)
        {
            col = GetComponent<CapsuleCollider>();
            if(col == null)
            {
                Debug.LogError("影の当たり判定にコライダーがないです");
            }
        }
        if(effect1 == null)
        {
            effect1 = trans.GetChild(0).GetComponent<VisualEffect>();
            if(effect1 == null)
            {
                Debug.LogError("炎のエフェクトが一番目の子にありません");
            }
            
        }
        if (effect2 == null)
        {
            effect2 = trans.GetChild(1).GetComponent<VisualEffect>();
            if (effect2 == null)
            {
                Debug.LogError("炎のエフェクトが二番目の子にありません");
            }

        }
        if(barrirEffect == null)
        {
            barrirEffect = trans.GetChild(2).GetComponent<VisualEffect>();
            if(barrirEffect == null)
            {
                Debug.LogError("バリアのエフェクトがありません");
            }
        }
        if (powerEffect1 == null)
        {
            powerEffect1 = trans.GetChild(3).GetComponent<VisualEffect>();
            if (powerEffect1 == null)
            {
                Debug.LogError("バリアのエフェクトがありません");
            }
        }
        if (powerEffect2 == null)
        {
            powerEffect2 = trans.GetChild(4).GetComponent<VisualEffect>();
            if (powerEffect2 == null)
            {
                Debug.LogError("バリアのエフェクトがありません");
            }
        }
        //effect.SendEvent("Stop");
        //effect1.gameObject.SetActive(false);
        //effect2.gameObject.SetActive(false);
        // トランスフォーム保存
        trans = transform;
        oldPos = trans.position;
        this.SetActive(false);
        //this.SetParent();
    }

    void Update()
    {
        // 親のチェック
        this.SetParent();

        if (!isActive) { return; }
        // 自身の前後に影がある分回す
        for (int i = 0; i < hitShadows.Count; i++)
        {
            // 一番上の親が存在していない場合
            if (hitShadows[i].transform.parent.parent == null)
            {

                // 
                hitShadows[i] = hitShadows[hitShadows.Count - 1];
                hitShadows.RemoveAt(hitShadows.Count - 1);
            }
        }
        //effect.SetVector3("NowPosition", trans.position);
        //effect.SetVector3("OldPosition", oldPos);
        this.PlayFire();
        oldPos = trans.position;
    }

    private void LateUpdate()
    {
        if (!isActive) { return; }
        // そもそもエネミー自体が消えていれば消滅
        if (!shadowManager.mainSqript.gameObject.activeSelf)
        {
            this.SetActive(false);
        }
        // 当たっているオブジェクトを整理する。
        this.AdjustHits();


        // もしこのオブジェクトが一番目の子であれば
        if (trans.GetSiblingIndex() == 0)
        {
            int parentNum = trans.parent.GetSiblingIndex();
            int serchNum = parentNum;
            for(int i = parentNum-1;i>=0;i--)
            {
                if(trans.parent.parent == null) { return; }
                if(trans.parent.parent.GetChild(i).childCount!=0)
                {
                    serchNum = i;
                }
            }
            
            if (serchNum == parentNum)
            {
                // 親のリストをリセット
                shadowManager.hitShadowMain.Clear();
            }
        }
        // 当たっている影の根分繰り返す
        for(int i = 0; i < hitObjs.Count; i++)
        {
            // 当たった影のマネージャーを登録する
            shadowManager.SetHitShadowMain(hitObjs[i]);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!isActive) { return; }
        // タグが影の物であれば
        if (other.gameObject.CompareTag("Shadow"))
        {
            // そのオブジェクトを登録
            for (int i = 0; i < hitShadows.Count; i++)
            {
                if (hitShadows[i] == other.gameObject)
                {
                    return;
                }
            }
            hitShadows.Add(other.gameObject);

            this.SetHitShadow(other);
        }
    }

    private void OnTriggerStay(Collider other)
    {
        // プレイヤーがヒットすれば
        if (other.gameObject.CompareTag("Player"))
        {
            // マネージャーがなければ抜ける
            if (shadowManager == null) { return; }
            // そもそもプレイヤーが影状態なら抜ける
            if (shadowManager.shadowModeSqript.isShadow) { return; }
            // 当たっている影を登録
            this.SetHitChild();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (!isActive) { return; }
        // 影のオブジェクトなら
        if (other.gameObject.CompareTag("Shadow"))
        {
            for(int i = 0;i<hitShadows.Count;i++)
            {
                if(hitShadows[i] == other.gameObject)
                {
                // 当たっている影のオブジェクトを解除
                    hitShadows[i] = hitShadows[hitShadows.Count-1];
                    hitShadows.RemoveAt(hitShadows.Count - 1);
                }
            }
        }
        // そもそも伸びている状態ならここで切る
        if (shadowManager.mainSqript.GetExtendFg())
        {
            return;
        }
        // 伸びていなくて、離れたのがプレイヤーなら
        if (other != null && other.gameObject.CompareTag("Player"))
        {
            this.RemoveHitChild();
        }
    }

    /// <summary>
    /// アクティブ状態を変化させる。
    /// </summary>
    /// <param name="_fg">状態</param>
    private void SetActive(bool _fg)
    {
        // アクティブ状態をセット
        isActive = _fg;
        col.enabled = _fg; 

        // フラグの状態に応じて、追加処理を行う
        if(_fg)
        {

            if (shadowManager.mainSqript.GetEnemyType() == ShadowMain.E_ENEMY_TYPE.Barrir)
            {
                barrirEffect.gameObject.SetActive(true);
                isBarrir = true;
            }
        }
        // 非アクティブにした時
        else
        {
            
            // 当たっている影のリストを全排除
            hitShadows.Clear();
            //effect.SendEvent("Stop");
            effect1.gameObject.SetActive(false);
            effect2.gameObject.SetActive(false);
            barrirEffect.gameObject.SetActive(false);
            powerEffect1.gameObject.SetActive(false);
            powerEffect2.gameObject.SetActive(false);

            mesh.material.color = Color.black;
        }
    }

    /// <summary>
    /// 親の情報を取得する
    /// </summary>
    private void SetParent()
    {
        // 親がいれば
        if (par != trans.parent.parent||par == null)
        {
            // 親の親を取得
            par = trans.parent.parent;
            if (par == null)
            {
                if (isActive)
                {
                    this.SetActive(false);
                }
                return;
            }
            // 親のオブジェクトを登録
            parObj = par.gameObject;
            // 親の持つ影用マネージャーがなければ登録
            if (shadowManager == null)
            {
                //Debug.Log("ここ何回通る？");
                shadowManager = parObj.GetComponent<ShadowManager>();
                // マネージャーが存在したとき
                if (shadowManager != null)
                {
                    // Transformを保存し、このオブジェクトをアクティブ状態にする。
                    managerTrans = shadowManager.transform;
                    this.SetActive(true);
                }
                else
                {
                    if (isActive)
                    {
                        // 非アクティブ状態を維持
                        this.SetActive(false);
                    }
                }
            }
            // マネージャーがあった時
            else
            {
                // 親の親の情報がマネージャーと同じならアクティブ
                // 異なれば非アクティブをセット
                this.SetActive(managerTrans == par);
            }
        }
    }

    /// <summary>
    /// 当たっている影と、そのマネージャーを整理する。
    /// </summary>
    private void AdjustHits()
    {
        // 当たっている影の根を逆から繰り返す
        for (int i = hitObjs.Count - 1; i >= 0; i--)
        {
            // アクティブ状態保存
            bool sarch = false;
            // 当たっている影分繰り返す
            for (int j = hitShadows.Count - 1; j >= 0; j--)
            {
                // 親の親を取得
                Transform grandPar = hitShadows[j].transform.parent.parent;
                // いなければ、そもそも相手がアクティブ状態ではない為外す。
                if (grandPar == null)
                {
                    hitShadows.RemoveAt(j);
                    continue;
                }
                // 根が同じもののみ判定
                if (grandPar.gameObject == hitObjs[i])
                {
                    // アクティブ状態のものが一つでもあればヒット
                    sarch = true;
                    break;
                }
            }
            // アクティブ状態でなければ
            if (!sarch)
            {
                hitObjs.RemoveAt(i);
            }
        }
    }

    private void SetHitShadow(Collider other)
    {
        if (other == null) { return; }  
        // 親の親を取得
        Transform grandPar = other.transform.parent.parent;
        if(grandPar == null) return;

        // 自分の親と同じならヒットなしとする
        if (grandPar ==managerTrans)
        {
            return;
        }
        // 既にヒットしている影の根分繰り返す
        for (int i = 0; i<hitObjs.Count;i++)
        {
            // 同じものがあればヒットなしとして抜ける
            if (hitObjs[i] == grandPar.gameObject)
            {
                return;
            }
        }
        // 当たっていれば影の根オブジェクトを追加
        hitObjs.Add(grandPar.gameObject);

    }

    private void SetHitChild()
    {
        // どの影オブジェにも当たっていないか、自身が一番手前なら
        if ((shadowManager.hitchild == null || shadowManager.hitchild.transform.GetSiblingIndex() > trans.GetSiblingIndex()))
        {
            // 自身が一番前なら
            if (trans.GetSiblingIndex() <= shadowManager.GetExtendAbleNum()
                || shadowManager.mainSqript.GetLightOn())
            {
                // 当たっている影のオブジェクトを自身に切り替える
                shadowManager.hitchild = this.gameObject;
            }
            // 手前の影として保存する
            shadowManager.hitStartShadow = this.gameObject;
        }
    }
    private void RemoveHitChild()
    {
        // ヒット履歴がある場合
        if (shadowManager.hitStartShadow != null)
        {
            // ヒット履歴が自身であれば
            if (shadowManager.hitStartShadow == this.gameObject)
            {
                // ヒット履歴を消す
                shadowManager.hitStartShadow = null;
            }
        }
        if (shadowManager.hitchild != null)
        {
            // ヒット履歴が自身であれば
            if (shadowManager.hitchild == this.gameObject)
            {
                // ヒット履歴を消す
                shadowManager.hitchild = null;
            }
        }
    }
    /// <summary>
    /// 炎の発生を管理する関数
    /// </summary>
    void PlayFire()
    {
        // 親の番号を取得
        int parNum = trans.parent.GetSiblingIndex();
        // マネージャー上の、炎管理スクリプトが起動状態にあるかをチェック
        // 無ければ念のためこの影が燃えていない状態にし、処理を終了
        if(shadowManager.mainSqript.GetFireCon(parNum).GetFireState()==FireController.FIRE_STATE.NOFIRE)
        {

            if (!shadowManager.mainSqript.GetExtendFg() && trans.GetSiblingIndex() <= shadowManager.GetExtendAbleNum())
            {
                mesh.material.color = Color.blue;
            }
            else
            {
                mesh.material.color = Color.black;
            }
            if(effect1.gameObject.activeSelf)
            {
                effect1.gameObject.SetActive(false);
                effect2.gameObject.SetActive(false);
                powerEffect1.gameObject.SetActive(false);
                powerEffect2.gameObject.SetActive(false);
            }
            passFire = false;
            return;
        }
        if (isBarrir&&shadowManager.mainSqript.GetFireCon(parNum).powerUp)
        {
            if (shadowManager.mainSqript.GetEnemyType() == ShadowMain.E_ENEMY_TYPE.Barrir)
            {
                barrirEffect.gameObject.SetActive(false);
                isBarrir = false;
            }
        }
        // 既に燃えていれば抜ける
        if(passFire)
        {
            //effect.SetVector3("NowPosition", trans.position);
            //effect.SetVector3("OldPosition", oldPos);
            return;
        }
        // このオブジェクトが、炎管理スクリプトの広がった範囲内にいた場合
        if(trans.GetSiblingIndex()>=shadowManager.mainSqript.GetFireCon(parNum).GetFireRoad() 
            && shadowManager.mainSqript.GetFireCon(parNum).GetFireState() == FireController.FIRE_STATE.OUT_IN_FIRE)
        {
            BackFireShadow(parNum);
            return;
        }
        if (trans.GetSiblingIndex() <= shadowManager.mainSqript.GetFireCon(parNum).GetFireRoad()
            && shadowManager.mainSqript.GetFireCon(parNum).GetFireState() == FireController.FIRE_STATE.IN_OUT_FIRE)
        {
            ForeFireShadow(parNum);
            return;
        }
    }

    private void BackFireShadow(int _parNum)
    {
        // 炎が通った状態にする
        passFire = true;
        if (shadowManager.mainSqript.GetFireCon(_parNum).powerUp)
        {
            //effect1.SetFloat("Size", 15);
            //effect2.SetFloat("Size", 12);
            powerEffect1.gameObject.SetActive(true);
            powerEffect2.gameObject.SetActive(true);
            powerEffect1.SendEvent("Play");
            powerEffect2.SendEvent("Play");
        }
        else
        {
            //effect1.SetFloat("Size", 9);
            //effect2.SetFloat("Size", 7);
            effect1.gameObject.SetActive(true);
            effect2.gameObject.SetActive(true);
            effect1.SendEvent("Play");
            effect2.SendEvent("Play");
        }
        // デバッグ用にコライダーマテリアル色を赤にする。
        // エフェクトが完成すれば、ここで実行しましょう。
        mesh.material.color = Color.red;


        if (!shadowManager.mainSqript.GetFireCon(_parNum).powerUp)
        {
            if (shadowManager.mainSqript.CheckHitPowerUp(trans))
            {
                shadowManager.mainSqript.GetFireCon(_parNum).powerUp = true;
                shadowManager.barrirBreak = true;
                mesh.material.color = Color.yellow;
            }
        }
        else
        {
            mesh.material.color = Color.yellow;
        }


        // 当たっている影分繰り返す
        for (int i = 0; i < hitShadows.Count; i++)
        {
            // 当たっている影の親の親を取得
            Transform grandPar = hitShadows[i].transform.parent.parent;
            // いなかったり自身と同じなら
            if (grandPar == managerTrans || grandPar == null)
            {
                //処理せずに次の影へ
                continue;
            }

            // 影がマネージャー内の何番目に登録されているか。
            int fireConNum = hitShadows[i].transform.parent.GetSiblingIndex();
            if(fireConNum > 3) { continue; }
            // マネーシャーを取得
            ShadowManager manage = grandPar.GetComponent<ShadowManager>();
            // 既に燃えていれば
            if (manage.mainSqript.GetFireCon(fireConNum).GetFire())
            {
                // 処理せずに次の影へ
                continue;
            }
            if(!shadowManager.mainSqript.GetFireCon(_parNum).powerUp&& manage.mainSqript.GetEnemyType() == ShadowMain.E_ENEMY_TYPE.Barrir)
            {
                shadowManager.mainSqript.GetFireCon(_parNum).StopFire(trans.GetSiblingIndex());
                shadowManager.fireEnd = true;
                manage.fireEnd = true;
                break;
            }
            // 残りの影連鎖時間
            int fireRemain = shadowManager.mainSqript.GetFireCon(_parNum).GetFireRemain();
            // 連鎖開始影の番号
            int shadowNum = hitShadows[i].transform.GetSiblingIndex();
            // 炎の強化フラグ
            bool powerUp = shadowManager.mainSqript.GetFireCon(_parNum).powerUp;
            // 影の連鎖を設定
            manage.mainSqript.GetFireCon(fireConNum).ChainSetting(fireRemain, shadowNum, powerUp);
        }
    }

    private void ForeFireShadow(int _parNum)
    {
        //if(trans.GetSiblingIndex() != _parNum) { return; }
        // 炎が通った状態にする
        passFire = true;
        if (shadowManager.mainSqript.GetFireCon(_parNum).powerUp)
        {
            //effect1.SetFloat("Size", 15);
            //effect2.SetFloat("Size", 12);
            powerEffect1.gameObject.SetActive(true);
            powerEffect2.gameObject.SetActive(true);
            powerEffect1.SendEvent("Play");
            powerEffect2.SendEvent("Play");
        }
        else
        {
            //effect1.SetFloat("Size", 9);
            //effect2.SetFloat("Size", 7);
            effect1.gameObject.SetActive(true);
            effect2.gameObject.SetActive(true);
            effect1.SendEvent("Play");
            effect2.SendEvent("Play");
        }
        // デバッグ用にコライダーマテリアル色を赤にする。
        // エフェクトが完成すれば、ここで実行しましょう。
        mesh.material.color = Color.red;

        if (!shadowManager.mainSqript.GetFireCon(_parNum).powerUp)
        {
            if (shadowManager.mainSqript.CheckHitPowerUp(trans))
            {
                shadowManager.mainSqript.GetFireCon(_parNum).powerUp = true;
                shadowManager.barrirBreak = true;
                mesh.material.color = Color.yellow;
            }
        }
        else
        {
            mesh.material.color = Color.yellow;
        }


        // 当たっている影分繰り返す
        for (int i = 0; i < hitShadows.Count; i++)
        {
            // 当たっている影の親の親を取得
            Transform grandPar = hitShadows[i].transform.parent.parent;
            // いなかったり自身と同じなら
            if (grandPar == managerTrans || grandPar == null)
            {
                //処理せずに次の影へ
                continue;
            }

            // マネーシャーを取得
            ShadowManager manage = grandPar.GetComponent<ShadowManager>();
            // 既にも得ていれば
            if (manage.mainSqript.GetFireCon(_parNum).GetFire())
            {
                // 処理せずに次の影へ
                continue;
            }
            // 影がマネージャー内の何番目に登録されているか。
            int fireConNum = hitShadows[i].transform.parent.GetSiblingIndex();
            // 残りの影連鎖時間
            int fireRemain = shadowManager.mainSqript.GetFireCon(_parNum).GetFireRemain();
            // 連鎖開始影の番号
            int shadowNum = hitShadows[i].transform.GetSiblingIndex();
            // 炎の強化フラグ
            bool powerUp = shadowManager.mainSqript.GetFireCon(_parNum).powerUp;
            // 影の連鎖を設定
            manage.mainSqript.GetFireCon(fireConNum).ChainSetting(fireRemain, shadowNum, powerUp);
        }
    }

    private void OnApplicationQuit()
    {
        hitObjs.Clear();
        hitShadows.Clear();
    }
}
