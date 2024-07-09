using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_Patrol : MonoBehaviour
{
    /* 二次元配列用の構造体 */
    [System.Serializable]
    private struct BasePoint_Array
    {
        public GameObject BasePoint;
        public GameObject[] WayPoints;
    }

    private Rigidbody m_Rigidbody;

    /* 移動ポイントオブジェクト */
    [SerializeField] private GameObject m_CorePoint;    // ポイント群の基礎オブジェクト

    /* 複数のベースポイントにアクセスする変数 */
    [SerializeField] private BasePoint_Array[] m_BasePoints;

    /* 動的アクセス用の整数型：CP(CorePoint), BP(BasePoint) */
    private int m_DefChild_Core;    // 初期化時のCP子オブジェクトの数
    private int m_AddChild_Core;    // 動的な追加CP子オブジェクトの数
    private int[] m_DefChild_Base;  // 初期化時のBP子オブジェクトの数
    private int[] m_AddChild_Base;  // 動的な追加BP子オブジェクトの数

    // 移動速度の設定
    [SerializeField] private float m_MoveSpeed;

    /* 司令からの倍率値を取得する */
    private float m_OperatorSpeedMag = 1.0f;
    public void SetOperatorSpeedMag(float _spd) { m_OperatorSpeedMag = _spd; }

    /* 移動地点の詳細 */
    private int m_CurrentWayPointIndex; // ウェイポイントの指定値
    private int m_LogWayPointIndex;     // ウェイポイントのログ

    /* 到着地点についたとき、停止する時間 */
    private float m_StopTime;

    // 到着地点の許容範囲の設定
    [SerializeField] private float m_Tolerance = 0.1f;

    // 一旦番号
    [SerializeField] private int m_Number;

    // アニメーション回転の際に使用する回転中の回転角
    private float m_RotateBase;
    private Enemy_Main.E_ANIM_ROTATE_PAT m_RotatePat;
    private Quaternion m_RotationBuf;

    /* 現在の移動地点IDを返す */
    public int GetCurrentWayPoint() { return m_CurrentWayPointIndex; }
    public int GetWayPointCount() { return m_BasePoints[m_Number].WayPoints.Length; }

    /* 回転角を返す */
    public float GetAnimRotateBase() { return m_RotateBase; }
    public Enemy_Main.E_ANIM_ROTATE_PAT GetAnimRotatePat() { return m_RotatePat; }

    /* 次の移動地点のゲームオブジェクトを渡す */
    public GameObject GetNextWayPoint() { return m_BasePoints[m_Number].WayPoints[m_CurrentWayPointIndex]; }

    private PlayerShadowMode m_ShadowMode;


    /* 通常開始処理 */
    private void Start()
    {
        // ポイント初期化処理
        AllPointSetUp();
        GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
        m_ShadowMode = objs[objs.Length - 1].GetComponent<PlayerShadowMode>();
        if(m_ShadowMode == null)
        {
            Debug.LogError("プレイヤー、又はPlayerShadowModeが見つかりません");
        }

        /* リジッドボディが入っていないなら追加、設定を完了させる */
        if (GetComponent<Rigidbody>() == null) this.gameObject.AddComponent<Rigidbody>();
        m_Rigidbody = GetComponent<Rigidbody>();
        m_Rigidbody.useGravity = false;
        m_RotationBuf = transform.rotation;
    }

    /* 通常更新処理 */
    private void Update()
    {
        if (m_ShadowMode.goFire || m_ShadowMode.isPause) { m_Rigidbody.velocity = Vector3.zero; return; }

        /* ポイント更新処理 */
        DynamicObtainCorePoint();
        DynamicObtainBasePoint();

        // 移動処理
        ChaseWayPoint();

        if (m_StopTime >= 0)
        {
            m_Rigidbody.velocity = Vector3.zero;
            m_StopTime -= (Time.deltaTime * 1);
            return;
        }
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

    /* コアポイントの情報を動的に取得する処理 */
    private void DynamicObtainCorePoint()
    {
        if (m_AddChild_Core == m_CorePoint.transform.childCount) return;

        /* 現在のコアポイント内の子オブジェクトの数と初期化時の数に違いがある時 */
        if(m_CorePoint.transform.childCount != m_DefChild_Core)
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
            if(m_BasePoints[i].BasePoint.transform.childCount != m_DefChild_Base[i])
            {
                Debug.Log(this.name + "のベースポイントを更新します");

                /* ウェイポイントの数を追加する */
                m_BasePoints[i].WayPoints = new GameObject[m_BasePoints[i].BasePoint.transform.childCount];

                m_AddChild_Base = new int[m_CorePoint.transform.childCount];

                /* 追加子オブジェクト数の初期化 */
                m_AddChild_Base[i] = 0;
                m_AddChild_Base[i] = m_BasePoints[i].BasePoint.transform.childCount;

                /* 指定ベースオブジェクトの追加ウェイポイント分繰り返す */
                for(int j= 0; j < m_AddChild_Base[i]; j++)
                {
                    m_BasePoints[i].WayPoints[j] = m_BasePoints[i].BasePoint.transform.GetChild(j).gameObject;
                }
            }
        }
    }

    /* ウェイポイントに向かって移動する処理 */
    private void ChaseWayPoint()
    {
        /* 現在の指定値とログの値が違っているなら */
        if (m_CurrentWayPointIndex != m_LogWayPointIndex)
        {
            // 停止処理を開始する
            ChaseStop(m_BasePoints[m_Number].WayPoints[m_LogWayPointIndex]);

            // 目標地点への方向を算出する
            Vector3 dir = m_BasePoints[m_Number].WayPoints[m_CurrentWayPointIndex].transform.position - transform.position;
            dir.y = 0;

            // 回転方向を計算する
            Quaternion targetRotate = Quaternion.LookRotation(dir);
            //Debug.Log(targetRotate);
            // Y軸回転の大きさを計算
            float difRotateY = Quaternion.Angle(m_RotationBuf, targetRotate);
            m_RotationBuf = targetRotate;
            //Debug.Log(difRotateY);
            // 0以下を補完
            if (difRotateY < 0) { difRotateY += 360.0f; }

            if (difRotateY < 135.0f)
            {
                //Debug.Log("左へまいります");
                m_RotatePat =  Enemy_Main.E_ANIM_ROTATE_PAT.LEFT;
            }
            else if (difRotateY > 225.0f)
            {
                m_RotatePat = Enemy_Main.E_ANIM_ROTATE_PAT.RIGHT;
            }
            else
            {
                m_RotatePat = Enemy_Main.E_ANIM_ROTATE_PAT.BACK;
            }
            m_RotateBase = difRotateY;

            // ログを更新する
            m_LogWayPointIndex = m_CurrentWayPointIndex;
        }

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

        // 目標地点への方向を算出する
        Vector3 direction = m_BasePoints[m_Number].WayPoints[m_CurrentWayPointIndex].transform.position - transform.position;
        direction.y = 0;

        // 方向に沿って移動する
        m_Rigidbody.velocity = direction.normalized * (m_MoveSpeed * m_OperatorSpeedMag);

        /* 指定した目標地点に近づいたなら */
        if (direction.sqrMagnitude < m_Tolerance * m_Tolerance)
        {
            // 次の目標地点に移動を開始する
            m_CurrentWayPointIndex = (m_CurrentWayPointIndex + 1) % m_BasePoints[m_Number].WayPoints.Length;
        }
    }

    /* ウェイポイント到着時に移動を停止する処理 */
    private void ChaseStop(GameObject _pt)
    {
        /* ウェイポイントの設定が追加されていないなら処理を抜ける */
        if (_pt.GetComponent<WayPoint_Setting>() == null) return;

        // コンポーネントを取得
        WayPoint_Setting option = _pt.GetComponent<WayPoint_Setting>();

        m_StopTime = option.GetStopTime();

        if (m_StopTime != 0) Debug.Log(m_StopTime + "秒待機します");

        return;
    }
}
