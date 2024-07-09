using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_Operator : MonoBehaviour
{
    // シーンに存在する敵オブジェクト
    private GameObject[] m_Enemies;

    [System.Serializable]
    private struct S_EnemyOperatorStatus
    {
        [Tooltip("優先して実行する")]
        public bool priority;

        [Tooltip("速度に倍率を付与する")]
        public float speedMag;

        [HideInInspector]
        public float speedMag_Log;
    }

    [SerializeField,Tooltip("全体に影響を与える")]
    private S_EnemyOperatorStatus m_UniversalStatus;

    [SerializeField,Tooltip("敵本体のみに影響を与える")]
    private S_EnemyOperatorStatus m_EnemyStatus;

    [SerializeField, Tooltip("巡回個体のみに影響を与える")]
    private S_EnemyOperatorStatus m_PatrolStatus;

    private void Start()
    {
        /* 敵の状態をすべて取る */
        m_Enemies = GameObject.FindGameObjectsWithTag("Enemy");
    }

    /* エディタ上のみ更新を行う */
#if UNITY_EDITOR

    private void Update()
    {
        bool uni = m_UniversalStatus.priority;
        bool ene = m_EnemyStatus.priority;
        bool pat = m_PatrolStatus.priority;

        if (uni || ene || pat) PriorityUpdate();
    }

#endif

    /* 優先度によって状態を変化させる */
    private void PriorityUpdate()
    {
        /* 全体の変更を行う */
        if(m_UniversalStatus.priority)
        {
            /* 敵と巡回オブジェクト情報の格納地点を作成 */
            Enemy_Main[] mains = new Enemy_Main[m_Enemies.Length];
            Enemy_Patrol[] patrols = new Enemy_Patrol[m_Enemies.Length];

            for(int i = 0; i < m_Enemies.Length; i++)
            {
                /* 変更コンポーネントの取得 */
                mains[i] = m_Enemies[i].GetComponent<Enemy_Main>();
                patrols[i] = m_Enemies[i].transform.parent.GetChild(1).GetComponent<Enemy_Patrol>();

                /* コンポーネント内の変更を行う */
                mains[i].SetOperatorSpeedMag(m_UniversalStatus.speedMag);
                patrols[i].SetOperatorSpeedMag(m_UniversalStatus.speedMag);
            }

            /* 優先度情報を削除する */
            m_UniversalStatus.priority = false;
            m_EnemyStatus.priority = false;
            m_PatrolStatus.priority = false;

            return;
        }

        /* 敵全体の変更を行う */
        if (m_EnemyStatus.priority)
        {
            /* 敵情報の格納地点を作成 */
            Enemy_Main[] mains = new Enemy_Main[m_Enemies.Length];

            for (int i = 0; i < m_Enemies.Length; i++)
            {
                /* 変更コンポーネントの取得 */
                mains[i] = m_Enemies[i].GetComponent<Enemy_Main>();

                /* コンポーネント内の変更を行う */
                mains[i].SetOperatorSpeedMag(m_EnemyStatus.speedMag);
            }

            /* 優先度情報を削除する */
            m_UniversalStatus.priority = false;
            m_EnemyStatus.priority = false;
            m_PatrolStatus.priority = false;

            return;
        }

        /* 巡回オブジェクトの変更を行う */
        if (m_PatrolStatus.priority)
        {
            /* 巡回オブジェクト情報の格納地点を作成 */
            Enemy_Patrol[] patrols = new Enemy_Patrol[m_Enemies.Length];

            for (int i = 0; i < m_Enemies.Length; i++)
            {
                /* 変更コンポーネントの取得 */
                patrols[i] = m_Enemies[i].transform.parent.GetChild(1).GetComponent<Enemy_Patrol>();

                /* コンポーネント内の変更を行う */
                patrols[i].SetOperatorSpeedMag(m_PatrolStatus.speedMag);
            }

            /* 優先度情報を削除する */
            m_UniversalStatus.priority = false;
            m_EnemyStatus.priority = false;
            m_PatrolStatus.priority = false;

            return;
        }

    }
}
