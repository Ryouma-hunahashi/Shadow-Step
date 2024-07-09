using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class RouteSearch : MonoBehaviour
{
    [SerializeField, Tooltip("自動行動を阻止する")]
    private bool m_NotAutoMove = true;

    [SerializeField,Tooltip("探索先の指定")] 
    private GameObject m_Target;
    private Vector3 m_TargetPositionLog;

    /* NavMeshの使用コンポーネント */
    private NavMeshPath m_NMPath;   // パス
    private NavMeshAgent m_NMAgent; // 判断

    public void SetNavAgentEnable(bool _en) { m_NMAgent.enabled = _en; }
    public bool GetNavAgentEnable() { return m_NMAgent.enabled; }

    // 角の座標リスト
    private List<Vector3> m_CornerPositions = new List<Vector3>();

    /* 角座標を返す関数 */
    public List<Vector3> GetCornerPositions() { return m_CornerPositions; }           // 複数を返す
    public Vector3 GetCornerPosition(int _num) { return m_CornerPositions[_num]; }    // 単体を返す
    public int GetCornerPositionLength() { return m_CornerPositions.Count; }          // リストの数を返す

    private void Start()
    {
        if(this.gameObject.GetComponent<NavMeshAgent>() == null)
        {
            this.gameObject.AddComponent<NavMeshAgent>();
        }
        GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
        m_Target = objs[objs.Length - 1];
        if(m_Target != null) Init(m_Target);
    }

    /* 初期化処理 */
    public void Init(GameObject _target)
    {
        if (m_Target == null) m_Target = _target;

        // ターゲットの地点を取得
        Vector3 targetPos = m_Target.transform.position;

        // パスの取得
        m_NMPath = new NavMeshPath();

        /* 自動移動AIの取得 */
        m_NMAgent = GetComponent<NavMeshAgent>();


        /*  自動行動を阻止するなら*/
        if (m_NotAutoMove)
        {
            /* 移動関連をオフにする */
            m_NMAgent.speed = 0;
            m_NMAgent.angularSpeed = 0;
            m_NMAgent.acceleration = 0;
            m_NMAgent.stoppingDistance = 0;
        }
        Debug.Log(m_NMAgent.ToString());
        /* 目的地の算出 */
        m_NMAgent.SetDestination(targetPos);
        m_NMAgent.CalculatePath(targetPos, m_NMPath);

        /* 各地点を確保する */
        for (int i = 0; i < m_NMPath.corners.Length; i++)
        {
            /* 現在の角座標を保存する */
            Vector3 cornerCurr = m_NMPath.corners[i];
            m_CornerPositions.Add(cornerCurr);

            // 判定が最後の角だったならターゲットの地点を保存する
            if (m_NMPath.corners.Length == i) m_CornerPositions.Add(targetPos);
        }
    }

    /* 指定オブジェクトへの追跡を開始する */
    public void ChaseStart(GameObject _obj)
    {
        // ターゲットの地点を取得
        Vector3 targetPos = _obj.transform.position;

        // パスの取得
        m_NMPath = new NavMeshPath();

        /* 自動移動AIの取得 */
        m_NMAgent = GetComponent<NavMeshAgent>();

        /* 目的地の算出 */
        m_NMAgent.destination = targetPos;
        m_NMAgent.CalculatePath(targetPos, m_NMPath);
    }

    /* 指定オブジェクトへのルートを更新する */
    public void RouteUpdate()
    {
        // ターゲットの地点を取得
        Vector3 targetPos = m_Target.transform.position;

        /* ターゲットの位置が前回と違いがあるなら */
        if (targetPos != m_TargetPositionLog)
        {
            // 角座標リストの初期化
            m_CornerPositions.Clear();

            /* 目的地の算出 */
            m_NMAgent.SetDestination(targetPos);
            m_NMAgent.CalculatePath(targetPos, m_NMPath);

            /* 初期地点を確保する */
            for (int i = 0; i < m_NMPath.corners.Length; i++)
            {
                /* 現在の角座標を保存する */
                Vector3 cornerCurr = m_NMPath.corners[i];
                m_CornerPositions.Add(cornerCurr);

                // 判定が最後の角だったならターゲットの地点を保存する
                if (m_NMPath.corners.Length == i) m_CornerPositions.Add(targetPos);
            }
        }

        // ログを更新する
        m_TargetPositionLog = targetPos;
    }

    /* 速度と回転速度のセット */
    public void SetSpeed(float _spd) { m_NMAgent.speed = _spd; }
    public void SetAngularSpeed(float _angSpd) { m_NMAgent.angularSpeed = _angSpd; }
    public void SetAcceleration(float _accel) { m_NMAgent.acceleration = _accel; }

    /* ゲーム終了時に行う処理 */
    private void OnApplicationQuit()
    {
        // 角の座標リストを消去する
        m_CornerPositions.Clear();
    }
}
