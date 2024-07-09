using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Enemy_Main : MonoBehaviour
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

    /* 追跡状態の列挙体 */
    [System.Serializable]
    public enum E_TRACKING
    {
        PATROL, // 巡回
        SHADOW, // 影
        PLAYER, // プレイヤー
    }

    public enum E_ANIM_ROTATE_PAT
    {
        RIGHT,
        LEFT,
        BACK,
    }

    [Header("プレイヤー追跡設定")]
    [SerializeField]
    private GameObject m_NavMeshObject;
    private RouteSearch m_RouteSearch;

    [Header("レイの設定")]
    [SerializeField] private S_RaySetting m_Ray;

    [SerializeField, Range(0, 360)] private float m_ViewFov;
    [SerializeField, Range(0, 360)] private float m_ViewRotation;
    [SerializeField] private float m_ViewDistance;

    [Header("巡回への移行設定")]
    [SerializeField, Tooltip("召喚速度")]
    private float m_RespawnSpeed;
    [SerializeField, Tooltip("消滅までの時間")]
    private float m_DespawnTime;
    private float m_DespawnCounter;

    /* 移行状態 */
    private bool isRespawn; // 出現待機
    private bool isDespawn; // 消滅待機

    // スポーン地点からの距離
    private float mUnderDistance;

    public bool GetIsDespawn() { return isDespawn; }

    [Header("移動速度の設定")]
    [SerializeField] private float m_NormalSpeed;   // 通常速度
    private float m_VariableSpeed;                  // 変動速度
    [SerializeField] private float m_ChaseSpeed;

    /* 司令からの倍率値を取得する */
    private float m_OperatorSpeedMag = 1.0f;
    public void SetOperatorSpeedMag(float _spd) { m_OperatorSpeedMag = _spd; }

    // 影の状態
    [SerializeField] private ShadowMain m_Shadow;

    private Rigidbody m_Rigidbody;
    private Animator m_Anim;

    /* 二次元配列用の構造体 */
    [System.Serializable]
    private struct BasePoint_Array
    {
        public GameObject BasePoint;
        public GameObject[] WayPoints;
    }

    [Header("移動地点の設定")]

    // 追跡状態の設定
    [SerializeField] 
    private E_TRACKING m_Tracking;
    private E_TRACKING m_TrackingLog;

    public void SetTracking(E_TRACKING _tra)
    {
        if(_tra == E_TRACKING.PLAYER) { m_Anim.Play("Kill");SoundManager.Get().PlaySE3D(E_SE_TYPE.EM_DISCOVERY, transform); }

        m_Tracking = _tra;
    }

    /* 移動ポイントオブジェクト */
    [SerializeField] private GameObject m_Player;       // プレイヤーオブジェクト
    [SerializeField] private GameObject m_CorePoint;    // ポイント群の基礎オブジェクト
    [SerializeField] private GameObject m_PatrolTarget; // 巡回している透明オブジェクト

    /* 複数のベースポイントにアクセスする変数 */
    [SerializeField] private BasePoint_Array[] m_BasePoints;

    /* 動的アクセス用の整数型：CP(CorePoint), BP(BasePoint) */
    private int m_DefChild_Core;    // 初期化時のCP子オブジェクトの数
    private int m_AddChild_Core;    // 動的な追加CP子オブジェクトの数
    private int[] m_DefChild_Base;  // 初期化時のBP子オブジェクトの数
    private int[] m_AddChild_Base;  // 動的な追加BP子オブジェクトの数

    /* 移動地点の詳細 */
    private int m_CurrentWayPointIndex; // ウェイポイントの指定値

    /* 足音が聞こえている時間 */
    private float m_FootStepsCounter = 0.0f;
    public void ResetFSCounter() { m_FootStepsCounter = 0.0f; }

    [SerializeField,Tooltip("足音の聞こえる時間")]
    private float m_HearTime;

    // 到着地点の許容範囲の設定
    [SerializeField] private float m_Tolerance = 0.1f;

    [Header("通常時の回転設定")]
    [Tooltip("通常時の回転時間")]
    [SerializeField] private float m_RotationTime;
    [Tooltip("通常回転時の速度")]
    [SerializeField] private float m_RotationSpeed;

    [Header("影掴み時の回転設定")]
    [Tooltip("影を掴んだ時の回転時間")]
    [SerializeField] private float m_ShadowGripRotTime;
    [Tooltip("影を掴んだ瞬間の回転速度")]
    [SerializeField] private float m_ShadowGripRotSpd;

    /* 使用ベースポイント番号 */
    private int m_Number;

    // 影が捉えられた瞬間の状態を取る
    private bool isCatchedMoment;

    // 回転単体状態を取得する
    private bool isWaitRotateState;


    // アニメーションに代入する回転のパターン値
    private E_ANIM_ROTATE_PAT rotatePat;
    private float m_AnimRotateBase;

    [Header("影モードプレイヤーに対する反応")]
    [Tooltip("前方影")]
    [SerializeField] private bool frontShadowChase = true;
    [Tooltip("視覚")]
    [SerializeField] protected bool visionChase = true;

    private void Awake()
    {
        Debug.Log("ポジション移動");
        m_NavMeshObject.transform.position = transform.position;
    }

    /* 通常開始処理 */
    private void Start()
    {
        m_Shadow = GetComponent<ShadowMain>();
        if(m_Player==null)
        {
            GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
            m_Player = objs[objs.Length-1];
            if (m_Player == null) Debug.LogError("ぷれいやーがいない");
        }

        AllPointSetUp();
        m_VariableSpeed = m_NormalSpeed;

        if(m_NavMeshObject != null)
        {
            m_RouteSearch = m_NavMeshObject.GetComponent<RouteSearch>();
        }
        //else
        //{
        //    m_NavMeshObject = CreateEmptyObject(transform.parent.name + "_Nav");
        //    m_NavMeshObject.transform.position = transform.position;
        //    m_NavMeshObject.AddComponent<RouteSearch>();

        //    m_RouteSearch = m_NavMeshObject.GetComponent<RouteSearch>();
        //    m_RouteSearch.Init(m_Player);
        //}

        m_Rigidbody = GetComponent<Rigidbody>();
        m_Anim = GetComponent<Animator>();

        /* 追跡状態関連のリセット */
        ResetFSCounter();
        m_Tracking = E_TRACKING.PATROL;

    }

    /* 通常更新処理 */
    private void Update()
    {
        //Debug.Log(m_Rigidbody.velocity);

        if (m_Shadow.shadowMode.goFire || m_Shadow.GetLightOn() && m_Shadow.extendSetting||m_Shadow.shadowMode.isPause)
        {
            m_Rigidbody.velocity = Vector3.zero;
            return;
        }

        // レイの情報を更新
        UpdateRayState();

        // 掴まれた影の情報を取得
        m_Number = m_Shadow.GetExtendNum();

        // 前方影の処理
        CatchedFrontShadow();
        if (isCatchedMoment)
        {
            // 前方影の処理
            CatchedFrontShadow();


            m_Anim.SetBool("catch", true);
            m_Anim.SetInteger("rotatePat", (int)CheckRotatePat(m_BasePoints[m_Number].WayPoints[0]));

            // 回転待機状態に移行する
            isWaitRotateState = true;

            isCatchedMoment = false;
        }

        /* 移動地点の再設定 */
        DynamicObtainCorePoint();
        DynamicObtainBasePoint();

        /* 速度を止めて回転する処理 */
        if(isWaitRotateState)
        {
            m_Rigidbody.velocity = Vector3.zero;

            /* 影が離されているとき */
            if (!m_Shadow.GetExtendFg())
            {
                isWaitRotateState = false;

                // アニメーションの回転処理を終了
                m_Anim.SetBool("rotateEnd", true);
                m_Anim.SetBool("catch", false);
                
                return;
            }

            // 指定のオブジェクトに向かって回転する処理
            RotateTargetLocation(m_BasePoints[m_Number].WayPoints[0], m_ShadowGripRotSpd, m_ShadowGripRotTime);

            /* 相手へのベクトルと自身の前方ベクトルを取得 */
            Vector3 direction = (m_BasePoints[m_Number].WayPoints[0].transform.position - transform.position).normalized;
            Vector3 forward = transform.forward;

            // 自身の前方ベクトルと相手方向の内積計算
            float dotProduct = Vector3.Dot(forward, direction);

            // 内積値から自身が相手の方向を向いているかを判定
            bool dirSafe = (dotProduct > 0.99f);

            // 判定を返す
            isWaitRotateState = !dirSafe;

            if (!isWaitRotateState)
            {
                m_Anim.SetBool("rotateEnd", true); 
                m_Anim.SetFloat("rotateBlend", 0.0f); 
            }

            return;
        }

        // 追跡状態の変更
        TrackingStateChanger();

        // 現追跡状況に応じた処理
        VariousTrackingProcesses();
    }

    /* 空オブジェクトを作成する処理 */
    //private GameObject CreateEmptyObject(string _name = "Empty_Name", bool _child = false)
    //{
    //    /* 空オブジェクトの作成 */
    //    GameObject emp;
    //    emp = GameObject.CreatePrimitive(PrimitiveType.Cube);
    //    if (_child) emp.transform.parent = this.transform;

    //    /* オブジェクト設定の変更 */
    //    emp.name = _name;
    //    emp.transform.localPosition = Vector3.zero;
    //    emp.transform.localScale = Vector3.one;

    //    /* コンポーネントを削除する */
    //    DestroyImmediate(emp.GetComponent<Renderer>());
    //    DestroyImmediate(emp.GetComponent<MeshFilter>());
    //    DestroyImmediate(emp.GetComponent<BoxCollider>());

    //    return emp;
    //}

    /* 指定されたオブジェクト方向へレイを飛ばす */
    public bool SkipOverRay(GameObject _obj)
    {
        // 自身の位置情報
        Vector3 originPos = this.transform.position;

        // 相手の位置情報
        Vector3 targetPos = _obj.transform.position;

        // 自身と相手の距離
        float distance = (targetPos - originPos).magnitude;

        // 相手がいる方向
        Vector3 direction = (targetPos - originPos).normalized;

        /* レイを作成する処理 */
        Ray ray = new Ray(originPos, direction);
        RaycastHit[] castHit = Physics.RaycastAll(ray, distance);

#if UNITY_EDITOR

        /* レイの表示と詳細ログ */
        Debug.DrawRay(ray.origin, ray.direction * distance, Color.cyan);
        Debug.Log("レイキャストのヒット数：" + castHit.Length);

#endif

        /* キャストのヒット数に合わせて処理する */
        for (int i = 0; i < castHit.Length; i++)
        {
            /* 壁が一度でも挟まったなら */
            if(castHit[i].collider.CompareTag("Wall")&&!castHit[i].collider.isTrigger)
            {
                ResetFSCounter();
                Debug.Log("WallHit");

                // 処理を抜ける
                return false;
            }
        }

        if(m_FootStepsCounter < m_HearTime)
        {
            m_FootStepsCounter += Time.deltaTime;
            return false;
        }

        return true;
    }

    /* 巡回オブジェクトに追従する */
    private void ChasePatrol()
    {
        /* 巡回オブジェクトの情報を取る */
        Enemy_Patrol ep = m_PatrolTarget.GetComponent<Enemy_Patrol>();

        /* 消滅時の処理 */
        if(isDespawn)
        {
            if (m_DespawnCounter < m_DespawnTime)
            {
                // これ以上追いかけないよう速度ゼロ
                m_Rigidbody.velocity = Vector3.zero;

                // 足音カウンターのリセット
                ResetFSCounter();

                // 消滅までのカウントアップ
                m_DespawnCounter += Time.deltaTime;
                Debug.Log("syometsu");
                return;
            }
            else
            {
                m_Anim.SetBool("catch", false);
                m_Anim.SetBool("diving", false);
                m_Anim.SetBool("running", true);
                m_DespawnCounter = 0;
                isDespawn = false;
            }
        }

        /* 出現時の処理 */
        if (isRespawn)
        {
            // スポーン地点の設定
            transform.position =
                new Vector3
                (
                    m_PatrolTarget.transform.position.x,
                    m_PatrolTarget.transform.position.y - mUnderDistance,
                    m_PatrolTarget.transform.position.z
                );

            // 足音カウンターのリセット
            ResetFSCounter();

            isRespawn = false;
        }
        if (ep.GetWayPointCount() == 1)
        {
            m_Anim.SetBool("running", false);

        }
        else
        {
            m_Anim.SetBool("running", true);

        }

        /* 自分のY座標が巡回オブジェ以下にある時 */
        if (transform.position.y < m_PatrolTarget.transform.position.y)
        {
            // 自分の向きを次のウェイポイントに向ける
            RotateTargetLocation(ep.GetNextWayPoint(), m_RotationSpeed, m_RotationTime);

            /* 自分の位置を巡回オブジェに合わせつつ上昇させる */
            transform.position =
                new Vector3
                (
                    m_PatrolTarget.transform.position.x,
                    transform.position.y + m_RespawnSpeed,
                    m_PatrolTarget.transform.position.z
                );
            //Debug.Log("上昇中");
            // 足音カウンターのリセット
            ResetFSCounter();

            return;
        }

        // 自分の向きを次のウェイポイントに向ける
        RotateTargetLocation(ep.GetNextWayPoint(), m_RotationSpeed, m_RotationTime);

        this.transform.position = m_PatrolTarget.transform.position;
        m_NavMeshObject.transform.position = transform.position;
    }

    /* 影オブジェクトに追従する */
    private void ChaseShadow()
    {
        if (!m_Player.GetComponent<Player_Main>().GetHoldStatus()) return;

        RotateTargetLocation(m_BasePoints[m_Number].WayPoints[0], m_RotationSpeed, m_RotationTime);
        ChaseWayPoint();
    }

    /* プレイヤーオブジェクトに追従する */
    private void ChasePlayer()
    {
        /* ナビメッシュが稼働しているなら */
        if(m_RouteSearch != null)
        {
            Debug.Log(this.name + "NavMeshでの追従");

            m_RouteSearch.SetSpeed(m_ChaseSpeed);
            m_RouteSearch.SetAngularSpeed(m_RotationSpeed * 15);
            m_RouteSearch.SetAcceleration(m_ChaseSpeed);

            m_RouteSearch.ChaseStart(m_Player);
            m_RouteSearch.RouteUpdate();

            //RotateTargetLocation(m_Player, m_RotationSpeed, m_RotationTime);
            transform.rotation = m_NavMeshObject.transform.rotation;
            transform.position = m_NavMeshObject.transform.position;
            m_Rigidbody.velocity = Vector3.zero;

            return;
        }
        else
        {
            Debug.Log(this.name + "直線間での追従");

            RotateTargetLocation(m_Player, m_RotationSpeed, m_RotationTime);
            MoveTargetLocation(m_Player);

            return;
        }
    }

    /* 追跡状態の変更処理 */
    private void TrackingStateChanger()
    {
        /* プレイヤー追従中なら処理を抜ける */
        if (m_Tracking == E_TRACKING.PLAYER)
        {
            Player_Main pm = m_Player.GetComponent<Player_Main>();
            pm.MovementStop();

            return;
        }

        /* 巡回状態に変更する処理 */
        m_Tracking = E_TRACKING.PATROL;

        /* 巡回状態の直前状態が影追跡状態だったなら */
        if((m_Tracking == E_TRACKING.PATROL) &&(m_TrackingLog == E_TRACKING.SHADOW)
            )
        {
            Debug.Log("追跡状態[ 影 ] -> 巡回状態");

            isRespawn = true;
            isDespawn = true;
            //m_Anim.SetBool("rotateStart", false);
            //m_Anim.SetBool("rotateEnd", false);
            SoundManager.Get().PlaySE3D(E_SE_TYPE.EM_WARP, transform);
            m_Anim.SetBool("running", false);
            m_Anim.SetBool("diving", true);
        }

        /* 影追状態に変更する処理 */
        if (m_Shadow.GetExtendFg())
        {
            m_Tracking = E_TRACKING.SHADOW;

            if ((m_Tracking == E_TRACKING.SHADOW) && (m_TrackingLog == E_TRACKING.PATROL))
            {
                Debug.Log("巡回状態 -> 追跡状態[ 影 ]");
                m_CurrentWayPointIndex = 0;
            }

            /* 影追状態に入った瞬間の処理 */
            if (m_TrackingLog != m_Tracking)
            {
                isCatchedMoment = true;
            }
        }

        /* 追跡状態に変更する処理 */
        if (CheckFanOverlap(m_Player))
        {
            /* 途中に壁を挟んでいるかの判定 */
            if(SkipOverRay(m_Player))
            {
                m_Tracking = E_TRACKING.PLAYER;

                m_Anim.Play("Kill");
                SoundManager.Get().PlaySE3D(E_SE_TYPE.EM_DISCOVERY, transform);

                Player_Main pm = m_Player.GetComponent<Player_Main>();
                pm.MovementStop();

                Debug.Log(m_Player.name + "が" + this.name + "に発見されました");
            }
        }

        // 追跡状態をログに残す
        m_TrackingLog = m_Tracking;
    }

    /* 扇状の当たり判定 */
    private bool CheckFanOverlap(GameObject _obj)
    {
        /* 影追跡状態なら処理を抜ける */
        if(m_TrackingLog == E_TRACKING.SHADOW) return false;
        if (visionChase && m_Shadow.shadowMode.isShadow) { return false; }

        // 判定用の変化角度を取得する
        Quaternion addQuatRotate = Quaternion.Euler(0, m_ViewRotation, 0);

        // 視点の変化角度をラジアン角に変換
        float addRadRotate = m_ViewRotation * Mathf.Deg2Rad;

#if UNITY_EDITOR

        /* デバッグ時にレイとして表示する処理 */
        Vector3 Fov_L, Fov_M, Fov_R;

        Fov_M = transform.position + Quaternion.AngleAxis(addRadRotate * Mathf.Rad2Deg, transform.up) * transform.forward * m_ViewDistance;
        Debug.DrawRay(transform.position, Fov_M - transform.position, Color.blue);

        float halfFovRad = (m_ViewFov / 2f) * Mathf.Deg2Rad;
        Fov_L = transform.position + Quaternion.AngleAxis((addRadRotate + halfFovRad) * Mathf.Rad2Deg, transform.up) * transform.forward * m_ViewDistance;
        Debug.DrawRay(transform.position, Fov_L - transform.position, Color.red);

        Fov_R = transform.position + Quaternion.AngleAxis((addRadRotate - halfFovRad) * Mathf.Rad2Deg, transform.up) * transform.forward * m_ViewDistance;
        Debug.DrawRay(transform.position, Fov_R - transform.position, Color.red);

#endif

        // 自身と検索オブジェクトの距離を求める
        float AtoB_Distance = (transform.position - _obj.transform.position).magnitude;

        /* 索敵距離外なら処理を抜ける */
        if(AtoB_Distance > m_ViewDistance) return false;

        /* 自身から検索オブジェクトの方向を求める */
        Vector3 AtoB_Dir_Vec = (_obj.transform.position - transform.position).normalized;
        Quaternion AtoB_Dir_Quat = Quaternion.LookRotation(AtoB_Dir_Vec);

        /* 索敵範囲外に存在しているなら処理を抜ける */
        if (Quaternion.Angle(transform.rotation * addQuatRotate, AtoB_Dir_Quat) > (m_ViewFov / 2)) return false;

        return true;
    }

    /* 追跡状態に応じて処理を変更する処理 */
    private void VariousTrackingProcesses()
    {
        /* 追跡状態毎の処理 */
        switch(m_Tracking)
        {
            case E_TRACKING.PATROL:
                ChasePatrol();
                break;
            case E_TRACKING.SHADOW:
                ChaseShadow();
                break;
            case E_TRACKING.PLAYER:
                ChasePlayer();
                break;
        }
    }

    /* 前方にある影が掴まれたときの処理 */
    private void CatchedFrontShadow()
    {
        if (m_Tracking != E_TRACKING.PATROL) return;
        if (isDespawn) { return; }
        if (frontShadowChase && m_Shadow.shadowMode.isShadow) { return; }

        /* 影が掴まれていないなら処理を抜ける */
        if (m_Shadow.GetShadowManager().hitStartShadow == null) return;
        int hitNum = m_Shadow.GetShadowManager().hitStartShadow.transform.parent.GetSiblingIndex();

        // 光源の向きを取得する
        Vector3[] lightVec = m_Shadow.GetLightsVec();
        //Debug.Log("影に当たってる？");
        /* 設定された光源の数繰り返す */
        for(int i = 0; i < lightVec.Length; i++)
        {
            /* 光源の方向が設定されていないなら処理を飛ばす */
            if(lightVec[i] == Vector3.zero) continue;

            // 光源の回転座標を取得する
            Quaternion rot = Quaternion.LookRotation(lightVec[i], Vector3.up);

            /* 目標の回転座標に近づいたなら */
            if(Quaternion.Angle(transform.rotation, rot) < 1f)
            {
                /* 掴まれた影の番号と光源の番号が同じなら */
                if(hitNum == i)
                {
                    if (SkipOverRay(m_Player))
                    {
                        /* プレイヤー確保処理 */
                        m_Tracking = E_TRACKING.PLAYER;
                        m_Anim.Play("Kill");
                        SoundManager.Get().PlaySE3D(E_SE_TYPE.EM_DISCOVERY, transform);
                        Debug.Log("おま死");

                    }
                }
            }
        }
    }

    /* ターゲットの地点に向かって移動する処理 */
    private void MoveTargetLocation(GameObject _obj)
    {
        // 目標地点への方向を算出する
        Vector3 direction = _obj.transform.position - transform.position;

        // 方向に沿って移動
        m_Rigidbody.velocity = direction.normalized * (m_VariableSpeed * m_OperatorSpeedMag);
        //transform.Translate(direction.normalized * m_VariableSpeed * Time.deltaTime, Space.World);
    }

    /* ターゲットの地点に向かって回転する処理 */
    private void RotateTargetLocation(GameObject _obj, float _rotSpd, float _rotTime)
    {
        // 目標地点への方向を算出する
        Vector3 direction = _obj.transform.position - transform.position;
        direction.y = 0;

        // 回転方向を計算する
        Quaternion targetRotate = Quaternion.LookRotation(direction);
        // Y軸回転の大きさを計算
        float difRotateY = Quaternion.Angle(transform.rotation, targetRotate);

        if (Mathf.Abs(difRotateY) > 1f)
        {
           // Debug.Log("アニメーション回転開始");
            m_Anim.SetBool("rotateEnd", false);
            m_Anim.SetBool("rotateStart", true);

            // アニメーションブレンドに、回転量を送信する
            SetAnimaRotateBlend(difRotateY);
        }
        else
        {
            m_Anim.SetBool("rotateEnd", true);
            m_Anim.SetBool("rotateStart", false);
            m_Anim.SetFloat("rotateBlend", 0);
        }

        // 方向に向かって回転
        transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotate, Time.deltaTime * (_rotSpd / _rotTime));
    
    }

    /* ポイントの初期設定を行う処理 */
    private void AllPointSetUp()
    {
        /* 基礎オブジェクトが設定されているなら */
        if (m_CorePoint != null)
        {
            /* 開始時の子オブジェクトの数を取得する */
            m_DefChild_Core = m_CorePoint.transform.childCount;
            m_BasePoints = new BasePoint_Array[m_DefChild_Core];

            /* 各子オブジェクトが存在する数、配列を追加する */
            m_DefChild_Base = new int[m_DefChild_Core];

            /* 追加子オブジェクト数の更新 */
            m_DefChild_Base = new int[m_CorePoint.transform.childCount];

            /* ベースポイントを全て取得する */
            for (int i = 0; i < m_DefChild_Core; i++)
            {
                m_BasePoints[i].BasePoint = m_CorePoint.transform.GetChild(i).gameObject;
                m_DefChild_Base[i] = m_BasePoints[i].BasePoint.transform.childCount;
            }

            /* ベースポイント内のウェイポイントをすべて取得する */
            for (int i = 0; i < m_BasePoints.Length; i++)
            {
                int WayPoint_Cnt = m_BasePoints[i].BasePoint.transform.childCount;
                m_BasePoints[i].WayPoints = new GameObject[WayPoint_Cnt];

                /* ウェイポイントをすべて取得する */
                for (int j = 0; j < WayPoint_Cnt; j++)
                {
                    m_BasePoints[i].WayPoints[j] = m_BasePoints[i].BasePoint.transform.GetChild(j).gameObject;
                }
            }
        }
    }

    /* レイの状態更新処理 */
    private void UpdateRayState()
    {
        // 自身の位置情報
        Vector3 origin = this.transform.position;

        /* 自身の前方と右側を取得する */
        Vector3 dirForward = this.transform.forward;
        Vector3 dirRight = this.transform.right;

        // 衝突判定を取得する


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

    /* コアポイントの情報を動的に取得する処理 */
    private void DynamicObtainCorePoint()
    {
        if (m_AddChild_Core == m_CorePoint.transform.childCount) return;

        /* 現在のコアポイント内の子オブジェクトの数と初期化時の数に違いがある時 */
        if (m_CorePoint.transform.childCount != m_DefChild_Core)
        {
            Debug.Log(this.name + "のコアポイントを更新します");

            /* 追加子オブジェクト数の初期化 */
            m_AddChild_Core = 0;
            m_AddChild_Core = m_CorePoint.transform.childCount;

            /* ベースポイントの数を追加する */
            m_BasePoints = new BasePoint_Array[m_AddChild_Core];

            /* 追加子オブジェクト数の更新 */
            m_DefChild_Base = new int[m_CorePoint.transform.childCount];

            /* 追加のベースポイントの個数分処理を行う */
            for (int i = 0; i < m_AddChild_Core; i++)
            {
                m_BasePoints[i].BasePoint = m_CorePoint.transform.GetChild(i).gameObject;
            }
        }
    }

    /* ベースポイントの情報を動的に取得する処理 */
    private void DynamicObtainBasePoint()
    {
        /* ベースポイントが設定された数繰り返す */
        for (int i = 0; i < m_CorePoint.transform.childCount; i++)
        {
            /* 現在のベースポイント内の子オブジェクトの数と初期化時の数に違いがあるとき */
            if (m_BasePoints[i].BasePoint.transform.childCount != m_DefChild_Base[i])
            {
                //Debug.Log(this.name + "のベースポイントを更新します");

                /* ウェイポイントの数を追加する */
                m_BasePoints[i].WayPoints = new GameObject[m_BasePoints[i].BasePoint.transform.childCount];

                m_AddChild_Base = new int[m_CorePoint.transform.childCount];

                /* 追加子オブジェクト数の初期化 */
                m_AddChild_Base[i] = 0;
                m_AddChild_Base[i] = m_BasePoints[i].BasePoint.transform.childCount;

                /* 指定ベースオブジェクトの追加ウェイポイント分繰り返す */
                for (int j = 0; j < m_AddChild_Base[i]; j++)
                {
                    m_BasePoints[i].WayPoints[j] = m_BasePoints[i].BasePoint.transform.GetChild(j).gameObject;
                }
            }
        }
    }

    /* ウェイポイントに向かって移動する処理 */
    private void ChaseWayPoint()
    {
        /* ウェイポイントが設定されてないなら処理を抜ける */
        if (m_BasePoints[m_Number].BasePoint.transform.childCount == 0) return;

        if (m_BasePoints[m_Number].WayPoints.Length <= m_CurrentWayPointIndex)
        {
            m_CurrentWayPointIndex = m_BasePoints[m_Number].WayPoints.Length - 1;
        }

        /* ゲームオブジェクトがアクティブでないなら */
        if (!m_BasePoints[m_Number].WayPoints[m_CurrentWayPointIndex].activeSelf)
        {
            // 次の目標地点に移動を開始する
            m_CurrentWayPointIndex = (m_CurrentWayPointIndex + 1) % m_BasePoints[m_Number].WayPoints.Length;
        }

        m_Anim.SetBool("running", true);

        // 目標地点への方向を算出する
        Vector3 direction = m_BasePoints[m_Number].WayPoints[m_CurrentWayPointIndex].transform.position - transform.position;
        direction.y = 0;

        // 方向に沿って移動する
        m_Rigidbody.velocity = direction.normalized * (m_VariableSpeed * m_OperatorSpeedMag);
        //transform.Translate(direction.normalized * m_VariableSpeed * Time.deltaTime, Space.World);

        /* 指定した目標地点に近づいたなら */
        if (direction.sqrMagnitude < m_Tolerance * m_Tolerance)
        {

            m_Shadow.ReturnShadowObj(m_BasePoints[m_Number].WayPoints[m_CurrentWayPointIndex]);
            m_CurrentWayPointIndex = 0;
            //return;

            // 次の目標地点に移動を開始する
            //m_CurrentWayPointIndex = (m_CurrentWayPointIndex + 1) % m_BasePoints[m_Number].WayPoints.Length;
        }
    }

    // アニメーションでの回転方向を確認する
    private E_ANIM_ROTATE_PAT CheckRotatePat(GameObject _obj)
    {

        // 目標地点への方向を算出する
        Vector3 direction = _obj.transform.position - transform.position;
        direction.y = 0;

        // 回転方向を計算する
        Quaternion targetRotate = Quaternion.LookRotation(direction);

        // Y軸回転の大きさを計算
        float difRotateY = Quaternion.Angle(transform.rotation, targetRotate);
        // 0以下を補完
        if (difRotateY < 0) { difRotateY += 360.0f; }

        m_AnimRotateBase = difRotateY;

        if (difRotateY < 135.0f)
        {
            return E_ANIM_ROTATE_PAT.LEFT;
        }
        else if (difRotateY > 225.0f)
        {
            return E_ANIM_ROTATE_PAT.RIGHT;
        }
        else
        {
            return E_ANIM_ROTATE_PAT.BACK;
        }
    }

    private void SetAnimaRotateBlend(float _tarRotate)
    {

        float rotateBase = 0;
        switch (m_Tracking)
        {
            case E_TRACKING.PLAYER:
                break;
            case E_TRACKING.PATROL:
                Enemy_Patrol ep = m_PatrolTarget.GetComponent<Enemy_Patrol>();
                rotateBase = ep.GetAnimRotateBase();
                m_Anim.SetInteger("rotatePat", (int)ep.GetAnimRotatePat());
                break;
            case E_TRACKING.SHADOW:
                rotateBase = m_AnimRotateBase;
                break;
        }
        m_Anim.SetFloat("rotateBlend",rotateBase != 0 ? _tarRotate / rotateBase : 0.0f);
        
    }


    /* トリガーに触れた時の処理 */
    private void OnCollisionEnter(Collision other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            Application.LoadLevel(SceneManager.GetActiveScene().name);
        }
    }
}
