using System.Collections;
using System.Collections.Generic;
using UnityEngine;


// �쐬��2023/03/11    �X�V��2023/03/12
// �{��
public class FPS_Anchor : MonoBehaviour
{
    // �t���[�����[�g�v���Ǘ�
    // �t���[�����[�g�\���̐ݒ�
    [Tooltip("�t���[�����[�g��\�����邩")]
    [SerializeField] private bool displayFrameRate;

    // �\���t���[�����X�V����Ԋu
    [Tooltip("�\���Ԋu��ύX")]
    [SerializeField] private float frameInterval = 0.5f;

    // �t���[�����[�g�̎w��
    [Tooltip("�t���[�����[�g�̐ݒ�")]
    [SerializeField] private int frameRate = 60;

    // �t���[�����[�g�ύX��p�̕ϐ�
    private int frameRateRevision;

    public static FPS_Anchor instance;

    // 
    private float m_timeCount;
    private int m_frame;

    private float m_time_mn;
    public float m_fps;

    //�����g����������Ȃ��V���O���g��
    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(this.gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void Start()
    {

        // �t���[�����[�g���ꎞ�I�ɕێ�
        frameRateRevision = frameRate;

        // �t���[�����[�g�̎w��
        Application.targetFrameRate = frameRate;
    }

    private void Update()
    {
        // �t���[�����[�g���X�V���ꂽ�Ƃ��̏���
        if (frameRate != frameRateRevision)
        {//----- if_start -----

            // �C����̃t���[�����[�g���ꎞ�I�ɕێ�
            frameRateRevision = frameRate;

            // �t���[�����[�g�̎w��
            Application.targetFrameRate = frameRate;

            // �t���[�����[�g�X�V�̃��O
            Debug.Log("�t���[�����[�g��(" + frameRate + "Frame)�ɕύX���܂����I");

        }//----- if_stop -----

        // ���Ԃ̌v��
        m_time_mn -= Time.deltaTime;
        m_timeCount += Time.timeScale / Time.deltaTime;
        m_frame++;

        // �o�ߎ��ԓ��Ȃ珈���𔲂���
        if (0 < m_time_mn)
        {//----- if_start -----

            return;

        }//----- if_stop -----

        // fps�̌v�Z
        m_fps = m_timeCount / m_frame;

        // fps�J�E���g�̏�����
        m_time_mn = frameInterval;
        m_timeCount = 0;
        m_frame = 0;

    }

    // �t���[�����[�g�̕\������
    // �쐬��2023/03/11
    // �{��
    private void OnGUI()
    {
        // �t���[�����[�g��\�����邩
        if (displayFrameRate)
        {//----- if_start -----

            // ��ʓ���FPS��\������(��FFPS:60)
            GUILayout.Label("FPS : " + m_fps.ToString("f0"));

        }//----- if_stop -----
    }
}
