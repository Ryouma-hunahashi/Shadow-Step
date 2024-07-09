using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player_Main : MonoBehaviour
{
#if UNITY_EDITOR

    [System.Serializable]
    private struct S_RayView
    {
        public bool All;        // 全て表示
        public bool Forward;    // 前方
        public bool Backward;   // 後方
        public bool Left;       // 左側
        public bool Right;      // 右側
    };

    [Header("レイの描画設定")]
    [SerializeField] private S_RayView m_RayView;

#endif

    /* １方向レイの構造体 */
    [System.Serializable]
    private struct S_Ray
    {
        public float Distance;
        public RaycastHit Info;
        public bool Hit;
    }

    /* 各方向用レイの構造体 */
    [System.Serializable]
    private struct S_RaySetting
    {
        public S_Ray Forward;
        public S_Ray Backward;
        public S_Ray Left;
        public S_Ray Right;
    }

    [Header("レイの設定")]
    [SerializeField] private S_RaySetting m_Ray;

    /* 追加コンポーネント */
    private Rigidbody m_Rigidbody;
    private ControlManager m_ControlManager;
    private PlayerShadowMode m_ShadowMode;

    [System.Serializable]
    private struct S_MovementSetting
    {
        // デッドゾーンの設定
        [Range(0.0f, 1.0f)] public float DeadZone;
        public float Speed;     // 移動速度
        public float FootSteps; // 足音
    }

    [Header("スティック設定")]
    [Tooltip("傾きによって設定変化")]
    [SerializeField] private S_MovementSetting[] m_Movement;
    [Tooltip("通常移動でのスティックの傾きを可視化")]
    [SerializeField, Range(0f, 1f)] float m_StickTilt;

    [Header("キーボード設定")]
    [SerializeField, Tooltip("影掴みのキー設定")]
    private ControlManager.E_KB m_GrabShadowKey;
    [SerializeField, Tooltip("ダッシュキー設定")]
    private ControlManager.E_KB m_SprintKey;

    [System.Serializable]
    private struct S_HoldShadowSetting
    {
        // デッドゾーンの設定
        [Range(0.0f, 1.0f)] public float Deadzone;

        // 左右どちらを使うか
        [Tooltip("Left：LT　Right：RT")]
        public ControlManager.E_DIRECTION Direction;
    }

    [Header("トリガー設定")]
    [SerializeField] private S_HoldShadowSetting m_HoldShadow;

    [System.Serializable]
    private struct S_HoldShadowSpeed
    {
        [Range(0.0f, 1.0f)]
        public float Ratio;     // 比率
        public float Decrease;  // 減少値
    }

    [Header("影の詳細設定")]
    [SerializeField] private float m_ShadowMinSpeed;    // 影保持状態の最小速度
    [SerializeField] private float m_ShadowDefSpeed;    // 影保持状態の通常速度
    private float m_ShadowValSpeed;                     // 影保持状態の変動速度

    // 影保持状態のデッドゾーンの設定
    [SerializeField, Range(0.0f, 1.0f)] private float m_ShadowDeadzone;

    // 影保持状態の速度設定
    [SerializeField] private S_HoldShadowSpeed[] m_ShadowSpeed;

    [Tooltip("影保持状態での速度の比率を可視化")]
    [SerializeField, Range(0.0f, 1.0f)] private float m_ShadowSpeedRatio;

    /* 正面オブジェクトの設定 */
    private GameObject m_FrontObject;               // オブジェクト本体
    private const float m_MagDistToFrontObj = 1;    // 距離を離す倍率
    //private float m_DistToFrontObj;               // オブジェクトとの距離

    /* 足音判定用オブジェクトの設定 */
    private GameObject m_FootStepsObj;
    private SphereCollider m_FootSteps;

    private Animator m_Animator;
    private ParticleSystem m_footParticle;

    /* 各種状態の設定 */
    private bool isHold;    // 影掴み状態
    private bool isStop;    // 操作停止状態

    private int runSENum = 0;

    public bool GetHoldStatus() { return isHold; }

    /* 操作可能にする処理 */
    public void MovementStart() {m_Animator.enabled = true; isStop = false; }

    /* 速度を０にして操作を不可にする */
    public void MovementStop() { m_Rigidbody.velocity = Vector3.zero; m_Animator.enabled = false; isStop = true; }

    /* 通常開始処理 */
    private void Start()
    {
        // 停止状態を解除する
        isStop = false;

        // 影保持状態の速度を初期状態にする
        m_ShadowValSpeed = m_ShadowDefSpeed;

        // 正面オブジェクト作成処理
        m_FrontObject = CreateEmptyObject("Dir_Object", true);

        // 足音判定オブジェクト作成処理
        m_FootStepsObj = CreateEmptyObject("FootSteps_Obj", true);
        m_FootStepsObj.AddComponent<SphereCollider>();                      // 当たり判定の追加
        m_FootStepsObj.GetComponent<SphereCollider>().isTrigger = true;     // 当たり判定をトリガー化
        m_FootStepsObj.AddComponent<PlayerFootSteps>();                     // 判定の処理を追加
        m_FootSteps = m_FootStepsObj.GetComponent<SphereCollider>();       // 判定処理を格納
        m_FootStepsObj.transform.parent = transform.parent;

        /* コンポーネント追加 */
        m_Rigidbody = GetComponent<Rigidbody>();
        m_ControlManager = GetComponent<ControlManager>();
        m_ShadowMode = GetComponent<PlayerShadowMode>();
        m_Animator = GetComponent<Animator>();
        m_footParticle = transform.GetChild(3).GetComponent<ParticleSystem>();

        /* 段階速度の設定ログ */
        for(int i = 0; i < m_Movement.Length; i++)
        {
            if(m_Movement[i].Speed <= 0)
            {
                Debug.Log(this.name + "：" + (i + 1) + "段階目の速度が正しく設定されていません");
            }
        }
    }

    private void FixedUpdate()
    {
        if(m_ControlManager.GetVariousInput(ControlManager.E_TYPE.PRESSED, ControlManager.E_KB.ESCAPE))
        {
            if(S_Manager.instance!=null)
            {
                S_Manager.instance.SceneChange("StageSelect");
            }
        }
        //Debug.Log("プレイヤーRb:" + m_Rigidbody.velocity);
        if(m_ShadowMode.goFire||m_ShadowMode.isPause)
        {
            m_Animator.SetBool("running", false);
            m_Rigidbody.velocity = Vector3.zero;
            return;
        }
        // レイの更新処理
        UpdateRayState();

        // 影の保持遷移更新
        HoldShadowControl();

        // 正面オブジェクト処理
        MoveFrontObject();

        if (isStop) return;

        /* プレイヤーの操作処理 */
        MoveTargetLocation();
        RotateTargetLocation(m_FrontObject);
    }

    /* レイの状態更新処理 */
    private void UpdateRayState()
    {
        // 自身の位置情報
        Vector3 origin = this.transform.position;

        /* 自身の前方と右側を取得する */
        Vector3 dirForward = this.transform.forward;
        Vector3 dirRight = this.transform.right;

        /* 自身のレイの衝突状態を変数に送る */
        m_Ray.Forward.Hit = Physics.Raycast(origin, dirForward, out m_Ray.Forward.Info, m_Ray.Forward.Distance);
        m_Ray.Backward.Hit = Physics.Raycast(origin, -dirForward, out m_Ray.Backward.Info, m_Ray.Backward.Distance);
        m_Ray.Left.Hit = Physics.Raycast(origin, -dirRight, out m_Ray.Left.Info, m_Ray.Left.Distance);
        m_Ray.Right.Hit = Physics.Raycast(origin, dirRight, out m_Ray.Right.Info, m_Ray.Right.Distance);

#if UNITY_EDITOR

        /* 全てのレイを表示するなら */
        if (m_RayView.All)
        {
            /* 表示状態にする */
            m_RayView.Forward = true;
            m_RayView.Backward = true;
            m_RayView.Left = true;
            m_RayView.Right = true;
        }

        /* レイ衝突のログ */
        if (m_RayView.Forward && m_Ray.Forward.Hit) Debug.Log(this.name + "の前方に何かあります");
        if (m_RayView.Backward && m_Ray.Backward.Hit) Debug.Log(this.name + "の後方に何かあります");
        if (m_RayView.Left && m_Ray.Left.Hit) Debug.Log(this.name + "の左側になにかあります");
        if (m_RayView.Right && m_Ray.Right.Hit) Debug.Log(this.name + "の右側になにかあります");

        /* レイの描画処理 */
        if (m_RayView.Forward) Debug.DrawRay(origin, dirForward * m_Ray.Forward.Distance, Color.red);
        if (m_RayView.Backward) Debug.DrawRay(origin, -dirForward * m_Ray.Backward.Distance, Color.blue);
        if (m_RayView.Left) Debug.DrawRay(origin, -dirRight * m_Ray.Left.Distance, Color.yellow);
        if (m_RayView.Right) Debug.DrawRay(origin, dirRight * m_Ray.Right.Distance, Color.green);

#endif

    }

    /* 自身を正面オブジェクトの方向へ移動させる */
    private void MoveTargetLocation()
    {
        // 速度をゼロにする
        m_Rigidbody.velocity = Vector3.zero;

        // 足音判定をゼロにする
        float nowRadius = m_FootSteps.radius;
        m_FootSteps.radius = 0;

        m_Animator.SetBool("running", false);
        /* スティックが傾いていないなら処理を抜ける */
        if (m_StickTilt == 0)
        {
            return;
        }

        /* 影を掴んでいる状態のとき */
        if (isHold)
        {
            //m_Animator.SetFloat("runMode", 1.0f);
            for(int i = 0; i < m_ShadowSpeed.Length; i++)
            {
                /* 後でかなり改変するからコメント待ってな */
                if(m_ShadowSpeed[i].Ratio >= m_ShadowSpeedRatio)
                {
                    if (m_StickTilt >= m_ShadowDeadzone)
                    {
                        m_Animator.SetBool("running", true);
                        // 前方へ速度に合わせて加速させる
                        m_Rigidbody.velocity = transform.forward * m_ShadowValSpeed;

                        m_ShadowValSpeed -= m_ShadowSpeed[i].Decrease;

                        if (m_ShadowValSpeed <= m_ShadowMinSpeed) m_ShadowValSpeed = m_ShadowMinSpeed;
                    }
                }
            }
            m_Animator.SetFloat("runMode", m_ShadowValSpeed / m_ShadowDefSpeed);
            
            if (m_ShadowValSpeed > 0 && m_ShadowValSpeed <= m_Movement[0].Speed)
            {
                if (!SoundManager.Get().GeIsPlaySE3D(runSENum, E_SE_TYPE.PL_FAST_WALK))
                {
                    runSENum = SoundManager.Get().PlaySE3D(E_SE_TYPE.PL_FAST_WALK, transform);
                }
            }
            else if (m_ShadowValSpeed <= m_Movement[1].Speed)
            {
                if (!SoundManager.Get().GeIsPlaySE3D(runSENum, E_SE_TYPE.PL_WALK))
                {
                    runSENum = SoundManager.Get().PlaySE3D(E_SE_TYPE.PL_WALK, transform);
                }
            }
            else
            {
                if (!SoundManager.Get().GeIsPlaySE3D(runSENum, E_SE_TYPE.PL_RUN))
                {
                    runSENum = SoundManager.Get().PlaySE3D(E_SE_TYPE.PL_RUN, transform);
                }
            }
        }
        else
        {
            // 影保持状態の速度を初期状態に戻す
            m_ShadowValSpeed = m_ShadowDefSpeed;

            E_SE_TYPE footSE = E_SE_TYPE.PL_FAST_WALK;

            for (int i = 0; i < m_Movement.Length; i++)
            {
                if (m_StickTilt >= m_Movement[i].DeadZone)
                {
                    m_Animator.SetBool("running", true);
                    m_Animator.SetFloat("runMode", m_Movement[i].DeadZone);
                    if(i!=0)
                    {
                        footSE++;
                    }

                    // 前方へ速度に合わせて加速させる
                    m_Rigidbody.velocity = transform.forward * m_Movement[i].Speed;

                    m_FootSteps.radius = m_Movement[i].FootSteps;
                }
            }
            if (m_FootSteps.radius > 0)
            {
                if (m_footParticle.isPlaying&&nowRadius != m_FootSteps.radius)
                {
                    m_footParticle.Simulate(0, true, true, true);
                }
                else if (!m_footParticle.isPlaying)
                {
                    m_footParticle.startSpeed = m_FootSteps.radius * m_FootStepsObj.transform.lossyScale.x;
                    m_footParticle.Play();
                }
                if(!SoundManager.Get().GeIsPlaySE3D(runSENum,footSE))
                {
                    runSENum = SoundManager.Get().PlaySE3D(footSE, transform);
                }
            }
            else
            {
                // 足音止める
            }
        }
        /* 影保持状態の速度値を変動させる */
        m_ShadowSpeedRatio = (m_ShadowMinSpeed - m_ShadowValSpeed) / (m_ShadowMinSpeed - m_ShadowDefSpeed);
    }

    /* 自身の向きを正面オブジェクトへ */
    private void RotateTargetLocation(GameObject _obj)
    {
        /* スティックが非入力状態なら処理を抜ける */
        if (m_ControlManager.GetConnect() && m_ControlManager.GetStickValue(ControlManager.E_DIRECTION.LEFT) == Vector2.zero) return;

        /* ゲームパッドが接続されていない時の処理抜け */
        if (!m_ControlManager.GetConnect() &&
            !m_ControlManager.GetHoldPress(ControlManager.E_KB.W) &&
            !m_ControlManager.GetHoldPress(ControlManager.E_KB.A) &&
            !m_ControlManager.GetHoldPress(ControlManager.E_KB.S) &&
            !m_ControlManager.GetHoldPress(ControlManager.E_KB.D)) return;

        /* 速度がゼロなら処理を抜ける */
        if (m_Rigidbody.velocity == Vector3.zero) return;

        // 目標地点への方向を算出する
        Vector3 direction = (_obj.transform.position - transform.position).normalized;
        direction.y = 0;

        // 回転方向を組み込む
        Quaternion targetRotate = Quaternion.LookRotation(direction);

        // 指定の方向に向かって回転
        transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotate, 360f);
    }

    /* 空オブジェクトを作成する処理 */
    private GameObject CreateEmptyObject(string _name = "Empty_Name", bool _child = false)
    {
        /* 空オブジェクトの作成 */
        GameObject emp;
        emp = GameObject.CreatePrimitive(PrimitiveType.Cube);
        if (_child) emp.transform.parent = this.transform;

        /* オブジェクト設定の変更 */
        emp.name = _name;
        emp.transform.localPosition = Vector3.zero;
        emp.transform.localScale = Vector3.one;

        /* コンポーネントを削除する */
        DestroyImmediate(emp.GetComponent<Renderer>());
        DestroyImmediate(emp.GetComponent<MeshFilter>());
        DestroyImmediate(emp.GetComponent<BoxCollider>());

        return emp;
    }

    /* 移動入力中に専用オブジェクトを動かす */
    private void MoveFrontObject()
    {
        Vector3 movePoint = new Vector3(0.0f, 0.0f, 0.0f);

        /* スティックの移動状態を反映する */
        movePoint.x = (float)m_ControlManager.GetStickValue(ControlManager.E_DIRECTION.LEFT, ControlManager.E_COORDINATE.HORIZONTAL);
        movePoint.z = (float)m_ControlManager.GetStickValue(ControlManager.E_DIRECTION.LEFT, ControlManager.E_COORDINATE.VERTICAL);

        /* ゲームパッドが接続されていない時 */
        if(!m_ControlManager.GetConnect())
        {
            bool sprint = m_ControlManager.GetHoldPress(m_SprintKey);

            /* キーボードでの操作を実行する */
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.W)) movePoint.z = m_Movement[0].DeadZone;
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.A)) movePoint.x = -m_Movement[0].DeadZone;
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.S)) movePoint.z = -m_Movement[0].DeadZone;
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.D)) movePoint.x = m_Movement[0].DeadZone;

            /* 影を掴んでいるときは最大値を与える */
            if (isHold && movePoint.x > 0) movePoint.x = m_Movement[m_Movement.Length - 1].DeadZone;
            if (isHold && movePoint.x < 0) movePoint.x = -m_Movement[m_Movement.Length - 1].DeadZone;
            if (isHold && movePoint.z > 0) movePoint.z = m_Movement[m_Movement.Length - 1].DeadZone;
            if (isHold && movePoint.z < 0) movePoint.z = -m_Movement[m_Movement.Length - 1].DeadZone;

            /* スプリントキーを入力しているとき最大値を返す */
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.W) && sprint) movePoint.z = m_Movement[m_Movement.Length - 1].DeadZone;
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.A) && sprint) movePoint.x = -m_Movement[m_Movement.Length - 1].DeadZone;
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.S) && sprint) movePoint.z = -m_Movement[m_Movement.Length - 1].DeadZone;
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.D) && sprint) movePoint.x = m_Movement[m_Movement.Length - 1].DeadZone;
        }

        // 移動地点に倍率を含める
        movePoint *= m_MagDistToFrontObj;

        // スティック入力値と自身の位置から正面を算出する
        m_FrontObject.transform.position = movePoint + transform.position;

        // 正面オブジェクトと自身の距離を算出する
        //m_DistToFrontObj = (m_FrontObject.transform.position - transform.position).sqrMagnitude;

        // 現在の正面オブジェクトとの距離を正規化する
        m_StickTilt = movePoint.magnitude;//m_DistToFrontObj / (m_MagDistToFrontObj * m_MagDistToFrontObj);
    }

    /* 影保持遷移処理 */
    private void HoldShadowControl()
    {
        /* 影が触れているとき */
        if (m_ShadowMode.shadowHit||m_ShadowMode.isLSwitchHit)
        {
            /* トリガーが押されているなら影を掴む */
            isHold = m_ControlManager.GetTriggerSqueeze(m_HoldShadow.Direction, m_HoldShadow.Deadzone);
            if (!m_ControlManager.GetConnect()) isHold = m_ControlManager.GetHoldPress(m_GrabShadowKey);
            m_ShadowMode.SetShadow(isHold);
        }
        else
        {
            /* 掴みが持続しているならキャンセルする */
            if(isHold) isHold = false;
        }
    }
}
