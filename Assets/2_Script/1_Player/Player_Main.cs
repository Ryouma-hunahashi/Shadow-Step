using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player_Main : MonoBehaviour
{
#if UNITY_EDITOR

    [System.Serializable]
    private struct S_RayView
    {
        public bool All;        // �S�ĕ\��
        public bool Forward;    // �O��
        public bool Backward;   // ���
        public bool Left;       // ����
        public bool Right;      // �E��
    };

    [Header("���C�̕`��ݒ�")]
    [SerializeField] private S_RayView m_RayView;

#endif

    /* �P�������C�̍\���� */
    [System.Serializable]
    private struct S_Ray
    {
        public float Distance;
        public RaycastHit Info;
        public bool Hit;
    }

    /* �e�����p���C�̍\���� */
    [System.Serializable]
    private struct S_RaySetting
    {
        public S_Ray Forward;
        public S_Ray Backward;
        public S_Ray Left;
        public S_Ray Right;
    }

    [Header("���C�̐ݒ�")]
    [SerializeField] private S_RaySetting m_Ray;

    /* �ǉ��R���|�[�l���g */
    private Rigidbody m_Rigidbody;
    private ControlManager m_ControlManager;
    private PlayerShadowMode m_ShadowMode;

    [System.Serializable]
    private struct S_MovementSetting
    {
        // �f�b�h�]�[���̐ݒ�
        [Range(0.0f, 1.0f)] public float DeadZone;
        public float Speed;     // �ړ����x
        public float FootSteps; // ����
    }

    [Header("�X�e�B�b�N�ݒ�")]
    [Tooltip("�X���ɂ���Đݒ�ω�")]
    [SerializeField] private S_MovementSetting[] m_Movement;
    [Tooltip("�ʏ�ړ��ł̃X�e�B�b�N�̌X��������")]
    [SerializeField, Range(0f, 1f)] float m_StickTilt;

    [Header("�L�[�{�[�h�ݒ�")]
    [SerializeField, Tooltip("�e�݂͂̃L�[�ݒ�")]
    private ControlManager.E_KB m_GrabShadowKey;
    [SerializeField, Tooltip("�_�b�V���L�[�ݒ�")]
    private ControlManager.E_KB m_SprintKey;

    [System.Serializable]
    private struct S_HoldShadowSetting
    {
        // �f�b�h�]�[���̐ݒ�
        [Range(0.0f, 1.0f)] public float Deadzone;

        // ���E�ǂ�����g����
        [Tooltip("Left�FLT�@Right�FRT")]
        public ControlManager.E_DIRECTION Direction;
    }

    [Header("�g���K�[�ݒ�")]
    [SerializeField] private S_HoldShadowSetting m_HoldShadow;

    [System.Serializable]
    private struct S_HoldShadowSpeed
    {
        [Range(0.0f, 1.0f)]
        public float Ratio;     // �䗦
        public float Decrease;  // �����l
    }

    [Header("�e�̏ڍאݒ�")]
    [SerializeField] private float m_ShadowMinSpeed;    // �e�ێ���Ԃ̍ŏ����x
    [SerializeField] private float m_ShadowDefSpeed;    // �e�ێ���Ԃ̒ʏ푬�x
    private float m_ShadowValSpeed;                     // �e�ێ���Ԃ̕ϓ����x

    // �e�ێ���Ԃ̃f�b�h�]�[���̐ݒ�
    [SerializeField, Range(0.0f, 1.0f)] private float m_ShadowDeadzone;

    // �e�ێ���Ԃ̑��x�ݒ�
    [SerializeField] private S_HoldShadowSpeed[] m_ShadowSpeed;

    [Tooltip("�e�ێ���Ԃł̑��x�̔䗦������")]
    [SerializeField, Range(0.0f, 1.0f)] private float m_ShadowSpeedRatio;

    /* ���ʃI�u�W�F�N�g�̐ݒ� */
    private GameObject m_FrontObject;               // �I�u�W�F�N�g�{��
    private const float m_MagDistToFrontObj = 1;    // �����𗣂��{��
    //private float m_DistToFrontObj;               // �I�u�W�F�N�g�Ƃ̋���

    /* ��������p�I�u�W�F�N�g�̐ݒ� */
    private GameObject m_FootStepsObj;
    private SphereCollider m_FootSteps;

    private Animator m_Animator;
    private ParticleSystem m_footParticle;

    /* �e���Ԃ̐ݒ� */
    private bool isHold;    // �e�͂ݏ��
    private bool isStop;    // �����~���

    private int runSENum = 0;

    public bool GetHoldStatus() { return isHold; }

    /* ����\�ɂ��鏈�� */
    public void MovementStart() {m_Animator.enabled = true; isStop = false; }

    /* ���x���O�ɂ��đ����s�ɂ��� */
    public void MovementStop() { m_Rigidbody.velocity = Vector3.zero; m_Animator.enabled = false; isStop = true; }

    /* �ʏ�J�n���� */
    private void Start()
    {
        // ��~��Ԃ���������
        isStop = false;

        // �e�ێ���Ԃ̑��x��������Ԃɂ���
        m_ShadowValSpeed = m_ShadowDefSpeed;

        // ���ʃI�u�W�F�N�g�쐬����
        m_FrontObject = CreateEmptyObject("Dir_Object", true);

        // ��������I�u�W�F�N�g�쐬����
        m_FootStepsObj = CreateEmptyObject("FootSteps_Obj", true);
        m_FootStepsObj.AddComponent<SphereCollider>();                      // �����蔻��̒ǉ�
        m_FootStepsObj.GetComponent<SphereCollider>().isTrigger = true;     // �����蔻����g���K�[��
        m_FootStepsObj.AddComponent<PlayerFootSteps>();                     // ����̏�����ǉ�
        m_FootSteps = m_FootStepsObj.GetComponent<SphereCollider>();       // ���菈�����i�[
        m_FootStepsObj.transform.parent = transform.parent;

        /* �R���|�[�l���g�ǉ� */
        m_Rigidbody = GetComponent<Rigidbody>();
        m_ControlManager = GetComponent<ControlManager>();
        m_ShadowMode = GetComponent<PlayerShadowMode>();
        m_Animator = GetComponent<Animator>();
        m_footParticle = transform.GetChild(3).GetComponent<ParticleSystem>();

        /* �i�K���x�̐ݒ胍�O */
        for(int i = 0; i < m_Movement.Length; i++)
        {
            if(m_Movement[i].Speed <= 0)
            {
                Debug.Log(this.name + "�F" + (i + 1) + "�i�K�ڂ̑��x���������ݒ肳��Ă��܂���");
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
        //Debug.Log("�v���C���[Rb:" + m_Rigidbody.velocity);
        if(m_ShadowMode.goFire||m_ShadowMode.isPause)
        {
            m_Animator.SetBool("running", false);
            m_Rigidbody.velocity = Vector3.zero;
            return;
        }
        // ���C�̍X�V����
        UpdateRayState();

        // �e�̕ێ��J�ڍX�V
        HoldShadowControl();

        // ���ʃI�u�W�F�N�g����
        MoveFrontObject();

        if (isStop) return;

        /* �v���C���[�̑��쏈�� */
        MoveTargetLocation();
        RotateTargetLocation(m_FrontObject);
    }

    /* ���C�̏�ԍX�V���� */
    private void UpdateRayState()
    {
        // ���g�̈ʒu���
        Vector3 origin = this.transform.position;

        /* ���g�̑O���ƉE�����擾���� */
        Vector3 dirForward = this.transform.forward;
        Vector3 dirRight = this.transform.right;

        /* ���g�̃��C�̏Փˏ�Ԃ�ϐ��ɑ��� */
        m_Ray.Forward.Hit = Physics.Raycast(origin, dirForward, out m_Ray.Forward.Info, m_Ray.Forward.Distance);
        m_Ray.Backward.Hit = Physics.Raycast(origin, -dirForward, out m_Ray.Backward.Info, m_Ray.Backward.Distance);
        m_Ray.Left.Hit = Physics.Raycast(origin, -dirRight, out m_Ray.Left.Info, m_Ray.Left.Distance);
        m_Ray.Right.Hit = Physics.Raycast(origin, dirRight, out m_Ray.Right.Info, m_Ray.Right.Distance);

#if UNITY_EDITOR

        /* �S�Ẵ��C��\������Ȃ� */
        if (m_RayView.All)
        {
            /* �\����Ԃɂ��� */
            m_RayView.Forward = true;
            m_RayView.Backward = true;
            m_RayView.Left = true;
            m_RayView.Right = true;
        }

        /* ���C�Փ˂̃��O */
        if (m_RayView.Forward && m_Ray.Forward.Hit) Debug.Log(this.name + "�̑O���ɉ�������܂�");
        if (m_RayView.Backward && m_Ray.Backward.Hit) Debug.Log(this.name + "�̌���ɉ�������܂�");
        if (m_RayView.Left && m_Ray.Left.Hit) Debug.Log(this.name + "�̍����ɂȂɂ�����܂�");
        if (m_RayView.Right && m_Ray.Right.Hit) Debug.Log(this.name + "�̉E���ɂȂɂ�����܂�");

        /* ���C�̕`�揈�� */
        if (m_RayView.Forward) Debug.DrawRay(origin, dirForward * m_Ray.Forward.Distance, Color.red);
        if (m_RayView.Backward) Debug.DrawRay(origin, -dirForward * m_Ray.Backward.Distance, Color.blue);
        if (m_RayView.Left) Debug.DrawRay(origin, -dirRight * m_Ray.Left.Distance, Color.yellow);
        if (m_RayView.Right) Debug.DrawRay(origin, dirRight * m_Ray.Right.Distance, Color.green);

#endif

    }

    /* ���g�𐳖ʃI�u�W�F�N�g�̕����ֈړ������� */
    private void MoveTargetLocation()
    {
        // ���x���[���ɂ���
        m_Rigidbody.velocity = Vector3.zero;

        // ����������[���ɂ���
        float nowRadius = m_FootSteps.radius;
        m_FootSteps.radius = 0;

        m_Animator.SetBool("running", false);
        /* �X�e�B�b�N���X���Ă��Ȃ��Ȃ珈���𔲂��� */
        if (m_StickTilt == 0)
        {
            return;
        }

        /* �e��͂�ł����Ԃ̂Ƃ� */
        if (isHold)
        {
            //m_Animator.SetFloat("runMode", 1.0f);
            for(int i = 0; i < m_ShadowSpeed.Length; i++)
            {
                /* ��ł��Ȃ���ς��邩��R�����g�҂��Ă� */
                if(m_ShadowSpeed[i].Ratio >= m_ShadowSpeedRatio)
                {
                    if (m_StickTilt >= m_ShadowDeadzone)
                    {
                        m_Animator.SetBool("running", true);
                        // �O���֑��x�ɍ��킹�ĉ���������
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
            // �e�ێ���Ԃ̑��x��������Ԃɖ߂�
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

                    // �O���֑��x�ɍ��킹�ĉ���������
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
                // �����~�߂�
            }
        }
        /* �e�ێ���Ԃ̑��x�l��ϓ������� */
        m_ShadowSpeedRatio = (m_ShadowMinSpeed - m_ShadowValSpeed) / (m_ShadowMinSpeed - m_ShadowDefSpeed);
    }

    /* ���g�̌����𐳖ʃI�u�W�F�N�g�� */
    private void RotateTargetLocation(GameObject _obj)
    {
        /* �X�e�B�b�N������͏�ԂȂ珈���𔲂��� */
        if (m_ControlManager.GetConnect() && m_ControlManager.GetStickValue(ControlManager.E_DIRECTION.LEFT) == Vector2.zero) return;

        /* �Q�[���p�b�h���ڑ�����Ă��Ȃ����̏������� */
        if (!m_ControlManager.GetConnect() &&
            !m_ControlManager.GetHoldPress(ControlManager.E_KB.W) &&
            !m_ControlManager.GetHoldPress(ControlManager.E_KB.A) &&
            !m_ControlManager.GetHoldPress(ControlManager.E_KB.S) &&
            !m_ControlManager.GetHoldPress(ControlManager.E_KB.D)) return;

        /* ���x���[���Ȃ珈���𔲂��� */
        if (m_Rigidbody.velocity == Vector3.zero) return;

        // �ڕW�n�_�ւ̕������Z�o����
        Vector3 direction = (_obj.transform.position - transform.position).normalized;
        direction.y = 0;

        // ��]������g�ݍ���
        Quaternion targetRotate = Quaternion.LookRotation(direction);

        // �w��̕����Ɍ������ĉ�]
        transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotate, 360f);
    }

    /* ��I�u�W�F�N�g���쐬���鏈�� */
    private GameObject CreateEmptyObject(string _name = "Empty_Name", bool _child = false)
    {
        /* ��I�u�W�F�N�g�̍쐬 */
        GameObject emp;
        emp = GameObject.CreatePrimitive(PrimitiveType.Cube);
        if (_child) emp.transform.parent = this.transform;

        /* �I�u�W�F�N�g�ݒ�̕ύX */
        emp.name = _name;
        emp.transform.localPosition = Vector3.zero;
        emp.transform.localScale = Vector3.one;

        /* �R���|�[�l���g���폜���� */
        DestroyImmediate(emp.GetComponent<Renderer>());
        DestroyImmediate(emp.GetComponent<MeshFilter>());
        DestroyImmediate(emp.GetComponent<BoxCollider>());

        return emp;
    }

    /* �ړ����͒��ɐ�p�I�u�W�F�N�g�𓮂��� */
    private void MoveFrontObject()
    {
        Vector3 movePoint = new Vector3(0.0f, 0.0f, 0.0f);

        /* �X�e�B�b�N�̈ړ���Ԃ𔽉f���� */
        movePoint.x = (float)m_ControlManager.GetStickValue(ControlManager.E_DIRECTION.LEFT, ControlManager.E_COORDINATE.HORIZONTAL);
        movePoint.z = (float)m_ControlManager.GetStickValue(ControlManager.E_DIRECTION.LEFT, ControlManager.E_COORDINATE.VERTICAL);

        /* �Q�[���p�b�h���ڑ�����Ă��Ȃ��� */
        if(!m_ControlManager.GetConnect())
        {
            bool sprint = m_ControlManager.GetHoldPress(m_SprintKey);

            /* �L�[�{�[�h�ł̑�������s���� */
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.W)) movePoint.z = m_Movement[0].DeadZone;
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.A)) movePoint.x = -m_Movement[0].DeadZone;
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.S)) movePoint.z = -m_Movement[0].DeadZone;
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.D)) movePoint.x = m_Movement[0].DeadZone;

            /* �e��͂�ł���Ƃ��͍ő�l��^���� */
            if (isHold && movePoint.x > 0) movePoint.x = m_Movement[m_Movement.Length - 1].DeadZone;
            if (isHold && movePoint.x < 0) movePoint.x = -m_Movement[m_Movement.Length - 1].DeadZone;
            if (isHold && movePoint.z > 0) movePoint.z = m_Movement[m_Movement.Length - 1].DeadZone;
            if (isHold && movePoint.z < 0) movePoint.z = -m_Movement[m_Movement.Length - 1].DeadZone;

            /* �X�v�����g�L�[����͂��Ă���Ƃ��ő�l��Ԃ� */
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.W) && sprint) movePoint.z = m_Movement[m_Movement.Length - 1].DeadZone;
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.A) && sprint) movePoint.x = -m_Movement[m_Movement.Length - 1].DeadZone;
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.S) && sprint) movePoint.z = -m_Movement[m_Movement.Length - 1].DeadZone;
            if (m_ControlManager.GetHoldPress(ControlManager.E_KB.D) && sprint) movePoint.x = m_Movement[m_Movement.Length - 1].DeadZone;
        }

        // �ړ��n�_�ɔ{�����܂߂�
        movePoint *= m_MagDistToFrontObj;

        // �X�e�B�b�N���͒l�Ǝ��g�̈ʒu���琳�ʂ��Z�o����
        m_FrontObject.transform.position = movePoint + transform.position;

        // ���ʃI�u�W�F�N�g�Ǝ��g�̋������Z�o����
        //m_DistToFrontObj = (m_FrontObject.transform.position - transform.position).sqrMagnitude;

        // ���݂̐��ʃI�u�W�F�N�g�Ƃ̋����𐳋K������
        m_StickTilt = movePoint.magnitude;//m_DistToFrontObj / (m_MagDistToFrontObj * m_MagDistToFrontObj);
    }

    /* �e�ێ��J�ڏ��� */
    private void HoldShadowControl()
    {
        /* �e���G��Ă���Ƃ� */
        if (m_ShadowMode.shadowHit||m_ShadowMode.isLSwitchHit)
        {
            /* �g���K�[��������Ă���Ȃ�e��͂� */
            isHold = m_ControlManager.GetTriggerSqueeze(m_HoldShadow.Direction, m_HoldShadow.Deadzone);
            if (!m_ControlManager.GetConnect()) isHold = m_ControlManager.GetHoldPress(m_GrabShadowKey);
            m_ShadowMode.SetShadow(isHold);
        }
        else
        {
            /* �݂͂��������Ă���Ȃ�L�����Z������ */
            if(isHold) isHold = false;
        }
    }
}
