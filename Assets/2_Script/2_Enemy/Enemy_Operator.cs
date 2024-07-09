using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_Operator : MonoBehaviour
{
    // �V�[���ɑ��݂���G�I�u�W�F�N�g
    private GameObject[] m_Enemies;

    [System.Serializable]
    private struct S_EnemyOperatorStatus
    {
        [Tooltip("�D�悵�Ď��s����")]
        public bool priority;

        [Tooltip("���x�ɔ{����t�^����")]
        public float speedMag;

        [HideInInspector]
        public float speedMag_Log;
    }

    [SerializeField,Tooltip("�S�̂ɉe����^����")]
    private S_EnemyOperatorStatus m_UniversalStatus;

    [SerializeField,Tooltip("�G�{�݂̂̂ɉe����^����")]
    private S_EnemyOperatorStatus m_EnemyStatus;

    [SerializeField, Tooltip("����݂̂̂ɉe����^����")]
    private S_EnemyOperatorStatus m_PatrolStatus;

    private void Start()
    {
        /* �G�̏�Ԃ����ׂĎ�� */
        m_Enemies = GameObject.FindGameObjectsWithTag("Enemy");
    }

    /* �G�f�B�^��̂ݍX�V���s�� */
#if UNITY_EDITOR

    private void Update()
    {
        bool uni = m_UniversalStatus.priority;
        bool ene = m_EnemyStatus.priority;
        bool pat = m_PatrolStatus.priority;

        if (uni || ene || pat) PriorityUpdate();
    }

#endif

    /* �D��x�ɂ���ď�Ԃ�ω������� */
    private void PriorityUpdate()
    {
        /* �S�̂̕ύX���s�� */
        if(m_UniversalStatus.priority)
        {
            /* �G�Ə���I�u�W�F�N�g���̊i�[�n�_���쐬 */
            Enemy_Main[] mains = new Enemy_Main[m_Enemies.Length];
            Enemy_Patrol[] patrols = new Enemy_Patrol[m_Enemies.Length];

            for(int i = 0; i < m_Enemies.Length; i++)
            {
                /* �ύX�R���|�[�l���g�̎擾 */
                mains[i] = m_Enemies[i].GetComponent<Enemy_Main>();
                patrols[i] = m_Enemies[i].transform.parent.GetChild(1).GetComponent<Enemy_Patrol>();

                /* �R���|�[�l���g���̕ύX���s�� */
                mains[i].SetOperatorSpeedMag(m_UniversalStatus.speedMag);
                patrols[i].SetOperatorSpeedMag(m_UniversalStatus.speedMag);
            }

            /* �D��x�����폜���� */
            m_UniversalStatus.priority = false;
            m_EnemyStatus.priority = false;
            m_PatrolStatus.priority = false;

            return;
        }

        /* �G�S�̂̕ύX���s�� */
        if (m_EnemyStatus.priority)
        {
            /* �G���̊i�[�n�_���쐬 */
            Enemy_Main[] mains = new Enemy_Main[m_Enemies.Length];

            for (int i = 0; i < m_Enemies.Length; i++)
            {
                /* �ύX�R���|�[�l���g�̎擾 */
                mains[i] = m_Enemies[i].GetComponent<Enemy_Main>();

                /* �R���|�[�l���g���̕ύX���s�� */
                mains[i].SetOperatorSpeedMag(m_EnemyStatus.speedMag);
            }

            /* �D��x�����폜���� */
            m_UniversalStatus.priority = false;
            m_EnemyStatus.priority = false;
            m_PatrolStatus.priority = false;

            return;
        }

        /* ����I�u�W�F�N�g�̕ύX���s�� */
        if (m_PatrolStatus.priority)
        {
            /* ����I�u�W�F�N�g���̊i�[�n�_���쐬 */
            Enemy_Patrol[] patrols = new Enemy_Patrol[m_Enemies.Length];

            for (int i = 0; i < m_Enemies.Length; i++)
            {
                /* �ύX�R���|�[�l���g�̎擾 */
                patrols[i] = m_Enemies[i].transform.parent.GetChild(1).GetComponent<Enemy_Patrol>();

                /* �R���|�[�l���g���̕ύX���s�� */
                patrols[i].SetOperatorSpeedMag(m_PatrolStatus.speedMag);
            }

            /* �D��x�����폜���� */
            m_UniversalStatus.priority = false;
            m_EnemyStatus.priority = false;
            m_PatrolStatus.priority = false;

            return;
        }

    }
}
