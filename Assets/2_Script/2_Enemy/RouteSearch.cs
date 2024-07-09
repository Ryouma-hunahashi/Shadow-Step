using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class RouteSearch : MonoBehaviour
{
    [SerializeField, Tooltip("�����s����j�~����")]
    private bool m_NotAutoMove = true;

    [SerializeField,Tooltip("�T����̎w��")] 
    private GameObject m_Target;
    private Vector3 m_TargetPositionLog;

    /* NavMesh�̎g�p�R���|�[�l���g */
    private NavMeshPath m_NMPath;   // �p�X
    private NavMeshAgent m_NMAgent; // ���f

    public void SetNavAgentEnable(bool _en) { m_NMAgent.enabled = _en; }
    public bool GetNavAgentEnable() { return m_NMAgent.enabled; }

    // �p�̍��W���X�g
    private List<Vector3> m_CornerPositions = new List<Vector3>();

    /* �p���W��Ԃ��֐� */
    public List<Vector3> GetCornerPositions() { return m_CornerPositions; }           // ������Ԃ�
    public Vector3 GetCornerPosition(int _num) { return m_CornerPositions[_num]; }    // �P�̂�Ԃ�
    public int GetCornerPositionLength() { return m_CornerPositions.Count; }          // ���X�g�̐���Ԃ�

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

    /* ���������� */
    public void Init(GameObject _target)
    {
        if (m_Target == null) m_Target = _target;

        // �^�[�Q�b�g�̒n�_���擾
        Vector3 targetPos = m_Target.transform.position;

        // �p�X�̎擾
        m_NMPath = new NavMeshPath();

        /* �����ړ�AI�̎擾 */
        m_NMAgent = GetComponent<NavMeshAgent>();


        /*  �����s����j�~����Ȃ�*/
        if (m_NotAutoMove)
        {
            /* �ړ��֘A���I�t�ɂ��� */
            m_NMAgent.speed = 0;
            m_NMAgent.angularSpeed = 0;
            m_NMAgent.acceleration = 0;
            m_NMAgent.stoppingDistance = 0;
        }
        Debug.Log(m_NMAgent.ToString());
        /* �ړI�n�̎Z�o */
        m_NMAgent.SetDestination(targetPos);
        m_NMAgent.CalculatePath(targetPos, m_NMPath);

        /* �e�n�_���m�ۂ��� */
        for (int i = 0; i < m_NMPath.corners.Length; i++)
        {
            /* ���݂̊p���W��ۑ����� */
            Vector3 cornerCurr = m_NMPath.corners[i];
            m_CornerPositions.Add(cornerCurr);

            // ���肪�Ō�̊p�������Ȃ�^�[�Q�b�g�̒n�_��ۑ�����
            if (m_NMPath.corners.Length == i) m_CornerPositions.Add(targetPos);
        }
    }

    /* �w��I�u�W�F�N�g�ւ̒ǐՂ��J�n���� */
    public void ChaseStart(GameObject _obj)
    {
        // �^�[�Q�b�g�̒n�_���擾
        Vector3 targetPos = _obj.transform.position;

        // �p�X�̎擾
        m_NMPath = new NavMeshPath();

        /* �����ړ�AI�̎擾 */
        m_NMAgent = GetComponent<NavMeshAgent>();

        /* �ړI�n�̎Z�o */
        m_NMAgent.destination = targetPos;
        m_NMAgent.CalculatePath(targetPos, m_NMPath);
    }

    /* �w��I�u�W�F�N�g�ւ̃��[�g���X�V���� */
    public void RouteUpdate()
    {
        // �^�[�Q�b�g�̒n�_���擾
        Vector3 targetPos = m_Target.transform.position;

        /* �^�[�Q�b�g�̈ʒu���O��ƈႢ������Ȃ� */
        if (targetPos != m_TargetPositionLog)
        {
            // �p���W���X�g�̏�����
            m_CornerPositions.Clear();

            /* �ړI�n�̎Z�o */
            m_NMAgent.SetDestination(targetPos);
            m_NMAgent.CalculatePath(targetPos, m_NMPath);

            /* �����n�_���m�ۂ��� */
            for (int i = 0; i < m_NMPath.corners.Length; i++)
            {
                /* ���݂̊p���W��ۑ����� */
                Vector3 cornerCurr = m_NMPath.corners[i];
                m_CornerPositions.Add(cornerCurr);

                // ���肪�Ō�̊p�������Ȃ�^�[�Q�b�g�̒n�_��ۑ�����
                if (m_NMPath.corners.Length == i) m_CornerPositions.Add(targetPos);
            }
        }

        // ���O���X�V����
        m_TargetPositionLog = targetPos;
    }

    /* ���x�Ɖ�]���x�̃Z�b�g */
    public void SetSpeed(float _spd) { m_NMAgent.speed = _spd; }
    public void SetAngularSpeed(float _angSpd) { m_NMAgent.angularSpeed = _angSpd; }
    public void SetAcceleration(float _accel) { m_NMAgent.acceleration = _accel; }

    /* �Q�[���I�����ɍs������ */
    private void OnApplicationQuit()
    {
        // �p�̍��W���X�g����������
        m_CornerPositions.Clear();
    }
}
